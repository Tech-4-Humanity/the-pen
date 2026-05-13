# Buddy Platform V2 — Strategic Distillation & Wave-C Delta

**Date:** 2026-05-13
**Status:** PARTIAL → strategic distillation receipted; runtime layer still pending
**Builds on:** [handoffs/2026-05-11-buddy-platform-v2-build-handoff.md](./2026-05-11-buddy-platform-v2-build-handoff.md) (commit `1f40055d`)
**Cluster:** CL_BRIDGE_PEN (interim) — new cluster `CL_EDU_BUDDY` proposed below
**Project code:** EDU-BUDDY-V2
**RDTI:** is_rd=true

---

## 1. What changed since the V2 build handoff

Three new inputs landed since 2026-05-11:

1. **Wave-C compliance substrate uploads** — EAL/D numeracy (020), First Nations substrate (021), Validation/Advisory/Ethics (022), State alignment pages (023), Outreach drafts staged (024). All represent operational governance, not features.
2. **Kids Visit Mode / Calmbound Guardian** — distributed agentic household governance runtime with tri-agent topology (Family Guardian + Security Sentinel + Home Orchestrator).
3. **Expanded backlog** — 65 issues across 9 sections (A–I) covering Reading Buddy, Maths Buddy, Maths Mate (new), Community Buddy (new), ESL/EAL-D, Elderly, Indigenous, Neurodiverse+NDIS, Platform/Infra.

The cumulative effect: Reading Buddy is no longer "an app that helps kids read." It is converging toward **a governed adaptive human-development runtime** spanning school, home, therapy, NDIS, family, neurodiversity, multilingual, aging, and community contexts.

---

## 2. Strategic re-positioning

| Old positioning | New positioning |
|---|---|
| "AI for education" | "Operational infrastructure for human development" |
| App / SaaS / EdTech | Cross-context intervention runtime |
| Supplementary to curriculum | Curriculum-native; operationalises existing literacy / numeracy / intervention / reporting / evidence obligations |
| Per-product features | Shared substrate underneath every Buddy |

**Procurement consequence:** the sales conversation flips from "would you like an AI literacy tool?" to "this system operationalises your existing literacy, numeracy, intervention, reporting, and evidence obligations." Significantly harder to displace once embedded.

---

## 3. Curriculum-native alignment surface

V2 must explicitly map to (Wave-C delivered or in flight):

- NESA (NSW), VCAA (VIC), QCAA (QLD), SCSA (WA), SA Numeracy Check
- PLAN2, MOI/FDOI, Growth Points, NNLP, NAPLAN pathways
- OneSchool, IB programs
- RTI / Tiered intervention models

This is the **defensibility layer**. It changes Reading Buddy / Maths Buddy from "content delivery" to **diagnostic evidence generation** — WCPM, miscue analysis, running records, report cards, longitudinal literacy telemetry.

---

## 4. The reusable tri-agent middleware

The Kids-Visit-Mode / Calmbound Guardian pattern is bigger than routers. Same topology maps across every product:

| Product | Guardian | Sentinel | Orchestrator |
|---|---|---|---|
| Reading Buddy | Literacy Guardian | Frustration Sentinel | Learning Orchestrator |
| Maths Buddy | Numeracy Guardian | Error Sentinel | CPA Orchestrator |
| Community Buddy | Community Guardian | Safety Sentinel | Event Orchestrator |
| Maths Mate | Engagement Guardian | Disengagement Sentinel | Motivation Orchestrator |
| Neurodiverse mode | Regulation Guardian | Overload Sentinel | Adaptation Orchestrator |
| ESL/EAL-D | Language Guardian | Confusion Sentinel | Scaffold Orchestrator |
| Elderly | Cognition Guardian | Decline Sentinel | Engagement Orchestrator |
| Indigenous | Cultural Guardian | Extraction Sentinel | Partnership Orchestrator |
| Outcome Ready | Evidence Guardian | Drift Sentinel | Reporting Orchestrator |
| Thriving Kids | Family Guardian | Risk Sentinel | Intervention Orchestrator |

