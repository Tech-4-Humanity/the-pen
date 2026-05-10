# Pen Convergence & Portfolio Governance Engine v1

## Purpose

Transform The Pen from a passive ingestion layer into an active convergence, triage, merge, governance, and canonicalisation system.

This engine:
- Detects duplicates
- Detects capability overlap
- Detects wrapper businesses
- Detects infrastructure pretending to be products
- Detects dormant assets
- Routes items toward MERGE / CONTINUE / ARCHIVE / KILL
- Creates daily HITL governance packs
- Gradually reduces human governance over time

---

## Canonical Lifecycle

```yaml
states:
  - INTAKE
  - NORMALISED
  - TRIAGED
  - EXECUTING
  - MERGED
  - WRAPPER
  - DORMANT
  - ARCHIVED
  - KILLED
```

---

## Core Tables

### pen_items

```sql
create table if not exists pen_items (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  updated_at timestamptz default now(),

  title text not null,
  description text,
  source_thread text,
  source_url text,

  state text default 'INTAKE',
  reality_state text default 'PARTIAL',

  business_name text,
  product_name text,
  capability_name text,

  owner_system text,
  canonical_system text,

  overlap_score numeric default 0,
  monetisation_score numeric default 0,
  execution_score numeric default 0,
  reuse_score numeric default 0,
  strategic_score numeric default 0,

  recommended_action text,
  hitl_required boolean default false,

  merge_target uuid,
  archived_reason text,

  evidence jsonb default '{}'::jsonb,
  metadata jsonb default '{}'::jsonb
);
```

### canonical_capabilities

```sql
create table if not exists canonical_capabilities (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),

  capability_name text unique not null,
  canonical_system text not null,

  description text,

  status text default 'ACTIVE',

  owner_business text,
  maturity_level text,

  metadata jsonb default '{}'::jsonb
);
```

### convergence_links

```sql
create table if not exists convergence_links (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),

  source_item uuid references pen_items(id),
  target_item uuid references pen_items(id),

  relationship_type text,
  similarity_score numeric,

  recommendation text,

  approved boolean default false,
  approved_by text,
  approved_at timestamptz
);
```

### daily_triage_pack

```sql
create table if not exists daily_triage_pack (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),

  item_id uuid references pen_items(id),

  category text,
  severity text,

  recommendation text,
  rationale text,

  hitl_required boolean default true,

  resolved boolean default false,
  resolved_at timestamptz
);
```

---

## Canonical Capability Registry

| Capability | Canonical System |
|---|---|
| orchestration | WorkFamilyAI |
| consent | ConsentX |
| signal processing | MyNeuralSignal |
| execution | MCP Bridge |
| governance | GC-BAT |
| runtime UI | Synal |
| portfolio control | Command Centre |
| education wrapper | Outcome Ready |
| reading systems | Reading Buddy |
| neuro orchestration | NeuroPAK |
| robotics orchestration | RATPAK |
| evidence | Reality Ledger |
| agent registry | Neural Ennead |

---

## Merge Logic

```yaml
merge_rules:
  - if_overlap_gt_80:
      action: MERGE
  - if_same_capability_and_same_market:
      action: MERGE
  - if_same_capability_but_new_market:
      action: WRAPPER
  - if_no_market_and_low_reuse:
      action: DORMANT
  - if_no_signal_90_days:
      action: ARCHIVE
  - if_duplicate_and_no_unique_value:
      action: KILL
```

---

## HITL Governance Layer

Human-in-the-loop remains mandatory for:

```yaml
hitl_rules:
  - brand_merge
  - business_shutdown
  - legal_boundary
  - domain_transfer
  - high_cost_execution
  - permanent_archive
  - canonical_system_change
```

Everything else defaults to:

```yaml
default_execution_mode: AUTONOMOUS
```

---

## Daily Triage Output

```yaml
sections:
  - new_items
  - duplicate_detection
  - merge_candidates
  - wrapper_candidates
  - drift_detection
  - dormant_assets
  - strategic_signals
  - kill_candidates
  - reusable_primitives
  - unresolved_hitl
```

---

## Example Classification

```yaml
item: SchoolFamilyAI
capability: orchestration
market: education
canonical_system: WorkFamilyAI
similarity_score: 0.82
recommended_action: MERGE
wrapper_target: Outcome Ready
hitl_required: true
```

---

## Dev vs Pen Responsibilities

### Pen
- capture intent
- capture payloads
- capture discussions
- capture bridge jobs
- preserve raw cognition

### Dev
- normalise
- classify
- compare
- detect duplicates
- recommend merges
- score reuse
- generate governance packs
- escalate HITL items

---

## Decision Framework

| Scenario | Action |
|---|---|
| Same engine, different market | WRAPPER |
| Same engine, same market | MERGE |
| Infra pretending to be business | RECLASSIFY |
| Strong signal, low maturity | INCUBATE |
| No signal, no reuse | ARCHIVE |
| Canonical conflict | HITL |
| Strategic divergence | EXEC REVIEW |

---

## Daily Operating Cadence

### Morning
- ingest overnight items
- run similarity scan
- run convergence scan
- generate HITL pack

### Midday
- approve merges
- approve wrappers
- escalate conflicts

### Night
- archive dormant items
- update capability graph
- publish portfolio telemetry

---

## Reality Ledger Binding

```yaml
status: PARTIAL
result: governance asset committed to Pen repository; runtime deployment still pending
evidence:
  - type: commit_id
    value: pending_from_github_create_file
  - type: repo
    value: TML-4PM/the-pen
gaps:
  - Supabase tables not deployed
  - Command Centre widget not deployed
  - Daily automation not scheduled
  - Bridge runtime receipt not available in this connector path
next_action:
  - deploy SQL tables
  - wire daily triage pack automation
  - add Command Centre governance view
  - bind future Bridge receipt when MCP endpoint is available
elevation: organisational cognitive compression infrastructure
pressure_flags:
  - duplicate business emergence
  - wrapper/product confusion
  - canonical capability drift
score: 8.8
```

---

## End State

The Pen evolves into organisational cognitive compression infrastructure.

Capabilities:
- converges thousands of ideas into a few scalable systems
- detects portfolio drift
- compresses duplicate cognition
- maps reusable primitives
- creates canonical systems automatically
- reduces HITL over time
- preserves innovation without fragmentation

This becomes the defensibility layer.
