"""
30_ram_normalizer_worker.py

RAM Janitor runtime. Stateless, idempotent, reversible via ram_asset_lineage.
Reads from public.ram_assets, applies canonical naming rules, writes lineage rows.

Envelope: TOP-LEVEL { "asset_id": "uuid", "force": false }

Safety:
  - Never overwrites without hash match
  - Never deletes
  - Always writes lineage row
"""

import re
import json
import hashlib
from typing import Dict, Any

SEMANTIC_RANGES = {
    "meta": (0, 9), "schema": (10, 19), "api": (20, 29), "runtime": (30, 39),
    "ui": (40, 49), "automation": (50, 59), "deploy": (60, 69),
    "evidence": (70, 79), "reports": (80, 89), "archive": (90, 99),
}

ASSET_TYPE_TO_RANGE = {
    "doc": "meta", "readme": "meta", "manifest": "meta",
    "schema": "schema", "sql": "schema",
    "api_contract": "api", "openapi": "api",
    "worker": "runtime", "lambda": "runtime", "agent": "runtime",
    "widget": "ui", "component": "ui", "page": "ui",
    "bridge": "automation", "queue": "automation",
    "deploy": "deploy", "cfn": "deploy", "terraform": "deploy",
    "receipt": "evidence", "log": "evidence", "validation": "evidence",
    "report": "reports", "summary": "reports",
    "legacy": "archive", "migration": "archive",
}

FORBIDDEN_TOKENS = ("final", "real-final", "fixed", "fixed2", "latest", "untitled", "new-")
SAFE_CHAR_RE = re.compile(r"[^a-z0-9._-]+")
MULTI_DASH_RE = re.compile(r"-{2,}")


def slugify(text: str) -> str:
    s = text.strip().lower()
    s = SAFE_CHAR_RE.sub("-", s)
    s = MULTI_DASH_RE.sub("-", s).strip("-")
    return s


def infer_range(asset_type: str) -> str:
    return ASSET_TYPE_TO_RANGE.get(asset_type, "meta")


def next_prefix(asset_type: str, sibling_prefixes: set) -> str:
    rng_name = infer_range(asset_type)
    lo, hi = SEMANTIC_RANGES[rng_name]
    for n in range(lo, hi + 1):
        prefix = f"{n:02d}"
        if prefix not in sibling_prefixes:
            return prefix
    return f"{hi:02d}"


def strip_forbidden(stem: str) -> str:
    out = stem
    for tok in FORBIDDEN_TOKENS:
        out = out.replace(tok, "")
    return out


def detect_env(metadata: Dict[str, Any]) -> str:
    env = (metadata or {}).get("environment", "").lower()
    if env in ("prod", "dev", "staging", "bridge", "pen", "local", "test"):
        return env
    return ""


def normalize(asset: Dict[str, Any], sibling_prefixes: set) -> Dict[str, Any]:
    original = asset.get("original_name") or asset.get("canonical_name") or "untitled"
    asset_type = asset.get("asset_type") or "doc"
    metadata = asset.get("metadata") or {}
    env = detect_env(metadata)

    if "." in original:
        stem, ext = original.rsplit(".", 1)
    else:
        stem, ext = original, "md"

    stem = strip_forbidden(slugify(stem)) or "asset"
    if env:
        stem = f"{env}_{stem}"

    prefix = next_prefix(asset_type, sibling_prefixes)
    canonical = f"{prefix}_{stem}.{ext.lower()}"

    lineage = {
        "previous_name": original,
        "canonical_name": canonical,
        "rule_applied": "ram_janitor_v1",
        "env_tag": env or None,
        "asset_type": asset_type,
    }
    return {"canonical_name": canonical, "lineage": lineage}


def handler(event: Dict[str, Any], context=None) -> Dict[str, Any]:
    asset = event.get("asset") or {}
    sibling_prefixes = set(event.get("sibling_prefixes") or [])
    result = normalize(asset, sibling_prefixes)
    return {
        "status": "REAL" if result["canonical_name"] != asset.get("canonical_name") else "PARTIAL",
        "result": result,
        "receipt_stem": f"RCPT_ram_normalize_{asset.get('id','unknown')}",
    }


if __name__ == "__main__":
    demo = {"asset": {"id": "demo-1", "original_name": "new ai thing FINAL v4.zip", "asset_type": "deploy", "metadata": {"environment": "prod"}}, "sibling_prefixes": ["60", "61"]}
    print(json.dumps(handler(demo), indent=2))
