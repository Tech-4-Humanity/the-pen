# Ecosystem Asset & Impact Gate — Pen Handoff

**Date:** 2026-05-07  
**Owner:** Tech 4 Humanity / Troy Latter  
**Repo:** TML-4PM/the-pen  
**Status:** PARTIAL — handed to Pen via GitHub receipt  
**HITL:** OUT unless legal, money, credentials, destructive action, or external authority is required

---

## 1. Executive intent

Create a top-level ecosystem operating layer that ensures every new idea, asset, product, business, opportunity, program, or surface is automatically classified, mapped, pressure-tested, scored, snapshotted, routed, and made visible to business and technical execution systems.

This is not only D2D. D2D is one downstream process that can use this layer.

The actual layer is:

> **Shared Asset & Impact Registry + Ecosystem Impact Gate**

It answers:

> When something new is created, what else does it touch across the ecosystem — positively, negatively, commercially, operationally, ethically, technically, and from a runway perspective?

---

## 2. Core concept

### Shared Asset & Impact Registry

A top-level registry that records:

- reusable assets
- business surfaces
- products
- programs
- channels
- opportunities
- partner/white-label paths
- positive and negative ecosystem touches
- external risks
- runway interactions
- evidence requirements
- commercial paths
- owner and next action

### Ecosystem Impact Gate

An automatic stage-gate that runs before material build, Pen admission, Dev admission, or launch.

It performs:

1. Entry Test
2. Impact Map
3. Insurance Pre-Test
4. Viability Freeze Snapshot
5. Kanban routing
6. Agentic continuation plan
7. Reality Ledger classification

---

## 3. Classification taxonomy

Every new item must be classified as one or more of:

| Type | Meaning |
|---|---|
| company | legal entity |
| ecosystem | portfolio-wide layer |
| business | commercial operating unit |
| brand | market-facing identity |
| product | sellable/offered capability |
| program | campaign/intervention/mission |
| surface | website/app/portal/storefront/Kanban/listing |
| asset | reusable object/template/content |
| primitive | shared capability used by multiple products |
| channel | distribution path |
| partner_offer | white-label or partner variant |
| opportunity | emerging business/customer/market opening |

Example classifications:

| Name | Correct classification |
|---|---|
| Tech 4 Humanity | company / ecosystem brand |
| Outcome Ready | business |
| AI4Tradies | business |
| WorkFamilyAI | business |
| Reading Buddy | product |
| Maths Buddy | product |
| Teacher Resource Exchange | marketplace surface |
| Shared Asset Registry | primitive |
| worksheet/poster/form | asset |
| Kindergarten Starter Pack | product / SKU |
| D2D | process/orchestration pattern |

---

## 4. Entry Test

Before something enters Pen or Dev, it must either pass the Entry Test or be automatically routed to `Entry Test Missing`.

Required fields:

| Field | Required |
|---|---|
| item_name | yes |
| item_type | yes |
| primary_business_home | yes |
| secondary_touches | yes |
| audience | yes |
| positive_touches | yes |
| negative_touches | yes |
| runway_interaction | yes |
| external_factors | yes |
| resource_requirement | yes |
| success_definition | yes |
| evidence_required | yes |
| initial_score | yes |
| decision_state | yes |
| kanban_lane | yes |
| next_action | yes |

Rule:

> Anything entering Pen or Dev must either pass the Entry Test or be automatically routed to `Entry Test Missing` with a business Kanban card, impact snapshot requirement, and agentic gap-closure tasks.

---

## 5. Insurance Pre-Test

The Insurance Pre-Test pressure-tests the item against:

1. external factors
2. known businesses and surfaces
3. current runway activity
4. internal conflict/cannibalisation
5. dependencies
6. risk controls
7. revenue protection
8. reuse upside
9. timing fit

### External factor categories

- policy / regulation
- funding windows
- seasonality
- competitor activity
- procurement reality
- public sentiment
- platform dependency
- legal / IP
- safety
- economic climate

### Known-business pressure test

Every item is tested against at least:

- Outcome Ready
- Reading Buddy
- Maths Buddy
- WorkFamilyAI
- AI4Tradies
- Enter Australia
- Augmented Humanity Coach
- HoloOrg
- ConsentX
- MyNeuralSignal
- HealthFlow
- Sport / Social Wellness
- White-label partners

### Runway interaction states

