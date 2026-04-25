# DRA — Drug Resilience Atlas · Canonical Definition

**Source of truth:** Origin conversation Oct 2025, ratified as "Drug Resilience Atlas (A–E Framework)" para 2577 of `Drug Resilience Atlas V1B.docx` (S3: `troy-intelligence-dashboard/GDRIVE_WORK_BACKUP/`)

**Github:** `TML-4PM/drug-resilience-atlas`
**Notion:** Drug Resilience Atlas (System Root)
**Supabase:** `lzfgigiyqpuuxslsygjt` (S1, Ecosystem Explorer)

---

## WHAT DRA IS (from source, verbatim where possible)

> *"A living, automated system mapping how biology, culture, law, and economics shape the body's response to substances."*
> — V1B para 2399

> *"Combines global data, neuroscience, and policy analytics to reveal tolerance curves, economic strain, and social ripple effects. Built for governments, researchers, and citizens who want evidence — not moral panic."*
> — V1B para 2429

DRA is **not** a clinical case-series study. DRA is **not** a framework inside a paper. DRA is a **whole system** — a living multi-domain index of how substances interact with people across biology, culture, economy, and policy, with a built-in education loop.

The "Atlas" part is literal — it maps something.
The "Resilience" part reframes drug research away from "addiction risk" and toward "resilience systems" (V1B para 2500: *"Conceptually novel (redefining drug studies from 'addiction risk' to 'resilience systems')"*).

## THE A–E FRAMEWORK (canonical)

Confirmed para 2575, locked para 2577:

| Axis | Domain | Function | Output |
|---|---|---|---|
| **A** | Anatomy / Neurochemistry | Model human baselines | half-life, ceiling, floor data |
| **B** | Biology & Behaviour | Track real use and recovery | tolerance and resilience patterns |
| **C** | Culture & Community | Map social modifiers | ritual rhythm, trust, trauma |
| **D** | Data & Policy Dynamics | Quantify systemic levers | economics, legality, policing |
| **E** | Education & Empowerment | Return insights to humans | courses, dashboards, simulations |

Loop: data → model → insight → education → new data.

## THE 14-SECTION DATA SCHEMA (canonical)

From V1B para 1449 — "the master structure that unites everything":

1. Identity and Scope (country, region, community group, substance, route, year, data_source)
2. Prevalence and Use Pattern
3. Biological Variables (half-life, tolerance, enzyme profiles, body temp, hydration, sleep)
4. Environmental and Contextual Variables (latitude, temp, urban density, UV)
5. Social and Cultural Factors (trust, ritual rhythm, loneliness, collective trauma, Indigenous share)
6. Economic Layer (GDP, Gini, price, income ratio, tax, unemployment)
7. Legal and Policy Layer (legal status, enforcement intensity, JSI, rule of law)
8. Infrastructure and Harm Reduction
9. Derived Indices (Resilience, Vulnerability, Judicial Severity, Economic Access, Ceiling Breach, Safe Spacing)
10. Measurement Outputs
11. Insights & Visual Layers
12. Shareability (Supabase table, REST/GraphQL API, CSV/JSON/PNG exports)
13. README sections
14. Ripple effects + stakeholders (added at para 1871)

## COHORTS BUILT INTO DRA FROM THE START

From V1B paras 114–172, explicitly scoped:

- **Neurotypical / general population** (baseline)
- **ADHD** (low baseline dopamine tone, stimulant tolerance faster)
- **Autism** (GABA-glutamate skew, sensory filtering)
- **Indigenous populations** (collective trauma, cultural rhythm)
- **Elderly** (receptor density decline, polypharmacy)

Substances: alcohol, nicotine/vapes, cannabis (THC), MDMA, methamphetamine, cocaine, heroin/opiates.

## MONETISABLE LAYERS (V1B para 2547)

All branded `DRA-*`:

- **DRA-Learn** — micro-courses for schools, clinicians, policymakers
- **DRA-Pro** — paid analytics + API for governments, insurers, universities
- **DRA-Health** — personal self-assessment tool, subscription
- **DRA-Insight Reports** — annual paid reports
- **DRA-Partner Services** — consulting layer
- **DRA-Certify** — credentialling system

## WHAT DRA IS NOT

1. **DRA is not a framework section inside the AI Sweet Spots paper.** That's a different thing. Paper §5.1 "Drug Response × AI" is a governance overlay for AI-at-work × substances. DRA is the underlying data system that would feed it.

2. **DRA is not a clinical case-series of n=44.** The `public.ass_study_cards` row claiming `DRA, case-series, n=44` is **wrong**. That's a mis-categorisation. The actual n=44 might be a sub-sample of pilot data, but DRA itself is a living atlas, not a fixed-n case series.

3. **DRA is not an A3 subarea under "Extreme AI Effects".** The `t4h_research_subarea A3-S4` placement is a mis-filing. DRA is its own programme, not a branch of ASS-2.

4. **DRA is not the same as CARE or "Resilience Atlas Integration".** The `research_topics T07-S03` row linking DRA to CARE is a cross-reference, not identity.

