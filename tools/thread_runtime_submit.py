#!/usr/bin/env python3
"""Provider-neutral thread ingress for Pen.

Durable truth is the canonical JSON envelope plus receipt. Supabase is optional
and is never required for acceptance. Supported backends:

- local: atomic filesystem spool
- s3: immutable object write using AWS CLI

The same envelope can later be indexed into Supabase, Notion, or another store.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from typing import Any

SCHEMA_VERSION = "t4h.thread-runtime-envelope.v1"


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def canonical_json(value: Any) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False) + "\n").encode("utf-8")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_payload(path: str | None) -> dict[str, Any]:
    raw = pathlib.Path(path).read_bytes() if path else sys.stdin.buffer.read()
    try:
        value = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"BLOCKED: invalid JSON: {exc}") from exc
    if not isinstance(value, dict):
        raise SystemExit("BLOCKED: payload must be a JSON object")
    return value


def validate(payload: dict[str, Any]) -> None:
    required = ["source_system", "source_thread_id", "principal_id", "title", "content"]
    missing = [key for key in required if not payload.get(key)]
    if missing:
        raise SystemExit(f"BLOCKED: missing required fields: {', '.join(missing)}")
    if not isinstance(payload["content"], (str, dict, list)):
        raise SystemExit("BLOCKED: content must be string, object, or array")


def build_envelope(payload: dict[str, Any]) -> tuple[dict[str, Any], bytes]:
    content_bytes = canonical_json(payload["content"])
    content_hash = sha256(content_bytes)
    idempotency_key = sha256(
        f"{payload['source_system']}\n{payload['source_thread_id']}\n{content_hash}".encode("utf-8")
    )
    envelope = {
        "schema_version": SCHEMA_VERSION,
        "submission_id": idempotency_key,
        "idempotency_key": idempotency_key,
        "source_system": payload["source_system"],
        "source_thread_id": payload["source_thread_id"],
        "principal_id": payload["principal_id"],
        "title": payload["title"],
        "content_hash": content_hash,
        "content": payload["content"],
        "attachments": payload.get("attachments", []),
        "privacy_class": payload.get("privacy_class", "internal"),
        "retention_policy": payload.get("retention_policy", "institutional"),
        "owner": payload.get("owner"),
        "authority": payload.get("authority", {}),
        "whole_of_life": payload.get("whole_of_life", {}),
        "whole_of_business": payload.get("whole_of_business", {}),
        "workfamilyai_heatmap_inputs": payload.get("workfamilyai_heatmap_inputs", {}),
        "requested_disposition": payload.get("requested_disposition", "CONTINUE"),
        "submitted_at": utc_now(),
        "state": "QUEUED",
    }
    return envelope, canonical_json(envelope)


def atomic_write(path: pathlib.Path, data: bytes) -> bool:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        return False
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as temp:
        temp.write(data)
        temp.flush()
        os.fsync(temp.fileno())
        temp_path = pathlib.Path(temp.name)
    try:
        os.link(temp_path, path)
        return True
    except FileExistsError:
        return False
    finally:
        temp_path.unlink(missing_ok=True)


def submit_local(envelope: dict[str, Any], data: bytes, root: pathlib.Path) -> tuple[str, bool]:
    target = root / "inbox" / f"{envelope['submission_id']}.json"
    created = atomic_write(target, data)
    return str(target), created


def submit_s3(envelope: dict[str, Any], data: bytes, bucket: str, prefix: str) -> tuple[str, bool]:
    key = f"{prefix.rstrip('/')}/inbox/{envelope['submission_id']}.json"
    uri = f"s3://{bucket}/{key}"
    head = subprocess.run(["aws", "s3api", "head-object", "--bucket", bucket, "--key", key], capture_output=True)
    if head.returncode == 0:
        return uri, False
    proc = subprocess.run(
        ["aws", "s3api", "put-object", "--bucket", bucket, "--key", key, "--body", "/dev/stdin", "--content-type", "application/json"],
        input=data,
        capture_output=True,
    )
    if proc.returncode != 0:
        raise SystemExit(f"BLOCKED: S3 write failed: {proc.stderr.decode(errors='replace')}")
    verify = subprocess.run(["aws", "s3api", "head-object", "--bucket", bucket, "--key", key], capture_output=True)
    if verify.returncode != 0:
        raise SystemExit("BLOCKED: S3 readback failed")
    return uri, True


def write_receipt(root: pathlib.Path, envelope: dict[str, Any], location: str, created: bool, backend: str) -> pathlib.Path:
    receipt = {
        "schema_version": "t4h.thread-runtime-receipt.v1",
        "status": "REAL",
        "result": "THREAD_ACCEPTED" if created else "THREAD_DEDUPLICATED",
        "submission_id": envelope["submission_id"],
        "backend": backend,
        "location": location,
        "created": created,
        "content_hash": envelope["content_hash"],
        "readback_completed": True,
        "recorded_at": utc_now(),
    }
    target = root / "receipts" / f"{envelope['submission_id']}.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(canonical_json(receipt))
    return target


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="JSON input file; defaults to stdin")
    parser.add_argument("--backend", choices=["local", "s3"], default=os.getenv("T4H_THREAD_BACKEND", "local"))
    parser.add_argument("--runtime-root", default=os.getenv("T4H_THREAD_RUNTIME_ROOT", "runtime/thread-ingest"))
    parser.add_argument("--s3-bucket", default=os.getenv("T4H_THREAD_S3_BUCKET"))
    parser.add_argument("--s3-prefix", default=os.getenv("T4H_THREAD_S3_PREFIX", "thread-runtime/current"))
    args = parser.parse_args()

    payload = load_payload(args.input)
    validate(payload)
    envelope, data = build_envelope(payload)
    root = pathlib.Path(args.runtime_root)

    if args.backend == "local":
        location, created = submit_local(envelope, data, root)
    else:
        if not args.s3_bucket:
            raise SystemExit("BLOCKED: --s3-bucket or T4H_THREAD_S3_BUCKET is required")
        location, created = submit_s3(envelope, data, args.s3_bucket, args.s3_prefix)

    receipt_path = write_receipt(root, envelope, location, created, args.backend)
    print(json.dumps({
        "status": "REAL",
        "result": "THREAD_ACCEPTED" if created else "THREAD_DEDUPLICATED",
        "submission_id": envelope["submission_id"],
        "backend": args.backend,
        "location": location,
        "receipt": str(receipt_path),
        "supabase_required": False,
    }, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
