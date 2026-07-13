#!/usr/bin/env python3
"""Validate and summarise the canonical T4H portfolio deployment registry.

No deployment is performed. This command enforces the REAL gate and emits a
receipt-grade summary that downstream provision/deploy tools can consume.
"""
from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path
from urllib.parse import urlparse

ALLOWED_STATES = {"OBSERVED", "STALE", "CONFLICTING", "MISSING", "VERIFIED"}
ALLOWED_STATUS = {"REAL", "PARTIAL", "BLOCKED", "ASPIRATIONAL"}
REAL_REQUIRED = (
    "repository",
    "artifact_path",
    "s3_bucket",
    "cloudfront_distribution_id",
    "canonical_url",
    "expected_content_identity",
    "rollback_source",
    "owner",
)


def fail(message: str) -> None:
    print(json.dumps({"status": "BLOCKED", "error": message}, indent=2))
    raise SystemExit(1)


def validate_target(target: dict) -> list[str]:
    errors: list[str] = []
    target_id = target.get("target_id", "<missing>")

    if target.get("status") not in ALLOWED_STATUS:
        errors.append(f"{target_id}: invalid status")

    for field, state in target.get("field_state", {}).items():
        if state not in ALLOWED_STATES:
            errors.append(f"{target_id}: invalid field state {field}={state}")

    url = target.get("canonical_url")
    if url and urlparse(url).scheme != "https":
        errors.append(f"{target_id}: canonical_url must be https")

    if target.get("status") == "REAL":
        for field in REAL_REQUIRED:
            if target.get(field) in (None, "", {}):
                errors.append(f"{target_id}: REAL missing {field}")

        for field in (
            "repository",
            "artifact_path",
            "s3_bucket",
            "cloudfront_distribution_id",
            "canonical_url",
        ):
            if target.get("field_state", {}).get(field) != "VERIFIED":
                errors.append(f"{target_id}: REAL field {field} is not VERIFIED")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--registry", default="registry/portfolio-deployment-targets.json"
    )
    parser.add_argument("--target")
    parser.add_argument("--receipt")
    args = parser.parse_args()

    path = Path(args.registry)
    if not path.is_file():
        fail(f"registry not found: {path}")

    data = json.loads(path.read_text(encoding="utf-8"))
    targets = data.get("targets")
    if not isinstance(targets, list):
        fail("targets must be an array")

    identifiers = [target.get("target_id") for target in targets]
    duplicates = sorted(
        key for key, count in Counter(identifiers).items() if key and count > 1
    )

    errors = [f"duplicate target_id: {identifier}" for identifier in duplicates]
    for target in targets:
        errors.extend(validate_target(target))

    selected = targets
    if args.target:
        selected = [
            target for target in targets if target.get("target_id") == args.target
        ]
        if not selected:
            fail(f"unknown target: {args.target}")

    status_counts = Counter(target.get("status", "UNKNOWN") for target in targets)
    field_counts = Counter(
        state
        for target in targets
        for state in target.get("field_state", {}).values()
    )

    result = {
        "status": "REAL" if not errors else "BLOCKED",
        "registry": str(path),
        "schema_version": data.get("schema_version"),
        "targets_total": len(targets),
        "status_counts": dict(sorted(status_counts.items())),
        "field_state_counts": dict(sorted(field_counts.items())),
        "selected_targets": selected,
        "errors": errors,
    }

    output = json.dumps(result, indent=2)
    print(output)

    if args.receipt:
        receipt = Path(args.receipt)
        receipt.parent.mkdir(parents=True, exist_ok=True)
        receipt.write_text(output + "\n", encoding="utf-8")

    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
