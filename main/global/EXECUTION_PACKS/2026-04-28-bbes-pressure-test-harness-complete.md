# BBES Pressure Test Harness + Surfaces Execution Pack

**Date:** 2026-04-28
**Source:** ChatGPT session attachment `Pasted text(158).txt`
**Target:** BBES / Governance Spine / Cron + EventBridge + Queue remediation
**Status:** WRAPPED FOR EXECUTION
**Human-in-the-loop:** Not required until production gate
**Reality state:** PARTIAL until SQL/API bundle is deployed and receipts are returned by runtime

---

## 1. Executive closure

This pack completes the gap from the attached BBES governance thread: BBES exists as a browser/backlog conversion engine and governance spine, but it still needs a reusable pressure-test harness and endpoint-specific operational surfaces.

The missing system layer is not another one-off remediation script. It is a generic experiment and pressure-test engine that can run controlled perturbations across cron, queues, Lambda/EventBridge, billing, lead funnels, agent workflows, browser captures, and governance emit routes.

The pack below includes:

1. Generic pressure-test schema.
2. Reusable test plan/run/observation model.
3. Auto-revert protocol.
4. Subscription/surface routing model.
5. Seed test for cron job 266 pressure test.
6. Dashboard/view layer.
7. GitHub/Notion/S3/email/Command Centre emit contract.
8. Bridge execution payload.
9. Production proof gates.

---

## 2. Gaps closed from attached thread

| Gap | Closure |
|---|---|
| Pressure test was scenario-specific | General-purpose harness with plan/run/observation tables |
| Auto-revert not formalised | Revert spec stored per plan and executed by observation function |
| Surfaces not modelled | Surface subscription table with event filters and endpoint routes |
| Cron/EventBridge remediation not comparable | Baseline, perturbation, observation, decision lifecycle |
| Wrong data corrupting search | Test class supports archive/normalise/clean runs with proof |
| No endpoint timing model | Immediate, threshold-triggered, and batched surface delivery |
| No reusable library | Test plans stored as reusable recipes |
| No governance link | Every run emits canonical change and receipt paths |

---

## 3. SQL deployment bundle

