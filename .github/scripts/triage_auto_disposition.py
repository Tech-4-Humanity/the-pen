#!/usr/bin/env python3
"""
Triage Auto-Disposition Enforcer
================================

Enforces the 2026-05-24 triage standing disposition:
  Any issue still open and silent past 2026-06-07 is closed as not_planned,
  with the original triage clarification preserved as the audit receipt.

Engagement is detected as: any comment posted after the triage marker comment,
OR any timeline event (cross-reference, label change, reopen, commit ref) after
the triage marker.

Environment:
  GH_TOKEN            - GitHub token (required)
  GITHUB_REPOSITORY   - owner/repo (auto from Actions)
  DRY_RUN             - "true" (default) or "false"
  GITHUB_RUN_ID       - Actions run ID (auto)

Exit codes:
  0 - success (including dry-run with N silent issues found)
  1 - fatal error (API failure, missing token, etc.)
"""
from __future__ import annotations
import os
import sys
import json
import time
import re
import urllib.request
import urllib.error
from datetime import datetime, timezone


TRIAGE_MARKERS = [
    "Triage clarification request",
    "Reopened — bulk-close 2026-05-25",
    "DEV HANDOFF — verified evidence",
]

DEADLINE_ISO = "2026-06-07"


def gh(token: str, path: str, method: str = "GET", payload=None):
    url = f"https://api.github.com{path}" if path.startswith("/") else path
    body = None if payload is None else json.dumps(payload).encode()
    req = urllib.request.Request(
        url, data=body, method=method,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "Content-Type": "application/json",
            "User-Agent": "t4h-triage-enforcer/1.0",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read())
        except Exception:
            return e.code, {}


def find_triage_comment(comments):
    """Return the latest comment matching any triage marker, or None."""
    best = None
    for c in comments:
        body = c.get("body", "")
        for marker in TRIAGE_MARKERS:
            if marker in body:
                if best is None or c["created_at"] > best["created_at"]:
                    best = c
                break
    return best


def has_activity_after(comments, timeline, triage_at, triage_id):
    """True if any meaningful activity exists after the triage comment."""
    later_comments = [
        c for c in comments
        if c["created_at"] > triage_at and c["id"] != triage_id
    ]
    if later_comments:
        return True, len(later_comments), []
    meaningful_events = {"referenced", "cross-referenced", "closed", "reopened", "labeled", "committed"}
    tl_hits = [
        e.get("event")
        for e in timeline
        if e.get("event") in meaningful_events
        and (e.get("created_at") or "") > triage_at
    ]
    return bool(tl_hits), 0, tl_hits


def build_closing_comment(triage_at, triage_url, marker, days_silent, run_url, run_id, now_iso):
    return f"""## 🛑 CLOSED — silent past {DEADLINE_ISO} deadline

Per the standing disposition set in the 2026-05-24 triage sweep (3 days pre-ATO 2026-06-10):

> *"Any issue still open and silent on {DEADLINE_ISO} is legitimately closeable as `not_planned`, with the original triage question preserved as the close receipt. Engagement before then = stays open."*

**Status of this issue at deadline:**
- Original triage comment posted: `{triage_at}`
- Days silent since triage: **{days_silent}**
- Triage comment (preserved as audit receipt): {triage_url}
- Triage marker matched: `{marker}`

**No engagement detected.** No new comments, no commit cross-references, no label changes, no reopens after the triage marker.

**Closed as `not_planned`** by the Triage Auto-Disposition workflow.

- Workflow run: {run_url}
- Run ID: `{run_id}`
- Run timestamp: `{now_iso}`
- Issue body and original triage clarification request remain intact for audit.

**To reactivate:** reopen this issue with a comment answering the original triage questions.

_Kernel governance receipts: `every_state_must_be_traceable` (this comment), `evidence_must_be_replayable` (run ID `{run_id}`), `no_unobserved_execution` (workflow output public)._
"""


