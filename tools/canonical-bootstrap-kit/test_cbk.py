from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest

MODULE_PATH = pathlib.Path(__file__).with_name("cbk.py")
spec = importlib.util.spec_from_file_location("cbk", MODULE_PATH)
cbk = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(cbk)


class CbkTest(unittest.TestCase):
    def test_generate_validate_compile(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = cbk.generate("research", "AI Sweet Spots", pathlib.Path(tmp), "Troy Latter", False)
            validation = cbk.validate(target)
            self.assertTrue(validation["valid"], validation)
            manifest = cbk.compile_project(target)
            self.assertEqual("cbk.manifest.v0.1", manifest["schema_version"])
            self.assertTrue((target / "build/manifest.json").is_file())
            self.assertTrue((target / "build/index.html").is_file())

    def test_reject_existing_target(self):
        with tempfile.TemporaryDirectory() as tmp:
            cbk.generate("product", "Reading Buddy", pathlib.Path(tmp), "Troy Latter", False)
            with self.assertRaises(FileExistsError):
                cbk.generate("product", "Reading Buddy", pathlib.Path(tmp), "Troy Latter", False)

    def test_slug(self):
        self.assertEqual("ai-sweet-spots", cbk.slugify("AI Sweet Spots"))


if __name__ == "__main__":
    unittest.main()
