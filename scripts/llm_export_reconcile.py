#!/usr/bin/env python3
"""Reconcile LLM export candidates without deleting, uploading, or hydrating files.

The input inventory intentionally has broad filename matches. This script separates
full provider exports from incidental files whose names merely mention a provider,
hashes readable local files, deduplicates only within one account scope, and emits
plans that remain blocked until S3 verification is supplied.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import sys
from collections import Counter, defaultdict
from pathlib import Path

PROVIDERS = ("GPT", "CLAUDE", "GROK", "GEMINI", "PERPLEXITY")
CORE_ACCOUNT_PROVIDERS = ("GPT", "CLAUDE")
ACCOUNT_SCOPES = ("GMAIL", "T4H", "MAC_DESKTOP")


def sha256_file(path: Path, chunk_size: int = 8 * 1024 * 1024) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        while chunk := handle.read(chunk_size):
            digest.update(chunk)
    return digest.hexdigest()


def read_tsv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def account_scope(path_text: str, root_text: str) -> str:
    text = f"{root_text} {path_text}".lower()
    if "googledrive-troy@tech4humanity.com.au" in text:
        return "T4H"
    if "googledrive-troy.latter@gmail.com" in text:
        return "GMAIL"
    if "/desktop/" in text or root_text.endswith("/Desktop"):
        return "MAC_DESKTOP"
    return "OTHER"


def provider_names(models: str) -> list[str]:
    found = [x.strip().upper() for x in models.split(",") if x.strip()]
    return [x for x in found if x in PROVIDERS] or ["UNKNOWN"]


def is_full_export_candidate(row: dict[str, str], path: Path) -> bool:
    """Conservative test for a provider account export rather than incidental code."""
    name = path.name.lower()
    path_text = str(path).lower()
    size = int(row.get("bytes") or 0)
    suffix = path.suffix.lower()

    strong_names = (
        "conversations.json",
        "conversations (1).json",
        "gpt conversations",
        "claude conversations",
        "gpt data",
        "chat gpt data",
        "gpt chats",
        "claude data",
        "claude last 90 days",
        "prod-grok-backend",
        "gemini_full_export",
        "takeout-",
    )
    strong_path = any(
        marker in path_text
        for marker in (
            "/llm-json-intake/",
            "/llm chats/",
            "/llm-intake/raw/",
            "/001 - llm chats - li articles/",
        )
    )
    strong_name = any(marker in name for marker in strong_names)

    if name.endswith(".crdownload"):
        return strong_name or size >= 100 * 1024 * 1024
    if suffix not in {".zip", ".json", ".jsonl", ".ndjson"}:
        return False
    if size < 1024:
        return False
    return strong_name or (strong_path and size >= 1 * 1024 * 1024)


def preferred_copy(group: list[dict[str, str]]) -> dict[str, str]:
    return sorted(
        group,
        key=lambda item: (
            "Shared drives/T4H1" not in item.get("path", ""),
            "Shared drives/LLM Chats" not in item.get("path", ""),
            "My Drive" not in item.get("path", ""),
            "Desktop" in item.get("root", ""),
            -int(item.get("modified_epoch") or 0),
        ),
    )[0]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--inventory", required=True, type=Path)
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--min-free-gb", type=float, default=5.0)
    args = parser.parse_args()

    inventory = args.inventory.expanduser().resolve()
    output_dir = (args.output_dir or inventory.parent / "reconciliation").expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    rows = read_tsv(inventory)
    statvfs = os.statvfs(str(Path.home()))
    free_bytes = statvfs.f_bavail * statvfs.f_frsize
    hashing_allowed = free_bytes >= int(args.min_free_gb * 1024**3)

    enriched: list[dict[str, str]] = []
    hashes_by_scope: dict[tuple[str, str], list[dict[str, str]]] = defaultdict(list)
    full_export_hashes: dict[str, list[dict[str, str]]] = defaultdict(list)

    for row in rows:
        path = Path(row.get("path", ""))
        classification = row.get("classification", "")
        scope = account_scope(row.get("path", ""), row.get("root", ""))
        providers = provider_names(row.get("models", ""))
        full_export = is_full_export_candidate(row, path)

        result = dict(row)
        result.update({
            "account_scope": scope,
            "provider": ",".join(providers),
            "full_export_candidate": str(full_export).lower(),
            "exists": "false",
            "readable": "false",
            "sha256": "",
            "hash_status": "NOT_ATTEMPTED",
            "recommended_action": "REVIEW",
            "reason": "",
        })

        try:
            exists = path.is_file()
        except OSError:
            exists = False
        result["exists"] = str(exists).lower()

        if classification == "INCOMPLETE_DOWNLOAD" or path.name.lower().endswith(".crdownload"):
            result["recommended_action"] = "RETAIN_INCOMPLETE_PENDING_REPLACEMENT"
            result["reason"] = "Incomplete provider export; do not remove until a complete replacement is verified."
        elif classification == "TINY_ZIP_OR_PLACEHOLDER" or (
            path.suffix.lower() == ".zip" and int(row.get("bytes") or 0) < 1024
        ):
            result["recommended_action"] = "DELETE_AFTER_RECEIPT"
            result["reason"] = "Tiny ZIP or placeholder; retain a gap/forensic receipt first."
        elif not full_export:
            result["recommended_action"] = "RETAIN_NON_EXPORT_ARTIFACT"
            result["reason"] = "Provider-named project artefact, not classified as a full account export."
        elif not exists:
            result["recommended_action"] = "RETAIN_CLOUD_REFERENCE_PENDING_API_VERIFY"
            result["reason"] = "Cloud object is not locally materialised; verify by Drive API or controlled hydration."
        elif not hashing_allowed:
            result["recommended_action"] = "RETAIN_PENDING_HASH"
            result["reason"] = "Disk free-space gate prevented hashing."
            result["hash_status"] = "BLOCKED_LOW_DISK"
        else:
            try:
                digest = sha256_file(path)
                result["readable"] = "true"
                result["sha256"] = digest
                result["hash_status"] = "HASHED"
                result["recommended_action"] = "RETAIN_UNIQUE_EXPORT_PENDING_S3"
                hashes_by_scope[(scope, digest)].append(result)
                full_export_hashes[digest].append(result)
            except (OSError, PermissionError) as exc:
                result["hash_status"] = "READ_FAILED"
                result["recommended_action"] = "RETAIN_CLOUD_UNREADABLE_PENDING_API_VERIFY"
                result["reason"] = str(exc)[:300]

        enriched.append(result)

    duplicate_groups: list[dict[str, object]] = []
    for (scope, digest), group in hashes_by_scope.items():
        if len(group) < 2:
            continue
        preferred = preferred_copy(group)
        for item in group:
            if item is preferred:
                item["recommended_action"] = "RETAIN_CANONICAL_ACCOUNT_EXPORT_PENDING_S3"
                item["reason"] = f"Preferred {scope} copy for SHA-256 {digest}."
            else:
                item["recommended_action"] = "DELETE_AFTER_S3_VERIFY"
                item["reason"] = f"Exact duplicate within {scope} of {preferred.get('path', '')}."
        duplicate_groups.append({
            "account_scope": scope,
            "sha256": digest,
            "bytes": int(preferred.get("bytes") or 0),
            "copies": len(group),
            "canonical_path": preferred.get("path", ""),
            "duplicate_paths": [x.get("path", "") for x in group if x is not preferred],
        })

    cross_account_matches: list[dict[str, object]] = []
    for digest, group in full_export_hashes.items():
        scopes = sorted({x.get("account_scope", "") for x in group})
        if "GMAIL" in scopes and "T4H" in scopes:
            cross_account_matches.append({
                "sha256": digest,
                "account_scopes": scopes,
                "paths": [x.get("path", "") for x in group],
                "action": "RETAIN_ONE_COPY_PER_ACCOUNT_SCOPE",
            })

    fields = list(enriched[0].keys()) if enriched else []
    reconciled_path = output_dir / "llm_export_reconciled.tsv"
    with reconciled_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t")
        writer.writeheader()
        writer.writerows(enriched)

    delete_plan_path = output_dir / "delete_plan.tsv"
    delete_rows = [r for r in enriched if r["recommended_action"].startswith("DELETE_")]
    with delete_plan_path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t")
        writer.writeheader()
        writer.writerows(delete_rows)

    full_exports = [r for r in enriched if r["full_export_candidate"] == "true"]
    coverage = Counter((r["provider"], r["account_scope"]) for r in full_exports)
    unresolved = [
        r for r in full_exports
        if r["recommended_action"] in {
            "RETAIN_INCOMPLETE_PENDING_REPLACEMENT",
            "RETAIN_CLOUD_REFERENCE_PENDING_API_VERIFY",
            "RETAIN_CLOUD_UNREADABLE_PENDING_API_VERIFY",
            "RETAIN_PENDING_HASH",
        }
    ]

    required_missing = []
    for provider in CORE_ACCOUNT_PROVIDERS:
        for scope in ("GMAIL", "T4H"):
            if coverage[(provider, scope)] == 0:
                required_missing.append(f"{provider}:{scope}")

    status = "REAL" if not unresolved and not required_missing else "PARTIAL"
    summary = {
        "status": status,
        "mode": "PLAN_ONLY_NO_DELETION_NO_UPLOAD",
        "inventory": str(inventory),
        "free_bytes": free_bytes,
        "hashing_allowed": hashing_allowed,
        "candidate_rows": len(rows),
        "full_export_candidates": len(full_exports),
        "non_export_provider_artifacts": len(rows) - len(full_exports),
        "hashed_full_exports": sum(1 for r in full_exports if r["hash_status"] == "HASHED"),
        "unresolved_full_exports": len(unresolved),
        "required_account_provider_gaps": required_missing,
        "account_scope_counts_all_matches": dict(Counter(r["account_scope"] for r in enriched)),
        "account_scope_counts_full_exports": dict(Counter(r["account_scope"] for r in full_exports)),
        "provider_account_coverage": {
            f"{provider}:{scope}": count
            for (provider, scope), count in sorted(coverage.items())
        },
        "duplicate_groups_within_account": len(duplicate_groups),
        "duplicate_copies_within_account": sum(max(0, int(g["copies"]) - 1) for g in duplicate_groups),
        "cross_account_same_hash_groups": len(cross_account_matches),
        "delete_plan_rows": len(delete_rows),
        "actions": dict(Counter(r["recommended_action"] for r in enriched)),
        "reconciled_manifest": str(reconciled_path),
        "delete_plan": str(delete_plan_path),
        "duplicate_groups_file": str(output_dir / "duplicate_groups.json"),
        "cross_account_matches_file": str(output_dir / "cross_account_matches.json"),
        "policy": "Retain one canonical GPT and Claude export family per account: Gmail and T4H. Never delete incomplete exports before verified replacement.",
        "next_gate": "Resolve cloud-unreadable account exports, verify canonical account-scoped exports in S3, then regenerate the delete plan.",
    }

    (output_dir / "duplicate_groups.json").write_text(
        json.dumps(duplicate_groups, indent=2) + "\n", encoding="utf-8"
    )
    (output_dir / "cross_account_matches.json").write_text(
        json.dumps(cross_account_matches, indent=2) + "\n", encoding="utf-8"
    )
    (output_dir / "summary.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
