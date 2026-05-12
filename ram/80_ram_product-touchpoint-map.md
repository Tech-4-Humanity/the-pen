# 80_ram_product-touchpoint-map.md

## Purpose
Define every Tech 4 Humanity system, business, brand, and surface that RAM touches. RAM is the asset intelligence layer for the whole spine, not a single-product utility. Each entry below is mapped to the RAM modules that operate on it, the evidence required, and the current dogfood status.

## Legend
- Modules: Clean (C), Validate (V), Lift (L), Portfolio (P), Reuse (R), Revenue (Rv), Watch (W), Lens (Ln), Registry (Rg), Dev-Inspect (DI), Prod-Promote (PP)
- Status: REAL / PARTIAL / BLOCKED
- All entries are PARTIAL until dogfood completion gates pass for each one.

---

## A. Foundation systems (the spine RAM attaches to)

### A1. The Pen — `TML-4PM/the-pen`
- Role: canonical artifact standard, package source of truth
- RAM modules: C, V, L, R, Rg, DI, W
- RAM operates on: pen packages, manifests, receipts, recovery files, naming compliance
- Evidence: commit ids, package stems, manifest hashes
- Status: PARTIAL (RAM scaffolding now lodged here)
- Completion: first 50 pen packages normalised and validated; all have manifests and receipts

### A2. Bridge Runner — `mcp-bridge-invoke-handler` + dual-auth Lambdas
- Role: execution layer for all autonomous actions
- RAM modules: C (package payloads), V (verify execution receipts), W (queue health), Rg
- RAM operates on: bridge payloads, queue jobs, receipts, failed handoffs
- Evidence: lambda invocation ids, audit.log rows, ops.work_queue rows
- Status: PARTIAL
- Completion: every bridge call in last 14 days has a paired RAM-tracked receipt

### A3. Reality Ledger — `public.reality_ledger` / `ops.reality_ledger`
- Role: canonical truth state for the entire ecosystem
- RAM modules: V, Rg, W, DI, PP
- RAM operates on: asset-level evidence rows, status transitions, drift events
- Evidence: ledger row ids, paired evidence objects
- Status: PARTIAL
- Completion: every RAM-managed asset has at least one ledger row with typed evidence

### A4. MCP Command Centre — `TML-4PM/mcp-command-centre`
- Role: dashboards, telemetry, widgets, operator visibility
- RAM modules: P (surface), W (drift widgets), Rg, R (reusable widgets)
- RAM operates on: t4h_ui_snippet rows, page registrations, widget bundles
- Evidence: vercel deployment ids, snippet slugs, render checks
- Status: PARTIAL
- Completion: 9 RAM widgets registered in t4h_ui_snippet and rendering REAL data

### A5. Supabase — S1 `lzfgigiyqpuuxslsygjt`
- Role: canonical registry, schema home for all RAM tables
- RAM modules: Rg (everything), V, W
- RAM operates on: table schemas, RLS policies, RPCs, registry rows
- Evidence: schema diffs via information_schema, run_sql RPC outputs
- Status: PARTIAL (S2 `pflisxkcxbzboxwidywf` is read-only mirror; no writes)
- Completion: ram_* tables created with RLS, smoke inserts present

### A6. FAR-CAGE — agent governance + accountability
- Role: agent action recording, AI accountability
- RAM modules: V (action evidence), W (drift), Rg
- RAM operates on: agent runs, role bindings, action logs
- Evidence: FAR-CAGE event ids, agent ids
- Status: PARTIAL
- Completion: every RAM agent action recorded in FAR-CAGE

### A7. STAMP governance kernel — `stamp.*` schema (alias `agoe`)
- Role: governance kernel (renamed from AGOE 2026-05-07)
- RAM modules: V, Rg, DI, PP
- RAM operates on: governance policies, approval chains, kernel constraints
- Evidence: stamp policy ids, approval rows
- Status: PARTIAL
- Completion: RAM promotions gated through STAMP approvals where required

### A8. Vercel — team `team_IKIr2Kcs38KGo8Zs60yNtm7Y`
- Role: frontend deployments, surface delivery
- RAM modules: V (deploy probe), W, Rg
- RAM operates on: project deployments, env vars, build receipts
- Evidence: vercel deployment ids, project ids
- Status: PARTIAL
- Completion: all RAM-tagged surfaces deploy clean with paired receipts

### A9. GitHub org `TML-4PM`
- Role: code home for 150+ repos
- RAM modules: C, V, R, Rg, W
- RAM operates on: repos, files, commits, releases, workflows
- Evidence: commit SHAs, file paths, sha sums
- Status: PARTIAL
- Completion: at least 10 internal repos ingested into ram_assets with REAL evidence

