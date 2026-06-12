-- ============================================================
-- 20260612_create_ops_work_queue.sql
-- Canonical runtime queue substrate for runtime-proof sweeper
-- Issue: the-pen#169
-- ============================================================

create schema if not exists ops;
create schema if not exists audit;

create table if not exists ops.work_queue (
  job_id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  status text not null default 'ready',
  origin text not null,
  destination text not null,
  env text not null default 'prod',
  payload jsonb not null default '{}'::jsonb,
  result jsonb,
  dedupe_key text,
  idempotency_key text,
  llm_source text,
  project_code text,
  topic text,
  owner text,
  claimed_by text,
  proof_ref text,
  blocked_reason text,
  error_code text,
  error_message text,
  retry_count integer not null default 0,
  max_retries integer not null default 3,
  started_at timestamptz,
  last_heartbeat timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint work_queue_status_check check (
    status in (
      'ready',
      'submitted',
      'claimed',
      'in_progress',
      'blocked',
      'failed',
      'error',
      'done',
      'verified',
      'cancelled',
      'duplicate_skipped'
    )
  )
);

create unique index if not exists idx_work_queue_dedupe_key
  on ops.work_queue (dedupe_key)
  where dedupe_key is not null;

create unique index if not exists idx_work_dedupe
  on ops.work_queue (idempotency_key)
  where idempotency_key is not null;

create index if not exists idx_work_queue_status_updated
  on ops.work_queue (status, updated_at);

create index if not exists idx_work_queue_destination_status
  on ops.work_queue (destination, status);

create table if not exists audit.log (
  audit_id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_id text not null,
  event_type text not null,
  actor text not null,
  env text not null default 'prod',
  old_value jsonb,
  new_value jsonb,
  immutable boolean not null default true,
  created_at timestamptz not null default now()
);

create or replace function ops.set_work_queue_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_work_queue_updated_at on ops.work_queue;
create trigger trg_work_queue_updated_at
before update on ops.work_queue
for each row
execute function ops.set_work_queue_updated_at();

create or replace view ops.v_work_queue_status_counts as
select
  status,
  count(*)::bigint as jobs,
  min(created_at) as oldest_created,
  max(updated_at) as newest_updated
from ops.work_queue
group by status;

create or replace view ops.v_work_queue_recovery_state as
select
  count(*) filter (
    where status = 'claimed'
      and updated_at < now() - interval '30 minutes'
      and last_heartbeat is null
  )::bigint as stale_claimed_count,
  count(*) filter (
    where status = 'in_progress'
      and updated_at < now() - interval '30 minutes'
  )::bigint as stale_in_progress_count,
  count(*) filter (where status = 'blocked')::bigint as blocked_count,
  count(*) filter (where status in ('failed','error'))::bigint as failed_count,
  max(updated_at) filter (where status in ('done','verified')) as last_successful_completion_at
from ops.work_queue;

-- Validation block. This must return installed objects after migration.
select 'schema:ops' as object, 'installed' as state
where exists (select 1 from information_schema.schemata where schema_name = 'ops')
union all
select 'table:ops.work_queue', 'installed'
where exists (select 1 from information_schema.tables where table_schema = 'ops' and table_name = 'work_queue')
union all
select 'table:audit.log', 'installed'
where exists (select 1 from information_schema.tables where table_schema = 'audit' and table_name = 'log')
union all
select 'view:ops.v_work_queue_status_counts', 'installed'
where exists (select 1 from information_schema.views where table_schema = 'ops' and table_name = 'v_work_queue_status_counts')
union all
select 'view:ops.v_work_queue_recovery_state', 'installed'
where exists (select 1 from information_schema.views where table_schema = 'ops' and table_name = 'v_work_queue_recovery_state');
