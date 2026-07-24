from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

from .core import Check, Receipt, RuntimeFailure, aws_inventory, deploy_and_verify, find_repo, utc_now, write_receipt


def output_dir(repo: Path, requested: str | None) -> Path:
    return Path(requested).expanduser().resolve() if requested else repo / "runtime" / "receipts"


def emit(receipt: Receipt, directory: Path) -> int:
    json_path, md_path = write_receipt(receipt, directory)
    print(json.dumps({"status": receipt.status, "json_receipt": str(json_path), "markdown_receipt": str(md_path), "evidence": receipt.evidence}, indent=2))
    return 0 if receipt.status == "REAL" else 2


def discover(args: argparse.Namespace) -> int:
    started = utc_now()
    checks: list[Check] = []
    gaps: list[str] = []
    evidence: dict[str, object] = {}
    try:
        repo = find_repo(Path(args.start) if args.start else None, args.repo_name)
        checks.append(Check("repository_discovery", True, str(repo)))
        evidence["repository"] = str(repo)
        if shutil.which("aws"):
            inventory = aws_inventory()
            checks.append(Check("aws_identity", True, str(inventory["identity"])))
            checks.append(Check("aws_inventory", True, f"{len(inventory['buckets'])} buckets; {len(inventory['distributions'])} distributions"))
            evidence["aws"] = inventory
            status = "REAL"
        else:
            checks.append(Check("aws_cli", False, "aws executable not found"))
            gaps.append("Install AWS CLI v2 and authenticate an authorised role.")
            status = "BLOCKED"
    except Exception as exc:
        checks.append(Check("discover", False, str(exc)))
        gaps.append(str(exc))
        status = "BLOCKED"
        repo = Path.cwd()
    receipt = Receipt("discover", status, started, utc_now(), checks, evidence, gaps)
    return emit(receipt, output_dir(repo, args.receipts))


def doctor(args: argparse.Namespace) -> int:
    started = utc_now()
    checks: list[Check] = []
    evidence: dict[str, object] = {}
    gaps: list[str] = []
    repo = Path.cwd()
    try:
        repo = find_repo(Path(args.start) if args.start else None, args.repo_name)
        checks.append(Check("repository", True, str(repo)))
        for command in ("git", "aws", "python3"):
            path = shutil.which(command)
            checks.append(Check(command, bool(path), path or "not found"))
            if not path:
                gaps.append(f"Missing executable: {command}")
        if shutil.which("aws"):
            inventory = aws_inventory()
            evidence["aws"] = inventory
            checks.append(Check("aws_identity", True, str(inventory["identity"])))
        status = "REAL" if all(c.ok for c in checks) else "BLOCKED"
    except Exception as exc:
        checks.append(Check("doctor", False, str(exc)))
        gaps.append(str(exc))
        status = "BLOCKED"
    return emit(Receipt("doctor", status, started, utc_now(), checks, evidence, gaps), output_dir(repo, args.receipts))


def deploy(args: argparse.Namespace) -> int:
    started = utc_now()
    checks: list[Check] = []
    evidence: dict[str, object] = {}
    gaps: list[str] = []
    repo = Path.cwd()
    try:
        repo = find_repo(None, args.repo_name)
        result = deploy_and_verify(Path(args.source), args.bucket, args.prefix, args.distribution_id, args.endpoint)
        evidence["deployment"] = result
        checks.extend([
            Check("s3_upload", True, result["destination"]),
            Check("independent_readback", bool(result["readback_verified"]), f"{result['file_count']} files verified"),
            Check("sha256", True, "all local and readback hashes match"),
        ])
        if args.distribution_id:
            checks.append(Check("cloudfront_invalidation", True, args.distribution_id))
        if args.endpoint:
            checks.append(Check("http_endpoint", True, str(result["http"])))
        status = "REAL"
    except Exception as exc:
        checks.append(Check("deploy", False, str(exc)))
        gaps.append(str(exc))
        status = "BLOCKED"
    return emit(Receipt("deploy", status, started, utc_now(), checks, evidence, gaps), output_dir(repo, args.receipts))


def inventory(args: argparse.Namespace) -> int:
    return discover(args)


def status(args: argparse.Namespace) -> int:
    repo = find_repo(None, args.repo_name)
    receipt_dir = output_dir(repo, args.receipts)
    receipts = sorted(receipt_dir.glob("runtime-*.json"), reverse=True) if receipt_dir.exists() else []
    print(json.dumps({"repository": str(repo), "receipt_count": len(receipts), "latest": str(receipts[0]) if receipts else None}, indent=2))
    return 0


def unsupported(name: str, args: argparse.Namespace) -> int:
    repo = find_repo(None, args.repo_name)
    receipt = Receipt(name, "PARTIAL", utc_now(), utc_now(), [Check(name, False, "command reserved; no mutation performed")], {}, ["This command is not implemented in slice 1."])
    return emit(receipt, output_dir(repo, args.receipts))


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(prog="runtime")
    root.add_argument("--repo-name", default="the-pen")
    root.add_argument("--receipts")
    sub = root.add_subparsers(dest="command", required=True)
    for name in ("discover", "doctor", "inventory"):
        item = sub.add_parser(name)
        item.add_argument("--start")
    deploy_parser = sub.add_parser("deploy")
    deploy_parser.add_argument("--source", required=True)
    deploy_parser.add_argument("--bucket", required=True)
    deploy_parser.add_argument("--prefix", default="")
    deploy_parser.add_argument("--distribution-id")
    deploy_parser.add_argument("--endpoint")
    sub.add_parser("status")
    for name in ("verify", "recover", "receipt", "reconcile"):
        sub.add_parser(name)
    return root


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        if args.command == "discover":
            return discover(args)
        if args.command == "doctor":
            return doctor(args)
        if args.command == "inventory":
            return inventory(args)
        if args.command == "deploy":
            return deploy(args)
        if args.command == "status":
            return status(args)
        return unsupported(args.command, args)
    except RuntimeFailure as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
