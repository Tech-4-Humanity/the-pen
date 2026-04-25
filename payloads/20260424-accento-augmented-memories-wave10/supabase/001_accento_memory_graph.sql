-- Accento / Augmented Memories Memory Graph
-- Wave 10 production baseline
-- Date: 2026-04-24
-- Scope: shared memory infrastructure for T4H 30-business ecosystem

begin;

create extension if not exists pgcrypto;
create extension if not exists postgis;

create type if not exists public.accento_memory_visibility as enum ('private','circle','public','partner','institutional');
create type if not exists public.accento_memory_status as enum ('draft','active','archived','deleted','disputed','blocked');
create type if not exists public.accento_memory_type as enum ('personal','family','work','memorial','cultural','education','health','sport','travel','venue','museum','environment','system_generated');
create type if not exists public.accento_asset_type as enum ('photo','video','audio','document','text','link','scan','qr','nfc','other');
create type if not exists public.accento_entity_type as enum ('person','place','org','event','collection','memory');
create type if not exists public.accento_reality_classification as enum ('REAL','PARTIAL','PRETEND','BLOCKED');
create type if not exists public.accento_commercial_layer as enum ('consumer_subscription','memorial_pack','place_network','enterprise_license','partner_channel','services','insight');

create table if not exists public.accento_tenant (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  tenant_type text not null default 'consumer',
  owner_user_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);

create table if not exists public.accento_place_entity (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete set null,
  name text not null,
  place_type text not null default 'unknown',
  geo_point geography(Point,4326),
  geo_boundary geography(Polygon,4326),
  address text,
  locality text,
  region text,
  country text,
  external_refs jsonb not null default '{}'::jsonb,
  verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);

create index if not exists accento_place_geo_point_gix on public.accento_place_entity using gist (geo_point);
create index if not exists accento_place_type_idx on public.accento_place_entity(place_type);

create table if not exists public.accento_person_entity (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete set null,
  owner_user_id uuid,
  display_name text not null,
  person_type text not null default 'known',
  relationship_to_owner text,
  is_deceased boolean not null default false,
  identity_level text not null default 'unverified',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);

create table if not exists public.accento_org_entity (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete set null,
  name text not null,
  org_type text not null default 'unknown',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);

create table if not exists public.accento_consent_policy (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete cascade,
  owner_user_id uuid,
  policy_name text not null default 'default',
  visibility public.accento_memory_visibility not null default 'private',
  allowed_roles jsonb not null default '[]'::jsonb,
  blocked_roles jsonb not null default '[]'::jsonb,
  expiry_rules jsonb not null default '{}'::jsonb,
  jurisdiction text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);

create table if not exists public.accento_memory_collection (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete cascade,
  owner_user_id uuid,
  name text not null,
  collection_type text not null default 'general',
  visibility public.accento_memory_visibility not null default 'private',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);

create table if not exists public.accento_memory_object (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete cascade,
  owner_user_id uuid not null,
  collection_id uuid references public.accento_memory_collection(id) on delete set null,
  title text not null,
  description text,
  memory_type public.accento_memory_type not null default 'personal',
  status public.accento_memory_status not null default 'draft',
  visibility public.accento_memory_visibility not null default 'private',
  consent_policy_id uuid references public.accento_consent_policy(id) on delete set null,
  event_time timestamptz,
  location_id uuid references public.accento_place_entity(id) on delete set null,
  emotion_vector jsonb not null default '{}'::jsonb,
  source_type text not null default 'manual',
  source_ref jsonb not null default '{}'::jsonb,
  lifecycle jsonb not null default '{"storage_tier":"hot","retention":"active"}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  deleted_at timestamptz
);

create index if not exists accento_memory_owner_idx on public.accento_memory_object(owner_user_id);
create index if not exists accento_memory_location_idx on public.accento_memory_object(location_id);
create index if not exists accento_memory_visibility_idx on public.accento_memory_object(visibility);
create index if not exists accento_memory_status_idx on public.accento_memory_object(status);
create index if not exists accento_memory_type_idx on public.accento_memory_object(memory_type);
create index if not exists accento_memory_event_time_idx on public.accento_memory_object(event_time);

create table if not exists public.accento_memory_asset (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete cascade,
  memory_id uuid not null references public.accento_memory_object(id) on delete cascade,
  asset_type public.accento_asset_type not null,
  storage_url text,
  storage_bucket text,
  storage_path text,
  content_hash text,
  mime_type text,
  size_bytes bigint,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  archived_at timestamptz
);

create index if not exists accento_asset_memory_idx on public.accento_memory_asset(memory_id);
create index if not exists accento_asset_hash_idx on public.accento_memory_asset(content_hash);

