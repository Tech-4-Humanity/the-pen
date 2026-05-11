-- Pen Convergence & Portfolio Governance Engine v1
-- Purpose: schema for Pen triage, duplicate detection, merge/wrapper/kill decisions, HITL governance, and daily executive review.

create extension if not exists pgcrypto;

create table if not exists public.pen_items (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  title text not null,
  description text,
  source_thread text,
  source_url text,
  state text not null default 'INTAKE' check (state in ('INTAKE','NORMALISED','TRIAGED','EXECUTING','MERGED','WRAPPER','DORMANT','ARCHIVED','KILLED')),
  reality_state text not null default 'PARTIAL' check (reality_state in ('REAL','PARTIAL','BLOCKED','PRETEND')),
  business_name text,
  product_name text,
  capability_name text,
  owner_system text,
  canonical_system text,
  overlap_score numeric not null default 0 check (overlap_score >= 0 and overlap_score <= 1),
  monetisation_score numeric not null default 0 check (monetisation_score >= 0 and monetisation_score <= 1),
  execution_score numeric not null default 0 check (execution_score >= 0 and execution_score <= 1),
  reuse_score numeric not null default 0 check (reuse_score >= 0 and reuse_score <= 1),
  strategic_score numeric not null default 0 check (strategic_score >= 0 and strategic_score <= 1),
  recommended_action text check (recommended_action is null or recommended_action in ('CONTINUE','MERGE','WRAPPER','RECLASSIFY','INCUBATE','DORMANT','ARCHIVE','KILL','EXEC_REVIEW')),
  hitl_required boolean not null default false,
  merge_target uuid references public.pen_items(id),
  archived_reason text,
  evidence jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists public.canonical_capabilities (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  capability_name text unique not null,
  canonical_system text not null,
  description text,
  status text not null default 'ACTIVE' check (status in ('ACTIVE','INCUBATING','DORMANT','ARCHIVED','KILLED')),
  owner_business text,
  maturity_level text,
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists public.convergence_links (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  source_item uuid not null references public.pen_items(id) on delete cascade,
  target_item uuid not null references public.pen_items(id) on delete cascade,
  relationship_type text not null check (relationship_type in ('DUPLICATE','SIMILAR','WRAPPER_OF','MERGES_INTO','CONFLICTS_WITH','REUSES','REPLACES')),
  similarity_score numeric not null check (similarity_score >= 0 and similarity_score <= 1),
  recommendation text not null check (recommendation in ('CONTINUE','MERGE','WRAPPER','RECLASSIFY','INCUBATE','DORMANT','ARCHIVE','KILL','EXEC_REVIEW')),
  approved boolean not null default false,
  approved_by text,
  approved_at timestamptz,
  unique (source_item, target_item, relationship_type)
);

create table if not exists public.daily_triage_pack (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  triage_date date not null default current_date,
  item_id uuid references public.pen_items(id) on delete cascade,
  category text not null check (category in ('NEW_ITEM','DUPLICATE_DETECTION','MERGE_CANDIDATE','WRAPPER_CANDIDATE','DRIFT_DETECTION','DORMANT_ASSET','STRATEGIC_SIGNAL','KILL_CANDIDATE','REUSABLE_PRIMITIVE','UNRESOLVED_HITL')),
  severity text not null default 'NORMAL' check (severity in ('LOW','NORMAL','HIGH','CRITICAL')),
  recommendation text not null,
  rationale text not null,
  hitl_required boolean not null default true,
  resolved boolean not null default false,
  resolved_at timestamptz,
  evidence jsonb not null default '{}'::jsonb
);

create index if not exists pen_items_state_idx on public.pen_items(state);
create index if not exists pen_items_capability_idx on public.pen_items(capability_name);
create index if not exists pen_items_canonical_system_idx on public.pen_items(canonical_system);
create index if not exists convergence_links_source_idx on public.convergence_links(source_item);
create index if not exists convergence_links_target_idx on public.convergence_links(target_item);
create index if not exists daily_triage_pack_date_idx on public.daily_triage_pack(triage_date);
create index if not exists daily_triage_pack_hitl_idx on public.daily_triage_pack(hitl_required, resolved);

create or replace function public.pen_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_pen_items_updated_at on public.pen_items;
create trigger trg_pen_items_updated_at
before update on public.pen_items
for each row execute function public.pen_set_updated_at();

create or replace view public.v_pen_daily_governance as
select
  p.id,
  p.title,
  p.state,
  p.reality_state,
  p.business_name,
  p.product_name,
  p.capability_name,
  p.canonical_system,
  p.overlap_score,
  p.recommended_action,
  p.hitl_required,
  count(cl.id) as convergence_link_count,
  max(cl.similarity_score) as max_similarity_score,
  max(dtp.severity) as latest_triage_severity
from public.pen_items p
left join public.convergence_links cl on cl.source_item = p.id or cl.target_item = p.id
left join public.daily_triage_pack dtp on dtp.item_id = p.id and dtp.triage_date = current_date
where p.state not in ('ARCHIVED','KILLED')
group by p.id;

insert into public.canonical_capabilities (capability_name, canonical_system, description, owner_business, maturity_level)
values
  ('orchestration','WorkFamilyAI','Canonical orchestration capability for people, roles, pods, workflows, and organisational cognition.','WorkFamilyAI','ACTIVE'),
  ('consent','ConsentX','Canonical consent and governance state capability.','ConsentX','ACTIVE'),
  ('signal processing','MyNeuralSignal','Canonical signal capture, interpretation, and intervention layer.','MyNeuralSignal','ACTIVE'),
  ('execution','MCP Bridge','Canonical execution, dispatch, and receipt pathway.','The Bridge','ACTIVE'),
  ('governance','GC-BAT','Canonical governance, audit, risk, and foresight layer.','GC-BAT','ACTIVE'),
  ('runtime UI','Synal','Canonical multi-surface interaction and control UI.','Synal','INCUBATING'),
  ('portfolio control','Command Centre','Canonical portfolio visibility, telemetry, and control plane.','Command Centre','ACTIVE'),
  ('education wrapper','Outcome Ready','Canonical education and readiness market wrapper.','Outcome Ready','ACTIVE'),
  ('reading systems','Reading Buddy','Canonical reading improvement product and evidence chain.','Reading Buddy','ACTIVE'),
  ('neuro orchestration','NeuroPAK','Canonical neurotechnology orchestration gateway.','NeuroPAK','INCUBATING'),
  ('robotics orchestration','RATPAK','Canonical robotics and physical autonomy orchestration layer.','RATPAK','INCUBATING'),
  ('evidence','Reality Ledger','Canonical evidence, proof, classification, and receipt ledger.','Reality Ledger','ACTIVE'),
  ('agent registry','Neural Ennead','Canonical agent registry and role-to-agent mapping model.','Neural Ennead','ACTIVE')
on conflict (capability_name) do update set
  canonical_system = excluded.canonical_system,
  description = excluded.description,
  owner_business = excluded.owner_business,
  maturity_level = excluded.maturity_level;

create or replace function public.pen_recommend_action(
  p_overlap numeric,
  p_same_capability boolean,
  p_same_market boolean,
  p_market_signal numeric,
  p_reuse_score numeric,
  p_days_inactive integer
)
returns text
language sql
immutable
as $$
  select case
    when p_overlap >= 0.80 and p_same_capability and p_same_market then 'MERGE'
    when p_same_capability and not p_same_market then 'WRAPPER'
    when coalesce(p_market_signal,0) < 0.20 and coalesce(p_reuse_score,0) < 0.20 then 'DORMANT'
    when coalesce(p_days_inactive,0) >= 90 then 'ARCHIVE'
    when p_overlap >= 0.90 and coalesce(p_reuse_score,0) < 0.30 then 'KILL'
    else 'CONTINUE'
  end;
$$;
