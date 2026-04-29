# AIMOS — Augmented Intelligent Medication Orchestration System

**Canonical handoff package**  
**Destination:** TML-4PM/the-pen  
**Status:** PARTIAL until deployed, smoke-tested, and Reality Ledger bound  
**Purpose:** Convert AIMOS from concept into bridge-ready infrastructure for pen → dev → prod flow.

---

## 1. Brand spine

**AIMOS** = Augmented Intelligent Medication Orchestration System.

Core belief:

> Medicine is safety and care. AIMOS makes it personal, continuous, and augmented.

Formal system position:

> AIMOS is a real-time, agent-driven orchestration system that manages the full lifecycle of medication from prescription to outcome across patients, chemists, doctors, suppliers, carers, and care networks.

Do not position AIMOS as a pharmacy chatbot, reminder app, or dispensing tool. It is medication orchestration infrastructure.

---

## 2. Persona layer: Dr Amos Roll

**Dr Amos Roll** is the human explanation layer for AIMOS.

Use:
- patient onboarding
- demo walkthroughs
- explainer videos
- internal shorthand
- companion-agent voice

Do not use:
- regulatory claims
- formal clinical documentation
- anything implying replacement of doctors, pharmacists, or emergency care

Positioning:

> Meet Dr Amos Roll — the calm intelligence behind AIMOS that helps keep medication safe, personal, and on track.

Internal rule:

> AIMOS is the system. Amos is how humans understand it.

Tone:
- calm
- reassuring
- precise
- never gimmicky
- never “AI doctor”
- always “coordination and safety support”

---

## 3. Core system loop

AIMOS is only real when this loop runs end-to-end:

```text
prescribe → validate → dispense → monitor → detect → decide → act → resolve → learn
```

Machine form:

```text
event → signal → decision → action → outcome → evidence
```

No loop, no product. No evidence, no REAL claim.

---

## 4. MVP operating boundary

First executable scope:

1. Script Intelligence Agent
2. Medication Companion Agent
3. Care Coordination Agent
4. Event bus
5. Supabase schema
6. API handlers
7. Simulated patient flows
8. Reality Ledger proof hooks
9. Pen → dev → prod deployment contract

Do not start with UI polish. Build the loop first.

---

## 5. Pilot clusters

Initial real-world pilot model is three local health clusters, not three isolated chemists.

### Cluster 1 — Grays Point
- Chemist: TerryWhite Chemmart Grays Point
- Nearby GP: next-door / local practice relationship
- Strategic value: proximity and trust

### Cluster 2 — Caringbah
- Chemist: Chemist Warehouse Caringbah
- Nearby medical centre: across road / local flow
- Strategic value: retail scale + medical adjacency

### Cluster 3 — Kirrawee
- Chemist: independent/local chemist
- Nearby GP: ~100m / family practice relationship
- Strategic value: smaller controlled trial environment

Pilot must begin with simulated patients before real-world use.

---

## 6. Supabase schema

