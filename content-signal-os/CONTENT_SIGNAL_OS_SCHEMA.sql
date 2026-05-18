-- Content Signal Operating System schema
-- Status: PARTIAL until deployed and wired to ingestion/runtime.

create table if not exists content_asset (
  asset_id text primary key,
  title text not null,
  asset_type text not null,
  stream text,
  status text not null default 'candidate',
  lifecycle text not null default 'draft',
  source text,
  source_ref text,
  created_at timestamptz default now(),
  published_at timestamptz,
  length_class text,
  primary_topic_id text,
  release_score numeric default 0,
  approval_required boolean default true,
  notes text
);

create table if not exists conversation_signal (
  signal_id text primary key,
  source_system text not null,
  thread_id text,
  message_ref text,
  captured_at timestamptz default now(),
  raw_excerpt text not null,
  extracted_summary text,
  confidence numeric default 0,
  article_candidate boolean default false,
  requested_length text,
  preferred_pov text,
  action_state text not null default 'recorded'
);

create table if not exists llm_chat_source (
  chat_id text primary key,
  source_system text not null,
  title text,
  started_at timestamptz,
  last_seen_at timestamptz,
  source_uri text,
  imported_at timestamptz default now(),
  status text default 'imported'
);

create table if not exists article_export_source (
  export_id text primary key,
  platform text not null default 'linkedin',
  file_name text,
  source_uri text,
  title text,
  created_at_source timestamptz,
  published_at_source timestamptz,
  imported_at timestamptz default now(),
  status text default 'imported'
);

create table if not exists topic_registry (
  topic_id text primary key,
  topic_name text unique not null,
  topic_type text default 'theme',
  first_seen_at timestamptz default now(),
  last_seen_at timestamptz default now(),
  occurrence_count integer default 0,
  asset_count integer default 0,
  signal_count integer default 0,
  escalation_state text default 'one_off',
  strategic_value numeric default 0,
  notes text
);

create table if not exists topic_occurrence (
  occurrence_id text primary key,
  topic_id text references topic_registry(topic_id),
  source_type text not null,
  source_id text not null,
  occurred_at timestamptz default now(),
  confidence numeric default 0,
  context_excerpt text
);

create table if not exists topic_relationship (
  relationship_id text primary key,
  source_topic_id text references topic_registry(topic_id),
  target_topic_id text references topic_registry(topic_id),
  relationship_type text default 'related',
  strength numeric default 0,
  evidence_count integer default 0,
  notes text
);

create table if not exists series_registry (
  series_id text primary key,
  series_title text not null,
  stream text,
  status text default 'candidate',
  topic_ids text[],
  asset_ids text[],
  suggested_order text[],
  created_at timestamptz default now(),
  notes text
);

create table if not exists content_package (
  package_id text primary key,
  asset_id text references content_asset(asset_id),
  title_options jsonb,
  draft_body text,
  summary text,
  social_cutdowns jsonb,
  image_briefs jsonb,
  related_articles jsonb,
  approval_state text default 'needs_review',
  created_at timestamptz default now()
);

create table if not exists brand_voice_registry (
  voice_id text primary key,
  brand_name text not null,
  representative text,
  tone text,
  audience text,
  default_footer text,
  allowed_claims text[],
  banned_phrases text[],
  examples jsonb,
  active boolean default true
);

create table if not exists point_of_view_registry (
  pov_id text primary key,
  pov_name text not null,
  business text,
  speaker text,
  viewpoint_rules jsonb,
  tone_rules jsonb,
  default_stream text,
  active boolean default true
);

create table if not exists platform_registry (
  platform_id text primary key,
  platform_name text not null,
  status text default 'planned',
  supports_longform boolean default false,
  supports_video boolean default false,
  supports_images boolean default true,
  telemetry_available boolean default false
);

create table if not exists platform_format_rule (
  rule_id text primary key,
  platform_id text references platform_registry(platform_id),
  format_name text not null,
  min_words integer,
  max_words integer,
  media_required boolean default false,
  caption_required boolean default true,
  hashtag_policy text,
  approval_required boolean default true
);

