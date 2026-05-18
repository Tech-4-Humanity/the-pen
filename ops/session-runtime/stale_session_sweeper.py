#!/usr/bin/env python3
"""
stale_session_sweeper.py
Quarantines stale agent memory outputs and audits open sessions.
Closes #109: quarantine stale agent memory and audit outputs.
"""
import os
import json
import datetime
import urllib.request

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
REPO_OWNER = "TML-4PM"
REPO_NAME = "the-pen"
STALE_TTL_HOURS = 48


def now() -> datetime.datetime:
    return datetime.datetime.utcnow()


def fetch_open_issues() -> list:
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/issues?state=open&per_page=100"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github+json"
    })
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())


def is_stale(issue: dict, ttl_hours: int = STALE_TTL_HOURS) -> bool:
    updated = datetime.datetime.fromisoformat(issue["updated_at"].rstrip("Z"))
    age = (now() - updated).total_seconds() / 3600
    return age > ttl_hours


def classify_memory(issue: dict) -> str:
    body = (issue.get("body") or "").upper()
    if "STATUS: REAL" in body:
        return "CURRENT"
    if "STATUS: FAIL" in body:
        return "CONTRADICTED"
    if "STATUS: BLOCKED" in body:
        return "BLOCKED_NO_SOURCE"
    if is_stale(issue):
        return "STALE"
    return "CURRENT"


def run_sweep():
    issues = fetch_open_issues()
    report = {
        "swept_at": now().isoformat() + "Z",
        "total": len(issues),
        "CURRENT": [],
        "STALE": [],
        "CONTRADICTED": [],
        "BLOCKED_NO_SOURCE": []
    }
    for issue in issues:
        classification = classify_memory(issue)
        report[classification].append({
            "number": issue["number"],
            "title": issue["title"][:80],
            "updated_at": issue["updated_at"]
        })
    print(json.dumps(report, indent=2))
    return report


if __name__ == "__main__":
    run_sweep()
