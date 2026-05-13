-- Self-Employed OS schema migration
-- task_id: SEO-SELFEMP-OS-20260509-001
-- status: PARTIAL until executed by Bridge/Supabase

create table if not exists operator_segments (
  id text primary key,
  name text not null,
  slug text unique not null,
  parent_category text,
  audience_type text,
  regulatory_intensity integer check (regulatory_intensity between 1 and 5),
  admin_intensity integer check (admin_intensity between 1 and 5),
  ai_uplift_score numeric(4,2),
  market_priority integer,
  first_offer text,
  status text default 'BASE_REAL',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists operator_personas (
  id text primary key,
  segment_id text references operator_segments(id) on delete cascade,
  persona_name text not null,
  role_type text,
  business_stage text,
  pains text[],
  desired_outcomes text[],
  objections text[],
  buying_trigger text,
  pricing_sensitivity text,
  created_at timestamptz default now()
);

create table if not exists qualification_requirements (
  id text primary key,
  segment_id text references operator_segments(id) on delete cascade,
  trade_or_role text not null,
  jurisdiction text default 'AU',
  qualification_name text not null,
  qualification_type text,
  initial_or_renewal text,
  renewal_period_months integer,
  evidence_required text[],
  source_url text,
  confidence_state text default 'PARTIAL',
  reviewed_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists operator_modules (
  id text primary key,
  module_name text not null,
  module_slug text unique not null,
  layer text not null,
  description text,
  input_required text[],
  output_generated text[],
  reusable_across_segments boolean default true,
  monetisation_role text,
  evidence_required text[],
  created_at timestamptz default now()
);

create table if not exists operator_offers (
  id text primary key,
  offer_name text not null,
  slug text unique not null,
  target_segment text,
  price_low numeric,
  price_high numeric,
  currency text default 'AUD',
  billing_model text,
  included_modules text[],
  delivery_mode text,
  stripe_product_id text,
  landing_page_url text,
  status text default 'DRAFT',
  created_at timestamptz default now()
);

create table if not exists operator_workflows (
  id text primary key,
  workflow_name text not null,
  segment_id text references operator_segments(id) on delete set null,
  trigger_event text,
  steps_json jsonb not null default '[]'::jsonb,
  systems_involved text[],
  human_gate_required boolean default false,
  output_asset text,
  evidence_event text,
  status text default 'BASE_REAL',
  created_at timestamptz default now()
);

create table if not exists operator_evidence_events (
  id text primary key,
  operator_id text,
  segment_id text references operator_segments(id) on delete set null,
  module_id text references operator_modules(id) on delete set null,
  event_type text not null,
  evidence_type text not null,
  evidence_url text,
  classification text check (classification in ('REAL','PARTIAL','PRETEND','BLOCKED')) default 'PARTIAL',
  confidence_score numeric(4,2),
  created_at timestamptz default now()
);

create table if not exists self_employed_os_reality_ledger (
  task_id text primary key,
  intent text not null,
  execution text,
  output text,
  status text check (status in ('REAL','PARTIAL','PRETEND','BLOCKED')) not null,
  evidence jsonb not null default '[]'::jsonb,
  gaps text[],
  next_action text,
  elevation text,
  pressure_flags text[],
  score numeric(4,2),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

insert into self_employed_os_reality_ledger (
  task_id, intent, execution, output, status, evidence, gaps, next_action, elevation, pressure_flags, score
) values (
  'SEO-SELFEMP-OS-20260509-001',
  'Expand AI for Tradies into Self-Employed OS and wire it for Bridge execution',
  'Schema, seed, registry, widget, and bridge invocation files prepared in GitHub',
  'Executable Base REAL bundle for Bridge/Supabase/Command Centre runtime',
  'PARTIAL',
  '[{"type":"commit","value":"pending per file commit receipts"},{"type":"issue","value":"https://github.com/TML-4PM/the-pen/issues/68"}]'::jsonb,
  array['Supabase migration not yet executed','Seed inserts not yet runtime verified','Command Centre widget not yet rendered','Vercel landing page not yet changed','Stripe products not yet created'],
  'Bridge executor must run SQL, insert seeds, bind widget, return runtime receipt',
  'Base REAL to Runtime REAL promotion path for Self-Employed OS',
  array['Do not call production live until Vercel/Supabase receipts exist','Avoid generic SaaS drift'],
  9.20
) on conflict (task_id) do update set
  execution = excluded.execution,
  output = excluded.output,
  status = excluded.status,
  evidence = excluded.evidence,
  gaps = excluded.gaps,
  next_action = excluded.next_action,
  elevation = excluded.elevation,
  pressure_flags = excluded.pressure_flags,
  score = excluded.score,
  updated_at = now();
