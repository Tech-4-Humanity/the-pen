#!/usr/bin/env python3
"""Receipt-grade quality gate for a canonical ingest run.

Reads the manifest plus v2 upload/verification receipts using Python's TSV parser,
thereby avoiding the Bash IFS/read column-shift defect that caused false S3 404s.
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
from collections import Counter
from pathlib import Path
from typing import Iterable


def read_tsv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def count_matching(rows: Iterable[dict[str, str]], needles: tuple[str, ...]) -> int:
    count = 0
    for row in rows:
        text = " ".join(str(v) for v in row.values()).lower()
        if any(needle in text for needle in needles):
            count += 1
    return count


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
    uploads = read_tsv(upload_path)
    verifies = read_tsv(verify_path)
    upload_counts = status_counts(uploads)
    verify_counts = status_counts(verifies)

    canonical_rows = [r for r in manifest if r.get("canonical_status") != "DUPLICATE"]
    duplicate_rows = [r for r in manifest if r.get("canonical_status") == "DUPLICATE"]
    source_types = Counter((r.get("source_type") or "UNKNOWN") for r in manifest)
    source_roots = Counter((r.get("source_root") or "UNKNOWN") for r in manifest)

    llm_count = count_matching(
        manifest,
        ("conversations-", "shared_conversations.json", "conversation_asset_file_names.json", "chatgpt", "claude", "anthropic", "gemini"),
    )
    linkedin_count = count_matching(manifest, ("linkedin",))
    drive_count = sum(v for k, v in source_types.items() if k.lower() in {"gdrive", "google-drive", "shared-drive"})

    failed = upload_counts.get("FAILED", 0) + verify_counts.get("FAILED", 0) + verify_counts.get("MISMATCH", 0)
    deferred = upload_counts.get("DEFERRED", 0) + verify_counts.get("DEFERRED", 0)
    verified = verify_counts.get("VERIFIED", 0)
    expected = len(canonical_rows)
    complete = expected > 0 and verified == expected and failed == 0 and deferred <= args.allow_deferred

    warnings: list[str] = []
    if set(source_types) == {"mac"} and set(source_roots) == {"daily-index"}:
        warnings.append("Scope is one Mac source root only; this is not the whole Mac or cloud estate.")
    if drive_count == 0:
        warnings.append("Google My Drive and Shared Drives are not represented in this run.")
    if not summary_path.exists():
        warnings.append("Final resume uploader summary is not present yet.")

    report = {
        "status": "REAL" if complete else "PARTIAL",
        "run": str(run),
        "quality_gate": {
            "manifest_rows": len(manifest),
            "canonical_rows": expected,
            "duplicate_rows": len(duplicate_rows),
            "duplicate_ratio": round(len(duplicate_rows) / len(manifest), 6) if manifest else 0,
            "upload_status_counts": dict(sorted(upload_counts.items())),
            "verify_status_counts": dict(sorted(verify_counts.items())),
            "verified_rows": verified,
            "failed_rows": failed,
            "deferred_rows": deferred,
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
        "next_gate": "Publish final receipt and latest pointer" if complete else "Finish/resume upload and clear failures/deferred rows",
    }

    output = args.output or run / "receipts/canonical_ingest_quality_report.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    return 0 if complete else 2


if __name__ == "__main__":
    sys.exit(main())
