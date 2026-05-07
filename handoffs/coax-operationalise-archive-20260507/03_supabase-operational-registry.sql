create table if not exists operational_projects (
  id uuid primary key default gen_random_uuid(),
  project_uuid text unique not null,
  name text not null,
  domain text,
  classification text not null default 'PARTIAL' check (classification in ('REAL','PARTIAL','BLOCKED','PRETEND')),
  runtime_status text default 'OFFLINE',
  deployment_url text,
  telemetry_enabled boolean default false,
  revenue_linked boolean default false,
  bridge_bound boolean default false,
  reality_ledger_bound boolean default false,
  orchestration_agent text,
  maturity_score numeric default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists operational_project_evidence (
  id uuid primary key default gen_random_uuid(),
  project_uuid text not null,
  evidence_type text not null,
  evidence_value text,
  classification text,
  created_at timestamptz default now()
);

create index if not exists operational_projects_classification_idx
on operational_projects(classification);
