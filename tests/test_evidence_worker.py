import unittest, tempfile
from runtime.executor.evidence_worker import EvidenceWorker
class TestEvidenceWorker(unittest.TestCase):
    def test_init(self): self.assertEqual(EvidenceWorker().worker_id, "wk-evidence-005")
    def test_run(self):
        r = EvidenceWorker().run({"target_run_id": "test-001"}, "test-005", tempfile.gettempdir())
        self.assertEqual(r["receipt"]["status"], "SUCCESS")
if __name__ == "__main__": unittest.main()
