-- Runtime Capability Registry 1.0
-- Purpose: persist connector/capability truth so sessions do not start blind.

create extension if not exists pgcrypto;

create table if not exists public.t4h_connector_registry (
  connector_id text primary key,
  connector_name text not null,
  owner text not null default 'troy.latter',
  required_default boolean not null default false,
  required_for text[] not null default '{}',
  status text not null default 'UNKNOWN' check (status in ('UNKNOWN','LIVE','DEGRADED','BLOCKED','ABSENT')),
  last_healthcheck_at timestamptz,
  last_success_at timestamptz,
  last_failure_at timestamptz,
  failure_class text,
  failure_reason text,
  repair_authority text not null default 'bridge_if_authorised',
  repair_attempts integer not null default 0,
  evidence_uri text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.t4h_runtime_capability (
  capability_id text primary key,
  connector_id text not null references public.t4h_connector_registry(connector_id) on delete cascade,
  capability_name text not null,
  capability_family text not null,
  status text not null default 'UNKNOWN' check (status in ('UNKNOWN','LIVE','DEGRADED','BLOCKED','ABSENT')),
  required_default boolean not null default false,
  required_for text[] not null default '{}',
  confidence numeric(5,2) not null default 0 check (confidence >= 0 and confidence <= 100),
  last_verified_at timestamptz,
  last_success_at timestamptz,
  last_failure_at timestamptz,
  failure_reason text,
  evidence_type text,
  evidence_value text,
  raw_result jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(connector_id, capability_name)
);

create table if not exists public.t4h_connector_healthcheck_log (
  healthcheck_id uuid primary key default gen_random_uuid(),
  connector_id text not null references public.t4h_connector_registry(connector_id) on delete cascade,
  run_id text not null,
  status text not null check (status in ('LIVE','DEGRADED','BLOCKED','ABSENT')),
  checked_at timestamptz not null default now(),
  latency_ms integer,
  evidence_type text,
  evidence_value text,
  remediation_action text,
  raw_result jsonb not null default '{}'::jsonb
);

create table if not exists public.t4h_session_bootstrap_log (
  bootstrap_id uuid primary key default gen_random_uuid(),
  session_label text,
  started_at timestamptz not null default now(),
  runtime_profile text not null default 'troy-default',
  required_connectors text[] not null default '{}',
  live_connectors text[] not null default '{}',
  degraded_connectors text[] not null default '{}',
  blocked_connectors text[] not null default '{}',
  absent_connectors text[] not null default '{}',
  total_capabilities integer not null default 0,
  live_capabilities integer not null default 0,
  degraded_capabilities integer not null default 0,
  blocked_capabilities integer not null default 0,
  readiness_score numeric(5,2) not null default 0,
  overall_status text not null check (overall_status in ('REAL','PARTIAL','BLOCKED')),
  evidence_uri text,
  next_action text,
  raw_summary jsonb not null default '{}'::jsonb
);

create or replace function public.t4h_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_t4h_connector_registry_touch on public.t4h_connector_registry;
create trigger trg_t4h_connector_registry_touch
before update on public.t4h_connector_registry
for each row execute function public.t4h_touch_updated_at();

drop trigger if exists trg_t4h_runtime_capability_touch on public.t4h_runtime_capability;
create trigger trg_t4h_runtime_capability_touch
before update on public.t4h_runtime_capability
for each row execute function public.t4h_touch_updated_at();

create or replace view public.t4h_runtime_capability_status_v as
select
  count(*)::int as total_capabilities,
  count(*) filter (where status = 'LIVE')::int as live_capabilities,
  count(*) filter (where status = 'DEGRADED')::int as degraded_capabilities,
  count(*) filter (where status = 'BLOCKED')::int as blocked_capabilities,
  count(*) filter (where status = 'ABSENT')::int as absent_capabilities,
  case when count(*) = 0 then 0
       else round((count(*) filter (where status = 'LIVE')::numeric / count(*)::numeric) * 100, 2)
  end as readiness_score,
  case
    when count(*) filter (where required_default and status in ('BLOCKED','ABSENT','UNKNOWN')) > 0 then 'BLOCKED'
    when count(*) filter (where status in ('DEGRADED','UNKNOWN')) > 0 then 'PARTIAL'
    else 'REAL'
  end as overall_status
from public.t4h_runtime_capability;

insert into public.t4h_connector_registry (connector_id, connector_name, required_default, required_for, status)
values
  ('github','GitHub',true,array['spine','code','issues','receipts'],'UNKNOWN'),
  ('bridge','Bridge',true,array['execution','receipts','repair'],'UNKNOWN'),
  ('supabase','Supabase',true,array['state','ledger','widgets'],'UNKNOWN'),
  ('google_drive','Google Drive',true,array['evidence','documents'],'UNKNOWN'),
  ('gmail','Gmail',false,array['messaging','evidence'],'UNKNOWN'),
  ('google_calendar','Google Calendar',false,array['scheduling'],'UNKNOWN'),
  ('vercel','Vercel',false,array['deployment','web'],'UNKNOWN'),
  ('stripe','Stripe',false,array['revenue','billing'],'UNKNOWN'),
  ('lovable','Lovable',false,array['prototype','front_end'],'UNKNOWN')
on conflict (connector_id) do update set
  connector_name = excluded.connector_name,
  required_default = excluded.required_default,
  required_for = excluded.required_for;

insert into public.t4h_runtime_capability (capability_id, connector_id, capability_name, capability_family, required_default, required_for)
values
  ('github_read','github','github_read','github',true,array['spine','inspection']),
  ('github_write','github','github_write','github',true,array['spine','artifacts']),
  ('issue_create','github','issue_create','github',true,array['spine','handoff']),
  ('issue_update','github','issue_update','github',true,array['spine','receipts']),
  ('bridge_execute','bridge','bridge_execute','bridge',true,array['runtime','execution']),
  ('bridge_receipt','bridge','bridge_receipt','bridge',true,array['reality_ledger']),
  ('supabase_write','supabase','supabase_write','supabase',true,array['state','ledger']),
  ('supabase_read','supabase','supabase_read','supabase',true,array['state','ledger']),
  ('drive_read','google_drive','drive_read','google_drive',true,array['evidence']),
  ('drive_write','google_drive','drive_write','google_drive',false,array['artifacts']),
  ('gmail_read','gmail','gmail_read','gmail',false,array['messaging']),
  ('gmail_send','gmail','gmail_send','gmail',false,array['messaging']),
  ('calendar_read','google_calendar','calendar_read','google_calendar',false,array['scheduling']),
  ('calendar_create','google_calendar','calendar_create','google_calendar',false,array['scheduling']),
  ('vercel_deploy','vercel','vercel_deploy','vercel',false,array['deployment']),
  ('stripe_health','stripe','stripe_health','stripe',false,array['revenue']),
  ('lovable_project_lookup','lovable','lovable_project_lookup','lovable',false,array['prototype'])
on conflict (capability_id) do update set
  connector_id = excluded.connector_id,
  capability_name = excluded.capability_name,
  capability_family = excluded.capability_family,
  required_default = excluded.required_default,
  required_for = excluded.required_for;
