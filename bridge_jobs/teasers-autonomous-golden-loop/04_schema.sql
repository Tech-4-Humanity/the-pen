-- Teasers Autonomous Golden Loop schema
-- Status: deployable migration spec. Runtime proof required after apply.

create extension if not exists pgcrypto;

create table if not exists teaser_prompt (
  id uuid primary key default gen_random_uuid(),
  prompt_type text not null check (prompt_type in ('pulse','context','topical','reflection','recovery')),
  prompt_text text not null,
  response_type text not null default 'binary',
  weight numeric not null default 1,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint teaser_prompt_unique_text unique (prompt_type, prompt_text)
);

create table if not exists teaser_delivery (
  id uuid primary key default gen_random_uuid(),
  user_ref text,
  tenant_ref text,
  prompt_id uuid references teaser_prompt(id),
  delivered_at timestamptz not null default now(),
  surface text not null default 'browser',
  context_snapshot jsonb not null default '{}'::jsonb
);

create table if not exists teaser_response (
  id uuid primary key default gen_random_uuid(),
  delivery_id uuid references teaser_delivery(id),
  response_value text,
  interaction_type text not null check (interaction_type in ('answer','snooze','dismiss','timeout')),
  latency_ms integer,
  created_at timestamptz not null default now()
);

create table if not exists teaser_signal_score (
  id uuid primary key default gen_random_uuid(),
  delivery_id uuid references teaser_delivery(id),
  response_id uuid references teaser_response(id),
  user_ref text,
  tenant_ref text,
  focus_score numeric,
  reactivity_score numeric,
  load_score numeric,
  control_score numeric,
  recovery_score numeric,
  movement_score numeric,
  effectiveness_score numeric,
  human_effectiveness_vector jsonb not null default '{}'::jsonb,
  evidence_tier text not null default 'inferred',
  created_at timestamptz not null default now()
);

create table if not exists teaser_policy (
  id uuid primary key default gen_random_uuid(),
  tenant_ref text,
  cadence_rules jsonb not null default '{}'::jsonb,
  suppression_rules jsonb not null default '{}'::jsonb,
  allowed_prompt_types jsonb not null default '["pulse","context","topical","reflection","recovery"]'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists teaser_runtime_receipt (
  id uuid primary key default gen_random_uuid(),
  receipt_type text not null,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED')),
  evidence jsonb not null default '{}'::jsonb,
  gaps jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

insert into teaser_prompt (prompt_type, prompt_text, response_type, weight)
values
('pulse','Feeling more reactive than planned today?','binary',1),
('context','Are meetings helping or blocking real work today?','choice',1),
('reflection','Are you busier than last week, or more interrupted?','choice',1),
('recovery','Did movement improve your thinking today?','binary',1)
on conflict (prompt_type, prompt_text) do nothing;
