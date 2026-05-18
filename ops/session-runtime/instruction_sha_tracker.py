#!/usr/bin/env python3
"""
instruction_sha_tracker.py
Tracks the current commit SHA of key instruction files.
Prevents sessions from operating on stale doctrine.
"""
import os
import json
import urllib.request

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
REPO_OWNER = "TML-4PM"
REPO_NAME = "the-pen"

INSTRUCTION_FILES = [
    "GLOBAL_RULE.md",
    "MCP_EXECUTION_CONTRACT.md",
    "ENFORCEMENT_LIVE.md",
    "contracts/mandatory_pen_runtime_preflight.md"
]


def get_file_sha(path: str) -> dict:
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents/{path}"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github+json"
    })
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read())
            return {"path": path, "sha": data.get("sha"), "status": "FOUND"}
    except Exception as e:
        return {"path": path, "sha": None, "status": "MISSING", "error": str(e)}


def track_all() -> list:
    results = [get_file_sha(f) for f in INSTRUCTION_FILES]
    print(json.dumps(results, indent=2))
    return results


if __name__ == "__main__":
    track_all()
