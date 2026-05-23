#!/usr/bin/env python3
"""GitHub Spine Watch: collect, classify, receipt, and escalate failed workflow runs.

Runs inside GitHub Actions. Uses GH_PAT if present, otherwise GITHUB_TOKEN.
Does not mutate secrets, billing, permissions, branches, or deployments.
"""
import json
import os
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CONFIG = ROOT / "config" / "repos.json"
OUT = Path(os.environ.get("SPINE_WATCH_OUT", "spine-watch-out"))
TOKEN = os.environ.get("GH_PAT") or os.environ.get("GITHUB_TOKEN")
API = "https://api.github.com"

if not TOKEN:
    print("missing GH_PAT/GITHUB_TOKEN", file=sys.stderr)
    sys.exit(2)


def now():
    return datetime.now(timezone.utc).isoformat()


def gh(path, method="GET", data=None):
    url = API + path
    body = None
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {TOKEN}",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "the-pen-spine-watch"
    }
    if data is not None:
        body = json.dumps(data).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            raw = r.read().decode("utf-8")
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        text = e.read().decode("utf-8", errors="replace")
        return {"_error": True, "status": e.code, "body": text, "url": url}


def classify_run(run, jobs):
    conclusion = run.get("conclusion") or "unknown"
    event = run.get("event") or "unknown"
    run_duration = None
    try:
        started = datetime.fromisoformat(run["run_started_at"].replace("Z", "+00:00"))
        updated = datetime.fromisoformat(run["updated_at"].replace("Z", "+00:00"))
        run_duration = int((updated - started).total_seconds())
    except Exception:
        pass

    job_list = jobs.get("jobs", []) if isinstance(jobs, dict) else []
    total_steps = sum(len(j.get("steps") or []) for j in job_list)
    job_names = [j.get("name") for j in job_list]
    classes = []

    if not job_list:
        classes.append("NO_JOB_PAYLOAD")
    if job_list and total_steps == 0:
        classes.append("PRE_EXECUTION_COLLAPSE")
    if run_duration is not None and run_duration <= 3:
        classes.append("FAST_FAIL_3S")
    if event == "pull_request" and total_steps == 0:
        classes.append("CHECK_RUN_DESYNC")
    name_blob = " ".join([str(run.get("name", ""))] + [str(n or "") for n in job_names]).lower()
    if "heartbeat" in name_blob:
        classes.append("HEARTBEAT_FAIL")
    if "drift" in name_blob:
        classes.append("DRIFT_CHECK_FAIL")
    if "queue" in name_blob or "worker" in name_blob:
        classes.append("WORKER_OR_QUEUE_FAIL")
    if not classes:
        classes.append("UNKNOWN")

    return {
        "classification": classes,
        "duration_seconds": run_duration,
        "job_count": len(job_list),
        "step_count": total_steps,
        "job_names": job_names,
        "conclusion": conclusion,
        "event": event,
    }


def fetch_failed_runs(repo):
    q = urllib.parse.urlencode({"status": "completed", "per_page": 20})
    runs = gh(f"/repos/{repo}/actions/runs?{q}")
    if runs.get("_error"):
        return {"repo": repo, "error": runs, "runs": []}
    failed = []
    for run in runs.get("workflow_runs", []):
        if run.get("conclusion") not in ("failure", "timed_out", "cancelled", "action_required"):
            continue
        jobs = gh(f"/repos/{repo}/actions/runs/{run['id']}/jobs?per_page=100")
        c = classify_run(run, jobs)
        failed.append({
            "repo": repo,
            "run_id": run.get("id"),
            "run_number": run.get("run_number"),
            "workflow": run.get("name"),
            "event": run.get("event"),
            "head_sha": run.get("head_sha"),
            "html_url": run.get("html_url"),
            "created_at": run.get("created_at"),
            "updated_at": run.get("updated_at"),
            "classifier": c,
            "jobs_error": jobs if isinstance(jobs, dict) and jobs.get("_error") else None,
        })
    return {"repo": repo, "runs": failed}


def write_receipts(report):
    OUT.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    json_path = OUT / f"spine-watch-{stamp}.json"
    md_path = OUT / f"spine-watch-{stamp}.md"
    json_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    lines = ["# Spine Watch Receipt", "", f"Time: {report['time_utc']}", f"Status: {report['status']}", ""]
    for item in report["findings"]:
        lines.append(f"## {item['repo']}")
        if item.get("error"):
            lines.append(f"- API error: {item['error']}")
        if not item.get("runs"):
            lines.append("- No failed runs found in latest sample.")
        for run in item.get("runs", []):
            cls = ", ".join(run["classifier"]["classification"])
            lines.append(f"- {run['workflow']} #{run['run_number']} `{run['run_id']}`: {cls}")
            lines.append(f"  - url: {run['html_url']}")
            lines.append(f"  - sha: {run['head_sha']}")
            lines.append(f"  - jobs/steps: {run['classifier']['job_count']}/{run['classifier']['step_count']}")
        lines.append("")
    md_path.write_text("\n".join(lines), encoding="utf-8")
    return json_path, md_path


def post_parent_comment(parent_issue, report):
    repo = "TML-4PM/the-pen"
    total = report["failed_run_count"]
    classes = sorted(report["classes"])
    body = "\n".join([
        "## Spine Watch automated receipt",
        "",
        f"time: {report['time_utc']}",
        f"status: {report['status']}",
        f"failed runs in sample: {total}",
        f"classes: {', '.join(classes) if classes else 'none'}",
        "",
        "This was generated by the scheduled spine watcher. Troy is escalation-only, not detector.",
    ])
    return gh(f"/repos/{repo}/issues/{parent_issue}/comments", method="POST", data={"body": body})


def main():
    cfg = json.loads(CONFIG.read_text(encoding="utf-8"))
    findings = [fetch_failed_runs(repo) for repo in cfg["repos"]]
    classes = set()
    failed_count = 0
    for item in findings:
        for run in item.get("runs", []):
            failed_count += 1
            classes.update(run["classifier"]["classification"])
    report = {
        "time_utc": now(),
        "status": "BROKEN" if failed_count else "PASS",
        "failed_run_count": failed_count,
        "classes": sorted(classes),
        "parent_issue": cfg.get("parentIssues", {}).get("spineIntegrity"),
        "findings": findings,
    }
    jp, mp = write_receipts(report)
    print(json.dumps(report, indent=2))
    parent = report.get("parent_issue")
    if parent and failed_count:
        res = post_parent_comment(parent, report)
        if isinstance(res, dict) and res.get("_error"):
            print(json.dumps({"comment_error": res}, indent=2), file=sys.stderr)
    if failed_count:
        sys.exit(1)

if __name__ == "__main__":
    main()
