#!/usr/bin/env python3
from __future__ import annotations

import json
import pathlib
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "thread_runtime_submit.py"


def run(payload: dict, runtime_root: pathlib.Path) -> dict:
    proc = subprocess.run(
        [sys.executable, str(SCRIPT), "--backend", "local", "--runtime-root", str(runtime_root)],
        input=json.dumps(payload).encode(),
        capture_output=True,
        check=True,
    )
    return json.loads(proc.stdout)


def main() -> None:
    payload = {
        "source_system": "test",
        "source_thread_id": "thread-001",
        "principal_id": "llm.test",
        "title": "Provider-neutral runtime proof",
        "content": {"purpose": "prove intake without Supabase"},
        "requested_disposition": "CONTINUE",
    }
    with tempfile.TemporaryDirectory() as tmp:
        runtime_root = pathlib.Path(tmp)
        first = run(payload, runtime_root)
        second = run(payload, runtime_root)
        assert first["status"] == "REAL"
        assert first["result"] == "THREAD_ACCEPTED"
        assert second["result"] == "THREAD_DEDUPLICATED"
        assert first["submission_id"] == second["submission_id"]
        assert first["supabase_required"] is False
        assert len(list((runtime_root / "inbox").glob("*.json"))) == 1
        assert len(list((runtime_root / "receipts").glob("*.json"))) == 1
    print("provider-neutral thread runtime tests: PASS")


if __name__ == "__main__":
    main()