```sql
create extension if not exists pgcrypto;

create table if not exists public.aimos_patients (
  patient_id uuid primary key default gen_random_uuid(),
  external_ref text,
  display_name text,
  date_of_birth date,
  risk_level text not null default 'unknown' check (risk_level in ('unknown','low','medium','high','critical')),
  consent_level text not null default 'session' check (consent_level in ('none','session','full')),
  linked_gp text,
  linked_chemist text,
  cluster_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.aimos_event_stream (
  event_id uuid primary key default gen_random_uuid(),
  event_type text not null,
  patient_id uuid references public.aimos_patients(patient_id),
  source text not null,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'new' check (status in ('new','processing','processed','failed','blocked')),
  processed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_aimos_event_stream_type_status on public.aimos_event_stream(event_type, status);
create index if not exists idx_aimos_event_stream_patient on public.aimos_event_stream(patient_id);

create table if not exists public.aimos_agents (
  agent_id text primary key,
  name text not null,
  layer text not null check (layer in ('signal','interpret','decide','execute','outcome')),
  trigger_events text[] not null default '{}',
  action_endpoint text,
  autonomy_level text not null default 'assist' check (autonomy_level in ('observe','assist','recommend','execute_dry_run','execute_approved')),
  status text not null default 'active' check (status in ('draft','active','paused','retired')),
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.aimos_actions (
  action_id uuid primary key default gen_random_uuid(),
  event_id uuid references public.aimos_event_stream(event_id),
  agent_id text references public.aimos_agents(agent_id),
  patient_id uuid references public.aimos_patients(patient_id),
  action_type text not null,
  action_taken text,
  result jsonb not null default '{}'::jsonb,
  outcome_status text not null default 'pending' check (outcome_status in ('pending','success','failed','blocked','needs_human')),
  evidence_ref text,
  created_at timestamptz not null default now()
);

create table if not exists public.aimos_outcomes (
  outcome_id uuid primary key default gen_random_uuid(),
  patient_id uuid references public.aimos_patients(patient_id),
  source_event_id uuid references public.aimos_event_stream(event_id),
  intervention text,
  outcome_type text not null,
  outcome_value jsonb not null default '{}'::jsonb,
  evidence_ref text,
  classification text not null default 'PARTIAL' check (classification in ('REAL','PARTIAL','PRETEND')),
  created_at timestamptz not null default now()
);

create table if not exists public.aimos_cluster_registry (
  cluster_id text primary key,
  cluster_name text not null,
  chemist_name text,
  gp_name text,
  suburb text,
  state text default 'NSW',
  status text not null default 'planned' check (status in ('planned','simulated','pilot','active','paused','retired')),
  notes text,
  created_at timestamptz not null default now()
);
```

---

## 7. Seed data

```sql
insert into public.aimos_agents (agent_id, name, layer, trigger_events, autonomy_level, config)
values
('aimos_script_intelligence', 'AIMOS Script Intelligence Agent', 'interpret', array['SCRIPT_CREATED'], 'recommend', '{"checks":["dose","duplication","interaction","history"]}'::jsonb),
('aimos_companion', 'AIMOS Medication Companion Agent', 'signal', array['MEDICATION_DISPENSED','MISSED_DOSE','ADHERENCE_DROP'], 'assist', '{"functions":["remind","detect_missed_dose","raise_adherence_drop"]}'::jsonb),
('aimos_care_coordination', 'AIMOS Care Coordination Agent', 'execute', array['GP_BOOKING_REQUIRED','SYMPTOM_ALERT','HIGH_RISK_ADHERENCE_DROP'], 'execute_dry_run', '{"functions":["prepare_booking","attach_context","notify_human"]}'::jsonb)
on conflict (agent_id) do update set
name = excluded.name,
layer = excluded.layer,
trigger_events = excluded.trigger_events,
autonomy_level = excluded.autonomy_level,
config = excluded.config,
updated_at = now();

insert into public.aimos_cluster_registry (cluster_id, cluster_name, chemist_name, gp_name, suburb, notes)
values
('grays_point', 'Grays Point Medication Safety Cluster', 'TerryWhite Chemmart Grays Point', 'Nearby GP / next-door practice', 'Grays Point', 'High-proximity pilot cluster'),
('caringbah', 'Caringbah Medication Safety Cluster', 'Chemist Warehouse Caringbah', 'Nearby medical centre', 'Caringbah', 'Retail scale and medical adjacency'),
('kirrawee', 'Kirrawee Medication Safety Cluster', 'Independent/local chemist', 'Nearby family practice', 'Kirrawee', 'Controlled local pilot environment')
on conflict (cluster_id) do update set
cluster_name = excluded.cluster_name,
chemist_name = excluded.chemist_name,
gp_name = excluded.gp_name,
suburb = excluded.suburb,
notes = excluded.notes;
```

---

## 8. API contract

### POST /api/aimos/events

Purpose: ingest canonical AIMOS event.

Request:

