#!/usr/bin/env python3
from __future__ import annotations
import argparse, importlib.util, json, os, pathlib, shutil, subprocess, tempfile, time
from datetime import datetime, timezone
from typing import Any

HERE = pathlib.Path(__file__).resolve().parent
BASE_PATH = HERE / "vercel-estate-to-aws.py"
spec = importlib.util.spec_from_file_location("estate_base", BASE_PATH)
base = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(base)

REGION = os.getenv("AWS_REGION", "ap-southeast-2")
TEAM_SLUG = os.getenv("VERCEL_TEAM_SLUG", "troys-projects-t4h-machine")


def docker_ready() -> bool:
    if not shutil.which("docker"):
        return False
    p = subprocess.run(["docker", "info"], text=True, capture_output=True, timeout=20)
    return p.returncode == 0


def parse_aws_count(value: str | None) -> int:
    """Normalize scalar or repeated AWS CLI text output."""
    tokens = [line.strip() for line in (value or "").splitlines() if line.strip()]
    if not tokens or all(token.lower() in {"none", "null"} for token in tokens):
        return 0
    numeric = [int(token) for token in tokens if token.isdigit()]
    if numeric and len(numeric) == len(tokens):
        return sum(numeric)
    raise ValueError(f"unexpected AWS count output: {value!r}")


def cleanup_source_tree(path: pathlib.Path, sources_root: pathlib.Path) -> str | None:
    """Delete only a reproducible per-project worktree, retaining logs and receipts."""
    if not path.exists():
        return None
    resolved = path.resolve(strict=False)
    root = sources_root.resolve(strict=False)
    if resolved.parent != root:
        return f"CLEANUP_REFUSED_OUTSIDE_SOURCES_ROOT: {resolved}"
    last_error: Exception | None = None
    for _ in range(3):
        try:
            shutil.rmtree(resolved)
            return None
        except FileNotFoundError:
            return None
        except OSError as exc:
            last_error = exc
            base.run(["/bin/chmod", "-R", "u+w", str(resolved)], timeout=120)
            removed = base.run(["/bin/rm", "-rf", "--", str(resolved)], timeout=300)
            if removed.returncode == 0 and not resolved.exists():
                return None
            time.sleep(1)
    return f"CLEANUP_FAILED: {last_error}"


