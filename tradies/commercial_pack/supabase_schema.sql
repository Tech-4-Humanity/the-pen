-- AI for Tradies Supabase Schema
-- Status: PARTIAL until executed against Supabase and smoke-tested.

create extension if not exists pgcrypto;

create table if not exists public.tradie_businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  trade_type text not null,
  region text,
  phone text,
  email text,
  website text,
  plan_code text default 'starter',
  status text default 'lead' check (status in ('lead','trial','active','paused','churned')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.tradie_customers (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.tradie_businesses(id) on delete cascade,
  full_name text,
  phone text,
  email text,
  address text,
  suburb text,
  customer_type text default 'residential',
  lifetime_value numeric default 0,
  created_at timestamptz default now()
);

create table if not exists public.tradie_jobs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.tradie_businesses(id) on delete cascade,
  customer_id uuid references public.tradie_customers(id),
  job_type text not null,
  status text default 'new' check (status in ('new','qualified','quoted','booked','in_progress','completed','invoiced','paid','lost')),
  urgency text default 'normal' check (urgency in ('low','normal','urgent','emergency')),
  source_channel text,
  description text,
  quoted_amount numeric,
  actual_amount numeric,
  margin_estimate numeric,
  scheduled_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists public.tradie_agents (
  id uuid primary key default gen_random_uuid(),
  agent_code text unique not null,
  domain text not null,
  name text not null,
  purpose text not null,
  active boolean default true,
  model_preference text,
  cost_limit_cents int default 100,
  created_at timestamptz default now()
);

create table if not exists public.tradie_agent_runs (
  id uuid primary key default gen_random_uuid(),
  agent_id uuid references public.tradie_agents(id),
  business_id uuid references public.tradie_businesses(id),
  job_id uuid references public.tradie_jobs(id),
  input jsonb not null default '{}',
  output jsonb not null default '{}',
  status text default 'queued' check (status in ('queued','running','completed','failed','blocked')),
  evidence jsonb default '[]'::jsonb,
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists public.tradie_products (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  monthly_price numeric not null,
  interaction_limit int,
  stripe_product_id text,
  stripe_price_id text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.tradie_subscriptions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.tradie_businesses(id) on delete cascade,
  product_id uuid references public.tradie_products(id),
  stripe_customer_id text,
  stripe_subscription_id text,
  status text default 'trial' check (status in ('trial','active','past_due','cancelled','paused')),
  current_period_start timestamptz,
  current_period_end timestamptz,
  created_at timestamptz default now()
);

create table if not exists public.tradie_events (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.tradie_businesses(id) on delete cascade,
  job_id uuid references public.tradie_jobs(id),
  event_type text not null,
  payload jsonb not null default '{}',
  source text default 'system',
  created_at timestamptz default now()
);

create table if not exists public.tradie_reality_ledger (
  id uuid primary key default gen_random_uuid(),
  task_id text not null,
  intent text not null,
  execution text,
  output jsonb default '{}',
  status text not null check (status in ('REAL','PARTIAL','BLOCKED','PRETEND')),
  evidence jsonb not null default '[]',
  gaps jsonb not null default '[]',
  next_action text,
  score numeric default 0,
  created_at timestamptz default now()
);

insert into public.tradie_products (code, name, monthly_price, interaction_limit)
values
('starter','AI Tradies Starter',99,50),
('growth','AI Tradies Growth',299,500),
('pro','AI Tradies Pro',799,2000),
('enterprise','AI Tradies Enterprise',1999,null)
on conflict (code) do nothing;

insert into public.tradie_reality_ledger (task_id,intent,execution,output,status,evidence,gaps,next_action,score)
values (
  'ai-tradies-commercial-pack-v1',
  'Create schema for AI Tradies operating system',
  'SQL generated and committed to GitHub',
  '{"tables":8,"products":4}'::jsonb,
  'PARTIAL',
  '[{"type":"github_file","path":"tradies/commercial_pack/supabase_schema.sql"}]'::jsonb,
  '["Not executed against Supabase","No RLS smoke test","No API binding yet"]'::jsonb,
  'Execute SQL via approved Supabase executor and capture db_result evidence',
  0.62
);
