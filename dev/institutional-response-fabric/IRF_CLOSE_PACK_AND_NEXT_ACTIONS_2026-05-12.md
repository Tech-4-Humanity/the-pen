# Institutional Response Fabric — Close Pack and Next Actions

Date: 2026-05-12
Status: POSTED_TO_DEV
Evidence classification: PARTIAL

## What was completed

Compiled and posted the dev deployment spine for the Institutional Response Fabric and Constitutional Cognitive Mesh.

Committed payloads:

1. `dev/institutional-response-fabric/IRF_DEV_DEPLOYMENT_PAYLOAD_2026-05-12.json`
   - Commit: `a1922b4511944f5c14492c4f81564430f9aa7673`
   - Includes core runtime contract, registry schemas, seed capabilities, funding theses, POV lenses, wrappers, bridge manifest, and first proof-case definition.

2. `dev/institutional-response-fabric/IRF_PRODUCT_ROUTES_AND_READINESS_2026-05-12.json`
   - Commit: `e35714c62a28eba80d10cf0b2907d319e642852e`
   - Includes product readiness gates, product routing, first four concrete output routes, evidence gap requirements, and deployment actions.

3. `dev/institutional-response-fabric/IRF_CONSTITUTIONAL_RENEWAL_AND_TINY_GRANT_OUTPUTS_2026-05-12.json`
   - Commit: `581039184c8467e6e34ee2b91b396526d8ec642d`
   - Includes constitutional runtime boundary doctrine, no-HITL policy boundaries, evidence classification refinement, tiny grant wrapper, and first two tiny grant blueprints.

Prior related lineage:

- `TML-4PM/the-pen/inbox/thrivingkids-nohitl-endstatepack-20260512.json`
- Commit: `64c0f816dd6bcdc2b2c77deb171e173f6b517b31`

## System now defined

The system is not a grant-writing tool.

Canonical identity:

> Evidence-to-Opportunity Runtime inside an Institutional Response Fabric, governed by a Constitutional Cognitive Mesh.

Runtime loop:

```text
Opportunity intake
→ fit score
→ capability match
→ evidence check
→ evidence gap register
→ POV review
→ wrapper output
→ receipt
→ reuse
```

## Core registries to materialise in dev

Runtime-first:

- `opportunity_registry`
- `capability_registry`
- `evidence_registry`
- `output_registry`
- `receipt_ledger`
- `evidence_gap_register`

Enhancement layer:

- `asset_registry`
- `narrative_blocks`
- `pov_registry`
- `wrapper_templates`
- `relationship_edges`
- `scoring_model`
- `product_registry`
- `agent_registry` later, not first

## Seed capabilities

Initial canonical capabilities:

1. Disability Operations Intelligence
2. Carer Companion and Family Support Intelligence
3. AI Sweet Spots Assessment
4. Cognitive Accessibility Modes
5. ConsentX Dynamic Consent
6. Human Integrity Stack Governance
7. Reality Ledger Evidence System
8. WorkFamilyAI POV Review
9. AI4Professionals
10. AI4Tradies
11. Digital Child Protection
12. ADHD Desert and Access Gap Intelligence

## Output wrappers defined

- Grant wrapper
- Tiny grant wrapper
- Income offer wrapper
- Research wrapper
- Book wrapper
- Course wrapper
- Content wrapper
- Tender wrapper
- Investor wrapper

## Tiny grant correction

First two near-deadline grants are small-dollar and should not carry the full architecture.

Use tiny output packs only:

1. Inclusive Community Intelligence Pilot
2. Carer Companion and Family Support Intelligence Micro-Pilot

Tiny grant pack maximum:

- 150–250 word summary
- need statement
- who benefits
- 3–5 activity rows
- simple budget table
- 3–5 outcome measures
- short governance/safeguarding note
- evidence state note

## Constitutional runtime boundaries

Runtime identity is now:

> AUTONOMOUS_WITH_POLICY_GUARDS

No-HITL means:

- execution continuity without manual dependency
- inside immutable constitutional policy boundaries
- with evidence-backed truth enforcement
- telemetry visibility
- deterministic recovery
- bounded authority

It does not mean unrestricted authority over:

- communications
- identity
- claims
- finance
- destructive operations
- governance
- credentials
- health/legal interpretation
- production mutation

## Evidence classification

Current state remains PARTIAL.

Reasons:

