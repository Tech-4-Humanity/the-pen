-- Integrity Stack Runtime Schema
-- Status: PARTIAL until deployed against a live database and linked to Reality Ledger receipts.
-- Purpose: make Need -> Signal -> Identity -> Consent -> Intent -> Route -> Act -> Measure -> Learn -> Govern -> Recover executable.

create table if not exists integrity_needs (
  need_id text primary key,
  owner_actor_id text,
  beneficiary text not null,
  beneficiary_group text not null,
  need_statement text not null,
  urgency text check (urgency in ('LOW','MEDIUM','HIGH','CRITICAL')) default 'MEDIUM',
  status text check (status in ('PROPOSED','ACTIVE','RESOLVED','REJECTED','BLOCKED')) default 'PROPOSED',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists integrity_signals (
  signal_id text primary key,
  need_id text references integrity_needs(need_id),
  source_layer int not null check (source_layer between 1 and 7),
  signal_type text not null,
  signal_payload jsonb not null default '{}'::jsonb,
  provenance jsonb not null default '{}'::jsonb,
  quality_score numeric check (quality_score >= 0 and quality_score <= 1),
  captured_at timestamptz default now()
);

create table if not exists integrity_identities (
  identity_id text primary key,
  actor_id text not null,
  actor_type text not null,
  role_context text,
  authority_scope jsonb not null default '{}'::jsonb,
  credential_status text check (credential_status in ('ASSERTED','VERIFIED','EXPIRED','REVOKED','UNKNOWN')) default 'UNKNOWN',
  evidence_ref text,
  created_at timestamptz default now()
);

create table if not exists integrity_consents (
  consent_id text primary key,
  identity_id text references integrity_identities(identity_id),
  purpose text not null,
  data_scope jsonb not null default '{}'::jsonb,
  consent_status text check (consent_status in ('GRANTED','DENIED','REVOKED','LIMITED','UNKNOWN')) not null,
  fallback_mode text check (fallback_mode in ('FULL','SESSION','NONE')) default 'NONE',
  receipt_ref text,
  valid_from timestamptz default now(),
  valid_until timestamptz
);

create table if not exists integrity_intents (
  intent_id text primary key,
  need_id text references integrity_needs(need_id),
  actor_id text not null,
  actor_type text not null,
  beneficiary text not null,
  purpose text not null,
  target_outcome text not null,
  signal_refs text[] default '{}',
  identity_ref text references integrity_identities(identity_id),
  consent_ref text references integrity_consents(consent_id),
  intervention_options jsonb not null default '[]'::jsonb,
  selected_route text,
  risk_classification text check (risk_classification in ('LOW','MEDIUM','HIGH','CRITICAL','UNKNOWN')) default 'UNKNOWN',
  economic_path jsonb not null default '{}'::jsonb,
  recovery_path text,
  status text check (status in ('PROPOSED','ROUTED','ACTIVE','COMPLETED','BLOCKED','RECOVERING','FAILED')) default 'PROPOSED',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists integrity_routes (
  route_id text primary key,
  intent_id text references integrity_intents(intent_id),
  route_type text check (route_type in ('HUMAN','AGENT','MACHINE','PRODUCT','RESEARCH','GOVERNANCE')) not null,
  route_target text not null,
  safety_gate_result text check (safety_gate_result in ('PASS','WARN','FAIL','BLOCKED')) not null,
  routing_receipt jsonb not null default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists integrity_interventions (
  intervention_id text primary key,
  route_id text references integrity_routes(route_id),
  product_or_agent_ref text not null,
  action_taken text not null,
  status text check (status in ('PLANNED','EXECUTED','FAILED','REVERSED','BLOCKED')) default 'PLANNED',
  execution_receipt jsonb not null default '{}'::jsonb,
  executed_at timestamptz
);

create table if not exists integrity_evidence (
  evidence_id text primary key,
  related_object_type text not null,
  related_object_id text not null,
  evidence_type text not null,
  evidence_value text not null,
  source_ref text,
  hash text,
  confidence_score numeric check (confidence_score >= 0 and confidence_score <= 1),
  created_at timestamptz default now()
);

create table if not exists integrity_outcomes (
  outcome_id text primary key,
  intent_id text references integrity_intents(intent_id),
  intervention_id text references integrity_interventions(intervention_id),
  outcome_statement text not null,
  metric_name text,
  metric_value numeric,
  target_value numeric,
  evidence_ref text,
  economic_result jsonb not null default '{}'::jsonb,
  status text check (status in ('UNMEASURED','IMPROVED','UNCHANGED','WORSE','INCONCLUSIVE')) default 'UNMEASURED',
  measured_at timestamptz default now()
);

create table if not exists integrity_governance_events (
  governance_event_id text primary key,
  intent_id text references integrity_intents(intent_id),
  governance_layer text default 'GCBAT',
  judgement text check (judgement in ('APPROVED','WARNED','BLOCKED','RECOVERY_REQUIRED','ESCALATED')) not null,
  reason text not null,
  standards_mapping jsonb not null default '{}'::jsonb,
  audit_receipt jsonb not null default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists integrity_recoveries (
  recovery_id text primary key,
  intent_id text references integrity_intents(intent_id),
  recovery_trigger text not null,
  recovery_action text not null,
  rollback_ref text,
  validation_result text check (validation_result in ('UNTESTED','PASS','FAIL','PARTIAL')) default 'UNTESTED',
  evidence_ref text,
  created_at timestamptz default now(),
  validated_at timestamptz
);

create table if not exists integrity_telemetry_events (
  telemetry_id text primary key,
  loop_stage text not null,
  related_object_type text not null,
  related_object_id text not null,
  event_payload jsonb not null default '{}'::jsonb,
  continuity_key text not null,
  created_at timestamptz default now()
);

create table if not exists integrity_reality_ledger (
  ledger_id text primary key,
  task_id text not null,
  intent text not null,
  execution text not null,
  output text not null,
  status text check (status in ('REAL','PARTIAL','BLOCKED')) not null,
  evidence jsonb not null default '[]'::jsonb,
  gaps jsonb not null default '[]'::jsonb,
  score numeric check (score >= 0 and score <= 1),
  created_at timestamptz default now()
);

create index if not exists idx_integrity_signals_need on integrity_signals(need_id);
create index if not exists idx_integrity_intents_need on integrity_intents(need_id);
create index if not exists idx_integrity_routes_intent on integrity_routes(intent_id);
create index if not exists idx_integrity_evidence_related on integrity_evidence(related_object_type, related_object_id);
create index if not exists idx_integrity_telemetry_continuity on integrity_telemetry_events(continuity_key);
