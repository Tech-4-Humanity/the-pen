-- Accento / Augmented Memories Smoke Tests
-- Purpose: prove schema, place graph, memory object, visibility, density view, and Reality Ledger write.
-- Expected: all SELECT checks return rows and final ledger row states PARTIAL until live Bridge execution evidence is attached.

begin;

-- Seed tenant
insert into public.accento_tenant(name, tenant_type, metadata)
values ('Accento Smoke Tenant', 'test', '{"source":"smoke_test"}'::jsonb)
returning id;

-- Seed place
with t as (
  select id from public.accento_tenant where name = 'Accento Smoke Tenant' order by created_at desc limit 1
)
insert into public.accento_place_entity(tenant_id, name, place_type, geo_point, locality, region, country, verified, external_refs)
select t.id, 'Accento Test Corner', 'cafe', ST_SetSRID(ST_MakePoint(151.2093, -33.8688),4326)::geography, 'Sydney', 'NSW', 'Australia', true, '{"test":"smoke"}'::jsonb
from t
returning id;

-- Seed public memory
with t as (
  select id as tenant_id from public.accento_tenant where name = 'Accento Smoke Tenant' order by created_at desc limit 1
), p as (
  select id as place_id from public.accento_place_entity where name = 'Accento Test Corner' order by created_at desc limit 1
)
insert into public.accento_memory_object(
  tenant_id, owner_user_id, title, description, memory_type, status, visibility, event_time, location_id, emotion_vector, source_type, metadata
)
select
  t.tenant_id,
  gen_random_uuid(),
  'Smoke Test Public Memory',
  'This proves the public place memory layer can store and surface a discoverable memory.',
  'personal',
  'active',
  'public',
  now(),
  p.place_id,
  '{"nostalgia":0.7,"joy":0.8}'::jsonb,
  'smoke_test',
  '{"wave":"10","product":"Accento Memory Places MVP"}'::jsonb
from t,p
returning id;

-- Add signal
with m as (
  select id as memory_id, tenant_id, location_id from public.accento_memory_object where title = 'Smoke Test Public Memory' order by created_at desc limit 1
)
insert into public.accento_memory_signal(tenant_id, memory_id, place_id, signal_type, intensity, signal_payload)
select tenant_id, memory_id, location_id, 'proximity_density', 9.5, '{"source":"smoke_test"}'::jsonb
from m;

-- Add asset shell
with m as (
  select id as memory_id, tenant_id from public.accento_memory_object where title = 'Smoke Test Public Memory' order by created_at desc limit 1
)
insert into public.accento_memory_asset(tenant_id, memory_id, asset_type, storage_url, metadata)
select tenant_id, memory_id, 'text', 'memory://smoke-test/public-memory', '{"synthetic":true}'::jsonb
from m;

-- Proof queries
select 'CHECK_PUBLIC_MEMORY_VISIBLE' as check_name, count(*) as row_count
from public.v_accento_public_memory_nearby
where title = 'Smoke Test Public Memory';

select 'CHECK_PLACE_DENSITY' as check_name, public_memory_count, total_active_memory_count, signal_score
from public.v_accento_place_density
where name = 'Accento Test Corner';

select 'CHECK_SCHEMA_OBJECTS' as check_name, count(*) as required_tables_present
from information_schema.tables
where table_schema = 'public'
  and table_name in (
    'accento_tenant','accento_place_entity','accento_person_entity','accento_org_entity','accento_consent_policy',
    'accento_memory_collection','accento_memory_object','accento_memory_asset','accento_memory_relationship','accento_memory_signal',
    'accento_interaction_event','accento_dispute_event','accento_commercial_event','accento_reality_ledger'
  );

insert into public.accento_reality_ledger(claim, classification, evidence_type, evidence_ref, evidence_payload)
values (
  'Accento smoke test script deposited and ready for Bridge execution',
  'PARTIAL',
  'github_smoke_test',
  'payloads/20260424-accento-augmented-memories-wave10/supabase/002_accento_smoke_tests.sql',
  '{"expected_checks":["CHECK_PUBLIC_MEMORY_VISIBLE","CHECK_PLACE_DENSITY","CHECK_SCHEMA_OBJECTS"],"next_gate":"live Supabase execution"}'::jsonb
);

commit;