create table if not exists media_asset (
  media_id text primary key,
  asset_id text references content_asset(asset_id),
  media_type text,
  style_id text,
  source_uri text,
  prompt text,
  approval_state text default 'needs_review',
  created_at timestamptz default now()
);

create table if not exists approval_gate (
  approval_id text primary key,
  package_id text references content_package(package_id),
  gate_type text not null,
  status text default 'pending',
  approver text,
  decided_at timestamptz,
  notes text
);

create table if not exists publishing_queue (
  queue_id text primary key,
  package_id text references content_package(package_id),
  platform_id text references platform_registry(platform_id),
  status text default 'queued',
  scheduled_at timestamptz,
  published_at timestamptz,
  external_post_uri text,
  notes text
);

create table if not exists engagement_fact (
  engagement_id text primary key,
  asset_id text references content_asset(asset_id),
  platform_id text references platform_registry(platform_id),
  measured_at timestamptz default now(),
  views integer default 0,
  comments integer default 0,
  reactions integer default 0,
  shares integer default 0,
  saves integer default 0,
  clicks integer default 0,
  raw jsonb
);

create table if not exists topic_performance_rollup (
  topic_id text references topic_registry(topic_id),
  platform_id text references platform_registry(platform_id),
  asset_count integer default 0,
  total_views integer default 0,
  total_comments integer default 0,
  total_reactions integer default 0,
  total_shares integer default 0,
  last_calculated_at timestamptz default now(),
  primary key(topic_id, platform_id)
);

create table if not exists gap_analysis (
  gap_id text primary key,
  topic_id text references topic_registry(topic_id),
  gap_type text,
  demand_score numeric default 0,
  supply_score numeric default 0,
  opportunity_score numeric default 0,
  recommendation text,
  created_at timestamptz default now()
);

create table if not exists monetisation_map (
  map_id text primary key,
  topic_id text references topic_registry(topic_id),
  business text,
  product_path text,
  course_candidate boolean default false,
  ebook_candidate boolean default false,
  partnership_candidate boolean default false,
  revenue_score numeric default 0,
  notes text
);

create table if not exists reality_ledger_receipt (
  receipt_id text primary key,
  task_id text,
  intent text,
  execution text,
  output text,
  status text,
  evidence jsonb,
  score numeric,
  created_at timestamptz default now()
);

insert into platform_registry(platform_id, platform_name, status, supports_longform, supports_video, supports_images, telemetry_available)
values
('linkedin','LinkedIn','active',true,false,true,true),
('instagram','Instagram','planned',false,true,true,true),
('tiktok','TikTok','planned',false,true,true,true),
('youtube','YouTube','planned',true,true,true,true)
on conflict (platform_id) do nothing;

insert into platform_format_rule(rule_id, platform_id, format_name, min_words, max_words, media_required, caption_required, approval_required)
values
('linkedin_short','linkedin','short',600,900,true,true,true),
('linkedin_normal','linkedin','normal',1500,2500,true,true,true),
('linkedin_long','linkedin','long',4000,7000,true,true,true),
('linkedin_extra_long','linkedin','extra_long',8000,15000,true,true,true),
('linkedin_essay','linkedin','essay',15000,40000,true,true,true)
on conflict (rule_id) do nothing;

insert into brand_voice_registry(voice_id, brand_name, representative, tone, audience, default_footer)
values
('innovate_me_troy','InnovateMe','Troy Latter','executive, future-facing, provocative, grounded','executives, founders, boards','Troy Latter | InnovateMe | Tech 4 Humanity'),
('tech4humanity','Tech 4 Humanity','Troy Latter','ethical, human-centred, policy-aware','governments, citizens, responsible innovators','Tech 4 Humanity | contact@tech4humanity.com.au'),
('ahc','Augmented Humanity Coach','Troy Latter','practical, augmentation-led, organisational transformation','enterprise leaders, operators, teams','Augmented Humanity Coach | Human + Agent capability'),
('gcbat','GC-BAT','Troy Latter','governance, standards, neurotechnology risk','standards bodies, researchers, policymakers','GC-BAT | Brain-assistive technology governance'),
('emerging_tech','Emerging Tech','Troy Latter','exploratory, opportunity-driven, frontier signals','builders, investors, executives','Emerging Tech | Tech 4 Humanity')
on conflict (voice_id) do nothing;
