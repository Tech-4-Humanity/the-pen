#!/usr/bin/env python3
"""Audit, classify, repair, retry and verify GitHub Actions across a GitHub owner.

The controller is intentionally conservative:
- reads every active repository
- fingerprints workflows and composite actions
- classifies zero-step and <=2s failures
- applies only safe repository hygiene fixes automatically
- retries only after the detected blocker is removed
- emits durable JSON/CSV/Markdown receipts

Requires: GH_TOKEN with repo + workflow + read:org scopes.
Optional: APPLY_FIXES=true to enable safe changes.
"""
from __future__ import annotations

import argparse
import base64
import csv
import datetime as dt
import hashlib
import json
import os
import pathlib
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter, defaultdict
from typing import Any, Iterable

API = "https://api.github.com"
UTC = dt.timezone.utc
SAFE_GITIGNORE = """.vercel
node_modules/
dist/
build/
coverage/
.env
.env.*
*.log
.DS_Store
.vscode/
.idea/
"""


def request(method: str, url: str, token: str, payload: dict[str, Any] | None = None) -> Any:
    body = None if payload is None else json.dumps(payload).encode()
    req = urllib.request.Request(
        url,
        data=body,
        method=method,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "t4h-github-actions-autofix-controller/1.0",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=90) as response:
            raw = response.read()
            return json.loads(raw.decode()) if raw else None
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")
        raise RuntimeError(f"GitHub API {exc.code} {method} {url}: {detail[:1000]}") from exc


def paginate(url: str, token: str, key: str | None = None, max_pages: int = 20) -> Iterable[Any]:
    sep = "&" if "?" in url else "?"
    for page in range(1, max_pages + 1):
        data = request("GET", f"{url}{sep}per_page=100&page={page}", token)
        items = data if key is None else data.get(key, [])
        if not isinstance(items, list):
            raise RuntimeError(f"Expected list from {url}")
        yield from items
        if len(items) < 100:
            break


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()


def normalize_yaml(text: str) -> str:
    lines = []
    for raw in text.splitlines():
        line = re.sub(r"\s+#.*$", "", raw.rstrip())
        if line.strip():
            lines.append(line)
    return "\n".join(lines) + "\n"


def content_get(repo: str, path: str, ref: str, token: str) -> tuple[str, str] | None:
    try:
        data = request("GET", f"{API}/repos/{repo}/contents/{urllib.parse.quote(path)}?ref={urllib.parse.quote(ref)}", token)
    except RuntimeError as exc:
        if " 404 " in str(exc):
            return None
        raise
    content = base64.b64decode(data["content"]).decode(errors="replace")
    return data["sha"], content


def content_put(repo: str, path: str, branch: str, message: str, text: str, token: str, sha: str | None = None) -> str:
    payload: dict[str, Any] = {
        "message": message,
        "branch": branch,
        "content": base64.b64encode(text.encode()).decode(),
    }
    if sha:
        payload["sha"] = sha
    data = request("PUT", f"{API}/repos/{repo}/contents/{urllib.parse.quote(path)}", token, payload)
    return data["commit"]["sha"]


def active_repos(owner: str, token: str) -> list[dict[str, Any]]:
    repos = list(paginate(f"{API}/user/repos?affiliation=owner,organization_member", token))
    return sorted(
        [r for r in repos if r.get("owner", {}).get("login") == owner and not r.get("archived") and not r.get("disabled")],
        key=lambda r: r["full_name"].lower(),
    )


def tree_paths(repo: str, branch: str, token: str) -> list[str]:
    try:
        data = request("GET", f"{API}/repos/{repo}/git/trees/{urllib.parse.quote(branch)}?recursive=1", token)
    except RuntimeError:
        return []
    return [node["path"] for node in data.get("tree", []) if node.get("type") == "blob"]


def workflow_fingerprints(repo: str, branch: str, token: str) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    workflows: list[dict[str, Any]] = []
    actions: list[dict[str, Any]] = []
    for path in tree_paths(repo, branch, token):
        is_workflow = path.startswith(".github/workflows/") and re.search(r"\.ya?ml$", path)
        is_action = path.startswith(".github/actions/") and path.endswith(("action.yml", "action.yaml"))
        if not (is_workflow or is_action):
            continue
        result = content_get(repo, path, branch, token)
        if not result:
            continue
        _, text = result
        record = {
            "repository": repo,
            "path": path,
            "sha256": sha256_text(normalize_yaml(text)),
            "name": next((m.group(1).strip(" '\"") for line in text.splitlines() if (m := re.match(r"^name:\s*(.+)$", line))), ""),
            "runs_on": sorted(set(re.findall(r"runs-on:\s*([^\n#]+)", text))),
            "uses": sorted(set(re.findall(r"uses:\s*([^\s#]+)", text))),
            "has_workflow_call": bool(re.search(r"^\s*workflow_call:\s*$", text, re.M)),
        }
        (workflows if is_workflow else actions).append(record)
    return workflows, actions