**This is the architectural primitive.** Build the agent middleware once; wrap each Buddy in a configured trio. Avoids rebuilding orchestration eleven times.

---

## 5. The `portal.html` → executable governance pattern

The Calmbound Guardian's `portal.html` became the "ethical source of truth." Generalise:

> User-visible agreements, family rules, intervention boundaries, consent structures, operational policy, AI constraints — all become **executable runtime artifacts**, not static PDFs.

Implication for Buddy Platform: every consent form, accommodation flag, school policy, family setting, NDIS plan section becomes a runtime input that the agent middleware reads and enforces. Policy is executable. Consent is executable. Governance becomes operational.

---

## 6. Expanded ecosystem — 9-section backlog

| Section | Issues | What it really is |
|---|---|---|
| A — Reading Buddy core | 10 | Observational literacy engine |
| B — Maths Buddy | 10 | Mathematical cognition infrastructure |
| C — Maths Mate *(new)* | 4 | Motivation / retention loop infrastructure |
| D — Community Buddy *(new)* | 4 | Social cohesion / regional deployment layer |
| E — ESL / EAL-D | 4 | International scalability infrastructure |
| F — Elderly | 3 | Lifespan cognition / aged-care pathway |
| G — Indigenous | 4 | Culturally governed delivery substrate |
| H — Neurodiverse + NDIS | 10 | Adaptive cognition infrastructure |
| I — Platform / Infra | 16 | The actual moat (telemetry, identity, governance) |

**Total: 65 issues.** All required for the runtime to function as more than the sum of its parts.

### Strategic notes per section

- **C — Maths Mate** is bigger than it looks: peer duels, family challenges, rich tasks. Without this layer, retention collapses; with it, products become ecosystems. Maths Mate is the **motivation infrastructure** that Reading Buddy and Maths Buddy plug into.
- **D — Community Buddy** opens councils, libraries, NGOs, aged care, migrant services, regional deployment. One of the strongest expansion vectors.
- **E — ESL/EAL-D + Offline PWA** = globally scalable. AMEP alignment opens government funding pathways.
- **F — Elderly** changes the platform from child education to **lifespan cognition**. Massive procurement defensibility upgrade.
- **G — Indigenous** must stay partnership-first. Wave-C posture is correct: no extraction, no autonomous marketing, community consent first, partnership gating, bidialectal handling, remote/offline support. **Do not industrialise.**
- **H — Neurodiverse + NDIS** is the category-defining commercial area. Move beyond "NDIS documentation tools" to **adaptive developmental systems**: dyslexia, ADHD, autism, dyscalculia, giftedness, anxiety, provider portal. Supersedes the current `/ndis` page.
- **I — Platform/Infra** is the actual moat — without it everything fragments.

---

## 7. The missing layer: Intervention Runtime Ledger

Across all 11 products mapped above, the single most important missing layer is the **Intervention Runtime Ledger**.

Required event spine:

| Event | Stored evidence |
|---|---|
| signal_detected | source, signal_type, learner_id, raw_signal, confidence |
| intervention_proposed | intervention_id, signal_ref, intervention_type, rationale |
| intervention_accepted | accepted_by (learner / teacher / parent / agent), consent_ref |
| intervention_executed | execution_id, runtime_endpoint, execution_evidence |
| outcome_observed | outcome_metric, delta_vs_baseline, observed_at |
| confidence_score | calibration_method, score, evidence_chain_hash |
| follow_up_action | next_intervention_id OR closure_reason |

This becomes simultaneously:
- the **REAL engine** (no receipt → no REAL classification)
- the **telemetry engine** (longitudinal outcome tracking)
- the **compliance engine** (auditable intervention trail for NDIS / schools / parents)
- the **defensibility engine** (causal evidence chains for outcome claims)
- the **future AI training substrate** (intervention-outcome pairs are RLHF gold)

