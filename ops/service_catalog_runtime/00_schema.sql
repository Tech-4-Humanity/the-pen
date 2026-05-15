-- Service Catalog Runtime + Memory Integrity Control Plane
-- Idempotent schema deployment
-- Date: 2026-05-15

CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE IF NOT EXISTS ops.runtime_session_registry (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text UNIQUE NOT NULL,
  agent_id text,
  source_surface text,
  created_at timestamptz DEFAULT now(),
  last_seen_at timestamptz DEFAULT now(),
  last_refresh_at timestamptz,
  instruction_sha text,
  instruction_source text,
  memory_age_seconds integer,
  freshness_state text NOT NULL DEFAULT 'STALE' CHECK (freshness_state IN ('CURRENT','STALE','CONTRADICTED','BLOCKED')),
  mutation_allowed boolean NOT NULL DEFAULT false,
  contradiction_count integer NOT NULL DEFAULT 0,
  blocked_reason text,
  evidence_ref text,
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.runtime_instruction_refresh_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id text,
  agent_id text,
  source_path text NOT NULL,
  source_sha text,
  fetched_at timestamptz DEFAULT now(),
  fetch_status text NOT NULL CHECK (fetch_status IN ('OK','STALE','CONTRADICTED','BLOCKED','ERROR')),
  fetch_method text,
  error text,
  evidence_ref text
);

CREATE TABLE IF NOT EXISTS ops.service_catalog_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  catalog_id text UNIQUE NOT NULL,
  name text NOT NULL,
  brand text NOT NULL,
  business_group text,
  offer_type text NOT NULL,
  lifecycle_stage text NOT NULL DEFAULT 'DRAFT' CHECK (lifecycle_stage IN ('IDEA','DRAFT','OFFER_READY','MARKET_READY','ACTIVE','PAUSED','RETIRED')),
  customer_segment text[] DEFAULT '{}',
  problem_statement text,
  promised_outcome text,
  inclusions text[] DEFAULT '{}',
  exclusions text[] DEFAULT '{}',
  prerequisites text[] DEFAULT '{}',
  intake_requirements text[] DEFAULT '{}',
  fulfilment_steps text[] DEFAULT '{}',
  delivery_owner text,
  agent_roles text[] DEFAULT '{}',
  systems_touched text[] DEFAULT '{}',
  data_touched text[] DEFAULT '{}',
  authority_required text NOT NULL DEFAULT 'LOG' CHECK (authority_required IN ('AUTO','LOG','GATED','BLOCKED')),
  risk_class text NOT NULL DEFAULT 'NORMAL' CHECK (risk_class IN ('LOW','NORMAL','HIGH','CRITICAL')),
  evidence_required text[] DEFAULT '{}',
  telemetry_required text[] DEFAULT '{}',
  price_model text CHECK (price_model IS NULL OR price_model IN ('fixed','tiered','usage','retainer','quote','free','internal')),
  cost_drivers text[] DEFAULT '{}',
  margin_notes text,
  support_model text CHECK (support_model IS NULL OR support_model IN ('self_service','guided','managed','enterprise')),
  sla text,
  audit_status text NOT NULL DEFAULT 'PARTIAL' CHECK (audit_status IN ('CURRENT','STALE','PARTIAL','CONTRADICTED','BLOCKED')),
  last_refreshed_at timestamptz,
  instruction_sha text,
  evidence_ref text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.runtime_contradiction_register (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  detected_at timestamptz DEFAULT now(),
  detected_by text,
  source_surface text,
  object_type text,
  object_key text,
  stale_claim text,
  observed_claim text,
  stale_source_ref text,
  observed_source_ref text,
  severity text NOT NULL DEFAULT 'NORMAL' CHECK (severity IN ('LOW','NORMAL','HIGH','CRITICAL')),
  status text NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','ACKNOWLEDGED','RESOLVED','BLOCKED')),
  required_action text,
  resolved_at timestamptz,
  resolution_ref text
);

CREATE TABLE IF NOT EXISTS ops.audit_quarantine_register (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  artifact_ref text NOT NULL,
  artifact_type text,
  source_surface text,
  created_at_source timestamptz,
  reviewed_at timestamptz DEFAULT now(),
  instruction_sha text,
  runtime_receipt text,
  source_timestamp timestamptz,
  freshness_state text NOT NULL CHECK (freshness_state IN ('CURRENT','STALE','CONTRADICTED','BLOCKED','SAFE_HISTORICAL_ONLY')),
  classification text NOT NULL DEFAULT 'PARTIAL' CHECK (classification IN ('REAL','PARTIAL','BLOCKED')),
  reuse_allowed boolean NOT NULL DEFAULT false,
  reason text,
  required_refresh_action text,
  evidence_ref text
);

CREATE TABLE IF NOT EXISTS ops.runtime_execution_receipts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id text NOT NULL,
  action text NOT NULL,
  status text NOT NULL CHECK (status IN ('REAL','PARTIAL','BLOCKED','FAILED')),
  result jsonb DEFAULT '{}'::jsonb,
  evidence jsonb DEFAULT '{}'::jsonb,
  gaps text[] DEFAULT '{}',
  next_action text,
  created_at timestamptz DEFAULT now()
);

CREATE OR REPLACE VIEW ops.v_stale_sessions AS
SELECT *
FROM ops.runtime_session_registry
WHERE freshness_state <> 'CURRENT' OR mutation_allowed = false;

