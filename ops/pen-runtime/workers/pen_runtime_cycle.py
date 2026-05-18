#!/usr/bin/env python3
"""
pen_runtime_cycle.py
Main orchestration cycle for The Pen runtime.
Runs: intake → route → dispatch → sweep → report
"""
import os
import json
import datetime
from typing import Optional

GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_KEY", "")
REPO_OWNER = "TML-4PM"
REPO_NAME = "the-pen"
STALE_TTL_HOURS = 48


def now_iso() -> str:
    return datetime.datetime.utcnow().isoformat() + "Z"


def intake_scan() -> list:
    """Scan The Pen for OPEN/PARTIAL/BLOCKED issues."""
    import urllib.request
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/issues?state=open&per_page=100"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github+json"
    })
    with urllib.request.urlopen(req) as resp:
        issues = json.loads(resp.read())
    return issues


def classify_issue(issue: dict) -> str:
    """Classify issue into lane based on labels and body signals."""
    labels = [l["name"] for l in issue.get("labels", [])]
    body = (issue.get("body") or "").upper()
    if "critical" in labels or "CRITICAL" in body:
        return "CRITICAL"
    if "bridge-ready" in labels or "bridge" in labels:
        return "BRIDGE"
    if "partial" in labels or "PARTIAL" in body:
        return "PARTIAL"
    if "blocked" in labels or "BLOCKED" in body:
        return "BLOCKED"
    return "OPEN"


def build_bridge_payload(issue: dict, action: str = "execute") -> dict:
    return {
        "task_id": f"pen-{issue['number']}-{now_iso()[:10]}",
        "action": action,
        "repo": f"{REPO_OWNER}/{REPO_NAME}",
        "issue_number": issue["number"],
        "priority": "HIGH",
        "payload": {"title": issue["title"]},
        "require_receipt": True,
        "dispatched_at": now_iso()
    }


def write_bootstrap_receipt(issues: list) -> dict:
    receipt = {
        "status": "PARTIAL",
        "task_id": f"pen-runtime-cycle-{now_iso()[:10]}",
        "source": f"{REPO_OWNER}/{REPO_NAME}",
        "target": "Bridge",
        "commit_sha": None,
        "evidence": [{"type": "scan", "value": f"{len(issues)} issues scanned"}],
        "gaps": ["Bridge dispatch not yet live", "Supabase write not yet connected"],
        "next_actions": ["Connect SUPABASE_URL + SUPABASE_SERVICE_KEY env vars", "Run with Bridge invoke access"],
        "score": 0.60,
        "created_at": now_iso()
    }
    os.makedirs("ops/pen-runtime/receipts", exist_ok=True)
    with open("ops/pen-runtime/receipts/bootstrap.receipt.json", "w") as f:
        json.dump(receipt, f, indent=2)
    return receipt


def run_cycle():
    print(f"[{now_iso()}] Pen Runtime Cycle starting...")
    issues = intake_scan()
    print(f"  Scanned {len(issues)} open issues")
    classified = [(i, classify_issue(i)) for i in issues]
    for issue, lane in classified:
        print(f"  #{issue['number']} [{lane}] {issue['title'][:60]}")
    receipt = write_bootstrap_receipt(issues)
    print(f"  Bootstrap receipt written: {receipt['status']}")
    print(f"[{now_iso()}] Cycle complete.")
    return receipt


if __name__ == "__main__":
    run_cycle()
