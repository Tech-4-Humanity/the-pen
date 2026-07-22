import json
import tempfile
import unittest
from pathlib import Path

from workers.capability_manifest_runtime import canonical_hash, select_route


class CapabilityManifestRuntimeTests(unittest.TestCase):
    def test_hash_is_deterministic(self):
        self.assertEqual(canonical_hash({"b": 2, "a": 1}), canonical_hash({"a": 1, "b": 2}))

    def test_selects_primary_and_fallback(self):
        bundle = {
            "registries": {
                "workers": {
                    "workers": [
                        {
                            "worker_id": "worker-a",
                            "capabilities": ["validation"],
                            "authority": ["read"],
                            "health_state": "HEALTHY",
                            "truth_state": "PARTIAL",
                            "cost_score": 10,
                            "reliability_score": 90,
                        },
                        {
                            "worker_id": "worker-b",
                            "capabilities": ["validation"],
                            "authority": ["read"],
                            "health_state": "HEALTHY",
                            "truth_state": "PARTIAL",
                            "cost_score": 20,
                            "reliability_score": 80,
                        },
                    ]
                },
                "providers": {"providers": []},
            }
        }
        route = select_route(
            bundle,
            {"required_capabilities": ["validation"], "authority": {"operations": ["read"]}},
        )
        self.assertEqual(route["primary"]["worker_id"], "worker-a")
        self.assertEqual(route["fallback"]["worker_id"], "worker-b")

    def test_rejects_unauthorised_worker(self):
        bundle = {
            "registries": {
                "workers": {
                    "workers": [
                        {
                            "worker_id": "worker-a",
                            "capabilities": ["validation"],
                            "authority": ["read"],
                            "health_state": "HEALTHY",
                        }
                    ]
                },
                "providers": {"providers": []},
            }
        }
        with self.assertRaises(RuntimeError):
            select_route(
                bundle,
                {"required_capabilities": ["validation"], "authority": {"operations": ["deploy"]}},
            )


if __name__ == "__main__":
    unittest.main()
