-- ============================================================
-- backlog_reconciliation.sql
-- runtime-proof-sweeper hourly kick installation
-- Per the-pen#145, 2026-05-25
-- ============================================================

-- 1. Kick function: enqueues an hourly sweeper job into ops.work_queue.
--    Dispatcher picks it up; troy-runtime-proof-sweeper Lambda executes it.
--    Idempotent per (year, month, day, hour) via dedupe_key.

CREATE OR REPLACE FUNCTION public.fn_runtime_proof_sweeper_kick()
RETURNS TABLE(job_id uuid, status text, dedupe_key text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_dedupe_key text;
  v_job_id uuid;
BEGIN
  v_dedupe_key := 'runtime-proof-sweeper:' || to_char(now() AT TIME ZONE 'UTC', 'YYYY-MM-DD-HH24');

  INSERT INTO ops.work_queue (
    title, description, status, origin, destination, env,
    payload, dedupe_key, llm_source, project_code, topic,
    max_retries, last_heartbeat, created_at, updated_at
  )
  VALUES (
    'runtime-proof-sweeper hourly run ' || v_dedupe_key,
    'Per the-pen#145 contract. Inspects all open issues/PRs/queue, classifies REAL/PARTIAL/BLOCKED, requeues stale non-destructively, writes receipt.',
    'ready',
    'fn_runtime_proof_sweeper_kick',
    'troy-runtime-proof-sweeper',
    'prod',
    jsonb_build_object(
      'task_type', 'runtime_proof_sweep',
      'sweep_window_hours', 1,
      'requeue_non_destructive', true,
      'write_receipt', true,
      'contract', 'the-pen#145'
    ),
    v_dedupe_key,
    'cron', 'PHASE_C_SWEEPER', 'runtime_proof_sweeper',
    3, NULL, now(), now()
  )
  ON CONFLICT (dedupe_key) DO NOTHING
  RETURNING work_queue.job_id INTO v_job_id;

  IF v_job_id IS NULL THEN
    -- Already enqueued for this hour; return existing
    SELECT q.job_id INTO v_job_id FROM ops.work_queue q WHERE q.dedupe_key = v_dedupe_key LIMIT 1;
    job_id := v_job_id; status := 'duplicate_skipped'; dedupe_key := v_dedupe_key;
  ELSE
    job_id := v_job_id; status := 'enqueued'; dedupe_key := v_dedupe_key;
  END IF;
  RETURN NEXT;
END;
$$;

-- 2. Hourly cron job
--    NOTE: this function depends on Lambda 'troy-runtime-proof-sweeper' being deployed.
--    Until then, enqueued jobs will sit at status='ready' with a bounded blocker.

SELECT cron.schedule(
  'runtime_proof_sweeper_hourly',
  '15 * * * *',
  'SELECT public.fn_runtime_proof_sweeper_kick()'
)
WHERE NOT EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'runtime_proof_sweeper_hourly'
);

-- 3. Command Centre widget view: counts per latest sweep
CREATE OR REPLACE VIEW public.v_runtime_proof_sweeper_latest AS
WITH latest AS (
  SELECT *
  FROM public.reality_ledger
  WHERE system = 'runtime_proof_sweeper'
    AND status = 'REAL'
  ORDER BY last_verified DESC
  LIMIT 1
)
SELECT
  l.last_verified            AS last_run,
  l.component                AS run_label,
  l.evidence ->> 'execution_trace' AS trace,
  l.evidence -> 'api_response'      AS summary
FROM latest l;

-- 4. Verify
SELECT 'fn_runtime_proof_sweeper_kick' AS object, 'installed' AS state
WHERE EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
              WHERE n.nspname='public' AND p.proname='fn_runtime_proof_sweeper_kick')
UNION ALL
SELECT 'cron.job: runtime_proof_sweeper_hourly', CASE WHEN active THEN 'active' ELSE 'inactive' END
FROM cron.job WHERE jobname='runtime_proof_sweeper_hourly'
UNION ALL
SELECT 'v_runtime_proof_sweeper_latest', 'installed'
WHERE EXISTS (SELECT 1 FROM pg_views WHERE schemaname='public' AND viewname='v_runtime_proof_sweeper_latest');