Without it, the platform is a collection of products. With it, the platform is **operational infrastructure**.

Recommended home: new schema `intervention` (or extend `runtime`), tables `intervention.events`, `intervention.outcomes`, `intervention.evidence_chain`. Bind every Buddy session, every NDIS plan event, every Outcome Ready report, every Thriving Kids signal.

---

## 8. Other missing layers before REAL classification

1. **Runtime telemetry continuity** — continuous runtime proofs, longitudinal intervention outcomes, recovery/reconciliation, signal drift detection, survivability metrics, autonomous operational continuity.
2. **Reading outcome causality engine** — intervention → outcome linkage, confidence scoring, causal evidence chains, signal correlation, longitudinal learning models. Infrastructure is good; proof engine is incomplete.
3. **Unified canonical operational graph** — family, school, student, household, intervention, consent, curriculum, diagnostics, device, agent are all in scope, but not yet on one graph. Required to prevent splintering as products multiply.

---

## 9. Canonical ontology (proposed v0)

One unified model required across all Buddies:

```
learner, family, school, provider, intervention, curriculum, signal,
consent, assessment, session, telemetry, evidence, adaptation, accessibility
```

Same nouns, same edges, every product. Without this the platform fragments under its own weight.

---

## 10. Registry & cluster requirements

### Existing registry entries (verified via `core.registry_entities`)

- `outcome_ready_master` (system) — Outcome Ready
- `biz.outrd` (system) — Outcome Ready (duplicate-ish)
- `product.reading-buddy` (system) — Reading Buddy
- `product.maths-buddy` (system) — Maths Buddy
- `thriving_kids` (system) — Thriving Kids
- `lambda.reading-buddy-api`, `lambda.reading-buddy-web`, `lambda.outcome-ready-web`
- `lambda.rb-map-reading-import`, `lambda.mb-pat-maths-import`, `lambda.mb-eald-vocab-lookup`
- `lambda.bridge-runner-reading`, `lambda.grants-outcome-recorder`

### Gaps in registry — need adding

| entity_key | type | name | reason |
|---|---|---|---|
| `product.maths-mate` | system | Maths Mate | section C — new product, not in registry |
| `product.community-buddy` | system | Community Buddy | section D — new product, not in registry |
| `product.buddy-platform` | system | Buddy Platform (umbrella) | shared substrate for all Buddies |
| `module.neurodiverse-mode` | module | Neurodiverse Mode | section H — supersedes `/ndis` page |
| `module.eald-substrate` | module | EAL/D Substrate | Wave-C 020 |
| `module.first-nations-substrate` | module | First Nations Substrate | Wave-C 021 |
| `module.intervention-ledger` | module | Intervention Runtime Ledger | missing layer §7 |
| `pattern.tri-agent` | pattern | Tri-Agent Middleware (Guardian / Sentinel / Orchestrator) | reusable middleware §4 |

### Gap in `core.cluster_registry`

No education / human-development cluster exists. Closest is `CL_BRIDGE_PEN` (where the prior handoff was parked). Proposed:

```
CL_EDU_BUDDY
  cluster_name: "Buddy Platform / Reading / Maths / Community / Neurodiverse / EAL-D / Elderly / Indigenous / Intervention runtime"
  priority: P1
  home_schema: runtime
  ledger_sink: public.reality_ledger
  closure_rule: REAL requires intervention-ledger event chain + outcome observation
  evidence_type: typed (signal, intervention, outcome, confidence_score)
```

This unblocks proper FK attachment for all future Buddy reality_ledger rows.

---

## 11. Status assessment

**STATUS:** ADVANCED PARTIAL — strong infrastructure phase, runtime layer still pending