```json
{
  "event_type": "SCRIPT_CREATED",
  "patient_id": "uuid-or-null",
  "source": "gp|chemist|patient|device|simulator",
  "payload": {}
}
```

Response:

```json
{
  "ok": true,
  "event_id": "uuid",
  "status": "new"
}
```

### POST /api/aimos/dispatch

Purpose: process new events and trigger matching agents.

Response:

```json
{
  "ok": true,
  "processed": 3,
  "actions_created": 3,
  "blocked": 0
}
```

### GET /api/aimos/patient/:id/timeline

Purpose: return patient medication journey timeline.

Response:

```json
{
  "patient_id": "uuid",
  "events": [],
  "actions": [],
  "outcomes": []
}
```

### POST /api/aimos/simulate

Purpose: create synthetic patient flow for proof.

Request:

```json
{
  "scenario": "missed_dose_escalation",
  "cluster_id": "grays_point"
}
```

Response:

```json
{
  "ok": true,
  "patient_id": "uuid",
  "events_created": 5,
  "expected_loop": "prescribe_validate_dispense_monitor_escalate_resolve"
}
```

---

## 9. Agent behaviours

### 9.1 Script Intelligence Agent

Trigger:
- SCRIPT_CREATED

Inputs:
- medication
- dosage
- patient risk level
- known medications if available

Outputs:
- SCRIPT_OK
- SCRIPT_FLAGGED
- SCRIPT_BLOCKED_FOR_HUMAN_REVIEW

Actions:
- create aimos_actions row
- emit follow-up event if flagged
- never changes a script autonomously

### 9.2 Medication Companion Agent

Trigger:
- MEDICATION_DISPENSED
- MISSED_DOSE
- ADHERENCE_DROP

Inputs:
- dispense record
- patient preferences
- schedule

Outputs:
- REMINDER_SENT
- MISSED_DOSE
- ADHERENCE_DROP
- HIGH_RISK_ADHERENCE_DROP

Actions:
- reminders in dry-run/simulated form first
- flag pharmacist for medium/high risk
- escalate to care coordination when high risk

### 9.3 Care Coordination Agent

Trigger:
- GP_BOOKING_REQUIRED
- SYMPTOM_ALERT
- HIGH_RISK_ADHERENCE_DROP

Inputs:
- patient
- cluster
- urgency
- medication context

Outputs:
- GP_BOOKING_PREPARED
- HUMAN_REVIEW_REQUIRED
- EMERGENCY_ESCALATION_RECOMMENDED

Actions:
- prepare booking payload
- attach context
- never independently claims emergency diagnosis
- escalates to human for clinical action

---

## 10. Bridge-ready invocation envelopes

### 10.1 Supabase migration dry run

```json
{
  "action": "invoke_function",
  "function_name": "troy-sql-executor",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "dry_run",
    "system": "AIMOS",
    "migration_name": "aimos_core_schema_v1",
    "sql_source": "TML-4PM/the-pen/AIMOS_BRIDGE_READY_DEPLOYMENT_PACKAGE.md#supabase-schema"
  },
  "metadata": {
    "request_id": "aimos-schema-dry-run-v1",
    "source": "chatgpt",
    "timestamp_utc": "AUTO",
    "auth_context": "pen_to_dev"
  }
}
```

### 10.2 API deploy dry run

```json
{
  "action": "invoke_function",
  "function_name": "troy-lambda-deployer",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "dry_run",
    "system": "AIMOS",
    "service": "aimos-api",
    "handlers": [
      "events_ingest",
      "dispatch_events",
      "patient_timeline",
      "simulate_flow"
    ]
  },
  "metadata": {
    "request_id": "aimos-api-dry-run-v1",
    "source": "chatgpt",
    "timestamp_utc": "AUTO",
    "auth_context": "pen_to_dev"
  }
}
```

### 10.3 Smoke simulation

