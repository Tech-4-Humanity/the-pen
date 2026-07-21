#!/usr/bin/env python3
"""Provider-neutral governed thread ingress for Pen.

Accepts either:
1. a canonical ``pen.thread-runtime.envelope.v1`` envelope; or
2. the legacy compact payload used by the original Pen ingress utility.

Durable truth is the canonical JSON object plus an independently verified
readback receipt. Supabase is optional and never blocks acceptance.
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

CANONICAL_SCHEMA = "pen.thread-runtime.envelope.v1"
LEGACY_SCHEMA = "t4h.thread-runtime-envelope.v1"
RECEIPT_SCHEMA = "pen.thread-runtime.receipt.v1"
VALID_STATES = {
    "REAL", "PARTIAL", "BLOCKED", "DEGRADED", "QUARANTINED",
    "ASPIRATIONAL", "INVALIDATED",
}


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def canonical_json(value: Any) -> bytes:
    return json.dumps(
        value,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    ).encode("utf-8")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_json(path: str | None) -> dict[str, Any]:
    raw = pathlib.Path(path).read_bytes() if path else sys.stdin.buffer.read()
    try:
        value = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"BLOCKED: invalid JSON: {exc}") from exc
    if not isinstance(value, dict):
        raise SystemExit("BLOCKED: payload must be a JSON object")
    return value


def validate_canonical(envelope: dict[str, Any]) -> None:
    thread = envelope.get("thread")
    if not isinstance(thread, dict):
        raise SystemExit("BLOCKED: canonical envelope requires thread object")
    missing = [
        key for key in ("source_system", "source_thread_reference", "title", "purpose")
        if not thread.get(key)
    ]
    if missing:
        raise SystemExit("BLOCKED: missing thread fields: " + ", ".join(missing))
    classification = envelope.get("classification")
    if not isinstance(classification, dict):
        raise SystemExit("BLOCKED: canonical envelope requires classification object")
    state = classification.get("state")
    if state not in VALID_STATES:
        raise SystemExit(f"BLOCKED: invalid classification.state: {state!r}")


def validate_legacy(payload: dict[str, Any]) -> None:
    required = ["source_system", "source_thread_id", "principal_id", "title", "content"]
    missing = [key for key in required if not payload.get(key)]
    if missing:
        raise SystemExit(f"BLOCKED: missing required fields: {', '.join(missing)}")
    if not isinstance(payload["content"], (str, dict, list)):
        raise SystemExit("BLOCKED: content must be string, object, or array")


def normalise(payload: dict[str, Any]) -> dict[str, Any]:
    if payload.get("schema") == CANONICAL_SCHEMA:
        validate_canonical(payload)
        return payload

    validate_legacy(payload)
    return {
        "schema": CANONICAL_SCHEMA,
        "envelope_mode": "SHORT",
        "thread": {
            "source_system": payload["source_system"],
            "source_thread_reference": payload["source_thread_id"],
            "title": payload["title"],
            "purpose": "Provider-neutral Pen thread ingestion",
            "captured_at": utc_now(),
        },
        "classification": {
            "state": payload.get("classification", "PARTIAL"),
            "rationale": "Legacy compact payload normalised by Pen ingress.",
        },
        "facts": {"content": payload["content"], "attachments": payload.get("attachments", [])},
        "governance": {
            "principal_id": payload["principal_id"],
            "owner": payload.get("owner"),
            "authority": payload.get("authority", {}),
            "privacy_class": payload.get("privacy_class", "internal"),
            "retention_policy": payload.get("retention_policy", "institutional"),
        },
        "whole_of_life_business_assessment": {
            "whole_of_life": payload.get("whole_of_life", {}),
            "whole_of_business": payload.get("whole_of_business", {}),
        },
        "workfamilyai_heatmap_inputs": payload.get("workfamilyai_heatmap_inputs", {}),
        "disposition": {"final": payload.get("requested_disposition", "CONTINUE")},
    }


def identity(envelope: dict[str, Any]) -> tuple[str, str, str]:
    body = canonical_json(envelope)
    content_hash = sha256(body)
    thread = envelope["thread"]
    idempotency_key = sha256(
        (
            f"{thread['source_system']}\n"
            f"{thread['source_thread_reference']}\n"
            f"{content_hash}"
        ).encode("utf-8")
    )
    return content_hash, idempotency_key, f"thr_{idempotency_key[:24]}"


def atomic_create(path: pathlib.Path, data: bytes) -> tuple[bool, bytes]:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        return False, path.read_bytes()
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as temp:
        temp.write(data)
        temp.flush()
        os.fsync(temp.fileno())
        temp_path = pathlib.Path(temp.name)
    try:
        os.link(temp_path, path)
        return True, path.read_bytes()
    except FileExistsError:
        return False, path.read_bytes()
    finally:
        temp_path.unlink(missing_ok=True)


def submit_local(body: bytes, submission_id: str, root: pathlib.Path) -> dict[str, Any]:
    target = root / "inbox" / f"{submission_id}.json"
    created, readback = atomic_create(target, body)
    if readback != body:
        return {
            "status": "CONFLICT",
            "result": "IDEMPOTENCY_CONFLICT",
            "location": str(target),
            "readback": "MISMATCH",
            "readback_sha256": sha256(readback),
        }
    return {
        "status": "ACKED" if created else "EXISTING",
        "result": "THREAD_ACCEPTED" if created else "THREAD_DEDUPLICATED",
        "location": str(target),
        "readback": "VERIFIED",
        "readback_sha256": sha256(readback),
    }


def aws(*args: str, input_bytes: bytes | None = None) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(["aws", *args], input=input_bytes, capture_output=True)


def submit_s3(
    body: bytes,
    submission_id: str,
    bucket: str,
    prefix: str,
    idempotency_key: str,
    content_hash: str,
) -> dict[str, Any]:
    key = f"{prefix.rstrip('/')}/{submission_id}.json"
    uri = f"s3://{bucket}/{key}"

    existing = aws("s3api", "get-object", "--bucket", bucket, "--key", key, "/dev/stdout")
    if existing.returncode == 0:
        if existing.stdout != body:
            return {
                "status": "CONFLICT",
                "result": "IDEMPOTENCY_CONFLICT",
                "location": uri,
                "readback": "MISMATCH",
                "readback_sha256": sha256(existing.stdout),
            }
        created = False
    else:
        with tempfile.NamedTemporaryFile(delete=False) as temp:
            temp.write(body)
            temp_path = pathlib.Path(temp.name)
        try:
            put = aws(
                "s3api", "put-object",
                "--bucket", bucket,
                "--key", key,
                "--body", str(temp_path),
                "--content-type", "application/json",
                "--metadata", f"idempotency-key={idempotency_key},content-hash={content_hash},schema={CANONICAL_SCHEMA}",
            )
        finally:
            temp_path.unlink(missing_ok=True)
        if put.returncode != 0:
            raise SystemExit(f"BLOCKED: S3 write failed: {put.stderr.decode(errors='replace')}")
        created = True

    readback = aws("s3api", "get-object", "--bucket", bucket, "--key", key, "/dev/stdout")
    if readback.returncode != 0:
        raise SystemExit(f"BLOCKED: S3 readback failed: {readback.stderr.decode(errors='replace')}")
    if readback.stdout != body:
        return {
            "status": "CONFLICT",
            "result": "READBACK_MISMATCH",
            "location": uri,
            "readback": "MISMATCH",
            "readback_sha256": sha256(readback.stdout),
        }
    return {
        "status": "ACKED" if created else "EXISTING",
        "result": "THREAD_ACCEPTED" if created else "THREAD_DEDUPLICATED",
        "location": uri,
        "readback": "VERIFIED",
        "readback_sha256": sha256(readback.stdout),
    }


def write_receipt(root: pathlib.Path, receipt: dict[str, Any]) -> pathlib.Path:
    target = root / "receipts" / f"{receipt['submission_id']}.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return target


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", help="JSON input file; defaults to stdin")
    parser.add_argument("--backend", choices=["local", "s3"], default=os.getenv("T4H_THREAD_BACKEND", "local"))
    parser.add_argument("--runtime-root", default=os.getenv("T4H_THREAD_RUNTIME_ROOT", "runtime/thread-ingest"))
    parser.add_argument("--s3-bucket", default=os.getenv("T4H_THREAD_S3_BUCKET"))
    parser.add_argument("--s3-prefix", default=os.getenv("T4H_THREAD_S3_PREFIX", "thread-runtime/current"))
    args = parser.parse_args()

    envelope = normalise(load_json(args.input))
    body = canonical_json(envelope)
    content_hash, idempotency_key, submission_id = identity(envelope)
    root = pathlib.Path(args.runtime_root)

    if args.backend == "local":
        outcome = submit_local(body, submission_id, root)
    else:
        if not args.s3_bucket:
            raise SystemExit("BLOCKED: --s3-bucket or T4H_THREAD_S3_BUCKET is required")
        outcome = submit_s3(
            body, submission_id, args.s3_bucket, args.s3_prefix,
            idempotency_key, content_hash,
        )

    receipt = {
        "schema": RECEIPT_SCHEMA,
        "submission_id": submission_id,
        "idempotency_key": idempotency_key,
        "content_hash": content_hash,
        "backend": args.backend,
        "classification": envelope["classification"]["state"],
        "source_system": envelope["thread"]["source_system"],
        "source_thread_reference": envelope["thread"]["source_thread_reference"],
        "recorded_at": utc_now(),
        "supabase_required": False,
        **outcome,
    }
    receipt_path = write_receipt(root, receipt)
    receipt["receipt"] = str(receipt_path)
    print(json.dumps(receipt, indent=2, sort_keys=True))

    return 0 if receipt["status"] in {"ACKED", "EXISTING"} and receipt["readback"] == "VERIFIED" else 1


if __name__ == "__main__":
    raise SystemExit(main())
