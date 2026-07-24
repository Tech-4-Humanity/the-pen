#!/usr/bin/env python3
"""Idempotent bootstrap for the Hakuna Matata runtime pack."""
from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PACK = ROOT / "runtime" / "hakuna_matata"
OUT = PACK / "out"
RECEIPTS = OUT / "receipts"

REQUIRED = [
    ROOT / "registry" / "hakuna-matata" / "tables.json",
    ROOT / "registry" / "hakuna-matata" / "loops.json",
    ROOT / "registry" / "hakuna-matata" / "perspectives.json",
    ROOT / "registry" / "hakuna-matata" / "providers.json",
    ROOT / "schemas" / "hakuna-matata" / "canonical-table.schema.json",
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    digest.update(path.read_bytes())
    return digest.hexdigest()


def main() -> int:
    RECEIPTS.mkdir(parents=True, exist_ok=True)
    missing = [str(p.relative_to(ROOT)) for p in REQUIRED if not p.exists()]
    classification = "REAL" if not missing else "BLOCKED"
    receipt = {
        "receipt_id": f"hakuna-bootstrap-{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}",
        "intent": "bootstrap Hakuna Matata table-of-tables runtime pack",
        "classification": classification,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "missing": missing,
        "evidence": [
            {"path": str(p.relative_to(ROOT)), "sha256": sha256(p)}
            for p in REQUIRED
            if p.exists()
        ],
        "next_valid_state": "validate" if not missing else "recover_missing_files",
        "replay": "python3 runtime/hakuna_matata/bootstrap.py",
    }
    target = RECEIPTS / "bootstrap-latest.json"
    target.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(receipt, indent=2))
    return 0 if not missing else 2


if __name__ == "__main__":
    raise SystemExit(main())
