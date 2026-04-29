-- Outcome Ready NeuroProfile + Activity Engine
-- Non-diagnostic functional profiling, readiness, activity, practitioner enablement, and evidence tracking.
-- Boundary: this system does not diagnose, prescribe, or provide treatment advice.

create extension if not exists pgcrypto;

create table if not exists public.or_neuro_domains (
  id uuid primary key default gen_random_uuid(),
  domain_key text not null unique,
  domain_name text not null,
  description text not null,
  boundary_note text not null default 'Non-diagnostic functional support domain.',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.or_measurement_references (
  id uuid primary key default gen_random_uuid(),
  reference_key text not null unique,
  reference_name text not null,
  domain_key text not null references public.or_neuro_domains(domain_key),
  reference_type text not null check (reference_type in ('screening_reference','clinical_reference','functional_reference','research_reference','activity_reference')),
  intended_use text not null,
  not_for_use text not null default 'Not used by Outcome Ready to diagnose, prescribe, or replace qualified professional advice.',
  notes text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.or_functional_markers (
  id uuid primary key default gen_random_uuid(),
  marker_key text not null unique,
  domain_key text not null references public.or_neuro_domains(domain_key),
  marker_name text not null,
  marker_description text not null,
  evidence_inputs text[] not null default '{}',
  activity_links text[] not null default '{}',
  escalation_hint text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.or_activity_library (
  id uuid primary key default gen_random_uuid(),
  activity_key text not null unique,
  activity_name text not null,
  domain_key text not null references public.or_neuro_domains(domain_key),
  activity_type text not null check (activity_type in ('game','exercise','routine','reflection','environment_change','communication_script','ai_scaffold','practitioner_protocol')),
  audience text not null check (audience in ('adult','child','parent_carer','teacher','practitioner','provider','pharmacy_partner','workplace','mixed')),
  description text not null,
  steps jsonb not null default '[]'::jsonb,
  outcome_markers text[] not null default '{}',
  minimum_review_role text not null default 'practitioner_or_trained_support_worker',
  safety_boundary text not null default 'This activity is educational and functional support only. It is not diagnosis or treatment advice.',
  resale_ready boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.or_neuroprofile_sessions (
  id uuid primary key default gen_random_uuid(),
  subject_ref text not null,
  session_type text not null check (session_type in ('self_check','parent_carer_check','practitioner_supported','provider_supported','pharmacy_referred','school_supported','workplace_supported')),
  consent_state text not null check (consent_state in ('full','session','limited','none')),
  referral_source text,
  professional_involved boolean not null default false,
  boundary_acknowledged boolean not null default false,
  status text not null default 'started' check (status in ('started','in_progress','completed','archived','escalated')),
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.or_neuroprofile_observations (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.or_neuroprofile_sessions(id) on delete cascade,
  marker_key text not null references public.or_functional_markers(marker_key),
  observation_source text not null check (observation_source in ('self','parent_carer','teacher','practitioner','provider','pharmacy_partner','ai_activity','system')),
  score numeric,
  score_scale text,
  observation_text text,
  confidence text not null default 'medium' check (confidence in ('low','medium','high')),
  created_at timestamptz not null default now()
);

create table if not exists public.or_activity_assignments (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.or_neuroprofile_sessions(id) on delete cascade,
  activity_key text not null references public.or_activity_library(activity_key),
  assigned_by text not null default 'system',
  assignment_reason text not null,
  status text not null default 'assigned' check (status in ('assigned','started','completed','skipped','needs_review')),
  outcome_note text,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.or_practitioner_products (
  id uuid primary key default gen_random_uuid(),
  product_key text not null unique,
  product_name text not null,
  customer_type text not null check (customer_type in ('practitioner','school','provider','pharmacy_partner','workplace','family','mixed')),
  description text not null,
  included_activity_keys text[] not null default '{}',
  included_report_keys text[] not null default '{}',
  pricing_model text not null default 'licence',
  readiness_status text not null default 'draft' check (readiness_status in ('draft','review','ready','live')),
  created_at timestamptz not null default now()
);

create table if not exists public.or_reality_ledger (
  id uuid primary key default gen_random_uuid(),
  event_key text not null unique,
  event_type text not null,
  object_ref text not null,
  claim text not null,
  evidence jsonb not null default '{}'::jsonb,
  classification text not null check (classification in ('REAL','PARTIAL','PRETEND')),
  created_at timestamptz not null default now()
);

insert into public.or_neuro_domains (domain_key, domain_name, description)
values
('attention_regulation','Attention Regulation','Functional patterns around sustained attention, distractibility, focus recovery, and task persistence.'),
('executive_function','Executive Function','Functional patterns around planning, organisation, task initiation, working memory, and follow-through.'),
('sensory_load','Sensory Load','Functional patterns around environmental sensitivity, overload, recovery, and sensory preference.'),
('social_communication','Social Communication','Functional patterns around interaction, interpretation, expression, and communication load.'),
('emotional_regulation','Emotional Regulation','Functional patterns around emotional intensity, recovery, frustration tolerance, and co-regulation.'),
('learning_access','Learning Access','Functional patterns around reading, writing, comprehension, memory, and learning scaffolds.'),
('ai_sweet_spot','AI Sweet Spot','Functional response to AI support levels, including independence, scaffolding benefit, and cognitive load.')
on conflict (domain_key) do nothing;

insert into public.or_measurement_references (reference_key, reference_name, domain_key, reference_type, intended_use, notes)
values
('asrs_reference','Adult ADHD Self-Report Scale reference','attention_regulation','screening_reference','Reference point for adult attention and executive-function readiness conversations.','Use only as a reference concept unless licensing and permissions allow direct implementation.'),
('brief_a_reference','BRIEF-A executive function reference','executive_function','clinical_reference','Reference point for executive-function domains and functional observation categories.','Use as domain inspiration and validation checkpoint, not copied instrument content.'),
('sensory_profile_reference','Sensory profile reference','sensory_load','functional_reference','Reference point for sensory preference and overload mapping.','Use to shape functional observations and activity selection.'),
('autism_social_reference','Autism social communication reference set','social_communication','clinical_reference','Reference point for social communication, sensory, and adaptive-function observations.','No diagnosis. Used to prepare better support conversations.'),
('ai_sweet_spots_research','AI Sweet Spots research lens','ai_sweet_spot','research_reference','Maps how different people benefit from different AI scaffolding levels.','Core Outcome Ready differentiator.')
on conflict (reference_key) do nothing;

insert into public.or_functional_markers (marker_key, domain_key, marker_name, marker_description, evidence_inputs, escalation_hint)
values
('focus_recovery_time','attention_regulation','Focus recovery time','How long it takes to return to task after distraction.',array['self report','timed activity','parent or teacher observation'],'Escalate when attention disruption causes repeated safety, school, work, or family breakdown.'),
('task_start_latency','executive_function','Task start latency','Delay between intention and starting an agreed task.',array['timed activity','self report','provider observation'],'Escalate when inability to start tasks causes serious daily-life impairment.'),
('sensory_recovery_need','sensory_load','Sensory recovery need','Amount of recovery needed after sensory load or overload.',array['environment log','self report','carer observation'],'Escalate where overload causes shutdown, distress, aggression, or withdrawal.'),
('communication_repair_load','social_communication','Communication repair load','Effort needed to repair misunderstanding or communication mismatch.',array['reflection','practitioner note','family or school observation'],'Escalate when communication mismatch creates social isolation or conflict.'),
('regulation_recovery_time','emotional_regulation','Regulation recovery time','Time and support required to return to usable regulation after distress.',array['self report','parent carer observation','provider observation'],'Escalate when distress is frequent, severe, or safety relevant.'),
('reading_scaffold_benefit','learning_access','Reading scaffold benefit','Improvement in comprehension or persistence when support is added.',array['reading task','comprehension check','self report'],'Escalate when reading barriers materially affect school, work, or independence.'),
('ai_support_tolerance','ai_sweet_spot','AI support tolerance','Level of AI assistance that improves output without increasing cognitive debt.',array['task comparison','self report','performance trace'],'Escalate only for professional review where AI use masks significant functional difficulty.')
on conflict (marker_key) do nothing;

insert into public.or_activity_library (activity_key, activity_name, domain_key, activity_type, audience, description, steps, outcome_markers, resale_ready)
values
('focus_sprint_3x5','Three by five focus sprint','attention_regulation','exercise','mixed','Three short focus rounds with reset points to measure attention return and task persistence.','[{"step":1,"text":"Choose a low-risk task."},{"step":2,"text":"Run three five-minute focus rounds."},{"step":3,"text":"Record distraction and recovery moments."},{"step":4,"text":"Compare completion and stress before and after."}]'::jsonb,array['focus_recovery_time'],true),
('task_launch_ladder','Task launch ladder','executive_function','routine','mixed','A scaffold for turning a stuck task into the smallest safe first action.','[{"step":1,"text":"Name the task."},{"step":2,"text":"Name the first visible action."},{"step":3,"text":"Set a two-minute start window."},{"step":4,"text":"Record whether starting became easier."}]'::jsonb,array['task_start_latency'],true),
('sensory_reset_card','Sensory reset card','sensory_load','environment_change','parent_carer','A simple environmental reset routine for overload-prone moments.','[{"step":1,"text":"Identify current sensory load."},{"step":2,"text":"Choose one reduction action."},{"step":3,"text":"Wait and observe recovery."},{"step":4,"text":"Record what helped."}]'::jsonb,array['sensory_recovery_need'],true),
('communication_repair_script','Communication repair script','social_communication','communication_script','mixed','A script to repair misunderstanding without blame.','[{"step":1,"text":"Pause the exchange."},{"step":2,"text":"Restate what was heard."},{"step":3,"text":"Ask what was meant."},{"step":4,"text":"Record whether conflict reduced."}]'::jsonb,array['communication_repair_load'],true),
('regulation_weather_report','Regulation weather report','emotional_regulation','reflection','child','A child-friendly check-in to name emotional state and support need.','[{"step":1,"text":"Pick a weather word."},{"step":2,"text":"Name body clues."},{"step":3,"text":"Choose a support action."},{"step":4,"text":"Check again after five minutes."}]'::jsonb,array['regulation_recovery_time'],true),
('reading_buddy_compare','Reading Buddy scaffold comparison','learning_access','ai_scaffold','mixed','Compare reading with and without scaffolded support to detect useful assistance levels.','[{"step":1,"text":"Read a short passage without support."},{"step":2,"text":"Answer simple comprehension prompts."},{"step":3,"text":"Repeat with scaffolded support."},{"step":4,"text":"Compare comprehension, effort, and persistence."}]'::jsonb,array['reading_scaffold_benefit','ai_support_tolerance'],true)
on conflict (activity_key) do nothing;

insert into public.or_practitioner_products (product_key, product_name, customer_type, description, included_activity_keys, readiness_status)
values
('neuroprofile_activity_engine','NeuroProfile Activity Engine','practitioner','Licensable functional profiling and activity library for practitioners and providers.',array['focus_sprint_3x5','task_launch_ladder','sensory_reset_card','communication_repair_script','regulation_weather_report','reading_buddy_compare'],'draft'),
('pharmacy_referral_readiness_kit','Pharmacy Referral Readiness Kit','pharmacy_partner','Partner kit for safe referral into readiness and functional support pathways.',array['task_launch_ladder','sensory_reset_card'],'draft'),
('ndis_thriving_kids_outcomes_pack','NDIS and Thriving Kids Outcomes Pack','provider','Functional outcome pack for families, providers, and support coordinators.',array['regulation_weather_report','reading_buddy_compare','task_launch_ladder'],'draft')
on conflict (product_key) do nothing;

insert into public.or_reality_ledger (event_key, event_type, object_ref, claim, evidence, classification)
values
('or-neuroprofile-schema-20260429','schema_package','outcome_ready_neuroprofile_activity_engine','Initial non-diagnostic functional profiling schema and seed pack created for Pen execution.',jsonb_build_object('repo','TML-4PM/the-pen','path','bridge_jobs/outcome_ready_neuroprofile_activity_engine_20260429.sql'),'PARTIAL')
on conflict (event_key) do nothing;
