-- Research Runtime v1 schema
-- Canonical chain: theme -> question -> uncertainty -> hypothesis -> activity -> experiment -> evidence -> asset -> product -> revenue -> claim -> reuse

create extension if not exists pgcrypto;

create table if not exists research_theme (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  status text not null default 'partial',
  owner text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists research_question (
  id uuid primary key default gen_random_uuid(),
  theme_id uuid not null references research_theme(id) on delete cascade,
  question text not null,
  why_it_matters text,
  status text not null default 'partial',
  created_at timestamptz not null default now()
);

create table if not exists research_uncertainty (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references research_question(id) on delete cascade,
  uncertainty_statement text not null,
  uncertainty_type text,
  routine_knowledge_boundary text,
  claim_strength text not null default 'medium',
  created_at timestamptz not null default now()
);

create table if not exists research_hypothesis (
  id uuid primary key default gen_random_uuid(),
  uncertainty_id uuid not null references research_uncertainty(id) on delete cascade,
  hypothesis text not null,
  expected_signal text,
  success_criteria text,
  created_at timestamptz not null default now()
);

create table if not exists research_activity (
  id uuid primary key default gen_random_uuid(),
  hypothesis_id uuid references research_hypothesis(id) on delete set null,
  title text not null,
  activity_type text,
  performed_by text,
  date_start date,
  date_end date,
  cost_trace text,
  created_at timestamptz not null default now()
);

create table if not exists research_experiment (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid references research_activity(id) on delete cascade,
  method text not null,
  inputs text,
  outputs text,
  result text,
  failed_attempts text,
  learning text,
  status text not null default 'partial',
  created_at timestamptz not null default now()
);

create table if not exists research_evidence (
  id uuid primary key default gen_random_uuid(),
  experiment_id uuid references research_experiment(id) on delete set null,
  source_type text not null,
  title text not null,
  uri text,
  sha256 text,
  evidence_grade text not null check (evidence_grade in ('A','B','C','D')),
  observed_at timestamptz,
  receipt text,
  created_at timestamptz not null default now()
);

create table if not exists research_asset (
  id uuid primary key default gen_random_uuid(),
  evidence_id uuid references research_evidence(id) on delete set null,
  title text not null,
  asset_type text not null,
  reuse_path text,
  commercial_path text,
  r_and_d_relevance text not null default 'medium',
  audit_grade text,
  status text not null default 'partial',
  created_at timestamptz not null default now()
);

create table if not exists research_product (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid references research_asset(id) on delete set null,
  title text not null,
  customer_problem text,
  customer_outcome text,
  offer text,
  status text not null default 'partial',
  created_at timestamptz not null default now()
);

create table if not exists research_revenue (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references research_product(id) on delete set null,
  revenue_model text,
  price_point text,
  buyer text,
  evidence_uri text,
  status text not null default 'partial',
  created_at timestamptz not null default now()
);

create table if not exists research_claim (
  id uuid primary key default gen_random_uuid(),
  uncertainty_id uuid references research_uncertainty(id) on delete set null,
  evidence_id uuid references research_evidence(id) on delete set null,
  claim_type text not null,
  claim_position text,
  confidence numeric(4,2) default 0.70,
  risk_notes text,
  status text not null default 'partial',
  created_at timestamptz not null default now()
);

create table if not exists research_reuse (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid references research_asset(id) on delete set null,
  reuse_context text not null,
  target_brand text,
  target_product text,
  value_score numeric(4,2) default 0.70,
  status text not null default 'partial',
  created_at timestamptz not null default now()
);

create table if not exists research_runtime_receipt (
  id uuid primary key default gen_random_uuid(),
  task_id text not null,
  status text not null,
  result text,
  evidence_type text,
  evidence_value text,
  score numeric(4,2),
  created_at timestamptz not null default now()
);

create or replace view research_dossier_view as
select
  t.id as theme_id,
  t.title as theme,
  q.question,
  u.uncertainty_statement,
  h.hypothesis,
  a.title as activity,
  e.method as experiment_method,
  ev.title as evidence_title,
  ev.evidence_grade,
  ra.title as asset_title,
  p.title as product_title,
  r.revenue_model,
  c.claim_type,
  rr.reuse_context
from research_theme t
left join research_question q on q.theme_id = t.id
left join research_uncertainty u on u.question_id = q.id
left join research_hypothesis h on h.uncertainty_id = u.id
left join research_activity a on a.hypothesis_id = h.id
left join research_experiment e on e.activity_id = a.id
left join research_evidence ev on ev.experiment_id = e.id
left join research_asset ra on ra.evidence_id = ev.id
left join research_product p on p.asset_id = ra.id
left join research_revenue r on r.product_id = p.id
left join research_claim c on c.uncertainty_id = u.id or c.evidence_id = ev.id
left join research_reuse rr on rr.asset_id = ra.id;
