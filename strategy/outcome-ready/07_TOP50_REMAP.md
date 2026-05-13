# 07 — Top 50 Agent / Product Remap

The thread's key insight: **almost all Thriving Biz and Thriving Kids capability already exists** in the T4H top 50 products / agents. This document maps existing capability to the new brand bundles.

This is illustrative — Troy to validate against the actual registry (`t4h_business_registry` + `mcp_lambda_registry`).

## Mapping Method

For each existing agent/product:
1. Identify the underlying agentic function
2. Map to one or both brands
3. Identify the SKU it lives inside

## Provisional Remap Table

| # | Existing capability (function) | Thriving Biz SKU | Thriving Kids SKU |
|---|--------------------------------|-------------------|--------------------|
| 1 | Intake / triage agent | Provider Risk Scan, AI Office | AI Sweet Spots, Family Risk Snapshot |
| 2 | Functional assessment scorer | — | AI Sweet Spots — Child Profile |
| 3 | Pathway routing engine | Reform Readiness Snapshot | Parent Action Plan |
| 4 | Planning / next-action generator | Compliance OS planner | Parent OS planner |
| 5 | Reading-specific intervention agent | — | Reading Buddy |
| 6 | Daily engagement / streak system | — | Reading Buddy, Parent OS |
| 7 | Signal capture / telemetry | Compliance OS, Evidence Engine | Functional Progress Tracker |
| 8 | Evidence pack generator | Audit Defence Pack, Evidence Engine | Plan Defence Pack, Escalation Pack |
| 9 | Justification / narrative builder | Claim Defence Layer | NDIS Re-Entry Pack |
| 10 | Risk scoring agent | Provider Risk Scan, Pre-Audit Sim | School student risk view |
| 11 | Anomaly detection | Pre-Audit Sim, Compliance OS | (n/a) |
| 12 | Reporting / report-pack generator | Outcome Reporting Pack | Functional Snapshot Report |
| 13 | Call / receptionist agent | AI Calls + Intake | (n/a) |
| 14 | Workflow / task agent | AI Office | Coordination Agent (school + family) |
| 15 | Finance / claims agent | Evidence Engine (claim linkage) | (n/a) |
| 16 | Document automation | AI Office, Compliance OS | (n/a) |
| 17 | Comms drafting agent | Sales + Campaign Agents | Parent comms templates |
| 18 | Sales / lead agent | Sales + Campaign Agents | (n/a) |
| 19 | Roster / staff coordination | Staff Coordination | (n/a) |
| 20 | Handover / shift notes | Staff Coordination | (n/a) |
| 21 | Policy / reform monitoring | Thriving Biz Alert | Thriving Kids "What's Changing?" |
| 22 | Alert / notification agent | Thriving Biz Alert | Parent alert (plan review triggers) |
| 23 | Dashboard / business health | Management Dashboard | School Outcomes Dashboard |
| 24 | Audit log / event ledger | Compliance OS | Evidence Engine (parent view) |
| 25 | Identity / profile store | ConsentX + Identity | ConsentX + Identity |
| 26 | Consent management | ConsentX | ConsentX |
| 27 | Longitudinal data store | LifeGraph | LifeGraph |
| 28 | Multi-modal data ingest | Evidence Engine | Functional Progress Tracker |
| 29 | OCR / document parsing | Compliance OS | Plan Defence Pack |
| 30 | Image / artifact storage | Evidence vault | Reading Buddy media |
| 31 | Recommendation engine | Compliance OS recommendations | Parent OS recommendations |
| 32 | Escalation logic | Audit Defence | NDIS Re-Entry / Escalation Pack |
| 33 | Templates library | Compliance OS templates | Parent / school templates |
| 34 | Versioning / change tracking | Compliance OS policy versioning | Functional Tracker history |
| 35 | Multi-tenant per-org isolation | Provider org tenancy | School org tenancy |
| 36 | Per-child / per-participant tenancy | (n/a) | Child profile under parent account |
| 37 | Subscription billing | Stripe | Stripe |
| 38 | Per-use / metered billing | Pre-Audit Sim, Claim Defence | Plan Defence on-demand |
| 39 | Referral / partner agent | Accountant channel | Practitioner referral |
| 40 | Knowledge base / FAQ agent | Reform FAQ | Thriving Kids FAQ |
| 41 | Search agent | Compliance OS search | Parent OS search |
| 42 | Reading / comprehension scorer | (n/a) | Reading Buddy |
| 43 | Attention / focus indicator | (n/a) | Functional Progress Tracker |
| 44 | Regulation / behaviour indicator | (n/a) | Functional Progress Tracker |
| 45 | School-facing summary generator | (n/a) | Student Support Pack |
| 46 | 2e detection pattern | (n/a) | 2e Toolkit + Sweet Spots scoring |
| 47 | Telegram / messaging bridge | Internal ops only | (n/a) |
| 48 | Calendar / scheduling agent | AI Office | Coordination Agent |
| 49 | Multi-language support | Future | Future |
| 50 | Agent orchestration / supervisor | Internal | Internal |

## Net New Capability Required

| New piece | Where | Effort |
|-----------|-------|--------|
| Brand-specific landing pages | Web | Low |
| Brand-specific consent + onboarding flows | ConsentX skins | Low |
| Subscription packaging in Stripe | Billing | Low |
| 2e detection ruleset inside Sweet Spots | Scoring engine config | Low–Med |
| Parent-friendly Reading Buddy UI polish | Existing Reading Buddy | Med |
| School org tenancy for cohort licences | Identity + billing | Med |
| Plan Defence / Escalation report templates | Evidence Engine templates | Low–Med |
| Reform Alert content pipeline | Content + comms agent | Low |

**Everything else is repackaging.**

## Reuse-First Build Rule

Before any new build under Thriving Biz or Thriving Kids:
1. Search the registry for existing capability
2. Confirm whether it can be **repackaged** rather than rebuilt
3. Only build new if the capability genuinely does not exist
4. Record reuse decisions in the canonical change log (`t4h_canonical_changes`)

## Cross-Brand Adjacency (Window 3 Onwards)

| Adjacent market | Example reuse |
|-----------------|---------------|
| Accountants under ATO reform pressure | "Thriving Biz for accountants" — Compliance OS + Reform Alert |
| Allied health (non-NDIS) | Practice OS + Reporting |
| Aged care providers | Same pattern: registration + compliance + evidence |
| Education systems beyond NDIS | School Pilot template applied broadly |
| Workforce optimisation | AHC-derived skin |

## Open Questions For Troy

- [ ] Which existing T4H businesses are nearest to "Outcome Ready" and should be folded under this brand?
- [ ] Is Reading Buddy currently a standalone business or a feature inside another?
- [ ] Confirm Stripe configuration supports per-child sub-accounts under parent identity
- [ ] Confirm ConsentX schema supports school-level + parent-level + practitioner-level consent
- [ ] Confirm LifeGraph can store both Biz (organisation) and Kids (child) timelines
