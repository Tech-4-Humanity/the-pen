create table if not exists public.asset_type_catalogue (
  type_code text primary key,
  family text not null,
  type_name text not null,
  description text,
  default_security text,
  default_audit_required boolean default true,
  default_versioned boolean default true,
  typical_locations text[],
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.master_asset_register (
  asset_id uuid primary key default gen_random_uuid(),
  asset_slug text unique not null,
  asset_name text not null,
  asset_type_code text references public.asset_type_catalogue(type_code),
  asset_family text,
  layer integer check (layer between 1 and 7),
  business_owner text,
  product_owner text,
  project_owner text,
  brand_owner text,
  primary_platform text,
  deployment_status text default 'draft',
  truth_status text default 'PARTIAL' check (truth_status in ('REAL','PARTIAL','PRETEND','BLOCKED','ARCHIVED')),
  purpose_business boolean default false,
  purpose_research boolean default false,
  purpose_internal boolean default false,
  purpose_marketing boolean default false,
  purpose_reporting boolean default false,
  purpose_compliance boolean default false,
  reuse_scope text default 'unknown',
  ip_family text,
  agent_dependency boolean default false,
  survey_dependency boolean default false,
  evidence_linked boolean default false,
  rdti_eligible boolean default false,
  source_location text,
  github_url text,
  vercel_url text,
  lovable_url text,
  notion_url text,
  google_drive_url text,
  supabase_project_url text,
  supabase_table_refs text[],
  supabase_storage_paths text[],
  s3_paths text[],
  stripe_product_ids text[],
  stripe_price_ids text[],
  domain_names text[],
  domain_expiry_date date,
  dns_provider text,
  ssl_expiry_date date,
  uptime_monitor_url text,
  asset_count_est integer,
  widget_count integer,
  table_count integer,
  api_count integer,
  page_count integer,
  risk_level text default 'unknown',
  runbook_url text,
  evidence_ids text[],
  notes text,
  created_at timestamptz default now(),
  last_updated_at timestamptz default now()
);

create table if not exists public.service_catalogue (
  service_id uuid primary key default gen_random_uuid(),
  service_slug text unique not null,
  service_name text not null,
  service_family text not null,
  owning_business text,
  catalogue_status text default 'draft',
  truth_status text default 'PARTIAL',
  primary_asset_id uuid references public.master_asset_register(asset_id),
  required_asset_types text[],
  pre_sales_requirements text,
  delivery_requirements text,
  post_sales_requirements text,
  support_requirements text,
  evidence_requirements text,
  telemetry_requirements text,
  pricing_model text,
  stripe_product_ids text[],
  stripe_price_ids text[],
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.product_pricing_registry (
  pricing_id uuid primary key default gen_random_uuid(),
  sku text unique not null,
  product_name text not null,
  owning_business text,
  offer_type text,
  status text default 'draft',
  currency text,
  amount_minor integer,
  interval text,
  stripe_product_id text,
  stripe_price_id text,
  lookup_key text,
  source_system text,
  site_slug text,
  repo_url text,
  doc_url text,
  use_scope text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.registry_reconciliation_loop (
  loop_id uuid primary key default gen_random_uuid(),
  loop_slug text unique not null,
  loop_name text not null,
  cadence text not null,
  authority text default 'autonomous_log_only',
  target_table text not null,
  query_hint text,
  action_on_find text,
  escalation_rule text,
  last_run_at timestamptz,
  next_run_at timestamptz,
  status text default 'active',
  created_at timestamptz default now()
);

create table if not exists public.registry_reality_ledger (
  ledger_id uuid primary key default gen_random_uuid(),
  task_id text not null,
  intent text not null,
  execution text not null,
  output text,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED','PRETEND')),
  evidence jsonb default '[]'::jsonb,
  gaps text[],
  next_action text,
  pressure_flags text[],
  score numeric,
  created_at timestamptz default now()
);

create or replace view public.v_service_catalogue_control as
select
  sc.service_slug,
  sc.service_name,
  sc.service_family,
  sc.owning_business,
  sc.catalogue_status,
  sc.truth_status,
  mar.asset_slug as primary_asset_slug,
  mar.primary_platform,
  mar.deployment_status as asset_deployment_status,
  mar.evidence_linked,
  sc.pricing_model,
  sc.stripe_product_ids,
  sc.stripe_price_ids
from public.service_catalogue sc
left join public.master_asset_register mar on mar.asset_id = sc.primary_asset_id;

insert into public.asset_type_catalogue(type_code,family,type_name,description,default_security,default_audit_required,default_versioned,typical_locations) values
('RE_DS','Research and Evidence','Dataset','Raw or curated dataset used for analysis','Confidential',true,true,array['S3','Supabase']),
('RE_SI','Research and Evidence','Survey Instrument','Survey questions and structure','Confidential',true,true,array['Supabase','GitHub']),
('RE_SC','Research and Evidence','Scoring Model','Scoring rubric or mapping model','Confidential',true,true,array['Supabase','GitHub']),
('RE_RP','Research and Evidence','Replication Pack','Repro bundle: code, data, instructions','Internal',true,true,array['S3','GitHub']),
('PC_SKU','Product and Commercial','SKU','Commercial SKU definition','Internal',true,true,array['Supabase','Stripe']),
('PC_OFR','Product and Commercial','Offer','Named offer with scope','Internal',true,true,array['Supabase','S3']),
('PC_STRP','Product and Commercial','Stripe Product','Stripe product object','Internal',true,true,array['Stripe']),
('PC_STRP_P','Product and Commercial','Stripe Price','Stripe price object','Internal',true,true,array['Stripe']),
('SA_DB','Systems and Architecture','Supabase Table','Database table schema','Confidential',true,true,array['Supabase','GitHub']),
('SA_VER','Systems and Architecture','Vercel Project','Vercel app or project','Internal',false,true,array['Vercel','GitHub']),
('SA_WDG','Systems and Architecture','Widget Snippet','UI snippet stored as widget','Internal',false,true,array['Supabase']),
('GI_EVD','Governance and Integrity','Evidence Ledger','Evidence ledger table or export','Restricted',true,true,array['Supabase','S3']),
('GI_RLY','Governance and Integrity','Reality Ledger','Truth packs and runtime proof','Restricted',true,true,array['Supabase','S3']),
('CI_BOK','Content and IP','Book','Long-form manuscript','Internal',true,true,array['S3','GitHub']),
('CI_ART','Content and IP','Article','Article or essay','Public',false,true,array['Vercel','GitHub']),
('AG_ORC','AI Agents','Orchestrator Agent','Routes intents and coordinates sub-agents','Confidential',true,true,array['Supabase','GitHub']),
('DS_WEB','Digital Surface','Website','Primary marketing or product website','Public',false,true,array['Vercel','GitHub']),
('DS_DSH','Digital Surface','Dashboard','Operational or business dashboard','Internal',false,true,array['Vercel','Supabase']),
('FO_ASR','Financial and Operational','Asset Register','Asset register','Confidential',true,true,array['Supabase']),
('SM_REG','Strategic and Meta','Registry Definition','Registry and table definitions','Confidential',true,true,array['Supabase','GitHub']),
('CR_CMP','Creative','Campaign','Campaign plan and assets','Public',false,true,array['S3','Vercel'])
on conflict (type_code) do update set
  family = excluded.family,
  type_name = excluded.type_name,
  description = excluded.description,
  updated_at = now();

insert into public.service_catalogue(service_slug,service_name,service_family,owning_business,catalogue_status,truth_status,required_asset_types,pre_sales_requirements,delivery_requirements,post_sales_requirements,support_requirements,evidence_requirements,telemetry_requirements,pricing_model,notes) values
('research-asset-register-service','Research Asset Register Service','Registry Operations','Tech 4 Humanity','draft','PARTIAL',array['RE_DS','RE_SI','RE_SC','RE_RP','GI_EVD','GI_RLY'],'Discovery source list, owner hypothesis, asset family rules','Create/update registry rows, classify assets, bind evidence and source locations','Export control sheet, publish Command Centre view, create remediation backlog','Weekly reconciliation and stale asset review','Runtime receipt, source link, reconciliation log','Loop run count, unknown count, duplicate count, REAL/PARTIAL ratio','Internal service initially; later managed service','First service catalogue product for autonomous asset registry maintenance'),
('service-catalogue-control-service','Service Catalogue Control Service','Registry Operations','Tech 4 Humanity','draft','PARTIAL',array['PC_SKU','PC_OFR','PC_STRP','PC_STRP_P','SA_DB','DS_DSH'],'Current offers, pricing sources, Stripe state, business ownership','Map products to services, Stripe IDs, checkout, delivery pack, fulfilment runbook','Publish offer matrix and gap list','Monthly catalogue and price reconciliation','Stripe objects, Supabase rows, GitHub/Drive source docs','Mapped price count, unmapped Stripe count, docs-only offer count','Internal control service; future managed service','Turns product/pricing chaos into sellable catalogue control')
on conflict (service_slug) do update set
  service_name = excluded.service_name,
  updated_at = now();

insert into public.product_pricing_registry(sku,product_name,owning_business,offer_type,status,currency,amount_minor,interval,source_system,use_scope,notes) values
('AISS-FREE','AI Sweet Spots Assessment Free','AI Sweet Spots','assessment','live','AUD',0,null,'stripe_seen','business','Stripe-live family seen in prior extraction'),
('AISS-EXTENDED-1997','AI Sweet Spots Extended','AI Sweet Spots','assessment','live','AUD',1997,null,'stripe_seen','business','Stripe-live family seen in prior extraction'),
('AISS-BUNDLE-3997','AI Sweet Spots Bundle','AI Sweet Spots','bundle','live','AUD',3997,null,'stripe_seen','business','Stripe-live family seen in prior extraction'),
('AISS-COMP-7500','AI Sweet Spots Comprehensive','AI Sweet Spots','assessment','live','AUD',7500,null,'stripe_seen','business','Stripe-live family seen in prior extraction'),
('OR-PERSONAL-PROGRESS-14900','OutcomeReady Personal Progress Pack','OutcomeReady','pack','live','AUD',14900,null,'stripe_seen','business','Stripe-live family seen in prior extraction'),
('OR-EVERYDAY-FUNCTION-8900','OutcomeReady Everyday Function Toolkit','OutcomeReady','toolkit','live','AUD',8900,null,'stripe_seen','business','Stripe-live family seen in prior extraction'),
('OR-FACILITATOR-KIT-59000','OutcomeReady Facilitator Kit','OutcomeReady','kit','live','AUD',59000,null,'stripe_seen','business','Stripe-live family seen in prior extraction'),
('OR-FAMILY-EVIDENCE-49000','OutcomeReady Family Evidence Coach','OutcomeReady','service_pack','live','AUD',49000,null,'stripe_seen','business','Stripe-live family seen in prior extraction'),
('AHC-EXEC-CALCULATOR','AHC Executive Calculator','Augmented Humanity Coach','calculator','draft',null,null,null,'site_registry','reusable','Calculator/quote engine requiring Stripe SKU mapping')
on conflict (sku) do update set
  product_name = excluded.product_name,
  updated_at = now();

insert into public.registry_reconciliation_loop(loop_slug,loop_name,cadence,authority,target_table,query_hint,action_on_find,escalation_rule,status) values
('asset-discovery-loop','Asset Discovery Loop','daily','autonomous_log_only','master_asset_register','Scan GitHub, Vercel, Drive, Notion, Stripe, Supabase, Canva for new assets','Create PARTIAL row with source and owner hypothesis','Escalate only if destructive action required','active'),
('stripe-product-map-loop','Stripe Product Mapping Loop','hourly','autonomous_log_only','product_pricing_registry','Pull Stripe products/prices and compare with product_pricing_registry','Upsert live Stripe objects and flag unmapped rows','Escalate only for pricing changes or destructive action','active'),
('research-evidence-loop','Research Evidence Loop','daily','autonomous_log_only','master_asset_register','Find research artifacts without evidence_ids or source_location','Flag gaps and create remediation row','Escalate if restricted data or ethics boundary appears','active'),
('service-catalogue-readiness-loop','Service Catalogue Readiness Loop','daily','autonomous_log_only','service_catalogue','Find services missing pricing, delivery, support, evidence, telemetry','Downgrade truth_status to PARTIAL and create closure action','Escalate if customer-facing claim is unsupported','active')
on conflict (loop_slug) do update set
  loop_name = excluded.loop_name;

insert into public.registry_reality_ledger(task_id,intent,execution,output,status,evidence,gaps,next_action,pressure_flags,score) values
('asset-register-service-catalogue-v1','Build executable research asset register and service catalogue spine','SQL schema and seed package committed for Bridge/Supabase execution','Tables, view, seed taxonomy, services, pricing starter, reconciliation loops','PARTIAL','[{"type":"github_issue","value":"TML-4PM/the-pen#119"}]'::jsonb,array['Supabase execution receipt absent','Command Centre surface absent','Runtime loop proof absent'],'Run SQL through Bridge executor, capture receipt, wire Command Centre view',array['stagnation_risk','handoff_not_enough'],0.86);
