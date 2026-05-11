#!/usr/bin/env python3
"""
Cleanup Day Rerun Harness

Purpose:
- parse the GDrive artefact catalogue
- classify assets
- extract runtime references
- detect bridge/pen signals
- build project clusters
- generate recovery queues
- emit REAL/PARTIAL/BLOCKED ledgers

This is intentionally dependency-light so it can run locally,
in CI, inside bridge workers, or inside future orchestration agents.
"""

from __future__ import annotations

import csv
import json
import os
import re
from collections import Counter, defaultdict
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Dict, List, Optional

ROOT = Path.cwd()
OUTPUT = ROOT / "cleanup-day" / "output"
OUTPUT.mkdir(parents=True, exist_ok=True)

KEYWORDS = {
    "bridge": ["bridge", "dispatch", "receipt", "invoke"],
    "pen": ["the-pen", "pen", "handoff"],
    "atlas": ["atlas", "dra", "drug resilience"],
    "signal": ["signal", "synal", "doolittle", "chatter"],
    "family": ["workfamily", "reading buddy", "schoolfamily"],
    "runtime": ["vercel", "supabase", "stripe", "lambda", "aws"],
}

BUSINESS_MAP = {
    "workfamily": "WorkFamilyAI",
    "reading": "Reading Buddy",
    "atlas": "Drug Resilience Atlas",
    "dra": "Drug Resilience Atlas",
    "synal": "Synal",
    "consentx": "ConsentX",
    "gcbat": "GC-BAT",
    "neuropak": "NEUROPAK",
    "ratpak": "RATPAK",
    "outcome": "Outcome Ready",
}

URL_REGEX = re.compile(r"https?://[^\s\"'<>]+")


@dataclass
class Asset:
    path: str
    ext: str
    category: str
    business: str
    runtime_refs: List[str]
    urls: List[str]
    state: str


def classify_state(asset: Asset) -> str:
    if asset.runtime_refs and asset.urls:
        return "PARTIAL"
    if asset.business != "UNCLASSIFIED":
        return "PARTIAL"
    return "BLOCKED"


def detect_business(path: str) -> str:
    lowered = path.lower()
    for k, v in BUSINESS_MAP.items():
        if k in lowered:
            return v
    return "UNCLASSIFIED"


def detect_runtime_refs(path: str) -> List[str]:
    refs = []
    lowered = path.lower()
    for group, terms in KEYWORDS.items():
        if any(t in lowered for t in terms):
            refs.append(group)
    return refs


def detect_category(ext: str) -> str:
    return {
        ".js": "script",
        ".ts": "script",
        ".tsx": "component",
        ".html": "page",
        ".json": "config",
        ".md": "doc",
        ".png": "image",
        ".jpg": "image",
        ".jpeg": "image",
        ".csv": "data",
    }.get(ext.lower(), "other")


def parse_catalogue(csv_path: Path) -> List[Asset]:
    assets: List[Asset] = []

    with open(csv_path, newline="", encoding="utf-8", errors="ignore") as f:
        reader = csv.DictReader(f)

        for row in reader:
            raw = json.dumps(row)
            path = row.get("path") or row.get("name") or raw[:120]
            ext = Path(path).suffix.lower()

            business = detect_business(path)
            runtime_refs = detect_runtime_refs(path)
            urls = URL_REGEX.findall(raw)

            asset = Asset(
                path=path,
                ext=ext,
                category=detect_category(ext),
                business=business,
                runtime_refs=runtime_refs,
                urls=urls,
                state="PARTIAL",
            )

            asset.state = classify_state(asset)
            assets.append(asset)

    return assets


def write_csv(path: Path, rows: List[Dict]):
    if not rows:
        return

    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def main():
    catalogue = ROOT / "GDrive Artifact Catalogue — 2026-03-01 05_01 - Catalogue.csv"

    if not catalogue.exists():
        raise FileNotFoundError(f"Catalogue missing: {catalogue}")

    assets = parse_catalogue(catalogue)

    registry = [asdict(a) for a in assets]
    write_csv(OUTPUT / "asset_registry.csv", registry)

    clusters = defaultdict(list)
    for a in assets:
        clusters[a.business].append(a.path)

    cluster_rows = []
    for business, items in clusters.items():
        cluster_rows.append({
            "business": business,
            "count": len(items),
            "sample": items[:5],
        })

    write_csv(OUTPUT / "project_clusters.csv", cluster_rows)

    recovery_rows = []
    for a in assets:
        if a.state != "REAL":
            recovery_rows.append({
                "path": a.path,
                "business": a.business,
                "state": a.state,
                "runtime_refs": ",".join(a.runtime_refs),
                "next_action": "validate_runtime_and_receipts",
            })

    write_csv(OUTPUT / "recovery_queue.csv", recovery_rows)

    runtime_rows = []
    for a in assets:
        for u in a.urls:
            runtime_rows.append({
                "path": a.path,
                "url": u,
                "business": a.business,
                "status": "UNKNOWN",
            })

    if runtime_rows:
        write_csv(OUTPUT / "runtime_checks.csv", runtime_rows)

    monetisation_rows = []
    for a in assets:
        if any(r in a.runtime_refs for r in ["runtime", "bridge", "signal"]):
            monetisation_rows.append({
                "business": a.business,
                "path": a.path,
                "monetisation_candidate": True,
                "next_action": "map_stripe_and_offer",
            })

    if monetisation_rows:
        write_csv(OUTPUT / "monetisation_queue.csv", monetisation_rows)

    summary = {
        "total_assets": len(assets),
        "by_category": dict(Counter(a.category for a in assets)),
        "by_state": dict(Counter(a.state for a in assets)),
        "by_business": dict(Counter(a.business for a in assets)),
    }

    with open(OUTPUT / "executive_summary.md", "w", encoding="utf-8") as f:
        f.write("# Cleanup Day Executive Summary\n\n")
        f.write(json.dumps(summary, indent=2))

    with open(OUTPUT / "reality_ledger.jsonl", "w", encoding="utf-8") as f:
        for a in assets:
            row = {
                "task_id": f"cleanup::{a.path}",
                "status": a.state,
                "evidence": {
                    "path": a.path,
                    "runtime_refs": a.runtime_refs,
                },
            }
            f.write(json.dumps(row) + "\n")

    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
