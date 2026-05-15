-- ============================================================
-- Runtime Language OS — Production Drop v1 schema
-- Additive only. Idempotent. Safe to re-run.
-- Applied to Supabase S1 (lzfgigiyqpuuxslsygjt) on 2026-05-16
-- via migration: runtime_language_production_drop_v1_schema
-- ============================================================

-- ---------- existing tables: additive columns ----------

alter table ops.ontology_nodes
  add column if not exists domain text,
  add column if not exists metadata jsonb default '{}'::jsonb;

alter table ops.ontology_edges
  add column if not exists authority_required text;

alter table ops.ontology_runtime_state
  add column if not exists object_type_id text,
  add column if not exists closure_level text,
  add column if not exists next_owner text,
  add column if not exists failure_owner text,
  add column if not exists metadata jsonb default '{}'::jsonb,
  add column if not exists created_at timestamptz default now();

do $$ begin
  alter table ops.ontology_runtime_state
    add constraint ontology_runtime_state_closure_level_chk
    check (closure_level is null or closure_level in (
      'closed_for_operator','closed_for_bridge',
      'closed_for_runtime','closed_for_human'
    ));
exception when duplicate_object then null; end $$;

alter table ops.ontology_receipts
  add column if not exists actor text,
  add column if not exists classification text,
  add column if not exists receipt_hash text;

do $$ begin
  alter table ops.ontology_receipts
    add constraint ontology_receipts_classification_chk
    check (classification is null or classification in ('REAL','PARTIAL','BLOCKED','FAIL'));
exception when duplicate_object then null; end $$;

alter table ops.ontology_drift
  add column if not exists detected_in text,
  add column if not exists resolved boolean default false;

-- ---------- new tables ----------

create table if not exists ops.ontology_state_transitions (
  id text primary key,
  from_state text not null,
  to_state text not null,
  verb text not null,
  authority text,
  evidence_required boolean default false,
  failure_state text,
  timeout_value interval,
  notes text,
  created_at timestamptz default now()
);

create table if not exists ops.ontology_closure_chain (
  id text primary key,
  state text not null unique,
  requires text,
  evidence text,
  may_claim_done boolean default false,
  ordering int not null
);

create table if not exists ops.ontology_assertions (
  id text primary key,
  subject text not null,
  predicate text not null,
  object text not null,
  evidence_type text,
  confidence numeric default 1.0,
  notes text,
  created_at timestamptz default now()
);

create table if not exists ops.ontology_test_cases (
  id text primary key,
  workstream text not null,
  description text not null,
  expected_outcome text,
  status text default 'pending' check (status in ('pending','passed','failed','blocked')),
  evidence text,
  updated_at timestamptz default now()
);

create table if not exists ops.ontology_connectors (
  id text primary key,
  name text not null,
  surface text not null,
  status text not null default 'unknown' check (status in ('healthy','degraded','failed','unknown')),
  last_checked timestamptz,
  notes text
);

create table if not exists ops.ontology_reviewers (
  id text primary key,
  reviewer text not null,
  role text,
  assigned_tests text[],
  status text default 'unassigned',
  notes text,
  updated_at timestamptz default now()
);

create table if not exists ops.ontology_receipt_ledger (
  id bigserial primary key,
  receipt_id text not null,
  task_id text not null,
  event text not null,
  prior_hash text,
  current_hash text,
  payload jsonb,
  created_at timestamptz default now()
);

-- ---------- indexes ----------

