#!/usr/bin/env python3
import importlib.util
import pathlib
import tempfile
import unittest

HERE = pathlib.Path(__file__).resolve().parent
MODULE_PATH = HERE.parent / "inventory-next-runtime.py"
SPEC = importlib.util.spec_from_file_location("runtime_inventory", MODULE_PATH)
inventory_module = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(inventory_module)


class RuntimeInventoryTests(unittest.TestCase):
    def test_enumerates_methods_dependencies_and_parameterised_pages(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            api = root / "app/api/billing/checkout"
            page = root / "app/r/[code]"
            api.mkdir(parents=True)
            page.mkdir(parents=True)
            (api / "route.ts").write_text(
                'import Stripe from "stripe";\n'
                'import { createClient } from "@supabase/supabase-js";\n'
                'export async function POST() {}\n'
                'export async function GET() {}\n'
            )
            (page / "page.tsx").write_text(
                'import { createClient } from "@supabase/supabase-js";\n'
                'export default function Page() {}\n'
            )
            result = inventory_module.inventory(root)

        self.assertEqual(result["api_route_count"], 1)
        self.assertEqual(result["parameterised_page_count"], 1)
        self.assertEqual(result["runtime_route_count"], 2)
        self.assertEqual(result["classification"], "PARTIAL")
        self.assertEqual(len(result["evidence_sha256"]), 64)

        api_route = next(route for route in result["routes"] if route["kind"] == "api")
        self.assertEqual(api_route["path"], "/api/billing/checkout")
        self.assertEqual(api_route["methods"], ["GET", "POST"])
        self.assertEqual(api_route["dependencies"], ["stripe", "supabase"])
        self.assertEqual(api_route["runtime_target"], "UNRESOLVED")

        page_route = next(
            route for route in result["routes"]
            if route["kind"] == "parameterised-page"
        )
        self.assertEqual(page_route["path"], "/r/[code]")
        self.assertEqual(page_route["methods"], ["GET"])
        self.assertEqual(page_route["dependencies"], ["supabase"])

    def test_missing_app_is_blocked(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "app directory"):
                inventory_module.inventory(pathlib.Path(directory))


if __name__ == "__main__":
    unittest.main()
