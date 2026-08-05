#!/usr/bin/env python3
"""Guarded Vercel-to-AWS migration v3 planner.

This foundation validates a site manifest, classifies routes, creates resumable
checkpoint receipts, and refuses to classify an unexecuted migration as REAL.
AWS mutation adapters are deliberately gated until implemented and verified.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import sys
from datetime import datetime, timezone
from typing import Any

SCHEMA = "t4h.vercel_aws_migration.site_manifest.v3"
STAGES = [
    "source_refresh",
    "inventory",
    "route_classification",
    "build",
    "s3_publish",
    "s3_readback",
    "cloudfront",
    "acm",
    "pre_cutover_validation",
    "dns_snapshot",
    "route53_cutover",
    "live_https_validation",
    "rollback_window",
    "final_receipt",
]
ROUTE_CLASSES = {"static", "dynamic", "externalized", "unsupported", "quarantined"}


class ManifestError(ValueError):
    pass


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def canonical_hash(value: Any) -> str:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(encoded).hexdigest()


def require_string(value: Any, path: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ManifestError(f"{path} must be a non-empty string")
    return value.strip()


def validate_manifest(data: Any) -> dict[str, Any]:
    if not isinstance(data, dict):
        raise ManifestError("manifest must be an object")
    if data.get("schema") != SCHEMA:
        raise ManifestError(f"schema must equal {SCHEMA}")
    for key in ("site_id", "repository", "source_ref", "domain", "owner"):
        require_string(data.get(key), key)
    aws = data.get("aws")
    if not isinstance(aws, dict):
        raise ManifestError("aws must be an object")
    for key in ("account_id", "region", "bucket"):
        require_string(aws.get(key), f"aws.{key}")
    routes = data.get("routes")
    if not isinstance(routes, list) or not routes:
        raise ManifestError("routes must be a non-empty array")
    seen: set[str] = set()
    for index, route in enumerate(routes):
        if not isinstance(route, dict):
            raise ManifestError(f"routes[{index}] must be an object")
        path = require_string(route.get("path"), f"routes[{index}].path")
        if not path.startswith("/"):
            raise ManifestError(f"routes[{index}].path must start with /")
        if path in seen:
            raise ManifestError(f"duplicate route: {path}")
        seen.add(path)
        classification = route.get("classification")
        if classification not in ROUTE_CLASSES:
            raise ManifestError(
                f"routes[{index}].classification must be one of {sorted(ROUTE_CLASSES)}"
            )
        require_string(route.get("owner"), f"routes[{index}].owner")
        require_string(route.get("lifecycle"), f"routes[{index}].lifecycle")
        evidence = route.get("evidence")
        if not isinstance(evidence, list) or not evidence:
            raise ManifestError(f"routes[{index}].evidence must be a non-empty array")
        if classification != "static":
            require_string(route.get("reason"), f"routes[{index}].reason")
            dependency = route.get("dependency")
            if not isinstance(dependency, dict) or not dependency:
                raise ManifestError(
                    f"routes[{index}].dependency is required for non-static routes"
                )
    required_routes = data.get("acceptance", {}).get("required_routes")
    if not isinstance(required_routes, list) or "/" not in required_routes:
        raise ManifestError("acceptance.required_routes must include /")
    missing = sorted(set(required_routes) - seen)
    if missing:
        raise ManifestError(f"required routes missing from inventory: {missing}")
    return data


def migration_plan(manifest: dict[str, Any]) -> dict[str, Any]:
    routes = manifest["routes"]
    counts = {
        classification: sum(r["classification"] == classification for r in routes)
        for classification in sorted(ROUTE_CLASSES)
    }
    unresolved = [
        r["path"]
        for r in routes
        if r["classification"] in {"dynamic", "unsupported", "quarantined"}
        and not r.get("accepted_disposition")
    ]
    return {
        "schema": "t4h.vercel_aws_migration.plan.v3",
        "site_id": manifest["site_id"],
        "domain": manifest["domain"],
        "manifest_sha256": canonical_hash(manifest),
        "stages": [{"id": stage, "status": "PENDING"} for stage in STAGES],
        "route_counts": counts,
        "unresolved_runtime_routes": unresolved,
        "classification": "PARTIAL",
        "real_gate": (
            "All required stages must execute with receipts, ledger entries, telemetry, "
            "provider readback, live HTTPS validation and tested rollback."
        ),
        "created_at": now(),
    }


def checkpoint_path(run_root: pathlib.Path, stage: str) -> pathlib.Path:
    return run_root / "checkpoints" / f"{stage}.json"


def write_checkpoint(
    run_root: pathlib.Path,
    stage: str,
    status: str,
    evidence: dict[str, Any],
) -> pathlib.Path:
    if stage not in STAGES:
        raise ManifestError(f"unknown stage: {stage}")
    if status not in {"SUCCEEDED", "FAILED", "BLOCKED"}:
        raise ManifestError("checkpoint status must be SUCCEEDED, FAILED or BLOCKED")
    receipt = {
        "schema": "t4h.vercel_aws_migration.checkpoint.v3",
        "stage": stage,
        "status": status,
        "classification": "PARTIAL",
        "evidence": evidence,
        "evidence_sha256": canonical_hash(evidence),
        "created_at": now(),
    }
    target = checkpoint_path(run_root, stage)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(receipt, indent=2) + "\n")
    return target


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=pathlib.Path)
    parser.add_argument("--run-root", type=pathlib.Path)
    parser.add_argument("--plan-only", action="store_true")
    args = parser.parse_args()

    try:
        manifest = validate_manifest(json.loads(args.manifest.read_text()))
    except (OSError, json.JSONDecodeError, ManifestError) as exc:
        print(json.dumps({"status": "BLOCKED", "error": str(exc)}, indent=2))
        return 2

    plan = migration_plan(manifest)
    run_root = args.run_root or pathlib.Path("runtime/migration-runs") / manifest["site_id"]
    run_root.mkdir(parents=True, exist_ok=True)
    plan_path = run_root / "plan.json"
    plan_path.write_text(json.dumps(plan, indent=2) + "\n")
    write_checkpoint(
        run_root,
        "inventory",
        "SUCCEEDED",
        {
            "manifest": str(args.manifest),
            "manifest_sha256": plan["manifest_sha256"],
            "route_counts": plan["route_counts"],
        },
    )
    output = {
        "status": "PLANNED",
        "classification": "PARTIAL",
        "plan": str(plan_path),
        "unresolved_runtime_routes": plan["unresolved_runtime_routes"],
        "next_action": (
            "Implement and execute receipted AWS adapters."
            if not args.plan_only
            else "Review the plan before execution."
        ),
    }
    print(json.dumps(output, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
