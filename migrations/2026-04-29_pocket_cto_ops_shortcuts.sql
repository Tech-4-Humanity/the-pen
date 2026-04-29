-- =============================================================================
-- 2026-04-29: CTO-in-pocket ops shortcuts (Wave 1)
-- =============================================================================
-- Six SECURITY DEFINER ops functions for the canonical CC widget surface.
-- Pattern: short name, no value leakage, atomic, idempotent where applicable,
--          auto-logs canonical change row when state mutates.
-- All return jsonb so a single widget can dispatch and render uniformly.
-- =============================================================================

-- 1. fn_op_bridge_probe — single-call health snapshot
CREATE OR REPLACE FUNCTION public.fn_op_bridge_probe()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public, ops
AS $fn$
DECLARE
  v_db_now timestamptz;
  v_last_selftest timestamptz;
  v_selftest_gap interval;
  v_pushes_24h int;
  v_callable_lambdas int;
  v_selftest_status text;
BEGIN
  v_db_now := now();

  SELECT max(start_time) INTO v_last_selftest FROM cron.job_run_details WHERE jobid = 239 AND status = 'succeeded';
  v_selftest_gap := v_db_now - v_last_selftest;
  v_selftest_status := CASE
    WHEN v_selftest_gap < interval '90 minutes' THEN 'OK'
    WHEN v_selftest_gap < interval '6 hours' THEN 'WARN'
    ELSE 'CRITICAL' END;

  SELECT count(*) INTO v_pushes_24h FROM github_push_log
    WHERE pushed_at >= v_db_now - interval '24 hours' AND success;

  SELECT count(*) INTO v_callable_lambdas FROM mcp_lambda_registry WHERE is_callable;

  RETURN jsonb_build_object(
    'ok', v_selftest_status = 'OK',
    'db_now', v_db_now,
    'selftest', jsonb_build_object(
      'last_run_at', v_last_selftest,
      'gap_seconds', extract(epoch from v_selftest_gap)::int,
      'status', v_selftest_status),
    'github_push_24h', v_pushes_24h,
    'callable_lambdas', v_callable_lambdas
  );
END $fn$;

-- 2. fn_op_set_lambda_callable — single-row allow-list flip with audit
CREATE OR REPLACE FUNCTION public.fn_op_set_lambda_callable(
  p_function_name text, p_callable boolean, p_reason text, p_caller text DEFAULT 'manual')
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE v_before boolean; v_canon bigint;
BEGIN
  SELECT is_callable INTO v_before FROM mcp_lambda_registry WHERE function_name = p_function_name;
  IF v_before IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'function not in mcp_lambda_registry');
  END IF;
  IF v_before IS NOT DISTINCT FROM p_callable THEN
    RETURN jsonb_build_object('ok', true, 'noop', true, 'function_name', p_function_name, 'is_callable', v_before);
  END IF;
  UPDATE mcp_lambda_registry
     SET is_callable = p_callable,
         callable_reason = p_reason,
         callable_set_at = now(),
         callable_set_by = p_caller
   WHERE function_name = p_function_name;
  INSERT INTO t4h_canonical_changes (
    change_type, severity, title, summary, affected, broadcast_to, broadcast_ok, author, is_rd, audiences
  ) VALUES (
    'SYSTEM_CHANGE', 'NORMAL',
    format('Lambda allow-list: %s -> is_callable=%s', p_function_name, p_callable),
    format('flip via fn_op_set_lambda_callable. before=%s after=%s reason=%s caller=%s. Bridge cache TTL is 60s.',
      v_before, p_callable, p_reason, p_caller),
    ARRAY['mcp_lambda_registry', p_function_name], ARRAY['operator'], false, p_caller, false,
    ARRAY['ENG_AUDIT','KB_SOP']::gov_audience[]
  ) RETURNING id INTO v_canon;
  RETURN jsonb_build_object(
    'ok', true, 'function_name', p_function_name, 'before', v_before, 'after', p_callable,
    'cache_ttl_seconds', 60, 'canonical_change_id', v_canon);
END $fn$;

