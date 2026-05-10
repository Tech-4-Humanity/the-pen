create table if not exists achra_assessments (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),
  participant_id uuid,
  assessment_version text not null default '1.0',
  organisation text,
  role_title text,
  industry text,
  ai_cognitive_friction_score numeric,
  human_agent_symbiosis_index numeric,
  ai_burnout_risk numeric,
  verification_discipline_score numeric,
  automation_dependency_risk numeric,
  workflow_integration_readiness numeric,
  archetype text,
  raw_scores jsonb,
  derived_scores jsonb,
  interventions jsonb,
  telemetry jsonb,
  reality_status text default 'PARTIAL'
);

create table if not exists achra_question_responses (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid references achra_assessments(id) on delete cascade,
  question_key text not null,
  response_value numeric,
  response_text text,
  created_at timestamptz default now()
);

create table if not exists achra_intervention_rules (
  id uuid primary key default gen_random_uuid(),
  rule_key text unique,
  trigger_dimension text,
  threshold_min numeric,
  threshold_max numeric,
  intervention_type text,
  intervention_payload jsonb,
  created_at timestamptz default now()
);

create index if not exists achra_assessments_created_idx on achra_assessments(created_at desc);
create index if not exists achra_assessments_archetype_idx on achra_assessments(archetype);
