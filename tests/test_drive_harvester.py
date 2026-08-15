import unittest, tempfile
from runtime.executor.drive_harvester import DriveHarvester
class TestDriveHarvester(unittest.TestCase):
    def test_init(self): self.assertEqual(DriveHarvester().worker_id, "wk-drive-harvester-003")
    def test_run(self):
        r = DriveHarvester().run({"drive_folder": "root"}, "test-003", tempfile.gettempdir())
        self.assertEqual(r["receipt"]["status"], "SUCCESS")
if __name__ == "__main__": unittest.main()
