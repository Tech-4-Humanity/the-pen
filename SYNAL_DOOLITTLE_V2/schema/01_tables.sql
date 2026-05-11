-- Synal Doolittle V2 schema — deployed to Supabase 2026-05-08
-- All tables RLS-enabled with service_role bypass policy

create schema if not exists doolittle;

create table if not exists doolittle.tenants (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  product_name text default 'Synal Doolittle',
  logo_url text,
  primary_color text default '#ffd84d',
  plan text default 'starter',
  status text default 'active',
  created_at timestamptz default now(),
  archived_at timestamptz
);

create table if not exists doolittle.tenant_limits (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references doolittle.tenants(id) on delete cascade,
  max_spaces int default 3,
  max_threads int default 50,
  max_parties int default 10,
  monthly_model_budget numeric default 100,
  export_enabled boolean default true,
  proof_mode_enabled boolean default false,
  created_at timestamptz default now()
);

create table if not exists doolittle.project_spaces (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references doolittle.tenants(id),
  slug text not null,
  name text not null,
  purpose text,
  status text default 'active',
  created_at timestamptz default now(),
  archived_at timestamptz,
  unique (tenant_id, slug)
);

create table if not exists doolittle.threads (
  id uuid primary key default gen_random_uuid(),
  space_id uuid references doolittle.project_spaces(id) on delete cascade,
  title text not null,
  status text default 'open',
  created_at timestamptz default now(),
  archived_at timestamptz
);

create table if not exists doolittle.parties (
  id uuid primary key default gen_random_uuid(),
  party_key text unique not null,
  display_name text not null,
  party_type text not null,
  provider text,
  model text,
  can_execute boolean default false,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists doolittle.thread_parties (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid references doolittle.threads(id) on delete cascade,
  party_id uuid references doolittle.parties(id),
  role_in_thread text,
  invited_at timestamptz default now()
);

create table if not exists doolittle.messages (
  id uuid primary key default gen_random_uuid(),
  space_id uuid references doolittle.project_spaces(id),
  thread_id uuid references doolittle.threads(id) on delete cascade,
  party_id uuid references doolittle.parties(id),
  entry_type text not null,
  intent text,
  channel text,
  subject text,
  message text,
  confidence numeric,
  status text default 'PARTIAL',
  created_at timestamptz default now(),
  archived_at timestamptz
);

create table if not exists doolittle.attachments (
  id uuid primary key default gen_random_uuid(),
  message_id uuid references doolittle.messages(id) on delete cascade,
  file_name text,
  file_type text,
  file_size bigint,
  storage_url text,
  local_data_url text,
  created_at timestamptz default now()
);

create table if not exists doolittle.evidence_logs (
  id uuid primary key default gen_random_uuid(),
  message_id uuid references doolittle.messages(id) on delete cascade,
  evidence_type text,
  evidence_value text,
  status text,
  created_at timestamptz default now()
);

create table if not exists doolittle.resource_allocations (
  id uuid primary key default gen_random_uuid(),
  space_id uuid references doolittle.project_spaces(id),
  thread_id uuid references doolittle.threads(id),
  resource_type text not null,
  resource_key text not null,
  allocated_by text,
  allocation_reason text,
  budget_amount numeric,
  budget_unit text,
  priority text default 'normal',
  status text default 'allocated',
  created_at timestamptz default now()
);

create table if not exists doolittle.decisions (
  id uuid primary key default gen_random_uuid(),
  space_id uuid references doolittle.project_spaces(id),
  thread_id uuid references doolittle.threads(id),
  decided_by text not null,
  decision text not null,
  reason text,
  risk_class text,
  status text default 'PARTIAL',
  evidence_required boolean default true,
  evidence_status text default 'missing',
  created_at timestamptz default now()
);

create table if not exists doolittle.exports (
  id uuid primary key default gen_random_uuid(),
  space_id uuid references doolittle.project_spaces(id),
  thread_id uuid references doolittle.threads(id),
  export_type text,
  storage_url text,
  created_at timestamptz default now()
);

-- RLS
alter table doolittle.tenants enable row level security;
alter table doolittle.tenant_limits enable row level security;
alter table doolittle.project_spaces enable row level security;
alter table doolittle.threads enable row level security;
alter table doolittle.parties enable row level security;
alter table doolittle.thread_parties enable row level security;
alter table doolittle.messages enable row level security;
alter table doolittle.attachments enable row level security;
alter table doolittle.evidence_logs enable row level security;
alter table doolittle.resource_allocations enable row level security;
alter table doolittle.decisions enable row level security;
alter table doolittle.exports enable row level security;

-- service_role bypass policies (idempotent, per-table)
drop policy if exists svc_all on doolittle.tenants;
create policy svc_all on doolittle.tenants for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.tenant_limits;
create policy svc_all on doolittle.tenant_limits for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.project_spaces;
create policy svc_all on doolittle.project_spaces for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.threads;
create policy svc_all on doolittle.threads for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.parties;
create policy svc_all on doolittle.parties for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.thread_parties;
create policy svc_all on doolittle.thread_parties for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.messages;
create policy svc_all on doolittle.messages for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.attachments;
create policy svc_all on doolittle.attachments for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.evidence_logs;
create policy svc_all on doolittle.evidence_logs for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.resource_allocations;
create policy svc_all on doolittle.resource_allocations for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.decisions;
create policy svc_all on doolittle.decisions for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
drop policy if exists svc_all on doolittle.exports;
create policy svc_all on doolittle.exports for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
