#!/usr/bin/env python3
"""
pen_worker.py — T4H Pen Execution Worker
Reads an inbox JSON job, normalises governed orchestration envelopes,
executes them via bridge, and writes a receipt.
"""
import argparse
import json
import os
import sys
import hashlib
import datetime
import urllib.request
import urllib.error

BRIDGE_URL = os.environ.get("BRIDGE_INVOKE_URL", "")
BRIDGE_KEY = os.environ.get("BRIDGE_API_KEY", "")
SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE", "")


def bridge_call(fn, payload):
    data = json.dumps({"fn": fn, "payload": payload}).encode()
    req = urllib.request.Request(
        BRIDGE_URL,
        data=data,
        headers={"Content-Type": "application/json", "x-api-key": BRIDGE_KEY},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.load(r), r.status
    except urllib.error.HTTPError as e:
        return {"error": str(e), "body": e.read().decode()[:500]}, e.code
    except Exception as e:
        return {"error": str(e)}, 500


def normalise_bridge_request(job):
    """Return a bridge function and payload for legacy and governed job envelopes."""
    fn = job.get("fn") or job.get("action")
    payload = job.get("payload", job.get("data"))

    if fn:
        return fn, payload if payload is not None else {}

    if job.get("target") == "BRIDGE_RUNNER":
        payload = {
            "job_id": job.get("job_id"),
            "priority": job.get("priority", "P1"),
            "repository": job.get("repository"),
            "branch": job.get("branch", "main"),
            "objective": job.get("objective") or job.get("truth"),
            "source_script": job.get("source_script"),
            "steps": job.get("steps") or job.get("execution") or [],
            "required_outputs": job.get("required_outputs") or job.get("required_receipts") or [],
            "acceptance": job.get("acceptance") or [],
            "production_resources": job.get("production_resources", False),
            "no_hitl": job.get("no_hitl", True),
            "source_envelope": job,
        }
        return "organisation_accept", payload

    return "", {}


def write_receipt(receipts_dir, job, result, status, idempotency_key, commit_sha):
    os.makedirs(receipts_dir, exist_ok=True)
    ts = datetime.datetime.now(datetime.timezone.utc).isoformat()
    safe_key = idempotency_key.replace("/", "_").replace(" ", "_")[:80]
    receipt_path = os.path.join(receipts_dir, f"{safe_key}.receipt.json")
    receipt = {
        "idempotency_key": idempotency_key,
        "commit_sha": commit_sha,
        "job_path": job.get("_source_path", ""),
        "fn": job.get("_normalised_fn", job.get("fn", job.get("action", ""))),
        "status": status,
        "evidence_state": "REAL" if status == "ok" else "PARTIAL",
        "executed_at": ts,
        "result_summary": result,
    }
    with open(receipt_path, "w") as f:
        json.dump(receipt, f, indent=2)
    print(f"Receipt written: {receipt_path}")
    return receipt_path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--job", required=True)
    parser.add_argument("--receipts-dir", default="receipts/runtime")
    args = parser.parse_args()

    commit_sha = os.environ.get("GITHUB_SHA", "unknown")

    with open(args.job) as f:
        job = json.load(f)
    job["_source_path"] = args.job

    idempotency_key = job.get(
        "idempotency_key",
        job.get("job_id")
        or hashlib.sha256(json.dumps(job, sort_keys=True).encode()).hexdigest()[:16],
    )

    print(f"Processing job: {args.job}")
    print(f"idempotency_key: {idempotency_key}")
    print(f"commit_sha: {commit_sha}")

    fn, payload = normalise_bridge_request(job)
    job["_normalised_fn"] = fn

    if not fn:
        print("ERROR: no fn/action and envelope is not targeted to BRIDGE_RUNNER", file=sys.stderr)
        write_receipt(
            args.receipts_dir,
            job,
            {"error": "unsupported job envelope"},
            "error",
            idempotency_key,
            commit_sha,
        )
        sys.exit(1)

    if not BRIDGE_URL or not BRIDGE_KEY:
        print("ERROR: BRIDGE_INVOKE_URL and BRIDGE_API_KEY required", file=sys.stderr)
        write_receipt(
            args.receipts_dir,
            job,
            {"error": "no bridge config"},
            "error",
            idempotency_key,
            commit_sha,
        )
        sys.exit(1)

    result, http_status = bridge_call(fn, payload)
    status = "ok" if http_status == 200 else "error"

    print(f"Bridge response HTTP {http_status}: {json.dumps(result)[:200]}")
    write_receipt(args.receipts_dir, job, result, status, idempotency_key, commit_sha)

    if status != "ok":
        sys.exit(1)


if __name__ == "__main__":
    main()
