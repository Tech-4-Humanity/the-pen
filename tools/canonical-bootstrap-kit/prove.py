#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import pathlib
import shutil
import subprocess
import tempfile
from datetime import datetime, timezone

ROOT = pathlib.Path(__file__).resolve().parent
CBK = ROOT / "cbk.py"


def run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, text=True, capture_output=True, check=True)


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="cbk-proof-") as temp:
        base = pathlib.Path(temp)
        created = run("python3", str(CBK), "new", "research", "ai-sweet-spots", "--output", str(base))
        target = base / "ai-sweet-spots"
        validation = run("python3", str(CBK), "validate", str(target))
        manifest_process = run("python3", str(CBK), "compile", str(target))
        tests = run("python3", "-m", "unittest", "discover", "-s", str(target / "tests"))
        manifest = json.loads(manifest_process.stdout)
        receipt = {
            "schema_version": "cbk.execution-receipt.v0.1",
            "receipt_id": "cbk-proof-" + manifest["content_hash"][:16],
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "capability": "canonical-bootstrap-kit-v0.1",
            "classification": "REAL",
            "execution": {
                "generator_exit": created.returncode,
                "validator_exit": validation.returncode,
                "compiler_exit": manifest_process.returncode,
                "tests_exit": tests.returncode,
            },
            "generated_project": "research/ai-sweet-spots",
            "content_hash": manifest["content_hash"],
            "manifest_file_count": len(manifest["files"]),
            "runtime_readback": None,
        }
        out = ROOT / "receipts"
        out.mkdir(exist_ok=True)
        receipt_path = out / "cbk-v0.1-proof.json"
        receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
        readback = json.loads(receipt_path.read_text())
        readback_ok = readback["content_hash"] == manifest["content_hash"] and readback["classification"] == "REAL"
        receipt["runtime_readback"] = {
            "path": str(receipt_path.relative_to(ROOT)),
            "readback_ok": readback_ok,
            "sha256": hashlib.sha256(receipt_path.read_bytes()).hexdigest(),
        }
        receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
        final = json.loads(receipt_path.read_text())
        if not final["runtime_readback"]["readback_ok"]:
            raise RuntimeError("receipt readback failed")
        print(json.dumps(final, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
