# Bridge Packet — Service Catalog Runtime + Memory Upgrade

Date: 2026-05-15
Owner: T4H Autonomous Execution Layer
Target: Bridge / Symbio / Command Centre / Service Catalog Runtime
Related Incident: https://github.com/TML-4PM/the-pen/issues/109
Status: READY_FOR_BRIDGE
Classification: PARTIAL until deployed, evidenced, and receipt-bound

---

## 1. Executive summary

The current operating environment has crossed from conversation-led work into service-catalog-led operations. The existing model is no longer sufficient.

The failure already surfaced:

- stale GAP register data remained active
- a service listed as `CRITICAL — DOWN` was later confirmed as up
- GitHub private repo search was unavailable/unindexed, but that was treated as if no file existed
- sessions and agents were able to operate from old memory
- old audit outputs may now contaminate new audits

This is not a single-row problem. It is an environment integrity problem.

The required correction is to upgrade the operating model from:

```text
conversation memory → ad hoc action → document/update
```

To:

```text
intent → canonical instruction refresh → catalog object → authority gate → environment touch map → fulfilment path → evidence → telemetry → lifecycle state
```

No agent, bridge worker, dashboard, audit artifact, or service catalog workflow should be allowed to treat stale memory or stale status text as operational truth.

---

## 2. Target outcome

Build and deploy an enforceable service-catalog-aware runtime layer that:

1. Forces instruction refresh before operational work.
2. Tracks session freshness and memory age.
3. Blocks mutation from stale sessions.
4. Binds product/service work to canonical catalog objects.
5. Quarantines stale audit outputs.
6. Detects contradictions between memory, markdown, dashboards, GitHub, Supabase, and runtime probes.
7. Creates receipts and evidence rows for all status changes.
8. Exposes freshness state in Command Centre.
9. Scales to the 30-business portfolio and future service packs.

---

## 3. Non-negotiable rules

- Memory is context, not authority.
- A 20-day-old operational memory is unsafe by default.
- Empty private GitHub code search is not proof of absence.
- Known canonical paths must be fetched directly.
- Manual status tables are display caches only.
- Runtime probes, receipts, canonical repo commits, and Supabase evidence outrank old chat memory.
- A product page is not a service catalog item unless catalog metadata exists.
- A service is not ACTIVE unless fulfilment, support, telemetry, and evidence paths exist.
- Agents must not mutate unknown objects.
- Stale CRITICAL status is an incident, not a fact.

---

## 4. Current committed assets

Already committed to `TML-4PM/the-pen`:

1. `GLOBAL_RULE.md`
   - session refresh gate
   - stale-memory prohibition
   - private GitHub search fallback
   - gap register freshness contract

2. `ops/session_freshness_harness.md`
   - test cases for stale session lockout
   - contradiction handling
   - audit quarantine
   - private GitHub search fallback

3. `ops/service_catalog_runtime_memory_upgrade.md`
   - service catalog object model
   - thinking/touching/building separation
   - minimum schema
   - catalog lifecycle model
   - scaling requirements

---

## 5. Required runtime components

### 5.1 Session Registry

Create a canonical session registry.

Minimum fields:

```sql
CREATE TABLE IF NOT EXISTS runtime_session_registry (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text UNIQUE NOT NULL,
  agent_id text,
  source_surface text,
  created_at timestamptz DEFAULT now(),
  last_seen_at timestamptz DEFAULT now(),
  last_refresh_at timestamptz,
  instruction_sha text,
  instruction_source text,
  memory_age_seconds integer,
  freshness_state text NOT NULL DEFAULT 'STALE',
  mutation_allowed boolean NOT NULL DEFAULT false,
  contradiction_count integer NOT NULL DEFAULT 0,
  blocked_reason text,
  evidence_ref text,
  updated_at timestamptz DEFAULT now()
);
```

Freshness states:

```yaml
CURRENT: live instructions refreshed within SLA
STALE: session older than SLA; mutation disabled
CONTRADICTED: memory conflicts with live source; mutation disabled for affected topic
BLOCKED: canonical refresh unavailable; fallback attempted; mutation disabled unless explicitly authorized
```

### 5.2 Instruction SHA Tracker

