-- ACHRA Scoring RPC v1
-- public.achra_compute_scores(p_session_id uuid) RETURNS jsonb
-- Deployed: 2026-05-11 via Supabase MCP apply_migration
-- Evidence: migration achra_scoring_rpc_v1 + smoke test session f26b86fa

CREATE OR REPLACE FUNCTION public.achra_compute_scores(p_session_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_dims          jsonb := '{}';
  v_friction      numeric;
  v_symbiosis     numeric;
  v_burnout       numeric;
  v_verification  numeric;
  v_archetype     text;
  v_risk          text;
  r               record;
BEGIN
  -- 1. Aggregate dimension weighted averages, normalise 1-7 to 0-100
  SELECT jsonb_object_agg(dim, score) INTO v_dims FROM (
    SELECT i.dimension AS dim,
      GREATEST(0, LEAST(100,
        AVG(
          CASE i.item_type
            WHEN 'likert7' THEN
              CASE WHEN i.reverse
                THEN (8 - (resp.response_raw->>'value')::int) * i.weight
                ELSE     (resp.response_raw->>'value')::int  * i.weight
              END
            WHEN 'frequency' THEN
              CASE resp.response_raw->>'choice'
                WHEN 'never'     THEN 1
                WHEN 'rarely'    THEN 2
                WHEN 'sometimes' THEN 3
                WHEN 'often'     THEN 5
                WHEN 'always'    THEN 7
                ELSE 4
              END * i.weight
            ELSE (resp.response_raw->>'value')::int * i.weight
          END
        ) * 14.2857
      )) AS score
    FROM achra.items i
    JOIN achra.responses resp
      ON resp.item_code = i.item_code
     AND resp.session_id = p_session_id
    GROUP BY i.dimension
  ) sub;

  -- 2. Composites
  v_friction     := COALESCE(((v_dims->>'ai_trust_friction')::numeric + (v_dims->>'cognitive_load_response')::numeric) / 2.0, 50);
  v_symbiosis    := GREATEST(0, LEAST(100,
                     100 - v_friction * 0.5
                     + COALESCE((v_dims->>'ai_learning_velocity')::numeric, 50) * 0.3
                     + COALESCE((v_dims->>'workflow_adaptability')::numeric, 50) * 0.2
                   ));
  v_burnout      := COALESCE((v_dims->>'cognitive_recovery')::numeric, 50) * 0.6
                  + COALESCE((v_dims->>'cognitive_load_response')::numeric, 50) * 0.4;
  v_verification := COALESCE((v_dims->>'ai_trust_friction')::numeric, 50) * 0.7
                  + COALESCE((v_dims->>'human_pref_retention')::numeric, 50) * 0.3;

  -- 3. Archetype assignment
  v_archetype := CASE
    WHEN COALESCE((v_dims->>'curiosity_experimentation')::numeric,0) >= 70
     AND COALESCE((v_dims->>'ai_learning_velocity')::numeric,0)      >= 65 THEN 'AI_EXPLORER'
    WHEN COALESCE((v_dims->>'ai_trust_friction')::numeric,0)         >= 65
     AND COALESCE((v_dims->>'human_pref_retention')::numeric,0)      >= 65 THEN 'VERIFICATION_ANALYST'
    WHEN v_friction <= 35
     AND COALESCE((v_dims->>'ai_learning_velocity')::numeric,0)      >= 60 THEN 'COGNITIVE_AMPLIFIER'
    WHEN v_friction >= 65
     AND COALESCE((v_dims->>'cognitive_recovery')::numeric,0)        >= 65 THEN 'OVERLOADED_OPERATOR'
    WHEN COALESCE((v_dims->>'exec_function_need')::numeric,0)        >= 60 THEN 'ASSISTED_EXECUTOR'
    ELSE 'HUMAN_CENTRIC_STRATEGIST'
  END;

  -- 4. Risk tier
  v_risk := CASE
    WHEN v_burnout >= 75 THEN 'CRITICAL'
    WHEN v_burnout >= 55 THEN 'ELEVATED'
    WHEN v_burnout >= 35 THEN 'MANAGED'
    ELSE 'LOW'
  END;

  -- 5. Upsert scores
  INSERT INTO achra.scores (
    session_id, ai_trust_friction, cognitive_load_response, automation_dependency,
    curiosity_experimentation, identity_threat, workflow_adaptability, exec_function_need,
    human_pref_retention, ai_learning_velocity, cognitive_recovery,
    ai_cognitive_friction_score, human_agent_symbiosis_idx, ai_burnout_risk,
    verification_discipline, archetype, risk_tier
  ) VALUES (
    p_session_id,
    (v_dims->>'ai_trust_friction')::numeric,
    (v_dims->>'cognitive_load_response')::numeric,
    (v_dims->>'automation_dependency')::numeric,
    (v_dims->>'curiosity_experimentation')::numeric,
    (v_dims->>'identity_threat')::numeric,
    (v_dims->>'workflow_adaptability')::numeric,
    (v_dims->>'exec_function_need')::numeric,
    (v_dims->>'human_pref_retention')::numeric,
    (v_dims->>'ai_learning_velocity')::numeric,
    (v_dims->>'cognitive_recovery')::numeric,
    v_friction, v_symbiosis, v_burnout, v_verification, v_archetype, v_risk
  )
  ON CONFLICT (session_id) DO UPDATE SET
    ai_cognitive_friction_score = EXCLUDED.ai_cognitive_friction_score,
    human_agent_symbiosis_idx   = EXCLUDED.human_agent_symbiosis_idx,
    ai_burnout_risk             = EXCLUDED.ai_burnout_risk,
    verification_discipline     = EXCLUDED.verification_discipline,
    archetype                   = EXCLUDED.archetype,
    risk_tier                   = EXCLUDED.risk_tier,
    scored_at                   = now();

  -- 6. Match and insert interventions
  FOR r IN
    SELECT ir.rule_code, ir.actions,
      CASE ir.rule_code
        WHEN 'LOW_TRUST_HIGH_FATIGUE'     THEN 'ONBOARDING'
        WHEN 'HIGH_AUTOMATION_DEPENDENCY' THEN 'CALIBRATION'
        WHEN 'ADHD_HIGH_BENEFIT'          THEN 'SCAFFOLDING'
        WHEN 'OVERLOADED_OPERATOR'        THEN 'ONBOARDING'
        ELSE 'GOVERNANCE'
      END AS category
    FROM achra.intervention_rules ir
    WHERE (
      SELECT bool_and(
        CASE c->>'op' WHEN 'gte' THEN
          CASE c->>'field'
            WHEN 'ai_trust_friction'           THEN COALESCE((v_dims->>'ai_trust_friction')::numeric,0)          >= (c->>'value')::numeric
            WHEN 'cognitive_load_response'     THEN COALESCE((v_dims->>'cognitive_load_response')::numeric,0)    >= (c->>'value')::numeric
            WHEN 'automation_dependency'       THEN COALESCE((v_dims->>'automation_dependency')::numeric,0)      >= (c->>'value')::numeric
            WHEN 'curiosity_experimentation'   THEN COALESCE((v_dims->>'curiosity_experimentation')::numeric,0)  >= (c->>'value')::numeric
            WHEN 'exec_function_need'          THEN COALESCE((v_dims->>'exec_function_need')::numeric,0)         >= (c->>'value')::numeric
            WHEN 'human_pref_retention'        THEN COALESCE((v_dims->>'human_pref_retention')::numeric,0)       >= (c->>'value')::numeric
            WHEN 'ai_learning_velocity'        THEN COALESCE((v_dims->>'ai_learning_velocity')::numeric,0)       >= (c->>'value')::numeric
            WHEN 'cognitive_recovery'          THEN COALESCE((v_dims->>'cognitive_recovery')::numeric,0)         >= (c->>'value')::numeric
            WHEN 'verification_discipline'     THEN v_verification                                               >= (c->>'value')::numeric
            WHEN 'ai_cognitive_friction_score' THEN v_friction                                                   >= (c->>'value')::numeric
            ELSE false END
        ELSE false END
      ) FROM jsonb_array_elements(ir.conditions) AS c
    )
  LOOP
    INSERT INTO achra.interventions (session_id, trigger_rule, category, action_code, label, description, priority)
    SELECT p_session_id, r.rule_code, r.category,
      a->>'action_code', a->>'label', a->>'description', (a->>'priority')::int
    FROM jsonb_array_elements(r.actions) AS a
    ON CONFLICT DO NOTHING;
  END LOOP;

  UPDATE achra.sessions SET completed_at = now() WHERE id = p_session_id;

  RETURN jsonb_build_object(
    'session_id',    p_session_id,
    'archetype',     v_archetype,
    'risk_tier',     v_risk,
    'friction_score', v_friction,
    'symbiosis_idx',  v_symbiosis,
    'burnout_risk',   v_burnout,
    'verification',   v_verification
  );
END;
$$;
