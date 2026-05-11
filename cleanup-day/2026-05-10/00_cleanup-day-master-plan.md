# Cleanup Day Master Plan — 2026-05-10

status: PARTIAL
result: Execution plan created and lodged to the Pen. It is ready for rerun/build execution, but remains PARTIAL until the runtime sweep executes and returns receipts.
evidence:
- type: api_response
  source: GitHub connector create_file
  repo: TML-4PM/the-pen
  path: cleanup-day/2026-05-10/00_cleanup-day-master-plan.md
- type: source_catalogue
  source: uploaded GDrive Artifact Catalogue — 2026-03-01 05_01 - Catalogue.csv
  observed_counts:
    total_indexed_files: 6314
    js: 2988
    ts: 603
    html: 540
    md: 531
    json: 499
    png: 399
    tsx: 311
    txt: 228
    bridge_keyword_matches: 50
    pen_keyword_matches: 21
    dra_keyword_matches: 11
    atlas_keyword_matches: 2
gaps:
- Runtime sweep has not yet executed against Drive, GitHub, Vercel, Supabase, Stripe, and Bridge.
- Bridge-specific receipt endpoint is not available inside this connector view.
- Supabase and AWS execution proof still require bridge/local executor or credentials.
- Existing assets need semantic clustering beyond filename matching.
next_action: Run the cleanup rerun harness, emit REAL/PARTIAL/BLOCKED rows, and write receipts back to the Pen.
elevation: This moves the day from ad hoc cleanup into a repeatable portfolio recovery operating system.
pressure_flags:
- no_new_value risk if this remains a plan only
- drag risk if no runtime receipt is generated
- duplicate/project-drift risk across names, URLs, repos, and deployments
- false-completion risk where visual assets exist without runtime proof
score: 0.72
ledger:
  task_id: CLEANUP-DAY-2026-05-10-PLAN
  intent: Consolidate the whole session into a cleanup, recovery, indexing, signal, and rerun plan.
  execution: Created Pen plan asset via GitHub connector.
  output: cleanup-day/2026-05-10/00_cleanup-day-master-plan.md
  status: PARTIAL
  evidence: api_response pending commit SHA from GitHub create_file result
  score: 0.72

---

## 1. Operating Frame

Today is a cleanup, recovery, signal, indexing, and truth-alignment day.

The goal is not to create more disconnected artefacts. The goal is to recover what already exists, classify it, bind it to evidence, repair what is broken, identify duplicates, and push everything into the Pen as the canonical intake and execution surface.

The working model is:

```text
collect → index → cluster → classify → repair → lodge → receipt → rerun → monetise → replicate
```

Everything discovered must land in one of these states:

| State | Meaning | Action |
|---|---|---|
| REAL | Executed, evidenced, logged, replayable | Preserve, monitor, monetise |
| PARTIAL | Exists but missing proof, linkage, runtime, or receipt | Rerun or repair |
| BLOCKED | Requires credentials, authority, unavailable dependency, legal/safety gate | Escalate with bounded reason |
| KILL | Duplicate, stale, no value, or superseded | Archive/mark not planned |

---

## 2. Core Cleanup Domains

### 2.1 Business Registry Cleanup

Create the canonical registry of:
- business
- brand
- product
- offer
- domain
- deployment
- repo
- data source
- Stripe/payment link
- current status
- owner group
- lifecycle state

Required output:

| Business | Brand | Product | URL | Repo | Runtime | Revenue | State | Next Action |
|---|---|---|---|---|---|---|---|---|

