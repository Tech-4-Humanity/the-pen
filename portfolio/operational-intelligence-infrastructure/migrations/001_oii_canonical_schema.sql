-- =====================================================================
-- Operational Intelligence Infrastructure - canonical schema migration
-- Schema: oii
-- Aligned to: GLOBAL_RULE_KERNEL_V6
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS oii;

-- ---------------------------------------------------------------------
-- Catalogue: products (canonical SKUs)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.products (
  sku                text PRIMARY KEY,
  name               text NOT NULL,
  function           text NOT NULL,
  category           text NOT NULL,
  core_capabilities  jsonb NOT NULL DEFAULT '[]'::jsonb,
  default_agents     jsonb NOT NULL DEFAULT '[]'::jsonb,
  required_integrations jsonb NOT NULL DEFAULT '[]'::jsonb,
  optional_integrations jsonb NOT NULL DEFAULT '[]'::jsonb,
  tiers_available    jsonb NOT NULL DEFAULT '[]'::jsonb,
  evidence_outputs   jsonb NOT NULL DEFAULT '[]'::jsonb,
  is_bundle          boolean NOT NULL DEFAULT false,
  includes_skus      jsonb,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Catalogue: wrappers (vertical packs)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.wrappers (
  slug                 text PRIMARY KEY,
  name                 text NOT NULL,
  route                text NOT NULL,
  priority_wave        int NOT NULL,
  parent_wrapper       text REFERENCES oii.wrappers(slug),
  buyer                text NOT NULL,
  verticals_within     jsonb NOT NULL DEFAULT '[]'::jsonb,
  hero                 text NOT NULL,
  subhero              text,
  pains_addressed      jsonb NOT NULL DEFAULT '[]'::jsonb,
  default_skus         jsonb NOT NULL DEFAULT '[]'::jsonb,
  optional_skus        jsonb NOT NULL DEFAULT '[]'::jsonb,
  terminology_overrides jsonb NOT NULL DEFAULT '{}'::jsonb,
  required_integrations jsonb NOT NULL DEFAULT '[]'::jsonb,
  optional_integrations jsonb NOT NULL DEFAULT '[]'::jsonb,
  compliance_packs     jsonb NOT NULL DEFAULT '[]'::jsonb,
  evidence_packs       jsonb NOT NULL DEFAULT '[]'::jsonb,
  case_study_anchor    text,
  is_active            boolean NOT NULL DEFAULT true,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Catalogue: pricing tiers
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.pricing_tiers (
  tier                  text PRIMARY KEY,
  label                 text NOT NULL,
  tagline               text,
  monthly_aud           numeric,
  monthly_aud_starting_from numeric,
  annual_aud            numeric,
  annual_aud_starting_from numeric,
  agent_seats_included  text NOT NULL,
  human_seats_included  text NOT NULL,
  evidence_retention_months text NOT NULL,
  telemetry             text NOT NULL,
  governance            text NOT NULL,
  deployment            text NOT NULL,
  sla                   text NOT NULL,
  skus_available        jsonb NOT NULL DEFAULT '[]'::jsonb,
  stripe_product_id     text,
  stripe_price_monthly_id text,
  stripe_price_annual_id text,
  data_residency        jsonb,
  is_active             boolean NOT NULL DEFAULT true,
  created_at            timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Catalogue: agents
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.agents (
  id                    text PRIMARY KEY,
  class                 text NOT NULL,
  label_default         text NOT NULL,
  label_overrides       jsonb NOT NULL DEFAULT '{}'::jsonb,
  default_skus          jsonb NOT NULL DEFAULT '[]'::jsonb,
  required_capabilities jsonb NOT NULL DEFAULT '[]'::jsonb,
  required_authority    text NOT NULL,
  escalation_target     text,
  is_active             boolean NOT NULL DEFAULT true,
  created_at            timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Runtime: tenants
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.tenants (
  tenant_id     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  wrapper_slug  text NOT NULL REFERENCES oii.wrappers(slug),
  tier          text NOT NULL REFERENCES oii.pricing_tiers(tier),
  status        text NOT NULL DEFAULT 'active'
                 CHECK (status IN ('active','suspended','offboarded')),
  metadata      jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Runtime: universal event stream
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.events (
  event_id              uuid PRIMARY KEY,
  event_type            text NOT NULL,
  occurred_at           timestamptz NOT NULL,
  received_at           timestamptz NOT NULL DEFAULT now(),
  actor_id              text NOT NULL,
  tenant_id             uuid REFERENCES oii.tenants(tenant_id),
  execution_id          text NOT NULL,
  runtime_id            text NOT NULL,
  session_id            text NOT NULL,
  orchestration_id      text,
  execution_nonce       text NOT NULL,
  wrapper_slug          text NOT NULL,
  sku                   text NOT NULL,
  agent_id              text,
  classification        text NOT NULL
                          CHECK (classification IN ('REAL','PARTIAL','BLOCKED')),
  evidence              jsonb NOT NULL DEFAULT '[]'::jsonb,
  causal_parent_event_id uuid,
  recovery              jsonb,
  economics             jsonb,
  payload               jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_oii_events_tenant_time
  ON oii.events (tenant_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_oii_events_execution
  ON oii.events (execution_id);
CREATE INDEX IF NOT EXISTS idx_oii_events_classification
  ON oii.events (classification);
CREATE INDEX IF NOT EXISTS idx_oii_events_event_type
  ON oii.events (event_type);

-- ---------------------------------------------------------------------
-- Runtime: evidence register
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.evidence_register (
  evidence_id    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid REFERENCES oii.tenants(tenant_id),
  event_id       uuid REFERENCES oii.events(event_id),
  evidence_type  text NOT NULL,
  value          text NOT NULL,
  hash           text,
  expires_at     timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_oii_evidence_tenant
  ON oii.evidence_register (tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_oii_evidence_event
  ON oii.evidence_register (event_id);

-- ---------------------------------------------------------------------
-- Runtime: per-tenant classification ledger
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.tenant_classification_ledger (
  ledger_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL REFERENCES oii.tenants(tenant_id),
  sku              text NOT NULL REFERENCES oii.products(sku),
  classification   text NOT NULL
                     CHECK (classification IN ('REAL','PARTIAL','BLOCKED')),
  reason           text,
  evidence_refs    jsonb NOT NULL DEFAULT '[]'::jsonb,
  last_verified    timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_oii_tenant_sku
  ON oii.tenant_classification_ledger (tenant_id, sku);

-- ---------------------------------------------------------------------
-- Runtime: drift events
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.drift_events (
  drift_id     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid REFERENCES oii.tenants(tenant_id),
  drift_type   text NOT NULL,
  response     text NOT NULL,
  resolved     boolean NOT NULL DEFAULT false,
  detail       jsonb,
  detected_at  timestamptz NOT NULL DEFAULT now(),
  resolved_at  timestamptz
);

-- ---------------------------------------------------------------------
-- Catalogue: workflow modules
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oii.workflows (
  id                 text PRIMARY KEY,
  name               text NOT NULL,
  steps              jsonb NOT NULL DEFAULT '[]'::jsonb,
  evidence_outputs   jsonb NOT NULL DEFAULT '[]'::jsonb,
  recovery_strategies jsonb NOT NULL DEFAULT '[]'::jsonb,
  used_by_wrappers   jsonb NOT NULL DEFAULT '[]'::jsonb,
  is_active          boolean NOT NULL DEFAULT true
);

-- =====================================================================
-- Seed: pricing tiers
-- =====================================================================
INSERT INTO oii.pricing_tiers
  (tier, label, tagline, monthly_aud, annual_aud, agent_seats_included,
   human_seats_included, evidence_retention_months, telemetry, governance,
   deployment, sla, skus_available)
VALUES
  ('foundation','Foundation','Connect systems and capture evidence.',
   199, 2148, '1','1','12','basic','shared','shared_multitenant','best_effort',
   '["ai_front_desk","ai_booking_desk","ai_ops_dashboard"]'::jsonb),
  ('structured','Structured','Operational intelligence with workflow automation.',
   599, 6468, '3','3','36','standard','shared_with_audit_export','shared_multitenant','business_hours',
   '["ai_front_desk","ai_proposal_desk","ai_booking_desk","ai_growth_desk","ai_evidence_desk","ai_ops_dashboard","ai_retention_desk","ai_memory_desk"]'::jsonb),
  ('autonomous','Autonomous','Multi-agent orchestration with recovery and replay.',
   1799, 19404, '10','10','84','full','real_partial_blocked_classification','shared_multitenant_with_isolated_data','24x7_response',
   '["all_except_full_vertical_ai_os"]'::jsonb)
ON CONFLICT (tier) DO NOTHING;

INSERT INTO oii.pricing_tiers
  (tier, label, tagline, monthly_aud_starting_from, annual_aud_starting_from,
   agent_seats_included, human_seats_included, evidence_retention_months,
   telemetry, governance, deployment, sla, skus_available)
VALUES
  ('enterprise','Enterprise','Governance, telemetry, and evidence at scale.',
   4999, 53989, '50','50','120','full_plus_export','policy_engine_with_approval_chains',
   'dedicated_database_shared_compute','24x7_priority','["all"]'::jsonb),
  ('sovereign','Sovereign','Dedicated private runtime.',
   14999, 161989, 'unlimited','unlimited','configurable_up_to_240',
   'full_plus_data_residency','full_policy_engine_with_data_residency',
   'dedicated_runtime_dedicated_database','named_engineer_24x7','["all"]'::jsonb)
ON CONFLICT (tier) DO NOTHING;

-- =====================================================================
-- Seed: governance promotion gate function
-- =====================================================================
CREATE OR REPLACE FUNCTION oii.promote_to_real(
  p_tenant_id uuid,
  p_sku text,
  p_evidence jsonb
) RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_ledger_id uuid;
  v_has_evidence boolean;
  v_has_telemetry boolean;
BEGIN
  -- evidence presence check
  v_has_evidence := jsonb_array_length(p_evidence) > 0;

  -- telemetry presence check
  SELECT EXISTS (
    SELECT 1 FROM oii.events
    WHERE tenant_id = p_tenant_id
      AND sku = p_sku
      AND classification = 'REAL'
    LIMIT 1
  ) INTO v_has_telemetry;

  IF NOT v_has_evidence OR NOT v_has_telemetry THEN
    -- promote to PARTIAL instead
    INSERT INTO oii.tenant_classification_ledger
      (tenant_id, sku, classification, reason, evidence_refs)
    VALUES
      (p_tenant_id, p_sku, 'PARTIAL',
       CASE
         WHEN NOT v_has_evidence THEN 'missing_evidence'
         WHEN NOT v_has_telemetry THEN 'missing_telemetry'
       END,
       p_evidence)
    ON CONFLICT (tenant_id, sku)
    DO UPDATE SET classification = EXCLUDED.classification,
                  reason = EXCLUDED.reason,
                  evidence_refs = EXCLUDED.evidence_refs,
                  last_verified = now()
    RETURNING ledger_id INTO v_ledger_id;
    RETURN v_ledger_id;
  END IF;

  INSERT INTO oii.tenant_classification_ledger
    (tenant_id, sku, classification, evidence_refs)
  VALUES
    (p_tenant_id, p_sku, 'REAL', p_evidence)
  ON CONFLICT (tenant_id, sku)
  DO UPDATE SET classification = 'REAL',
                reason = NULL,
                evidence_refs = EXCLUDED.evidence_refs,
                last_verified = now()
  RETURNING ledger_id INTO v_ledger_id;

  RETURN v_ledger_id;
END
$$;

-- =====================================================================
-- View: runtime classification rollup per wrapper
-- =====================================================================
CREATE OR REPLACE VIEW oii.v_wrapper_classification_rollup AS
SELECT
  t.wrapper_slug,
  l.classification,
  count(*) AS tenant_sku_count
FROM oii.tenant_classification_ledger l
JOIN oii.tenants t ON t.tenant_id = l.tenant_id
GROUP BY t.wrapper_slug, l.classification;

-- =====================================================================
-- Migration receipt
-- =====================================================================
DO $$
BEGIN
  RAISE NOTICE 'OII canonical schema migration applied at %', now();
END $$;
