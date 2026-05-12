"""
31_ram_validator_worker.py

RAM Validator runtime. Runs typed checks against assets and writes
evidence rows + validation rows. Reality-Ledger compatible.

Envelope: TOP-LEVEL
  {"asset_id": "uuid", "checks": ["link","repo","deploy","hash","naming","evidence"]}
"""

import json
import re
import hashlib
from typing import Dict, Any, List

NAMING_RE = re.compile(r"^([0-9]{2})_([a-z0-9_-]+)(?:_v[0-9-]+)?\.[a-z0-9]+$")
FORBIDDEN_TOKENS = ("final", "real-final", "fixed", "fixed2", "latest", "untitled")


def check_naming(name: str) -> Dict[str, Any]:
    ok = bool(NAMING_RE.match(name))
    forbidden = [t for t in FORBIDDEN_TOKENS if t in name.lower()]
    score = 1.0 if ok and not forbidden else (0.5 if ok else 0.0)
    return {
        "status": "REAL" if ok and not forbidden else ("PARTIAL" if ok else "BLOCKED"),
        "score": score,
        "evidence": {"forbidden_tokens": forbidden, "pattern_match": ok},
    }


def check_hash(content_bytes: bytes, declared_hash: str) -> Dict[str, Any]:
    actual = hashlib.sha256(content_bytes).hexdigest() if content_bytes is not None else None
    if not declared_hash:
        return {"status": "PARTIAL", "score": 0.5, "evidence": {"actual_hash": actual}}
    return {
        "status": "REAL" if actual == declared_hash else "BLOCKED",
        "score": 1.0 if actual == declared_hash else 0.0,
        "evidence": {"actual_hash": actual, "declared_hash": declared_hash},
    }


def check_link(url: str, http_status: int) -> Dict[str, Any]:
    # http_status is provided by the bridge probe; this worker is stateless
    if http_status == 0:
        return {"status": "BLOCKED", "score": 0.0, "evidence": {"url": url, "reason": "no_probe"}}
    if 200 <= http_status < 300:
        return {"status": "REAL", "score": 1.0, "evidence": {"url": url, "http": http_status}}
    if 300 <= http_status < 400:
        return {"status": "PARTIAL", "score": 0.6, "evidence": {"url": url, "http": http_status}}
    return {"status": "BLOCKED", "score": 0.0, "evidence": {"url": url, "http": http_status}}


def check_repo(repo_present: bool, repo_uri: str) -> Dict[str, Any]:
    if repo_present:
        return {"status": "REAL", "score": 1.0, "evidence": {"repo": repo_uri}}
    return {"status": "BLOCKED", "score": 0.0, "evidence": {"repo": repo_uri, "reason": "not_found"}}


def check_deploy(deploy_state: str, deploy_uri: str) -> Dict[str, Any]:
    if deploy_state.lower() in ("active", "ready", "live"):
        return {"status": "REAL", "score": 1.0, "evidence": {"deploy": deploy_uri, "state": deploy_state}}
    if deploy_state.lower() in ("building", "queued"):
        return {"status": "PARTIAL", "score": 0.5, "evidence": {"deploy": deploy_uri, "state": deploy_state}}
    return {"status": "BLOCKED", "score": 0.0, "evidence": {"deploy": deploy_uri, "state": deploy_state}}


def check_evidence(evidence_rows: List[Dict[str, Any]]) -> Dict[str, Any]:
    if not evidence_rows:
        return {"status": "BLOCKED", "score": 0.0, "evidence": {"count": 0}}
    real = [e for e in evidence_rows if e.get("status") == "REAL"]
    return {
        "status": "REAL" if real else "PARTIAL",
        "score": min(1.0, len(real) / max(1, len(evidence_rows))),
        "evidence": {"count": len(evidence_rows), "real_count": len(real)},
    }


def roll_up(results: Dict[str, Dict[str, Any]]) -> Dict[str, Any]:
    if any(r["status"] == "BLOCKED" for r in results.values()):
        overall = "BLOCKED"
    elif all(r["status"] == "REAL" for r in results.values()):
        overall = "REAL"
    else:
        overall = "PARTIAL"
    score = round(sum(r["score"] for r in results.values()) / max(1, len(results)), 3)
    return {"status": overall, "validation_score": score}


def handler(event: Dict[str, Any], context=None) -> Dict[str, Any]:
    asset_id = event.get("asset_id")
    probes = event.get("probes", {})
    results = {}

    if "naming" in event.get("checks", []):
        results["naming"] = check_naming(probes.get("name", ""))
    if "hash" in event.get("checks", []):
        results["hash"] = check_hash(probes.get("content_bytes"), probes.get("declared_hash", ""))
    if "link" in event.get("checks", []):
        results["link"] = check_link(probes.get("url", ""), probes.get("http_status", 0))
    if "repo" in event.get("checks", []):
        results["repo"] = check_repo(probes.get("repo_present", False), probes.get("repo_uri", ""))
    if "deploy" in event.get("checks", []):
        results["deploy"] = check_deploy(probes.get("deploy_state", ""), probes.get("deploy_uri", ""))
    if "evidence" in event.get("checks", []):
        results["evidence"] = check_evidence(probes.get("evidence_rows", []))

    summary = roll_up(results) if results else {"status": "PARTIAL", "validation_score": 0.0}
    return {
        "asset_id": asset_id,
        "checks": results,
        **summary,
        "receipt_stem": f"RCPT_ram_validate_{asset_id}",
    }


if __name__ == "__main__":
    demo = {
        "asset_id": "demo-1",
        "checks": ["naming", "link", "evidence"],
        "probes": {
            "name": "80_ram_product-touchpoint-map.md",
            "url": "https://example.com",
            "http_status": 200,
            "evidence_rows": [{"status": "REAL"}, {"status": "PARTIAL"}],
        },
    }
    print(json.dumps(handler(demo), indent=2))
