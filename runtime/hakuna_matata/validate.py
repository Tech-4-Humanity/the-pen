#!/usr/bin/env python3
"""Dependency-free validator for Hakuna Matata registry contracts."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / "registry" / "hakuna-matata" / "tables.json"
VALID_STATES = {"REAL", "PARTIAL", "BLOCKED", "DEGRADED", "QUARANTINED", "ASPIRATIONAL"}
REQUIRED = {
    "table_id", "name", "purpose", "owner", "lifecycle", "schema_version",
    "relationships", "validators", "producers", "consumers",
    "evidence_required", "next_valid_states", "status"
}


def main() -> int:
    document = json.loads(REGISTRY.read_text(encoding="utf-8"))
    tables = document.get("tables", [])
    ids = [table.get("table_id") for table in tables]
    errors: list[str] = []

    if not tables:
        errors.append("registry contains no tables")
    if len(ids) != len(set(ids)):
        errors.append("duplicate table_id values")

    known = set(ids)
    for index, table in enumerate(tables):
        missing = sorted(REQUIRED - set(table))
        if missing:
            errors.append(f"tables[{index}] {table.get('table_id')}: missing {missing}")
        if table.get("status") not in VALID_STATES:
            errors.append(f"{table.get('table_id')}: invalid status")
        if not table.get("validators"):
            errors.append(f"{table.get('table_id')}: validators empty")
        if not table.get("evidence_required"):
            errors.append(f"{table.get('table_id')}: evidence_required empty")
        for relationship in table.get("relationships", []):
            target = relationship.get("target_table")
            if target not in known:
                errors.append(f"{table.get('table_id')}: unknown relationship target {target}")

    result = {
        "classification": "REAL" if not errors else "BLOCKED",
        "table_count": len(tables),
        "relationship_count": sum(len(t.get("relationships", [])) for t in tables),
        "errors": errors,
        "next_valid_state": "ready" if not errors else "repair",
    }
    print(json.dumps(result, indent=2))
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