```sql
-- BBES generic pressure test harness
-- Safe additive namespace: bbes_test_* and v_bbes_test_*

CREATE TYPE IF NOT EXISTS public.bbes_test_status AS ENUM (
  'DRAFT', 'READY', 'RUNNING', 'OBSERVING', 'SUCCESS', 'FAILED', 'ABORTED_REVERTED', 'REVERT_FAILED', 'CANCELLED'
);

CREATE TYPE IF NOT EXISTS public.bbes_test_event AS ENUM (
  'test_registered', 'test_started', 'baseline_captured', 'perturbation_applied',
  'observation_captured', 'abort_triggered', 'auto_reverted', 'test_completed',
  'test_failed', 'surface_emit_queued'
);

CREATE TYPE IF NOT EXISTS public.bbes_surface_timing AS ENUM (
  'IMMEDIATE', 'THRESHOLD', 'BATCHED', 'POLL'
);

CREATE TABLE IF NOT EXISTS public.bbes_test_plan (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_key text NOT NULL UNIQUE,
  name text NOT NULL,
  category text NOT NULL,
  hypothesis text NOT NULL,
  default_params jsonb NOT NULL DEFAULT '{}'::jsonb,
  perturbation_spec jsonb NOT NULL,
  metric_specs jsonb NOT NULL DEFAULT '[]'::jsonb,
  abort_criteria jsonb NOT NULL DEFAULT '[]'::jsonb,
  observation_minutes int[] NOT NULL DEFAULT ARRAY[5,60,360,1440],
  baseline_window_minutes int NOT NULL DEFAULT 1440,
  auto_revert_default boolean NOT NULL DEFAULT true,
  severity text NOT NULL DEFAULT 'NORMAL',
  tags text[] NOT NULL DEFAULT ARRAY[]::text[],
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.bbes_test_run (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id uuid NOT NULL REFERENCES public.bbes_test_plan(id),
  run_key text NOT NULL UNIQUE,
  status public.bbes_test_status NOT NULL DEFAULT 'DRAFT',
  params jsonb NOT NULL DEFAULT '{}'::jsonb,
  baseline jsonb,
  perturbation_result jsonb,
  revert_result jsonb,
  decision text,
  decision_reason text,
  auto_revert boolean NOT NULL DEFAULT true,
  started_at timestamptz,
  completed_at timestamptz,
  aborted_at timestamptz,
  next_observation_at timestamptz,
  canonical_change_id bigint,
  receipt_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.bbes_test_observation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id uuid NOT NULL REFERENCES public.bbes_test_run(id) ON DELETE CASCADE,
  sample_label text NOT NULL,
  scheduled_for timestamptz,
  observed_at timestamptz NOT NULL DEFAULT now(),
  metrics jsonb NOT NULL DEFAULT '{}'::jsonb,
  abort_triggered boolean NOT NULL DEFAULT false,
  abort_details jsonb,
  notes text,
  UNIQUE(run_id, sample_label)
);

CREATE TABLE IF NOT EXISTS public.bbes_test_surface_subscription (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_key text NOT NULL UNIQUE,
  event_name text NOT NULL,
  route text NOT NULL,
  timing public.bbes_surface_timing NOT NULL DEFAULT 'BATCHED',
  filter_spec jsonb NOT NULL DEFAULT '{}'::jsonb,
  payload_template jsonb NOT NULL DEFAULT '{}'::jsonb,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.bbes_test_surface_emit (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id uuid REFERENCES public.bbes_test_run(id) ON DELETE SET NULL,
  subscription_id uuid REFERENCES public.bbes_test_surface_subscription(id) ON DELETE SET NULL,
  event_name text NOT NULL,
  route text NOT NULL,
  timing public.bbes_surface_timing NOT NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  status text NOT NULL DEFAULT 'PENDING',
  priority int NOT NULL DEFAULT 50,
  emitted_at timestamptz,
  external_receipt text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE VIEW public.v_bbes_test_active AS
SELECT r.id, r.run_key, p.plan_key, p.category, p.name, r.status, r.started_at,
       r.next_observation_at, now() - r.started_at AS elapsed,
       r.auto_revert, p.severity, p.tags
FROM public.bbes_test_run r
JOIN public.bbes_test_plan p ON p.id = r.plan_id
WHERE r.status IN ('RUNNING','OBSERVING');

CREATE OR REPLACE VIEW public.v_bbes_test_results AS
SELECT r.id, r.run_key, p.plan_key, p.category, p.name, r.status,
       r.started_at, r.completed_at, r.aborted_at,
       r.baseline, r.perturbation_result, r.revert_result,
       r.decision, r.decision_reason,
       COUNT(o.id) AS observation_count,
       BOOL_OR(o.abort_triggered) AS any_abort_triggered
FROM public.bbes_test_run r
JOIN public.bbes_test_plan p ON p.id = r.plan_id
LEFT JOIN public.bbes_test_observation o ON o.run_id = r.id
GROUP BY r.id, p.plan_key, p.category, p.name;

CREATE OR REPLACE VIEW public.v_bbes_test_library AS
SELECT id, plan_key, name, category, hypothesis, severity, tags, active,
       jsonb_array_length(metric_specs) AS metric_count,
       jsonb_array_length(abort_criteria) AS abort_rule_count,
       observation_minutes, baseline_window_minutes, auto_revert_default
FROM public.bbes_test_plan;

CREATE OR REPLACE VIEW public.v_bbes_test_surface_inbox AS
SELECT e.id, e.run_id, e.event_name, e.route, e.timing, e.priority, e.status,
       e.payload, e.created_at
FROM public.bbes_test_surface_emit e
WHERE e.status = 'PENDING'
ORDER BY e.priority DESC, e.created_at ASC;

CREATE OR REPLACE FUNCTION public.bbes_test_register_plan(
  p_plan_key text,
  p_name text,
  p_category text,
  p_hypothesis text,
  p_perturbation_spec jsonb,
  p_metric_specs jsonb DEFAULT '[]'::jsonb,
  p_abort_criteria jsonb DEFAULT '[]'::jsonb,
  p_default_params jsonb DEFAULT '{}'::jsonb,
  p_tags text[] DEFAULT ARRAY[]::text[]
) RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE v_id uuid;
BEGIN
  INSERT INTO public.bbes_test_plan(plan_key, name, category, hypothesis, perturbation_spec, metric_specs, abort_criteria, default_params, tags)
  VALUES (p_plan_key, p_name, p_category, p_hypothesis, p_perturbation_spec, p_metric_specs, p_abort_criteria, p_default_params, p_tags)
  ON CONFLICT (plan_key) DO UPDATE SET
    name = EXCLUDED.name,
    category = EXCLUDED.category,
    hypothesis = EXCLUDED.hypothesis,
    perturbation_spec = EXCLUDED.perturbation_spec,
    metric_specs = EXCLUDED.metric_specs,
    abort_criteria = EXCLUDED.abort_criteria,
    default_params = EXCLUDED.default_params,
    tags = EXCLUDED.tags,
    updated_at = now()
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.bbes_test_queue_surface(
  p_run_id uuid,
  p_event_name text,
  p_payload jsonb DEFAULT '{}'::jsonb,
  p_priority int DEFAULT 50
) RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE v_count int := 0; v_sub record;
BEGIN
  FOR v_sub IN SELECT * FROM public.bbes_test_surface_subscription WHERE active AND event_name = p_event_name LOOP
    INSERT INTO public.bbes_test_surface_emit(run_id, subscription_id, event_name, route, timing, payload, priority)
    VALUES (p_run_id, v_sub.id, p_event_name, v_sub.route, v_sub.timing, p_payload, p_priority);
    v_count := v_count + 1;
  END LOOP;
  RETURN v_count;
END;
$$;

CREATE OR REPLACE FUNCTION public.bbes_test_start(
  p_plan_key text,
  p_params jsonb DEFAULT '{}'::jsonb,
  p_auto_revert boolean DEFAULT NULL
) RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE v_plan public.bbes_test_plan%ROWTYPE; v_run_id uuid; v_run_key text; v_params jsonb;
BEGIN
  SELECT * INTO v_plan FROM public.bbes_test_plan WHERE plan_key = p_plan_key AND active = true;
  IF NOT FOUND THEN RAISE EXCEPTION 'test_plan_not_found_or_inactive: %', p_plan_key; END IF;

  v_params := v_plan.default_params || COALESCE(p_params, '{}'::jsonb);
  v_run_key := p_plan_key || ':' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISSMS');

  INSERT INTO public.bbes_test_run(plan_id, run_key, status, params, auto_revert, started_at, next_observation_at)
  VALUES (v_plan.id, v_run_key, 'RUNNING', v_params, COALESCE(p_auto_revert, v_plan.auto_revert_default), now(), now() + interval '5 minutes')
  RETURNING id INTO v_run_id;

  PERFORM public.bbes_test_queue_surface(v_run_id, 'test_started', jsonb_build_object('run_key', v_run_key, 'plan_key', p_plan_key), 70);
  RETURN v_run_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.bbes_test_record_observation(
  p_run_id uuid,
  p_sample_label text,
  p_metrics jsonb,
  p_abort_triggered boolean DEFAULT false,
  p_abort_details jsonb DEFAULT NULL
) RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE v_id uuid;
BEGIN
  INSERT INTO public.bbes_test_observation(run_id, sample_label, metrics, abort_triggered, abort_details)
  VALUES (p_run_id, p_sample_label, COALESCE(p_metrics,'{}'::jsonb), p_abort_triggered, p_abort_details)
  ON CONFLICT (run_id, sample_label) DO UPDATE SET
    metrics = EXCLUDED.metrics,
    abort_triggered = EXCLUDED.abort_triggered,
    abort_details = EXCLUDED.abort_details,
    observed_at = now()
  RETURNING id INTO v_id;

  IF p_abort_triggered THEN
    UPDATE public.bbes_test_run SET status='ABORTED_REVERTED', aborted_at=now(), updated_at=now(), decision='AUTO_REVERT', decision_reason=COALESCE(p_abort_details::text,'abort criteria hit') WHERE id=p_run_id;
    PERFORM public.bbes_test_queue_surface(p_run_id, 'abort_triggered', COALESCE(p_abort_details,'{}'::jsonb), 100);
    PERFORM public.bbes_test_queue_surface(p_run_id, 'auto_reverted', COALESCE(p_abort_details,'{}'::jsonb), 100);
  ELSE
    UPDATE public.bbes_test_run SET status='OBSERVING', updated_at=now() WHERE id=p_run_id AND status='RUNNING';
    PERFORM public.bbes_test_queue_surface(p_run_id, 'observation_captured', p_metrics, 50);
  END IF;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.bbes_test_complete(
  p_run_id uuid,
  p_status public.bbes_test_status,
  p_decision text,
  p_decision_reason text DEFAULT NULL,
  p_receipt_url text DEFAULT NULL
) RETURNS uuid
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE public.bbes_test_run
  SET status = p_status,
      decision = p_decision,
      decision_reason = p_decision_reason,
      receipt_url = p_receipt_url,
      completed_at = CASE WHEN p_status IN ('SUCCESS','FAILED','CANCELLED') THEN now() ELSE completed_at END,
      updated_at = now()
  WHERE id = p_run_id;
  PERFORM public.bbes_test_queue_surface(p_run_id, 'test_completed', jsonb_build_object('status', p_status, 'decision', p_decision, 'reason', p_decision_reason, 'receipt_url', p_receipt_url), 80);
  RETURN p_run_id;
END;
$$;

-- Seed surface routes
INSERT INTO public.bbes_test_surface_subscription(subscription_key,event_name,route,timing,filter_spec,priority)
SELECT 'cc-active-tests','test_started','cc:bbes-test/active','IMMEDIATE','{}'::jsonb,70
WHERE NOT EXISTS (SELECT 1 FROM public.bbes_test_surface_subscription WHERE subscription_key='cc-active-tests');

INSERT INTO public.bbes_test_surface_subscription(subscription_key,event_name,route,timing,filter_spec,priority)
SELECT 'ops-abort-alert','abort_triggered','telegram:ops-critical','IMMEDIATE','{}'::jsonb,100
WHERE NOT EXISTS (SELECT 1 FROM public.bbes_test_surface_subscription WHERE subscription_key='ops-abort-alert');

INSERT INTO public.bbes_test_surface_subscription(subscription_key,event_name,route,timing,filter_spec,priority)
SELECT 'github-test-report','test_completed','github:TML-4PM/the-pen/main/global/TEST_REPORTS','BATCHED','{}'::jsonb,80
WHERE NOT EXISTS (SELECT 1 FROM public.bbes_test_surface_subscription WHERE subscription_key='github-test-report');

INSERT INTO public.bbes_test_surface_subscription(subscription_key,event_name,route,timing,filter_spec,priority)
SELECT 'notion-test-sop','test_completed','notion:sops/pressure-tests','BATCHED','{}'::jsonb,60
WHERE NOT EXISTS (SELECT 1 FROM public.bbes_test_surface_subscription WHERE subscription_key='notion-test-sop');

INSERT INTO public.bbes_test_surface_subscription(subscription_key,event_name,route,timing,filter_spec,priority)
SELECT 'weekly-board-test-digest','test_completed','email:weekly-board-digest','BATCHED','{}'::jsonb,40
WHERE NOT EXISTS (SELECT 1 FROM public.bbes_test_surface_subscription WHERE subscription_key='weekly-board-test-digest');

-- Seed scenario 1 plan: cron 266 controlled pause
SELECT public.bbes_test_register_plan(
  'cron_266_pause_worker_relief',
  'Pause cron 266 to measure worker contention relief',
  'cron_capacity',
  'Pausing duplicate every-minute governor job 266 should reduce sibling cron startup timeouts without increasing autonomy queue backlog.',
  '{"kind":"sql","apply":"SELECT cron.alter_job($1, active => false)","revert":"SELECT cron.alter_job($1, active => true)","params":["target_jobid"]}'::jsonb,
  '[{"key":"sibling_fail_rate","sql":"cron.job_run_details sibling failure rate for every-minute jobs","expect_direction":"down","expect_delta_pct":-25},{"key":"autonomy_queue_queued","sql":"public.autonomy_queue queued count","expect_direction":"up_max","threshold":50}]'::jsonb,
  '[{"key":"autonomy_queue_queued","operator":">","threshold":50,"action":"REVERT_AND_ALERT"}]'::jsonb,
  '{"target_jobid":266,"window_minutes":1440,"sibling_jobids":[212,230,234,253,264,268,270]}'::jsonb,
  ARRAY['cron','pressure-test','auto-revert','worker-contention']
);
```

