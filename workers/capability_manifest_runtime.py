#!/usr/bin/env python3
"""Deterministic Capability Manifest loader, validator and router for PEN workers."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError as exc:  # pragma: no cover
    raise SystemExit("PyYAML is required: pip install pyyaml") from exc

REQUIRED_MANIFEST_KEYS = {
    "schema", "manifest_id", "owner", "repository", "branch",
    "lifecycle", "truth_state", "registries", "boot_requirements",
}
REQUIRED_REGISTRIES = {"capabilities", "workers", "providers", "operations"}
ALLOWED_TRUTH_STATES = {
    "REAL", "PARTIAL", "DEGRADED", "BLOCKED_WITH_EVIDENCE",
    "QUARANTINED", "ASPIRATIONAL", "INVALIDATED",
}


def canonical_hash(value: Any) -> str:
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def load_yaml(path: Path) -> Any:
    if not path.exists():
        raise ValueError(f"missing registry file: {path}")
    with path.open("r", encoding="utf-8") as handle:
        value = yaml.safe_load(handle)
    if value is None:
        raise ValueError(f"empty registry file: {path}")
    return value


def records(value: Any, preferred_keys: tuple[str, ...]) -> list[dict[str, Any]]:
    if isinstance(value, list):
        return [item for item in value if isinstance(item, dict)]
    if isinstance(value, dict):
        for key in preferred_keys:
            candidate = value.get(key)
            if isinstance(candidate, list):
                return [item for item in candidate if isinstance(item, dict)]
        return [item for item in value.values() if isinstance(item, dict)]
    return []


def record_id(record: dict[str, Any], keys: tuple[str, ...]) -> str:
    for key in keys:
        value = record.get(key)
        if value:
            return str(value)
    return ""


def validate_manifest(manifest_path: Path) -> dict[str, Any]:
    manifest = load_yaml(manifest_path)
    if not isinstance(manifest, dict):
        raise ValueError("manifest must be a mapping")
    missing = sorted(REQUIRED_MANIFEST_KEYS - set(manifest))
    if missing:
        raise ValueError(f"manifest missing required keys: {', '.join(missing)}")
    if manifest.get("truth_state") not in ALLOWED_TRUTH_STATES:
        raise ValueError(f"invalid truth_state: {manifest.get('truth_state')}")
    registries = manifest.get("registries")
    if not isinstance(registries, dict):
        raise ValueError("manifest.registries must be a mapping")
    missing_registries = sorted(REQUIRED_REGISTRIES - set(registries))
    if missing_registries:
        raise ValueError(f"manifest missing registries: {', '.join(missing_registries)}")

    root = manifest_path.parents[2]
    loaded: dict[str, Any] = {}
    registry_hashes: dict[str, str] = {}
    for name, relative_path in registries.items():
        path = root / str(relative_path)
        loaded[name] = load_yaml(path)
        registry_hashes[name] = canonical_hash(loaded[name])

    result = {
        "manifest": manifest,
        "registries": loaded,
        "manifest_hash": canonical_hash(manifest),
        "registry_hashes": registry_hashes,
        "root": str(root),
    }
    return result


def select_route(bundle: dict[str, Any], job: dict[str, Any]) -> dict[str, Any]:
    required = set(job.get("required_capabilities") or job.get("capabilities") or [])
    authority = set(job.get("authority", {}).get("operations", []))
    workers = records(bundle["registries"]["workers"], ("workers", "items", "records"))
    providers = records(bundle["registries"]["providers"], ("providers", "items", "records"))

    provider_map = {
        record_id(provider, ("provider_id", "id", "name")): provider
        for provider in providers
        if record_id(provider, ("provider_id", "id", "name"))
    }

    eligible: list[dict[str, Any]] = []
    rejected: list[dict[str, Any]] = []
    for worker in workers:
        worker_id = record_id(worker, ("worker_id", "id", "name"))
        capabilities = set(worker.get("capabilities") or worker.get("capability_ids") or [])
        permitted = set(worker.get("authority") or worker.get("allowed_operations") or [])
        lifecycle = str(worker.get("lifecycle") or worker.get("lifecycle_state") or "production_candidate")
        health = str(worker.get("health") or worker.get("health_state") or "UNKNOWN")
        truth = str(worker.get("truth_state") or "PARTIAL")
        reasons: list[str] = []
        if required and not required.issubset(capabilities):
            reasons.append("capability_mismatch")
        if authority and permitted and not authority.issubset(permitted):
            reasons.append("authority_mismatch")
        if lifecycle.lower() in {"deprecated", "retired", "destroyed", "quarantined"}:
            reasons.append("invalid_lifecycle")
        if health.upper() in {"DOWN", "FAILED", "UNHEALTHY", "QUARANTINED"}:
            reasons.append("unhealthy")
        if truth in {"QUARANTINED", "INVALIDATED"}:
            reasons.append("invalid_truth_state")
        provider_id = str(worker.get("provider_id") or worker.get("provider") or "")
        provider = provider_map.get(provider_id, {})
        provider_health = str(provider.get("health") or provider.get("health_state") or "UNKNOWN")
        if provider_health.upper() in {"DOWN", "FAILED", "UNHEALTHY", "QUARANTINED"}:
            reasons.append("provider_unhealthy")
        candidate = {
            "worker_id": worker_id,
            "provider_id": provider_id,
            "worker": worker,
            "provider": provider,
        }
        if reasons:
            candidate["reasons"] = reasons
            rejected.append(candidate)
        else:
            cost = worker.get("cost_score", provider.get("cost_score", 100))
            reliability = worker.get("reliability_score", provider.get("reliability_score", 0))
            candidate["routing_score"] = float(reliability or 0) - float(cost or 0)
            eligible.append(candidate)

    eligible.sort(key=lambda item: (-item["routing_score"], item["worker_id"]))
    if not eligible:
        raise RuntimeError(json.dumps({"error": "no eligible route", "rejected": rejected}, sort_keys=True))
    primary = eligible[0]
    fallback = eligible[1] if len(eligible) > 1 else None
    return {
        "primary": {k: v for k, v in primary.items() if k not in {"worker", "provider"}},
        "fallback": ({k: v for k, v in fallback.items() if k not in {"worker", "provider"}} if fallback else None),
        "eligible_count": len(eligible),
        "rejected": [{"worker_id": item["worker_id"], "reasons": item["reasons"]} for item in rejected],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default="registry/worker-capability/capability-manifest.yaml")
    parser.add_argument("--job")
    parser.add_argument("--output")
    args = parser.parse_args()

    bundle = validate_manifest(Path(args.manifest))
    result: dict[str, Any] = {
        "schema": "t4h.pen.capability-manifest-validation.v1",
        "status": "VALID",
        "manifest_hash": bundle["manifest_hash"],
        "registry_hashes": bundle["registry_hashes"],
    }
    if args.job:
        with Path(args.job).open("r", encoding="utf-8") as handle:
            job = json.load(handle)
        result["job_hash"] = canonical_hash(job)
        result["route"] = select_route(bundle, job)
    result["result_hash"] = canonical_hash(result)
    rendered = json.dumps(result, indent=2, sort_keys=True)
    if args.output:
        output = Path(args.output)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(rendered + "\n", encoding="utf-8")
    print(rendered)


if __name__ == "__main__":
    main()
