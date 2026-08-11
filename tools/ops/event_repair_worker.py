#!/usr/bin/env python3
"""T4H event-driven GitHub workflow repair worker.

Fail-closed repair scope:
- scans GitHub Actions workflows and local actions for YAML syntax errors;
- repairs deterministic plain-scalar `: ` parsing defects by quoting the scalar;
- validates every proposed repair with Ruby/Psych before changing the checkout;
- creates a repair branch and pull request; never writes directly to main;
- records unresolved findings explicitly.
"""

import json
import os
import pathlib
import re
import subprocess
import sys
import tempfile
from datetime import datetime, timezone

ROOT = pathlib.Path(os.environ.get("GITHUB_WORKSPACE", ".")).resolve()
SCAN_ROOTS = [ROOT / ".github" / "workflows", ROOT / ".github" / "actions"]
YAML_SUFFIXES = {".yml", ".yaml"}
KEY_RE = re.compile(r"^(\s*)([A-Za-z0-9_.-]+):(\s+)(.*)$")


def run(cmd, check=True, **kwargs):
    return subprocess.run(cmd, check=check, text=True, **kwargs)


def yaml_ok(path):
    result = run(
        ["ruby", "-e", "require 'yaml'; YAML.load_file(ARGV[0]);", str(path)],
        check=False,
        capture_output=True,
    )
    return result.returncode == 0, result.stderr.strip()


def repair_plain_scalars(text):
    """Quote mapping scalars containing ': ' when they are plainly unquoted."""
    out = []
    changed = False
    for line in text.splitlines(keepends=True):
        raw = line.rstrip("\r\n")
        ending = line[len(raw):]
        match = KEY_RE.match(raw)
        if not match:
            out.append(line)
            continue
        indent, key, whitespace, value = match.groups()
        stripped = value.strip()
        if (
            not stripped
            or stripped.startswith(("#", "'", '"', "|", ">", "[", "{"))
            or ": " not in stripped
        ):
            out.append(line)
            continue
        out.append(f"{indent}{key}:{whitespace}{json.dumps(stripped, ensure_ascii=False)}{ending}")
        changed = True
    return "".join(out), changed


def scan():
    findings = []
    fixes = {}
    for root in SCAN_ROOTS:
        if not root.exists():
            continue
        for path in sorted(root.rglob("*")):
            if not path.is_file() or path.suffix.lower() not in YAML_SUFFIXES:
                continue
            ok, error = yaml_ok(path)
            if ok:
                findings.append({"file": str(path.relative_to(ROOT)), "status": "OK"})
                continue
            original = path.read_text(encoding="utf-8")
            repaired, changed = repair_plain_scalars(original)
            if not changed:
                findings.append({"file": str(path.relative_to(ROOT)), "status": "UNFIXED", "error": error})
                continue
            with tempfile.NamedTemporaryFile("w", suffix=path.suffix, delete=False, encoding="utf-8") as temp:
                temp.write(repaired)
                temp_path = pathlib.Path(temp.name)
            try:
                repaired_ok, repaired_error = yaml_ok(temp_path)
            finally:
                temp_path.unlink(missing_ok=True)
            if repaired_ok:
                fixes[path] = repaired
                findings.append({"file": str(path.relative_to(ROOT)), "status": "FIXABLE", "error": error})
            else:
                findings.append({"file": str(path.relative_to(ROOT)), "status": "UNFIXED", "error": repaired_error})
    return findings, fixes


def write_receipt(findings, fixes):
    receipt_dir = ROOT / "receipts" / "runtime"
    receipt_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    receipt = receipt_dir / f"event-repair-{stamp}.json"
    payload = {
        "worker": "t4h-event-repair-worker",
        "timestamp_utc": stamp,
        "classification": "REAL",
        "scan_roots": [str(p.relative_to(ROOT)) for p in SCAN_ROOTS if p.exists()],
        "findings": findings,
        "fix_count": len(fixes),
    }
    receipt.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return receipt


def create_pr(changed_paths, receipt):
    branch = "ops/event-repair/" + datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    run(["git", "config", "user.name", "t4h-event-repair-worker"])
    run(["git", "config", "user.email", "t4h-event-repair-worker@users.noreply.github.com"])
    run(["git", "checkout", "-b", branch])
    run(["git", "add", *[str(p.relative_to(ROOT)) for p in changed_paths], str(receipt.relative_to(ROOT))])
    run(["git", "commit", "-m", "fix(ops): repair invalid GitHub workflow YAML"])
    run(["git", "push", "--set-upstream", "origin", branch])

    repo = os.environ.get("GITHUB_REPOSITORY", "TML-4PM/the-pen")
    title = "fix(ops): self-heal invalid GitHub workflow YAML"
    body = (
        "Automated repair proposal from `t4h-event-repair-worker`.\n\n"
        "The worker detected deterministic GitHub Actions YAML syntax defects, "
        "validated the proposed repairs independently, and committed them to this branch.\n\n"
        f"Changed files: {len(changed_paths)}\n"
        f"Receipt: `{receipt.relative_to(ROOT)}`\n\n"
        "The worker never writes directly to `main`; merge remains a separate governed action."
    )
    run(["gh", "pr", "create", "--repo", repo, "--base", "main", "--head", branch, "--title", title, "--body", body])
    print(json.dumps({"branch": branch, "changed_files": len(changed_paths), "receipt": str(receipt.relative_to(ROOT))}))


def main():
    findings, fixes = scan()
    if fixes:
        for path, content in fixes.items():
            path.write_text(content, encoding="utf-8")
    receipt = write_receipt(findings, fixes)
    unresolved = [f for f in findings if f["status"] == "UNFIXED"]
    print(json.dumps({"findings": findings, "fix_count": len(fixes), "unfixed_count": len(unresolved)}, indent=2))
    if fixes:
        create_pr(list(fixes), receipt)
    if unresolved:
        print("Unresolved findings remain; no automatic success claim.", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
