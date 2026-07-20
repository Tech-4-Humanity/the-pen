create schema if not exists knowledge_runtime;

create table if not exists knowledge_runtime.translation_profiles (
  profile_id uuid primary key default gen_random_uuid(),
  profile_key text not null unique,
  profile_version text not null,
  output_media_type text not null,
  instructions jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.translation_runs (
  run_id uuid primary key default gen_random_uuid(),
  external_run_id text not null unique,
  source_cko_id text not null,
  profile_key text not null,
  status text not null,
  source_sha256 text,
  output_sha256 text,
  error jsonb,
  metrics jsonb not null default '{}'::jsonb,
  started_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists knowledge_runtime.translation_outputs (
  output_id uuid primary key default gen_random_uuid(),
  run_id uuid not null references knowledge_runtime.translation_runs(run_id) on delete cascade,
  source_cko_id text not null,
  profile_key text not null,
  output_payload jsonb not null,
  output_sha256 text not null,
  lifecycle_state text not null default 'validated',
  created_at timestamptz not null default now(),
  unique(source_cko_id, profile_key, output_sha256)
);

create table if not exists knowledge_runtime.translation_telemetry (
  telemetry_id uuid primary key default gen_random_uuid(),
  run_id uuid not null references knowledge_runtime.translation_runs(run_id) on delete cascade,
  event_type text not null,
  details jsonb not null default '{}'::jsonb,
  event_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.translation_receipts (
  receipt_id uuid primary key default gen_random_uuid(),
  run_id uuid not null references knowledge_runtime.translation_runs(run_id) on delete cascade,
  status text not null,
  evidence jsonb not null,
  receipt_sha256 text not null,
  created_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.validation_rules (
  rule_id uuid primary key default gen_random_uuid(),
  rule_key text not null unique,
  rule_version text not null,
  severity text not null,
  rule_definition jsonb not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.validation_runs (
  validation_run_id uuid primary key default gen_random_uuid(),
  target_type text not null,
  target_id text not null,
  status text not null,
  decision text not null,
  findings jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.policy_rules (
  policy_id uuid primary key default gen_random_uuid(),
  policy_key text not null unique,
  policy_version text not null,
  policy_definition jsonb not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.policy_decisions (
  decision_id uuid primary key default gen_random_uuid(),
  policy_key text not null,
  target_type text not null,
  target_id text not null,
  decision text not null,
  rationale jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.relationship_types (
  relationship_type text primary key,
  inverse_type text,
  transitive boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.cko_relationships (
  relationship_id uuid primary key default gen_random_uuid(),
  source_id text not null,
  relationship_type text not null references knowledge_runtime.relationship_types(relationship_type),
  target_id text not null,
  evidence jsonb not null default '{}'::jsonb,
  relationship_sha256 text not null,
  created_at timestamptz not null default now(),
  unique(source_id, relationship_type, target_id)
);

create table if not exists knowledge_runtime.search_index (
  index_id uuid primary key default gen_random_uuid(),
  object_type text not null,
  object_id text not null,
  title text,
  search_text text not null,
  metadata jsonb not null default '{}'::jsonb,
  indexed_at timestamptz not null default now(),
  unique(object_type, object_id)
);

create index if not exists search_index_fts_idx
  on knowledge_runtime.search_index
  using gin (to_tsvector('english', search_text));

create table if not exists knowledge_runtime.memory_registry (
  memory_id uuid primary key default gen_random_uuid(),
  memory_key text not null unique,
  source_ids jsonb not null default '[]'::jsonb,
  summary jsonb not null default '{}'::jsonb,
  lifecycle_state text not null default 'active',
  refreshed_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.ingestion_events (
  event_id uuid primary key default gen_random_uuid(),
  idempotency_key text not null unique,
  source_system text not null,
  event_type text not null,
  payload jsonb not null,
  status text not null default 'QUEUED',
  attempt_count integer not null default 0,
  max_attempts integer not null default 3,
  error jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists knowledge_runtime.agent_work_items (
  work_item_id uuid primary key default gen_random_uuid(),
  event_id uuid references knowledge_runtime.ingestion_events(event_id),
  work_type text not null,
  status text not null default 'QUEUED',
  validation_state text not null,
  payload jsonb not null,
  receipt jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into knowledge_runtime.relationship_types(relationship_type, inverse_type, transitive)
values
  ('derived_from','has_derivative',false),
  ('translated_to','translated_from',false),
  ('validated_by','validates',false),
  ('depends_on','required_by',true),
  ('supersedes','superseded_by',true)
on conflict (relationship_type) do nothing;

insert into knowledge_runtime.translation_profiles(profile_key, profile_version, output_media_type, instructions)
values
  ('exec-summary-v1','1.0.0','application/json','{"purpose":"executive briefing","max_words":450}'::jsonb),
  ('sales-catalog-v1','1.0.0','application/json','{"purpose":"sales package catalogue"}'::jsonb),
  ('website-pricing-v1','1.0.0','application/json','{"purpose":"website pricing payload"}'::jsonb),
  ('compliance-safe-v1','1.0.0','application/json','{"purpose":"disclaimer and scope-safe output"}'::jsonb),
  ('partner-summary-v1','1.0.0','application/json','{"purpose":"partner proposal summary"}'::jsonb),
  ('audit-summary-v1','1.0.0','application/json','{"purpose":"audit evidence summary"}'::jsonb)
on conflict (profile_key) do update set
  profile_version=excluded.profile_version,
  output_media_type=excluded.output_media_type,
  instructions=excluded.instructions,
  active=true;

insert into knowledge_runtime.validation_rules(rule_key, rule_version, severity, rule_definition)
values
  ('require-source-lineage','1.0.0','critical','{"field":"source_cko_id","operator":"present"}'::jsonb),
  ('require-output-hash','1.0.0','critical','{"field":"output_sha256","operator":"sha256"}'::jsonb),
  ('require-pricing-disclaimer','1.0.0','high','{"profiles":["sales-catalog-v1","website-pricing-v1"],"contains":"indicative"}'::jsonb),
  ('prohibit-guaranteed-compliance','1.0.0','critical','{"prohibited_phrases":["guaranteed compliance","guarantees AUSTRAC compliance"]}'::jsonb),
  ('detect-pii','1.0.0','high','{"classes":["email","phone","dob","address"]}'::jsonb),
  ('detect-stale-evidence','1.0.0','medium','{"max_age_days":365}'::jsonb)
on conflict (rule_key) do update set
  rule_version=excluded.rule_version,
  severity=excluded.severity,
  rule_definition=excluded.rule_definition,
  active=true;

alter table knowledge_runtime.translation_profiles enable row level security;
alter table knowledge_runtime.translation_runs enable row level security;
alter table knowledge_runtime.translation_outputs enable row level security;
alter table knowledge_runtime.translation_telemetry enable row level security;
alter table knowledge_runtime.translation_receipts enable row level security;
alter table knowledge_runtime.validation_rules enable row level security;
alter table knowledge_runtime.validation_runs enable row level security;
alter table knowledge_runtime.policy_rules enable row level security;
alter table knowledge_runtime.policy_decisions enable row level security;
alter table knowledge_runtime.relationship_types enable row level security;
alter table knowledge_runtime.cko_relationships enable row level security;
alter table knowledge_runtime.search_index enable row level security;
alter table knowledge_runtime.memory_registry enable row level security;
alter table knowledge_runtime.ingestion_events enable row level security;
alter table knowledge_runtime.agent_work_items enable row level security;

revoke all on all tables in schema knowledge_runtime from anon, authenticated;