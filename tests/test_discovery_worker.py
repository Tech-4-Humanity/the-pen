import unittest, tempfile
from runtime.executor.discovery_worker import DiscoveryWorker
class TestDiscoveryWorker(unittest.TestCase):
    def test_init(self): self.assertEqual(DiscoveryWorker().worker_id, "wk-discovery-002")
    def test_run(self):
        r = DiscoveryWorker().run({"scan_paths": ["/test"]}, "test-002", tempfile.gettempdir())
        self.assertEqual(r["receipt"]["status"], "SUCCESS")
if __name__ == "__main__": unittest.main()
