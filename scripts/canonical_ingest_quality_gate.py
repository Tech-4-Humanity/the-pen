#!/usr/bin/env python3
"""Receipt-grade quality gate for a canonical ingest run.

Reads manifest and v2 receipts with Python TSV parsing. Repeated/resumed uploader
runs are reconciled by object identity so idempotent retries cannot inflate counts.
Browser partial-download artefacts are classified as excluded rather than failed.
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
from collections import Counter
from pathlib import Path
from typing import Iterable

TEMP_SUFFIXES = (
    ".crdownload",
    ".part",
    ".partial",
    ".download",
    ".tmp",
)


def read_tsv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def count_matching(rows: Iterable[dict[str, str]], needles: tuple[str, ...]) -> int:
    return sum(
        1
        for row in rows
        if any(needle in " ".join(str(v) for v in row.values()).lower() for needle in needles)
    )


def row_text(row: dict[str, str]) -> str:
    return " ".join(str(v) for v in row.values()).lower()


def is_temporary_download(row: dict[str, str]) -> bool:
    text = row_text(row)
    return any(suffix in text for suffix in TEMP_SUFFIXES)


def object_key(row: dict[str, str]) -> str:
    """Return the stable object identity used across upload and verify receipts."""
    return (row.get("s3_uri") or row.get("stage_path") or row.get("sha256") or "").strip()


def latest_by_object(rows: Iterable[dict[str, str]]) -> dict[str, dict[str, str]]:
    """Last receipt row wins for each object, matching append-only resume semantics."""
    result: dict[str, dict[str, str]] = {}
    for index, row in enumerate(rows):
        key = object_key(row) or f"__unkeyed__:{index}"
        result[key] = row
    return result


def status_counts(rows: Iterable[dict[str, str]]) -> Counter[str]:
    result: Counter[str] = Counter()
    for row in rows:
        value = (row.get("status") or "").strip()
        if value:
            result[value] += 1
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run", required=True, type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--allow-deferred", type=int, default=0)
    args = parser.parse_args()

    run = args.run.expanduser().resolve()
    manifest_path = run / "manifests/master_manifest.tsv"
    upload_path = run / "receipts/upload_receipt_v2.tsv"
    verify_path = run / "receipts/verify_receipt_v2.tsv"
    summary_path = run / "receipts/resume_upload_v2_summary.json"

    manifest = read_tsv(manifest_path)
    upload_raw = read_tsv(upload_path)
    verify_raw = read_tsv(verify_path)
    uploads = latest_by_object(upload_raw)
    verifies = latest_by_object(verify_raw)

    canonical_rows_all = [r for r in manifest if r.get("canonical_status") != "DUPLICATE"]
    excluded_temp_rows = [r for r in canonical_rows_all if is_temporary_download(r)]
    canonical_rows = [r for r in canonical_rows_all if not is_temporary_download(r)]
    duplicate_rows = [r for r in manifest if r.get("canonical_status") == "DUPLICATE"]

    uploads_in_scope = {k: r for k, r in uploads.items() if not is_temporary_download(r)}
    verifies_in_scope = {k: r for k, r in verifies.items() if not is_temporary_download(r)}
    upload_counts = status_counts(uploads_in_scope.values())
    verify_counts = status_counts(verifies_in_scope.values())

    source_types = Counter((r.get("source_type") or "UNKNOWN") for r in manifest)
    source_roots = Counter((r.get("source_root") or "UNKNOWN") for r in manifest)

    expected_objects = {
        (r.get("s3_uri") or r.get("stage_path") or r.get("sha256") or "").strip()
        for r in canonical_rows
    }
    expected_objects.discard("")
    verified_objects = {
        key for key, row in verifies_in_scope.items() if (row.get("status") or "").strip() == "VERIFIED"
    }
    missing_objects = expected_objects - verified_objects
    unexpected_verified = verified_objects - expected_objects

    llm_count = count_matching(
        manifest,
        ("conversations-", "shared_conversations.json", "conversation_asset_file_names.json", "chatgpt", "claude", "anthropic", "gemini"),
    )
    linkedin_count = count_matching(manifest, ("linkedin",))
    drive_count = sum(v for k, v in source_types.items() if k.lower() in {"gdrive", "google-drive", "shared-drive"})

    failed = upload_counts.get("FAILED", 0) + verify_counts.get("FAILED", 0) + verify_counts.get("MISMATCH", 0)
    deferred = upload_counts.get("DEFERRED", 0) + verify_counts.get("DEFERRED", 0)
    expected = len(expected_objects) if expected_objects else len(canonical_rows)
    verified = len(verified_objects & expected_objects) if expected_objects else verify_counts.get("VERIFIED", 0)
    complete = expected > 0 and not missing_objects and failed == 0 and deferred <= args.allow_deferred

    warnings: list[str] = []
    if set(source_types) == {"mac"} and set(source_roots) == {"daily-index"}:
        warnings.append("Scope is one Mac source root only; this is not the whole Mac or cloud estate.")
    if drive_count == 0:
        warnings.append("Google My Drive and Shared Drives are not represented in this run.")
    if not summary_path.exists():
        warnings.append("Final resume uploader summary is not present yet.")
    if len(upload_raw) != len(uploads):
        warnings.append(f"Collapsed {len(upload_raw) - len(uploads)} repeated upload receipt rows from resumed/idempotent runs.")
    if len(verify_raw) != len(verifies):
        warnings.append(f"Collapsed {len(verify_raw) - len(verifies)} repeated verification rows from resumed/idempotent runs.")
    if excluded_temp_rows:
        warnings.append(f"Excluded {len(excluded_temp_rows)} browser partial-download artefacts from the canonical verification requirement.")
    if unexpected_verified:
        warnings.append(f"Observed {len(unexpected_verified)} verified receipt objects not present in the canonical manifest set.")

    report = {
        "status": "REAL" if complete else "PARTIAL",
        "run": str(run),
        "quality_gate": {
            "manifest_rows": len(manifest),
            "canonical_rows_before_exclusions": len(canonical_rows_all),
            "excluded_temporary_download_rows": len(excluded_temp_rows),
            "canonical_rows": len(canonical_rows),
            "canonical_object_identities": expected,
            "duplicate_rows": len(duplicate_rows),
            "duplicate_ratio": round(len(duplicate_rows) / len(manifest), 6) if manifest else 0,
            "raw_upload_receipt_rows": len(upload_raw),
            "deduplicated_upload_objects": len(uploads),
            "raw_verify_receipt_rows": len(verify_raw),
            "deduplicated_verify_objects": len(verifies),
            "upload_status_counts": dict(sorted(upload_counts.items())),
            "verify_status_counts": dict(sorted(verify_counts.items())),
            "verified_objects": verified,
            "missing_verification_objects": len(missing_objects),
            "unexpected_verified_objects": len(unexpected_verified),
            "failed_objects": failed,
            "deferred_objects": deferred,
            "allow_deferred": args.allow_deferred,
        },
        "coverage": {
            "source_types": dict(source_types),
            "source_roots": dict(source_roots),
            "json_files": sum(1 for r in manifest if (r.get("filename") or "").lower().endswith(".json")),
            "likely_llm_chat_assets": llm_count,
            "likely_linkedin_assets": linkedin_count,
            "google_drive_or_shared_drive_rows": drive_count,
            "scope_classification": "MAC_DAILY_INDEX_ONLY" if drive_count == 0 and set(source_roots) == {"daily-index"} else "MULTI_SOURCE",
        },
        "warnings": warnings,
        "next_gate": "Publish final receipt and latest pointer" if complete else "Clear missing, failed, or deferred object identities",
    }

    output = args.output or run / "receipts/canonical_ingest_quality_report.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    return 0 if complete else 2


if __name__ == "__main__":
    sys.exit(main())
