# Research Hub Long-Cycle Compile Receipt

Date: 2026-05-21
Owner: Troy Latter / Tech 4 Humanity
Status: PARTIAL — compiled and posted to canonical repo; Bridge runtime receipt still requires Bridge execution confirmation.

## Summary

This compile consolidates the long-cycle research extraction and architecture work covering AI Sweet Spots, Digital Child Protection, Research Hub, Research IP registry, Operating Ledger, Temporal orchestration, and infrastructure-readiness material.

The key outcome is that the programme is no longer just a set of sites and conversations. It is now represented as a traceable research operating spine:

- Two mature public research arms: AI Sweet Spots and Digital Child Protection.
- Six expansion arms mapped into an 8 x 8 programme model.
- A Research Hub landing architecture for hosting programmes and artefacts.
- A Research IP registry with 11 studies, 29 known artefacts, 8 reading packs, 10 priority gaps, and a 58-plus column schema.
- Operating Ledger schema and Bridge queue payloads for Plan / Build / Run execution.
- Temporal V1 architecture charter for durable orchestration.
- Infrastructure map precursor showing 42 businesses, 156 Vercel projects, 80 site rows, 1,581 schema/table rows, seven infrastructure groups, and readiness scoring.

## Primary source files opened and classified

### 1. Level 10 portfolio / infrastructure pack

Classification: PARTIAL source-of-truth candidate.

Findings:
- 140-surface audit seed.
- 44 connector catalogue.
- 1,000-agent operating registry.
- Unified surface registry.
- Explicitly does not resolve business ownership, domains, deployments, connectors, and evidence.

Conclusion: staging workbook, not final operational truth.

### 2. T4H infrastructure map

Classification: high-value precursor.

Findings:
- 42 mapped businesses.
- 156 Vercel projects.
- 80 site rows.
- 1,581 schema/table rows.
- Seven infrastructure groups.
- Business readiness scoring.

Conclusion: precursor to March 11 state file and useful for portfolio/runway audit.

### 3. Operating Ledger Stack

Classification: build-ready operating schema.

Findings:
- Plan / Build / Run operating ledger model.
- Canonical ID design: portfolio_id, group_id, business_id, product_id, system_id, env_id, vendor_id, contract_id, cost_item_id, artifact_id, run_unit_id.
- Registries: business, product, system, vendor, contract/subscription, environment, data classification, asset/evidence, runbook/controls.
- Link graph: business to products, products to systems, systems to vendors, systems to environments, systems to data classifications, systems to run units, cost items to systems/products, transactions to evidence.
- API views: systems summary, budget rollup, risk rollup, vendor spend, business spend, gap hunter, public surface, renewals, drift summary, run health.
- SQL packs for dry-run, commit, drift evaluator, usage heartbeat, RUN initialisation.

Conclusion: strong candidate to become the system/control-plane ledger for T4H operations.

### 4. Temporal V1 Architecture Charter

Classification: durable orchestration charter.

Findings:
- Eight queue taxonomy: orchestration, AI, data, files, system, governance, deadletter, maintenance.
- 13-state lifecycle: RECEIVED through terminal states.
- 39 resource types.
- 22 day-one connectors.
- Six worker types.
- Seven core workflows.
- Evidence binding, dead-letter, retry, supervisor, replay, audit by design.
- Builder handoff path and five-week implementation plan.

Conclusion: orchestration blueprint for Bridge / Temporal / autonomous job execution.

### 5. Research-home progression document

Classification: programme architecture lock.

Findings:
- Establishes 8 x 8 research programme model.
- Defines two mature arms: AI Sweet Spots and Digital Child Protection.
- Frames six additional expansion arms: CARE/CSO, Extreme AI Effects, X-overpoints, Human Biology x AI, MyNeuralSignal, Unified Biological Intelligence.
- Defines artefact-first migration model.
- Defines Research Hub sitemap: /, /programmes, /programmes/ai-sweet-spots, /programmes/digital-child-protection, /artefacts, /methods, /evidence, /partners, /about.
- Defines octopus design rule: body fixed, arms thicken with maturity, uneven arm shapes allowed, timeline shows 1 -> 2 -> 4 -> 8 progression.
- Defines artefact maturity ladder: Defined, Built, Tested, Reusable, Institutional.

Conclusion: public research-home architecture and narrative wrapper.

### 6. 04_RESEARCH_IP_Registry_v1.0 latest candidate

Classification: strongest structured research evidence source located in this cycle.

Latest candidate opened: 04_RESEARCH_IP_Registry_v1.0 (2).xlsx, updated 2026-04-17.

Findings:
- 11 studies.
- 29 known artefacts.
- 8 reading packs.
- 10 gap / next-action rows.
- 58-column schema extended to derived fields.

