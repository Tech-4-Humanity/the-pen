create table if not exists public.aiss_sources (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  source_type text not null,
  source_url text,
  sample_size int,
  peer_reviewed boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.aiss_claims (
  id uuid primary key default gen_random_uuid(),
  claim_id text unique not null,
  claim_text text not null,
  intervention text not null,
  cohort text,
  task_context text,
  source_asset text,
  evidence_state text not null,
  publication_state text not null,
  confidence text not null default 'medium',
  risk_notes text,
  created_at timestamptz default now()
);

create table if not exists public.drxai_interactions (
  id uuid primary key default gen_random_uuid(),
  interaction_id text unique not null,
  intervention_category text not null,
  substance_or_factor text,
  ai_intensity numeric,
  cohort text,
  task_context text,
  observed_effect text,
  risk_profile text,
  evidence_state text not null,
  created_at timestamptz default now()
);