-- 3. fn_op_pause_cron / fn_op_resume_cron — pause and resume jobs by id
CREATE OR REPLACE FUNCTION public.fn_op_set_cron_active(
  p_jobid bigint, p_active boolean, p_reason text, p_caller text DEFAULT 'manual')
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public, cron
AS $fn$
DECLARE v_jobname text; v_before boolean; v_canon bigint;
BEGIN
  SELECT jobname, active INTO v_jobname, v_before FROM cron.job WHERE jobid = p_jobid;
  IF v_jobname IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', format('cron jobid %s not found', p_jobid));
  END IF;
  IF v_before IS NOT DISTINCT FROM p_active THEN
    RETURN jsonb_build_object('ok', true, 'noop', true, 'jobid', p_jobid, 'jobname', v_jobname, 'active', v_before);
  END IF;
  PERFORM cron.alter_job(job_id := p_jobid, active := p_active);
  INSERT INTO t4h_canonical_changes (
    change_type, severity, title, summary, affected, broadcast_to, broadcast_ok, author, is_rd, audiences
  ) VALUES (
    'SYSTEM_CHANGE', 'NORMAL',
    format('pg_cron %s (jobid=%s) %s', v_jobname, p_jobid, CASE WHEN p_active THEN 'RESUMED' ELSE 'PAUSED' END),
    format('via fn_op_set_cron_active. before_active=%s after_active=%s reason=%s caller=%s',
      v_before, p_active, p_reason, p_caller),
    ARRAY['cron.job', v_jobname], ARRAY['operator'], false, p_caller, false,
    ARRAY['ENG_AUDIT','KB_SOP']::gov_audience[]
  ) RETURNING id INTO v_canon;
  RETURN jsonb_build_object('ok', true, 'jobid', p_jobid, 'jobname', v_jobname,
    'before_active', v_before, 'after_active', p_active, 'canonical_change_id', v_canon);
END $fn$;

-- 4. fn_op_broadcast — log a canonical change in one call (no boilerplate)
CREATE OR REPLACE FUNCTION public.fn_op_broadcast(
  p_title text, p_summary text,
  p_severity text DEFAULT 'NORMAL',
  p_change_type text DEFAULT 'SYSTEM_CHANGE',
  p_affected text[] DEFAULT ARRAY['ad-hoc'],
  p_caller text DEFAULT 'manual',
  p_audiences text[] DEFAULT ARRAY['ENG_AUDIT'])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE v_id bigint; v_aud gov_audience[];
BEGIN
  SELECT array_agg(a::gov_audience) INTO v_aud FROM unnest(p_audiences) a;
  INSERT INTO t4h_canonical_changes (
    change_type, severity, title, summary, affected, broadcast_to, broadcast_ok, author, is_rd, audiences
  ) VALUES (p_change_type, p_severity, p_title, p_summary, p_affected,
    ARRAY['operator','ai-llms'], false, p_caller, false, v_aud
  ) RETURNING id INTO v_id;
  RETURN jsonb_build_object('ok', true, 'canonical_change_id', v_id, 'severity', p_severity, 'title', p_title);
END $fn$;

-- 5. fn_op_secret_check — verify a secret exists, surface non-sensitive metadata
CREATE OR REPLACE FUNCTION public.fn_op_secret_check(p_key text DEFAULT NULL)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE v_rows jsonb;
BEGIN
  SELECT jsonb_agg(jsonb_build_object(
    'key', key, 'len', length(value), 'is_deprecated', is_deprecated,
    'updated_at', updated_at, 'last_verified_at', last_verified_at, 'is_canonical', is_canonical
  ) ORDER BY key) INTO v_rows
  FROM cap_secrets WHERE p_key IS NULL OR key = p_key;
  RETURN jsonb_build_object('ok', v_rows IS NOT NULL,
    'count', coalesce(jsonb_array_length(v_rows),0), 'secrets', coalesce(v_rows, '[]'::jsonb));
END $fn$;

-- 6. fn_op_pen_status — pen ingest health snapshot
CREATE OR REPLACE FUNCTION public.fn_op_pen_status()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE v_pushes_today int; v_pushes_failed_24h int; v_canon_today int;
BEGIN
  SELECT count(*) INTO v_pushes_today FROM github_push_log
    WHERE pushed_at >= date_trunc('day', now()) AND success
    AND repo = 'TML-4PM/the-pen';
  SELECT count(*) INTO v_pushes_failed_24h FROM github_push_log
    WHERE pushed_at >= now() - interval '24 hours' AND NOT success
    AND repo = 'TML-4PM/the-pen';
  SELECT count(*) INTO v_canon_today FROM t4h_canonical_changes
    WHERE created_at >= date_trunc('day', now());
  RETURN jsonb_build_object('ok', true,
    'pushes_today_pen', v_pushes_today,
    'failed_pushes_24h', v_pushes_failed_24h,
    'canonical_changes_today', v_canon_today,
    'as_of', now());
END $fn$;

COMMENT ON FUNCTION public.fn_op_bridge_probe() IS 'CC widget: bridge + selftest health snapshot in one call';
COMMENT ON FUNCTION public.fn_op_set_lambda_callable(text,boolean,text,text) IS 'CC widget: 1-touch lambda allow-list flip; bridge cache TTL 60s';
COMMENT ON FUNCTION public.fn_op_set_cron_active(bigint,boolean,text,text) IS 'CC widget: pause/resume pg_cron job by id';
COMMENT ON FUNCTION public.fn_op_broadcast(text,text,text,text,text[],text,text[]) IS 'CC widget: log canonical change without boilerplate';
COMMENT ON FUNCTION public.fn_op_secret_check(text) IS 'CC widget: verify cap_secrets metadata, no value leakage';
COMMENT ON FUNCTION public.fn_op_pen_status() IS 'CC widget: pen ingest health snapshot';