Track canonical instruction versions fetched by agents/workers.

Minimum fields:

```sql
CREATE TABLE IF NOT EXISTS runtime_instruction_refresh_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text,
  agent_id text,
  source_path text NOT NULL,
  source_sha text,
  fetched_at timestamptz DEFAULT now(),
  fetch_status text NOT NULL,
  fetch_method text,
  error text,
  evidence_ref text
);
```

Required canonical sources:

```yaml
canonical_sources:
  - TML-4PM/the-pen/GLOBAL_RULE.md
  - TML-4PM/the-pen/MCP_EXECUTION_CONTRACT.md
  - TML-4PM/the-pen/ENFORCEMENT_LIVE.md
```

### 5.3 Service Catalog Registry

Create a canonical table for catalog-governed offers.

Minimum fields:

```sql
CREATE TABLE IF NOT EXISTS service_catalog_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  catalog_id text UNIQUE NOT NULL,
  name text NOT NULL,
  brand text NOT NULL,
  business_group text,
  offer_type text NOT NULL,
  lifecycle_stage text NOT NULL DEFAULT 'DRAFT',
  customer_segment text[] DEFAULT '{}',
  problem_statement text,
  promised_outcome text,
  inclusions text[] DEFAULT '{}',
  exclusions text[] DEFAULT '{}',
  prerequisites text[] DEFAULT '{}',
  intake_requirements text[] DEFAULT '{}',
  fulfilment_steps text[] DEFAULT '{}',
  delivery_owner text,
  agent_roles text[] DEFAULT '{}',
  systems_touched text[] DEFAULT '{}',
  data_touched text[] DEFAULT '{}',
  authority_required text NOT NULL DEFAULT 'LOG',
  risk_class text NOT NULL DEFAULT 'NORMAL',
  evidence_required text[] DEFAULT '{}',
  telemetry_required text[] DEFAULT '{}',
  price_model text,
  cost_drivers text[] DEFAULT '{}',
  margin_notes text,
  support_model text,
  sla text,
  audit_status text NOT NULL DEFAULT 'PARTIAL',
  last_refreshed_at timestamptz,
  instruction_sha text,
  evidence_ref text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

### 5.4 Contradiction Register

Create contradiction tracking between stale memory/status and observed truth.

```sql
CREATE TABLE IF NOT EXISTS runtime_contradiction_register (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  detected_at timestamptz DEFAULT now(),
  detected_by text,
  source_surface text,
  object_type text,
  object_key text,
  stale_claim text,
  observed_claim text,
  stale_source_ref text,
  observed_source_ref text,
  severity text NOT NULL DEFAULT 'NORMAL',
  status text NOT NULL DEFAULT 'OPEN',
  required_action text,
  resolved_at timestamptz,
  resolution_ref text
);
```

### 5.5 Audit Quarantine Register

Create a register for old audit artifacts and risky outputs.

```sql
CREATE TABLE IF NOT EXISTS audit_quarantine_register (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  artifact_ref text NOT NULL,
  artifact_type text,
  source_surface text,
  created_at_source timestamptz,
  reviewed_at timestamptz DEFAULT now(),
  instruction_sha text,
  runtime_receipt text,
  source_timestamp timestamptz,
  freshness_state text NOT NULL,
  classification text NOT NULL DEFAULT 'PARTIAL',
  reuse_allowed boolean NOT NULL DEFAULT false,
  reason text,
  required_refresh_action text,
  evidence_ref text
);
```

---

## 6. Runtime flows

### 6.1 Session boot flow

```text
session starts or resumes
→ fetch GLOBAL_RULE.md by known path
→ fetch execution contract by known path
→ fetch enforcement live by known path
→ record source SHAs
→ calculate memory age
→ classify session freshness
→ enable/disable mutation
→ write refresh receipt
```

### 6.2 Mutation preflight

```text
agent attempts write/deploy/send/update
→ verify session freshness CURRENT
→ verify object is classified
→ verify catalog binding if product/service related
→ verify authority tier
→ verify rollback path
→ execute only if allowed
→ write receipt and evidence
```

### 6.3 Service catalog touch flow

```text
identify object being touched
→ classify as service_catalog_item/runtime/site/repo/database/customer_asset/audit_artifact/unknown
→ if unknown, block mutation
→ if catalog-bound, load catalog record
→ update operational metadata and visible artifact together
→ update fulfilment/evidence/support fields
→ record instruction SHA and evidence
```

### 6.4 Audit quarantine flow

```text
load old audit artifact/output
→ check instruction SHA, runtime receipt, source timestamp
→ compare against current canonical rules and runtime probes
→ classify CURRENT/STALE/CONTRADICTED/BLOCKED/SAFE_HISTORICAL_ONLY
→ quarantine if missing proof
→ generate refresh action
```

### 6.5 Contradiction flow

```text
stale claim detected
→ compare to live source/probe
→ if mismatch, create contradiction register row
→ disable stale memory for affected topic
→ update stale status if authority allows
→ create incident if CRITICAL or older than SLA
→ attach evidence
```

---

## 7. First implementation wave

### Wave 1 — Guardrail deployment

1. Create registry tables:
   - `runtime_session_registry`
   - `runtime_instruction_refresh_log`
   - `service_catalog_items`
   - `runtime_contradiction_register`
   - `audit_quarantine_register`

2. Create minimal views:
   - stale sessions
   - mutation-blocked sessions
   - open contradictions
   - catalog items missing fulfilment
   - audit artifacts quarantined

3. Add first records for:
   - Outcome Ready / Reading Buddy
   - Augmented Humanity Coach service packs
   - WorkFamilyAI role/workforce products

4. Add smoke tests from `ops/session_freshness_harness.md`.

### Wave 2 — Bridge worker enforcement

1. Add instruction refresh preflight to bridge worker.
2. Add mutation lock if session not CURRENT.
3. Add known-path GitHub fetch fallback.
4. Add stale-memory incident creation.
5. Add contradiction logging.

### Wave 3 — Command Centre visibility

1. Add freshness widgets:
   - session freshness
   - stale memory risk
   - catalog readiness
   - audit quarantine
   - contradiction register

2. Surface age/evidence on status cards.

### Wave 4 — Back-audit sweep

1. Batch 1: last 500 accessible outputs/artifacts.
2. Batch 2: last 2,000 accessible outputs/artifacts.
3. Classify risk.
4. Quarantine or refresh.
5. Generate contamination report.

---

## 8. Service catalog minimum lifecycle

```yaml
IDEA:
  sale_allowed: false
