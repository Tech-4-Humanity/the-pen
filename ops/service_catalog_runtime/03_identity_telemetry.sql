-- Service Catalog Runtime: distributed identity, telemetry stream, drift register, graph cognition
-- Deployed migration: service_catalog_runtime_03_identity_telemetry
-- Date: 2026-05-16

ALTER TABLE ops.runtime_execution_receipts
  ADD COLUMN IF NOT EXISTS actor_id text,
  ADD COLUMN IF NOT EXISTS tenant_id text NOT NULL DEFAULT 'tech4humanity',
  ADD COLUMN IF NOT EXISTS execution_id uuid NOT NULL DEFAULT gen_random_uuid(),
  ADD COLUMN IF NOT EXISTS runtime_id text,
  ADD COLUMN IF NOT EXISTS orchestration_id text,
  ADD COLUMN IF NOT EXISTS execution_nonce text,
  ADD COLUMN IF NOT EXISTS parent_execution_id uuid,
  ADD COLUMN IF NOT EXISTS instruction_sha text,
  ADD COLUMN IF NOT EXISTS catalog_id text;

ALTER TABLE ops.runtime_session_registry
  ADD COLUMN IF NOT EXISTS actor_id text,
  ADD COLUMN IF NOT EXISTS tenant_id text NOT NULL DEFAULT 'tech4humanity',
  ADD COLUMN IF NOT EXISTS runtime_id text,
  ADD COLUMN IF NOT EXISTS orchestration_id text;

CREATE TABLE IF NOT EXISTS ops.runtime_telemetry_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  emitted_at timestamptz DEFAULT now(),
  stream text NOT NULL CHECK (stream IN (
    'execution','economics','recovery','authority','drift','latency',
    'failure','orchestration','classification','runtime_health')),
  severity text NOT NULL DEFAULT 'INFO' CHECK (severity IN ('DEBUG','INFO','WARN','ERROR','CRITICAL')),
  source text, actor_id text,
  tenant_id text NOT NULL DEFAULT 'tech4humanity',
  execution_id uuid, catalog_id text, event_key text,
  payload jsonb DEFAULT '{}'::jsonb, evidence_ref text
);

CREATE TABLE IF NOT EXISTS ops.runtime_drift_register (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  detected_at timestamptz DEFAULT now(),
  drift_type text NOT NULL CHECK (drift_type IN (
    'infrastructure','policy','schema','dependency','orchestration',
    'runtime','prompt','identity')),
  surface text, object_key text, expected jsonb, observed jsonb,
  severity text NOT NULL DEFAULT 'NORMAL' CHECK (severity IN ('LOW','NORMAL','HIGH','CRITICAL')),
  response text CHECK (response IS NULL OR response IN ('reconcile','rollback','quarantine','escalate','recover')),
  status text NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','ACKNOWLEDGED','RESOLVED','BLOCKED')),
  resolved_at timestamptz, resolution_ref text, evidence_ref text
);

CREATE TABLE IF NOT EXISTS ops.runtime_graph_nodes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  node_key text UNIQUE NOT NULL,
  node_type text NOT NULL CHECK (node_type IN (
    'human','agent','workflow','runtime','api','database','bridge',
    'evidence','economic_event','orchestration_surface','governance_policy','telemetry_stream','catalog_item')),
  display_name text, attributes jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(), updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ops.runtime_graph_edges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_key text NOT NULL, target_key text NOT NULL,
  edge_type text NOT NULL CHECK (edge_type IN (
    'owns','governs','depends_on','executes','validates','monetises',
    'escalates','reconciles','recovers')),
  attributes jsonb DEFAULT '{}'::jsonb, created_at timestamptz DEFAULT now(),
  UNIQUE (source_key, target_key, edge_type)
);

CREATE OR REPLACE FUNCTION ops.fn_emit_telemetry(
  p_stream text, p_event_key text, p_payload jsonb DEFAULT '{}'::jsonb,
  p_severity text DEFAULT 'INFO', p_source text DEFAULT NULL,
  p_actor_id text DEFAULT NULL, p_execution_id uuid DEFAULT NULL,
  p_catalog_id text DEFAULT NULL, p_evidence_ref text DEFAULT NULL
) RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE v_id uuid;
BEGIN
  INSERT INTO ops.runtime_telemetry_events (
    stream, event_key, payload, severity, source, actor_id,
    execution_id, catalog_id, evidence_ref
  ) VALUES (
    p_stream, p_event_key, p_payload, p_severity, p_source, p_actor_id,
    p_execution_id, p_catalog_id, p_evidence_ref
  ) RETURNING id INTO v_id;
  RETURN v_id;
END; $$;
