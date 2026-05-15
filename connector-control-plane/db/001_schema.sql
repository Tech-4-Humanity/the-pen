-- Connector Control Plane — canonical ledger schema
-- Apply via: psql $SUPABASE_DB_URL -f db/001_schema.sql
-- Target: Supabase S1 (lzfgigiyqpuuxslsygjt), schema public

begin;

create table if not exists public.ccp_connectors (
  connector_id     text primary key,
  name             text not null,
  provider         text not null,
  base_url         text not null,
  health_url       text,
  auth_type        text not null default 'bearer',
  capabilities     text[] not null default array[]::text[],
  cost_micros      bigint not null default 0,
  priority         int not null default 100,
  slo_p99_ms       int not null default 1500,
  owner            text not null default 'tech-4-humanity',
  enabled          boolean not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table if not exists public.ccp_receipts (
  execution_id     uuid primary key,
  actor_id         text not null,
  runtime_id       text not null,
  state            text not null check (state in ('REAL','PARTIAL','BLOCKED')),
  intent           text not null,
  connector        text references public.ccp_connectors(connector_id),
  evidence         jsonb not null,
  evidence_hash    text not null,
  started_at       timestamptz not null,
  finished_at      timestamptz not null,
  duration_ms      int not null,
  cost_micros      bigint not null default 0,
  error            text,
  created_at       timestamptz not null default now()
);

create table if not exists public.ccp_health_snapshots (
  id               bigserial primary key,
  connector_id     text not null references public.ccp_connectors(connector_id) on delete cascade,
  healthy          boolean not null,
  latency_ms       int,
  status_code      int,
  observed_at      timestamptz not null default now()
);

create table if not exists public.ccp_intents (
  intent_id        text primary key,
  description      text not null,
  required_capability text not null,
  default_cost_budget_micros bigint not null default 1000,
  created_at       timestamptz not null default now()
);

create or replace view public.v_ccp_connector_health as
select
  c.connector_id,
  c.name,
  c.provider,
  c.enabled,
  (select healthy    from public.ccp_health_snapshots h where h.connector_id = c.connector_id order by observed_at desc limit 1) as last_healthy,
  (select latency_ms from public.ccp_health_snapshots h where h.connector_id = c.connector_id order by observed_at desc limit 1) as last_latency_ms,
  (select observed_at from public.ccp_health_snapshots h where h.connector_id = c.connector_id order by observed_at desc limit 1) as last_observed_at
from public.ccp_connectors c;

commit;
