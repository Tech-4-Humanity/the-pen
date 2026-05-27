-- Research Hub / Forge / Registry Schema v1.0
-- Status: PARTIAL until applied to Supabase and receipt captured
-- Purpose: canonical table-of-tables substrate for Research Hub / Forge / Factory / Bridge / Reality Ledger operations

create table if not exists t4h_entity_registry (
  entity_id text primary key,
  entity_type text not null,
  title text not null,
  canonical_name text,
  description text,
  status text not null default 'RAW',
  owner text,
  source_system text,
  source_ref text,
  visibility_class text not null default 'private_internal',
  authority_tier text not null default 'AUTONOMOUS',
  risk_level text not null default 'normal',
  evidence_score numeric default 0,
  commercial_score numeric default 0,
  rdti_relevant boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint entity_status_check check (status in ('RAW','TRIAGED','PARTIAL','VALIDATED','REAL','MONETISED','AUTOMATED','ARCHIVED','REJECTED','BLOCKED')),
  constraint visibility_class_check check (visibility_class in ('private_internal','client_visible','public','regulated','tax_sensitive','commercial_sensitive','personal_sensitive')),
  constraint authority_tier_check check (authority_tier in ('AUTONOMOUS','LOG_ONLY','GATED','BLOCKED'))
);

create table if not exists t4h_asset_registry (
  asset_id text primary key,
  entity_id text not null references t4h_entity_registry(entity_id) on delete cascade,
  asset_type text not null,
  title text not null,
  maturity_state text not null default 'RAW',
  canonical_status text not null default 'unknown',
  source_system text,
  source_ref text,
  owner text,
  evidence_id text,
  service_id text,
  receipt_id text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint asset_maturity_state_check check (maturity_state in ('RAW','TRIAGED','PARTIAL','VALIDATED','REAL','MONETISED','AUTOMATED','ARCHIVED','REJECTED','BLOCKED')),
  constraint canonical_status_check check (canonical_status in ('canonical','duplicate','fork','archive','superseded','unknown'))
);

create table if not exists t4h_file_registry (
  file_id text primary key,
  entity_id text references t4h_entity_registry(entity_id) on delete set null,
  asset_id text references t4h_asset_registry(asset_id) on delete set null,
  source_system text not null,
  source_ref text not null,
  current_path text,
  proposed_path text,
  filename text,
  mime_type text,
  hash_sha256 text,
  canonical_status text not null default 'unknown',
  duplicate_cluster_id text,
  visibility_class text not null default 'private_internal',
  move_manifest_required boolean default true,
  confidence numeric default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint file_canonical_status_check check (canonical_status in ('canonical','duplicate','fork','archive','superseded','unknown')),
  constraint file_visibility_class_check check (visibility_class in ('private_internal','client_visible','public','regulated','tax_sensitive','commercial_sensitive','personal_sensitive'))
);

create table if not exists t4h_service_catalogue (
  service_id text primary key,
  entity_id text not null references t4h_entity_registry(entity_id) on delete cascade,
  asset_id text references t4h_asset_registry(asset_id) on delete set null,
  service_name text not null,
  audience text,
  offer_summary text,
  price_status text not null default 'unpriced',
  price_amount numeric,
  currency text default 'AUD',
  maturity_state text not null default 'PARTIAL',
  evidence_id text,
  owner text,
  go_to_market_status text default 'not_ready',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint service_maturity_check check (maturity_state in ('RAW','TRIAGED','PARTIAL','VALIDATED','REAL','MONETISED','AUTOMATED','ARCHIVED','REJECTED','BLOCKED'))
);

create table if not exists t4h_evidence_registry (
  evidence_id text primary key,
  entity_id text references t4h_entity_registry(entity_id) on delete set null,
  asset_id text references t4h_asset_registry(asset_id) on delete set null,
  evidence_type text not null,
  evidence_value text not null,
  source_system text,
  source_ref text,
  grade text not null default 'C',
  confidence numeric default 0,
  rdti_relevant boolean default false,
  attack_surface text,
  weakness text,
  defence text,
  receipt_id text,
  created_at timestamptz default now(),
  constraint evidence_grade_check check (grade in ('A','B','C','D'))
);