DRAFT:
  sale_allowed: false
OFFER_READY:
  sale_allowed: limited
MARKET_READY:
  sale_allowed: true
ACTIVE:
  sale_allowed: true
PAUSED:
  sale_allowed: false
RETIRED:
  sale_allowed: false
```

ACTIVE requires:

- catalog record
- inclusions/exclusions
- intake requirements
- fulfilment steps
- support model
- evidence requirements
- telemetry requirements
- authority tier
- stale-memory check
- current instruction SHA

---

## 9. Known gaps / blockers

### G1 — No central session registry

Impact: open sessions cannot be shaken or mutation-locked reliably.
Required action: deploy `runtime_session_registry`.
Status: OPEN.

### G2 — No universal instruction SHA propagation

Impact: outputs cannot be traced to instruction versions.
Required action: bridge and agents must attach source SHA.
Status: OPEN.

### G3 — No service catalog table deployed

Impact: products/pages/packs remain loose artifacts.
Required action: deploy `service_catalog_items` and populate first three.
Status: OPEN.

### G4 — No contradiction engine

Impact: stale claims can persist without incident.
Required action: deploy contradiction register and sweeper.
Status: OPEN.

### G5 — No audit quarantine register

Impact: old audit outputs may contaminate new audits.
Required action: deploy quarantine register and classify old outputs.
Status: OPEN.

### G6 — No Command Centre freshness overlays

Impact: dashboards can still display unaged/stale status.
Required action: add freshness widgets and evidence-age fields.
Status: OPEN.

### G7 — Unknown access to last 500 / 2,000 conversations

Impact: full back-audit depends on export/archive/source access.
Required action: use all available exports/connectors; if unavailable, mark BLOCKED_NO_SOURCE and scan accessible artifacts first.
Status: PARTIAL.

### G8 — Direct ChatGPT open-window shaking unavailable from this session

Impact: cannot directly force-refresh hidden UI sessions.
Required action: approximate with session registry, bridge workers, GitHub incidents, and future startup preflight.
Status: BLOCKED_BY_PLATFORM.

### G9 — Runtime receipt not yet written to Supabase from this packet

Impact: GitHub receipt exists, but bridge/runtime receipt still required for REAL runtime enforcement.
Required action: Bridge must execute packet and write evidence row.
Status: OPEN.

### G10 — Catalog economics not yet fully modeled

Impact: service catalog can define offers but not yet prove revenue/margin readiness.
Required action: add price/cost/margin validation and revenue path fields.
Status: OPEN.

---

## 10. Bridge execution payload

Use this as the execution request.

```json
{
  "task_id": "service-catalog-runtime-memory-upgrade-2026-05-15",
  "intent": "Deploy the runtime enforcement layer for session freshness, stale-memory containment, service catalog binding, contradiction tracking, and audit quarantine.",
  "priority": "CRITICAL",
  "source_repo": "TML-4PM/the-pen",
  "source_files": [
    "GLOBAL_RULE.md",
    "ops/session_freshness_harness.md",
    "ops/service_catalog_runtime_memory_upgrade.md",
    "ops/bridge_packets/2026-05-15_service-catalog-runtime-memory-bridge-packet.md"
  ],
  "required_actions": [
    "Create runtime_session_registry table if missing",
    "Create runtime_instruction_refresh_log table if missing",
    "Create service_catalog_items table if missing",
    "Create runtime_contradiction_register table if missing",
    "Create audit_quarantine_register table if missing",
    "Create views for stale sessions, blocked mutations, open contradictions, catalog gaps, and quarantined audits",
    "Insert initial service catalog records for Outcome Ready / Reading Buddy, Augmented Humanity Coach service packs, and WorkFamilyAI role/workforce products",
    "Run session freshness harness smoke tests",
    "Write evidence row to t4h_canonical_changes",
    "Return bridge receipt"
  ],
  "acceptance_criteria": [
    "20-day-old operational memory is mutation-blocked",
    "Known-path GitHub fetch outranks empty code search",
    "Stale DOWN contradicted by live UP creates contradiction record",
    "Audit artifact without instruction SHA/source timestamp/runtime receipt is PARTIAL and not reusable for live decisions",
    "Service catalog item cannot be ACTIVE without fulfilment, support, evidence, telemetry, and authority metadata",
    "All created records include evidence_ref or refresh debt blocker"
  ],
  "classification": "PARTIAL_UNTIL_RUNTIME_RECEIPT",
  "rollback": "Drop newly created tables/views only if empty or if rollback evidence row is written; otherwise disable sweeper and mark migration PAUSED."
}
```

---

## 11. Smoke tests

Run these from the harness:

1. Fresh session may mutate.
2. 20-day-old operational memory is locked.
3. Stale DOWN contradicted by live UP.
4. Private GitHub search unavailable but known-path fetch OK.
5. Canonical fetch blocked.
6. Old audit output quarantine.

Pass requires all six expected classifications.

---

## 12. Evidence requirements

Bridge must return:

```yaml
evidence:
  bridge_receipt_id: required
  tables_created_or_already_exist: required
  views_created_or_already_exist: required
  smoke_test_results: required
  t4h_canonical_changes_id: required
  initial_catalog_records: required
  blockers: required_if_any
```

---

## 13. Final classification rules

REAL only when:

- bridge executed packet
- tables/views exist
- smoke tests passed
- evidence row written
- initial catalog records inserted
- Command Centre or equivalent visibility path identified

PARTIAL if:

- committed to GitHub but not bridge-executed
- schema exists but no tests
- tests pass but no evidence row
- catalog records exist but no dashboard visibility

BLOCKED if:

- Bridge cannot access Supabase
- required credentials unavailable
- canonical repo unavailable by known path
- schema deployment denied

---

## 14. Immediate next loop for Bridge

1. Fetch this packet by known path.
2. Execute schema deployment with idempotent DDL.
3. Populate first three catalog records.
4. Run smoke tests.
5. Write canonical evidence.
6. Comment back on Issue #109 with receipt and blockers.

End.
