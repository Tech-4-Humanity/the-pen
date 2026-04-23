-- RPT_AWSHostedZoneRegistry_SupabaseGithubNotion_20260424.sql
-- Purpose: Canonical AWS Route 53 hosted zone registry for Supabase, GitHub, Notion and AWS-hosted evidence workflows.
-- Source: AWS Route 53 hosted zone export supplied in ChatGPT session on 2026-04-24.
-- Rule: Data first. Do not rely on memory-only domain claims. Archive, never delete.

create schema if not exists registry;

create table if not exists registry.aws_hosted_zone_registry (
  id uuid primary key default gen_random_uuid(),
  hosted_zone_name text not null,
  normalized_domain text generated always as (lower(trim(trailing '.' from hosted_zone_name))) stored,
  zone_type text not null default 'Public' check (zone_type in ('Public','Private')),
  created_by text,
  record_count int not null default 0 check (record_count >= 0),
  description text,
  hosted_zone_id text not null,
  aws_service text not null default 'Route 53',
  aws_region text default 'global',
  registrar_source text,
  mail_control_plane boolean generated always as (
    description ilike '%mail%' or description ilike '%T4H mail%'
  ) stored,
  brand_key text,
  business_group text check (business_group is null or business_group in ('G1_CORE','G2_SIGNAL','G3_MISSION','G4_RETAIL_ENTRY','G5_FUN_SIGNAL_SURFACE','RESEARCH','PERSONAL','UNKNOWN')),
  canonical_status text not null default 'observed' check (canonical_status in ('observed','canonical','candidate','deprecated','kill','blocked','unknown')),
  domain_status text not null default 'active' check (domain_status in ('active','inactive','redirect','parking','mail_only','expired','unknown')),
  website_url text,
  notion_page_url text,
  github_source_path text,
  github_commit_sha text,
  supabase_project_ref text default 'lzfgigiyqpuuxslsygjt',
  aws_account_alias text,
  evidence_source text not null default 'aws_route53_export',
  evidence_ref text,
  evidence_hash text,
  reality_state text not null default 'PARTIAL' check (reality_state in ('REAL','PARTIAL','PRETEND','BLOCKED')),
  last_verified_at timestamptz default now(),
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  archived_at timestamptz,
  notes text,
  unique (hosted_zone_id),
  unique (normalized_domain)
);

create table if not exists registry.aws_hosted_zone_registry_audit (
  audit_id uuid primary key default gen_random_uuid(),
  registry_id uuid references registry.aws_hosted_zone_registry(id),
  action text not null check (action in ('insert','update','archive','verify','classify','sync','error')),
  actor text not null default 'system',
  source_system text not null default 'chatgpt',
  before_row jsonb,
  after_row jsonb,
  evidence_ref text,
  created_at timestamptz default now()
);

create or replace function registry.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_aws_hosted_zone_registry_updated_at on registry.aws_hosted_zone_registry;
create trigger trg_aws_hosted_zone_registry_updated_at
before update on registry.aws_hosted_zone_registry
for each row execute function registry.touch_updated_at();

create or replace view registry.v_aws_hosted_zone_registry_active as
select
  normalized_domain,
  hosted_zone_name,
  hosted_zone_id,
  zone_type,
  record_count,
  description,
  mail_control_plane,
  brand_key,
  business_group,
  canonical_status,
  domain_status,
  website_url,
  reality_state,
  last_verified_at,
  notes
from registry.aws_hosted_zone_registry
where archived_at is null
order by normalized_domain;

create or replace view registry.v_aws_hosted_zone_registry_attention as
select *
from registry.aws_hosted_zone_registry
where archived_at is null
  and (
    canonical_status in ('candidate','kill','blocked','unknown')
    or domain_status in ('inactive','expired','unknown')
    or reality_state <> 'REAL'
  )
order by canonical_status, normalized_domain;

alter table registry.aws_hosted_zone_registry enable row level security;
alter table registry.aws_hosted_zone_registry_audit enable row level security;

do $$ begin
  create policy aws_hosted_zone_registry_service_all
  on registry.aws_hosted_zone_registry
  for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');
exception when duplicate_object then null; end $$;

do $$ begin
  create policy aws_hosted_zone_registry_read_authenticated
  on registry.aws_hosted_zone_registry
  for select
  using (auth.role() in ('authenticated','service_role'));
exception when duplicate_object then null; end $$;

do $$ begin
  create policy aws_hosted_zone_registry_audit_service_all
  on registry.aws_hosted_zone_registry_audit
  for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');
exception when duplicate_object then null; end $$;