create index if not exists idx_ontology_nodes_type on ops.ontology_nodes(type);
create index if not exists idx_ontology_nodes_term on ops.ontology_nodes(term);
create index if not exists idx_ontology_edges_source on ops.ontology_edges(source_id);
create index if not exists idx_ontology_edges_target on ops.ontology_edges(target_id);
create index if not exists idx_ontology_edges_rel on ops.ontology_edges(relationship);
create index if not exists idx_ontology_translation_profile on ops.ontology_translation(profile_id);
create index if not exists idx_ontology_translation_human on ops.ontology_translation(human_term);
create index if not exists idx_ontology_runtime_state_owner on ops.ontology_runtime_state(owner);
create index if not exists idx_ontology_runtime_state_closure on ops.ontology_runtime_state(closure_level);
create index if not exists idx_ontology_receipts_task on ops.ontology_receipts(task_id);
create index if not exists idx_ontology_receipts_class on ops.ontology_receipts(classification);
create index if not exists idx_receipt_ledger_task on ops.ontology_receipt_ledger(task_id);

-- ---------- trigger: updated_at maintenance ----------

create or replace function ops.fn_set_updated_at() returns trigger as $$
begin
  new.updated_at := now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_ontology_nodes_updated_at on ops.ontology_nodes;
create trigger trg_ontology_nodes_updated_at before update on ops.ontology_nodes
  for each row execute function ops.fn_set_updated_at();

drop trigger if exists trg_ontology_runtime_state_updated_at on ops.ontology_runtime_state;
create trigger trg_ontology_runtime_state_updated_at before update on ops.ontology_runtime_state
  for each row execute function ops.fn_set_updated_at();

drop trigger if exists trg_ontology_translation_updated_at on ops.ontology_translation;
create trigger trg_ontology_translation_updated_at before update on ops.ontology_translation
  for each row execute function ops.fn_set_updated_at();

drop trigger if exists trg_ontology_reviewers_updated_at on ops.ontology_reviewers;
create trigger trg_ontology_reviewers_updated_at before update on ops.ontology_reviewers
  for each row execute function ops.fn_set_updated_at();

drop trigger if exists trg_ontology_test_cases_updated_at on ops.ontology_test_cases;
create trigger trg_ontology_test_cases_updated_at before update on ops.ontology_test_cases
  for each row execute function ops.fn_set_updated_at();

-- ---------- views ----------

create or replace view ops.v_runtime_language_semantic_exceptions as
  select
    r.object_id,
    r.object_type,
    r.closure_level,
    r.owner,
    r.updated_at,
    case
      when r.closure_level = 'closed_for_operator'
        and not exists (
          select 1 from ops.ontology_receipts x
          where x.task_id = r.object_id and x.receipt_type = 'bridge'
        )
        then 'operator_closed_bridge_open'
      when r.closure_level = 'closed_for_bridge'
        and not exists (
          select 1 from ops.ontology_receipts x
          where x.task_id = r.object_id and x.receipt_type = 'runtime'
        )
        then 'bridge_closed_runtime_open'
      when r.closure_level = 'closed_for_runtime'
        and not exists (
          select 1 from ops.ontology_receipts x
          where x.task_id = r.object_id and x.receipt_type = 'human'
        )
        then 'runtime_closed_human_open'
      else null
    end as exception_type
  from ops.ontology_runtime_state r
  where r.closure_level is not null
    and r.closure_level <> 'closed_for_human';

create or replace view ops.v_runtime_language_drift_active as
  select * from ops.ontology_drift
  where resolved is not true
  order by created_at desc;

create or replace view ops.v_runtime_language_health as
  select
    (select count(*)::int from ops.ontology_nodes) as nodes,
    (select count(*)::int from ops.ontology_edges) as edges,
    (select count(*)::int from ops.ontology_translation) as translations,
    (select count(*)::int from ops.ontology_state_transitions) as transitions,
    (select count(*)::int from ops.ontology_closure_chain) as closure_levels,
    (select count(*)::int from ops.ontology_receipts) as receipts,
    (select count(*)::int from ops.ontology_drift where resolved is not true) as active_drift,
    (select count(*)::int from ops.v_runtime_language_semantic_exceptions where exception_type is not null) as active_exceptions,
    (select count(*)::int from ops.ontology_connectors where status = 'healthy') as healthy_connectors,
    (select count(*)::int from ops.ontology_connectors where status in ('degraded','failed','unknown')) as unhealthy_connectors,
    now() as as_of;
