-- QUEUE CONTROL PLANE V1
-- Source: wip/queue-control-plane-v1/
-- Promoted: 2026-05-07
-- Execute via: troy-sql-executor
-- Idempotent: YES (all CREATE ... IF NOT EXISTS)

-- ============================================================
-- CORE JOB QUEUE
-- ============================================================
create table if not exists public.t4h_job_queue (
  id uuid primary key default gen_random_uuid(),
  idempotency_key text unique not null,
  job_key text not null,
  priority int not null default 50, -- 10=IMMEDIATE 20=CRITICAL 30=COMMERCIAL 40=RESEARCH 50=CLOSE
  status text not null default 'QUEUED'
    check (status in ('QUEUED','CLAIMED','RUNNING','COMPLETED','FAILED','BLOCKED','DLQ','ARCHIVED')),
  payload jsonb not null default '{}'::jsonb,
  source_path text,
  env text not null default 'dev' check (env in ('dev','prod')),
  claimed_by text,
  claimed_at timestamptz,
  stale_after timestamptz,
  retry_count int not null default 0,
  max_retries int not null default 3,
  error_message text,
  receipt_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_t4h_job_queue_status_priority
  on public.t4h_job_queue (status, priority, created_at);

create index if not exists idx_t4h_job_queue_idempotency
  on public.t4h_job_queue (idempotency_key);

-- ============================================================
-- DEAD LETTER QUEUE
-- ============================================================
create table if not exists public.t4h_job_dlq (
  id uuid primary key default gen_random_uuid(),
  original_job_id uuid references public.t4h_job_queue(id),
  job_key text not null,
  idempotency_key text not null,
  payload jsonb not null,
  failure_reason text,
  retry_count int not null default 0,
  moved_at timestamptz not null default now()
);

-- ============================================================
-- AUDIT LOG
-- ============================================================
create table if not exists public.t4h_job_audit (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references public.t4h_job_queue(id),
  event text not null, -- work_started, work_completed, work_failed, retry, dlq_move, receipt_written
  actor text,
  detail jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- ============================================================
-- SECRET REGISTRY
-- ============================================================
create table if not exists public.t4h_secret_registry (
  id uuid primary key default gen_random_uuid(),
  canonical_name text not null unique,
  provider text not null,
  aliases jsonb not null default '[]'::jsonb,
  runtime_scopes text[] not null default '{}',
  owner_system text not null default 'unknown',
  required boolean not null default true,
  validation_status text not null default 'UNKNOWN'
    check (validation_status in ('VALID','MISSING','EXPIRED','INVALID','UNKNOWN','BLOCKED')),
  last_validated_at timestamptz,
  last_validated_by text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- CONNECTOR HEALTH
-- ============================================================
create table if not exists public.t4h_connector_health (
  id uuid primary key default gen_random_uuid(),
  connector_name text not null,
  provider text not null,
  runtime_scope text not null,
  health_status text not null
    check (health_status in ('GREEN','YELLOW','RED','BLOCKED','UNKNOWN')),
  blocker text,
  evidence_ref text,
  last_checked_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create unique index if not exists idx_connector_health_name_scope
  on public.t4h_connector_health (connector_name, runtime_scope);

-- ============================================================
-- REALITY LEDGER
-- ============================================================
create table if not exists public.t4h_reality_ledger (
  id uuid primary key default gen_random_uuid(),
  job_key text not null,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED','PRETEND','FAILED')),
  result text,
  evidence jsonb default '[]'::jsonb,
  gaps jsonb default '[]'::jsonb,
  next_action text,
  score numeric(3,2),
  created_at timestamptz not null default now()
);

-- ============================================================
-- JOB STATE COUNTS VIEW (Command Centre)
-- ============================================================
create or replace view public.v_job_state_counts as
select
  env,
  status,
  count(*) as job_count,
  min(created_at) as oldest_job,
  max(updated_at) as last_updated
from public.t4h_job_queue
group by env, status
order by env, status;

-- ============================================================
-- SEED: GOOGLE DRIVE SECRETS
-- ============================================================
insert into public.t4h_secret_registry
  (canonical_name, provider, aliases, runtime_scopes, owner_system, required, notes)
values
  ('GOOGLE_CLIENT_ID', 'google', '["GDRIVE_CLIENT_ID","GOOGLE_DRIVE_CLIENT_ID"]'::jsonb,
   '{mcp,bridge,lambda,local}', 'google-drive-mcp', true, 'Canonical Google OAuth client ID'),
  ('GOOGLE_CLIENT_SECRET', 'google', '["GDRIVE_CLIENT_SECRET","GOOGLE_DRIVE_CLIENT_SECRET"]'::jsonb,
   '{mcp,bridge,lambda,local}', 'google-drive-mcp', true, 'Canonical Google OAuth client secret'),
  ('GOOGLE_REFRESH_TOKEN', 'google', '["GDRIVE_REFRESH_TOKEN","GOOGLE_DRIVE_REFRESH_TOKEN"]'::jsonb,
   '{mcp,bridge,lambda,local}', 'google-drive-mcp', true, 'Canonical Google OAuth refresh token'),
  ('GOOGLE_PROJECT_ID', 'google', '["GDRIVE_PROJECT_ID","GOOGLE_DRIVE_PROJECT_ID"]'::jsonb,
   '{mcp,bridge,lambda}', 'google-drive-mcp', false, 'Google Cloud project ID'),
  ('GOOGLE_DRIVE_FOLDER_ID', 'google', '["GDRIVE_FOLDER_ID","GOOGLE_DRIVE_ROOT_FOLDER_ID"]'::jsonb,
   '{mcp,bridge}', 'google-drive-mcp', false, 'Root Drive folder ID')
on conflict (canonical_name) do nothing;

-- ============================================================
-- SEED: CONNECTOR HEALTH INITIAL ROWS
-- ============================================================
insert into public.t4h_connector_health
  (connector_name, provider, runtime_scope, health_status, blocker)
values
  ('google-drive-mcp', 'google', 'mcp', 'UNKNOWN', 'Pending env var validation and probe'),
  ('github-mcp', 'github', 'mcp', 'GREEN', 'Connected — Perplexity MCP confirmed 2026-05-07'),
  ('supabase-sql', 'supabase', 'bridge', 'UNKNOWN', 'Pending troy-sql-executor probe'),
  ('stripe', 'stripe', 'lambda', 'UNKNOWN', 'Pending test payment probe'),
  ('lambda-deployer', 'aws', 'bridge', 'UNKNOWN', 'Pending troy-lambda-deployer probe')
on conflict (connector_name, runtime_scope) do nothing;