def robust_s3_publish(name: str, output: pathlib.Path) -> tuple[str, int, str]:
    bucket = f"t4h-recovery-{base.slug(name)}-{base.ACCOUNT_ID}"[:63]
    head = base.run(["aws", "s3api", "head-bucket", "--bucket", bucket])
    if head.returncode != 0:
        cmd = ["aws", "s3api", "create-bucket", "--bucket", bucket, "--region", REGION]
        if REGION != "us-east-1":
            cmd += ["--create-bucket-configuration", f"LocationConstraint={REGION}"]
        created = base.run(cmd)
        if created.returncode != 0 and "BucketAlreadyOwnedByYou" not in (created.stderr or ""):
            raise RuntimeError(f"S3_CREATE_FAILED: {created.stderr.strip() or created.stdout.strip()}")
        deadline = time.time() + 60
        while time.time() < deadline:
            if base.run(["aws", "s3api", "head-bucket", "--bucket", bucket]).returncode == 0:
                break
            time.sleep(2)
        else:
            raise RuntimeError("S3_BUCKET_NOT_VISIBLE_AFTER_CREATE")
    base.run(["aws", "s3api", "put-bucket-versioning", "--bucket", bucket,
              "--versioning-configuration", "Status=Enabled"], check=True)
    base.run(["aws", "s3api", "delete-public-access-block", "--bucket", bucket])
    policy = {"Version":"2012-10-17","Statement":[{"Sid":"PublicReadRecovery","Effect":"Allow","Principal":"*","Action":"s3:GetObject","Resource":f"arn:aws:s3:::{bucket}/*"}]}
    with tempfile.NamedTemporaryFile("w", delete=False) as fh:
        json.dump(policy, fh); policy_path = fh.name
    try:
        base.run(["aws", "s3api", "put-bucket-policy", "--bucket", bucket,
                  "--policy", f"file://{policy_path}"], check=True)
    finally:
        pathlib.Path(policy_path).unlink(missing_ok=True)
    base.run(["aws", "s3api", "put-bucket-website", "--bucket", bucket,
              "--website-configuration", '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"index.html"}}'], check=True)
    sync_cmd = ["aws", "s3", "sync", str(output) + "/", f"s3://{bucket}/", "--delete", "--only-show-errors"]
    for attempt in range(5):
        synced = base.run(sync_cmd, timeout=1800)
        if synced.returncode == 0:
            break
        detail = (synced.stderr or "") + (synced.stdout or "")
        if "NoSuchBucket" not in detail and "OperationAborted" not in detail:
            raise RuntimeError(f"S3_SYNC_FAILED: {detail.strip()}")
        time.sleep(2 ** attempt)
    else:
        raise RuntimeError(f"S3_SYNC_RETRY_EXHAUSTED: {detail.strip()}")
    count_p = base.run(["aws", "s3api", "list-objects-v2", "--bucket", bucket,
                        "--query", "KeyCount", "--output", "text"], check=True)
    count = parse_aws_count(count_p.stdout)
    url = f"http://{bucket}.s3-website-{REGION}.amazonaws.com"
    http = base.run(["curl", "-L", "-sS", "-o", "/dev/null", "-w", "%{http_code}", url + "/"], timeout=60)
    if http.stdout.strip() != "200":
        raise RuntimeError(f"S3_READBACK_FAILED_HTTP_{http.stdout.strip()}")
    return bucket, count, url


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--start-at", default=os.getenv("START_AT", ""))
    parser.add_argument("--max-projects", type=int, default=int(os.getenv("MAX_PROJECTS", "0")))
    parser.add_argument("--resume-root", default=os.getenv("RESUME_ROOT", ""))
    args = parser.parse_args()
    for command in ["aws", "gh", "git", "curl", "npm", "npx"]:
        base.require(command)
    base.REGION = REGION
    base.TEAM_SLUG = TEAM_SLUG
    base.ACCOUNT_ID = json.loads(base.run(["aws", "sts", "get-caller-identity"], check=True).stdout)["Account"]
    token = base.read_vercel_token()
    tid = base.team_id(token)
    projects = base.list_projects(token, tid)
    projects.sort(key=lambda p: (p.get("name") != "outcome-ready", p.get("name", "")))
    inventory_projects = list(projects)
    if args.start_at:
        project_names = [p.get("name", "") for p in projects]
        try:
            start_index = project_names.index(args.start_at)
        except ValueError:
            raise SystemExit(
                f"BLOCKED: --start-at project {args.start_at!r} is not in the "
                f"{len(projects)}-project live Vercel inventory"
            )
        projects = projects[start_index:]
    if args.max_projects > 0:
        projects = projects[:args.max_projects]
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    root = pathlib.Path(args.resume_root).expanduser() if args.resume_root else pathlib.Path.home()/"t4h-vercel-estate-to-aws"/run_id
    sources, logs, receipts = root/"sources", root/"logs", root/"receipts"
    for p in [sources, logs, receipts]: p.mkdir(parents=True, exist_ok=True)
    base.write_json(root/"vercel-projects-v2.json", {"team_slug":TEAM_SLUG,"team_id":tid,"count":len(inventory_projects),"processing_count":len(projects),"start_at":args.start_at or None,"docker_ready":docker_ready(),"projects":inventory_projects})
    summary: list[dict[str, Any]] = []
    dynamic_ok = docker_ready()
    for index, project in enumerate(projects, 1):
        name = project["name"]
        receipt_path = receipts/f"{base.slug(name)}.json"
        if receipt_path.exists():
            old = json.loads(receipt_path.read_text())
            if old.get("status") == "REAL":
                print(f"SKIP_REAL [{index}/{len(projects)}] {name}", flush=True)
                summary.append(old); continue
        print(f"START [{index}/{len(projects)}] {name}", flush=True)
        record: dict[str, Any] = {"schema":"t4h.vercel_aws_migration.receipt.v2","run_id":run_id,"project":name,
            "vercel_project_id":project.get("id"),"started_at":base.now(),"status":"BLOCKED","source_mode":None,
            "aws_mode":None,"aws_url":None,"reason":None,"dns_changed":False,"vercel_deleted":False}
        dest=sources/base.slug(name); log=logs/f"{base.slug(name)}.log"
        try:
            # Failed/deferred attempts may leave a partial checkout that makes both
            # gh clone and vercel link fail on resume. Receipts and logs are retained;
            # only the reproducible working copy is rebuilt.
            cleanup_error = cleanup_source_tree(dest, sources)
            if cleanup_error:
                raise RuntimeError(cleanup_error)
            source=base.source_from_github(project,dest,log)
            if source:
                record["source_mode"]="github"
                if not base.install_and_build(source,logs/f"{base.slug(name)}-build.log"):
                    raise RuntimeError("SOURCE_BUILD_FAILED")
            else:
                source=base.source_from_vercel(project,dest,log); record["source_mode"]="vercel-pull-build"
                if not source: raise RuntimeError("VERCEL_SOURCE_RECOVERY_FAILED")
            static=base.find_static(source)
            if static:
                bucket,count,url=robust_s3_publish(name,static)
                record.update(status="REAL",aws_mode="s3",aws_url=url,bucket=bucket,object_count=count)
            elif (source/"package.json").exists():
                if not dynamic_ok:
                    record.update(status="PARTIAL",reason="DEFERRED_DYNAMIC_DOCKER_UNAVAILABLE")
                else:
                    arn,url=base.apprunner_publish(name,source)
                    record.update(status="REAL",aws_mode="apprunner",aws_url=url,service_arn=arn)
            else:
                raise RuntimeError("NO_DEPLOYABLE_STATIC_OR_NODE_OUTPUT")
        except subprocess.TimeoutExpired as exc:
            record["reason"]=f"TIMEOUT: {exc.cmd}"
        except Exception as exc:
            record["reason"]=str(exc)[:2000]
            if record["reason"] in {
                "SOURCE_BUILD_FAILED",
                "VERCEL_SOURCE_RECOVERY_FAILED",
                "NO_DEPLOYABLE_STATIC_OR_NODE_OUTPUT",
            }:
                record["status"]="PARTIAL"
        cleanup_warning = cleanup_source_tree(dest, sources)
        if cleanup_warning:
            record["cleanup_warning"] = cleanup_warning
        record["finished_at"]=base.now(); base.write_json(receipt_path,record); summary.append(record)
        print(f"{record['status']} {name} {record.get('aws_url') or record.get('reason')}",flush=True)
    # Reconcile the final estate receipt against the complete live inventory, not
    # only the tail selected by --start-at.
    reconciled: list[dict[str, Any]] = []
    for project in inventory_projects:
        receipt_path = receipts/f"{base.slug(project['name'])}.json"
        if receipt_path.exists():
            reconciled.append(json.loads(receipt_path.read_text()))
        else:
            reconciled.append({
                "schema":"t4h.vercel_aws_migration.receipt.v2",
                "run_id":run_id,
                "project":project["name"],
                "vercel_project_id":project.get("id"),
                "status":"BLOCKED",
                "reason":"NOT_PROCESSED_OR_RECEIPT_MISSING",
                "dns_changed":False,
                "vercel_deleted":False,
            })
    summary = reconciled
    counts={s:sum(r.get("status")==s for r in summary) for s in ["REAL","PARTIAL","BLOCKED"]}
    final={"schema":"t4h.vercel_aws_migration.estate_receipt.v2","run_id":run_id,"team_slug":TEAM_SLUG,
           "inventory_count":len(inventory_projects),"processing_count":len(projects),"start_at":args.start_at or None,
           "counts":counts,"classification":"REAL" if summary and counts["PARTIAL"]==0 and counts["BLOCKED"]==0 else "PARTIAL",
           "docker_ready":dynamic_ok,"root":str(root),"completed_at":base.now(),"items":summary}
    base.write_json(root/"final-receipt-v2.json",final)
    print(json.dumps({k:final[k] for k in ["run_id","inventory_count","counts","classification","docker_ready","root"]},indent=2))
    print(f"FINAL_RECEIPT={root/'final-receipt-v2.json'}")
    return 0 if final["classification"]=="REAL" else 2

if __name__=="__main__":
    raise SystemExit(main())