| State | Meaning |
|---|---|
| ACCELERATES | helps an active item move faster |
| DEPENDS_ON | cannot progress until another item exists |
| DUPLICATES | repeats something already in progress |
| COMPETES_WITH | confuses or cannibalises another surface |
| MERGES_INTO | should become part of another item |
| UNLOCKS | creates a missing capability for several items |
| DISTRACTS_FROM | pulls resources away from higher-priority work |
| REQUIRES_FREEZE | unresolved risks require freeze |
| SAFE_PARALLEL | can proceed without hurting runway |
| PARK_UNTIL | wait for trigger/date/dependency |

### Insurance scoring

| Dimension | Weight |
|---|---:|
| external_resilience | 15 |
| known_business_alignment | 15 |
| runway_acceleration | 15 |
| internal_conflict_avoidance | 10 |
| capability_readiness | 10 |
| risk_manageability | 10 |
| revenue_protection | 10 |
| reuse_upside | 10 |
| timing_fit | 5 |

Score bands:

| Score | Meaning |
|---:|---|
| 85-100 | INSURED — accelerate |
| 70-84 | INSURABLE — continue with controls |
| 55-69 | CONDITIONAL — schedule/watch |
| 40-54 | UNDER_INSURED — park until proof/control exists |
| 0-39 | EXPOSED — block/merge/kill |

---

## 6. Viability Freeze Snapshot

At the freeze gate, create an immutable snapshot.

Required snapshot fields:

```json
{
  "snapshot_id": "uuid",
  "item_id": "uuid",
  "item_name": "text",
  "item_type": "enum",
  "stage_gate": "entry|impact|insurance|viability|pen_admission|dev_admission|launch|reality_review",
  "run_at": "timestamp",
  "run_by_agents": ["portfolio_impact", "business_viability", "resource_capability", "risk_compliance", "reuse_asset", "market_timing", "evidence_reality", "parking_lot", "continuity"],
  "primary_business": "text",
  "candidate_surfaces": [],
  "positive_touches": [],
  "negative_touches": [],
  "required_capabilities": [],
  "resource_requirements": {},
  "dependencies": [],
  "risks": [],
  "revenue_paths": [],
  "success_definition": "text",
  "evidence_required": [],
  "evidence_available": [],
  "insurance_status": "INSURED|INSURABLE|CONDITIONAL|UNDER_INSURED|EXPOSED",
  "runway_interactions": [],
  "scores": {},
  "weighted_total": 0,
  "decision": "ACCELERATE|CONTINUE|SCHEDULE|PARK|MERGE|WATCH|BLOCKED|KILL",
  "parking_lot_status": "none|parked|watch|scheduled",
  "reactivation_trigger": "text",
  "next_actions": [],
  "kanban_lane": "text",
  "reality_state": "REAL|PARTIAL|BLOCKED",
  "snapshot_hash": "sha256"
}
```

---

## 7. Business Kanban

Business Kanban provides visibility, not low-level task management.

### Required lanes

| Lane | Meaning |
|---|---|
| Intake | new item captured |
| Entry Test | being classified and pressure-tested |
| Entry Test Missing | entered Pen/Dev without gate; backfill required |
| Ready for Pen | structured enough for Pen handoff |
| Ready for Dev | structured enough for technical epic/tasks |
| In Build | active execution |
| Evidence Needed | built/started, not proven |
| Market Ready | offer/surface/funnel exists |
| Revenue / Live | earning or operational |
| Parked | not now; has trigger/date |
| Watch | waiting for external signal |
| Merge | absorb into another business/product |
| Blocked | requires access, authority, money, legal, dependency |
| Retired / Killed | closed with reason |

### Business card fields

```json
{
  "card_id": "uuid",
  "title": "text",
  "type": "enum",
  "primary_home": "text",
  "related_businesses": [],
  "score": 0,
  "insurance_status": "text",
  "decision": "text",
  "lane": "text",
  "runway_stage": "PRE-INTAKE|INTAKE|SIGNAL-WIRED|OFFER-READY|MARKET-READY|PRETEND|PARTIAL|REAL",
  "owner": "text",
  "revenue_path": [],
  "risk_flags": [],
  "next_gate": "text",
  "next_review": "date",
  "linked_pen_item": "text",
  "linked_dev_epic": "text",
  "reality_state": "REAL|PARTIAL|BLOCKED"
}
```

---

## 8. Pen admission payload

Pen should receive structured payloads, not vague ideas.

Example payload:

