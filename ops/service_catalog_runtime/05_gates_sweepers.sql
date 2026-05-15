-- Service Catalog Runtime: mutation gate, sweepers, contamination scan, freshness decay, runtime tick
-- Deployed migration: service_catalog_runtime_05_gates_sweepers
-- Date: 2026-05-16

CREATE OR REPLACE FUNCTION ops.fn_mutation_gate(
  p_session_id text, p_action text, p_object_type text DEFAULT NULL,
  p_object_key text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
  v_session record; v_open_contradictions integer; v_age integer;
BEGIN
  SELECT * INTO v_session FROM ops.runtime_session_registry WHERE session_id = p_session_id;
  IF v_session IS NULL THEN
    PERFORM ops.fn_emit_telemetry('authority','mutation_blocked_no_session',
      jsonb_build_object('session_id', p_session_id, 'action', p_action),
      'WARN','fn_mutation_gate', NULL, NULL, NULL, NULL);
    RETURN jsonb_build_object('allowed', false, 'reason', 'session_not_registered',
                              'required_action', 'call fn_classify_session first');
  END IF;

  IF v_session.last_refresh_at IS NULL THEN v_age := NULL;
  ELSE v_age := EXTRACT(EPOCH FROM (now() - v_session.last_refresh_at))::integer; END IF;

  IF v_session.freshness_state = 'BLOCKED' THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'session_blocked',
                              'blocked_reason', v_session.blocked_reason);
  END IF;
  IF v_session.freshness_state = 'CONTRADICTED' THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'session_contradicted',
                              'required_action', 'resolve open contradictions');
  END IF;
  IF v_session.freshness_state <> 'CURRENT' OR v_age IS NULL OR v_age > 86400 THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'session_stale',
                              'memory_age_seconds', v_age,
                              'required_action', 'refresh instruction_sha from canonical source');
  END IF;

  SELECT COUNT(*) INTO v_open_contradictions FROM ops.runtime_contradiction_register
   WHERE status IN ('OPEN','BLOCKED')
     AND object_key = COALESCE(p_object_key, object_key);

  IF v_open_contradictions > 0 THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'open_contradictions_for_object',
                              'open_contradictions', v_open_contradictions);
  END IF;

  PERFORM ops.fn_emit_telemetry('authority','mutation_allowed',
    jsonb_build_object('session_id',p_session_id,'action',p_action,
                       'object_type',p_object_type,'object_key',p_object_key),
    'INFO','fn_mutation_gate', v_session.actor_id, NULL, NULL, NULL);

  RETURN jsonb_build_object('allowed', true, 'session_id', p_session_id,
                            'memory_age_seconds', v_age,
                            'execution_nonce', gen_random_uuid()::text);
END; $$;

CREATE OR REPLACE FUNCTION ops.fn_sweep_sessions(p_stale_after_seconds integer DEFAULT 86400)
RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE v_marked integer;
BEGIN
  WITH upd AS (
    UPDATE ops.runtime_session_registry
       SET freshness_state = 'STALE', mutation_allowed = false, updated_at = now()
     WHERE freshness_state = 'CURRENT'
       AND (last_refresh_at IS NULL
            OR EXTRACT(EPOCH FROM (now() - last_refresh_at))::integer > p_stale_after_seconds)
     RETURNING id
  ) SELECT COUNT(*) INTO v_marked FROM upd;
  PERFORM ops.fn_emit_telemetry('runtime_health','session_sweep',
    jsonb_build_object('marked_stale', v_marked, 'threshold_seconds', p_stale_after_seconds),
    CASE WHEN v_marked > 0 THEN 'WARN' ELSE 'INFO' END,
    'fn_sweep_sessions', NULL, NULL, NULL, NULL);
  RETURN jsonb_build_object('marked_stale', v_marked, 'ran_at', now());
END; $$;

CREATE OR REPLACE FUNCTION ops.fn_sweep_audit_artifacts(p_stale_after_days integer DEFAULT 14)
RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE v_quarantined integer;
BEGIN
  WITH upd AS (
    UPDATE ops.audit_quarantine_register
       SET freshness_state = 'STALE', classification = 'PARTIAL',
           reuse_allowed = false, reviewed_at = now(),
           reason = COALESCE(reason,'') || ' [auto-swept: age > ' || p_stale_after_days || 'd]'
     WHERE freshness_state = 'CURRENT'
       AND (source_timestamp IS NULL
            OR source_timestamp < now() - (p_stale_after_days || ' days')::interval)
     RETURNING id
  ) SELECT COUNT(*) INTO v_quarantined FROM upd;
  PERFORM ops.fn_emit_telemetry('classification','audit_sweep',
    jsonb_build_object('quarantined', v_quarantined, 'threshold_days', p_stale_after_days),
    CASE WHEN v_quarantined > 0 THEN 'WARN' ELSE 'INFO' END,
    'fn_sweep_audit_artifacts', NULL, NULL, NULL, NULL);
  RETURN jsonb_build_object('quarantined', v_quarantined, 'ran_at', now());