### A10. AWS — account `140548542136`, region `ap-southeast-2`
- Role: Lambda, S3, CloudWatch, IAM
- RAM modules: V, Rg, W
- RAM operates on: Lambda configs, log groups, S3 prefixes
- Evidence: Lambda ARNs, CloudWatch event ids
- Status: PARTIAL
- Completion: RAM Lambdas deployed with kill-switch and RDTI tag

### A11. MAAT financial system
- Role: 6,070+ real transactions, PDF/CSV pipeline, BASIQ banking, BAS/RDTI
- RAM modules: V (receipt validation), L (evidence pack uplift), P (compliance portfolio)
- RAM operates on: transaction evidence, BAS workpapers, RDTI evidence chain
- Evidence: maat_* table rows, transaction ids, BAS quarter rows
- Status: PARTIAL
- Completion: BAS FY25-26 Q1+Q2 and RDTI FY24-25 evidence packs RAM-normalised and validated

### A12. Telegram broadcast — chat_id `6972032328`
- Role: cross-LLM notification channel
- RAM modules: W (dev/prod hand-off notifications)
- Evidence: telegram message ids
- Status: PARTIAL

### A13. SES inbound forwarder + Route53
- Role: email ingress, DNS
- RAM modules: V (DNS probe), W
- Evidence: SES rule ids, route53 record states
- Status: PARTIAL

### A14. CIP — Critical Infra Process
- Role: HITL-gated per-deploy approval
- RAM modules: DI, PP (gates promotion of RAM Lambdas)
- Evidence: cip.approvals rows where status='approved'
- Status: PARTIAL

---

## B. Master brand: Synal (parent of Place products)

### B1. Synal — master brand
- Role: parent identity for Place products
- RAM modules: P, R, Rv
- RAM operates on: brand assets, capability cards, cross-product reuse
- Status: PARTIAL

### B2. Snaps (Place product) — context capture
- RAM modules: C, V, L, P, R
- RAM operates on: snap content, prompts, capture flows
- Status: PARTIAL

### B3. Spirals (Place product) — recurring reflection
- RAM modules: C, V, L, P
- Status: PARTIAL

### B4. Rhythm Method (Place product) — cadence
- RAM modules: C, V, L, P
- Status: PARTIAL

### B5. Snaps by Comet (single use case under Snaps)
- RAM modules: C, V, P
- Note: not a peer product to Snaps; one use case only
- Status: PARTIAL

---

## C. Cadence stack (sequential product chain)

Order: Snaps -> Auditor -> Research -> Lead -> Workflow

### C1. Auditor — diagnostic / audit
- RAM modules: V, L, P, R
- RAM operates on: audit templates, evidence packs, findings reports
- Status: PARTIAL

### C2. Research — research artefacts
- RAM modules: V, L, P, R, Rg
- RAM operates on: research notes, transcripts, findings
- Status: PARTIAL

### C3. Lead — opportunity surfacing
- RAM modules: P, Rv, V
- RAM operates on: prospect packs, offer maps
- Status: PARTIAL

### C4. Workflow — execution layer
- RAM modules: R, V, W, Rg
- RAM operates on: workflow templates, runtime evidence
- Status: PARTIAL

---

## D. AGL canonical types

Canonical types: APP, DATA, AGENT, MARKETPLACE, PROMO. Peak-wave view: `core.v_spine_agl_latest`.

### D1. APP type — applications
- RAM modules: V, R, P, Rg
- Status: PARTIAL

### D2. DATA type — data products
- RAM modules: V, Rg, W
- Status: PARTIAL

### D3. AGENT type — agentic products
- RAM modules: V, R, Rg, W
- Status: PARTIAL

### D4. MARKETPLACE type — marketplaces
- RAM modules: P, Rv, V
- Status: PARTIAL

### D5. PROMO type — promotional surfaces
- RAM modules: P, Rv, V
- Status: PARTIAL

---

## E. Workforce / family / community AI stack

### E1. WorkFamilyAI — workforce role mapping
- Role: 729/1000-agent role coverage system
- RAM modules: C, V, L, R, P, Rg
- RAM operates on: role cards, capability descriptions, workflow packs
- Evidence: role bindings, agent runs, FAR-CAGE rows
- Status: PARTIAL
- Completion: every active role has a validated capability card

### E2. SchoolFamilyAI — family/teacher/student bridge
- RAM modules: C, V, L, P, R
- RAM operates on: curriculum assets, family communications, teacher resources
- Status: PARTIAL

