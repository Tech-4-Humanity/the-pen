#!/usr/bin/env python3
"""Audit GitHub Actions runs for zero-step failures across an owner.

Requires:
  GITHUB_TOKEN with read access to Actions and repository metadata.

Produces JSONL records. It never changes repository settings or reruns jobs.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import asdict, dataclass
from typing import Any, Iterable

API = "https://api.github.com"


@dataclass
class Finding:
    repository: str
    workflow_name: str | None
    run_id: int
    run_event: str | None
    run_status: str | None
    run_conclusion: str | None
    head_sha: str | None
    job_id: int
    job_name: str
    job_status: str | None
    job_conclusion: str | None
    step_count: int
    runner_name: str | None
    runner_group_name: str | None
    started_at: str | None
    completed_at: str | None
    classification: str
    evidence: list[str]


class GitHub:
    def __init__(self, token: str) -> None:
        self.token = token

    def get(self, path: str, params: dict[str, Any] | None = None) -> tuple[Any, dict[str, str]]:
        query = "?" + urllib.parse.urlencode(params or {}) if params else ""
        req = urllib.request.Request(
            API + path + query,
            headers={
                "Authorization": f"Bearer {self.token}",
                "Accept": "application/vnd.github+json",
                "X-GitHub-Api-Version": "2022-11-28",
                "User-Agent": "t4h-zero-step-auditor/1.0",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                return json.load(response), dict(response.headers.items())
        except urllib.error.HTTPError as exc:
            body = exc.read().decode("utf-8", errors="replace")
            raise RuntimeError(f"GitHub GET {path} failed: HTTP {exc.code}: {body}") from exc


def paged(gh: GitHub, path: str, key: str | None = None, **params: Any) -> Iterable[Any]:
    page = 1
    while True:
        payload, _ = gh.get(path, {**params, "per_page": 100, "page": page})
        values = payload[key] if key else payload
        if not values:
            return
        yield from values
        if len(values) < 100:
            return
        page += 1


def classify(job: dict[str, Any]) -> tuple[str, list[str]]:
    steps = job.get("steps") or []
    runner = job.get("runner_name") or ""
    runner_group = job.get("runner_group_name") or ""
    evidence: list[str] = [f"step_count={len(steps)}"]
    if runner:
        evidence.append(f"runner_name={runner}")
    else:
        evidence.append("runner_name_absent")
    if runner_group:
        evidence.append(f"runner_group={runner_group}")
    else:
        evidence.append("runner_group_absent")

    if len(steps) == 0 and not runner and not runner_group:
        return "ZERO_STEP_RUNNER_START_FAILURE", evidence
    if len(steps) == 0 and job.get("conclusion") == "skipped":
        return "ZERO_STEP_JOB_SKIPPED", evidence
    if any(step.get("conclusion") == "failure" for step in steps):
        return "STEP_EXECUTION_FAILURE", evidence
    return "OTHER", evidence


def audit_repo(gh: GitHub, repo: str, runs_per_repo: int) -> Iterable[Finding]:
    runs, _ = gh.get(f"/repos/{repo}/actions/runs", {"per_page": min(runs_per_repo, 100)})
    for run in (runs.get("workflow_runs") or [])[:runs_per_repo]:
        jobs, _ = gh.get(f"/repos/{repo}/actions/runs/{run['id']}/jobs", {"per_page": 100})
        for job in jobs.get("jobs") or []:
            classification, evidence = classify(job)
            if classification not in {"ZERO_STEP_RUNNER_START_FAILURE", "ZERO_STEP_JOB_SKIPPED"}:
                continue
            yield Finding(
                repository=repo,
                workflow_name=run.get("name"),
                run_id=run["id"],
                run_event=run.get("event"),
                run_status=run.get("status"),
                run_conclusion=run.get("conclusion"),
                head_sha=run.get("head_sha"),
                job_id=job["id"],
                job_name=job.get("name") or "",
                job_status=job.get("status"),
                job_conclusion=job.get("conclusion"),
                step_count=len(job.get("steps") or []),
                runner_name=job.get("runner_name"),
                runner_group_name=job.get("runner_group_name"),
                started_at=job.get("started_at"),
                completed_at=job.get("completed_at"),
                classification=classification,
                evidence=evidence,
            )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner", default="TML-4PM")
    parser.add_argument("--runs-per-repo", type=int, default=20)
    parser.add_argument("--include-archived", action="store_true")
    parser.add_argument("--sleep", type=float, default=0.0)
    args = parser.parse_args()

    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        print("GITHUB_TOKEN is required", file=sys.stderr)
        return 2

    gh = GitHub(token)
    findings = 0
    repos_scanned = 0
    errors = 0

    for repo in paged(gh, f"/users/{args.owner}/repos", sort="updated", direction="desc", type="owner"):
        if repo.get("archived") and not args.include_archived:
            continue
        name = repo["full_name"]
        repos_scanned += 1
        try:
            for finding in audit_repo(gh, name, args.runs_per_repo):
                print(json.dumps(asdict(finding), sort_keys=True))
                findings += 1
        except RuntimeError as exc:
            print(json.dumps({"repository": name, "classification": "AUDIT_ERROR", "error": str(exc)}))
            errors += 1
        if args.sleep:
            time.sleep(args.sleep)

    summary = {
        "owner": args.owner,
        "repos_scanned": repos_scanned,
        "runs_per_repo": args.runs_per_repo,
        "zero_step_findings": findings,
        "audit_errors": errors,
        "status": "REAL" if errors == 0 else "PARTIAL",
    }
    print(json.dumps({"summary": summary}, sort_keys=True))
    return 0 if errors == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