| Dimension | Score | Comment |
|---|---|---|
| Vision | 9.7 | Re-positioning is locked in |
| Architecture | 9.2 | Tri-agent + portal.html patterns are correct primitives |
| Governance | 9.4 | Wave-C substrate is institution-grade |
| Educational defensibility | 9.3 | Curriculum-native, multi-jurisdiction |
| Commercial positioning | 9.1 | "Operational infrastructure for human development" is a much bigger category |
| Runtime maturity | 6.2 | No live telemetry, no intervention ledger |
| Operational proof | 5.8 | No deployed runtime evidence |
| Survivability | 5.5 | No reconciliation/recovery proof |

---

## 12. Next actions

1. **Build the Intervention Runtime Ledger first.** It is the highest-leverage missing layer; everything else gets easier once events flow through it.
2. **Add `CL_EDU_BUDDY` cluster** and reattach prior reality_ledger row `a064d683` from `CL_BRIDGE_PEN` to its proper home.
3. **Register the 8 missing entities** (Maths Mate, Community Buddy, Buddy Platform umbrella, Neurodiverse Mode, EAL/D, First Nations, Intervention Ledger, Tri-Agent pattern) in `core.registry_entities`.
4. **Build tri-agent middleware once.** Wrap each existing Buddy in a configured trio. Don't write orchestration eleven times.
5. **Promote `portal.html` pattern** to all consent/policy/accommodation surfaces across the platform.
6. **Run the 65-issue backlog scripts** (`create-reading-buddy-v2-labels.sh`, `create-reading-buddy-v2-expanded.sh`) once the labels and section structure are confirmed.
7. **Set up canonical ontology in `runtime` schema** before adding any new product so the graph stays consistent.

---

## 13. Close condition

This distillation closes at **handoff level** once committed and ledger-receipted. It becomes **REAL** only when:

- Intervention Runtime Ledger schema is live with at least one signal → outcome chain receipted
- `CL_EDU_BUDDY` cluster exists
- 8 missing entities are registered
- At least one Buddy product has tri-agent middleware in production with telemetry

Until then: status remains PARTIAL.

---

## Bridge payload

```json
{
  "task_id": "buddy-platform-v2-strategic-distillation-20260513",
  "parent_task": "buddy-platform-v2-build-20260511",
  "intent": "Distil Wave-C uploads, Kids Visit Mode tri-agent pattern, and expanded 65-issue backlog into actionable architectural delta on V2 build handoff. Name the missing Intervention Runtime Ledger as highest-leverage gap.",
  "source_artifacts": [
    "kids vist mode raw grok.pdf",
    "020_eald_numeracy.sql",
    "021_first_nations_substrate.sql",
    "022_validation_advisory_ethics.sql",
    "023_state_alignment_pages.md",
    "024_outreach_drafts_staged.sql",
    "025_README.md",
    "ndis thriving kids campaign dataset README",
    "marketing campaign board apr nov 2026"
  ],
  "target_repo": "TML-4PM/the-pen",
  "target_path": "handoffs/2026-05-13-buddy-platform-v2-strategic-distillation.md",
  "systems": ["Reading Buddy", "Maths Buddy", "Maths Mate", "Community Buddy", "Buddy Platform", "Outcome Ready", "Thriving Kids", "Tech4Humanity"],
  "execution_mode": "NO_HITL_UNLESS_CREDENTIALS_LEGAL_SAFETY_OR_DESTRUCTIVE_ACTION",
  "required_outputs": [
    "intervention runtime ledger schema",
    "CL_EDU_BUDDY cluster creation",
    "8 missing entity registrations",
    "tri-agent middleware module",
    "portal.html executable governance pattern",
    "canonical ontology in runtime schema",
    "65-issue backlog execution"
  ],
  "classification": "PARTIAL_UNTIL_LEDGER_AND_TRIAGENT_LIVE",
  "next_executor": "bridge_or_symbio_dev"
}
```