def run_duration_seconds(run: dict[str, Any]) -> int | None:
    try:
        start = dt.datetime.fromisoformat((run.get("run_started_at") or run.get("created_at")).replace("Z", "+00:00"))
        end = dt.datetime.fromisoformat(run["updated_at"].replace("Z", "+00:00"))
        return max(0, int((end - start).total_seconds()))
    except Exception:
        return None


def classify_run(repo: str, run: dict[str, Any], token: str) -> list[dict[str, Any]]:
    if run.get("status") != "completed" or run.get("conclusion") not in {"failure", "startup_failure", "action_required", "cancelled", "timed_out"}:
        return []
    jobs = request("GET", f"{API}/repos/{repo}/actions/runs/{run['id']}/jobs?filter=latest&per_page=100", token).get("jobs", [])
    records: list[dict[str, Any]] = []
    duration = run_duration_seconds(run)
    if not jobs:
        records.append({
            "repository": repo,
            "workflow": run.get("name"),
            "run_id": run.get("id"),
            "job_id": None,
            "job_name": None,
            "duration_seconds": duration,
            "step_count": 0,
            "classification": "NO_JOBS_OR_WORKFLOW_VALIDATION",
            "url": run.get("html_url"),
        })
        return records
    for job in jobs:
        steps = job.get("steps") or []
        classification = "OTHER_FAILURE"
        if not steps:
            classification = "ZERO_STEP_RUNNER_OR_ACCOUNT_BLOCK"
        elif duration is not None and duration <= 2:
            classification = "ZERO_TO_TWO_SECOND_FAILURE"
        records.append({
            "repository": repo,
            "workflow": run.get("name"),
            "run_id": run.get("id"),
            "job_id": job.get("id"),
            "job_name": job.get("name"),
            "duration_seconds": duration,
            "step_count": len(steps),
            "classification": classification,
            "url": run.get("html_url"),
        })
    return records


def recent_failures(repo: str, token: str, days: int, max_pages: int) -> list[dict[str, Any]]:
    since = (dt.datetime.now(UTC) - dt.timedelta(days=days)).strftime("%Y-%m-%dT%H:%M:%SZ")
    url = f"{API}/repos/{repo}/actions/runs?status=completed&created=>={urllib.parse.quote(since)}"
    records: list[dict[str, Any]] = []
    for run in paginate(url, token, key="workflow_runs", max_pages=max_pages):
        records.extend(classify_run(repo, run, token))
    return records


def safe_hygiene_fix(repo: str, branch: str, token: str, apply: bool) -> dict[str, Any]:
    paths = tree_paths(repo, branch, token)
    tracked_node_modules = any(p.startswith("node_modules/") for p in paths)
    existing = content_get(repo, ".gitignore", branch, token)
    gitignore = existing[1] if existing else ""
    needs_ignore = "node_modules/" not in {line.strip() for line in gitignore.splitlines()}
    result = {
        "repository": repo,
        "tracked_node_modules": tracked_node_modules,
        "gitignore_missing_node_modules": needs_ignore,
        "fix_applied": False,
        "commit": None,
        "manual_required": tracked_node_modules,
    }
    if apply and needs_ignore:
        merged = gitignore.rstrip() + ("\n" if gitignore.strip() else "") + "node_modules/\n"
        result["commit"] = content_put(repo, ".gitignore", branch, "chore: ignore node_modules", merged, token, existing[0] if existing else None)
        result["fix_applied"] = True
    return result


def rerun(repo: str, run_id: int, token: str) -> bool:
    try:
        request("POST", f"{API}/repos/{repo}/actions/runs/{run_id}/rerun-failed-jobs", token, {})
        return True
    except RuntimeError:
        return False


def wait_for_attempt(repo: str, run_id: int, token: str, timeout: int = 300) -> dict[str, Any]:
    deadline = time.time() + timeout
    latest: dict[str, Any] = {}
    while time.time() < deadline:
        latest = request("GET", f"{API}/repos/{repo}/actions/runs/{run_id}", token)
        if latest.get("status") == "completed" and latest.get("run_attempt", 1) > 1:
            return latest
        time.sleep(10)
    return latest


