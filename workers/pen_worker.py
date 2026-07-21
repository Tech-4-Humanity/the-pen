#!/usr/bin/env python3
"""PEN execution worker: read one PEN job, execute it, and always leave proof."""
import argparse
import datetime
import hashlib
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

BRIDGE_URL = os.environ.get("BRIDGE_INVOKE_URL", "")
BRIDGE_KEY = os.environ.get("BRIDGE_API_KEY", "")
CONTRACT_PATH = Path(os.environ.get("PEN_CONTRACT_PATH", "workers/CONTRACT.json"))
REQUIRED_JOB_FIELDS = {"job_id", "objective", "target", "authority", "acceptance", "receipt"}


def utc_now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def load_contract():
    if not CONTRACT_PATH.exists():
        raise RuntimeError(f"worker contract missing: {CONTRACT_PATH}")
    contract = json.loads(CONTRACT_PATH.read_text())
    if not contract.get("mission", {}).get("always_write_receipt"):
        raise RuntimeError("worker contract does not require receipts")
    return contract


def validate_job(job):
    missing = sorted(REQUIRED_JOB_FIELDS - set(job))
    if missing:
        raise ValueError(f"job envelope missing required fields: {', '.join(missing)}")
    if not isinstance(job["target"], dict) or not job["target"].get("type"):
        raise ValueError("job target.type is required")
    operations = job.get("authority", {}).get("operations", [])
    if not operations:
        raise ValueError("job authority.operations is required")
    if not job.get("acceptance"):
        raise ValueError("job acceptance evidence is required")


def bridge_call(fn, payload):
    data = json.dumps({"fn": fn, "payload": payload}).encode()
    req = urllib.request.Request(
        BRIDGE_URL,
        data=data,
        headers={"Content-Type": "application/json", "x-api-key": BRIDGE_KEY},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.load(response), response.status
    except urllib.error.HTTPError as exc:
        return {"error": str(exc), "body": exc.read().decode()[:1000]}, exc.code
    except Exception as exc:
        return {"error": str(exc)}, 500


def normalise_bridge_request(job):
    fn = job.get("fn") or job.get("action")
    payload = job.get("payload", job.get("data"))
    if fn:
        return fn, payload if payload is not None else {}

    target = job.get("target", {})
    legacy_target = job.get("target") == "BRIDGE_RUNNER"
    if isinstance(target, dict) or legacy_target:
        repository = target.get("repository") if isinstance(target, dict) else job.get("repository")
        branch = target.get("branch", "main") if isinstance(target, dict) else job.get("branch", "main")
        payload = {
            "job_id": job.get("job_id"),
            "priority": job.get("priority", "P1"),
            "repository": repository,
            "branch": branch,
            "objective": job.get("objective") or job.get("truth"),
            "target": target,
            "authority": job.get("authority", {}),
            "inputs": job.get("inputs", {}),
            "steps": job.get("steps") or job.get("execution") or [],
            "fallbacks": job.get("fallbacks", []),
            "required_outputs": job.get("required_outputs") or job.get("required_receipts") or [],
            "acceptance": job.get("acceptance") or [],
            "receipt": job.get("receipt", {}),
            "production_resources": job.get("production_resources", False),
            "no_hitl": job.get("no_hitl", True),
            "source_envelope": job,
        }
        return "organisation_accept", payload
    return "", {}


def seal(payload):
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(canonical).hexdigest()


def write_receipt(receipts_dir, job, result, status, idempotency_key, commit_sha, started_at):
    os.makedirs(receipts_dir, exist_ok=True)
    safe_key = idempotency_key.replace("/", "_").replace(" ", "_")[:80]
    configured = job.get("receipt", {}).get("ledger_path")
    receipt_path = configured if configured and not os.path.isabs(configured) else os.path.join(receipts_dir, f"{safe_key}.receipt.json")
    os.makedirs(os.path.dirname(receipt_path), exist_ok=True)
    receipt = {
        "schema": "t4h.pen.receipt.v1",
        "job_id": job.get("job_id", idempotency_key),
        "idempotency_key": idempotency_key,
        "worker": "PEN-Worker-001",
        "status": status,
        "evidence_state": "REAL" if status == "COMPLETE" else status,
        "started_at": started_at,
        "finished_at": utc_now(),
        "commit_sha": commit_sha,
        "job_path": job.get("_source_path", ""),
        "target": job.get("target"),
        "authority_used": job.get("authority", {}).get("operations", []),
        "acceptance": job.get("acceptance", []),
        "normalised_fn": job.get("_normalised_fn", ""),
        "result": result,
    }
    receipt["receipt_hash"] = seal(receipt)
    with open(receipt_path, "w") as handle:
        json.dump(receipt, handle, indent=2)
    print(f"Receipt written: {receipt_path}")
    return receipt_path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--job", required=True)
    parser.add_argument("--receipts-dir", default="receipts/runtime")
    args = parser.parse_args()
    started_at = utc_now()
    commit_sha = os.environ.get("GITHUB_SHA", "unknown")
    job = {}
    idempotency_key = Path(args.job).stem

    try:
        contract = load_contract()
        with open(args.job) as handle:
            job = json.load(handle)
        job["_source_path"] = args.job
        idempotency_key = job.get("idempotency_key") or job.get("job_id") or hashlib.sha256(json.dumps(job, sort_keys=True).encode()).hexdigest()[:16]
        validate_job(job)
        fn, payload = normalise_bridge_request(job)
        job["_normalised_fn"] = fn
        if not fn:
            raise RuntimeError("no authorised executor route for job target")
        if not BRIDGE_URL or not BRIDGE_KEY:
            raise RuntimeError("BRIDGE_INVOKE_URL and BRIDGE_API_KEY are unavailable")
        print(json.dumps({"worker": contract["identity"]["name"], "job": job["job_id"], "target": job["target"]}))
        result, http_status = bridge_call(fn, payload)
        status = "COMPLETE" if http_status == 200 else "BLOCKED"
        write_receipt(args.receipts_dir, job, result, status, idempotency_key, commit_sha, started_at)
        if status != "COMPLETE":
            raise RuntimeError(f"executor returned HTTP {http_status}")
    except Exception as exc:
        result = {"error": type(exc).__name__, "message": str(exc), "next_action": "repair or use an authorised fallback; do not stall the queue"}
        write_receipt(args.receipts_dir, job, result, "BLOCKED", idempotency_key, commit_sha, started_at)
        print(json.dumps(result), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
