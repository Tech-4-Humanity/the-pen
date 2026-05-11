-- Operational Object Graph Runtime Schema
-- Purpose: canonical operational reality substrate for Factor, Holo-Org, MRI, Command Centre, and deployment packs.

create schema if not exists oog;

create table if not exists oog.operational_objects (
  object_id uuid primary key default gen_random_uuid(),
  object_type text not null,
  canonical_name text not null,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  confidence_score numeric(5,2) not null default 0.50 check (confidence_score >= 0 and confidence_score <= 1),
  source_system text not null,
  external_ref text,
  consent_state text not null default 'UNKNOWN',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (object_type, source_system, external_ref)
);

create table if not exists oog.operational_edges (
  edge_id uuid primary key default gen_random_uuid(),
  from_object_id uuid not null references oog.operational_objects(object_id) on delete cascade,
  to_object_id uuid not null references oog.operational_objects(object_id) on delete cascade,
  edge_type text not null,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  confidence_score numeric(5,2) not null default 0.50 check (confidence_score >= 0 and confidence_score <= 1),
  evidence_ref text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (from_object_id, to_object_id, edge_type)
);

create table if not exists oog.operational_events (
  event_id uuid primary key default gen_random_uuid(),
  object_id uuid references oog.operational_objects(object_id) on delete set null,
  event_type text not null,
  event_time timestamptz not null default now(),
  source_system text not null,
  actor_ref text,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  evidence_ref text,
  created_at timestamptz not null default now()
);

create table if not exists oog.evidence_registry (
  evidence_id uuid primary key default gen_random_uuid(),
  evidence_type text not null,
  source_system text not null,
  source_uri text,
  source_hash text,
  object_id uuid references oog.operational_objects(object_id) on delete set null,
  event_id uuid references oog.operational_events(event_id) on delete set null,
  evidence_summary text not null,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists oog.factor_memory (
  memory_id uuid primary key default gen_random_uuid(),
  object_id uuid references oog.operational_objects(object_id) on delete cascade,
  memory_type text not null,
  memory_text text not null,
  confidence_score numeric(5,2) not null default 0.50 check (confidence_score >= 0 and confidence_score <= 1),
  evidence_id uuid references oog.evidence_registry(evidence_id) on delete set null,
  valid_from timestamptz not null default now(),
  valid_to timestamptz,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists oog.work_queue (
  work_id uuid primary key default gen_random_uuid(),
  object_id uuid references oog.operational_objects(object_id) on delete set null,
  work_type text not null,
  priority int not null default 50,
  owner_role text not null default 'agent_runtime',
  trigger_ref text,
  action_payload jsonb not null default '{}'::jsonb,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  next_action text not null,
  due_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists oog.deployment_packs (
  pack_id uuid primary key default gen_random_uuid(),
  pack_name text not null unique,
  target_customer text not null,
  object_types text[] not null default '{}',
  evidence_requirements text[] not null default '{}',
  workflows_triggered text[] not null default '{}',
  revenue_path text not null,
  success_metric text not null,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists oog.reality_ledger (
  ledger_id uuid primary key default gen_random_uuid(),
  task_id text not null,
  intent text not null,
  execution text not null,
  output text not null,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED')),
  evidence jsonb not null default '{}'::jsonb,
  gaps text[] not null default '{}',
  next_action text not null,
  score numeric(5,2) not null default 0.00,
  created_at timestamptz not null default now()
);

create index if not exists operational_objects_type_status_idx on oog.operational_objects(object_type, status);
create index if not exists operational_events_object_time_idx on oog.operational_events(object_id, event_time desc);
create index if not exists evidence_registry_object_idx on oog.evidence_registry(object_id);
create index if not exists work_queue_status_priority_idx on oog.work_queue(status, priority desc);
create index if not exists factor_memory_object_idx on oog.factor_memory(object_id);

create or replace view oog.command_centre_runtime_status as
select
  (select count(*) from oog.operational_objects) as object_count,
  (select count(*) from oog.operational_objects where status = 'REAL') as real_objects,
  (select count(*) from oog.operational_objects where status = 'PARTIAL') as partial_objects,
  (select count(*) from oog.operational_objects where status = 'BLOCKED') as blocked_objects,
  (select count(*) from oog.evidence_registry) as evidence_count,
  (select count(*) from oog.work_queue where status <> 'REAL') as open_work_items,
  (select count(*) from oog.deployment_packs) as deployment_pack_count,
  now() as measured_at;

insert into oog.deployment_packs (pack_name, target_customer, object_types, evidence_requirements, workflows_triggered, revenue_path, success_metric, status)
values
  ('Factor Accounting + R&D', 'accountants, R&D advisers, SMEs', array['organisation','financial_event','document','project','outcome'], array['invoice','bank_feed','claim_evidence','project_record'], array['evidence_pack','rd_claim_review','commercial_meaning_extraction'], 'subscription plus advisory uplift', 'validated evidence packs and measurable claim readiness', 'PARTIAL'),
  ('AI4Tradies', 'field service businesses and trades', array['person','organisation','task','communication','financial_event'], array['job_record','quote','invoice','customer_message'], array['job_triage','quote_followup','cash_collection'], 'monthly ops pack plus implementation services', 'faster quoting and reduced admin leakage', 'PARTIAL'),
  ('WorkFamilyAI', 'workforce leaders and families', array['person','role','communication','risk','outcome'], array['role_map','communication_trace','support_record'], array['role_support','family_workflow','escalation'], 'licence plus workplace support services', 'reduced coordination friction', 'PARTIAL'),
  ('ConsentX', 'regulated organisations', array['person','consent_state','event','risk','evidence'], array['consent_record','policy_reference','decision_trace'], array['consent_check','incident_response','audit_pack'], 'governance subscription and compliance packs', 'audit-ready consent evidence', 'PARTIAL'),
  ('Outcome Ready', 'providers, practitioners, participants', array['person','outcome','document','risk','task'], array['plan','progress_note','claim_evidence'], array['readiness_check','evidence_review','provider_ops'], 'subscription plus readiness packs', 'claim and operational readiness improvement', 'PARTIAL'),
  ('AI Sweet Spots', 'research and capability teams', array['person','signal','outcome','research','evidence'], array['survey','assessment','benchmark'], array['capability_profile','research_pack','market_signal'], 'research products and advisory', 'validated capability maps', 'PARTIAL')
on conflict (pack_name) do nothing;

insert into oog.reality_ledger (task_id, intent, execution, output, status, evidence, gaps, next_action, score)
values (
  'operational-object-graph-schema-v1',
  'Create canonical runtime schema for operational reality substrate',
  'SQL schema authored and committed for Bridge/Supabase execution',
  'operational-object-graph/01_operational-object-graph-schema.sql',
  'PARTIAL',
  jsonb_build_object('evidence_type','commit_pending_runtime_execution'),
  array['not yet executed against Supabase','no live runtime smoke test','no Command Centre widget read yet'],
  'Execute schema through Bridge SQL executor and capture runtime receipt',
  0.84
);
