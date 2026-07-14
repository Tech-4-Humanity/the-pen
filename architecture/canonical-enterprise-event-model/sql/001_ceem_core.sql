create extension if not exists pgcrypto;

create table if not exists ceem_event (
  id uuid primary key default gen_random_uuid(),
  event_id text not null unique,
  event_key text not null unique,
  canonical_name text not null,
  display_name text,
  description text not null,
  event_family text not null,
  domain text not null,
  capability text,
  business_process text,
  lifecycle_stage text not null,
  status text not null default 'DRAFT' check (status in ('ASPIRATIONAL','DRAFT','PARTIAL','REAL','DEGRADED','BLOCKED','QUARANTINED','DEPRECATED','ARCHIVED')),
  version text not null,
  priority text default 'MEDIUM',
  criticality text default 'NON_CRITICAL',
  business_owner text not null,
  operational_owner text not null,
  technical_owner text,
  data_steward text,
  trigger_type text not null,
  source_system text not null,
  primary_actor_type text not null,
  primary_audience_type text not null,
  required_action_summary text not null,
  default_next_event_key text,
  exception_event_key text not null,
  evidence_required boolean not null default true,
  receipt_required boolean not null default true,
  ledger_required boolean not null default true,
  telemetry_required boolean not null default true,
  replay_required boolean not null default false,
  success_metric_key text not null,
  sla_seconds integer not null default 0 check (sla_seconds >= 0),
  security_classification text not null default 'INTERNAL',
  effective_at timestamptz not null default now(),
  review_at timestamptz not null,
  expires_at timestamptz,
  tags text[] not null default '{}',
  source_refs jsonb not null default '[]',
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists ceem_event_edge (
  id uuid primary key default gen_random_uuid(),
  from_event_key text not null references ceem_event(event_key),
  relationship_type text not null check (relationship_type in ('PRECEDES','SUCCEEDS','DEFAULT_NEXT','ALTERNATIVE','EXCEPTION','RETRY','ROLLBACK','RECOVERY','CANCELS','SUPERSEDES')),
  to_event_key text not null references ceem_event(event_key),
  condition_expression text,
  priority integer not null default 100,
  is_default boolean not null default false,
  status text not null default 'ACTIVE',
  unique (from_event_key, relationship_type, to_event_key, condition_expression)
);

create table if not exists ceem_event_rule (
  id uuid primary key default gen_random_uuid(),
  event_key text not null references ceem_event(event_key),
  rule_key text not null,
  rule_type text not null,
  expression text not null,
  failure_event_key text,
  priority integer not null default 100,
  enabled boolean not null default true,
  version text not null,
  unique(event_key, rule_key, version)
);

create table if not exists ceem_event_action (
  id uuid primary key default gen_random_uuid(),
  event_key text not null references ceem_event(event_key),
  action_key text not null,
  action_type text not null,
  executor_type text not null check (executor_type in ('HUMAN','AI_AGENT','SYSTEM','WORKFLOW')),
  executor_ref text not null,
  target_system text,
  workflow_ref text,
  approval_required boolean not null default false,
  approval_role text,
  timeout_seconds integer not null default 0,
  retry_policy jsonb not null default '{}',
  fallback_event_key text,
  rollback_event_key text,
  required boolean not null default true,
  sequence integer not null default 100,
  unique(event_key, action_key)
);

create table if not exists ceem_event_output (
  id uuid primary key default gen_random_uuid(),
  event_key text not null references ceem_event(event_key),
  output_key text not null,
  output_type text not null,
  channel text not null,
  template_ref text,
  recipient_role text not null,
  consent_basis text,
  language text default 'en-AU',
  delivery_sla_seconds integer not null default 0,
  required boolean not null default true,
  personalisation_fields text[] not null default '{}',
  accessibility_policy_ref text,
  unique(event_key, output_key)
);

create table if not exists ceem_evidence_policy (
  id uuid primary key default gen_random_uuid(),
  event_key text not null unique references ceem_event(event_key),
  evidence_types text[] not null default '{}',
  verification_method text not null,
  receipt_schema_ref text,
  ledger_target text,
  retention_days integer not null default 2555,
  immutable_required boolean not null default true,
  chain_of_custody_required boolean not null default false
);

create table if not exists ceem_metric (
  id uuid primary key default gen_random_uuid(),
  metric_key text not null unique,
  event_key text references ceem_event(event_key),
  name text not null,
  definition text not null,
  unit text not null,
  target_value numeric,
  warning_threshold numeric,
  critical_threshold numeric,
  source_system text not null,
  calculation_expression text,
  owner text not null,
  reporting_frequency text not null
);

create table if not exists ceem_runtime_event (
  occurrence_id uuid primary key default gen_random_uuid(),
  event_key text not null references ceem_event(event_key),
  event_version text not null,
  occurred_at timestamptz not null,
  received_at timestamptz not null default now(),
  actor_ref text,
  subject_ref text,
  organisation_ref text,
  correlation_id text not null,
  causation_id text,
  idempotency_key text not null,
  source_system text not null,
  payload jsonb not null,
  authority_ref text,
  status text not null default 'PARTIAL',
  verification_status text,
  receipt_ref text,
  ledger_ref text,
  telemetry_ref text,
  error jsonb,
  unique(source_system, idempotency_key)
);

create index if not exists ceem_event_family_idx on ceem_event(event_family, lifecycle_stage, status);
create index if not exists ceem_runtime_event_correlation_idx on ceem_runtime_event(correlation_id, occurred_at);
create index if not exists ceem_runtime_event_subject_idx on ceem_runtime_event(subject_ref, occurred_at);

create or replace function ceem_validate_event_for_activation(p_event_key text)
returns table(valid boolean, gaps text[]) language sql stable as $$
  select
    count(*) = 0 as valid,
    coalesce(array_agg(gap) filter (where gap is not null), '{}') as gaps
  from (
    select case when business_owner is null or business_owner = '' then 'missing_business_owner' end gap from ceem_event where event_key=p_event_key
    union all select case when operational_owner is null or operational_owner = '' then 'missing_operational_owner' end from ceem_event where event_key=p_event_key
    union all select case when exception_event_key is null or exception_event_key = '' then 'missing_exception_event' end from ceem_event where event_key=p_event_key
    union all select case when receipt_required and not exists(select 1 from ceem_evidence_policy p where p.event_key=p_event_key and p.receipt_schema_ref is not null) then 'missing_receipt_schema' end
    union all select case when not exists(select 1 from ceem_event_action a where a.event_key=p_event_key and a.required) then 'missing_required_action' end
  ) g where gap is not null;
$$;
