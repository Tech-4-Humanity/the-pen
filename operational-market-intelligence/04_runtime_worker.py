"""
Operational Market Intelligence Runtime Worker

Purpose:
Convert world events into operational economic movement continuously.

This worker is intentionally dependency-light. Bridge should wire it to:
- Supabase
- feed sources
- LLM classifier/extractor
- Command Centre approval surface
- telemetry sink
"""

from __future__ import annotations

from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
import hashlib
import json


VALID_STATES = [
    "RAW_SIGNAL",
    "PARSED",
    "CLASSIFIED",
    "GAP_EXTRACTED",
    "PRODUCT_MAPPED",
    "CONTENT_GENERATED",
    "CAMPAIGN_DEPLOYED",
    "LEADS_CAPTURED",
    "REVENUE_ATTRIBUTED",
    "RUNTIME_OPTIMISED",
    "REJECTED",
    "BLOCKED",
]


@dataclass
class Signal:
    source_type: str
    source_name: str
    source_url: str
    headline: str
    raw_content: str
    industry: str
    region: str = "Australia"
    trust_score: float = 0.8

    @property
    def external_signal_key(self) -> str:
        seed = f"{self.source_name}|{self.source_url}|{self.headline}"
        return hashlib.sha256(seed.encode("utf-8")).hexdigest()[:32]


@dataclass
class PressureScore:
    pressure_type: str
    pressure_score: float
    rationale: str


@dataclass
class Gap:
    stakeholder_type: str
    gap_summary: str
    severity: str
    opportunity_score: float


@dataclass
class ProductMapping:
    business_name: str
    product_name: str
    feature_name: str
    wrapper_name: str
    commercialisation_stage: str
    reuse_assets: Dict[str, Any]


@dataclass
class CampaignAsset:
    campaign_type: str
    audience: str
    campaign_name: str
    cta: str
    deployment_surface: str
    asset_payload: Dict[str, Any]


@dataclass
class BusinessCandidate:
    business_name: str
    business_type: str
    target_buyer: str
    pain_solved: str
    first_offer: str
    landing_surface: str
    revenue_path: str
    risk_summary: str
    launch_score: float
    human_gate_status: str = "pending_yes_no"
    runtime_mode: str = "one_human_loop"


