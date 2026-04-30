#!/usr/bin/env python3
"""
pen_worker.py — T4H Pen Execution Worker
Reads an inbox JSON job, executes it via bridge, writes a receipt.
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
        BRIDGE_URL, data=data,
        headers={"Content-Type": "application/json", "x-api-key": BRIDGE_KEY},
        method="POST"
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.load(r), r.status
    except urllib.error.HTTPError as e:
        return {"error": str(e), "body": e.read().decode()[:500]}, e.code
    except Exception as e:
        return {"error": str(e)}, 500


def write_receipt(receipts_dir, job, result, status, idempotency_key, commit_sha):
    os.makedirs(receipts_dir, exist_ok=True)
    ts = datetime.datetime.utcnow().isoformat() + "Z"
    safe_key = idempotency_key.replace("/", "_").replace(" ", "_")[:80]
    receipt_path = os.path.join(receipts_dir, f"{safe_key}.receipt.json")
    receipt = {
        "idempotency_key": idempotency_key,
        "commit_sha": commit_sha,
        "job_path": job.get("_source_path", ""),
        "fn": job.get("fn", job.get("action", "")),
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
        hashlib.sha256(json.dumps(job, sort_keys=True).encode()).hexdigest()[:16]
    )

    print(f"Processing job: {args.job}")
    print(f"idempotency_key: {idempotency_key}")
    print(f"commit_sha: {commit_sha}")

    fn = job.get("fn", job.get("action", ""))
    payload = job.get("payload", job.get("data", {}))

    if not fn:
        print("ERROR: no fn or action in job", file=sys.stderr)
        write_receipt(args.receipts_dir, job, {"error": "no fn"}, "error", idempotency_key, commit_sha)
        sys.exit(1)

    if not BRIDGE_URL or not BRIDGE_KEY:
        print("ERROR: BRIDGE_INVOKE_URL and BRIDGE_API_KEY required", file=sys.stderr)
        write_receipt(args.receipts_dir, job, {"error": "no bridge config"}, "error", idempotency_key, commit_sha)
        sys.exit(1)

    result, http_status = bridge_call(fn, payload)
    status = "ok" if http_status == 200 else "error"

    print(f"Bridge response HTTP {http_status}: {json.dumps(result)[:200]}")
    write_receipt(args.receipts_dir, job, result, status, idempotency_key, commit_sha)

    if status != "ok":
        sys.exit(1)


if __name__ == "__main__":
    main()
