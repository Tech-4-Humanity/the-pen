#!/usr/bin/env python3
from __future__ import annotations

import copy
import json
import unittest
from pathlib import Path

from validate_registry import validate


REGISTRY_PATH = Path(__file__).with_name("runtime-capability-registry.v1.json")


class RegistryValidationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.registry = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))

    def test_canonical_registry_is_valid(self) -> None:
        self.assertEqual([], validate(self.registry))

    def test_partial_cannot_be_terminal(self) -> None:
        broken = copy.deepcopy(self.registry)
        broken["terminal_states"].append("PARTIAL")
        self.assertTrue(any("terminal_states" in error or "non-terminal" in error for error in validate(broken)))

    def test_unknown_worker_owner_fails(self) -> None:
        broken = copy.deepcopy(self.registry)
        broken["capabilities"][0]["owners"] = ["worker.missing"]
        self.assertTrue(any("unknown worker owner" in error for error in validate(broken)))

    def test_polling_cannot_be_primary(self) -> None:
        broken = copy.deepcopy(self.registry)
        broken["workers"][0]["polling_role"] = "primary"
        self.assertTrue(any("polling cannot be primary" in error for error in validate(broken)))

    def test_issue_255_regression_is_mandatory(self) -> None:
        broken = copy.deepcopy(self.registry)
        broken["regressions"] = []
        self.assertTrue(any("Issue #255 regression missing" in error for error in validate(broken)))


if __name__ == "__main__":
    unittest.main()
