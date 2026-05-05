create schema if not exists telemetry;
create table if not exists telemetry.signal_events (
  id uuid primary key default gen_random_uuid(),
  idempotency_key text not null,
  signal_class text not null,
  signal_key text not null,
  raw_value jsonb not null default '{}'::jsonb,
  observed_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create table if not exists telemetry.signal_scores (
  id uuid primary key default gen_random_uuid(),
  idempotency_key text not null,
  signal_key text not null,
  score numeric not null check (score >= 0 and score <= 1),
  evidence_state text not null default 'PARTIAL' check (evidence_state in ('REAL','PARTIAL','PRETEND')),
  calculated_at timestamptz not null default now()
);
create table if not exists telemetry.signal_composites (
  id uuid primary key default gen_random_uuid(),
  idempotency_key text not null,
  composite_key text not null,
  inputs jsonb not null default '[]'::jsonb,
  score numeric not null check (score >= 0 and score <= 1),
  evidence_state text not null default 'PARTIAL' check (evidence_state in ('REAL','PARTIAL','PRETEND')),
  calculated_at timestamptz not null default now()
);
alter table telemetry.signal_events enable row level security;
alter table telemetry.signal_scores enable row level security;
alter table telemetry.signal_composites enable row level security;