END; $$;

CREATE OR REPLACE FUNCTION ops.fn_scan_contamination() RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
  v_receipts_no_sha integer; v_audits_no_sha integer; v_catalog_no_sha integer;
BEGIN
  SELECT COUNT(*) INTO v_receipts_no_sha FROM ops.runtime_execution_receipts
   WHERE instruction_sha IS NULL AND created_at > now() - interval '90 days';
  SELECT COUNT(*) INTO v_audits_no_sha FROM ops.audit_quarantine_register
   WHERE instruction_sha IS NULL;
  SELECT COUNT(*) INTO v_catalog_no_sha FROM ops.service_catalog_items
   WHERE instruction_sha IS NULL AND lifecycle_stage IN ('OFFER_READY','MARKET_READY','ACTIVE');
  PERFORM ops.fn_emit_telemetry('classification','contamination_scan',
    jsonb_build_object('receipts_missing_sha', v_receipts_no_sha,
                       'audits_missing_sha', v_audits_no_sha,
                       'catalog_missing_sha', v_catalog_no_sha),
    CASE WHEN (v_receipts_no_sha + v_audits_no_sha + v_catalog_no_sha) > 0
         THEN 'WARN' ELSE 'INFO' END,
    'fn_scan_contamination', NULL, NULL, NULL, NULL);
  RETURN jsonb_build_object(
    'receipts_missing_sha', v_receipts_no_sha,
    'audits_missing_sha', v_audits_no_sha,
    'catalog_missing_sha', v_catalog_no_sha,
    'ran_at', now()
  );
END; $$;

CREATE OR REPLACE FUNCTION ops.fn_decay_freshness(p_catalog_stale_days integer DEFAULT 30)
RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE v_catalog_decayed integer;
BEGIN
  WITH upd AS (
    UPDATE ops.service_catalog_items
       SET audit_status = 'STALE', updated_at = now()
     WHERE audit_status = 'CURRENT'
       AND (last_refreshed_at IS NULL
            OR last_refreshed_at < now() - (p_catalog_stale_days || ' days')::interval)
     RETURNING id
  ) SELECT COUNT(*) INTO v_catalog_decayed FROM upd;
  PERFORM ops.fn_emit_telemetry('drift','catalog_freshness_decay',
    jsonb_build_object('decayed', v_catalog_decayed, 'threshold_days', p_catalog_stale_days),
    CASE WHEN v_catalog_decayed > 0 THEN 'WARN' ELSE 'INFO' END,
    'fn_decay_freshness', NULL, NULL, NULL, NULL);
  RETURN jsonb_build_object('catalog_decayed', v_catalog_decayed, 'ran_at', now());
END; $$;

CREATE OR REPLACE FUNCTION ops.fn_runtime_tick() RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE v_sessions jsonb; v_audits jsonb; v_contam jsonb; v_decay jsonb;
BEGIN
  v_sessions := ops.fn_sweep_sessions(86400);
  v_audits   := ops.fn_sweep_audit_artifacts(14);
  v_contam   := ops.fn_scan_contamination();
  v_decay    := ops.fn_decay_freshness(30);
  INSERT INTO ops.runtime_execution_receipts
    (task_id, action, status, result, evidence, gaps, next_action, instruction_sha, actor_id, runtime_id)
  VALUES (
    'runtime-tick-' || to_char(now(),'YYYYMMDDHH24MISS'),
    'fn_runtime_tick','REAL',
    jsonb_build_object('sessions',v_sessions,'audits',v_audits,
                       'contamination',v_contam,'decay',v_decay),
    jsonb_build_object('source','ops.fn_runtime_tick'),
    ARRAY[]::text[], 'continue',
    'bootstrap-v1','runtime_tick','ops-runtime'
  );
  RETURN jsonb_build_object('ran_at', now(), 'sessions', v_sessions,
    'audits', v_audits, 'contamination', v_contam, 'decay', v_decay);
END; $$;
