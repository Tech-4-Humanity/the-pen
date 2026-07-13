#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location("oikos_mail_runtime", ROOT / "runtime.py")
assert SPEC and SPEC.loader
runtime = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runtime)


class OikosMailRuntimeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.registry = runtime.load_registry()

    def test_registry_validates(self) -> None:
        self.assertEqual(runtime.validate(self.registry), [])

    def test_every_profile_has_folder_template(self) -> None:
        for profile in self.registry["mailbox_profiles"]:
            self.assertIn(profile["folder_template"], self.registry["folder_templates"])

    def test_required_operational_profiles_exist(self) -> None:
        profile_types = {item["type"] for item in self.registry["mailbox_profiles"]}
        self.assertTrue({"human", "executive", "shared", "machine", "catchall", "notification", "no_reply"}.issubset(profile_types))

    def test_folder_templates_have_no_duplicates(self) -> None:
        for folders in self.registry["folder_templates"].values():
            self.assertEqual(len(folders), len(set(folders)))

    def test_machine_profile_has_recovery_folders(self) -> None:
        folders = set(self.registry["folder_templates"]["machine"])
        self.assertTrue({"05-Failed", "06-Retry", "07-Quarantine", "Receipts", "Telemetry"}.issubset(folders))

    def test_github_failure_rule_is_closed_by_result(self) -> None:
        rule = next(item for item in self.registry["mail_rules"] if item["id"] == "github-action-failed")
        self.assertEqual(rule["folder"], "Systems/GitHub/Actions/Failed")
        self.assertEqual(rule["workflow"], "investigate_github_failure")
        self.assertIn("quarantine", rule["close_condition"])

    def test_github_workflow_has_required_lifecycle(self) -> None:
        steps = self.registry["workflow_templates"]["investigate_github_failure"]
        required = {"fetch_logs", "attempt_retry", "verify_result", "emit_receipt", "move_to_completed_or_quarantine"}
        self.assertTrue(required.issubset(set(steps)))

    def test_autoresponses_have_loop_guards(self) -> None:
        self.assertTrue(all(item["loop_guard"] for item in self.registry["autoresponse_templates"].values()))

    def test_signature_render(self) -> None:
        rendered = runtime.render_signature(
            self.registry,
            "business",
            {
                "name": "Test User",
                "role": "Operator",
                "brand": "OIKOS",
                "email": "operator@example.test",
                "phone": "+61 2 0000 0000",
                "website": "https://example.test",
                "tagline": "Consistent on brand.",
            },
        )
        self.assertIn("Test User", rendered["plain"])
        self.assertIn("mailto:operator@example.test", rendered["html"])

    def test_plan_is_deterministic(self) -> None:
        first = runtime.plan_profile(self.registry, "profile-machine", "github@example.test")
        second = runtime.plan_profile(self.registry, "profile-machine", "github@example.test")
        self.assertEqual(json.dumps(first, sort_keys=True), json.dumps(second, sort_keys=True))


if __name__ == "__main__":
    unittest.main(verbosity=2)
