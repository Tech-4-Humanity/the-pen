#!/usr/bin/env python3
import argparse
import hashlib
import json
import sys
from pathlib import Path

REQUIRED = [
    "repository",
    "artifact_path",
    "s3_bucket",
    "cloudfront_distribution_id",
    "canonical_url",
    "expected_content_identity",
    "rollback_source",
    "owner",
    "status",
]


def fail(message: str, code: int = 2) -> None:
    print(f"BLOCKED: {message}", file=sys.stderr)
    raise SystemExit(code)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("target_id")
    parser.add_argument("--registry", default="config/deployment-targets.json")
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()

    registry_path = Path(args.registry)
    if not registry_path.is_file():
        fail(f"registry missing: {registry_path}")

    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    if registry.get("policy", {}).get("heuristic_discovery_allowed") is not False:
        fail("registry must explicitly prohibit heuristic discovery")

    matches = [t for t in registry.get("targets", []) if t.get("target_id") == args.target_id]
    if len(matches) != 1:
        fail(f"target_id must resolve exactly once: {args.target_id}")
    target = matches[0]

    missing = [field for field in REQUIRED if field not in target]
    if missing:
        fail(f"missing required fields: {', '.join(missing)}")
    if target.get("status") != "REAL":
        fail(f"target is not REAL: {target.get('status')}")

    null_fields = [field for field in REQUIRED if target.get(field) in (None, "", [])]
    if null_fields:
        fail(f"unresolved target fields: {', '.join(null_fields)}")

    artifact = (Path(args.repo_root) / target["artifact_path"]).resolve()
    identity = target["expected_content_identity"]
    identity_path = artifact / identity.get("path", "")
    if identity.get("type") != "sha256":
        fail("only sha256 expected_content_identity is accepted")
    if not identity_path.is_file():
        fail(f"identity file missing: {identity_path}")

    actual = hashlib.sha256(identity_path.read_bytes()).hexdigest()
    expected = identity.get("value")
    if actual != expected:
        fail(f"content identity mismatch: expected {expected}, got {actual}")

    print(json.dumps({
        "status": "REAL",
        "target_id": target["target_id"],
        "repository": target["repository"],
        "artifact_path": str(artifact),
        "s3_bucket": target["s3_bucket"],
        "cloudfront_distribution_id": target["cloudfront_distribution_id"],
        "canonical_url": target["canonical_url"],
        "content_sha256": actual,
        "rollback_source": target["rollback_source"],
    }, indent=2))


if __name__ == "__main__":
    main()
