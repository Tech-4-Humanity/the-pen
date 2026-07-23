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
    base.run(["aws", "s3", "sync", str(output) + "/", f"s3://{bucket}/", "--delete", "--only-show-errors"], timeout=1800, check=True)
    count_p = base.run(["aws", "s3api", "list-objects-v2", "--bucket", bucket,
                        "--query", "KeyCount", "--output", "text"], check=True)
    count = int((count_p.stdout or "0").strip() or 0)
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
    if args.start_at:
        projects = [p for p in projects if p.get("name", "") >= args.start_at]
    if args.max_projects > 0:
        projects = projects[:args.max_projects]
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    root = pathlib.Path(args.resume_root).expanduser() if args.resume_root else pathlib.Path.home()/"t4h-vercel-estate-to-aws"/run_id
    sources, logs, receipts = root/"sources", root/"logs", root/"receipts"
    for p in [sources, logs, receipts]: p.mkdir(parents=True, exist_ok=True)
    base.write_json(root/"vercel-projects-v2.json", {"team_slug":TEAM_SLUG,"team_id":tid,"count":len(projects),"docker_ready":docker_ready(),"projects":projects})
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
        record["finished_at"]=base.now(); base.write_json(receipt_path,record); summary.append(record)
        print(f"{record['status']} {name} {record.get('aws_url') or record.get('reason')}",flush=True)
    counts={s:sum(r.get("status")==s for r in summary) for s in ["REAL","PARTIAL","BLOCKED"]}
    final={"schema":"t4h.vercel_aws_migration.estate_receipt.v2","run_id":run_id,"team_slug":TEAM_SLUG,
           "inventory_count":len(projects),"counts":counts,"classification":"REAL" if summary and counts["PARTIAL"]==0 and counts["BLOCKED"]==0 else "PARTIAL",
           "docker_ready":dynamic_ok,"root":str(root),"completed_at":base.now(),"items":summary}
    base.write_json(root/"final-receipt-v2.json",final)
    print(json.dumps({k:final[k] for k in ["run_id","inventory_count","counts","classification","docker_ready","root"]},indent=2))
    print(f"FINAL_RECEIPT={root/'final-receipt-v2.json'}")
    return 0 if final["classification"]=="REAL" else 2

if __name__=="__main__":
    raise SystemExit(main())