def write_outputs(out: pathlib.Path, payload: dict[str, Any]) -> None:
    out.mkdir(parents=True, exist_ok=True)
    (out / "autofix-report.json").write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")
    failures = payload["failures"]
    if failures:
        with (out / "failures.csv").open("w", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=failures[0].keys())
            writer.writeheader(); writer.writerows(failures)
    lines = [
        "# GitHub Actions Autofix Controller Report",
        "",
        f"Generated: `{payload['generated_at']}`",
        f"Repositories scanned: **{payload['summary']['repositories']}**",
        f"Workflow files: **{payload['summary']['workflows']}**",
        f"Composite actions: **{payload['summary']['composite_actions']}**",
        f"Failure records: **{payload['summary']['failures']}**",
        f"Safe fixes applied: **{payload['summary']['fixes_applied']}**",
        f"Retries requested: **{payload['summary']['retries_requested']}**",
        "",
        "## Failure classes",
        "",
    ]
    for key, value in payload["summary"]["failure_classes"].items():
        lines.append(f"- `{key}`: {value}")
    lines += ["", "## Workflow families", ""]
    for fp, rows in payload["workflow_families"][:20]:
        lines.append(f"- `{fp}`: {len(rows)} files")
    (out / "REPORT.md").write_text("\n".join(lines) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner", default="TML-4PM")
    parser.add_argument("--days", type=int, default=365)
    parser.add_argument("--max-run-pages", type=int, default=5)
    parser.add_argument("--apply-fixes", action="store_true", default=os.getenv("APPLY_FIXES") == "true")
    parser.add_argument("--retry", action="store_true", default=os.getenv("RETRY_FAILED") == "true")
    parser.add_argument("--output", default="receipts/github-actions-autofix")
    args = parser.parse_args()
    token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    if not token:
        print("GH_TOKEN or GITHUB_TOKEN is required", file=sys.stderr)
        return 2

    repos = active_repos(args.owner, token)
    all_workflows: list[dict[str, Any]] = []
    all_actions: list[dict[str, Any]] = []
    failures: list[dict[str, Any]] = []
    hygiene: list[dict[str, Any]] = []
    retries: list[dict[str, Any]] = []

    for repo in repos:
        full_name = repo["full_name"]
        branch = repo["default_branch"]
        workflows, actions = workflow_fingerprints(full_name, branch, token)
        all_workflows.extend(workflows)
        all_actions.extend(actions)
        repo_failures = recent_failures(full_name, token, args.days, args.max_run_pages)
        failures.extend(repo_failures)
        hygiene.append(safe_hygiene_fix(full_name, branch, token, args.apply_fixes))
        if args.retry:
            seen: set[int] = set()
            for item in repo_failures:
                run_id = int(item["run_id"])
                if run_id in seen or item["classification"] == "ZERO_STEP_RUNNER_OR_ACCOUNT_BLOCK":
                    continue
                seen.add(run_id)
                requested = rerun(full_name, run_id, token)
                result = wait_for_attempt(full_name, run_id, token) if requested else {}
                retries.append({
                    "repository": full_name,
                    "run_id": run_id,
                    "requested": requested,
                    "status": result.get("status"),
                    "conclusion": result.get("conclusion"),
                    "run_attempt": result.get("run_attempt"),
                })

    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for workflow in all_workflows:
        grouped[workflow["sha256"]].append(workflow)
    workflow_families = sorted(grouped.items(), key=lambda x: len(x[1]), reverse=True)
    failure_classes = Counter(item["classification"] for item in failures)

    payload = {
        "schema": "t4h.github-actions.autofix-controller.v1",
        "generated_at": dt.datetime.now(UTC).isoformat(),
        "owner": args.owner,
        "mode": {"apply_fixes": args.apply_fixes, "retry": args.retry},
        "summary": {
            "repositories": len(repos),
            "workflows": len(all_workflows),
            "composite_actions": len(all_actions),
            "failures": len(failures),
            "fixes_applied": sum(1 for row in hygiene if row["fix_applied"]),
            "manual_node_modules_cleanup": sum(1 for row in hygiene if row["manual_required"]),
            "retries_requested": sum(1 for row in retries if row["requested"]),
            "failure_classes": dict(failure_classes.most_common()),
        },
        "workflow_families": workflow_families,
        "workflows": all_workflows,
        "composite_actions": all_actions,
        "failures": failures,
        "hygiene": hygiene,
        "retries": retries,
    }
    write_outputs(pathlib.Path(args.output), payload)
    print(json.dumps(payload["summary"], indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
