-- ============================================================================
-- Content Signal Operating System — Schema Migration
-- Source of truth: TML-4PM/the-pen :: CONTENT_SIGNAL_HOUSE_RULES.md
--   commit 2b82c6bbf52153a148bd1310cec10ac20b9cfe40
--   blob   49a4e9c67c3bc14ecae73d1c975a4fd803e8097e
-- Target: Supabase S1 (lzfgigiyqpuuxslsygjt) — canonical write target
-- Properties: idempotent, additive-only, RLS locked-default, reversible
--             (see teardown/content_signal_os_teardown.sql)
-- Autonomy: schema + ingestion + escalation + packaging are NON-HITL per the
--           house rules. Publishing remains HITL via approval_gate +
--           publishing_queue (state defaults to held/pending). Nothing here
--           publishes, pays, or distributes.
-- Applied: 2026-05-18, canonical reality_ledger id d8808133-054c-47eb-a332-66ea982c1226 (PARTIAL)
-- ============================================================================

create schema if not exists content_signal;
comment on schema content_signal is
  'Content Signal OS. Source: the-pen/CONTENT_SIGNAL_HOUSE_RULES.md @ 2b82c6b. RDTI: is_rd=true project_code=CONTENT-SIGNAL.';

create table if not exists content_signal.conversation_signal (
  id uuid primary key default gen_random_uuid(),
  source_type text not null check (source_type in ('live_llm','chat_export','linkedin_article','comment','reaction','manual')),
  raw_text text not null,
  detected_intent text,
  thread_ref text,
  payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz,
  ingested_at timestamptz not null default now()
);

