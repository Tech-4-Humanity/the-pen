-- Thriving Kids Child Journey Graph v1
-- Purpose: One child journey record, four lenses: participant, practitioner, provider, governor.
-- Status: PARTIAL until deployed to Supabase and smoke-tested.

create extension if not exists pgcrypto;

create table if not exists tk_children (
  child_id uuid primary key default gen_random_uuid(),
  display_code text unique not null,
  preferred_name text not null,
  date_of_birth date,
  age_years numeric,
  region text,
  state text,
  pathway text check (pathway in ('early_notice','thriving_kids','ndis','school_support','community_support','unknown')) default 'unknown',
  support_level text check (support_level in ('universal','low','moderate','high','unknown')) default 'unknown',
  transition_risk text check (transition_risk in ('green','yellow','red','unknown')) default 'unknown',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists tk_people (
  person_id uuid primary key default gen_random_uuid(),
  child_id uuid references tk_children(child_id) on delete cascade,
  role text check (role in ('participant_family','practitioner','provider','governor','educator','navigator','admin')) not null,
  name text,
  organisation text,
  contact_channel text,
  consent_scope text check (consent_scope in ('full','limited','session','none')) default 'limited',
  created_at timestamptz default now()
);

create table if not exists tk_goals (
  goal_id uuid primary key default gen_random_uuid(),
  child_id uuid references tk_children(child_id) on delete cascade,
  domain text not null,
  goal_text text not null,
  owner_role text not null,
  status text check (status in ('proposed','active','improving','met','paused','closed')) default 'active',
  evidence_strength text check (evidence_strength in ('weak','moderate','strong','unknown')) default 'unknown',
  created_at timestamptz default now(),
  review_due date
);

create table if not exists tk_signals (
  signal_id uuid primary key default gen_random_uuid(),
  child_id uuid references tk_children(child_id) on delete cascade,
  source text check (source in ('family','reading_buddy','school','practitioner','provider','system')) not null,
  domain text not null,
  signal_value text not null,
  intensity text check (intensity in ('low','medium','high','unknown')) default 'unknown',
  observed_at timestamptz default now(),
  evidence_note text,
  confidence numeric check (confidence >= 0 and confidence <= 1) default 0.7
);

create table if not exists tk_events (
  event_id uuid primary key default gen_random_uuid(),
  child_id uuid references tk_children(child_id) on delete cascade,
  event_type text check (event_type in ('early_notice','referral','assessment','support_started','school_transition','plan_review','risk_alert','milestone','handover')) not null,
  title text not null,
  event_date date not null,
  actor_role text,
  summary text,
  created_at timestamptz default now()
);

create table if not exists tk_evidence (
  evidence_id uuid primary key default gen_random_uuid(),
  child_id uuid references tk_children(child_id) on delete cascade,
  linked_type text check (linked_type in ('goal','signal','event','document','note','report')) not null,
  linked_id uuid,
  evidence_grade text check (evidence_grade in ('A','B','C','D')) default 'C',
  title text not null,
  source_uri text,
  sha256 text,
  created_at timestamptz default now()
);

create table if not exists tk_transition_risk (
  risk_id uuid primary key default gen_random_uuid(),
  child_id uuid references tk_children(child_id) on delete cascade,
  risk_score numeric check (risk_score >= 0 and risk_score <= 100) not null,
  risk_band text check (risk_band in ('green','yellow','red')) not null,
  reasons jsonb default '[]'::jsonb,
  recommended_actions jsonb default '[]'::jsonb,
  calculated_at timestamptz default now()
);

create table if not exists tk_reality_ledger (
  ledger_id uuid primary key default gen_random_uuid(),
  task_id text not null,
  child_id uuid,
  intent text not null,
  execution text not null,
  output jsonb not null,
  status text check (status in ('REAL','PARTIAL','BLOCKED')) not null,
  evidence jsonb default '[]'::jsonb,
  gaps jsonb default '[]'::jsonb,
  next_action text,
  score numeric check (score >= 0 and score <= 1),
  created_at timestamptz default now()
);
