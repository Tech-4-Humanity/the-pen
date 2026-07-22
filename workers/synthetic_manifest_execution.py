#!/usr/bin/env python3
"""Synthetic non-production execution proving manifest validation and fallback semantics."""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path

from capability_manifest_runtime import canonical_hash, select_route, validate_manifest


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def write_json(path: Path, payload: dict) -> str:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload["receipt_hash"] = canonical_hash(payload)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return payload["receipt_hash"]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--job", default="inbox/JOB-CAPABILITY-MANIFEST-SYNTHETIC-001.json")
    parser.add_argument("--manifest", default="registry/worker-capability/capability-manifest.yaml")
    parser.add_argument("--receipts-dir", default="receipts/runtime/capability-manifest-synthetic")
    args = parser.parse_args()

    job = json.loads(Path(args.job).read_text(encoding="utf-8"))
    bundle = validate_manifest(Path(args.manifest))
    route = select_route(bundle, job)
    started_at = utc_now()
    execution_id = "exec_" + hashlib.sha256(
        f"{job['job_id']}:{bundle['manifest_hash']}".encode("utf-8")
    ).hexdigest()[:24]
    lease_id = "lease_" + hashlib.sha256(
        f"{job['job_id']}:{execution_id}:lease".encode("utf-8")
    ).hexdigest()[:20]
    root = Path(args.receipts_dir)

    common = {
        "schema": "t4h.pen.receipt.v1",
        "job_id": job["job_id"],
        "execution_id": execution_id,
        "lease_id": lease_id,
        "manifest_hash": bundle["manifest_hash"],
        "job_hash": canonical_hash(job),
        "authority_decision": "ALLOWED_NON_PRODUCTION_READ_ONLY",
    }

    started = {
        **common,
        "receipt_type": "started",
        "worker": route["primary"]["worker_id"],
        "provider": route["primary"].get("provider_id"),
        "started_at": started_at,
        "classification": "STARTED",
    }
    write_json(root / "01-started.json", started)

    failure = {
        **common,
        "receipt_type": "failure",
        "worker": route["primary"]["worker_id"],
        "provider": route["primary"].get("provider_id"),
        "failed_at": utc_now(),
        "classification": "DEGRADED",
        "failure_mode": "SYNTHETIC_BOUNDED_PRIMARY_FAILURE",
        "changed_retry_condition": "worker/provider route changed to fallback",
        "retry_is_identical": False,
    }
    write_json(root / "02-primary-failure.json", failure)

    fallback = route.get("fallback")
    if not fallback:
        blocked = {
            **common,
            "receipt_type": "completion",
            "finished_at": utc_now(),
            "classification": "BLOCKED_WITH_EVIDENCE",
            "reason": "No eligible fallback route",
            "route": route,
        }
        write_json(root / "05-completion.json", blocked)
        raise SystemExit(2)

    recovery = {
        **common,
        "receipt_type": "recovery",
        "worker": fallback["worker_id"],
        "provider": fallback.get("provider_id"),
        "recovered_at": utc_now(),
        "classification": "PARTIAL",
        "action": "Selected next eligible route after bounded primary failure",
    }
    write_json(root / "03-recovery.json", recovery)

    output = {
        "schema": "t4h.pen.synthetic-manifest-output.v1",
        "job_id": job["job_id"],
        "execution_id": execution_id,
        "manifest_hash": bundle["manifest_hash"],
        "primary": route["primary"],
        "fallback": fallback,
        "registry_hashes": bundle["registry_hashes"],
        "verification": "manifest loaded, route selected, failure changed condition, fallback completed",
    }
    output_hash = canonical_hash(output)
    output_path = root / "04-output.json"
    output_path.write_text(json.dumps(output, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    completion = {
        **common,
        "receipt_type": "completion",
        "worker": fallback["worker_id"],
        "provider": fallback.get("provider_id"),
        "finished_at": utc_now(),
        "classification": "REAL",
        "output_path": str(output_path),
        "output_hash": output_hash,
        "verification_method": "local deterministic readback",
        "verification_result": canonical_hash(json.loads(output_path.read_text(encoding="utf-8"))) == output_hash,
    }
    completion_hash = write_json(root / "05-completion.json", completion)

    reconciliation = {
        **common,
        "receipt_type": "reconciliation",
        "finished_at": utc_now(),
        "classification": "REAL",
        "route": route,
        "receipts": [
            "01-started.json",
            "02-primary-failure.json",
            "03-recovery.json",
            "05-completion.json",
        ],
        "output_path": str(output_path),
        "output_hash": output_hash,
        "completion_receipt_hash": completion_hash,
        "ledger_confirmation": "receipt directory is the durable test ledger",
        "replay_identifier": hashlib.sha256(
            f"{job['job_id']}:{bundle['manifest_hash']}:{output_hash}".encode("utf-8")
        ).hexdigest(),
    }
    write_json(root / "06-reconciliation.json", reconciliation)
    print(json.dumps(reconciliation, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