insert into registry.aws_hosted_zone_registry
(hosted_zone_name, zone_type, created_by, record_count, description, hosted_zone_id, registrar_source, canonical_status, domain_status, evidence_ref, reality_state, notes)
values
('aquame.com.au','Public','Route 53',9,'T4H mail - aquame.com.au','Z05443101HGU9W9C9FKGS',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('consentx.com.au','Public','Route 53',8,'T4H mail control plane','Z0654524JVP0PQPG9F8I',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('extremespotto.com.au','Public','Route 53',8,'T4H mail - extremespotto.com.au','Z0553914UPOFS6IXVA5S',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('girlmath.com.au','Public','Route 53',6,'T4H mail - girlmath.com.au','Z071160424KU6Y6DTQ251',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('houseofbiscuits.com.au','Public','Route 53',9,'T4H mail - houseofbiscuits.com.au','Z06491952KQ89MBP1P1H9',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('innovateme.com.au','Public','Route 53',9,'HostedZone created by Route53 Registrar','Z079317823W58DN6OSBF5','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('justpoint.com.au','Public','Route 53',8,'T4H mail - justpoint.com.au','Z05549122Z4MWTPIY92V4',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('justwalkout.com.au','Public','Route 53',7,'HostedZone created by Route53 Registrar','Z08638673ASO229985BRE','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('medledger.com.au','Public','Route 53',8,'T4H mail - medledger.com.au','Z055491911M5PR8HUMY2T',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('missioncritical.com.au','Public','Route 53',7,'T4H mail - missioncritical.com.au','Z0554449534YVG96K5IX',null,'kill','unknown','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','User flagged Mission Critical as non-owned/incorrect concept; keep evidence but do not treat as canonical brand without registrar proof'),
('neuropak.com.au','Public','Route 53',8,'T4H mail - neuropak.com.au','Z00303771GOO22FCFKENE',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('outcomeready.com.au','Public','Route 53',9,'T4H mail - outcomeready.com.au','Z00318281IIVRAYCEK9AF',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ownmyai.com.au','Public','Route 53',4,'HostedZone created by Route53 Registrar','Z0689350G53HNHYDIYCG','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ratpak.com.au','Public','Route 53',6,'T4H mail - ratpak.com.au','Z0031344MNX9BC702MNF',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('readingbuddy.com.au','Public','Route 53',8,'T4H mail - readingbuddy.com.au','Z05532173MOOUITXAZBYW',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('rhythmmethod.com.au','Public','Route 53',8,'T4H mail - rhythmmethod.com.au','Z0030372N0F3ULLFZMT',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('smartpark.com.au','Public','Route 53',8,'T4H mail - smartpark.com.au','Z07120482FVCQDNJBY0',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('tech4humanity.com.au','Public','Route 53',44,'HostedZone created by Route53 Registrar','Z0654647JP0C7H6Q99A','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('vuontroi.com.au','Public','Route 53',8,'T4H mail - vuontroi.com.au','Z05544152YER3QDEK14NP',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('xces.com.au','Public','Route 53',6,'T4H mail - xces.com.au','Z07096592PS6XAJX6U7B1',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ownmyai.biz','Public','Route 53',6,'HostedZone created by Route53 Registrar','Z0245089ZLR3Q0BN78JC','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ownyourai.biz','Public','Route 53',6,'HostedZone created by Route53 Registrar','Z0245403FPL2HHGXFR8G','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('augmented-humanity.coach','Public','Route 53',8,'T4H mail - augmented-humanity.coach','Z0647405H8RNDCIO56KP',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Hyphenated domain exists as hosted zone'),
('augmentedhumanity.coach','Public','Route 53',31,'HostedZone created by Route53 Registrar','Z08476712DDP54LIAK52K','Route53 Registrar','canonical','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Non-hyphenated AHC domain exists as hosted zone'),
('ai-olympics.com','Public','Route 53',6,'T4H mail - ai-olympics.com','Z0708966EDCK4QE4ZU0A',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('aioopsies.com','Public','Route 53',15,'HostedZone created by Route53 Registrar','Z057659834X98VIT33AI5','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('aisweetspots.com','Public','Route 53',6,'HostedZone created by Route53 Registrar','Z030455317134OXVCB467','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('apacjwo.com','Public','Route 53',8,'T4H mail - apacjwo.com','Z0649190SJDALDNMVKLF',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('apexpredatorinsurance.com','Public','Route 53',13,'HostedZone created by Route53 Registrar','Z0584644NMCDXYW7NUEW','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('augmentedhumanitycoach.com','Public','Route 53',8,'HostedZone created by Route53 Registrar','Z0251003F5NXEJ37C8U9','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('augmentedmemories.com','Public','Route 53',7,'T4H mail - augmentedmemories.com','Z0648715ZGCILLVTLUUN',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('extremespotto.com','Public','Route 53',6,'HostedZone created by Route53 Registrar','Z091502528UD5F5GC0QB9','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('far-cage.com','Public','Route 53',9,'T4H mail - far-cage.com','Z06500322LS5MMYLF18JU',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('gcbat.com','Public','Route 53',6,'T4H mail - gcbat.com','Z0029482H5ZOQEKKZD6S',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('holo-org.com','Public','Route 53',20,'HostedZone created by Route53 Registrar','Z09186532X6FA05SIM2W1','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('lifegraphplus.com','Public','Route 53',9,'T4H mail - lifegraphplus.com','Z06487083PS67D4E1J2IP',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('mcp-native.com','Public','Route 53',9,'HostedZone created by Route53 Registrar','Z10254733AU1YFB5862AE','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('myneuralsignal.com','Public','Route 53',9,'T4H mail - myneuralsignal.com','Z05532442OL4T1XV0K4YA',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('outcome-ready.com','Public','Route 53',6,'HostedZone created by Route53 Registrar','Z025375123P4TXTAV24VC','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('workfamilyai.com','Public','Route 53',8,'T4H mail - workfamilyai.com','Z003000022KXVR668NUSV',null,'observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ownmyai.info','Public','Route 53',17,'HostedZone created by Route53 Registrar','Z02313562QPI1OA7Y2RUB','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ownyourai.info','Public','Route 53',8,'HostedZone created by Route53 Registrar','Z06938063LUVVPUSSU0DK','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('innovateme.link','Public','Route 53',16,'HostedZone created by Route53 Registrar','Z06485818WLPXK20NHO2','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('aiolympics.net','Public','Route 53',5,'HostedZone created by Route53 Registrar','Z083599317NU1HG3GEC9I','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('getjustwalkout.net','Public','Route 53',4,'HostedZone created by Route53 Registrar','Z0910853KK28YLKNLP45','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ownmyai.net','Public','Route 53',4,'HostedZone created by Route53 Registrar','Z04711642HFEFLAUTTSWG','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ownyourai.net','Public','Route 53',4,'HostedZone created by Route53 Registrar','Z0689274YLEL59QW9YR0','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('tech4humanity.net','Public','Route 53',45,'HostedZone created by Route53 Registrar','Z091085430OM5JEACZFIA','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ai4tradies.org','Public','Route 53',11,'HostedZone created by Route53 Registrar','Z009902420KRBFDNI6LEZ','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('all-chemist.org','Public','Route 53',11,'HostedZone created by Route53 Registrar','Z104759012I1WSCE4OJUR','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('augmentedmemories.org','Public','Route 53',11,'HostedZone created by Route53 Registrar','Z01265683V13K2OB7GZ7K','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('consentx.org','Public','Route 53',7,'HostedZone created by Route53 Registrar','Z09631033P8AWSCUQ207S','Route53 Registrar','canonical','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','User confirmed correct real URL'),
('far-cage.org','Public','Route 53',6,'HostedZone created by Route53 Registrar','Z00789523DGVM3TJ4RI1I','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('gcbat.org','Public','Route 53',22,'HostedZone created by Route53 Registrar','Z056553728NW1DZWK2248','Route53 Registrar','canonical','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','User confirmed correct real URL'),
('globaltyres.org','Public','Route 53',18,'HostedZone created by Route53 Registrar','Z08114741PB6S8T6B2J1R','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('ownmyai.org','Public','Route 53',6,'HostedZone created by Route53 Registrar','Z05416873AMO3R6K7C58E','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Contact form issue previously flagged'),
('ownyourai.org','Public','Route 53',10,'HostedZone created by Route53 Registrar','Z02448992K1XN9OGHY7KT','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Contact form issue previously flagged'),
('workfamilyai.org','Public','Route 53',17,'HostedZone created by Route53 Registrar','Z07093672N00FT9ASWWXE','Route53 Registrar','canonical','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','User confirmed correct real URL'),
('innovateme.systems','Public','Route 53',9,'HostedZone created by Route53 Registrar','Z0648582XB53K9SAXVHL','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table'),
('enteraustralia.tech','Public','Route 53',10,'HostedZone created by Route53 Registrar','Z0571093IP6IX69IAX52','Route53 Registrar','observed','active','AWS Route 53 hosted zone export 2026-04-24','PARTIAL','Imported from AWS hosted zone table')
on conflict (hosted_zone_id) do update set
  hosted_zone_name = excluded.hosted_zone_name,
  zone_type = excluded.zone_type,
  created_by = excluded.created_by,
  record_count = excluded.record_count,
  description = excluded.description,
  registrar_source = excluded.registrar_source,
  canonical_status = excluded.canonical_status,
  domain_status = excluded.domain_status,
  evidence_ref = excluded.evidence_ref,
  reality_state = excluded.reality_state,
  notes = excluded.notes,
  last_verified_at = now();

-- Smoke checks
-- select count(*) from registry.aws_hosted_zone_registry;
-- select * from registry.v_aws_hosted_zone_registry_attention;
