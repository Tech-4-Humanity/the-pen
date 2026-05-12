create extension if not exists pgcrypto;

create table if not exists signal_registry (
  signal_id uuid primary key default gen_random_uuid(),
  external_signal_key text unique not null,
  source_type text not null,
  source_name text not null,
  source_url text,
  headline text,
  raw_content text,
  industry text,
  region text,
  trust_score numeric default 0,
  current_state text default 'RAW_SIGNAL',
  monetisable boolean default false,
  urgency_score numeric default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists signal_entity (
  entity_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  entity_type text not null,
  entity_value text not null,
  confidence_score numeric default 0,
  created_at timestamptz default now()
);

create table if not exists signal_pressure (
  pressure_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  pressure_type text not null,
  pressure_score numeric not null,
  rationale text,
  created_at timestamptz default now()
);

create table if not exists signal_gap (
  gap_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  stakeholder_type text,
  gap_summary text not null,
  severity text,
  opportunity_score numeric default 0,
  created_at timestamptz default now()
);

create table if not exists signal_product_map (
  map_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  business_name text,
  product_name text,
  feature_name text,
  wrapper_name text,
  commercialisation_stage text default 'candidate',
  reuse_assets jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists signal_campaign (
  campaign_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  campaign_type text,
  audience text,
  campaign_name text,
  status text default 'draft',
  deployment_surface text,
  cta text,
  asset_payload jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists signal_telemetry (
  telemetry_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  metric_name text not null,
  metric_value numeric default 0,
  metric_unit text,
  observed_at timestamptz default now(),
  metadata jsonb default '{}'::jsonb
);

create table if not exists signal_revenue (
  revenue_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  revenue_type text,
  amount numeric default 0,
  currency text default 'AUD',
  attribution_status text default 'unproven',
  attribution_notes text,
  created_at timestamptz default now()
);

create table if not exists signal_state_transition (
  transition_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  from_state text,
  to_state text not null,
  transition_reason text,
  evidence_ref text,
  actor text default 'system',
  created_at timestamptz default now()
);

create table if not exists signal_runtime_ledger (
  ledger_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  status text not null,
  result text,
  evidence jsonb default '[]'::jsonb,
  gaps jsonb default '[]'::jsonb,
  next_action jsonb default '[]'::jsonb,
  elevation text,
  pressure_flags jsonb default '[]'::jsonb,
  score numeric default 0,
  created_at timestamptz default now()
);

create table if not exists daily_business_candidate (
  candidate_id uuid primary key default gen_random_uuid(),
  signal_id uuid references signal_registry(signal_id) on delete set null,
  candidate_date date default current_date,
  business_name text not null,
  business_type text default 'new_or_existing_surface',
  target_buyer text,
  pain_solved text,
  first_offer text,
  landing_surface text,
  revenue_path text,
  risk_summary text,
  launch_score numeric default 0,
  human_gate_status text default 'pending_yes_no',
  runtime_mode text default 'one_human_loop',
  created_at timestamptz default now()
);

create table if not exists market_intelligence_pod_task (
  task_id uuid primary key default gen_random_uuid(),
  pod_name text not null,
  signal_id uuid references signal_registry(signal_id) on delete cascade,
  task_summary text not null,
  task_state text default 'queued',
  owner_mode text default 'autonomous',
  evidence_ref text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create or replace function set_signal_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_signal_registry_updated_at on signal_registry;
create trigger trg_signal_registry_updated_at
before update on signal_registry
for each row execute function set_signal_updated_at();

create or replace function advance_signal_state(p_signal_id uuid, p_to_state text, p_reason text, p_evidence_ref text default null, p_actor text default 'system')
returns void as $$
declare
  v_from_state text;
begin
  select current_state into v_from_state from signal_registry where signal_id = p_signal_id;
  update signal_registry set current_state = p_to_state where signal_id = p_signal_id;
  insert into signal_state_transition(signal_id, from_state, to_state, transition_reason, evidence_ref, actor)
  values (p_signal_id, v_from_state, p_to_state, p_reason, p_evidence_ref, p_actor);
end;
$$ language plpgsql;

create index if not exists idx_signal_registry_state on signal_registry(current_state);
create index if not exists idx_signal_registry_industry on signal_registry(industry);
create index if not exists idx_signal_entity_signal on signal_entity(signal_id);
create index if not exists idx_signal_pressure_signal on signal_pressure(signal_id);
create index if not exists idx_signal_gap_signal on signal_gap(signal_id);
create index if not exists idx_signal_product_map_signal on signal_product_map(signal_id);
create index if not exists idx_signal_campaign_signal on signal_campaign(signal_id);
create index if not exists idx_daily_business_candidate_date on daily_business_candidate(candidate_date);
