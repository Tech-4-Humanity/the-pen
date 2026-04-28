-- InnovateME Core Schema

create table if not exists innovateme_story (
  id uuid primary key default gen_random_uuid(),
  story_id text unique not null,
  title text not null,
  buyer_type text not null,
  pain_statement text not null,
  story_archetype text not null,
  agent_set jsonb default '[]'::jsonb,
  proof_metrics jsonb default '[]'::jsonb,
  pilot_duration text,
  indicative_price_band text,
  reality_ledger_status text default 'PRETEND',
  created_at timestamptz default now()
);

create table if not exists innovateme_pilot_offer (
  id uuid primary key default gen_random_uuid(),
  offer_key text unique not null,
  name text,
  level int,
  price_min_aud int,
  price_max_aud int,
  created_at timestamptz default now()
);

create table if not exists innovateme_execution_receipt (
  id uuid primary key default gen_random_uuid(),
  receipt_key text unique not null,
  status text,
  payload jsonb,
  created_at timestamptz default now()
);
