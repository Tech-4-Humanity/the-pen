#!/usr/bin/env python3
"""Migrate the complete Vercel workspace to AWS with bounded, receipt-driven execution.

Static projects are published to S3 website endpoints. Runnable Node/Next projects
with source are containerised and published to AWS App Runner. Projects that cannot
be reconstructed are preserved with metadata and a BLOCKED receipt.

No Vercel project, domain, repository or local source is deleted and DNS is not changed.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request
from datetime import datetime, timezone
from typing import Any

REGION = os.getenv("AWS_REGION", "ap-southeast-2")
TEAM_SLUG = os.getenv("VERCEL_TEAM_SLUG", "troys-projects-t4h-machine")
ACCOUNT_ID = ""


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def slug(value: str, limit: int = 42) -> str:
    s = re.sub(r"[^a-z0-9-]+", "-", value.lower()).strip("-")
    return s[:limit] or "site"


def run(cmd: list[str], *, cwd: pathlib.Path | None = None, timeout: int = 900,
        env: dict[str, str] | None = None, check: bool = False) -> subprocess.CompletedProcess[str]:
    merged = os.environ.copy()
    if env:
        merged.update(env)
    p = subprocess.run(cmd, cwd=cwd, env=merged, text=True, capture_output=True, timeout=timeout)
    if check and p.returncode != 0:
        raise RuntimeError(f"command failed ({p.returncode}): {' '.join(cmd)}\n{p.stdout}\n{p.stderr}")
    return p


def require(name: str) -> None:
    if not shutil.which(name):
        raise SystemExit(f"BLOCKED: missing command {name}")


def read_vercel_token() -> str:
    if os.getenv("VERCEL_TOKEN"):
        return os.environ["VERCEL_TOKEN"]
    candidates = [
        pathlib.Path.home() / ".local/share/com.vercel.cli/auth.json",
        pathlib.Path.home() / "Library/Application Support/com.vercel.cli/auth.json",
        pathlib.Path.home() / ".vercel/auth.json",
    ]
    for path in candidates:
        try:
            data = json.loads(path.read_text())
            token = data.get("token")
            if token:
                return token
        except Exception:
            pass
    raise SystemExit("BLOCKED: Vercel token not found. Export VERCEL_TOKEN or run `npx vercel login`.")


def api(token: str, path: str) -> dict[str, Any]:
    req = urllib.request.Request(
        "https://api.vercel.com" + path,
        headers={"Authorization": f"Bearer {token}", "User-Agent": "t4h-vercel-estate-recovery/1"},
    )
    with urllib.request.urlopen(req, timeout=90) as response:
        return json.loads(response.read())


def team_id(token: str) -> str:
    data = api(token, "/v2/teams?limit=100")
    for team in data.get("teams", []):
        if team.get("slug") == TEAM_SLUG:
            return str(team["id"])
    raise SystemExit(f"BLOCKED: Vercel team slug {TEAM_SLUG!r} is not visible to the local token")


def list_projects(token: str, tid: str) -> list[dict[str, Any]]:
    projects: list[dict[str, Any]] = []
    until: int | None = None
    while True:
        query = f"/v9/projects?teamId={tid}&limit=100"
        if until:
            query += f"&until={until}"
        data = api(token, query)
        batch = data.get("projects", [])
        projects.extend(batch)
        pagination = data.get("pagination") or {}
        until = pagination.get("next")
        if not until or not batch:
            break
    return projects


def write_json(path: pathlib.Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def source_from_github(project: dict[str, Any], dest: pathlib.Path, log: pathlib.Path) -> pathlib.Path | None:
    link = project.get("link") or {}
    org, repo = link.get("org"), link.get("repo")
    if not org or not repo:
        return None
    full = f"{org}/{repo}"
    p = run(["gh", "repo", "clone", full, str(dest), "--", "--depth", "1"], timeout=300)
    log.write_text(f"$ gh repo clone {full}\n{p.stdout}\n{p.stderr}", encoding="utf-8")
    return dest if p.returncode == 0 else None


def source_from_vercel(project: dict[str, Any], dest: pathlib.Path, log: pathlib.Path) -> pathlib.Path | None:
    dest.mkdir(parents=True, exist_ok=True)
    name = project["name"]
    commands = [
        ["npx", "--yes", "vercel@latest", "link", "--yes", "--scope", TEAM_SLUG, "--project", name],
        ["npx", "--yes", "vercel@latest", "pull", "--yes", "--environment=production", "--scope", TEAM_SLUG],
        ["npx", "--yes", "vercel@latest", "build", "--prod", "--scope", TEAM_SLUG],
    ]
    chunks: list[str] = []
    for cmd in commands:
        try:
            p = run(cmd, cwd=dest, timeout=600, env={"CI": "1", "VERCEL_TELEMETRY_DISABLED": "1"})
        except subprocess.TimeoutExpired:
            chunks.append(f"TIMEOUT: {' '.join(cmd)}")
            log.write_text("\n".join(chunks), encoding="utf-8")
            return None
        chunks.append(f"$ {' '.join(cmd)}\n{p.stdout}\n{p.stderr}")
        if p.returncode != 0 and "build" in cmd:
            log.write_text("\n".join(chunks), encoding="utf-8")
            return None
    log.write_text("\n".join(chunks), encoding="utf-8")
    return dest


def install_and_build(source: pathlib.Path, log: pathlib.Path) -> bool:
    package = source / "package.json"
    if not package.exists():
        return True
    if (source / "pnpm-lock.yaml").exists() and shutil.which("pnpm"):
        commands = [["pnpm", "install", "--frozen-lockfile"], ["pnpm", "run", "build"]]
    elif (source / "yarn.lock").exists() and shutil.which("yarn"):
        commands = [["yarn", "install", "--frozen-lockfile"], ["yarn", "build"]]
    else:
        commands = [["npm", "ci"], ["npm", "run", "build"]]
    chunks: list[str] = []
    for cmd in commands:
        p = run(cmd, cwd=source, timeout=1200, env={"CI": "1", "NEXT_TELEMETRY_DISABLED": "1"})
        chunks.append(f"$ {' '.join(cmd)}\n{p.stdout}\n{p.stderr}")
        if p.returncode != 0:
            if cmd[:2] == ["npm", "ci"]:
                p = run(["npm", "install"], cwd=source, timeout=1200, env={"CI": "1"})
                chunks.append(f"$ npm install\n{p.stdout}\n{p.stderr}")
            if p.returncode != 0:
                log.write_text("\n".join(chunks), encoding="utf-8")
                return False
    log.write_text("\n".join(chunks), encoding="utf-8")
    return True


def find_static(source: pathlib.Path) -> pathlib.Path | None:
    for rel in [".vercel/output/static", "dist", "out", "build", "public"]:
        path = source / rel
        if (path / "index.html").exists():
            return path
    if (source / "index.html").exists():
        return source
    return None


def s3_publish(name: str, output: pathlib.Path) -> tuple[str, int, str]:
    bucket = f"t4h-recovery-{slug(name)}-{ACCOUNT_ID}"[:63]
    head = run(["aws", "s3api", "head-bucket", "--bucket", bucket])
    if head.returncode != 0:
        run([
            "aws", "s3api", "create-bucket", "--bucket", bucket, "--region", REGION,
            "--create-bucket-configuration", f"LocationConstraint={REGION}"
        ], check=True)
    run(["aws", "s3api", "put-bucket-versioning", "--bucket", bucket,
         "--versioning-configuration", "Status=Enabled"], check=True)
    run(["aws", "s3api", "delete-public-access-block", "--bucket", bucket])
    policy = {
        "Version": "2012-10-17",
        "Statement": [{"Sid": "PublicReadRecovery", "Effect": "Allow", "Principal": "*",
                       "Action": "s3:GetObject", "Resource": f"arn:aws:s3:::{bucket}/*"}],
    }
    with tempfile.NamedTemporaryFile("w", delete=False) as fh:
        json.dump(policy, fh)
        policy_path = fh.name
    try:
        run(["aws", "s3api", "put-bucket-policy", "--bucket", bucket, "--policy", f"file://{policy_path}"], check=True)
    finally:
        pathlib.Path(policy_path).unlink(missing_ok=True)
    run(["aws", "s3api", "put-bucket-website", "--bucket", bucket,
         "--website-configuration", '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"index.html"}}'], check=True)
    run(["aws", "s3", "sync", str(output) + "/", f"s3://{bucket}/", "--delete", "--only-show-errors"], timeout=1800, check=True)
    count_p = run(["aws", "s3api", "list-objects-v2", "--bucket", bucket, "--query", "KeyCount", "--output", "text"], check=True)
    count = int(count_p.stdout.strip() or 0)
    url = f"http://{bucket}.s3-website-{REGION}.amazonaws.com"
    http = run(["curl", "-L", "-sS", "-o", "/dev/null", "-w", "%{http_code}", url + "/"], timeout=60)
    if http.stdout.strip() != "200":
        raise RuntimeError(f"S3 readback failed: HTTP {http.stdout.strip()}")
    return bucket, count, url


def ensure_apprunner_role() -> str:
    role_name = "T4HAppRunnerECRAccessRole"
    arn = f"arn:aws:iam::{ACCOUNT_ID}:role/{role_name}"
    if run(["aws", "iam", "get-role", "--role-name", role_name]).returncode != 0:
        trust = {"Version": "2012-10-17", "Statement": [{"Effect": "Allow", "Principal": {"Service": "build.apprunner.amazonaws.com"}, "Action": "sts:AssumeRole"}]}
        with tempfile.NamedTemporaryFile("w", delete=False) as fh:
            json.dump(trust, fh); path = fh.name
        try:
            run(["aws", "iam", "create-role", "--role-name", role_name, "--assume-role-policy-document", f"file://{path}"], check=True)
        finally:
            pathlib.Path(path).unlink(missing_ok=True)
        run(["aws", "iam", "attach-role-policy", "--role-name", role_name,
             "--policy-arn", "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"], check=True)
        time.sleep(10)
    return arn


def apprunner_publish(name: str, source: pathlib.Path) -> tuple[str, str]:
    if not shutil.which("docker"):
        raise RuntimeError("Docker is required for dynamic App Runner deployment")
    package = json.loads((source / "package.json").read_text())
    scripts = package.get("scripts") or {}
    if "start" not in scripts:
        raise RuntimeError("package.json has no start script")
    dockerfile = source / "Dockerfile.t4h-estate"
    dockerfile.write_text(
        "FROM node:22-alpine\nWORKDIR /app\nCOPY package*.json ./\n"
        "RUN npm ci || npm install\nCOPY . .\nENV NEXT_TELEMETRY_DISABLED=1\n"
        "RUN npm run build\nENV NODE_ENV=production\nENV PORT=3000\nEXPOSE 3000\nCMD [\"npm\",\"start\"]\n",
        encoding="utf-8",
    )
    repo = f"t4h-{slug(name, 50)}"
    image = f"{ACCOUNT_ID}.dkr.ecr.{REGION}.amazonaws.com/{repo}:latest"
    if run(["aws", "ecr", "describe-repositories", "--repository-names", repo]).returncode != 0:
        run(["aws", "ecr", "create-repository", "--repository-name", repo,
             "--image-scanning-configuration", "scanOnPush=true"], check=True)
    password = run(["aws", "ecr", "get-login-password", "--region", REGION], check=True).stdout
    login = subprocess.run(["docker", "login", "--username", "AWS", "--password-stdin",
                            f"{ACCOUNT_ID}.dkr.ecr.{REGION}.amazonaws.com"], input=password, text=True, capture_output=True)
    if login.returncode != 0:
        raise RuntimeError(login.stderr)
    run(["docker", "build", "--platform", "linux/amd64", "-f", str(dockerfile), "-t", image, "."], cwd=source, timeout=3600, check=True)
    run(["docker", "push", image], timeout=3600, check=True)
    role = ensure_apprunner_role()
    service_name = f"t4h-{slug(name, 32)}"
    services = json.loads(run(["aws", "apprunner", "list-services", "--region", REGION], check=True).stdout).get("ServiceSummaryList", [])
    existing = next((s for s in services if s.get("ServiceName") == service_name), None)
    source_cfg = json.dumps({"AuthenticationConfiguration": {"AccessRoleArn": role}, "AutoDeploymentsEnabled": False,
                             "ImageRepository": {"ImageIdentifier": image, "ImageRepositoryType": "ECR",
                             "ImageConfiguration": {"Port": "3000"}}})
    if existing:
        result = run(["aws", "apprunner", "update-service", "--region", REGION,
                      "--service-arn", existing["ServiceArn"], "--source-configuration", source_cfg], check=True)
        service_arn = json.loads(result.stdout)["Service"]["ServiceArn"]
    else:
        result = run(["aws", "apprunner", "create-service", "--region", REGION,
                      "--service-name", service_name, "--source-configuration", source_cfg], check=True)
        service_arn = json.loads(result.stdout)["Service"]["ServiceArn"]
    deadline = time.time() + 1800
    service: dict[str, Any] = {}
    while time.time() < deadline:
        data = json.loads(run(["aws", "apprunner", "describe-service", "--region", REGION,
                               "--service-arn", service_arn], check=True).stdout)
        service = data["Service"]
        status = service.get("Status")
        if status == "RUNNING":
            break
        if status in {"CREATE_FAILED", "UPDATE_FAILED", "DELETE_FAILED"}:
            raise RuntimeError(f"App Runner service failed: {status}")
        time.sleep(20)
    else:
        raise RuntimeError("App Runner wait timeout")
    url = "https://" + service["ServiceUrl"]
    http = run(["curl", "-L", "-sS", "-o", "/dev/null", "-w", "%{http_code}", url + "/"], timeout=60)
    if http.stdout.strip() not in {"200", "301", "302", "307", "308"}:
        raise RuntimeError(f"App Runner readback failed: HTTP {http.stdout.strip()}")
    return service_arn, url


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-projects", type=int, default=int(os.getenv("MAX_PROJECTS", "0")), help="0 means all")
    parser.add_argument("--start-at", default=os.getenv("START_AT", ""))
    args = parser.parse_args()
    for command in ["aws", "gh", "git", "curl", "npm", "npx"]:
        require(command)
    global ACCOUNT_ID
    ACCOUNT_ID = json.loads(run(["aws", "sts", "get-caller-identity"], check=True).stdout)["Account"]
    token = read_vercel_token()
    tid = team_id(token)
    projects = list_projects(token, tid)
    projects.sort(key=lambda p: (p.get("name") != "outcome-ready", p.get("name", "")))
    if args.start_at:
        projects = [p for p in projects if p.get("name", "") >= args.start_at]
    if args.max_projects > 0:
        projects = projects[:args.max_projects]
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    root = pathlib.Path.home() / "t4h-vercel-estate-to-aws" / run_id
    sources, logs, receipts = root / "sources", root / "logs", root / "receipts"
    for p in [sources, logs, receipts]: p.mkdir(parents=True, exist_ok=True)
    write_json(root / "vercel-projects.json", {"team_slug": TEAM_SLUG, "team_id": tid, "count": len(projects), "projects": projects})
    summary: list[dict[str, Any]] = []
    for index, project in enumerate(projects, 1):
        name = project["name"]
        print(f"START [{index}/{len(projects)}] {name}", flush=True)
        record: dict[str, Any] = {"schema": "t4h.vercel_aws_migration.receipt.v1", "run_id": run_id,
                                  "project": name, "vercel_project_id": project.get("id"), "started_at": now(),
                                  "status": "BLOCKED", "source_mode": None, "aws_mode": None,
                                  "aws_url": None, "reason": None, "dns_changed": False, "vercel_deleted": False}
        dest = sources / slug(name)
        log = logs / f"{slug(name)}.log"
        try:
            source = source_from_github(project, dest, log)
            if source:
                record["source_mode"] = "github"
                built = install_and_build(source, logs / f"{slug(name)}-build.log")
                if not built:
                    raise RuntimeError("SOURCE_BUILD_FAILED")
            else:
                source = source_from_vercel(project, dest, log)
                record["source_mode"] = "vercel-pull-build"
                if not source:
                    raise RuntimeError("VERCEL_SOURCE_RECOVERY_FAILED")
            static = find_static(source)
            if static:
                bucket, count, url = s3_publish(name, static)
                record.update(status="REAL", aws_mode="s3", aws_url=url, bucket=bucket, object_count=count)
            elif (source / "package.json").exists():
                service_arn, url = apprunner_publish(name, source)
                record.update(status="REAL", aws_mode="apprunner", aws_url=url, service_arn=service_arn)
            else:
                raise RuntimeError("NO_DEPLOYABLE_STATIC_OR_NODE_OUTPUT")
        except subprocess.TimeoutExpired as exc:
            record["reason"] = f"TIMEOUT: {exc.cmd}"
        except Exception as exc:
            record["reason"] = str(exc)[:2000]
        record["finished_at"] = now()
        write_json(receipts / f"{slug(name)}.json", record)
        summary.append(record)
        print(f"{record['status']} {name} {record.get('aws_url') or record.get('reason')}", flush=True)
    counts = {state: sum(r["status"] == state for r in summary) for state in ["REAL", "PARTIAL", "BLOCKED"]}
    final = {"schema": "t4h.vercel_aws_migration.estate_receipt.v1", "run_id": run_id,
             "team_slug": TEAM_SLUG, "projects": len(summary), "counts": counts,
             "classification": "REAL" if summary and counts["BLOCKED"] == 0 else "PARTIAL",
             "root": str(root), "completed_at": now(), "items": summary}
    write_json(root / "final-receipt.json", final)
    print(json.dumps({k: final[k] for k in ["run_id", "projects", "counts", "classification", "root"]}, indent=2))
    print(f"FINAL_RECEIPT={root / 'final-receipt.json'}")
    return 0 if counts["BLOCKED"] == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