CREATE OR REPLACE VIEW ops.v_open_contradictions AS
SELECT *
FROM ops.runtime_contradiction_register
WHERE status IN ('OPEN','ACKNOWLEDGED','BLOCKED');

CREATE OR REPLACE VIEW ops.v_catalog_gaps AS
SELECT
  catalog_id,
  name,
  brand,
  lifecycle_stage,
  audit_status,
  CASE
    WHEN cardinality(fulfilment_steps) = 0 THEN 'MISSING_FULFILMENT'
    WHEN cardinality(evidence_required) = 0 THEN 'MISSING_EVIDENCE'
    WHEN cardinality(telemetry_required) = 0 THEN 'MISSING_TELEMETRY'
    WHEN support_model IS NULL THEN 'MISSING_SUPPORT'
    WHEN instruction_sha IS NULL THEN 'MISSING_INSTRUCTION_SHA'
    ELSE 'OK'
  END AS gap_reason
FROM ops.service_catalog_items
WHERE lifecycle_stage IN ('OFFER_READY','MARKET_READY','ACTIVE')
  AND (
    cardinality(fulfilment_steps) = 0
    OR cardinality(evidence_required) = 0
    OR cardinality(telemetry_required) = 0
    OR support_model IS NULL
    OR instruction_sha IS NULL
  );

CREATE OR REPLACE VIEW ops.v_quarantined_audits AS
SELECT *
FROM ops.audit_quarantine_register
WHERE reuse_allowed = false OR classification <> 'REAL';

CREATE OR REPLACE FUNCTION ops.fn_classify_session(
  p_session_id text,
  p_agent_id text,
  p_source_surface text,
  p_last_refresh_at timestamptz,
  p_instruction_sha text,
  p_attempted_mutation boolean DEFAULT false,
  p_contradiction boolean DEFAULT false,
  p_blocked_reason text DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_memory_age integer;
  v_state text;
  v_mutation_allowed boolean;
BEGIN
  IF p_last_refresh_at IS NULL THEN
    v_memory_age := NULL;
  ELSE
    v_memory_age := EXTRACT(EPOCH FROM (now() - p_last_refresh_at))::integer;
  END IF;

  IF p_blocked_reason IS NOT NULL THEN
    v_state := 'BLOCKED';
    v_mutation_allowed := false;
  ELSIF p_contradiction THEN
    v_state := 'CONTRADICTED';
    v_mutation_allowed := false;
  ELSIF p_last_refresh_at IS NULL OR v_memory_age > 86400 THEN
    v_state := 'STALE';
    v_mutation_allowed := false;
  ELSE
    v_state := 'CURRENT';
    v_mutation_allowed := true;
  END IF;

  INSERT INTO ops.runtime_session_registry (
    session_id, agent_id, source_surface, last_seen_at, last_refresh_at,
    instruction_sha, instruction_source, memory_age_seconds, freshness_state,
    mutation_allowed, contradiction_count, blocked_reason, updated_at
  ) VALUES (
    p_session_id, p_agent_id, p_source_surface, now(), p_last_refresh_at,
    p_instruction_sha, 'TML-4PM/the-pen/GLOBAL_RULE.md', v_memory_age, v_state,
    v_mutation_allowed, CASE WHEN p_contradiction THEN 1 ELSE 0 END, p_blocked_reason, now()
  )
  ON CONFLICT (session_id) DO UPDATE SET
    agent_id = EXCLUDED.agent_id,
    source_surface = EXCLUDED.source_surface,
    last_seen_at = now(),
    last_refresh_at = EXCLUDED.last_refresh_at,
    instruction_sha = EXCLUDED.instruction_sha,
    memory_age_seconds = EXCLUDED.memory_age_seconds,
    freshness_state = EXCLUDED.freshness_state,
    mutation_allowed = EXCLUDED.mutation_allowed,
    contradiction_count = ops.runtime_session_registry.contradiction_count + EXCLUDED.contradiction_count,
    blocked_reason = EXCLUDED.blocked_reason,
    updated_at = now();

  RETURN jsonb_build_object(
    'session_id', p_session_id,
    'freshness_state', v_state,
    'mutation_allowed', v_mutation_allowed,
    'memory_age_seconds', v_memory_age
  );
END;
$$;

CREATE OR REPLACE FUNCTION ops.fn_record_contradiction(
  p_detected_by text,
  p_source_surface text,
  p_object_type text,
  p_object_key text,
  p_stale_claim text,
  p_observed_claim text,
  p_stale_source_ref text,
  p_observed_source_ref text,
  p_severity text DEFAULT 'NORMAL',
  p_required_action text DEFAULT NULL
) RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO ops.runtime_contradiction_register (
    detected_by, source_surface, object_type, object_key, stale_claim, observed_claim,
    stale_source_ref, observed_source_ref, severity, required_action
  ) VALUES (
    p_detected_by, p_source_surface, p_object_type, p_object_key, p_stale_claim, p_observed_claim,
    p_stale_source_ref, p_observed_source_ref, p_severity, p_required_action
  ) RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION ops.fn_catalog_active_ready(p_catalog_id text) RETURNS boolean
LANGUAGE sql
AS $$
  SELECT EXISTS (
    SELECT 1 FROM ops.service_catalog_items
    WHERE catalog_id = p_catalog_id
      AND lifecycle_stage = 'ACTIVE'
      AND cardinality(fulfilment_steps) > 0
      AND cardinality(evidence_required) > 0
      AND cardinality(telemetry_required) > 0
      AND support_model IS NOT NULL
      AND instruction_sha IS NOT NULL
  );
$$;
