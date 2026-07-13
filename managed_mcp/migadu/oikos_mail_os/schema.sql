create extension if not exists pgcrypto;

create table if not exists mail_registry_tables (
  table_name text primary key,
  purpose text not null,
  owner text not null default 'Signal System',
  lifecycle_state text not null default 'active',
  version text not null,
  updated_at timestamptz not null default now()
);

create table if not exists mailbox_profiles (
  id text primary key,
  mailbox_type text not null,
  folder_template text not null,
  signature_template text,
  autoresponse_template text,
  owner text,
  risk_class text not null default 'standard',
  lifecycle_state text not null default 'active',
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists mailbox_endpoints (
  id uuid primary key default gen_random_uuid(),
  address text not null unique,
  domain text not null,
  endpoint_type text not null,
  profile_id text references mailbox_profiles(id),
  business_owner text,
  technical_owner text,
  agent_name text,
  lifecycle_state text not null default 'planned',
  source_system text not null default 'migadu',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists folder_templates (
  id text primary key,
  folders jsonb not null,
  version text not null,
  created_at timestamptz not null default now()
);

create table if not exists signature_templates (
  id text primary key,
  plain_template text not null,
  html_template text not null,
  required_fields jsonb not null default '[]'::jsonb,
  version text not null,
  created_at timestamptz not null default now()
);

create table if not exists autoresponse_templates (
  id text primary key,
  subject_template text not null,
  plain_template text not null,
  html_template text,
  loop_guard boolean not null default true,
  conditions jsonb not null default '{}'::jsonb,
  version text not null,
  created_at timestamptz not null default now()
);

create table if not exists mail_rules (
  id text primary key,
  priority integer not null default 100,
  match_expression jsonb not null,
  destination_folder text,
  workflow_id text,
  close_condition text,
  enabled boolean not null default true,
  version text not null,
  created_at timestamptz not null default now()
);

create table if not exists workflow_templates (
  id text primary key,
  steps jsonb not null,
  authority_class text not null default 'controlled_write',
  recovery_policy jsonb not null default '{}'::jsonb,
  version text not null,
  created_at timestamptz not null default now()
);

create table if not exists mail_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  endpoint_address text,
  source_message_id text,
  payload jsonb not null default '{}'::jsonb,
  correlation_id text,
  status text not null default 'received',
  created_at timestamptz not null default now()
);

create table if not exists mail_test_runs (
  id uuid primary key default gen_random_uuid(),
  run_id text not null unique,
  scope text not null,
  result text not null,
  counts jsonb not null default '{}'::jsonb,
  evidence jsonb not null default '{}'::jsonb,
  started_at timestamptz not null,
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists mail_runtime_receipts (
  id uuid primary key default gen_random_uuid(),
  run_id text not null,
  operation text not null,
  truth_state text not null check (truth_state in ('REAL','PARTIAL','BLOCKED','ASPIRATIONAL')),
  before_hash text,
  after_hash text,
  trace_id text,
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists mail_runtime_failures (
  id uuid primary key default gen_random_uuid(),
  run_id text not null,
  stage text not null,
  error_class text,
  error_message text not null,
  recovery_action text,
  status text not null default 'open',
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create index if not exists idx_mailbox_endpoints_domain on mailbox_endpoints(domain);
create index if not exists idx_mail_events_status on mail_events(status);
create index if not exists idx_mail_receipts_run on mail_runtime_receipts(run_id);
create index if not exists idx_mail_failures_status on mail_runtime_failures(status);

insert into mail_registry_tables(table_name,purpose,version) values
('mailbox_profiles','Inheritance profiles for all mailbox variants','1.0.0'),
('mailbox_endpoints','Canonical mailbox, alias, identity, forwarder and catchall inventory','1.0.0'),
('folder_templates','Folder hierarchy definitions','1.0.0'),
('signature_templates','Reusable plain and HTML signature blocks','1.0.0'),
('autoresponse_templates','Reusable guarded autoresponses','1.0.0'),
('mail_rules','Routing and workflow triggers','1.0.0'),
('workflow_templates','Reusable activity sequences','1.0.0'),
('mail_events','Event stream for incoming communications and system notifications','1.0.0'),
('mail_test_runs','Repeatable test execution evidence','1.0.0'),
('mail_runtime_receipts','Receipt-grade runtime evidence','1.0.0'),
('mail_runtime_failures','Quarantine and recovery queue','1.0.0')
on conflict (table_name) do update set purpose=excluded.purpose, version=excluded.version, updated_at=now();