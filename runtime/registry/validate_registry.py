#!/usr/bin/env python3
"""Fail-closed validator for the T4H Runtime Capability Registry v1."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


TERMINAL = {"REAL", "BLOCKED_WITH_EVIDENCE", "INVALIDATED"}
FORBIDDEN_TERMINAL = {"PARTIAL", "TRANSFERRED", "STARTED", "QUEUED", "DEGRADED"}


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def ids(items: list[dict[str, Any]], key: str) -> set[str]:
    return {str(item.get(key, "")) for item in items if item.get(key)}


def validate(registry: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    require(registry.get("schema") == "t4h.runtime.capability-registry.v1", "unsupported schema", errors)
    require(registry.get("source_of_truth") is True, "registry must declare source_of_truth=true", errors)

    terminal = set(registry.get("terminal_states", []))
    non_terminal = set(registry.get("non_terminal_states", []))
    require(terminal == TERMINAL, f"terminal_states must equal {sorted(TERMINAL)}", errors)
    require(not (terminal & FORBIDDEN_TERMINAL), "non-terminal state declared terminal", errors)
    require(FORBIDDEN_TERMINAL <= non_terminal, "required non-terminal states missing", errors)

    capabilities = registry.get("capabilities", [])
    workers = registry.get("workers", [])
    providers = registry.get("providers", [])
    authorities = registry.get("authority_profiles", [])
    healthchecks = registry.get("healthchecks", [])
    recoveries = registry.get("recovery_policies", [])
    receipts = registry.get("receipt_contracts", [])

    capability_ids = ids(capabilities, "capability_id")
    worker_ids = ids(workers, "worker_id")
    provider_ids = ids(providers, "provider_id")
    authority_ids = ids(authorities, "authority_id")
    health_ids = ids(healthchecks, "healthcheck_id")
    recovery_ids = ids(recoveries, "recovery_id")
    receipt_ids = ids(receipts, "receipt_id")

    for name, values in {
        "capability": capability_ids,
        "worker": worker_ids,
        "provider": provider_ids,
        "authority": authority_ids,
        "healthcheck": health_ids,
        "recovery": recovery_ids,
        "receipt": receipt_ids,
    }.items():
        require(len(values) > 0, f"no {name} records", errors)

    require(len(capability_ids) == len(capabilities), "duplicate or missing capability_id", errors)
    require(len(worker_ids) == len(workers), "duplicate or missing worker_id", errors)

    for cap in capabilities:
        cid = cap.get("capability_id", "<missing>")
        for field in ["purpose", "inputs", "outputs", "owners", "providers", "required_authority", "success_predicate", "healthcheck", "recovery_policy", "receipt_contract"]:
            require(bool(cap.get(field)), f"{cid}: missing {field}", errors)
        require(set(cap.get("owners", [])) <= worker_ids, f"{cid}: unknown worker owner", errors)
        require(set(cap.get("providers", [])) <= provider_ids, f"{cid}: unknown provider", errors)
        require(cap.get("required_authority") in authority_ids, f"{cid}: unknown authority", errors)
        require(cap.get("healthcheck") in health_ids, f"{cid}: unknown healthcheck", errors)
        require(cap.get("recovery_policy") in recovery_ids, f"{cid}: unknown recovery policy", errors)
        require(cap.get("receipt_contract") in receipt_ids, f"{cid}: unknown receipt contract", errors)
        require(cap.get("resume_supported") is True, f"{cid}: resume_supported must be true", errors)

    for worker in workers:
        wid = worker.get("worker_id", "<missing>")
        require(worker.get("event_driven") is True, f"{wid}: event_driven must be true", errors)
        require(worker.get("polling_role") != "primary", f"{wid}: polling cannot be primary", errors)
        require(int(worker.get("max_concurrency", 0)) > 0, f"{wid}: max_concurrency must be > 0", errors)
        require(int(worker.get("lease_seconds", 0)) > 0, f"{wid}: lease_seconds must be > 0", errors)
        require(int(worker.get("heartbeat_seconds", 0)) > 0, f"{wid}: heartbeat_seconds must be > 0", errors)
        require(set(worker.get("capabilities", [])) <= capability_ids, f"{wid}: unknown capability", errors)

    routed_caps = {route.get("capability") for route in registry.get("routes", [])}
    require(routed_caps <= capability_ids, "route references unknown capability", errors)

    required_runtime_caps = {
        "pen.intake.github_issue",
        "pen.dispatch.route",
        "pen.execute.github",
        "pen.watchdog.stalled_job",
        "pen.replay.original_job",
    }
    require(required_runtime_caps <= capability_ids, "mandatory runtime capabilities missing", errors)

    for receipt in receipts:
        rid = receipt.get("receipt_id", "<missing>")
        fields = set(receipt.get("required_fields", []))
        require({"job_id", "worker_id", "state", "success_predicate", "verification", "evidence_refs", "receipt_hash"} <= fields, f"{rid}: receipt evidence fields missing", errors)

    regressions = registry.get("regressions", [])
    require(any(r.get("regression_id") == "pen-issue-255" for r in regressions), "Issue #255 regression missing", errors)

    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("registry", nargs="?", default="runtime/registry/runtime-capability-registry.v1.json")
    args = parser.parse_args()

    path = Path(args.registry)
    try:
        registry = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"INVALID: cannot load registry: {exc}", file=sys.stderr)
        return 2

    errors = validate(registry)
    if errors:
        print("INVALID runtime capability registry:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        "VALID runtime capability registry: "
        f"{len(registry['capabilities'])} capabilities, "
        f"{len(registry['workers'])} workers, "
        f"{len(registry['routes'])} routes"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