create table if not exists content_signal.llm_chat_source (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  export_name text not null,
  file_ref text,
  message_count integer not null default 0,
  status text not null default 'registered' check (status in ('registered','ingesting','ingested','failed')),
  ingested_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.article_export_source (
  id uuid primary key default gen_random_uuid(),
  source_name text not null,
  export_ref text,
  article_count integer not null default 0,
  status text not null default 'registered' check (status in ('registered','ingesting','ingested','failed')),
  ingested_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.brand_voice_registry (
  id uuid primary key default gen_random_uuid(),
  voice_key text unique not null,
  speaker text, business text, audience text, tone text,
  allowed_claims jsonb not null default '[]'::jsonb,
  banned_phrases jsonb not null default '[]'::jsonb,
  default_footer text,
  channels jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.point_of_view_registry (
  id uuid primary key default gen_random_uuid(),
  pov_key text unique not null,
  business text, stance text, description text,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.platform_registry (
  id uuid primary key default gen_random_uuid(),
  platform_key text unique not null,
  name text not null,
  is_primary boolean not null default false,
  status text not null default 'active' check (status in ('active','planned','disabled')),
  created_at timestamptz not null default now()
);

create table if not exists content_signal.platform_format_rule (
  id uuid primary key default gen_random_uuid(),
  platform_id uuid not null references content_signal.platform_registry(id) on delete cascade,
  format_key text not null,
  max_length integer,
  media_required jsonb not null default '[]'::jsonb,
  cadence text,
  approval_required boolean not null default true,
  created_at timestamptz not null default now(),
  unique (platform_id, format_key)
);

create table if not exists content_signal.image_style_registry (
  id uuid primary key default gen_random_uuid(),
  style_key text unique not null,
  description text,
  palette jsonb not null default '[]'::jsonb,
  constraints jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.topic_registry (
  id uuid primary key default gen_random_uuid(),
  topic_key text unique not null,
  label text not null,
  description text,
  occurrence_count integer not null default 0,
  escalation_state text not null default 'one_off' check (escalation_state in ('one_off','two_off','three_off','pillar','strategic')),
  first_seen timestamptz not null default now(),
  last_seen timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists content_signal.topic_occurrence (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references content_signal.topic_registry(id) on delete cascade,
  signal_id uuid references content_signal.conversation_signal(id) on delete set null,
  weight numeric not null default 1,
  context text,
  occurred_at timestamptz not null default now()
);

create table if not exists content_signal.topic_relationship (
  id uuid primary key default gen_random_uuid(),
  from_topic_id uuid not null references content_signal.topic_registry(id) on delete cascade,
  to_topic_id uuid not null references content_signal.topic_registry(id) on delete cascade,
  relation_type text not null default 'related',
  strength numeric not null default 0.5,
  created_at timestamptz not null default now(),
  check (from_topic_id <> to_topic_id),
  unique (from_topic_id, to_topic_id, relation_type)
);

create table if not exists content_signal.series_registry (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references content_signal.topic_registry(id) on delete set null,
  title text not null,
  status text not null default 'candidate' check (status in ('candidate','planned','active','done','dropped')),
  release_order jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.content_asset (
  id uuid primary key default gen_random_uuid(),
  asset_type text not null default 'article' check (asset_type in ('article','essay','series','campaign','product','partnership','ebook','course','other')),
  title text, body_md text,
  length_class text check (length_class in ('short','normal','long','extra_long','essay','platform')),
  status text not null default 'draft' check (status in ('draft','packaged','approved','published','archived')),
  brand_voice_id uuid references content_signal.brand_voice_registry(id) on delete set null,
  pov_id uuid references content_signal.point_of_view_registry(id) on delete set null,
  source_signal_id uuid references content_signal.conversation_signal(id) on delete set null,
  is_rd boolean not null default true,
  project_code text not null default 'CONTENT-SIGNAL',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists content_signal.content_package (
  id uuid primary key default gen_random_uuid(),
  content_asset_id uuid not null references content_signal.content_asset(id) on delete cascade,
  length_class text,
  title_options jsonb not null default '[]'::jsonb,
  summary text,
  stream_assignment text,
  pov_id uuid references content_signal.point_of_view_registry(id) on delete set null,
  related_articles jsonb not null default '[]'::jsonb,
  series_candidate boolean not null default false,
  suggested_images jsonb not null default '[]'::jsonb,
  social_cutdowns jsonb not null default '[]'::jsonb,
  approval_checklist jsonb not null default '[]'::jsonb,
  publishing_target text,
  reuse_path text,
  status text not null default 'draft' check (status in ('draft','awaiting_approval','approved','rejected','published')),
  created_at timestamptz not null default now()
);

create table if not exists content_signal.media_asset (
  id uuid primary key default gen_random_uuid(),
  asset_type text not null default 'image' check (asset_type in ('image','video','audio')),
  uri text, brief text,
  style_id uuid references content_signal.image_style_registry(id) on delete set null,
  content_asset_id uuid references content_signal.content_asset(id) on delete cascade,
  status text not null default 'briefed' check (status in ('briefed','generated','approved','rejected')),
  created_at timestamptz not null default now()
);

create table if not exists content_signal.approval_gate (
  id uuid primary key default gen_random_uuid(),
  content_package_id uuid not null references content_signal.content_package(id) on delete cascade,
  gate_type text not null check (gate_type in ('article','image','pov','legal','paid_distribution')),
  state text not null default 'pending' check (state in ('pending','approved','rejected')),
  decided_by text, decided_at timestamptz, notes text,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.publishing_queue (
  id uuid primary key default gen_random_uuid(),
  content_package_id uuid not null references content_signal.content_package(id) on delete cascade,
  platform_id uuid references content_signal.platform_registry(id) on delete set null,
  scheduled_for timestamptz,
  state text not null default 'held' check (state in ('held','queued','approved','published','failed')),
  handoff_ref text,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.engagement_fact (
  id uuid primary key default gen_random_uuid(),
  content_asset_id uuid references content_signal.content_asset(id) on delete cascade,
  platform_id uuid references content_signal.platform_registry(id) on delete set null,
  metric text not null check (metric in ('views','reactions','comments','shares','clicks','saves')),
  value numeric not null default 0,
  captured_at timestamptz not null default now()
);

create table if not exists content_signal.topic_performance_rollup (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references content_signal.topic_registry(id) on delete cascade,
  window_start timestamptz not null,
  window_end timestamptz not null,
  total_views numeric not null default 0,
  total_engagement numeric not null default 0,
  score numeric not null default 0,
  computed_at timestamptz not null default now()
);

create table if not exists content_signal.gap_analysis (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references content_signal.topic_registry(id) on delete set null,
  gap_type text not null,
  recommendation text,
  priority text not null default 'P3' check (priority in ('P1','P2','P3','P4')),
  created_at timestamptz not null default now()
);

create table if not exists content_signal.monetisation_map (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references content_signal.topic_registry(id) on delete set null,
  asset_path text not null,
  revenue_hypothesis text,
  status text not null default 'hypothesis' check (status in ('hypothesis','validating','live','dropped')),
  created_at timestamptz not null default now()
);

create table if not exists content_signal.partnership_signal (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references content_signal.topic_registry(id) on delete set null,
  partner_hint text, rationale text,
  strength numeric not null default 0.5,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.product_signal (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references content_signal.topic_registry(id) on delete set null,
  product_hint text, rationale text,
  strength numeric not null default 0.5,
  created_at timestamptz not null default now()
);

create table if not exists content_signal.campaign_registry (
  id uuid primary key default gen_random_uuid(),
  campaign_key text unique not null,
  title text not null,
  objective text,
  topic_ids jsonb not null default '[]'::jsonb,
  status text not null default 'planned' check (status in ('planned','active','paused','done')),
  created_at timestamptz not null default now()
);

create table if not exists content_signal.reality_ledger_receipt (
  id uuid primary key default gen_random_uuid(),
  system text not null default 'content_signal_os',
  component text not null,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED')),
  evidence jsonb not null default '{}'::jsonb,
  cluster_id text default 'content-signal-os',
  canonical_ledger_id uuid,
  recorded_at timestamptz not null default now()
);

create index if not exists ix_cs_signal_source on content_signal.conversation_signal(source_type, ingested_at desc);
create index if not exists ix_cs_topic_state on content_signal.topic_registry(escalation_state, occurrence_count desc);
create index if not exists ix_cs_occ_topic on content_signal.topic_occurrence(topic_id, occurred_at desc);
create index if not exists ix_cs_pkg_asset on content_signal.content_package(content_asset_id);
create index if not exists ix_cs_gate_state on content_signal.approval_gate(state, gate_type);
create index if not exists ix_cs_queue_state on content_signal.publishing_queue(state);
create index if not exists ix_cs_receipt_component on content_signal.reality_ledger_receipt(component, recorded_at desc);

do $$
declare t text;
begin
  for t in select tablename from pg_tables where schemaname = 'content_signal' loop
    execute format('alter table content_signal.%I enable row level security', t);
    execute format('alter table content_signal.%I force row level security', t);
  end loop;
end $$;

create or replace function content_signal.fn_register_topic_occurrence(
  p_topic_key text, p_label text, p_signal_id uuid default null,
  p_weight numeric default 1, p_context text default null
) returns content_signal.topic_registry language plpgsql as $$
declare v_topic content_signal.topic_registry; v_state text;
begin
  insert into content_signal.topic_registry (topic_key, label, occurrence_count)
  values (p_topic_key, p_label, 1)
  on conflict (topic_key) do update
    set occurrence_count = content_signal.topic_registry.occurrence_count + 1,
        last_seen = now(), label = excluded.label
  returning * into v_topic;
  insert into content_signal.topic_occurrence (topic_id, signal_id, weight, context)
  values (v_topic.id, p_signal_id, p_weight, p_context);
  v_state := case
    when v_topic.occurrence_count >= 10 then 'strategic'
    when v_topic.occurrence_count >= 5 then 'pillar'
    when v_topic.occurrence_count >= 3 then 'three_off'
    when v_topic.occurrence_count = 2 then 'two_off'
    else 'one_off' end;
  update content_signal.topic_registry set escalation_state = v_state
   where id = v_topic.id returning * into v_topic;
  return v_topic;
end $$;

create or replace function content_signal.fn_generate_package(
  p_signal_id uuid, p_title text, p_length_class text default 'normal',
  p_voice_key text default null, p_target text default 'linkedin'
) returns content_signal.content_package language plpgsql as $$
declare v_voice content_signal.brand_voice_registry;
        v_asset content_signal.content_asset;
        v_pkg content_signal.content_package;
begin
  select * into v_voice from content_signal.brand_voice_registry
   where voice_key = coalesce(p_voice_key, voice_key)
   order by (voice_key = p_voice_key) desc nulls last limit 1;
  insert into content_signal.content_asset
    (asset_type, title, length_class, status, brand_voice_id, source_signal_id)
  values ('article', p_title, p_length_class, 'packaged', v_voice.id, p_signal_id)
  returning * into v_asset;
  insert into content_signal.content_package
    (content_asset_id, length_class, title_options, summary, publishing_target, status)
  values (v_asset.id, p_length_class, jsonb_build_array(p_title),
     'Auto-package generated from mid-thread signal. Draft body pending writer pass.',
     p_target, 'awaiting_approval')
  returning * into v_pkg;
  insert into content_signal.approval_gate (content_package_id, gate_type)
  values (v_pkg.id, 'article'), (v_pkg.id, 'image'), (v_pkg.id, 'pov');
  insert into content_signal.publishing_queue (content_package_id, state)
  values (v_pkg.id, 'held');
  return v_pkg;
end $$;

comment on function content_signal.fn_generate_package is
  'Generates content package + HITL approval gates + HELD publishing queue row. Never publishes.';
