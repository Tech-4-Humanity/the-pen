#!/usr/bin/env python3
"""
Movement-first Pen inbox processor.

Purpose:
- Prevent inbox jobs from sitting idle.
- Turn every observed inbox payload into either movement receipt or blocker receipt.
- Prefer Bridge execution where configured.
- Never claim REAL unless downstream runtime proof exists.

This script is intentionally safe-by-default:
- It reads inbox/*.json.
- It writes receipts/runtime/*.json.
- It does not expose secrets.
- It can operate in dry/probe mode without Bridge credentials.

Environment variables:
- BRIDGE_INVOKE_URL: optional Bridge API Gateway invoke URL.
- BRIDGE_API_KEY: optional Bridge API key.
- GITHUB_REPOSITORY: defaults to TML-4PM/the-pen.
- MOVEMENT_FIRST_MAX_JOBS: default 25.

Exit behaviour:
- 0 when receipts/blockers were produced or no inbox jobs exist.
- non-zero only for local script/runtime errors.
"""

from __future__ import annotations

import base64
import json
import os
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple
from urllib import request, error

ROOT = Path(__file__).resolve().parents[1]
INBOX = ROOT / "inbox"
RECEIPTS = ROOT / "receipts" / "runtime"
PROCESSED = ROOT / "processed" / "inbox"
DEFAULT_REPO = "TML-4PM/the-pen"


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def safe_slug(value: str) -> str:
    out = []
    for c in value.lower():
        if c.isalnum() or c in ("-", "_"):
            out.append(c)
        else:
            out.append("-")
    slug = "".join(out).strip("-")
    while "--" in slug:
        slug = slug.replace("--", "-")
    return slug[:180] or "unknown"


def read_json(path: Path) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
    try:
        return json.loads(path.read_text(encoding="utf-8")), None
    except Exception as exc:
        return None, f"{type(exc).__name__}: {exc}"


def write_json(path: Path, data: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=False) + "\n", encoding="utf-8")


def git_sha(path: Path) -> Optional[str]:
    # Local git may not be available in all runners; this is best-effort only.
    try:
        import subprocess
        result = subprocess.run(
            ["git", "hash-object", str(path)],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except Exception:
        pass
    return None


def bridge_available() -> bool:
    return bool(os.getenv("BRIDGE_INVOKE_URL") and os.getenv("BRIDGE_API_KEY"))


def bridge_probe(job: Dict[str, Any]) -> Dict[str, Any]:
    """Attempt a non-destructive Bridge probe if credentials are present."""
    if not bridge_available():
        return {
            "attempted": False,
            "result": "blocked",
            "reason": "BRIDGE_INVOKE_URL and/or BRIDGE_API_KEY not configured in runner environment",
        }

    url = os.getenv("BRIDGE_INVOKE_URL", "")
    api_key = os.getenv("BRIDGE_API_KEY", "")

    # Probe uses read-only SQL if the bridge supports troy-sql-executor.
    body = {
        "fn": "troy-sql-executor",
        "payload": {
            "sql": "SELECT now() AS bridge_probe_time;"
        },
    }
    data = json.dumps(body).encode("utf-8")
    req = request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json", "x-api-key": api_key},
        method="POST",
    )
    try:
        with request.urlopen(req, timeout=20) as resp:
            raw = resp.read().decode("utf-8", errors="replace")
            return {
                "attempted": True,
                "result": "response",
                "status": resp.status,
                "body_preview": raw[:1000],
            }
    except error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace") if exc.fp else ""
        return {
            "attempted": True,
            "result": "http_error",
            "status": exc.code,
            "body_preview": raw[:1000],
        }
    except Exception as exc:
        return {
            "attempted": True,
            "result": "error",
            "error_type": type(exc).__name__,
            "error": str(exc),
        }


def classify_job(job: Dict[str, Any]) -> Dict[str, Any]:
    idempotency_key = str(job.get("idempotency_key") or job.get("id") or job.get("title") or "unknown")
    requested_action = job.get("requested_action") or job.get("action") or job.get("fn") or "unknown"
    has_required_shape = bool(idempotency_key and requested_action != "unknown")
    return {
        "idempotency_key": idempotency_key,
        "requested_action": requested_action,
        "has_required_shape": has_required_shape,
        "declared_evidence_state": job.get("evidence_state"),
    }


