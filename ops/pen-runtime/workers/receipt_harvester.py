#!/usr/bin/env python3
"""
receipt_harvester.py
Scans GitHub issue comments for receipt JSON blocks and reconciles into ledger.
"""
import os
import re
import json
import urllib.request

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
REPO_OWNER = "TML-4PM"
REPO_NAME = "the-pen"
RECEIPT_PATTERN = re.compile(r'```json\s*(\{[\s\S]*?"status"[\s\S]*?\})\s*```', re.IGNORECASE)


def fetch_comments(issue_number: int) -> list:
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/issues/{issue_number}/comments"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github+json"
    })
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())


def extract_receipts(issue_number: int) -> list:
    comments = fetch_comments(issue_number)
    receipts = []
    for comment in comments:
        body = comment.get("body", "")
        for match in RECEIPT_PATTERN.finditer(body):
            try:
                receipt = json.loads(match.group(1))
                receipt["_issue"] = issue_number
                receipt["_comment_id"] = comment["id"]
                receipts.append(receipt)
            except json.JSONDecodeError:
                pass
    return receipts


if __name__ == "__main__":
    import sys
    issue_num = int(sys.argv[1]) if len(sys.argv) > 1 else 110
    receipts = extract_receipts(issue_num)
    print(json.dumps(receipts, indent=2))