Study registry includes:
- STU-001 ASS1 AI Sweet Spots Core Discovery, n=1,627.
- STU-002 ASS2_EXT AI Sweet Spots Extended Longitudinal, n=4,247.
- STU-003 EXTREME_AI Extreme AI Effects, n=4,247.
- STU-004 CURVES_CONSQ From Curves to Consequences, n=4,247.
- STU-005 COG_ARCH Cognitive Architecture Optimization.
- STU-006 NEURO_TRUST Neurosymbolic Trust Architecture, n=1,427.
- STU-007 MYNEURAL MyNeuralSignal BCI Trust Platform.
- STU-008 LIVING_STACK The Living Stack.
- STU-009 UBI_ECON Unified Biological Intelligence, n=847.
- STU-010 STATE_COND_AI State-Conditional AI Sweet Spots and Cognitive Diversity, beta.
- STU-011 PSYCHEDELICS_AI Psychedelics x AI / DRA, draft.

Artefact registry status:
- Several public or Drive-backed artefacts found.
- Approximately 20 artefacts remain chat-only.
- 3 artefacts missing: Life of Consent PDF, AI Guardrails SVG, FAR-CAGE Map SVG.
- No print-ready poster PDFs across poster_main artefacts.
- State-Conditional study has strong methods paper but needs poster and teaser.
- DRA/Psychedelics paper is about 40 percent complete and must not be published as complete.

Conclusion: this registry is the most useful source for Research Hub, accountant/RDTI narrative, artefact migration, and source-of-truth work.

## Programme model compiled

### Mature arm 1 — AI Sweet Spots

Status: REAL as a programme surface, PARTIAL as formally evidenced dataset unless supporting files are bound.

Assets already visible in source material:
- Assessment engine.
- Studies register.
- Papers.
- Posters.
- Insights.
- Population profiles.
- Several study records with sample sizes and evidence grading.

Primary gap:
- Need hard evidence binding: canonical URLs, Drive/S3 mirrors, checksums, versioning, citation text, poster PDFs, and dataset packaging.

### Mature arm 2 — Digital Child Protection

Status: PARTIAL to STRONG depending on asset.

Assets identified in prior compiled material:
- Compare the Media / platform compliance tracker.
- SM Ban Watch.
- CalmBound / Kids Visit Mode.
- BYOV and U16 opt-out simulator.
- ConsentX integration.
- Cost/benefit model.
- ePub outputs.
- LinkedIn/public corpus.

Primary gap:
- Needs canonical landing page and asset registry binding equivalent to AI Sweet Spots.

### Expansion arms

- CARE / CSO: partial, needs evidence binding.
- Extreme AI Effects: partial/strong where linked to STU-003.
- X-overpoints: planned/partial.
- Human Biology x AI: planned/partial.
- MyNeuralSignal: partial/architectural.
- Unified Biological Intelligence: partial/theory, linked to STU-009.

## Required actions passed to Bridge

1. Preserve this compile in canonical repo.
2. Create Bridge execution ticket for Research Hub continuation.
3. Bind latest Research IP registry as current working candidate, not final truth until Drive/S3/export receipts exist.
4. Build artefact migration matrix keyed by study_id, artefact_id, programme arm, source URL, evidence grade, discoverability grade, checksum status, and next action.
5. Reconcile AI Sweet Spots study count and pricing inconsistencies.
6. Create Research Hub MVP surface with two dominant programme pages and artefact-first layout.
7. Create Digital Child Protection landing page as second mature arm.
8. Generate missing poster PDFs or mark explicitly BLOCKED if source assets are absent.
9. Export chat-only artefacts to durable storage and assign canonical_url / mirror_drive_url / checksum_sha256.
10. Add Reality Ledger status to each study and artefact: REAL, PARTIAL, BLOCKED.

## Evidence

Typed evidence available from this compile:
- Google Drive opened file: Operating Ledger Stack document.
- Google Drive opened file: Temporal V1 Architecture Charter.
- Google Drive opened file: Research-home progression document.
- Google Drive opened file: 04_RESEARCH_IP_Registry_v1.0 (2).xlsx.
- Google Drive search result family for Research IP registry variants.
- GitHub commit receipt for this compile file will be returned by connector.

## Gaps

- Bridge runtime receipt not yet confirmed at the time of this file creation.
- No direct deployment URL generated in this step.
- Some Drive files remain metadata-only or fetch-limited.
- Chat-only artefacts remain non-durable until exported.
- Missing artefacts remain unresolved.
- Some sample-size claims and public claims still require source dataset binding.

## Next action

Bridge should execute the Research Hub continuation as a durable work item:
- Pull this compile.
- Build the artefact migration matrix.
- Create Research Hub MVP artefact pack.
- Generate or queue missing exports.
- Return Bridge receipt with run_id, commit SHA(s), created files, and blocked items.

## Ledger

task_id: research-hub-long-cycle-compile-20260521
intent: compile long-cycle research extraction and post to canonical execution spine
execution: GitHub canonical receipt file creation via connector
output: receipts/2026-05-21-research-hub-long-cycle-compile.md
status: PARTIAL
evidence: GitHub create_file response plus opened Drive source files
score: 0.78
pressure_flags:
- no_bridge_runtime_receipt_yet
- chat_only_assets_not_durable
- missing_artifacts_exist
- claims_need_dataset_binding

elevation: The work moved from scattered chat/source discovery into a canonical compile receipt with explicit next Bridge execution actions.
