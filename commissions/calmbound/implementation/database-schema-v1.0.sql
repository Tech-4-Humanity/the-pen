-- CalmBound canonical database schema v1.0
-- PostgreSQL / Supabase-compatible reference implementation.
-- This file is published architecture, not evidence of execution against a live database.

create extension if not exists pgcrypto;

create table households (
  household_id uuid primary key default gen_random_uuid(),
  name text not null,
  timezone text not null default 'Australia/Sydney',
  status text not null default 'active' check (status in ('draft','active','paused','archived')),
  owner_person_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table people (
  person_id uuid primary key default gen_random_uuid(),
  display_name text not null,
  age_band text not null check (age_band in ('adult','young_adult','older_teen','early_teen','primary','young_child','unknown')),
  status text not null default 'active' check (status in ('invited','active','paused','removed')),
  created_at timestamptz not null default now()
);

alter table households add constraint households_owner_fk foreign key (owner_person_id) references people(person_id);

create table household_memberships (
  membership_id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(household_id) on delete cascade,
  person_id uuid not null references people(person_id) on delete cascade,
  role_type text not null,
  scope jsonb not null default '{}'::jsonb,
  status text not null default 'active' check (status in ('pending','active','expired','revoked','contested')),
  effective_at timestamptz not null default now(),
  expires_at timestamptz,
  evidence_refs jsonb not null default '[]'::jsonb,
  unique (household_id, person_id, role_type)
);

create table mode_definitions (
  mode_definition_id text not null,
  version text not null,
  name text not null,
  purpose text not null,
  definition jsonb not null,
  status text not null default 'active' check (status in ('draft','active','deprecated','retired')),
  created_at timestamptz not null default now(),
  primary key (mode_definition_id, version)
);

create table mode_instances (
  mode_instance_id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(household_id) on delete cascade,
  mode_definition_id text not null,
  mode_definition_version text not null,
  state text not null check (state in ('scheduled','active','paused','completed','failed','cancelled')),
  parameters jsonb not null default '{}'::jsonb,
  starts_at timestamptz not null,
  ends_at timestamptz,
  activated_by uuid references people(person_id),
  correlation_id uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  foreign key (mode_definition_id, mode_definition_version) references mode_definitions(mode_definition_id, version)
);

create table agreements (
  agreement_id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(household_id) on delete cascade,
  title text not null,
  plain_language text not null,
  version text not null,
  status text not null default 'active' check (status in ('draft','active','expired','revoked','superseded')),
  effective_at timestamptz not null default now(),
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create table permissions (
  permission_id uuid primary key default gen_random_uuid(),
  grantor_id uuid not null references people(person_id),
  grantee_id uuid not null references people(person_id),
  action text not null,
  object_type text not null,
  object_id text not null,
  scope jsonb not null,
  purpose text not null,
  conditions jsonb not null default '{}'::jsonb,
  status text not null default 'active' check (status in ('pending','active','expired','revoked','suspended','contested')),
  starts_at timestamptz not null,
  expires_at timestamptz,
  policy_version text not null,
  evidence_refs jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  revoked_at timestamptz,
  revocation_reason text
);

create table consents (
  consent_id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references people(person_id),
  grantor_id uuid not null references people(person_id),
  purpose text not null,
  scope jsonb not null,
  status text not null default 'active' check (status in ('pending','active','expired','revoked','renewal_due','contested')),
  starts_at timestamptz not null,
  expires_at timestamptz,
  policy_version text not null,
  jurisdiction text not null,
  age_suitability text not null,
  evidence_refs jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  revoked_at timestamptz,
  revocation_reason text
);

create table override_requests (
  override_id uuid primary key default gen_random_uuid(),
  mode_instance_id uuid not null references mode_instances(mode_instance_id) on delete cascade,
  requester_id uuid not null references people(person_id),
  reason text not null,
  requested_duration_minutes integer not null check (requested_duration_minutes between 1 and 1440),
  status text not null default 'pending' check (status in ('pending','approved','denied','expired','failed')),
  decided_by uuid references people(person_id),
  decided_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create table event_ledger (
  event_id uuid primary key,
  event_type text not null,
  event_version text not null,
  occurred_at timestamptz not null,
  recorded_at timestamptz not null default now(),
  source jsonb not null,
  actor jsonb not null,
  subject jsonb not null,
  object jsonb not null,
  action text not null,
  outcome jsonb not null,
  correlation_id uuid not null,
  causation_id uuid,
  policy_version text,
  model_version text,
  data_classification text not null,
  evidence_refs jsonb not null default '[]'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  integrity_hash text not null
);

create table evidence_objects (
  evidence_id uuid primary key default gen_random_uuid(),
  evidence_type text not null,
  source text not null,
  object_uri text,
  integrity_hash text not null,
  retention_policy_id text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz,
  status text not null default 'active' check (status in ('active','expired','deleted','quarantined'))
);

create table subscriptions (
  subscription_id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(household_id) on delete cascade,
  provider text not null,
  provider_customer_id text,
  provider_subscription_id text,
  plan text not null,
  status text not null check (status in ('pending','active','past_due','cancelled','ended')),
  entitlement_state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  unique (provider, provider_subscription_id)
);

create index idx_memberships_household on household_memberships(household_id);
create index idx_modes_household_state on mode_instances(household_id, state);
create index idx_permissions_grantee_status on permissions(grantee_id, status);
create index idx_consents_subject_status on consents(subject_id, status);
create index idx_events_correlation on event_ledger(correlation_id, occurred_at);
create index idx_events_type_time on event_ledger(event_type, occurred_at);

-- Reference RLS posture: deny browser access until authenticated policies are deliberately installed.
alter table households enable row level security;
alter table people enable row level security;
alter table household_memberships enable row level security;
alter table mode_instances enable row level security;
alter table agreements enable row level security;
alter table permissions enable row level security;
alter table consents enable row level security;
alter table override_requests enable row level security;
alter table event_ledger enable row level security;
alter table evidence_objects enable row level security;
alter table subscriptions enable row level security;

-- No permissive RLS policies are included by default. Access must be mediated by the runtime permission service.
