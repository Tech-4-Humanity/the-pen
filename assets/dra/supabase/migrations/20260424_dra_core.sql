-- Drug Resilience Atlas core schema
-- Classification: executable migration asset, not yet runtime-proven until applied to Supabase.

create extension if not exists pgcrypto;

create table if not exists public.dra_sources (
  id uuid primary key default gen_random_uuid(),
  source_key text unique not null,
  title text not null,
  source_type text not null check (source_type in ('pdf','chat_thread','notion','github','site','paper','observation','other')),
  url text,
  citation text,
  evidence_status text not null default 'partial' check (evidence_status in ('real','partial','unverified','retired')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.dra_substances (
  id uuid primary key default gen_random_uuid(),
  substance_key text unique not null,
  name text not null,
  category text,
  short_description text,
  primary_pathways text[] not null default '{}',
  status text not null default 'active' check (status in ('draft','active','needs_review','retired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.dra_populations (
  id uuid primary key default gen_random_uuid(),
  population_key text unique not null,
  name text not null,
  lens_type text not null default 'neurotype',
  short_description text,
  status text not null default 'active' check (status in ('draft','active','needs_review','retired')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.dra_neurochemical_pathways (
  id uuid primary key default gen_random_uuid(),
  pathway_key text unique not null,
  name text not null,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.dra_observations (
  id uuid primary key default gen_random_uuid(),
  substance_id uuid not null references public.dra_substances(id),
  population_id uuid not null references public.dra_populations(id),
  source_id uuid references public.dra_sources(id),
  primary_neurochemical_pathway text,
  felt_deficit_or_state_sought text,
  in_use_effect text,
  crash_or_rebound_effect text,
  neurotype_specific_landing_pattern text,
  functional_gain text,
  functional_harm text,
  dependency_risk text check (dependency_risk in ('low','medium','high','unknown')) default 'unknown',
  cognitive_load_effect text,
  executive_function_effect text,
  emotional_volatility_effect text,
  harm_reduction_notes text,
  evidence_status text not null default 'partial' check (evidence_status in ('real','partial','unverified','contradicted','retired')),
  confidence_score numeric(4,2) default 0.50 check (confidence_score >= 0 and confidence_score <= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(substance_id, population_id, source_id)
);

create table if not exists public.dra_hypotheses (
  id uuid primary key default gen_random_uuid(),
  hypothesis_key text unique not null,
  title text not null,
  statement text not null,
  related_substance_id uuid references public.dra_substances(id),
  related_population_id uuid references public.dra_populations(id),
  status text not null default 'new' check (status in ('new','triaged','testing','supported','mixed','rejected','retired')),
  evidence_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.dra_hypothesis_tests (
  id uuid primary key default gen_random_uuid(),
  hypothesis_id uuid not null references public.dra_hypotheses(id),
  source_id uuid references public.dra_sources(id),
  test_method text not null,
  result_summary text,
  result_classification text not null default 'partial' check (result_classification in ('real','partial','pretend','failed','blocked')),
  created_at timestamptz not null default now()
);

create table if not exists public.dra_ingestion_queue (
  id uuid primary key default gen_random_uuid(),
  item_key text unique,
  source_type text not null,
  title text,
  url text,
  raw_note text,
  status text not null default 'new' check (status in ('new','triaged','evidence_bound','needs_review','published','retired','blocked')),
  priority int not null default 50,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.dra_reality_ledger (
  id uuid primary key default gen_random_uuid(),
  event_key text unique not null,
  intent text not null,
  execution_target text not null,
  output_summary text,
  classification text not null check (classification in ('real','partial','pretend','blocked','failed')),
  evidence_url text,
  evidence_ref text,
  created_at timestamptz not null default now()
);

create index if not exists dra_observations_substance_population_idx on public.dra_observations(substance_id, population_id);
create index if not exists dra_observations_evidence_status_idx on public.dra_observations(evidence_status);
create index if not exists dra_hypotheses_status_idx on public.dra_hypotheses(status);
create index if not exists dra_ingestion_queue_status_idx on public.dra_ingestion_queue(status);

alter table public.dra_sources enable row level security;
alter table public.dra_substances enable row level security;
alter table public.dra_populations enable row level security;
alter table public.dra_neurochemical_pathways enable row level security;
alter table public.dra_observations enable row level security;
alter table public.dra_hypotheses enable row level security;
alter table public.dra_hypothesis_tests enable row level security;
alter table public.dra_ingestion_queue enable row level security;
alter table public.dra_reality_ledger enable row level security;

-- Read policies intentionally broad for published/public research surface.
do $$ begin
  create policy dra_public_read_sources on public.dra_sources for select using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy dra_public_read_substances on public.dra_substances for select using (status <> 'retired');
exception when duplicate_object then null; end $$;
do $$ begin
  create policy dra_public_read_populations on public.dra_populations for select using (status <> 'retired');
exception when duplicate_object then null; end $$;
do $$ begin
  create policy dra_public_read_pathways on public.dra_neurochemical_pathways for select using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy dra_public_read_observations on public.dra_observations for select using (evidence_status <> 'retired');
exception when duplicate_object then null; end $$;
do $$ begin
  create policy dra_public_read_hypotheses on public.dra_hypotheses for select using (status <> 'retired');
exception when duplicate_object then null; end $$;

-- Service role handles writes. Client writes should be mediated through backend functions.

insert into public.dra_reality_ledger(event_key, intent, execution_target, output_summary, classification, evidence_ref)
values (
  'dra_schema_asset_created_20260424',
  'Create executable schema asset for Drug Resilience Atlas',
  'github:the-pen/assets/dra/supabase/migrations/20260424_dra_core.sql',
  'Schema asset prepared. Runtime Supabase execution still required.',
  'partial',
  'commit_receipt_pending'
)
on conflict (event_key) do nothing;