create table if not exists public.accento_memory_relationship (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete cascade,
  memory_id uuid not null references public.accento_memory_object(id) on delete cascade,
  entity_type public.accento_entity_type not null,
  entity_id uuid not null,
  role text,
  confidence numeric not null default 1.0 check (confidence >= 0 and confidence <= 1),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists accento_rel_memory_idx on public.accento_memory_relationship(memory_id);
create index if not exists accento_rel_entity_idx on public.accento_memory_relationship(entity_type, entity_id);

create table if not exists public.accento_memory_signal (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete cascade,
  memory_id uuid references public.accento_memory_object(id) on delete cascade,
  place_id uuid references public.accento_place_entity(id) on delete cascade,
  signal_type text not null,
  intensity numeric not null default 0 check (intensity >= 0),
  signal_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists accento_signal_memory_idx on public.accento_memory_signal(memory_id);
create index if not exists accento_signal_place_idx on public.accento_memory_signal(place_id);
create index if not exists accento_signal_type_idx on public.accento_memory_signal(signal_type);

create table if not exists public.accento_interaction_event (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete cascade,
  user_id uuid,
  memory_id uuid references public.accento_memory_object(id) on delete set null,
  place_id uuid references public.accento_place_entity(id) on delete set null,
  action text not null,
  context jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists accento_interaction_user_idx on public.accento_interaction_event(user_id);
create index if not exists accento_interaction_memory_idx on public.accento_interaction_event(memory_id);
create index if not exists accento_interaction_place_idx on public.accento_interaction_event(place_id);

create table if not exists public.accento_dispute_event (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete cascade,
  memory_id uuid not null references public.accento_memory_object(id) on delete cascade,
  raised_by_user_id uuid,
  dispute_type text not null,
  description text,
  status text not null default 'open',
  resolution text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create table if not exists public.accento_commercial_event (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete set null,
  commercial_layer public.accento_commercial_layer not null,
  subject_type text not null,
  subject_id uuid,
  amount_cents integer,
  currency text default 'AUD',
  provider text,
  provider_ref text,
  event_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.accento_reality_ledger (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.accento_tenant(id) on delete set null,
  claim text not null,
  classification public.accento_reality_classification not null default 'PARTIAL',
  evidence_type text,
  evidence_ref text,
  evidence_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.accento_touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_accento_tenant_touch on public.accento_tenant;
create trigger trg_accento_tenant_touch before update on public.accento_tenant for each row execute function public.accento_touch_updated_at();

drop trigger if exists trg_accento_memory_touch on public.accento_memory_object;
create trigger trg_accento_memory_touch before update on public.accento_memory_object for each row execute function public.accento_touch_updated_at();

create or replace function public.accento_log_interaction(
  p_memory_id uuid,
  p_place_id uuid,
  p_action text,
  p_context jsonb default '{}'::jsonb
) returns uuid language plpgsql security definer as $$
declare
  v_id uuid;
begin
  insert into public.accento_interaction_event(user_id, memory_id, place_id, action, context)
  values (auth.uid(), p_memory_id, p_place_id, p_action, coalesce(p_context,'{}'::jsonb))
  returning id into v_id;
  return v_id;
end;
$$;

create or replace function public.accento_place_memory_density(p_place_id uuid)
returns table(place_id uuid, public_memory_count bigint, circle_memory_count bigint, private_memory_count bigint, signal_score numeric)
language sql stable as $$
  select
    p_place_id,
    count(*) filter (where visibility = 'public' and status = 'active') as public_memory_count,
    count(*) filter (where visibility = 'circle' and status = 'active') as circle_memory_count,
    count(*) filter (where visibility = 'private' and status = 'active') as private_memory_count,
    coalesce(sum(ms.intensity),0) as signal_score
  from public.accento_memory_object mo
  left join public.accento_memory_signal ms on ms.memory_id = mo.id
  where mo.location_id = p_place_id;
$$;

create or replace view public.v_accento_public_memory_nearby as
select
  mo.id as memory_id,
  mo.title,
  mo.description,
  mo.memory_type,
  mo.event_time,
  mo.created_at,
  pe.id as place_id,
  pe.name as place_name,
  pe.place_type,
  pe.geo_point,
  mo.metadata
from public.accento_memory_object mo
join public.accento_place_entity pe on pe.id = mo.location_id
where mo.visibility = 'public'
  and mo.status = 'active'
  and mo.deleted_at is null;

create or replace view public.v_accento_place_density as
select
  pe.id as place_id,
  pe.name,
  pe.place_type,
  pe.geo_point,
  count(mo.id) filter (where mo.visibility = 'public' and mo.status = 'active') as public_memory_count,
  count(mo.id) filter (where mo.status = 'active') as total_active_memory_count,
  coalesce(sum(ms.intensity),0) as signal_score
from public.accento_place_entity pe
left join public.accento_memory_object mo on mo.location_id = pe.id
left join public.accento_memory_signal ms on ms.place_id = pe.id or ms.memory_id = mo.id
group by pe.id;

alter table public.accento_tenant enable row level security;
alter table public.accento_place_entity enable row level security;
alter table public.accento_person_entity enable row level security;
alter table public.accento_org_entity enable row level security;
alter table public.accento_consent_policy enable row level security;
alter table public.accento_memory_collection enable row level security;
alter table public.accento_memory_object enable row level security;
alter table public.accento_memory_asset enable row level security;
alter table public.accento_memory_relationship enable row level security;
alter table public.accento_memory_signal enable row level security;
alter table public.accento_interaction_event enable row level security;
alter table public.accento_dispute_event enable row level security;
alter table public.accento_commercial_event enable row level security;
alter table public.accento_reality_ledger enable row level security;

-- Owner and public policies. Service-role bypass remains available for MCP Bridge / backend jobs.
drop policy if exists accento_tenant_owner_all on public.accento_tenant;
create policy accento_tenant_owner_all on public.accento_tenant for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists accento_place_public_read on public.accento_place_entity;
create policy accento_place_public_read on public.accento_place_entity for select using (archived_at is null);

drop policy if exists accento_place_owner_write on public.accento_place_entity;
create policy accento_place_owner_write on public.accento_place_entity for all using (tenant_id in (select id from public.accento_tenant where owner_user_id = auth.uid())) with check (tenant_id in (select id from public.accento_tenant where owner_user_id = auth.uid()) or tenant_id is null);

drop policy if exists accento_person_owner_all on public.accento_person_entity;
create policy accento_person_owner_all on public.accento_person_entity for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists accento_memory_owner_all on public.accento_memory_object;
create policy accento_memory_owner_all on public.accento_memory_object for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists accento_memory_public_read on public.accento_memory_object;
create policy accento_memory_public_read on public.accento_memory_object for select using (visibility = 'public' and status = 'active' and deleted_at is null);

drop policy if exists accento_collection_owner_all on public.accento_memory_collection;
create policy accento_collection_owner_all on public.accento_memory_collection for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists accento_consent_owner_all on public.accento_consent_policy;
create policy accento_consent_owner_all on public.accento_consent_policy for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());

drop policy if exists accento_asset_owner_read on public.accento_memory_asset;
create policy accento_asset_owner_read on public.accento_memory_asset for select using (memory_id in (select id from public.accento_memory_object where owner_user_id = auth.uid() or visibility = 'public'));

drop policy if exists accento_asset_owner_write on public.accento_memory_asset;
create policy accento_asset_owner_write on public.accento_memory_asset for all using (memory_id in (select id from public.accento_memory_object where owner_user_id = auth.uid())) with check (memory_id in (select id from public.accento_memory_object where owner_user_id = auth.uid()));

drop policy if exists accento_rel_owner_read on public.accento_memory_relationship;
create policy accento_rel_owner_read on public.accento_memory_relationship for select using (memory_id in (select id from public.accento_memory_object where owner_user_id = auth.uid() or visibility = 'public'));

drop policy if exists accento_signal_public_read on public.accento_memory_signal;
create policy accento_signal_public_read on public.accento_memory_signal for select using (memory_id in (select id from public.accento_memory_object where owner_user_id = auth.uid() or visibility = 'public') or memory_id is null);

drop policy if exists accento_interaction_self_all on public.accento_interaction_event;
create policy accento_interaction_self_all on public.accento_interaction_event for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists accento_dispute_owner_all on public.accento_dispute_event;
create policy accento_dispute_owner_all on public.accento_dispute_event for all using (raised_by_user_id = auth.uid() or memory_id in (select id from public.accento_memory_object where owner_user_id = auth.uid())) with check (raised_by_user_id = auth.uid() or memory_id in (select id from public.accento_memory_object where owner_user_id = auth.uid()));

drop policy if exists accento_org_public_read on public.accento_org_entity;
create policy accento_org_public_read on public.accento_org_entity for select using (archived_at is null);

drop policy if exists accento_commercial_owner_read on public.accento_commercial_event;
create policy accento_commercial_owner_read on public.accento_commercial_event for select using (tenant_id in (select id from public.accento_tenant where owner_user_id = auth.uid()));

drop policy if exists accento_reality_public_read on public.accento_reality_ledger;
create policy accento_reality_public_read on public.accento_reality_ledger for select using (true);

insert into public.accento_reality_ledger(claim, classification, evidence_type, evidence_ref, evidence_payload)
values (
  'Accento / Augmented Memories memory graph schema deposited to The Pen for MCP Bridge execution',
  'PARTIAL',
  'github_payload',
  'payloads/20260424-accento-augmented-memories-wave10/supabase/001_accento_memory_graph.sql',
  '{"next_gate":"execute via troy-sql-executor and run smoke tests"}'::jsonb
);

commit;
