import unittest, tempfile
from runtime.executor.estate_curator import EstateIntelligenceCurator
class TestEstateCurator(unittest.TestCase):
    def test_init(self): self.assertEqual(EstateIntelligenceCurator().worker_id, "wk-estate-curator-001")
    def test_run(self):
        r = EstateIntelligenceCurator().run({"content": "Test runtime worker"}, "test-001", tempfile.gettempdir())
        self.assertEqual(r["receipt"]["status"], "SUCCESS")
    def test_pivots(self):
        o = EstateIntelligenceCurator().execute({"content": "Let's park that."})
        self.assertGreater(len(o["pivots"]), 0)
if __name__ == "__main__": unittest.main()
