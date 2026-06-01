-- Research Runtime Schema v1.0
-- Purpose: make dossiers generated views over an object graph, not static documents.

create table if not exists research_theme (
  id text primary key,
  name text not null,
  description text,
  owner text,
  status text not null default 'PARTIAL',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists research_question (
  id text primary key,
  theme_id text references research_theme(id),
  question text not null,
  customer_problem text,
  business_value text,
  owner text,
  status text not null default 'PARTIAL',
  created_at timestamptz not null default now()
);

create table if not exists research_uncertainty (
  id text primary key,
  question_id text references research_question(id),
  uncertainty_statement text not null,
  uncertainty_type text,
  why_not_routine text,
  tax_relevance text default 'UNASSESSED',
  owner text,
  status text not null default 'PARTIAL',
  created_at timestamptz not null default now()
);

create table if not exists research_hypothesis (
  id text primary key,
  uncertainty_id text references research_uncertainty(id),
  hypothesis text not null,
  expected_signal text,
  success_criteria text,
  owner text,
  status text not null default 'PARTIAL',
  created_at timestamptz not null default now()
);

create table if not exists research_activity (
  id text primary key,
  hypothesis_id text references research_hypothesis(id),
  activity_name text not null,
  activity_type text,
  date_range text,
  people_involved text,
  cost_trace text,
  owner text,
  status text not null default 'PARTIAL',
  created_at timestamptz not null default now()
);

create table if not exists research_experiment (
  id text primary key,
  activity_id text references research_activity(id),
  method text not null,
  inputs text,
  outputs text,
  result text,
  failed_attempts text,
  learning text,
  owner text,
  status text not null default 'PARTIAL',
  created_at timestamptz not null default now()
);

create table if not exists research_evidence (
  id text primary key,
  experiment_id text references research_experiment(id),
  evidence_type text not null,
  source_uri text,
  claim_supported text,
  evidence_grade text,
  sha256 text,
  receipt text,
  date_observed timestamptz default now(),
  owner text,
  status text not null default 'PARTIAL'
);

create table if not exists research_asset (
  id text primary key,
  evidence_id text references research_evidence(id),
  asset_name text not null,
  asset_type text,
  origin_story text,
  reuse_path text,
  commercial_path text,
  tax_relevance text,
  audit_grade text,
  owner text,
  status text not null default 'PARTIAL',
  created_at timestamptz not null default now()
);

create table if not exists research_product (
  id text primary key,
  asset_id text references research_asset(id),
  product_name text not null,
  customer_segment text,
  offer text,
  first_value_moment text,
  trust_boundary text,
  owner text,
  status text not null default 'PARTIAL'
);

create table if not exists research_revenue (
  id text primary key,
  product_id text references research_product(id),
  revenue_model text,
  pricing_note text,
  economic_value text,
  owner text,
  status text not null default 'PARTIAL'
);

create table if not exists research_claim (
  id text primary key,
  evidence_id text references research_evidence(id),
  claim_type text,
  claim_position text,
  confidence text,
  cost_trace text,
  audit_note text,
  owner text,
  status text not null default 'PARTIAL'
);

create table if not exists research_reuse (
  id text primary key,
  asset_id text references research_asset(id),
  target_brand text,
  target_product text,
  reuse_mode text,
  propagation_note text,
  owner text,
  status text not null default 'PARTIAL'
);

create or replace view research_dossier_v1 as
select
  t.id as theme_id,
  t.name as theme_name,
  q.id as question_id,
  q.question,
  q.customer_problem,
  q.business_value,
  u.id as uncertainty_id,
  u.uncertainty_statement,
  u.why_not_routine,
  h.id as hypothesis_id,
  h.hypothesis,
  h.success_criteria,
  a.id as activity_id,
  a.activity_name,
  a.date_range,
  a.people_involved,
  x.id as experiment_id,
  x.method,
  x.result,
  x.failed_attempts,
  x.learning,
  e.id as evidence_id,
  e.evidence_type,
  e.source_uri,
  e.evidence_grade,
  r.id as asset_id,
  r.asset_name,
  r.asset_type,
  r.origin_story,
  r.commercial_path,
  p.id as product_id,
  p.product_name,
  p.customer_segment,
  p.offer,
  v.revenue_model,
  c.claim_type,
  c.claim_position,
  c.confidence,
  rr.target_brand,
  rr.target_product,
  rr.reuse_mode
from research_theme t
left join research_question q on q.theme_id = t.id
left join research_uncertainty u on u.question_id = q.id
left join research_hypothesis h on h.uncertainty_id = u.id
left join research_activity a on a.hypothesis_id = h.id
left join research_experiment x on x.activity_id = a.id
left join research_evidence e on e.experiment_id = x.id
left join research_asset r on r.evidence_id = e.id
left join research_product p on p.asset_id = r.id
left join research_revenue v on v.product_id = p.id
left join research_claim c on c.evidence_id = e.id
left join research_reuse rr on rr.asset_id = r.id;