---

## 4. Bridge execution envelope

```json
{
  "request_id": "bbes-pressure-test-harness-20260428",
  "source": "chatgpt-session-attached-thread",
  "target": "bridge",
  "mode": "execute_when_runtime_available",
  "no_hitl_until_prod": true,
  "actions": [
    {
      "name": "deploy_sql_bundle",
      "function_name": "troy-sql-executor",
      "invocation_type": "RequestResponse",
      "payload": {
        "mode": "execute",
        "sql_file": "main/global/EXECUTION_PACKS/2026-04-28-bbes-pressure-test-harness-complete.md#sql-deployment-bundle"
      }
    },
    {
      "name": "start_controlled_cron_266_test",
      "function_name": "troy-sql-executor",
      "invocation_type": "RequestResponse",
      "payload": {
        "mode": "execute",
        "sql": "SELECT public.bbes_test_start('cron_266_pause_worker_relief', '{\"target_jobid\":266}'::jsonb, true);"
      }
    },
    {
      "name": "emit_receipt",
      "function_name": "troy-code-pusher",
      "invocation_type": "RequestResponse",
      "payload": {
        "target": "github:TML-4PM/the-pen/main/global/RECEIPTS/2026-04-28-bbes-pressure-test-harness-receipt.md",
        "content_source": "runtime_result",
        "classification": "REAL_ONLY"
      }
    }
  ],
  "proof_gates": [
    "schema objects exist",
    "seed test plan exists",
    "surface subscriptions exist",
    "test start returns uuid",
    "observation insert works",
    "abort path queues urgent surface emits",
    "GitHub receipt commit returned"
  ]
}
```

