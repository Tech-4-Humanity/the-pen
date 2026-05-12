"""
32_ram_portfolio_worker.py

RAM Curator runtime. Generates evidence-backed portfolio cards from
validated assets. Never invents claims. Only surfaces REAL-state cards.

Envelope: TOP-LEVEL
  {"asset_ids": ["uuid", ...], "brand": "string", "audience": "exec|cto|gov|partner|investor|standards|humanitarian"}
"""

import json
from typing import Dict, Any, List

AUDIENCE_TONE = {
    "exec": "Outcome-led, one-paragraph framing, no jargon.",
    "cto":  "Architecture, dependencies, runtime state, deployment proof.",
    "gov":  "Governance, evidence, controls, audit trail, public-interest framing.",
    "partner":   "Capability fit, integration points, joint value.",
    "investor":  "Market, traction, defensibility, monetisation, evidence-bound.",
    "standards": "Standards alignment, controls, conformance, evidence.",
    "humanitarian": "Human outcome, beneficiary, sustainability, evidence of impact.",
}


def build_card(asset: Dict[str, Any], brand: str, audience: str) -> Dict[str, Any]:
    evidence = asset.get("evidence", [])
    real_evidence = [e for e in evidence if e.get("status") == "REAL"]
    evidence_state = "REAL" if real_evidence else ("PARTIAL" if evidence else "BLOCKED")

    summary = (
        f"[{brand}] {asset.get('asset_type','asset')} — {asset.get('canonical_name','')}. "
        f"{AUDIENCE_TONE.get(audience,'')} "
        f"Evidence: {len(real_evidence)} REAL of {len(evidence)} total."
    )

    return {
        "asset_id": asset.get("id"),
        "brand": brand,
        "capability": asset.get("metadata", {}).get("capability", "unspecified"),
        "audience": audience,
        "summary": summary,
        "evidence_state": evidence_state,
        "commercial_value": asset.get("metadata", {}).get("commercial_value"),
        "metadata": {
            "source_uri": asset.get("source_uri"),
            "evidence_count": len(evidence),
            "real_evidence_count": len(real_evidence),
        },
    }


def handler(event: Dict[str, Any], context=None) -> Dict[str, Any]:
    assets: List[Dict[str, Any]] = event.get("assets", [])
    brand = event.get("brand", "T4H")
    audience = event.get("audience", "exec")

    cards = [build_card(a, brand, audience) for a in assets]
    real_cards = [c for c in cards if c["evidence_state"] == "REAL"]

    return {
        "status": "REAL" if real_cards else "PARTIAL",
        "brand": brand,
        "audience": audience,
        "card_count": len(cards),
        "real_card_count": len(real_cards),
        "cards": cards,
        "receipt_stem": f"RCPT_ram_portfolio_{brand.lower()}_{audience}",
    }


if __name__ == "__main__":
    demo = {
        "assets": [{
            "id": "demo-1",
            "canonical_name": "82_outcome-ready_claim-engine.md",
            "asset_type": "doc",
            "source_uri": "github://TML-4PM/outcome-ready",
            "metadata": {"capability": "NDIS claim evidence", "commercial_value": "provider_pack"},
            "evidence": [{"status": "REAL", "type": "commit_id", "value": "abc123"}],
        }],
        "brand": "Outcome Ready",
        "audience": "gov",
    }
    print(json.dumps(handler(demo), indent=2))
