create schema if not exists telemetry;

create table if not exists telemetry.runtime_ledger (
  event_id uuid primary key default gen_random_uuid(),
  runtime_id text not null,
  agent_id text,
  business_slug text,
  job_id uuid,
  queue_name text,
  execution_trace jsonb,
  receipt_ref text,
  classification text check (classification in ('REAL','PARTIAL','PRETEND','DEGRADED','UNVERIFIED','ORPHANED','STALE')),
  health_state text,
  recovery_pointer text,
  economic_ref text,
  event_type text,
  latency_ms integer,
  success boolean,
  created_at timestamptz not null default now()
);

create index if not exists idx_runtime_ledger_runtime_id on telemetry.runtime_ledger(runtime_id);
create index if not exists idx_runtime_ledger_agent_id on telemetry.runtime_ledger(agent_id);
create index if not exists idx_runtime_ledger_job_id on telemetry.runtime_ledger(job_id);
create index if not exists idx_runtime_ledger_created_at on telemetry.runtime_ledger(created_at desc);

comment on table telemetry.runtime_ledger is 'Canonical append-only runtime telemetry ledger for AHC/WorkFamilyAI orchestration evidence.';