class MarketIntelligenceRuntime:
    def parse_signal(self, signal: Signal) -> Dict[str, Any]:
        text = f"{signal.headline}\n{signal.raw_content}".lower()
        entities: List[Dict[str, Any]] = []
        keyword_map = {
            "ndis": "industry",
            "fraud": "problem",
            "billing": "problem",
            "provider": "actor",
            "participant": "actor",
            "plan": "asset",
            "regulator": "regulator",
            "audit": "compliance",
        }
        for keyword, entity_type in keyword_map.items():
            if keyword in text:
                entities.append({
                    "entity_type": entity_type,
                    "entity_value": keyword,
                    "confidence_score": 0.82,
                })
        return {"signal": asdict(signal), "entities": entities, "state": "PARSED"}

    def score_pressure(self, signal: Signal) -> List[PressureScore]:
        text = f"{signal.headline}\n{signal.raw_content}".lower()
        scores = []
        scoring_rules = [
            ("trust", ["fraud", "rort", "identity", "drain"], "Trust collapse or abuse pattern detected."),
            ("regulatory", ["ndis", "regulator", "audit", "commission"], "Regulated market or enforcement context detected."),
            ("economic", ["billion", "billing", "plan", "overcharge"], "Money leakage or payment pressure detected."),
            ("emotional", ["fear", "vulnerable", "participant", "family"], "Human anxiety or vulnerability pattern detected."),
            ("automation", ["manual", "paper", "claim", "evidence"], "Automation opportunity detected."),
        ]
        for pressure_type, words, rationale in scoring_rules:
            hits = sum(1 for word in words if word in text)
            if hits:
                scores.append(PressureScore(pressure_type, min(1.0, 0.45 + hits * 0.17), rationale))
        return scores

    def extract_gaps(self, signal: Signal) -> List[Gap]:
        if "ndis" in signal.industry.lower() or "ndis" in signal.raw_content.lower():
            return [
                Gap("participant_family", "Families cannot easily see whether plans are being drained or misused.", "critical", 0.92),
                Gap("provider", "Good providers lack lightweight evidence packs to prove legitimate delivery.", "high", 0.88),
                Gap("support_coordinator", "Coordinators face complaint and workflow exposure without simple anomaly views.", "high", 0.83),
                Gap("government", "Fraud detection remains too reactive and fragmented.", "critical", 0.9),
            ]
        return [Gap("buyer", "Market pressure exists but stakeholder gap requires deeper classification.", "medium", 0.55)]

    def map_products(self, signal: Signal, gaps: List[Gap]) -> List[ProductMapping]:
        mappings = []
        for gap in gaps:
            if gap.stakeholder_type == "participant_family":
                mappings.append(ProductMapping("Outcome Ready", "Plan Watch", "plan-burn anomaly alerts", "Family Dashboard", "candidate", {"reuse": ["Outcome Ready", "LifeGraph+", "ConsentX"]}))
            elif gap.stakeholder_type == "provider":
                mappings.append(ProductMapping("Outcome Ready", "Integrity Shield", "claim evidence vault", "Provider Trust Pack", "candidate", {"reuse": ["Outcome Ready", "Audit Pack", "Evidence Vault"]}))
            elif gap.stakeholder_type == "government":
                mappings.append(ProductMapping("Outcome Ready", "Provider Trust Ledger", "risk pattern telemetry", "Government Integrity Brief", "candidate", {"reuse": ["Reality Ledger", "Command Centre"]}))
        return mappings

    def generate_campaigns(self, mappings: List[ProductMapping]) -> List[CampaignAsset]:
        campaigns = []
        for mapping in mappings:
            if mapping.wrapper_name == "Family Dashboard":
                campaigns.append(CampaignAsset("landing_page", "parents_and_carers", "See Where Every NDIS Dollar Goes", "Run a free plan-risk scan", "Outcome Ready", {"hero": "Protect the plan before damage is done."}))
            elif mapping.wrapper_name == "Provider Trust Pack":
                campaigns.append(CampaignAsset("assessment", "providers", "Prove Care Before Audits Tighten", "Start provider integrity assessment", "Outcome Ready", {"hero": "Good providers need evidence, not panic."}))
            elif mapping.wrapper_name == "Government Integrity Brief":
                campaigns.append(CampaignAsset("briefing", "government", "From Reactive Fraud Detection to Live Integrity Telemetry", "Request integrity briefing", "Tech 4 Humanity", {"hero": "Fraud prevention needs runtime visibility."}))
        return campaigns

    def generate_daily_business_candidate(self, signal: Signal, mappings: List[ProductMapping]) -> BusinessCandidate:
        return BusinessCandidate(
            business_name="NDIS Integrity Shield",
            business_type="new_or_existing_surface",
            target_buyer="NDIS providers, support coordinators, parents, carers, and government integrity teams",
            pain_solved="Fraud exposure, plan draining, weak evidence, and fragmented trust telemetry.",
            first_offer="Free NDIS Fraud & Evidence Readiness Scan",
            landing_surface="outcome-ready / ndis-integrity-shield",
            revenue_path="Assessment -> audit pack -> monthly monitoring -> enterprise integrity dashboard",
            risk_summary="Avoid legal/medical/financial advice; position as evidence, workflow, telemetry, and integrity support.",
            launch_score=0.89,
        )

    def run_one(self, signal: Signal) -> Dict[str, Any]:
        parsed = self.parse_signal(signal)
        pressures = self.score_pressure(signal)
        gaps = self.extract_gaps(signal)
        mappings = self.map_products(signal, gaps)
        campaigns = self.generate_campaigns(mappings)
        candidate = self.generate_daily_business_candidate(signal, mappings)
        now = datetime.now(timezone.utc).isoformat()
        return {
            "runtime": "operational_market_intelligence",
            "executed_at": now,
            "external_signal_key": signal.external_signal_key,
            "state_path": ["RAW_SIGNAL", "PARSED", "CLASSIFIED", "GAP_EXTRACTED", "PRODUCT_MAPPED", "CONTENT_GENERATED", "BUSINESS_CANDIDATE_CREATED"],
            "parsed": parsed,
            "pressures": [asdict(p) for p in pressures],
            "gaps": [asdict(g) for g in gaps],
            "product_mappings": [asdict(m) for m in mappings],
            "campaigns": [asdict(c) for c in campaigns],
            "daily_business_candidate": asdict(candidate),
            "reality_ledger": {
                "status": "PARTIAL",
                "result": "Signal converted to candidate business, products, wrappers, campaigns, and telemetry plan. Runtime deployment still requires Bridge/Supabase proof.",
                "evidence": ["local_worker_output", "github_commit", "bridge_issue"],
                "gaps": ["supabase_execution", "continuous_sweeps", "telemetry_sink", "campaign_deploy", "revenue_attribution"],
                "next_action": ["deploy_schema", "insert_signal", "run_state_transitions", "publish_candidate_surface", "capture_telemetry"],
                "elevation": "autonomous economic cognition infrastructure",
                "pressure_flags": ["trust", "regulatory", "economic", "emotional"],
                "score": 0.9,
            },
        }


if __name__ == "__main__":
    signal = Signal(
        source_type="news",
        source_name="ABC News",
        source_url="https://www.abc.net.au/news/2026-05-05/ndis-fraud-tactics-popping-up-around-australia/106622490",
        headline="NDIS fraud tactics popping up around Australia",
        raw_content="NDIS fraud tactics include false billing, plan draining, overcharging, identity misuse, and provider trust failures.",
        industry="NDIS",
    )
    result = MarketIntelligenceRuntime().run_one(signal)
    print(json.dumps(result, indent=2))
