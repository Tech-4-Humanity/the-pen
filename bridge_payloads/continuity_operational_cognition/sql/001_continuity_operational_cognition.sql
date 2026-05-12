-- Continuity Operational Cognition Migration
-- Classification: PARTIAL until applied by Bridge and receipt logged.
-- Purpose: turn Parking Lot work into institutional intents, ritual runs, signals, scratchpad, votes, freeze scopes, and playbook items.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS ops.house_rules (
  rule_id text PRIMARY KEY,
  title text NOT NULL,
  intent text NOT NULL,
  invariant text NOT NULL,
  guardrail text,
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','FROZEN','RETIRED')),
  evidence_state text NOT NULL DEFAULT 'PARTIAL' CHECK (evidence_state IN ('REAL','PARTIAL','PRETEND')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.freeze_scopes (
  freeze_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scope_key text UNIQUE NOT NULL,
  title text NOT NULL,
  reason text NOT NULL,
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','ENDED','ABORTED')),
  allowed_actions text[] NOT NULL DEFAULT '{}',
  blocked_actions text[] NOT NULL DEFAULT '{}',
  exit_conditions text[] NOT NULL DEFAULT '{}',
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  evidence_state text NOT NULL DEFAULT 'PARTIAL' CHECK (evidence_state IN ('REAL','PARTIAL','PRETEND'))
);

CREATE TABLE IF NOT EXISTS ops.institutional_intents (
  intent_id text PRIMARY KEY,
  title text NOT NULL,
  intent_description text NOT NULL,
  continuity_class text NOT NULL CHECK (continuity_class IN ('CRITICAL_CONTINUITY','HUMAN_TRUST','OPERATIONAL_HYGIENE','EXPERIMENTAL','NOISE')),
  state text NOT NULL DEFAULT 'OPEN' CHECK (state IN ('OPEN','IN_PROGRESS','CLOSED','ESCALATED','DEFERRED','INVALIDATED','ARCHIVED','FAILED_WITH_VISIBILITY')),
  reality_status text NOT NULL DEFAULT 'PARTIAL' CHECK (reality_status IN ('REAL','PARTIAL','PRETEND')),
  closure_type text CHECK (closure_type IN ('RESOLVED','DEFERRED_WITH_CONFIDENCE','ARCHIVED','HANDOFF_COMPLETE','INVALIDATED','AUTO_CLOSED','ESCALATED')),
  continuity_deadline timestamptz,
  continuity_cost numeric NOT NULL DEFAULT 0,
  attention_residue_score numeric NOT NULL DEFAULT 0,
  human_state_impact text CHECK (human_state_impact IN ('CALMING','NEUTRAL','COGNITIVELY_HEAVY','TRUST_SENSITIVE','URGENT','AMBIGUOUS')),
  owner_ref text,
  origin_ref text,
  payload jsonb NOT NULL DEFAULT '{}',
  dependencies text[] NOT NULL DEFAULT '{}',
  next_expected_transition text,
  evidence jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  closed_at timestamptz,
  CHECK ((state IN ('CLOSED','ARCHIVED','INVALIDATED','ESCALATED','DEFERRED','FAILED_WITH_VISIBILITY') AND closure_type IS NOT NULL) OR state IN ('OPEN','IN_PROGRESS'))
);

CREATE INDEX IF NOT EXISTS idx_institutional_intents_state ON ops.institutional_intents(state);
CREATE INDEX IF NOT EXISTS idx_institutional_intents_class_state ON ops.institutional_intents(continuity_class, state);
CREATE INDEX IF NOT EXISTS idx_institutional_intents_deadline ON ops.institutional_intents(continuity_deadline);
CREATE INDEX IF NOT EXISTS idx_institutional_intents_reality ON ops.institutional_intents(reality_status);
CREATE INDEX IF NOT EXISTS idx_institutional_intents_cost ON ops.institutional_intents(continuity_cost DESC);
CREATE INDEX IF NOT EXISTS idx_institutional_intents_residue ON ops.institutional_intents(attention_residue_score DESC);

CREATE TABLE IF NOT EXISTS ops.intent_executions (
  execution_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  intent_id text NOT NULL REFERENCES ops.institutional_intents(intent_id) ON DELETE CASCADE,
  worker_ref text,
  attempt_no int NOT NULL DEFAULT 1,
  status text NOT NULL CHECK (status IN ('STARTED','SUCCEEDED','FAILED','RETRIED','ESCALATED','SKIPPED')),
  started_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz,
  error text,
  receipt_ref text,
  telemetry jsonb NOT NULL DEFAULT '{}',
  evidence jsonb NOT NULL DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS ops.continuity_ritual_runs (
  run_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ritual_date date NOT NULL,
  ritual_type text NOT NULL CHECK (ritual_type IN ('MORNING_BRIEF','EVENING_CLOSURE','DAY_3_REFLECTION','DAY_7_SYNTHESIS')),
  posture text,
  template_version text NOT NULL DEFAULT 'v2.1',
  content jsonb NOT NULL DEFAULT '{}',
  frozen_scope boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (ritual_date, ritual_type)
);

CREATE TABLE IF NOT EXISTS ops.continuity_signal_events (
  signal_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id uuid REFERENCES ops.continuity_ritual_runs(run_id) ON DELETE CASCADE,
  signal_name text NOT NULL CHECK (signal_name IN ('clarity','overwhelm','mental_fragmentation','mental_carryover','continuity_trust','ability_to_disengage','operational_calm','attention_residue','time_to_clarity_minutes','relief_text')),
  signal_value numeric,
  signal_text text,
  measurement_context text NOT NULL CHECK (measurement_context IN ('MORNING_BEFORE','MORNING_AFTER','EVENING_BEFORE','EVENING_AFTER','DAY_REFLECTION')),
  source text NOT NULL DEFAULT 'manual_pilot',
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (signal_value IS NOT NULL OR signal_text IS NOT NULL)
);

CREATE TABLE IF NOT EXISTS ops.continuity_scratchpad (
  note_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text,
  body text NOT NULL,
  category text NOT NULL CHECK (category IN ('DRIFT','AMBIGUITY','NOISE','IDEA','RELIEF','FOLLOW_UP','OBSERVATION','DEFERRED_EXPANSION','PLAYBOOK_CANDIDATE')),
  linked_intent_id text REFERENCES ops.institutional_intents(intent_id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'CAPTURED' CHECK (status IN ('CAPTURED','PROMOTED','ARCHIVED','INVALIDATED')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.continuity_feedback_votes (
  vote_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id uuid REFERENCES ops.continuity_ritual_runs(run_id) ON DELETE CASCADE,
  prompt text NOT NULL,
  score numeric,
  response text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.continuity_playbook_items (
  item_no int PRIMARY KEY,
  group_key text NOT NULL,
  group_title text NOT NULL,
  question text NOT NULL,
  intent text,
  checklist_use text,
  automation_candidate boolean NOT NULL DEFAULT false,
  default_selected boolean NOT NULL DEFAULT false,
  risk_if_ignored text,
  evidence_state text NOT NULL DEFAULT 'PARTIAL' CHECK (evidence_state IN ('REAL','PARTIAL','PRETEND')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.parking_lot_triage_runs (
  triage_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_ref text NOT NULL,
  item_count int NOT NULL DEFAULT 0,
  promoted_count int NOT NULL DEFAULT 0,
  frozen_count int NOT NULL DEFAULT 0,
  archived_count int NOT NULL DEFAULT 0,
  notes jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE VIEW ops.continuity_health AS
SELECT
  count(*) FILTER (WHERE state IN ('OPEN','IN_PROGRESS')) AS open_intents,
  count(*) FILTER (WHERE continuity_class = 'HUMAN_TRUST' AND state IN ('OPEN','IN_PROGRESS')) AS human_trust_open,
  count(*) FILTER (WHERE continuity_class = 'CRITICAL_CONTINUITY' AND state IN ('OPEN','IN_PROGRESS')) AS critical_open,
  count(*) FILTER (WHERE continuity_deadline < now() AND state IN ('OPEN','IN_PROGRESS')) AS overdue_intents,
  count(*) FILTER (WHERE human_state_impact = 'AMBIGUOUS' AND state IN ('OPEN','IN_PROGRESS')) AS ambiguous_open,
  avg(attention_residue_score) FILTER (WHERE state IN ('OPEN','IN_PROGRESS')) AS avg_residue,
  avg(continuity_cost) FILTER (WHERE state IN ('OPEN','IN_PROGRESS')) AS avg_continuity_cost,
  count(*) FILTER (WHERE reality_status = 'PRETEND' AND state IN ('OPEN','IN_PROGRESS')) AS pretend_open
FROM ops.institutional_intents;

CREATE OR REPLACE VIEW ops.quiet_drift_candidates AS
SELECT *
FROM ops.institutional_intents
WHERE state IN ('OPEN','IN_PROGRESS')
  AND (
    continuity_deadline < now() + interval '72 hours'
    OR attention_residue_score >= 7
    OR continuity_cost >= 7
    OR human_state_impact IN ('TRUST_SENSITIVE','AMBIGUOUS','COGNITIVELY_HEAVY')
  )
ORDER BY continuity_class, continuity_deadline NULLS LAST, attention_residue_score DESC, continuity_cost DESC;

INSERT INTO ops.house_rules (rule_id, title, intent, invariant, guardrail, evidence_state)
VALUES
('PARALLEL_FORWARD_CHARGE','Parallel Forward Charge','Advance safe related workstreams in parallel.','If Day 1 work can reduce Day 7 risk, do it on Day 1.','Never make false REAL claims; receipts required.','PARTIAL'),
('CONTINUITY_FIRST_QUEUING','Continuity-First Queuing','Treat queued items as institutional intents, not jobs.','No orphaned intent.','Every intent ends visibly.','PARTIAL'),
('NO_FUTURE_TENSE_AS_PRESENT_TENSE','No Future-Tense As Present-Tense','Prevent narrative-first operational claims.','Live/active/production requires observable evidence.','Architecture remains PARTIAL until verified.','PARTIAL'),
('PILOT_FREEZE_RESTRAINT','Pilot Freeze Restraint','Protect the 7-day pilot from feature contamination.','No conceptual expansion during behavioural test.','Capture ideas separately.','PARTIAL')
ON CONFLICT (rule_id) DO UPDATE SET
  title = EXCLUDED.title,
  intent = EXCLUDED.intent,
  invariant = EXCLUDED.invariant,
  guardrail = EXCLUDED.guardrail,
  updated_at = now();

INSERT INTO ops.freeze_scopes (scope_key, title, reason, allowed_actions, blocked_actions, exit_conditions, evidence_state)
VALUES (
  'continuity_pilot_7_day_v2_1',
  '7-Day Continuity Pilot Freeze',
  'Protect ritual signal integrity while testing cognitive relief and continuity trust.',
  ARRAY['use current ritual','manual tracking','scratchpad capture','blocking defect fix','Day 3 review','Day 7 synthesis'],
  ARRAY['new widgets','new agent behaviours','ontology redesign','extra metrics','new dashboards','campaign expansion','feature additions'],
  ARRAY['Day 7 synthesis complete','ritual too heavy','safety issue','user ends pilot'],
  'PARTIAL'
)
ON CONFLICT (scope_key) DO NOTHING;
