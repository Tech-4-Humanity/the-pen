#!/usr/bin/env python3
"""Collect and cluster GitHub Actions failures across canonical runtime repositories.

Uses only the Python standard library and the GitHub REST API. The script is intended
for GitHub Actions, local gh-authenticated execution, or any environment with GITHUB_TOKEN.
It emits JSON, CSV and Markdown reports for fixed time windows and groups recurring
failure signatures rather than opening one incident per failed run.
"""
from __future__ import annotations

import argparse
import csv
import datetime as dt
import hashlib
import json
import os
import pathlib
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter, defaultdict
from typing import Any, Iterable

UTC = dt.timezone.utc
WINDOWS_HOURS = {
    "1h": 1,
    "6h": 6,
    "12h": 12,
    "24h": 24,
    "7d": 24 * 7,
    "30d": 24 * 30,
    "365d": 24 * 365,
}
DEFAULT_REPOS = [
    "TML-4PM/the-pen",
    "TML-4PM/t4h-remote-mcp-server-clean",
]


def utcnow() -> dt.datetime:
    return dt.datetime.now(UTC)


def parse_ts(value: str | None) -> dt.datetime | None:
    if not value:
        return None
    return dt.datetime.fromisoformat(value.replace("Z", "+00:00"))


def api_get(url: str, token: str) -> dict[str, Any]:
    req = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "t4h-actions-failure-census/1.0",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"GitHub API {exc.code} for {url}: {body[:1000]}") from exc


def paginate(url: str, token: str, key: str, max_pages: int) -> Iterable[dict[str, Any]]:
    separator = "&" if "?" in url else "?"
    for page in range(1, max_pages + 1):
        data = api_get(f"{url}{separator}per_page=100&page={page}", token)
        items = data.get(key, [])
        if not isinstance(items, list):
            raise RuntimeError(f"Unexpected GitHub response: missing list key {key!r}")
        yield from items
        if len(items) < 100:
            return


def first_failed_step(steps: list[dict[str, Any]]) -> str:
    for step in steps:
        if step.get("conclusion") == "failure":
            return str(step.get("name") or "<unnamed>")
    return ""


def normalize_failure_signature(job: dict[str, Any], log_state: str) -> str:
    steps = job.get("steps") or []
    if not steps:
        return "ZERO_STEP_OR_UNSCHEDULED"
    failed = first_failed_step(steps)
    text = " ".join(
        str(x or "")
        for x in [job.get("name"), failed, job.get("conclusion"), log_state]
    ).lower()
    rules = [
        (r"permission|resource not accessible|forbidden|403", "AUTHORITY_OR_PERMISSION"),
        (r"secret|credential|token|api key", "MISSING_OR_INVALID_SECRET"),
        (r"module not found|modulenotfounderror|cannot import|importerror", "PYTHON_IMPORT"),
        (r"no such file|not found|cannot open|path", "MISSING_FILE_OR_PATH"),
        (r"yaml|workflow.*invalid|syntax", "WORKFLOW_OR_SYNTAX"),
        (r"timeout|timed out|cancelled", "TIMEOUT_OR_CANCELLATION"),
        (r"runner|offline|queued", "RUNNER_CAPACITY_OR_OFFLINE"),
        (r"vercel|deployment blocked", "VERCEL_ACCOUNT_BLOCK"),
        (r"lambda|concurrency|throttl", "LAMBDA_CONCURRENCY"),
        (r"health|endpoint|curl|http", "ENDPOINT_HEALTH"),
        (r"test|assert|unittest|pytest", "TEST_FAILURE"),
    ]
    for pattern, signature in rules:
        if re.search(pattern, text):
            return signature
    return "OTHER_JOB_FAILURE"


def collect_repo(repo: str, token: str, since: dt.datetime, max_pages: int) -> list[dict[str, Any]]:
    owner, name = repo.split("/", 1)
    base = f"https://api.github.com/repos/{owner}/{name}"
    created_filter = since.strftime("%Y-%m-%dT%H:%M:%SZ")
    runs_url = f"{base}/actions/runs?status=completed&created=>={urllib.parse.quote(created_filter)}"
    records: list[dict[str, Any]] = []
    for run in paginate(runs_url, token, "workflow_runs", max_pages):
        if run.get("conclusion") not in {"failure", "timed_out", "cancelled", "action_required", "startup_failure"}:
            continue
        jobs_url = f"{base}/actions/runs/{run['id']}/jobs?filter=latest"
        jobs_data = api_get(jobs_url, token)
        jobs = jobs_data.get("jobs") or []
        if not jobs:
            records.append({
                "repository": repo,
                "workflow_id": run.get("workflow_id"),
                "workflow_name": run.get("name"),
                "event": run.get("event"),
                "run_id": run.get("id"),
                "run_number": run.get("run_number"),
                "job_id": None,
                "job_name": None,
                "created_at": run.get("created_at"),
                "started_at": run.get("run_started_at"),
                "completed_at": run.get("updated_at"),
                "conclusion": run.get("conclusion"),
                "step_count": 0,
                "first_failed_step": "",
                "runner_class": "",
                "head_sha": run.get("head_sha"),
                "html_url": run.get("html_url"),
                "log_state": "NO_JOBS_RETURNED",
                "failure_signature": "ZERO_STEP_OR_UNSCHEDULED",
            })
            continue
        for job in jobs:
            if job.get("conclusion") not in {"failure", "timed_out", "cancelled", "action_required", "startup_failure"}:
                continue
            steps = job.get("steps") or []
            log_state = "EXPECTED" if steps else "NO_STEPS_RETURNED"
            records.append({
                "repository": repo,
                "workflow_id": run.get("workflow_id"),
                "workflow_name": run.get("name"),
                "event": run.get("event"),
                "run_id": run.get("id"),
                "run_number": run.get("run_number"),
                "job_id": job.get("id"),
                "job_name": job.get("name"),
                "created_at": run.get("created_at"),
                "started_at": job.get("started_at") or run.get("run_started_at"),
                "completed_at": job.get("completed_at") or run.get("updated_at"),
                "conclusion": job.get("conclusion"),
                "step_count": len(steps),
                "first_failed_step": first_failed_step(steps),
                "runner_class": job.get("runner_name") or job.get("labels") or "",
                "head_sha": run.get("head_sha"),
                "html_url": run.get("html_url"),
                "log_state": log_state,
                "failure_signature": normalize_failure_signature(job, log_state),
            })
    return records


