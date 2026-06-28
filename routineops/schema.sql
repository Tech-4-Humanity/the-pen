-- RoutineOps P0 schema
-- Purpose: canonical runtime model for verified ambient routines.

create extension if not exists "pgcrypto";

create table if not exists routineops_households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  environment_type text not null check (environment_type in ('home','support_home','field_service','education','shared_space','other')),
  owner_ref text,
  consent_policy jsonb not null default '{}'::jsonb,
  status text not null default 'active' check (status in ('active','paused','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists routineops_profiles (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references routineops_households(id) on delete cascade,
  display_name text not null,
  role text not null check (role in ('parent','child','participant','support_worker','teacher','worker','manager','guest','admin','other')),
  permissions jsonb not null default '{}'::jsonb,
  consent_state text not null default 'unknown' check (consent_state in ('granted','declined','unknown','not_required')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists routineops_devices (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references routineops_households(id) on delete cascade,
  platform text not null default 'manual',
  external_ref text,
  display_name text not null,
  location text,
  role text,
  capabilities jsonb not null default '[]'::jsonb,
  last_seen_at timestamptz,
  lifecycle_status text not null default 'active' check (lifecycle_status in ('active','stale','missing','retired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists routineops_routines (
  id text primary key,
  display_name text not null,
  domain text not null,
  intent text not null,
  version integer not null default 1,
  risk_level text not null default 'low' check (risk_level in ('low','medium','high')),
  verification_rule jsonb not null default '{}'::jsonb,
  fallback_rule jsonb not null default '{}'::jsonb,
  status text not null default 'active' check (status in ('active','draft','retired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists routineops_routine_steps (
  id uuid primary key default gen_random_uuid(),
  routine_id text not null references routineops_routines(id) on delete cascade,
  step_order integer not null,
  step_type text not null,
  label text not null,
  payload jsonb not null default '{}'::jsonb,
  required boolean not null default true,
  created_at timestamptz not null default now(),
  unique (routine_id, step_order)
);

create table if not exists routineops_tags (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references routineops_households(id) on delete cascade,
  tag_uid text not null unique,
  label text not null,
  location text,
  routine_id text references routineops_routines(id),
  lifecycle_status text not null default 'active' check (lifecycle_status in ('active','stale','lost','retired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists routineops_runs (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references routineops_households(id) on delete set null,
  profile_id uuid references routineops_profiles(id) on delete set null,
  tag_id uuid references routineops_tags(id) on delete set null,
  routine_id text not null references routineops_routines(id),
  trigger_source text not null,
  context jsonb not null default '{}'::jsonb,
  status text not null default 'started' check (status in ('started','completed','partial','failed','cancelled')),
  confidence numeric(5,2) not null default 0,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  evidence jsonb not null default '{}'::jsonb
);

create table if not exists routineops_failures (
  id uuid primary key default gen_random_uuid(),
  run_id uuid references routineops_runs(id) on delete cascade,
  failure_class text not null,
  severity text not null default 'medium' check (severity in ('low','medium','high','critical')),
  detail text,
  recovery_action text,
  recovery_status text not null default 'open' check (recovery_status in ('open','retrying','recovered','manual_fallback','closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists routineops_evidence_packs (
  id uuid primary key default gen_random_uuid(),
  household_id uuid references routineops_households(id) on delete set null,
  period_start timestamptz not null,
  period_end timestamptz not null,
  export_type text not null check (export_type in ('json','csv','pdf')),
  summary jsonb not null default '{}'::jsonb,
  storage_ref text,
  created_at timestamptz not null default now()
);

create index if not exists idx_routineops_tags_uid on routineops_tags(tag_uid);
create index if not exists idx_routineops_runs_routine on routineops_runs(routine_id);
create index if not exists idx_routineops_runs_started on routineops_runs(started_at desc);
create index if not exists idx_routineops_failures_status on routineops_failures(recovery_status);
