-- Cost, Price, Resource, Agent, Service Limit and Telemetry Schema V1
-- Status: executable DDL draft. Apply via approved Supabase SQL executor.

create extension if not exists pgcrypto;

create table if not exists cost_centre_registry (
  cost_centre_id text primary key,
  name text not null,
  pillar text,
  business_id text,
  project_id text,
  domain_slug text,
  owner_type text default 'human',
  owner_id text,
  budget_status text default 'unknown',
  default_claim_category text default 'unknown_pending_review',
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists journey_stage_registry (
  journey_stage_id text primary key,
  stage_order int not null,
  stage_name text not null,
  default_claim_category text default 'unknown_pending_review',
  default_margin_floor numeric default 0.35,
  default_reality_gate text default 'PARTIAL',
  active boolean default true
);

create table if not exists resource_registry (
  resource_id uuid primary key default gen_random_uuid(),
  resource_type text not null,
  resource_name text not null,
  source_system text,
  source_ref text,
  s3_bucket text,
  s3_key text,
  repo_full_name text,
  repo_path text,
  supabase_schema text,
  supabase_table text,
  business_id text,
  project_id text,
  domain_slug text,
  cost_centre_id text references cost_centre_registry(cost_centre_id),
  journey_stage_id text references journey_stage_registry(journey_stage_id),
  owner_type text,
  owner_id text,
  data_class text default 'internal',
  retention_class text default 'standard',
  lifecycle_status text default 'candidate',
  sha256 text,
  evidence_ref text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  retired_at timestamptz
);

create unique index if not exists resource_registry_source_ref_idx on resource_registry(source_system, source_ref) where source_ref is not null;
create index if not exists resource_registry_cost_centre_idx on resource_registry(cost_centre_id);
create index if not exists resource_registry_business_idx on resource_registry(business_id);

create table if not exists service_limit_registry (
  service_limit_id text primary key,
  plan_code text not null,
  service_name text not null,
  included_agent_runs int default 0,
  included_model_tokens bigint default 0,
  included_storage_gb numeric default 0,
  included_uploads int default 0,
  included_pages int default 0,
  included_campaigns int default 0,
  included_contacts int default 0,
  included_reports int default 0,
  included_support_minutes int default 0,
  max_response_time_hours numeric,
  overage_model text default 'usage_based',
  overage_unit text,
  overage_price numeric default 0,
  hard_cap numeric,
  soft_cap numeric,
  active boolean default true
);

create table if not exists price_model_registry (
  price_model_id text primary key,
  model_type text not null,
  billing_frequency text,
  cost_basis text,
  wholesale_markup_pct numeric default 0.35,
  retail_markup_pct numeric default 1.50,
  minimum_margin_pct numeric default 0.60,
  setup_fee numeric default 0,
  recurring_fee numeric default 0,
  usage_fee_unit text,
  usage_fee_amount numeric default 0,
  active boolean default true
);

create table if not exists agent_price_book (
  agent_id text primary key,
  agent_family text,
  agent_name text,
  role_code text,
  role_level text,
  work_package_id text,
  default_model text,
  input_cost_per_1k numeric default 0,
  output_cost_per_1k numeric default 0,
  tool_cost_per_run numeric default 0,
  expected_runs_per_month int default 0,
  direct_cost_per_run numeric default 0,
  labour_equivalent_minutes numeric default 0,
  labour_equivalent_rate numeric default 150,
  labour_equivalent_cost numeric generated always as ((coalesce(labour_equivalent_minutes,0) / 60.0) * coalesce(labour_equivalent_rate,0)) stored,
  wholesale_price_per_run numeric default 0,
  retail_price_per_run numeric default 0,
  monthly_wholesale_price numeric default 0,
  monthly_retail_price numeric default 0,
  margin_floor numeric default 0.35,
  service_limit_id text references service_limit_registry(service_limit_id),
  overage_price numeric default 0,
  source_file text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists cost_event_ledger (
  cost_event_id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz default now(),
  event_type text not null,
  action text not null,
  resource_id uuid references resource_registry(resource_id),
  parent_resource_id uuid references resource_registry(resource_id),
  actor_type text,
  actor_id text,
  agent_id text references agent_price_book(agent_id),
  workflow_id text,
  campaign_id text,
  business_id text,
  project_id text,
  domain_slug text,
  cost_centre_id text references cost_centre_registry(cost_centre_id),
  journey_stage_id text references journey_stage_registry(journey_stage_id),
  quantity numeric default 1,
  unit text default 'event',
  unit_cost numeric default 0,
  direct_cost numeric default 0,
  model_input_tokens bigint default 0,
  model_output_tokens bigint default 0,
  model_cost numeric default 0,
  storage_gb_month numeric default 0,
  storage_cost numeric default 0,
  compute_seconds numeric default 0,
  compute_cost numeric default 0,
  labour_minutes numeric default 0,
  labour_rate numeric default 150,
  labour_cost numeric generated always as ((coalesce(labour_minutes,0) / 60.0) * coalesce(labour_rate,0)) stored,
  tool_cost numeric default 0,
  campaign_cost numeric default 0,
  payment_fee numeric default 0,
  total_cost numeric generated always as (
    coalesce(direct_cost,0) + coalesce(model_cost,0) + coalesce(storage_cost,0) + coalesce(compute_cost,0) + ((coalesce(labour_minutes,0) / 60.0) * coalesce(labour_rate,0)) + coalesce(tool_cost,0) + coalesce(campaign_cost,0) + coalesce(payment_fee,0)
  ) stored,
  wholesale_price numeric default 0,
  retail_price numeric default 0,
  gross_margin numeric generated always as (coalesce(retail_price,0) - (coalesce(direct_cost,0) + coalesce(model_cost,0) + coalesce(storage_cost,0) + coalesce(compute_cost,0) + ((coalesce(labour_minutes,0) / 60.0) * coalesce(labour_rate,0)) + coalesce(tool_cost,0) + coalesce(campaign_cost,0) + coalesce(payment_fee,0))) stored,
  claimable_status text default 'unknown_pending_adviser',
  claim_category text default 'unknown_pending_review',
  capitalisation_flag boolean default false,
  reusable_ip_flag boolean default false,
  revenue_linked boolean default false,
  revenue_event_id text,
  evidence_ref text,
  reality_status text default 'PARTIAL',
  created_at timestamptz default now()
);

create index if not exists cost_event_ledger_business_idx on cost_event_ledger(business_id);
create index if not exists cost_event_ledger_agent_idx on cost_event_ledger(agent_id);
create index if not exists cost_event_ledger_campaign_idx on cost_event_ledger(campaign_id);
create index if not exists cost_event_ledger_cost_centre_idx on cost_event_ledger(cost_centre_id);

create table if not exists bridge_cost_binding_policy (
  policy_id text primary key,
  applies_to text not null,
  required boolean default true,
  default_cost_centre_id text,
  default_claim_category text default 'software_development',
  min_reality_status text default 'PARTIAL',
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists runtime_resource_inventory_runs (
  inventory_run_id uuid primary key default gen_random_uuid(),
  source_system text not null,
  source_scope text,
  dry_run boolean default true,
  resources_seen int default 0,
  resources_created int default 0,
  resources_updated int default 0,
  resources_failed int default 0,
  evidence_ref text,
  reality_status text default 'PARTIAL',
  started_at timestamptz default now(),
  completed_at timestamptz
);

create or replace function log_resource_cost_event()
returns trigger language plpgsql as $$
begin
  insert into cost_event_ledger (
    event_type, action, resource_id, business_id, project_id, domain_slug, cost_centre_id, journey_stage_id, actor_type, actor_id, direct_cost, claim_category, evidence_ref, reality_status
  ) values (
    case when tg_op = 'INSERT' then 'create' when tg_op = 'UPDATE' then 'update' when tg_op = 'DELETE' then 'delete' else lower(tg_op) end,
    lower(tg_op) || '_resource_registry',
    coalesce(new.resource_id, old.resource_id),
    coalesce(new.business_id, old.business_id),
    coalesce(new.project_id, old.project_id),
    coalesce(new.domain_slug, old.domain_slug),
    coalesce(new.cost_centre_id, old.cost_centre_id),
    coalesce(new.journey_stage_id, old.journey_stage_id),
    'system',
    'cost_trigger',
    0,
    'operations',
    coalesce(new.evidence_ref, old.evidence_ref),
    'PARTIAL'
  );
  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_resource_registry_cost_event on resource_registry;
create trigger trg_resource_registry_cost_event
after insert or update or delete on resource_registry
for each row execute function log_resource_cost_event();

create or replace view v_cost_by_business as
select business_id, count(*) events, sum(total_cost) total_cost, sum(retail_price) retail_price, sum(gross_margin) gross_margin
from cost_event_ledger
group by business_id;

create or replace view v_cost_by_journey_stage as
select journey_stage_id, count(*) events, sum(total_cost) total_cost, sum(retail_price) retail_price, sum(gross_margin) gross_margin
from cost_event_ledger
group by journey_stage_id;

create or replace view v_cost_by_agent_family as
select apb.agent_family, count(cel.*) events, sum(cel.total_cost) total_cost, sum(cel.retail_price) retail_price, sum(cel.gross_margin) gross_margin
from cost_event_ledger cel
left join agent_price_book apb on cel.agent_id = apb.agent_id
group by apb.agent_family;

create or replace view v_cost_by_campaign as
select campaign_id, count(*) events, sum(total_cost) total_cost, sum(retail_price) retail_price, sum(gross_margin) gross_margin
from cost_event_ledger
group by campaign_id;

create or replace view v_claimability_summary as
select claimable_status, claim_category, count(*) events, sum(total_cost) total_cost
from cost_event_ledger
group by claimable_status, claim_category;

create or replace view v_wholesale_retail_margin as
select cost_centre_id, count(*) events, sum(total_cost) total_cost, sum(wholesale_price) wholesale_price, sum(retail_price) retail_price, sum(gross_margin) gross_margin
from cost_event_ledger
group by cost_centre_id;

create or replace view v_drag_vs_reusable_ip as
select reusable_ip_flag, capitalisation_flag, count(*) events, sum(total_cost) total_cost, sum(retail_price) retail_value
from cost_event_ledger
group by reusable_ip_flag, capitalisation_flag;