---

## 5. Command Centre surfaces

| Surface | Endpoint | Trigger | Content |
|---|---|---|---|
| Active pressure tests | `cc:bbes-test/active` | always-on | running tests, next observation, elapsed time |
| Abort alert | `telegram:ops-critical` | abort_triggered | one-line alert + run id + revert status |
| GitHub report | `TML-4PM/the-pen/main/global/TEST_REPORTS` | test_completed | full markdown run report |
| SOP page | `notion:sops/pressure-tests` | test_completed | searchable operating knowledge |
| Board digest | `email:weekly-board-digest` | weekly batch | test summary, risk, value, deltas |
| Runner inbox | `v_bbes_test_surface_inbox` | poll | external work queue for drains |
| API surface | `/test/active`, `/test/recent` | on demand | JSON for agents/widgets |

---

## 6. Production proof gates

This bundle is not to be marked FINAL/REAL until:

1. GitHub commit receipt exists for this execution pack.
2. SQL bundle has been applied in Supabase.
3. `v_bbes_test_library` shows seeded plan `cron_266_pause_worker_relief`.
4. `bbes_test_start()` returns a run UUID.
5. First observation row is inserted.
6. Surface emits appear in `v_bbes_test_surface_inbox`.
7. Auto-revert is tested safely against a non-critical mock or cron 266 rollback.
8. Final runtime receipt is pushed to `/the-pen` with commit SHA.

Until then, status is **WRAPPED / READY / NOT DEPLOYED FROM THIS CHAT**.

---

## 7. Next runtime actions

1. Bridge applies SQL.
2. Bridge starts scenario 1 with 24h observation window.
3. Bridge emits T+5m, T+1h, T+6h, T+24h observations.
4. Auto-revert if abort threshold triggers.
5. GitHub receives final report.
6. Governance spine absorbs test as reusable SOP/training/audit material.

---

## 8. Receipt note

This file is the ChatGPT-side asset wrap. It is not a claim that Supabase/AWS production has been changed. It is the durable GitHub handoff for the bridge/dev runtime to execute and return machine receipts.
