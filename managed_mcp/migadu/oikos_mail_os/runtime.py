#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from string import Template
from typing import Any

ROOT = Path(__file__).resolve().parent
REGISTRY_PATH = ROOT / "registry.json"


def load_registry(path: Path = REGISTRY_PATH) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def sha256_json(value: Any) -> str:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(encoded).hexdigest()


def validate(registry: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    required = {
        "table_of_tables",
        "mailbox_types",
        "folder_templates",
        "mailbox_profiles",
        "signature_templates",
        "autoresponse_templates",
        "mail_rules",
        "workflow_templates",
        "test_cases",
    }
    missing = required - registry.keys()
    if missing:
        errors.append(f"missing top-level keys: {sorted(missing)}")

    profiles = registry.get("mailbox_profiles", [])
    profile_ids = set()
    for profile in profiles:
        pid = profile.get("id")
        if not pid or pid in profile_ids:
            errors.append(f"invalid or duplicate profile id: {pid!r}")
        profile_ids.add(pid)
        if profile.get("type") not in registry.get("mailbox_types", {}):
            errors.append(f"profile {pid} references unknown mailbox type")
        if profile.get("folder_template") not in registry.get("folder_templates", {}):
            errors.append(f"profile {pid} references unknown folder template")
        signature = profile.get("signature")
        if signature and signature not in registry.get("signature_templates", {}):
            errors.append(f"profile {pid} references unknown signature")
        autoresponse = profile.get("autoresponse")
        if autoresponse and autoresponse not in registry.get("autoresponse_templates", {}):
            errors.append(f"profile {pid} references unknown autoresponse")

    for name, folders in registry.get("folder_templates", {}).items():
        if len(folders) != len(set(folders)):
            errors.append(f"folder template {name} contains duplicates")
        if not folders:
            errors.append(f"folder template {name} is empty")

    for rule in registry.get("mail_rules", []):
        workflow = rule.get("workflow")
        if workflow and workflow not in registry.get("workflow_templates", {}):
            errors.append(f"rule {rule.get('id')} references unknown workflow {workflow}")

    for name, template in registry.get("autoresponse_templates", {}).items():
        if not template.get("loop_guard"):
            errors.append(f"autoresponse {name} must enable loop_guard")

    return errors


def plan_profile(registry: dict[str, Any], profile_id: str, address: str) -> dict[str, Any]:
    profile = next((item for item in registry["mailbox_profiles"] if item["id"] == profile_id), None)
    if not profile:
        raise KeyError(f"unknown profile: {profile_id}")
    return {
        "address": address,
        "profile": profile,
        "folders": registry["folder_templates"][profile["folder_template"]],
        "signature_template": registry["signature_templates"].get(profile.get("signature")),
        "autoresponse_template": registry["autoresponse_templates"].get(profile.get("autoresponse")),
        "registry_hash": sha256_json(registry),
        "operation": "PLAN_ONLY",
    }


def render_template(text: str, values: dict[str, str]) -> str:
    converted = text.replace("{{", "${").replace("}}", "}")
    return Template(converted).safe_substitute(values)


def render_signature(registry: dict[str, Any], template_id: str, values: dict[str, str]) -> dict[str, str]:
    template = registry["signature_templates"][template_id]
    return {
        "plain": render_template(template["plain"], values),
        "html": render_template(template["html"], values),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="OIKOS Mail Operations registry runtime")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("validate")

    plan = sub.add_parser("plan")
    plan.add_argument("--profile", required=True)
    plan.add_argument("--address", required=True)

    render = sub.add_parser("render-signature")
    render.add_argument("--template", required=True)
    render.add_argument("--values", required=True, help="JSON object")

    args = parser.parse_args()
    registry = load_registry()
    errors = validate(registry)
    if errors:
        print(json.dumps({"status": "BLOCKED", "errors": errors}, indent=2))
        return 2

    if args.command == "validate":
        print(json.dumps({
            "status": "PARTIAL",
            "source_valid": True,
            "registry_hash": sha256_json(registry),
            "errors": [],
            "truth_boundary": "Live execution, readback, receipt, ledger and telemetry are still required for REAL."
        }, indent=2))
        return 0
    if args.command == "plan":
        print(json.dumps(plan_profile(registry, args.profile, args.address), indent=2))
        return 0
    if args.command == "render-signature":
        values = json.loads(args.values)
        print(json.dumps(render_signature(registry, args.template, values), indent=2))
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
