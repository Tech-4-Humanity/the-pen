-- Synal Store Core Schema

create table if not exists synal_store_products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  price numeric,
  pricing_model text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists synal_store_events (
  id uuid primary key default gen_random_uuid(),
  product_id uuid,
  event_type text,
  payload jsonb,
  created_at timestamptz default now()
);

create table if not exists synal_store_evidence_receipts (
  id uuid primary key default gen_random_uuid(),
  product_id uuid,
  intent text,
  execution text,
  output text,
  classification text check (classification in ('REAL','PARTIAL','PRETEND')),
  evidence jsonb,
  created_at timestamptz default now()
);

create table if not exists synal_store_installations (
  id uuid primary key default gen_random_uuid(),
  product_id uuid,
  user_id text,
  installed_at timestamptz default now()
);
