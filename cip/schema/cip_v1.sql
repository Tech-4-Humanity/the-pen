-- cip/schema/cip_v1.sql
-- CTO in Your Pocket — Solo CTO Control Layer schema, v1
-- Target: Supabase S1 (lzfgigiyqpuuxslsygjt)
-- First applied: 2026-05-07 (pilot loop receipt: handoffs/CTO_In_Your_Pocket_Pilot_Receipt_20260507.md)
-- Doctrine:
--   - reality_ledger sink is public.reality_ledger
--   - cluster_id is CL_CTO_POCKET in core.cluster_registry
--   - DDL is split atomic (no BEGIN/COMMIT; troy-sql-executor masks RETURNING)
--   - All writes are LOG-ONLY autonomy; DDL is GATED
-- Reuse: re-run idempotently. Every CREATE uses IF NOT EXISTS.

create schema if not exists cip;

-- assets — what we monitor
create table if not exists cip.assets (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  asset_type text not null check (asset_type in ('website','form','stripe','queue','api','agent')),
  url text,
  criticality text not null default 'P2' check (criticality in ('P0','P1','P2','P3')),
  fallback_url text,
  active boolean not null default true,
  business_key text,
  created_at timestamptz not null default now()
);

-- playbooks — safe remediation strategies
create table if not exists cip.playbooks (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  action_type text not null check (action_type in ('retry','redeploy','restart','failover','throttle','noop')),
  safe boolean not null default true,
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- incidents — failure state machine
create table if not exists cip.incidents (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references cip.assets(id),
  status text not null default 'detected' check (status in ('detected','remediating','recovered','escalated','closed')),
  severity text not null check (severity in ('P0','P1','P2','P3')),
  detected_at timestamptz not null default now(),
  resolved_at timestamptz,
  attempts int not null default 0,
  probe_payload jsonb,
  detected_http_status int,
  notes text
);

-- executions — what we tried, with hash
create table if not exists cip.executions (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references cip.incidents(id),
  playbook_id uuid not null references cip.playbooks(id),
  status text not null check (status in ('success','fail','timeout','skipped')),
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  logs jsonb,
  evidence_hash text
);

-- validations — did it actually work
create table if not exists cip.validations (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references cip.incidents(id),
  result text not null check (result in ('pass','fail','inconclusive')),
  http_status int,
  latency_ms int,
  checked_at timestamptz not null default now(),
  evidence jsonb
);

-- cluster registration (run once via core.cluster_registry — not part of cip schema)
-- insert into core.cluster_registry (
--   cluster_id, cluster_name, priority, description,
--   home_entity, home_schema, ledger_sink, closure_rule, evidence_type, is_active
-- ) values (
--   'CL_CTO_POCKET','CTO in Your Pocket','P1',
--   'Solo CTO Control Layer productised: probe>remediate>validate>ledger',
--   'cip.assets','cip','public.reality_ledger',
--   'incident_recovered_or_escalated','http_probe+sql_rows+evidence_hash',true
-- ) on conflict (cluster_id) do nothing;