create table if not exists t4h_execution_receipts (
  receipt_id text primary key,
  action text not null,
  entity_id text references t4h_entity_registry(entity_id) on delete set null,
  source text,
  target text,
  status text not null,
  evidence_type text,
  evidence_value text,
  payload_hash text,
  request_id text,
  response_ref text,
  next_action text,
  error_reason text,
  created_at timestamptz default now(),
  constraint receipt_status_check check (status in ('REAL','PARTIAL','BLOCKED','FAILED'))
);

create table if not exists t4h_bridge_payloads (
  payload_id text primary key,
  entity_id text references t4h_entity_registry(entity_id) on delete set null,
  issue_number integer,
  intent text not null,
  requested_action text not null,
  authority text not null default 'allow_autonomous_non_destructive',
  payload_json jsonb not null,
  payload_hash text not null,
  status text not null default 'READY',
  receipt_id text references t4h_execution_receipts(receipt_id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint bridge_payload_status_check check (status in ('READY','SUBMITTED','RECEIPTED','FAILED','BLOCKED'))
);

create table if not exists t4h_duplicate_clusters (
  duplicate_cluster_id text primary key,
  cluster_type text not null,
  canonical_ref text,
  status text not null default 'open',
  summary text,
  resolution_reason text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint duplicate_cluster_status_check check (status in ('open','resolved','blocked','archived'))
);

create table if not exists t4h_runtime_events (
  runtime_event_id text primary key,
  entity_id text references t4h_entity_registry(entity_id) on delete set null,
  event_type text not null,
  source_system text,
  source_ref text,
  severity text not null default 'normal',
  status text not null default 'open',
  payload jsonb,
  receipt_id text references t4h_execution_receipts(receipt_id) on delete set null,
  created_at timestamptz default now(),
  constraint runtime_event_severity_check check (severity in ('low','normal','high','critical')),
  constraint runtime_event_status_check check (status in ('open','closed','blocked','retrying'))
);

create table if not exists t4h_cost_allocations (
  cost_allocation_id text primary key,
  entity_id text references t4h_entity_registry(entity_id) on delete set null,
  supplier text,
  amount numeric,
  currency text default 'AUD',
  period_start date,
  period_end date,
  allocation_logic text,
  evidence_id text references t4h_evidence_registry(evidence_id) on delete set null,
  confidence numeric default 0,
  created_at timestamptz default now()
);

create table if not exists t4h_time_allocations (
  time_allocation_id text primary key,
  entity_id text references t4h_entity_registry(entity_id) on delete set null,
  actor text,
  activity_class text,
  hours numeric,
  period_start date,
  period_end date,
  allocation_logic text,
  confidence numeric default 0,
  evidence_id text references t4h_evidence_registry(evidence_id) on delete set null,
  created_at timestamptz default now()
);

-- Queue views
create or replace view v_new_unclassified_assets as
select * from t4h_asset_registry where maturity_state in ('RAW','TRIAGED') or canonical_status = 'unknown';

create or replace view v_duplicate_conflicts as
select * from t4h_file_registry where canonical_status in ('duplicate','fork','unknown') or duplicate_cluster_id is not null;

create or replace view v_missing_receipts as
select * from t4h_asset_registry where receipt_id is null and maturity_state in ('PARTIAL','VALIDATED','REAL','MONETISED','AUTOMATED');

create or replace view v_ready_to_promote as
select * from t4h_asset_registry where maturity_state = 'VALIDATED' and evidence_id is not null and receipt_id is not null;

create or replace view v_rdti_evidence_candidates as
select * from t4h_evidence_registry where rdti_relevant = true;

create or replace view v_commercialisation_candidates as
select e.* from t4h_entity_registry e where e.commercial_score >= 0.7 and e.status in ('VALIDATED','REAL');

create or replace view v_blocked_by_authority as
select * from t4h_entity_registry where authority_tier in ('GATED','BLOCKED') or status = 'BLOCKED';

create or replace view v_runtime_failures as
select * from t4h_runtime_events where status in ('open','blocked','retrying') and severity in ('high','critical');
