-- The Pen Execution Ledger
-- Queryable ledger for runtime receipts, task queue, value binding, retries, and drift checks.

create extension if not exists pgcrypto;

create table if not exists public.pen_task_queue (
  id uuid primary key default gen_random_uuid(),
  task_id text not null unique,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'queued' check (status in ('queued','running','succeeded','failed','dead_letter')),
  priority int not null default 100,
  attempt_count int not null default 0,
  max_attempts int not null default 5,
  next_run_at timestamptz not null default now(),
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pen_execution_ledger (
  id uuid primary key default gen_random_uuid(),
  request_id text not null unique,
  task_id text not null,
  source text not null,
  status text not null check (status in ('PASS','FAIL','BLOCKED')),
  reality_classification text not null check (reality_classification in ('REAL','PARTIAL','PRETEND')),
  receipt jsonb not null,
  output_refs jsonb not null default '[]'::jsonb,
  log_refs jsonb not null default '[]'::jsonb,
  value_event_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.pen_value_events (
  id uuid primary key default gen_random_uuid(),
  task_id text not null,
  request_id text,
  customer_ref text,
  product_ref text not null default 'the-pen-execution',
  currency text not null default 'AUD',
  unit_amount_cents int not null default 0,
  quantity int not null default 1,
  value_rule text not null default 'execution_receipt_created',
  stripe_customer_id text,
  stripe_price_id text,
  stripe_invoice_item_id text,
  stripe_checkout_session_id text,
  monetisation_status text not null default 'log_only' check (monetisation_status in ('log_only','ready','sent_to_stripe','paid','failed')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.pen_drift_checks (
  id uuid primary key default gen_random_uuid(),
  check_id text not null,
  check_type text not null,
  status text not null check (status in ('PASS','FAIL','WARN')),
  expected jsonb not null default '{}'::jsonb,
  actual jsonb not null default '{}'::jsonb,
  recovery_action text,
  created_at timestamptz not null default now()
);

create index if not exists pen_task_queue_status_next_run_idx on public.pen_task_queue(status, next_run_at, priority);
create index if not exists pen_execution_ledger_task_idx on public.pen_execution_ledger(task_id, created_at desc);
create index if not exists pen_value_events_task_idx on public.pen_value_events(task_id, created_at desc);
create index if not exists pen_drift_checks_type_idx on public.pen_drift_checks(check_type, created_at desc);

alter table public.pen_task_queue enable row level security;
alter table public.pen_execution_ledger enable row level security;
alter table public.pen_value_events enable row level security;
alter table public.pen_drift_checks enable row level security;

-- Service-role automation policies. Adjust for authenticated dashboard users separately.
do $$ begin
  create policy "service role manages pen_task_queue" on public.pen_task_queue for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
exception when duplicate_object then null; end $$;

do $$ begin
  create policy "service role manages pen_execution_ledger" on public.pen_execution_ledger for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
exception when duplicate_object then null; end $$;

do $$ begin
  create policy "service role manages pen_value_events" on public.pen_value_events for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
exception when duplicate_object then null; end $$;

do $$ begin
  create policy "service role manages pen_drift_checks" on public.pen_drift_checks for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
exception when duplicate_object then null; end $$;