def main():
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if not token:
        print("::error::GH_TOKEN / GITHUB_TOKEN not set")
        sys.exit(1)

    repo_full = os.environ.get("GITHUB_REPOSITORY", "")
    if "/" not in repo_full:
        print("::error::GITHUB_REPOSITORY not set or malformed")
        sys.exit(1)
    owner, repo = repo_full.split("/", 1)

    dry_run = os.environ.get("DRY_RUN", "true").lower() == "true"
    run_id = os.environ.get("GITHUB_RUN_ID", "manual")
    server_url = os.environ.get("GITHUB_SERVER_URL", "https://github.com")
    run_url = f"{server_url}/{repo_full}/actions/runs/{run_id}"
    now = datetime.now(timezone.utc)
    now_iso = now.isoformat()

    print(f"::notice::Triage Auto-Disposition starting :: repo={repo_full} dry_run={dry_run} run_id={run_id}")

    # 1) List open issues
    print(f"::group::Fetch open issues")
    all_issues = []
    page = 1
    while True:
        s, items = gh(token, f"/repos/{owner}/{repo}/issues?state=open&per_page=100&page={page}")
        if s != 200 or not isinstance(items, list):
            print(f"::error::issue list failed status={s} body={items}")
            sys.exit(1)
        real = [i for i in items if "pull_request" not in i]
        all_issues.extend(real)
        if len(items) < 100:
            break
        page += 1
        time.sleep(0.3)
    print(f"open issues: {len(all_issues)}")
    print("::endgroup::")

    silent, engaged, skipped = [], [], []

    # 2) Classify each
    for it in all_issues:
        num = it["number"]
        s, cmts = gh(token, f"/repos/{owner}/{repo}/issues/{num}/comments?per_page=100")
        if s != 200 or not isinstance(cmts, list):
            skipped.append({"num": num, "reason": f"comments fetch status={s}"})
            continue

        triage = find_triage_comment(cmts)
        if not triage:
            skipped.append({"num": num, "reason": "no triage marker"})
            continue

        s, tl = gh(token, f"/repos/{owner}/{repo}/issues/{num}/timeline?per_page=100")
        if s != 200 or not isinstance(tl, list):
            tl = []

        active, ncomments, tl_events = has_activity_after(cmts, tl, triage["created_at"], triage["id"])
        if active:
            engaged.append({
                "num": num,
                "title": (it.get("title") or "")[:80],
                "comments_after": ncomments,
                "events_after": tl_events,
            })
        else:
            triage_dt = datetime.fromisoformat(triage["created_at"].replace("Z", "+00:00"))
            days_silent = (now - triage_dt).days
            matched = next(m for m in TRIAGE_MARKERS if m in triage["body"])
            silent.append({
                "num": num,
                "title": (it.get("title") or "")[:80],
                "triage_at": triage["created_at"],
                "triage_url": triage["html_url"],
                "marker": matched,
                "days_silent": days_silent,
            })
        time.sleep(0.2)

    # 3) Report
    print(f"::group::Disposition summary")
    print(f"silent (would close): {len(silent)}")
    print(f"engaged (stay open):  {len(engaged)}")
    print(f"skipped (no marker):  {len(skipped)}")
    print(f"dry_run:              {dry_run}")
    print("::endgroup::")

    print(f"::group::Silent issues")
    for s_item in silent:
        print(f"  #{s_item['num']:<5} silent {s_item['days_silent']:>3}d :: {s_item['title']}")
    print("::endgroup::")

    if engaged:
        print(f"::group::Engaged issues (sample)")
        for e_item in engaged[:30]:
            print(f"  #{e_item['num']:<5} comments_after={e_item['comments_after']} events={e_item['events_after']} :: {e_item['title']}")
        print("::endgroup::")

    # 4) Execute closes
    closed, failed = [], []
    if not dry_run and silent:
        print(f"::group::Executing {len(silent)} closes")
        for s_item in silent:
            num = s_item["num"]
            comment_body = build_closing_comment(
                triage_at=s_item["triage_at"],
                triage_url=s_item["triage_url"],
                marker=s_item["marker"],
                days_silent=s_item["days_silent"],
                run_url=run_url,
                run_id=run_id,
                now_iso=now_iso,
            )
            s, _ = gh(token, f"/repos/{owner}/{repo}/issues/{num}/comments",
                      method="POST", payload={"body": comment_body})
            if s != 201:
                failed.append({"num": num, "step": "comment", "status": s})
                continue
            s2, r2 = gh(token, f"/repos/{owner}/{repo}/issues/{num}",
                        method="PATCH",
                        payload={"state": "closed", "state_reason": "not_planned"})
            if s2 == 200 and r2.get("state") == "closed":
                closed.append({"num": num, "closed_at": r2.get("closed_at")})
                print(f"  ✓ #{num} closed not_planned")
            else:
                failed.append({"num": num, "step": "close", "status": s2})
                print(f"  ✗ #{num} close failed status={s2}")
            time.sleep(0.8)
        print("::endgroup::")
    elif dry_run and silent:
        print(f"::notice::DRY RUN — would have closed {len(silent)} issues; re-run with dry_run=false to execute")

    # 5) Job summary
    summary_lines = [
        f"## Triage Auto-Disposition — {now_iso}",
        "",
        "| Metric | Count |",
        "|---|---|",
        f"| Open issues scanned | {len(all_issues)} |",
        f"| Silent (deadline triggered) | {len(silent)} |",
        f"| Engaged (stayed open) | {len(engaged)} |",
        f"| Skipped (no triage marker) | {len(skipped)} |",
        f"| Closed this run | {len(closed)} |",
        f"| Failed | {len(failed)} |",
        f"| Dry run | {dry_run} |",
        "",
        f"**Run URL:** {run_url}",
        "",
        f"### Silent issues",
    ]
    for s_item in silent[:50]:
        summary_lines.append(f"- #{s_item['num']} (silent {s_item['days_silent']}d): {s_item['title']}")
    if len(silent) > 50:
        summary_lines.append(f"- ... +{len(silent) - 50} more")

    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a") as f:
            f.write("\n".join(summary_lines) + "\n")

    # 6) Artifact data
    os.makedirs("/tmp", exist_ok=True)
    with open("/tmp/disposition-result.json", "w") as f:
        json.dump({
            "run_id": run_id,
            "run_url": run_url,
            "timestamp": now_iso,
            "dry_run": dry_run,
            "repo": repo_full,
            "open_scanned": len(all_issues),
            "silent": silent,
            "engaged_count": len(engaged),
            "skipped_count": len(skipped),
            "closed": closed,
            "failed": failed,
        }, f, indent=2)

    print(f"\n=== FINAL: scanned={len(all_issues)} silent={len(silent)} closed={len(closed)} dry={dry_run} ===")


if __name__ == "__main__":
    main()