```json
{
  "item_name": "NSW Teacher Resource Exchange",
  "item_type": "marketplace_surface",
  "primary_business_home": "Shared Asset & Impact Layer",
  "secondary_touches": ["Reading Buddy", "Maths Buddy", "Outcome Ready", "Enter Australia", "WorkFamilyAI"],
  "runway_interaction": ["ACCELERATES Reading Buddy", "ACCELERATES Outcome Ready", "DEPENDS_ON Asset Registry", "DEPENDS_ON Moderation"],
  "insurance_status": "INSURABLE",
  "decision_state": "CONTINUE",
  "kanban_lane": "Ready for Pen",
  "success_definition": "First storefront with 50 tagged assets, upload/download/payment/moderation path, and evidence snapshot",
  "next_action": "Create schema, seed asset catalogue, draft moderation checklist, create storefront spec"
}
```

---

## 9. Agent board

The gate is run by a board of agents:

| Agent | Responsibility |
|---|---|
| Portfolio Impact Agent | cross-business touch map |
| Business Viability Agent | revenue path, buyer, pricing, economic case |
| Resource Capability Agent | people, time, tools, content, data, partners required |
| Effort & Complexity Agent | build effort, operational drag, dependencies |
| Risk & Compliance Agent | legal, child safety, NDIS, health, privacy, copyright, brand risk |
| Reuse & Asset Agent | existing assets to reuse; new reusable assets created |
| Market Timing Agent | timing, policy windows, seasonality, triggers |
| Evidence & Reality Agent | proof available vs assumed; REAL/PARTIAL/BLOCKED |
| Parking Lot Agent | parking trigger, review date, reactivation score |
| Continuity Agent | ensures agentic work continues after snapshot |

---

## 10. Agentic continuation rules

Snapshot does not stop work unless state is KILL or BLOCKED.

| Decision | Agentic continuation |
|---|---|
| ACCELERATE | build assets, create offer, wire surface, prepare launch |
| CONTINUE | close gaps, collect proof, reduce risk, build MVP |
| SCHEDULE | prepare assets, watch trigger, queue launch window |
| PARK | gather evidence only, no heavy build |
| MERGE | move assets/ideas into parent business/product |
| WATCH | monitor market/policy/customer signals |
| BLOCKED | record blocker, wait for authority/access/legal/money |
| KILL | archive, retain rationale, prevent rework |

---

## 11. Parking lot rules

Parking lot must not become a graveyard.

Every parked item must include:

- parked_reason
- reactivation_trigger
- review_date
- minimum_score_to_reopen
- required_proof
- agentic_background_work
- owner
- next_scheduled_gate

---

## 12. Initial implementation target

Create these canonical database objects in the execution environment:

```sql
-- Names only here; implementation to be generated by Dev/Pen executor.
shared_asset_registry
shared_asset_lens_tags
shared_asset_surfaces
ecosystem_impact_items
ecosystem_impact_snapshots
insurance_pretests
business_kanban_cards
parking_lot_items
pen_admission_payloads
dev_admission_payloads
impact_gate_agent_runs
impact_gate_scores
```

---

## 13. First seed examples

Seed initial examples:

1. NSW Teacher Resource Exchange
2. Outcome Ready Provider Library
3. AI4Tradies Resource Hub
4. WorkFamilyAI Family Library
5. Shared Asset Registry
6. White-Label Resource Engine
7. Social Wellness Resource Pack
8. Migrant School Starter Pack
9. NDIS Provider Evidence Pack
10. Inclusive Sport Resource Pack

---

## 14. Required outputs from Dev/Pen

1. SQL schema
2. scoring functions
3. snapshot hash function
4. Kanban card generator
5. Pen admission payload generator
6. backfill routine for Entry Test Missing
7. parking lot scheduler
8. first seed rows
9. Reality Ledger event hook
10. README with operating procedure

---

## 15. Reality Ledger

| Field | Value |
|---|---|
| task_id | ecosystem_asset_impact_gate_20260507 |
| intent | Build and hand off Shared Asset & Impact Registry + Ecosystem Impact Gate to Pen |
| execution | GitHub handoff file created in TML-4PM/the-pen |
| output | handoffs/2026-05-07_ecosystem-asset-impact-gate-pen-handoff.md |
| status | PARTIAL |
| evidence | GitHub commit receipt required from create_file response + issue receipt |
| gaps | Direct Bridge/Pen execution unavailable in this chat; GitHub issue used as Pen receipt path |
| next_action | Dev/Pen executor to implement schema, Kanban model, gate runners, and seed data |
| elevation | Converts ideas/assets/opportunities into governed portfolio intelligence and execution intake |
| pressure_flags | Avoid bureaucracy; classify untested work instead of silently blocking it; preserve frozen snapshots while allowing agentic continuation |
| score | 0.88 PARTIAL |
