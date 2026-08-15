import unittest, tempfile
from runtime.executor.github_engineer import GitHubEngineer
class TestGitHubEngineer(unittest.TestCase):
    def test_init(self): self.assertEqual(GitHubEngineer().worker_id, "wk-github-engineer-004")
    def test_run(self):
        r = GitHubEngineer().run({"repository": "test/repo"}, "test-004", tempfile.gettempdir())
        self.assertEqual(r["receipt"]["status"], "SUCCESS")
if __name__ == "__main__": unittest.main()
