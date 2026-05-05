-- Supabase schema for Predictive Capacity Activation Engine

create table if not exists donors (
  id uuid primary key default gen_random_uuid(),
  consent boolean not null default false,
  last_donation_date date,
  eligibility_date date,
  reliability_score float default 0.5,
  preferred_channel text,
  location text,
  created_at timestamptz default now()
);

create table if not exists demand_signals (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz,
  region text,
  blood_type text,
  forecast_units int,
  created_at timestamptz default now()
);

create table if not exists supply_forecast (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz,
  segment text,
  expected_donors int,
  created_at timestamptz default now()
);

create table if not exists activation_events (
  id uuid primary key default gen_random_uuid(),
  donor_id uuid,
  message_type text,
  sent_at timestamptz,
  response text,
  created_at timestamptz default now()
);

create table if not exists outcomes (
  id uuid primary key default gen_random_uuid(),
  donor_id uuid,
  attended boolean,
  units int,
  created_at timestamptz default now()
);

create table if not exists reality_ledger (
  id uuid primary key default gen_random_uuid(),
  event_id uuid,
  status text,
  evidence text,
  created_at timestamptz default now()
);
