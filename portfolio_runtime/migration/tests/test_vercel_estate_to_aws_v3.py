#!/usr/bin/env python3
import importlib.util
import json
import pathlib
import tempfile
import unittest

HERE = pathlib.Path(__file__).resolve().parent
MODULE_PATH = HERE.parent / "vercel-estate-to-aws-v3.py"
SPEC = importlib.util.spec_from_file_location("migration_v3", MODULE_PATH)
migration = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(migration)


def valid_manifest():
    return {
        "schema": migration.SCHEMA,
        "site_id": "example",
        "repository": "TML-4PM/example",
        "source_ref": "main",
        "domain": "example.com",
        "owner": "T4H001",
        "aws": {
            "account_id": "140548542136",
            "region": "ap-southeast-2",
            "bucket": "t4h-example"
        },
        "routes": [
            {
                "path": "/",
                "classification": "static",
                "owner": "T4H001",
                "lifecycle": "READY",
                "evidence": ["source"]
            },
            {
                "path": "/api/jobs",
                "classification": "dynamic",
                "owner": "T4H001",
                "lifecycle": "TARGET_REQUIRED",
                "reason": "requires compute",
                "dependency": {"type": "runtime", "target": "UNRESOLVED"},
                "evidence": ["route inventory"]
            }
        ],
        "acceptance": {"required_routes": ["/", "/api/jobs"]},
        "rollback": {"retain_previous_runtime": True}
    }


class MigrationV3Tests(unittest.TestCase):
    def test_valid_manifest_builds_partial_plan(self):
        manifest = migration.validate_manifest(valid_manifest())
        plan = migration.migration_plan(manifest)
        self.assertEqual(plan["classification"], "PARTIAL")
        self.assertEqual(plan["route_counts"]["dynamic"], 1)
        self.assertEqual(plan["unresolved_runtime_routes"], ["/api/jobs"])
        self.assertEqual([s["id"] for s in plan["stages"]], migration.STAGES)

    def test_non_static_route_requires_dependency(self):
        manifest = valid_manifest()
        del manifest["routes"][1]["dependency"]
        with self.assertRaisesRegex(migration.ManifestError, "dependency"):
            migration.validate_manifest(manifest)

    def test_required_route_cannot_disappear(self):
        manifest = valid_manifest()
        manifest["acceptance"]["required_routes"].append("/missing")
        with self.assertRaisesRegex(migration.ManifestError, "missing"):
            migration.validate_manifest(manifest)

    def test_checkpoint_is_receipted_but_not_real(self):
        with tempfile.TemporaryDirectory() as directory:
            path = migration.write_checkpoint(
                pathlib.Path(directory),
                "inventory",
                "SUCCEEDED",
                {"routes": 2},
            )
            receipt = json.loads(path.read_text())
        self.assertEqual(receipt["classification"], "PARTIAL")
        self.assertEqual(receipt["status"], "SUCCEEDED")
        self.assertEqual(len(receipt["evidence_sha256"]), 64)


if __name__ == "__main__":
    unittest.main()