### E3. CommunityFamilyAI — community programmes
- RAM modules: C, V, L, P
- RAM operates on: stakeholder maps, programme packs, partner summaries
- Status: PARTIAL

---

## F. Signal / neural products

### F1. MyNeuralSignal — neural signal capture
- Role: signal capture and pattern surfacing
- RAM modules: C, V, L, R, Rg
- RAM operates on: signal taxonomies, capture flows, pattern packs
- Evidence: signal taxonomy versions, capture-flow commits
- Status: PARTIAL

### F2. Neural Ennead — 729-agent 9x9x9 trinomial system
- Role: agent topology
- RAM modules: R, V, Rg, W
- RAM operates on: agent definitions, trinomial mappings, role coverage
- Evidence: agent registry rows, coverage matrices
- Status: PARTIAL

### F3. HoloOrg — agent marketplace
- Role: org-as-agent-marketplace
- RAM modules: P, R, Rv, V, Rg
- RAM operates on: marketplace listings, capability packs, partner integrations
- Status: PARTIAL

---

## G. Mission / outcomes products

### G1. Outcome Ready — NDIS operational readiness
- Role: NDIS provider readiness, claim evidence, audit packs
- RAM modules: V, L, P, R, Rv
- RAM operates on: provider packs, practitioner packs, family packs, claim evidence, rejection/rework evidence
- Evidence: claim engine rows, audit pack hashes, deployment ids
- Status: PARTIAL
- Completion: at least one provider pack PKG_outcome-ready_* with REAL evidence

### G2. Drug Resilience Atlas — `TML-4PM/drug-resilience-atlas`
- Role: standalone programme (peer to AI Sweet Spots)
- RAM modules: V, L, P, R
- RAM operates on: public-entry layer, programme deliverables, evidence packs
- Note: not a sub-study; PRAX is deprecated and treated as fabrication
- Status: PARTIAL
- Completion: public-entry deployment validated; portfolio cards generated

### G3. AI Sweet Spots — research programme (11,241+ participants)
- Role: flagship research
- RAM modules: V, L, P, R, Rg
- RAM operates on: research artefacts, participant flow evidence, publications
- Status: PARTIAL

### G4. Reading Buddy — edtech intervention
- RAM modules: V, L, P, R, Rg
- RAM operates on: reading resources, intervention evidence, family/teacher reports
- Status: PARTIAL

### G5. Valdocco Primary — edtech
- RAM modules: V, L, P, R
- RAM operates on: curriculum assets, teacher resources, family communications
- Status: PARTIAL

### G6. AHC — AI coaching
- RAM modules: V, L, P, Rv
- RAM operates on: coaching templates, session evidence, outcome reports
- Status: PARTIAL

---

## H. Governance / consent / trust products

### H1. ConsentX — `consentx.org` (canonical, not .com.au)
- Role: consent + rights infrastructure
- RAM modules: V, Rg, W, P
- RAM operates on: consent records, provenance chains, asset rights metadata
- Status: PARTIAL

### H2. GC-BAT — AI governance
- Role: governance, board-AI-trust
- RAM modules: V, L, P, R, Rg
- RAM operates on: governance evidence, policy packs, audit trails
- Status: PARTIAL
- Completion: governance evidence packs RAM-bound with reality_ledger entries

---

## I. Portfolio / capability surfaces

### I1. T4H portfolio (1-page consolidated, 36 CCQs)
- Role: portfolio surface for the whole company
- RAM modules: P, V, R, Rg
- RAM operates on: portfolio cards, capability counts (live from registry), CCQ surfaces
- Constraint: all counts live from `t4h_business_registry`; never hardcoded
- Status: PARTIAL

### I2. Founder portfolio — Troy Latter (`TML-4PM/troy-latter`)
- Role: founder-level capability surface, CV
- RAM modules: P, V, L, R
- RAM operates on: CV, executive proof packs, speaking portfolio, advisory portfolio
- Gaps: placeholder fields, no JD tailoring
- Status: PARTIAL

### I3. Standards portfolio (Standards Australia / BCI)
- Role: standards-aligned capability surface
- RAM modules: P, V, L, R
- Status: PARTIAL

### I4. Humanitarian portfolio (Tech 4 Humanity framing)
- RAM modules: P, V, L
- Status: PARTIAL

### I5. Investor / commercial portfolio
- RAM modules: P, Rv, V
- Status: PARTIAL

---

## J. Operational / financial surfaces (cross-cutting)