def summarize(records: list[dict[str, Any]], now: dt.datetime) -> dict[str, Any]:
    counts_by_window: dict[str, int] = {}
    for label, hours in WINDOWS_HOURS.items():
        cutoff = now - dt.timedelta(hours=hours)
        counts_by_window[label] = sum(
            1 for r in records if (parse_ts(r.get("created_at")) or dt.datetime.min.replace(tzinfo=UTC)) >= cutoff
        )
    by_signature = Counter(r["failure_signature"] for r in records)
    by_workflow = Counter(f"{r['repository']}::{r['workflow_name']}" for r in records)
    clusters: list[dict[str, Any]] = []
    grouped: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    for record in records:
        grouped[(record["repository"], record["failure_signature"])].append(record)
    for (repo, signature), rows in sorted(grouped.items(), key=lambda item: len(item[1]), reverse=True):
        timestamps = sorted(parse_ts(r.get("created_at")) for r in rows if parse_ts(r.get("created_at")))
        clusters.append({
            "repository": repo,
            "failure_signature": signature,
            "count": len(rows),
            "first_occurrence": timestamps[0].isoformat() if timestamps else None,
            "latest_occurrence": timestamps[-1].isoformat() if timestamps else None,
            "workflows": sorted({str(r.get("workflow_name")) for r in rows}),
            "run_ids": sorted({int(r["run_id"]) for r in rows if r.get("run_id")}),
        })
    payload = {
        "schema": "t4h.github-actions.failure-census.v1",
        "generated_at": now.isoformat(),
        "record_count": len(records),
        "counts_by_window": counts_by_window,
        "counts_by_signature": dict(by_signature.most_common()),
        "counts_by_workflow": dict(by_workflow.most_common()),
        "clusters": clusters,
        "records": records,
    }
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    payload["census_hash"] = hashlib.sha256(canonical).hexdigest()
    return payload


def write_outputs(output_dir: pathlib.Path, payload: dict[str, Any]) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    json_path = output_dir / "github-actions-failure-census.json"
    csv_path = output_dir / "github-actions-failure-census.csv"
    md_path = output_dir / "github-actions-failure-census.md"
    json_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    fields = [
        "repository", "workflow_id", "workflow_name", "event", "run_id", "run_number",
        "job_id", "job_name", "created_at", "started_at", "completed_at", "conclusion",
        "step_count", "first_failed_step", "runner_class", "head_sha", "html_url",
        "log_state", "failure_signature",
    ]
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(payload["records"])
    lines = [
        "# GitHub Actions Failure Census",
        "",
        f"Generated: `{payload['generated_at']}`",
        f"Census hash: `{payload['census_hash']}`",
        f"Failure records: **{payload['record_count']}**",
        "",
        "## Time windows",
        "",
        "| Window | Failures |",
        "|---|---:|",
    ]
    lines.extend(f"| {window} | {count} |" for window, count in payload["counts_by_window"].items())
    lines += ["", "## Root-cause clusters", "", "| Repository | Signature | Count | Workflows |", "|---|---|---:|---|"]
    for cluster in payload["clusters"]:
        lines.append(
            f"| {cluster['repository']} | {cluster['failure_signature']} | {cluster['count']} | "
            f"{', '.join(cluster['workflows'])} |"
        )
    md_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", action="append", dest="repos", help="owner/repo; repeatable")
    parser.add_argument("--days", type=int, default=365, help="oldest run age to request")
    parser.add_argument("--max-pages", type=int, default=100, help="maximum run pages per repository")
    parser.add_argument("--output-dir", default="receipts/failure-census")
    args = parser.parse_args()
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not token:
        print("BLOCKED_WITH_EVIDENCE: GITHUB_TOKEN or GH_TOKEN is required", file=sys.stderr)
        return 2
    repos = args.repos or DEFAULT_REPOS
    now = utcnow()
    since = now - dt.timedelta(days=args.days)
    all_records: list[dict[str, Any]] = []
    errors: list[str] = []
    for repo in repos:
        try:
            all_records.extend(collect_repo(repo, token, since, args.max_pages))
        except Exception as exc:  # preserve other repositories and fail with evidence after output
            errors.append(f"{repo}: {exc}")
    payload = summarize(all_records, now)
    payload["repositories"] = repos
    payload["collection_errors"] = errors
    write_outputs(pathlib.Path(args.output_dir), payload)
    print(json.dumps({
        "state": "REAL" if not errors else "PARTIAL",
        "records": len(all_records),
        "counts_by_window": payload["counts_by_window"],
        "clusters": len(payload["clusters"]),
        "errors": errors,
        "census_hash": payload["census_hash"],
    }, indent=2))
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