- Payloads are compiled and committed.
- Runtime code execution is not yet proven.
- Supabase materialisation not yet verified.
- Telemetry continuity not yet proven.
- Recovery replay not yet validated.
- 72h survivability not demonstrated.
- External comms not smoke-tested.
- Reality Ledger reconciliation not verified.

## Code/DDL still required by bridge/dev worker

Generate and apply dev SQL for:

```sql
create schema if not exists irf;

create table if not exists irf.opportunity_registry (
  opportunity_id text primary key,
  type text not null,
  title text not null,
  source text,
  domain text,
  audience text,
  value_type text,
  value_estimate text,
  deadline date,
  requirements jsonb default '{}'::jsonb,
  scoring_criteria jsonb default '{}'::jsonb,
  evidence_required jsonb default '[]'::jsonb,
  status text not null default 'intake',
  priority text,
  reuse_score numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists irf.capability_registry (
  capability_id text primary key,
  name text not null,
  category text,
  description text,
  maturity text not null default 'PARTIAL',
  owner text,
  linked_evidence jsonb default '[]'::jsonb,
  linked_assets jsonb default '[]'::jsonb,
  reusable_for jsonb default '[]'::jsonb,
  commercial_status text,
  research_status text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists irf.evidence_registry (
  evidence_id text primary key,
  title text not null,
  evidence_type text,
  description text,
  source_url text,
  asset_ref text,
  capability_ref text,
  evidence_state text not null check (evidence_state in ('REAL','DEIDENTIFIED_REAL','PARTIAL','SYNTHETIC','HYBRID','INFERRED','PRETEND','PENDING')),
  confidence numeric,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists irf.product_registry (
  product_id text primary key,
  name text not null,
  buyer_segment text,
  primary_users text,
  outcome text,
  linked_capabilities jsonb default '[]'::jsonb,
  linked_evidence jsonb default '[]'::jsonb,
  commercial_status text,
  delivery_status text,
  evidence_state text not null default 'PARTIAL',
  reusable_for jsonb default '[]'::jsonb,
  priority text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists irf.wrapper_templates (
  wrapper_id text primary key,
  wrapper_type text not null,
  output_format text,
  required_sections jsonb default '[]'::jsonb,
  default_povs jsonb default '[]'::jsonb,
  required_evidence jsonb default '[]'::jsonb,
  scoring_weights jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists irf.pov_registry (
  pov_id text primary key,
  leader text,
  function text not null,
  core_question text,
  optimises_for jsonb default '[]'::jsonb,
  risks_seen jsonb default '[]'::jsonb,
  evidence_preference jsonb default '[]'::jsonb,
  comment_style text,
  reusable_for jsonb default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists irf.output_registry (
  output_id text primary key,
  output_type text not null,
  title text not null,
  source_opportunity text,
  linked_capabilities jsonb default '[]'::jsonb,
  linked_evidence jsonb default '[]'::jsonb,
  wrapper_used text,
  status text not null default 'draft',
  created_at timestamptz not null default now(),
  receipt_ref text
);

create table if not exists irf.evidence_gap_register (
  gap_id text primary key,
  related_opportunity text,
  related_capability text,
  missing_evidence text not null,
  importance text,
  owner text,
  status text not null default 'open',
  next_action text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists irf.receipt_ledger (
  receipt_id text primary key,
  receipt_type text not null,
  target text,
  status text not null,
  proof_url text,
  hash text,
  notes text,
  created_at timestamptz not null default now()
);
```

Add RLS, immutability and append-only policies before Synapse promotion.

## Bridge/dev next actions

1. Read all IRF payloads under `dev/institutional-response-fabric/`.
2. Create IRF dev schema/tables.
3. Seed 12 capabilities.
4. Seed 9 POV lenses.
5. Seed wrapper templates.
6. Seed product registry from product stack extension.
7. Generate first two tiny grant outputs.
8. Generate first four product-route outputs:
   - Provider Command Centre pilot one-pager
   - Disability Operations Intelligence grant wrapper
   - AI Sweet Spots course outline
   - ConsentX policy brief
9. Write evidence gaps for every unsupported claim.
10. Write receipt rows for generated outputs.
11. Emit runtime receipt with proof URL/hash.
12. Keep evidence state PARTIAL until runtime + telemetry + recovery evidence exists.

## What is next

Immediate next step:

> Run the dev worker / bridge deployment against this package and return runtime receipts.

The next meaningful evidence target is not another document. It is:

- Supabase tables created
- seed rows inserted
- generated outputs written
- evidence gaps logged
- receipt ledger populated
- worker log attached

Until then, the correct classification is PARTIAL.