### J1. BAS (FY25-26 Q1+Q2 overdue; FY24-25 unlodged with refund)
- RAM modules: V, L, P
- RAM operates on: BAS workpapers, evidence summaries, lodgement packs
- Evidence: maat workpaper rows, v_bas_quarterly_summary
- Status: PARTIAL — BLOCKED on lodgement

### J2. RDTI (FY22-23 to FY25-26 at 43.5% offset)
- RAM modules: V, L, P, R
- RAM operates on: RDTI evidence chain, AusIndustry CRP, project codes
- Required at creation: `is_rd=true` + `project_code`
- Status: PARTIAL

### J3. Banking / BASIQ — 10 tables, CFN `maat-basiq-prod`
- RAM modules: V, Rg, W
- Status: PARTIAL

### J4. Div7A balance — due 2026-06-30
- RAM modules: V, L
- Status: PARTIAL — BLOCKED on settlement plan

### J5. Atom schema — periodic table management
- Role: T4H Organisational Atom Table (v6–v10 active build surface)
- RAM modules: R, Rg, V
- RAM operates on: atom definitions, version diffs, build receipts
- Status: PARTIAL

### J6. Dashboard widget (4% fill across 27 portfolio assets)
- RAM modules: P, V, W
- RAM operates on: dashboard fill state, asset coverage
- Status: PARTIAL — BLOCKED until RAM portfolio cards backfill

---

## K. Asset registries / mechanical surfaces

### K1. `t4h_business_registry` — live business count
- RAM modules: Rg, V, P
- Constraint: counts always live; never hardcoded
- Status: PARTIAL

### K2. `t4h_canonical_changes` — change log (23 columns, 9 change_types, 4 severities)
- RAM modules: V, Rg, W
- RAM operates on: change rows, severity classification, broadcast
- Status: PARTIAL

### K3. `t4h_template_library` (`public.t4h_template_library`)
- Role: offer/use tracking templates
- RAM modules: R, V, P
- Status: PARTIAL

### K4. `infra_sites_registry` — portfolio site registry (~100+ surfaces)
- RAM modules: Rg, V, W
- Status: PARTIAL

### K5. `mcp_lambda_registry`
- Role: callable Lambdas, business_key UPPER-mapped to brand_map
- RAM modules: Rg, V, W
- Status: PARTIAL

### K6. `arch_wave_validation` — canonical architecture maturity
- Canonical (NOT `core.arch_maturity_spine`); max wave=6 across 8 systems; no wave=10
- RAM modules: V, Rg
- Status: PARTIAL

### K7. `llm_scratchpad` — cross-LLM scratchpad
- RAM modules: R, Rg, W
- Status: PARTIAL

---

## L. Cross-product RAM doctrines

1. **Dogfood-first.** RAM is not REAL until our own data is ingested, validated, reportable, dev-inspected, and prod-promoted with receipts.
2. **No PRETEND.** Only REAL / PARTIAL / BLOCKED.
3. **Counts always live.** No hardcoded business or asset counts; always pull from registry.
4. **Receipts mirror packages.** `PKG_*` always has a paired `RCPT_*`.
5. **Evidence is typed.** API response, db result, commit id, url with 2xx, receipt, hash, log.
6. **No hidden execution.** Every action writes to `audit.log` and (where applicable) `public.reality_ledger`.
7. **No `final` filenames.** Versioning + manifests already solve this.
8. **Reversible by lineage.** Renames go through `ram_asset_lineage`; never destructive.
9. **Reality Ledger is authoritative.** Session-start protocol: read `reality_ledger WHERE status=BLOCKED` first.
10. **STAMP governs.** Governance kernel approvals required where defined.

---

## M. Completion matrix (RAM-wide)

| Layer | REAL requires |
|---|---|
| Foundation systems | each spine system has at least one RAM-bound asset with REAL evidence |
| Master brand (Synal + Places) | one PKG_synal_* with REAL portfolio card |
| Cadence stack | each cadence product has one validated capability card |
| AGL types | each type has at least one peak-wave entry validated |
| Workforce/family/community | one role coverage report per product |
| Mission / outcomes | one validated evidence pack per product |
| Governance / trust | one governance evidence pack per product, ledger-bound |
| Portfolio surfaces | T4H 1-page portfolio rebuilt from RAM data |
| Operational / financial | BAS, RDTI, Div7A packs RAM-bound with reality_ledger rows |
| Registries | every registry row has RAM evidence coverage |

RAM is REAL when every row above is REAL.
Until then, the entire RAM entity stays PARTIAL.