def receipt_for(path: Path, job: Optional[Dict[str, Any]], parse_error: Optional[str]) -> Dict[str, Any]:
    observed_at = utc_now()
    if job is None:
        key = f"invalid-json-{safe_slug(path.stem)}"
        return {
            "idempotency_key": key,
            "source_path": str(path.relative_to(ROOT)),
            "observed_at": observed_at,
            "status": "blocked_invalid_json",
            "evidence_state": "PARTIAL",
            "movement": True,
            "movement_type": "blocker_receipt_created",
            "parse_error": parse_error,
            "next_executable_action": "Fix JSON syntax or replace payload with valid machine-readable job envelope.",
        }

    meta = classify_job(job)
    bridge = bridge_probe(job)
    missing_permissions: List[str] = []
    missing_secrets: List[str] = []
    missing_resources: List[str] = []
    missing_routes: List[str] = []
    failed_steps: List[Dict[str, Any]] = []

    if not bridge.get("attempted"):
        missing_secrets.extend(["BRIDGE_INVOKE_URL", "BRIDGE_API_KEY"])
        missing_routes.append("Configured runner-to-Bridge route")
        failed_steps.append({
            "step": "bridge_probe",
            "reason": bridge.get("reason"),
        })
    elif bridge.get("result") not in ("response",):
        failed_steps.append({
            "step": "bridge_probe",
            "result": bridge,
        })

    bridge_ok = bridge.get("attempted") is True and bridge.get("result") == "response" and int(bridge.get("status", 0)) in range(200, 300)

    return {
        "idempotency_key": f"movement-{meta['idempotency_key']}",
        "related_idempotency_key": meta["idempotency_key"],
        "source_path": str(path.relative_to(ROOT)),
        "observed_at": observed_at,
        "status": "movement_probe_complete" if bridge_ok else "movement_blocker_recorded",
        "evidence_state": "PARTIAL",
        "movement": True,
        "movement_type": "bridge_probe" if bridge_ok else "blocker_receipt_created",
        "job_classification": meta,
        "bridge_probe": bridge,
        "missing_permissions": missing_permissions,
        "missing_secrets": missing_secrets,
        "missing_resources": missing_resources,
        "missing_routes": missing_routes,
        "failed_steps": failed_steps,
        "next_required_human_action": [] if bridge_ok else [
            "Install/configure Bridge runtime secrets in the runner or route this job through the active Bridge SQL executor path."
        ],
        "next_executable_action": "If bridge probe succeeded, transform this inbox job into downstream registry/evidence writes. If blocked, repair the listed secrets/routes and rerun.",
        "real_classification_rule": "Remain PARTIAL until Bridge processing, registry update, evidence ledger write and Free-zer/canonical reconciliation receipts exist.",
    }


def iter_inbox(max_jobs: int) -> Iterable[Path]:
    if not INBOX.exists():
        return []
    files = sorted(INBOX.glob("*.json"), key=lambda p: p.stat().st_mtime)
    return files[:max_jobs]


def main() -> int:
    max_jobs = int(os.getenv("MOVEMENT_FIRST_MAX_JOBS", "25"))
    paths = list(iter_inbox(max_jobs))
    RECEIPTS.mkdir(parents=True, exist_ok=True)

    summary = {
        "idempotency_key": f"movement-first-run-{safe_slug(utc_now())}",
        "status": "started",
        "started_at": utc_now(),
        "repo": os.getenv("GITHUB_REPOSITORY", DEFAULT_REPO),
        "jobs_seen": len(paths),
        "receipts_written": [],
        "bridge_configured": bridge_available(),
    }

    if not paths:
        summary.update({
            "status": "no_inbox_jobs",
            "finished_at": utc_now(),
            "evidence_state": "REAL",
            "movement": True,
            "movement_type": "empty_queue_probe",
        })
        out = RECEIPTS / "movement_first_empty_queue_probe.json"
        write_json(out, summary)
        print(json.dumps(summary, indent=2))
        return 0

    for path in paths:
        job, parse_error = read_json(path)
        receipt = receipt_for(path, job, parse_error)
        receipt_path = RECEIPTS / f"{safe_slug(receipt['idempotency_key'])}.json"
        write_json(receipt_path, receipt)
        summary["receipts_written"].append(str(receipt_path.relative_to(ROOT)))

    summary.update({
        "status": "complete",
        "finished_at": utc_now(),
        "evidence_state": "PARTIAL",
        "movement": True,
        "movement_type": "receipts_written",
    })
    summary_path = RECEIPTS / "movement_first_run_summary.json"
    write_json(summary_path, summary)
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