Priority groups:
- G1 CORE: Tech 4 Humanity, WorkFamilyAI, Augmented Humanity Coach, HoloOrg
- G2 SIGNAL: GC-BAT, ConsentX, FAR-CAGE, MyNeuralSignal, NEUROPAK, RATPAK, LifeGraph+, AI Olympics
- G3 MISSION: Mission Critical, Outcome Ready, SmartPark, MedLedger, AquaMe
- G4 RETAIL / ENTRY: Enter Australia, APAC Just Walk Out, Vuon Troi, JustPoint, XCES, House of Biscuits
- G5 FUN / SIGNAL SURFACE: Apex Predator Insurance, Extreme Spotto, AI Oopsies, Rhythm Method, GirlMath, New Business 1, New Business 2
- Research and Personal sit outside the commercial flywheel but still require inventory.

---

### 2.2 Domain and Hosting Cleanup

Inventory and classify:
- registered domains
- Vercel projects
- Lovable deployments
- internal staging URLs
- external public URLs
- dead preview URLs
- duplicate frontends
- unbound domains
- SSL/DNS issues
- deployment protection state

Required output:

| Domain | Surface | Host | Repo | Backend | Auth | Stripe | Public/Internal | State |
|---|---|---|---|---|---|---|---|---|

---

### 2.3 Pen / Bridge / Dispatch Cleanup

Search and reconcile every instruction that says:
- send to bridge
- send to pen
- wrap and send
- get receipt
- close
- no HITL needed
- complete
- rerun
- receipt

Required output:

| Task | Source | Payload Exists | Pen Asset Exists | Bridge Receipt Exists | Runtime Proof | State |
|---|---|---|---|---|---|---|

This is the highest-risk truth gap. Requested execution does not equal executed work.

---

### 2.4 Asset Recovery Cleanup

The catalogue already shows 6,314 artefacts, including:
- 2,988 JS files
- 603 TS files
- 540 HTML surfaces
- 531 Markdown docs
- 499 JSON/config files
- 311 TSX files

This means the ecosystem has enough material for a major recovery pass.

Required processing:
- parse file names
- parse content where possible
- cluster semantically
- detect project lineage
- detect duplicate/rebranded systems
- detect runtime references
- detect Stripe/Supabase/Vercel/GitHub/API references
- detect receipts
- detect dead or orphaned outputs

---

### 2.5 Product Duplication and Naming Drift Cleanup

Known naming drift candidates:
- DRA / Drug Resilience Atlas / Drug Atlas / Resilience Atlas
- Outcome Ready / ThrivingOS / Thriving Biz / Thriving Kids
- Reading Buddy / SchoolFamilyAI / Kids Buddy / Education Buddy
- WorkFamilyAI / FamilyAI / Team Family
- MEE / JET / myJET
- Chatter / Synal / Doolittles / Signal Surface
- Tech4Humanity / Tech 4 Humanity / Tech for Humanity

Required output:

| Canonical Name | Aliases | Parent | Shared Engine | Keep/Merge/Kill | Reason |
|---|---|---|---|---|---|

---

### 2.6 Runtime Reality Cleanup

Every system must be classified by evidence, not confidence.

Checks:
- URL resolves
- API responds
- auth works or intentionally blocks
- form submission works
- Stripe path works
- data writes land in expected store
- logs/telemetry exist
- build/deployment is current
- receipt exists

Required output:

| Surface | Check | Result | Evidence | State | Fix |
|---|---|---|---|---|---|

---

### 2.7 Supabase / Data Cleanup

Inventory:
- projects
- tables
- edge functions
- RLS posture
- auth configuration
- JWT posture
- cron jobs
- queues
- old tables
- duplicate schemas
- orphan records

Required output:

| Project | Table/Function | Purpose | RLS/Auth | Used By | State | Fix |
|---|---|---|---|---|---|---|

---

### 2.8 Agent and Orchestration Cleanup

Reconcile:
- 727+ agents
- Neural Ennead
- 9x9x9
- HoloOrg role-to-agent mapping
- agent registry
- MCP Bridge agent actions
- role definitions
- prompt packs
- non-real/fake agents vs runtime agents

Required output:

| Agent | Purpose | Trigger | Tool Binding | Runtime Proof | State |
|---|---|---|---|---|---|