```json
{
  "action": "invoke_function",
  "function_name": "troy-lambda-manager",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "dry_run",
    "system": "AIMOS",
    "operation": "run_smoke_test",
    "scenario": "missed_dose_escalation",
    "cluster_id": "grays_point",
    "expected_events": [
      "SCRIPT_CREATED",
      "MEDICATION_DISPENSED",
      "MISSED_DOSE",
      "GP_BOOKING_REQUIRED",
      "OUTCOME_RECORDED"
    ]
  },
  "metadata": {
    "request_id": "aimos-smoke-v1",
    "source": "chatgpt",
    "timestamp_utc": "AUTO",
    "auth_context": "dev_proof"
  }
}
```

---

## 11. Suggested repo structure for dev/prod implementation

```text
aimos/
  README.md
  docs/
    BRAND_SPINE.md
    DR_AMOS_ROLL.md
    PILOT_CLUSTERS.md
    SAFETY_BOUNDARIES.md
  supabase/
    migrations/
      001_aimos_core_schema.sql
      002_aimos_seed_agents_clusters.sql
  api/
    events_ingest.ts
    dispatch_events.ts
    patient_timeline.ts
    simulate_flow.ts
  agents/
    script_intelligence.ts
    medication_companion.ts
    care_coordination.ts
  tests/
    smoke_missed_dose_escalation.test.ts
    smoke_script_flagged.test.ts
  bridge/
    invoke_schema_dry_run.json
    invoke_api_dry_run.json
    invoke_smoke_test.json
  reality-ledger/
    AIMOS_PROOF_GATES.md
```

---

## 12. Safety boundaries

AIMOS must not claim to diagnose, prescribe, replace doctors, replace pharmacists, or independently alter medication.

Allowed:
- remind
- detect patterns
- flag risk
- prepare context
- recommend human review
- coordinate logistics
- record outcomes

Blocked without human review:
- medication change
- substitution approval
- emergency triage final decision
- clinical diagnosis
- autonomous contacting of emergency services unless an explicit approved emergency workflow exists

---

## 13. Proof gates

AIMOS remains PARTIAL until all pass:

1. Schema deployed and queryable
2. Agents seeded in registry
3. Simulated patient created
4. SCRIPT_CREATED event ingested
5. Script Intelligence Agent action logged
6. MEDICATION_DISPENSED event ingested
7. Companion Agent action logged
8. MISSED_DOSE event ingested
9. Care Coordination Agent action logged
10. OUTCOME_RECORDED event ingested
11. Outcome row created
12. Reality Ledger evidence row written
13. Smoke test replayable
14. Deployment receipt stored

REAL status requires receipts for deployed infrastructure and runtime evidence.

---

## 14. Execution sequence

1. Store this package in TML-4PM/the-pen.
2. Dev team / bridge runner converts schema into migration files.
3. Run SQL dry-run.
4. Deploy schema to dev Supabase.
5. Seed agents and clusters.
6. Deploy API handlers.
7. Run smoke simulation.
8. Log Reality Ledger evidence.
9. Promote to prod only after dev proof passes.
10. Build minimal UI after loop proof, not before.

---

## 15. Homepage / pitch copy seed

Headline:

> Medication should not stop at the counter.

Subheadline:

> AIMOS keeps medication safe, personal, and continuous by coordinating patients, pharmacists, doctors, carers, and care teams through one intelligent medication journey.

Dr Amos Roll explainer:

> Meet Dr Amos Roll, the calm care layer inside AIMOS. Amos helps notice when something changes, prepares the right context, and makes sure the right human is brought in before small medication issues become bigger problems.

Callout:

> Safe. Personal. Continuous. Augmented.

---

## 16. Reality Ledger status

Current status: PARTIAL / HANDOFF CREATED

Reason:
- Concept, schema, API contracts, agents, proof gates, and deployment envelopes are defined.
- Not yet REAL because runtime deployment and smoke-test evidence are not attached.

Next REAL claim requires:
- GitHub receipt for this file
- dev deployment receipt
- smoke-test output
- Reality Ledger evidence binding
