-- =============================================================================
-- Cross-LLM Session Register — DDL v1
-- For: ops.llm_session_register
-- Author: COAX | Date: 2026-05-05
-- Status: STAGED — execute against S1 (lzfgigiyqpuuxslsygjt) on bridge return
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS ops;

-- Drop-and-recreate gated; safer is CREATE IF NOT EXISTS for first run
CREATE TABLE IF NOT EXISTS ops.llm_session_register (
  session_id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  llm_provider            text NOT NULL CHECK (llm_provider IN
                            ('claude','chatgpt','gemini','copilot','perplexity','grok','other')),
  llm_model               text,                       -- e.g. 'claude-opus-4-7'
  discovery_method        text NOT NULL CHECK (discovery_method IN
                            ('tab','connector','project','named-agent','direct-link','other')),
  discovery_source        text,                        -- which connector/tab/project specifically
  intent_brief            text,                        -- original brief at spin-up
  success_marker          text,                        -- one observable that proves it works
  drift_threshold_pct     int NOT NULL DEFAULT 30,     -- COAX-default; widget rule may override
  scoop_threshold_pct     int NOT NULL DEFAULT 40,
  current_drift_pct       int,                         -- last measured drift
  world_version           text,                        -- spine version this session reconciled to
  onboarded_at            timestamptz NOT NULL DEFAULT now(),
  onboard_cost_min        int,                         -- minutes from spin-up to first useful output
  last_check_in_at        timestamptz,
  last_useful_output_at   timestamptz,
  state                   text NOT NULL DEFAULT 'active' CHECK (state IN
                            ('active','idle','stale','re-anchoring','spiraling','terminated')),
  value_class             text CHECK (value_class IN ('REAL','PARTIAL','PRETEND')),
  spiral_indicators       jsonb DEFAULT '[]'::jsonb,   -- list of detected indicators
  offboard_at             timestamptz,
  offboard_reason         text,
  total_minutes_invested  int,
  net_value_score         numeric(3,2),                -- 0.00 to 1.00
  notes                   text,
  created_at              timestamptz NOT NULL DEFAULT now(),
  updated_at              timestamptz NOT NULL DEFAULT now()
);

-- Indexes for the queries we'll run weekly
CREATE INDEX IF NOT EXISTS idx_llm_session_provider     ON ops.llm_session_register (llm_provider);
CREATE INDEX IF NOT EXISTS idx_llm_session_state        ON ops.llm_session_register (state);
CREATE INDEX IF NOT EXISTS idx_llm_session_value_class  ON ops.llm_session_register (value_class);
CREATE INDEX IF NOT EXISTS idx_llm_session_discovery    ON ops.llm_session_register (discovery_method);
CREATE INDEX IF NOT EXISTS idx_llm_session_onboarded_at ON ops.llm_session_register (onboarded_at DESC);

-- Updated_at trigger (re-uses existing helper if present)
CREATE OR REPLACE FUNCTION ops.fn_set_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_llm_session_updated_at ON ops.llm_session_register;
CREATE TRIGGER trg_llm_session_updated_at
  BEFORE UPDATE ON ops.llm_session_register
  FOR EACH ROW EXECUTE FUNCTION ops.fn_set_updated_at();

-- =============================================================================
-- Weekly aggregate view: which discovery channels are net-positive
-- =============================================================================

CREATE OR REPLACE VIEW ops.v_session_channel_value AS
SELECT
  discovery_method,
  llm_provider,
  COUNT(*)                                              AS sessions_total,
  COUNT(*) FILTER (WHERE value_class = 'REAL')          AS sessions_real,
  COUNT(*) FILTER (WHERE value_class = 'PARTIAL')       AS sessions_partial,
  COUNT(*) FILTER (WHERE value_class = 'PRETEND')       AS sessions_pretend,
  COUNT(*) FILTER (WHERE state = 'spiraling')           AS sessions_spiraled,
  ROUND(AVG(onboard_cost_min)::numeric, 1)              AS avg_onboard_min,
  ROUND(AVG(total_minutes_invested)::numeric, 1)        AS avg_total_min,
  ROUND(AVG(net_value_score)::numeric, 2)               AS avg_value_score,
  -- net-positive if more REAL than PRETEND and avg_value_score > 0.5
  CASE
    WHEN COUNT(*) FILTER (WHERE value_class = 'REAL') >
         COUNT(*) FILTER (WHERE value_class = 'PRETEND')
         AND AVG(net_value_score) > 0.5
    THEN 'KEEP'
    WHEN COUNT(*) FILTER (WHERE value_class = 'PRETEND') >=
         COUNT(*) FILTER (WHERE value_class = 'REAL') * 2
    THEN 'DROP'
    ELSE 'WATCH'
  END                                                    AS doctrine_call
FROM ops.llm_session_register
WHERE onboarded_at >= now() - interval '90 days'
GROUP BY discovery_method, llm_provider
ORDER BY avg_value_score DESC NULLS LAST;

-- =============================================================================
-- Stale-session sweep: candidates for scoop-and-thanks
-- =============================================================================

CREATE OR REPLACE VIEW ops.v_session_scoop_candidates AS
SELECT
  session_id,
  llm_provider,
  discovery_method,
  intent_brief,
  state,
  current_drift_pct,
  total_minutes_invested,
  EXTRACT(EPOCH FROM (now() - last_check_in_at))/3600 AS hours_since_checkin,
  CASE
    WHEN current_drift_pct >= scoop_threshold_pct THEN 'scoop_drift'
    WHEN state IN ('idle','stale') AND last_check_in_at < now() - interval '24 hours' THEN 'scoop_stale'
    WHEN state = 'spiraling' THEN 'scoop_spiral'
    WHEN onboard_cost_min IS NOT NULL AND onboard_cost_min > 15 AND value_class IS NULL THEN 'scoop_no_value'
    ELSE 'monitor'
  END AS scoop_recommendation
FROM ops.llm_session_register
WHERE state != 'terminated'
ORDER BY total_minutes_invested DESC NULLS LAST;

-- =============================================================================
-- RLS — read open, write via service role only
-- =============================================================================

ALTER TABLE ops.llm_session_register ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS p_llm_session_read ON ops.llm_session_register;
CREATE POLICY p_llm_session_read ON ops.llm_session_register FOR SELECT USING (true);

-- writes restricted to service_role (Supabase default)
DROP POLICY IF EXISTS p_llm_session_write ON ops.llm_session_register;
CREATE POLICY p_llm_session_write ON ops.llm_session_register
  FOR ALL USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- =============================================================================
-- Smoke test (run after creation)
-- =============================================================================

-- Insert canary
INSERT INTO ops.llm_session_register
  (llm_provider, llm_model, discovery_method, intent_brief, success_marker, world_version)
VALUES
  ('claude', 'claude-opus-4-7', 'project', 'COAX dispatch session 2026-05-05',
   'Five artefacts produced and staged for bridge return',
   'spine-v2-2026-05-05')
RETURNING session_id, onboarded_at;

-- Verify aggregate works
SELECT * FROM ops.v_session_channel_value LIMIT 5;

-- Verify scoop view works
SELECT * FROM ops.v_session_scoop_candidates LIMIT 5;