---

### 2.9 Research Cleanup

Canonicalise:
- AI Cognitive Diversity Research
- Drug Resilience Atlas
- BCI governance / GC-BAT
- ConsentX
- MyNeuralSignal
- psychological friction survey
- AI Sweet Spots
- Black Mirror / futures vignettes
- Augmented Memories
- committee influence engine

Required output:

| Research Asset | Evidence | Publishability | Commercial Path | Product Link | State |
|---|---|---|---|---|---|

---

### 2.10 Financial / Monetisation Cleanup

Map every product to:
- customer
- offer
- pricing
- Stripe product
- Stripe price
- payment link
- lead capture
- onboarding
- continuation loop

Required output:

| Product | Buyer | Offer | Price | Stripe Link | Funnel | State |
|---|---|---|---|---|---|---|

No major product should remain pure demoware.

---

### 2.11 UI / UX / Surface Cleanup

Consolidate:
- Synal
- Chatter
- Command Centre
- Signal overlays
- Doolittles
- dashboard widgets
- portfolio views
- TV/sport/live overlays
- Place metadata layer

Required output:

| Surface | Purpose | Shared Components | Data Source | Audience | State |
|---|---|---|---|---|---|

---

### 2.12 Thread / Session Cleanup

Every thread is a potential source of:
- action items
- partial builds
- missing receipts
- business decisions
- recovery candidates
- bridges never fired
- files never lodged

Required output:

| Thread | Intent | Assets | Missing Actions | Receipt | State |
|---|---|---|---|---|---|

---

## 3. Priority Queue

### P0 — Truth and Execution
- Pen/Bridge receipt gap
- runtime proof
- dead deployments
- missing evidence
- broken auth/security
- orphaned infra/cost risks

### P1 — Recovery
- DRA / Atlas assets
- Outcome Ready assets
- Reading Buddy / SchoolFamilyAI
- WorkFamilyAI
- Chatter/Synal
- Bridge dispatch assets
- Thread Recovery Engine

### P2 — Business Registry
- canonical 30-business registry
- domains and URLs
- internal vs external surfaces
- product/brand hierarchy

### P3 — Monetisation
- Stripe products/prices/payment links
- lead capture
- offer packaging
- onboarding
- continuation loops

### P4 — Reuse / Replication
- common tables
- shared components
- prompt packs
- execution templates
- reusable recovery harness

---

## 4. Build Requirements

The build asset lodged alongside this plan must provide:
- CSV artefact parser
- semantic keyword clustering
- canonical business/brand matcher
- URL/domain extractor
- runtime reference extractor
- Pen/Bridge signal extractor
- REAL/PARTIAL/BLOCKED classifier
- CSV/JSON/Markdown outputs
- receipt ledger writer
- rerun queue generator

Outputs must be written as:

```text
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

The cleanup day is not complete until:

1. Every indexed artefact is assigned to a cluster or orphan bucket.
2. Every cluster has a canonical parent business/product.
3. Every URL is classified public/internal/dead/unknown.
4. Every Bridge/Pen request has a receipt state.
5. Every business has at least one status row.
6. Every major product has a monetisation state.
7. Every REAL claim has typed evidence.
8. Every blocker has a bounded reason.
9. All outputs are lodged to the Pen.
10. A receipt is returned for the lodged work.

---

## 6. Immediate Rerun Order

1. Parse uploaded GDrive catalogue.
2. Generate canonical asset registry.
3. Cluster DRA / Atlas / Outcome Ready / Reading Buddy / WorkFamilyAI / Chatter / Bridge / Pen / Synal.
4. Generate recovery queue.
5. Generate runtime verification queue.
6. Generate monetisation queue.
7. Lodge results to Pen.
8. Create receipt ledger.
9. Trigger Bridge/local execution for systems requiring credentials or runtime access.
10. Close with REAL/PARTIAL/BLOCKED summary.
