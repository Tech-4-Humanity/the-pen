#!/usr/bin/env python3
"""
dev_puller.py
Pulls OPEN/PARTIAL issues tagged for Dev/Symbio lane into a local work queue.
"""
import os
import json
import urllib.request
from typing import List

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
REPO_OWNER = "TML-4PM"
REPO_NAME = "the-pen"
DEV_LABELS = ["dev", "bridge-ready", "partial", "unblocked"]


def fetch_issues_by_labels(labels: List[str]) -> list:
    label_str = ",".join(labels)
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/issues?labels={label_str}&state=open&per_page=100"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github+json"
    })
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())


def pull_dev_queue() -> List[dict]:
    issues = fetch_issues_by_labels(DEV_LABELS)
    queue = []
    for issue in issues:
        queue.append({
            "issue_number": issue["number"],
            "title": issue["title"],
            "url": issue["html_url"],
            "labels": [l["name"] for l in issue.get("labels", [])],
            "lane": "Dev"
        })
    with open("/tmp/dev_queue.json", "w") as f:
        json.dump(queue, f, indent=2)
    print(f"Dev queue: {len(queue)} items")
    return queue


if __name__ == "__main__":
    pull_dev_queue()
