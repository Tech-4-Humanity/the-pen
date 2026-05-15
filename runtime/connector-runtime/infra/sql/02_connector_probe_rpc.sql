-- ============================================================================
-- Public RPC wrappers for runtime.connector_probes
-- Required by connector-probe-runner Lambda — PostgREST exposes only the
-- public schema by default, so we expose two SECURITY DEFINER functions there.
--
-- Author: Claude Opus 4.7
-- Audit:  connector-runtime-audit-2026-05-15
-- Project: lzfgigiyqpuuxslsygjt
-- ============================================================================

-- Reader: returns SCHEDULED rows from the last 7 days, up to 100 per call.
CREATE OR REPLACE FUNCTION public.fn_connector_probes_get_scheduled()
RETURNS TABLE(
  id              BIGINT,
  connector       TEXT,
  action          TEXT,
  idempotency_key TEXT,
  probed_at       TIMESTAMPTZ
)
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public, runtime, pg_temp
AS $$
  SELECT id, connector, action, idempotency_key, probed_at
  FROM runtime.connector_probes
  WHERE status = 'SCHEDULED'
    AND probed_at > now() - interval '7 days'
    AND (notes IS NULL OR notes NOT LIKE '%[processed by probe_id=%')
  ORDER BY probed_at ASC
  LIMIT 100;
$$;

COMMENT ON FUNCTION public.fn_connector_probes_get_scheduled() IS
  'PostgREST-accessible accessor: returns up to 100 unprocessed SCHEDULED rows from runtime.connector_probes in the last 7 days. Called by connector-probe-runner Lambda.';

-- Writer: appends a probe result row and marks the SCHEDULED row as processed.
-- Per House Rules §20 we never overwrite the SCHEDULED row — we INSERT a new
-- row, then annotate the original via notes so audit trail is preserved.
CREATE OR REPLACE FUNCTION public.fn_connector_probes_record(
  p_scheduled_probe_id BIGINT,
  p_connector          TEXT,
  p_status             TEXT,
  p_receipt_type       TEXT,
  p_receipt_id         TEXT,
  p_evidence           JSONB,
  p_notes              TEXT,
  p_auditor            TEXT
) RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, runtime, pg_temp
AS $$
DECLARE
  v_new_id BIGINT;
  v_idem   TEXT;
BEGIN
  v_idem := COALESCE(p_connector,'unknown') || ':probe_result:' || COALESCE(p_scheduled_probe_id::text,'null');

  INSERT INTO runtime.connector_probes(
    connector, action, status, receipt_type, receipt_id,
    evidence, notes, auditor, source_ref, idempotency_key
  ) VALUES (
    p_connector,
    'safe_probe_result',
    p_status,
    p_receipt_type,
    p_receipt_id,
    COALESCE(p_evidence, '{}'::jsonb),
    p_notes,
    p_auditor,
    'lambda:connector-probe-runner:scheduled_id=' || COALESCE(p_scheduled_probe_id::text,'null'),
    v_idem
  )
  ON CONFLICT (idempotency_key) DO NOTHING
  RETURNING id INTO v_new_id;

  UPDATE runtime.connector_probes
     SET notes = COALESCE(notes,'') ||
                 ' [processed by probe_id=' || COALESCE(v_new_id::text,'duplicate') ||
                 ' at ' || now()::text || ']'
   WHERE id = p_scheduled_probe_id
     AND status = 'SCHEDULED';

  RETURN v_new_id;
END
$$;

COMMENT ON FUNCTION public.fn_connector_probes_record IS
  'PostgREST-accessible writer: appends a probe result row to runtime.connector_probes and annotates the SCHEDULED source row as processed. SECURITY DEFINER so service_role can write without an explicit runtime-schema grant.';

GRANT EXECUTE ON FUNCTION public.fn_connector_probes_get_scheduled() TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_connector_probes_record(BIGINT,TEXT,TEXT,TEXT,TEXT,JSONB,TEXT,TEXT) TO service_role;