## DATA ERRORS IN SUPABASE (to correct)

| Table | Error | Should be |
|---|---|---|
| `public.ass_study_cards` (study_id=DRA) | "case-series, target_n=500, current_n=44" | DRA is not a case-series. It's a system. Misfiled. |
| `public.t4h_research_area` (DRUG_INTERACT) | "Drug **Resistance** Atlas" | Drug **Resilience** Atlas |
| `public.research_items` (EXT-003) | "Drug Resistance Atlas (N=11241)" | DRA is not N=11,241. That's ASS-2. Wrong record entirely. |
| `public.research_sublayers` (T3) | "Drug-Reaction-AI (DRA) protocol" | Wrong expansion. DRA = Drug Resilience Atlas. |
| Paper §5.1 (in .docx only, not Supabase) | "Drug Response × AI (DRA)" | Framework inside the paper should use its own acronym — DR×AI is fine, but **not DRA**. That collision caused all this. |

## COMMERCIAL CLASS

From `public.t4h_research_commercial_class`:
> "Neural Market Intelligence / Resilience Atlas (as dashboards)" — research_to_commercial, status=operational

Confirms DRA is intended as a productised dashboard offering, not a study.

## STATUS RIGHT NOW

| Artefact | Where | Status |
|---|---|---|
| Origin conversation | S3 `troy-intelligence-dashboard/GDRIVE_WORK_BACKUP/DRA initial.docx` | ✅ Complete, 350k chars |
| V1 spec | Same bucket, V1.docx | ✅ 155k chars |
| V1B spec | Same bucket, V1B.docx | ✅ 363k chars — the canonical version |
| GitHub repo | `TML-4PM/drug-resilience-atlas` | ✅ Exists (para 2930) |
| Notion root | "Drug Resilience Atlas (System Root)" | ✅ Exists (para 3173) |
| Supabase tables | `ass_study_cards`, `t4h_study_registry`, `t4h_research_area/subarea`, `t4h_research_asset` (8 seed rows) | ⚠️ Present but **misfiled as a study, not a system** |
| IP bucket folder | `t4h-ip-static/resilienceatlas/.folder` | ⚠️ Empty scaffold |
| 8 auto-seed artefact slots | `t4h_research_asset A3-S4-AST-*` | ❌ All `MISSING` / `PRETEND` — never populated |

## THE NAMING PROBLEM IN ONE SENTENCE

The Supabase records treat DRA as a small clinical case-series (n=44) under a larger "Extreme AI Effects" container. The source documents treat DRA as a standalone multi-domain atlas programme equal in status to AI Sweet Spots. **The source is right. The Supabase records are wrong.**

## WHAT NEEDS TO HAPPEN

Not my call to execute. These are the decisions you now have the information to make:

1. **Elevate DRA from sub-study to programme.** Move it out of `A3-S4` (Extreme AI Effects subarea) and into its own top-level research area. Update `t4h_research_area` to add a DRA row, update `t4h_study_registry` to reflect it's a system not a case-series.

2. **Kill the "n=44 case-series" misclassification.** Either the n=44 refers to something real that belongs to a different study code, or it's a placeholder that should be deleted. Either way, DRA itself doesn't have a sample-size number — it has a dataset.

3. **Fix the spelling inconsistencies.** "Drug Resistance" appears twice (`t4h_research_area DRUG_INTERACT`, `research_items EXT-003`) — both should be "Drug Resilience". "Drug-Reaction-AI" in `research_sublayers T3` should be "Drug Resilience Atlas".

4. **Rename the paper §5.1 framework.** The paper §5.1 "Drug Response × AI (DRA)" is what created the collision with the real DRA. It should be renamed to **DR×AI** (Drug Response × AI) — which you already flagged last turn — leaving DRA free to mean only the Atlas.

5. **Populate the 8 empty artefact slots** in `t4h_research_asset` — or delete them if auto-seeded prematurely. They've been `PRETEND` status since Feb 2026.

6. **Add the A–E framework as canonical to the study_registry `secondary_sources`** — right now the registry row for DRA has `secondary_sources = []` (empty). Should reference the V1B doc in S3.

---

## Clarified taxonomy for this project going forward

| Level | Name | What it is |
|---|---|---|
| Programme | **AI Sweet Spots** | Workplace ND × AI optimisation |
| Programme | **Drug Resilience Atlas (DRA)** | Substance × biology × culture × law × education multi-domain atlas |
| Study (under AI Sweet Spots) | ASS-1, ASS-2, EXT-MEDICATION-AI, Hormonal Cycles, CARE | Empirical cohorts |
| Framework (inside AI Sweet Spots paper) | **DR×AI** (Drug Response × AI) | Governance overlay, Green/Amber/Red zones — NOT the same as DRA |
| Framework (inside AI Sweet Spots paper) | AS×AI (Altered States × AI) | 71-state matrix |

DRA and AI Sweet Spots are **peer programmes**, not parent-child. They share some cohort overlap (substance × neurotype) but have different data models, different schemas, different commercial paths.
