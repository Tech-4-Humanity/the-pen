# Cleanup Day Master Plan — 2026-05-10

> **Enhanced 2026-05-11**: hyperlinks added throughout — commit refs, repo paths, canonical business surfaces, registry rows. Original content preserved verbatim. Predecessor sha [`8db48981`](https://github.com/TML-4PM/the-pen/commit/8db4898191c008e42693a0a81cc0af5afbabf5cc).

**status**: PARTIAL
**result**: Execution plan created and lodged to [the Pen](https://github.com/TML-4PM/the-pen). Ready for rerun/build execution; remains PARTIAL until runtime sweep executes and returns receipts.

**evidence**:
- type: api_response · source: GitHub connector · repo: [TML-4PM/the-pen](https://github.com/TML-4PM/the-pen) · path: [`cleanup-day/2026-05-10/00_cleanup-day-master-plan.md`](https://github.com/TML-4PM/the-pen/blob/main/cleanup-day/2026-05-10/00_cleanup-day-master-plan.md)
- type: source_catalogue · source: uploaded GDrive Artifact Catalogue 2026-03-01
- observed_counts: 6,314 indexed files (2,988 js · 603 ts · 540 html · 531 md · 499 json · 399 png · 311 tsx · 228 txt · 50 bridge keyword · 21 pen keyword · 11 dra keyword · 2 atlas keyword)

**gaps**:
- Runtime sweep has not executed against [Drive](https://drive.google.com), [GitHub](https://github.com/TML-4PM), [Vercel](https://vercel.com/troys-projects-t4h-machine), [Supabase](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt), [Stripe](https://dashboard.stripe.com), and Bridge.
- Bridge-specific receipt endpoint not exposed in connector view.
- Supabase and AWS execution proof still require bridge/local executor or credentials.
- Existing assets need semantic clustering beyond filename matching.

**next_action**: Run the [cleanup rerun harness](https://github.com/TML-4PM/the-pen/blob/main/cleanup-day/2026-05-10/01_cleanup-rerun-harness.py), emit REAL/PARTIAL/BLOCKED rows, write receipts back to the Pen.

**elevation**: Moves the day from ad-hoc cleanup into a repeatable portfolio recovery operating system.

**ledger**:
- task_id: `CLEANUP-DAY-2026-05-10-PLAN`
- intent: Consolidate the session into a cleanup, recovery, indexing, signal, and rerun plan.
- execution: Created Pen plan asset via GitHub connector.
- output: [`cleanup-day/2026-05-10/00_cleanup-day-master-plan.md`](https://github.com/TML-4PM/the-pen/blob/main/cleanup-day/2026-05-10/00_cleanup-day-master-plan.md)
- status: PARTIAL · score: 0.72

---

## 1. Operating Frame

Today is a cleanup, recovery, signal, indexing, and truth-alignment day.

The working model is:

```
collect → index → cluster → classify → repair → lodge → receipt → rerun → monetise → replicate
```

Everything discovered lands in one of these states (per [reality_ledger](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor) public table):

| State | Meaning | Action |
|---|---|---|
| **REAL** | Executed, evidenced, logged, replayable | Preserve, monitor, monetise |
| **PARTIAL** | Exists but missing proof, linkage, runtime, or receipt | Rerun or repair |
| **BLOCKED** | Requires credentials, authority, unavailable dependency | Escalate with bounded reason |
| **KILL** | Duplicate, stale, no value, superseded | Archive/mark not planned |

---

## 2. Core Cleanup Domains

### 2.1 Business Registry Cleanup

Canonical registry of business, brand, product, offer, domain, deployment, repo, data source, [Stripe](https://dashboard.stripe.com)/payment link, current status, owner group, lifecycle state.

Priority groups:
- **G1 CORE**: [Tech 4 Humanity](https://tech4humanity.org), [WorkFamilyAI](https://workfamilyai.com), [Augmented Humanity Coach](https://ahc.holo-org.com), [HoloOrg](https://holoorg.vercel.app)
- **G2 SIGNAL**: GC-BAT, [ConsentX](https://consentx.org), FAR-CAGE, [MyNeuralSignal](https://myneuralsignal.com), NEUROPAK, RATPAK, LifeGraph+, AI Olympics
- **G3 MISSION**: Mission Critical, [Outcome Ready](https://outcome-ready.com), SmartPark, MedLedger, AquaMe
- **G4 RETAIL / ENTRY**: Enter Australia, APAC Just Walk Out, Vuon Troi, JustPoint, XCES, House of Biscuits
- **G5 FUN / SIGNAL SURFACE**: Apex Predator Insurance, Extreme Spotto, AI Oopsies, Rhythm Method, GirlMath, New Business 1, New Business 2

Registry live in [`public.t4h_business_registry`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor).

---

### 2.2 Domain and Hosting Cleanup

Inventory registered domains, [Vercel projects](https://vercel.com/troys-projects-t4h-machine), Lovable deployments, internal staging URLs, external public URLs, dead preview URLs, duplicate frontends, unbound domains, SSL/DNS issues, deployment protection state.

Live source: [`public.infra_sites_registry`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor).

---

### 2.3 Pen / Bridge / Dispatch Cleanup

Reconcile every instruction that said: *send to bridge*, *send to pen*, *wrap and send*, *get receipt*, *close*, *no HITL needed*, *complete*, *rerun*, *receipt*.

Bridge endpoint: `https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke` (dual-auth: `x-api-key` + `Authorization: Bearer`).
Pen canonical: [TML-4PM/the-pen](https://github.com/TML-4PM/the-pen).

This is the highest-risk truth gap: **requested execution does not equal executed work.**

---

### 2.4 Asset Recovery Cleanup

Catalogue: 6,314 artefacts. Process: parse names + content; cluster semantically; detect project lineage, duplicates, rebrands, runtime references; detect [Stripe](https://stripe.com)/[Supabase](https://supabase.com)/[Vercel](https://vercel.com)/[GitHub](https://github.com)/API references; detect receipts; detect orphans.

---

### 2.5 Product Duplication and Naming Drift Cleanup

Known drift candidates:
- DRA / Drug Resilience Atlas / Drug Atlas / Resilience Atlas → canonical: [TML-4PM/drug-resilience-atlas](https://github.com/TML-4PM/drug-resilience-atlas)
- Outcome Ready / ThrivingOS / Thriving Biz / Thriving Kids → canonical: [outcome-ready.com](https://outcome-ready.com)
- Reading Buddy / SchoolFamilyAI / Kids Buddy / Education Buddy → canonical: [reading-buddy by OutcomeReady](https://reading-buddy-8zy68b2nr-troys-projects-t4h-machine.vercel.app)
- WorkFamilyAI / FamilyAI / Team Family → canonical: [workfamilyai.com](https://workfamilyai.com)
- MEE / JET / myJET
- Chatter / Synal / Doolittles / Signal Surface
- Tech4Humanity / Tech 4 Humanity / Tech for Humanity → canonical: [tech4humanity.org](https://tech4humanity.org) (`.com.au` mirror, `.com` LAPSED)

---

### 2.6 Runtime Reality Cleanup

Every system classified by evidence, not confidence. Checks: URL resolves, API responds, auth works or blocks intentionally, form submission works, [Stripe](https://stripe.com) path works, data writes land, logs/telemetry exist, build current, receipt exists.

---

### 2.7 Supabase / Data Cleanup

Inventory projects, tables, edge functions, RLS posture, auth configuration, JWT posture, cron jobs, queues, old tables, duplicate schemas, orphan records.

S1: [lzfgigiyqpuuxslsygjt](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt) (canonical).
S2: `pflisxkcxbzboxwidywf` (no writes — read-only mirror).

---

### 2.8 Agent and Orchestration Cleanup

Reconcile 727+ agents, [Neural Ennead](https://neural-ennead-family.vercel.app) 9×9×9, [HoloOrg](https://holoorg.vercel.app) role-to-agent mapping, agent registry, [MCP Bridge](https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/health) actions, role definitions, prompt packs.

---

### 2.9 Research Cleanup

Canonicalise:
- AI Cognitive Diversity Research
- Drug Resilience Atlas → [repo](https://github.com/TML-4PM/drug-resilience-atlas)
- BCI governance / GC-BAT
- [ConsentX](https://consentx.org)
- [MyNeuralSignal](https://myneuralsignal.com)
- psychological friction survey
- [AI Sweet Spots](https://aisweetspots.com)
- Black Mirror / futures vignettes
- Augmented Memories
- committee influence engine

---

### 2.10 Financial / Monetisation Cleanup

Map every product to customer, offer, pricing, [Stripe product](https://dashboard.stripe.com/products), [Stripe price](https://dashboard.stripe.com/prices), payment link, lead capture, onboarding, continuation loop.

No major product should remain pure demoware.

---

### 2.11 UI / UX / Surface Cleanup

Consolidate Synal, Chatter, [Command Centre](https://mcp-command-centre.vercel.app), Signal overlays, Doolittles, dashboard widgets, portfolio views, TV/sport/live overlays, Place metadata layer.

---

### 2.12 Thread / Session Cleanup

Every thread is a potential source of action items, partial builds, missing receipts, business decisions, recovery candidates, bridges never fired, files never lodged.

---

## 3. Priority Queue

- **P0 — Truth and Execution**: Pen/Bridge receipt gap, runtime proof, dead deployments, missing evidence, broken auth/security, orphaned infra/cost risks
- **P1 — Recovery**: DRA, OutcomeReady, Reading Buddy, WorkFamilyAI, Chatter/Synal, Bridge dispatch assets, Thread Recovery Engine
- **P2 — Business Registry**: canonical 30-business registry, domains/URLs, internal vs external surfaces, product/brand hierarchy
- **P3 — Monetisation**: [Stripe](https://stripe.com) products/prices/payment links, lead capture, offer packaging, onboarding, continuation loops
- **P4 — Reuse / Replication**: common tables, shared components, prompt packs, execution templates, reusable recovery harness

---

## 4. Build Requirements

Harness must provide CSV parser, semantic keyword clustering, canonical business/brand matcher, URL/domain extractor, runtime reference extractor, Pen/Bridge signal extractor, REAL/PARTIAL/BLOCKED classifier, CSV/JSON/Markdown outputs, receipt ledger writer, rerun queue generator.

Outputs:
```
cleanup-day/output/asset_registry.csv
cleanup-day/output/project_clusters.csv
cleanup-day/output/recovery_queue.csv
cleanup-day/output/runtime_checks.csv
cleanup-day/output/monetisation_queue.csv
cleanup-day/output/reality_ledger.jsonl
cleanup-day/output/executive_summary.md
```

---

## 5. Acceptance Gates

Cleanup day is not complete until:

1. Every indexed artefact assigned to a cluster or orphan bucket.
2. Every cluster has a canonical parent business/product.
3. Every URL classified public/internal/dead/unknown.
4. Every Bridge/Pen request has a receipt state.
5. Every business has at least one status row in [`t4h_business_registry`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor).
6. Every major product has a monetisation state.
7. Every REAL claim has typed evidence (api_response, db_result, cli_output, commit_id, url, hash, reproducible_steps).
8. Every blocker has a bounded reason.
9. All outputs lodged to [the Pen](https://github.com/TML-4PM/the-pen).
10. A receipt is returned for the lodged work.

---

## 6. Immediate Rerun Order

1. Parse uploaded GDrive catalogue.
2. Generate canonical asset registry.
3. Cluster DRA / Atlas / OutcomeReady / Reading Buddy / WorkFamilyAI / Chatter / Bridge / Pen / Synal.
4. Generate recovery queue.
5. Generate runtime verification queue.
6. Generate monetisation queue.
7. Lodge results to [the Pen](https://github.com/TML-4PM/the-pen).
8. Create receipt ledger row in [`public.reality_ledger`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor).
9. Trigger Bridge/local execution for systems requiring credentials or runtime access.
10. Close with REAL/PARTIAL/BLOCKED summary.

---

**Related artifacts in this bundle:**
- [`01_cleanup-rerun-harness.py`](https://github.com/TML-4PM/the-pen/blob/main/cleanup-day/2026-05-10/01_cleanup-rerun-harness.py) — REAL/PARTIAL/BLOCKED classifier
- [`ISSUE_BODY.md`](https://github.com/TML-4PM/the-pen/blob/main/cleanup-day/2026-05-10/ISSUE_BODY.md) — bundle issue body (push commands + verification gates)

**Related canonical surfaces:**
- Operations dashboard: [mcp-command-centre.vercel.app](https://mcp-command-centre.vercel.app)
- Reality ledger: [`public.reality_ledger`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor)
- Business registry: [`public.t4h_business_registry`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor)
- Infra sites registry: [`public.infra_sites_registry`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor)
- Canonical changes (Telegram broadcast): [`public.t4h_canonical_changes`](https://supabase.com/dashboard/project/lzfgigiyqpuuxslsygjt/editor)
