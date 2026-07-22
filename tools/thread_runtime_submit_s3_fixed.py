#!/usr/bin/env python3
"""Hotfixed Pen thread submission operator with byte-clean S3 readback.

The original operator passed /dev/stdout as the AWS CLI get-object destination.
AWS CLI also writes response metadata to stdout, so object bytes and metadata were
combined and every successful readback could be reported as a mismatch.
"""
from __future__ import annotations

import pathlib
import sys
import tempfile

# Import the governed operator and replace only its S3 readback implementation.
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import thread_runtime_submit as base  # noqa: E402


def get_s3_bytes(bucket: str, key: str) -> tuple[bool, bytes, bytes]:
    """Return (exists, object_bytes, stderr) using an isolated temporary file."""
    with tempfile.NamedTemporaryFile(delete=False) as temp:
        target = pathlib.Path(temp.name)
    try:
        result = base.aws(
            "s3api", "get-object",
            "--bucket", bucket,
            "--key", key,
            str(target),
        )
        if result.returncode != 0:
            return False, b"", result.stderr
        return True, target.read_bytes(), result.stderr
    finally:
        target.unlink(missing_ok=True)


def submit_s3_fixed(
    body: bytes,
    submission_id: str,
    bucket: str,
    prefix: str,
    idempotency_key: str,
    content_hash: str,
) -> dict[str, object]:
    key = f"{prefix.rstrip('/')}/{submission_id}.json"
    uri = f"s3://{bucket}/{key}"

    exists, existing_bytes, _ = get_s3_bytes(bucket, key)
    if exists:
        if existing_bytes != body:
            return {
                "status": "CONFLICT",
                "result": "IDEMPOTENCY_CONFLICT",
                "location": uri,
                "readback": "MISMATCH",
                "readback_sha256": base.sha256(existing_bytes),
            }
        created = False
    else:
        with tempfile.NamedTemporaryFile(delete=False) as temp:
            temp.write(body)
            temp_path = pathlib.Path(temp.name)
        try:
            put = base.aws(
                "s3api", "put-object",
                "--bucket", bucket,
                "--key", key,
                "--body", str(temp_path),
                "--content-type", "application/json",
                "--metadata",
                f"idempotency-key={idempotency_key},content-hash={content_hash},schema={base.CANONICAL_SCHEMA}",
            )
        finally:
            temp_path.unlink(missing_ok=True)
        if put.returncode != 0:
            raise SystemExit(
                "BLOCKED: S3 write failed: "
                + put.stderr.decode(errors="replace")
            )
        created = True

    readback_ok, readback_bytes, readback_err = get_s3_bytes(bucket, key)
    if not readback_ok:
        raise SystemExit(
            "BLOCKED: S3 readback failed: "
            + readback_err.decode(errors="replace")
        )
    if readback_bytes != body:
        return {
            "status": "CONFLICT",
            "result": "READBACK_MISMATCH",
            "location": uri,
            "readback": "MISMATCH",
            "readback_sha256": base.sha256(readback_bytes),
        }
    return {
        "status": "ACKED" if created else "EXISTING",
        "result": "THREAD_ACCEPTED" if created else "THREAD_DEDUPLICATED",
        "location": uri,
        "readback": "VERIFIED",
        "readback_sha256": base.sha256(readback_bytes),
    }


base.submit_s3 = submit_s3_fixed

if __name__ == "__main__":
    raise SystemExit(base.main())
