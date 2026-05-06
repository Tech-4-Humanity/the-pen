-- 01_ram_schema.sql
-- RAM = Retro Assets Modernisation
-- Dogfood-first schema. Status remains PARTIAL until internal assets are ingested and validated.

create extension if not exists pgcrypto;

create table if not exists public.ram_assets (
  id uuid primary key default gen_random_uuid(),
  canonical_name text not null,
  original_name text,
  asset_type text not null default 'unknown',
  source_system text not null,
  source_uri text,
  package_stem text,
  owner_system text default 'ram',
  evidence_state text not null default 'PARTIAL' check (evidence_state in ('REAL','PARTIAL','BLOCKED')),
  validation_score numeric(5,2) default 0,
  content_hash text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists ram_assets_canonical_name_uq on public.ram_assets(canonical_name);
create index if not exists ram_assets_source_system_idx on public.ram_assets(source_system);
create index if not exists ram_assets_package_stem_idx on public.ram_assets(package_stem);
create index if not exists ram_assets_evidence_state_idx on public.ram_assets(evidence_state);

create table if not exists public.ram_asset_locations (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.ram_assets(id) on delete cascade,
  location_type text not null,
  location_uri text not null,
  is_primary boolean not null default false,
  checked_at timestamptz,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists ram_asset_locations_asset_id_idx on public.ram_asset_locations(asset_id);

create table if not exists public.ram_asset_hashes (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.ram_assets(id) on delete cascade,
  hash_type text not null default 'sha256',
  hash_value text not null,
  byte_size bigint,
  created_at timestamptz not null default now(),
  unique(hash_type, hash_value)
);

create table if not exists public.ram_asset_lineage (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.ram_assets(id) on delete cascade,
  parent_asset_id uuid references public.ram_assets(id) on delete set null,
  relation_type text not null,
  confidence numeric(5,2) not null default 0,
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.ram_asset_validation (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.ram_assets(id) on delete cascade,
  validation_type text not null,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED')),
  score numeric(5,2) not null default 0,
  result jsonb not null default '{}'::jsonb,
  evidence_uri text,
  checked_at timestamptz not null default now()
);

create index if not exists ram_asset_validation_asset_id_idx on public.ram_asset_validation(asset_id);

create table if not exists public.ram_asset_evidence (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.ram_assets(id) on delete cascade,
  evidence_type text not null check (evidence_type in ('api_response','db_result','cli_output','commit_id','url','hash','repro_steps','log','receipt')),
  evidence_value text not null,
  evidence_payload jsonb not null default '{}'::jsonb,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED')),
  created_at timestamptz not null default now()
);

create table if not exists public.ram_packages (
  id uuid primary key default gen_random_uuid(),
  package_name text not null unique,
  package_stem text not null,
  purpose text not null,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  manifest jsonb not null default '{}'::jsonb,
  receipt_uri text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ram_portfolio_cards (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid references public.ram_assets(id) on delete set null,
  brand text not null,
  capability text not null,
  audience text not null,
  summary text not null,
  evidence_state text not null default 'PARTIAL' check (evidence_state in ('REAL','PARTIAL','BLOCKED')),
  commercial_value text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.ram_reuse_components (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid references public.ram_assets(id) on delete set null,
  component_type text not null,
  component_name text not null,
  reuse_target text,
  confidence numeric(5,2) not null default 0,
  evidence_state text not null default 'PARTIAL' check (evidence_state in ('REAL','PARTIAL','BLOCKED')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.ram_watch_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  severity text not null default 'info' check (severity in ('info','warning','critical')),
  asset_id uuid references public.ram_assets(id) on delete set null,
  package_id uuid references public.ram_packages(id) on delete set null,
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  message text not null,
  evidence jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.ram_dev_inspections (
  id uuid primary key default gen_random_uuid(),
  package_stem text not null,
  inspector text not null default 'dev',
  status text not null default 'PARTIAL' check (status in ('REAL','PARTIAL','BLOCKED')),
  findings jsonb not null default '{}'::jsonb,
  receipt_uri text,
  created_at timestamptz not null default now()
);

create table if not exists public.ram_prod_promotions (
  id uuid primary key default gen_random_uuid(),
  package_stem text not null,
  promoted_by text not null default 'ram',
  status text not null default 'BLOCKED' check (status in ('REAL','PARTIAL','BLOCKED')),
  gate_result jsonb not null default '{}'::jsonb,
  receipt_uri text,
  created_at timestamptz not null default now()
);
