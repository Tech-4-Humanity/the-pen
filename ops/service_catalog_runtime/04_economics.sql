-- Service Catalog Runtime: economics layer (pricing tiers, economic events, quote engine)
-- Deployed migration: service_catalog_runtime_04_economics
-- Date: 2026-05-16

CREATE TABLE IF NOT EXISTS ops.service_catalog_pricing (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  catalog_id text NOT NULL REFERENCES ops.service_catalog_items(catalog_id) ON DELETE CASCADE,
  tier_key text NOT NULL, tier_name text NOT NULL,
  currency text NOT NULL DEFAULT 'AUD',
  billing_cycle text NOT NULL DEFAULT 'one_off' CHECK (billing_cycle IN ('one_off','monthly','quarterly','annual','per_unit','retainer')),
  list_price_minor_units bigint NOT NULL DEFAULT 0,
  internal_cost_minor_units bigint NOT NULL DEFAULT 0,
  min_quantity integer DEFAULT 1, max_quantity integer,
  segment text[] DEFAULT '{}',
  effective_from timestamptz DEFAULT now(), effective_to timestamptz,
  notes text, evidence_ref text,
  UNIQUE (catalog_id, tier_key)
);

CREATE TABLE IF NOT EXISTS ops.service_catalog_economic_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  occurred_at timestamptz DEFAULT now(),
  catalog_id text REFERENCES ops.service_catalog_items(catalog_id),
  tier_key text,
  event_type text NOT NULL CHECK (event_type IN ('quote','sale','renewal','refund','adjustment','cost_recorded','compute_cost')),
  amount_minor_units bigint NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'AUD',
  actor_id text, customer_ref text,
  payload jsonb DEFAULT '{}'::jsonb, evidence_ref text
);

CREATE OR REPLACE FUNCTION ops.fn_quote_catalog_item(
  p_catalog_id text, p_tier_key text DEFAULT NULL,
  p_quantity integer DEFAULT 1, p_customer_ref text DEFAULT NULL,
  p_actor_id text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
  v_pricing record; v_subtotal bigint; v_quote_id uuid; v_catalog_active boolean;
BEGIN
  SELECT lifecycle_stage IN ('OFFER_READY','MARKET_READY','ACTIVE')
    INTO v_catalog_active FROM ops.service_catalog_items WHERE catalog_id = p_catalog_id;
  IF v_catalog_active IS NULL THEN
    RETURN jsonb_build_object('status','BLOCKED','reason','unknown catalog_id');
  END IF;
  IF v_catalog_active = false THEN
    RETURN jsonb_build_object('status','BLOCKED','reason','catalog item not quotable in current lifecycle');
  END IF;

  IF p_tier_key IS NULL THEN
    SELECT * INTO v_pricing FROM ops.service_catalog_pricing
     WHERE catalog_id = p_catalog_id AND (effective_to IS NULL OR effective_to > now())
     ORDER BY list_price_minor_units ASC LIMIT 1;
  ELSE
    SELECT * INTO v_pricing FROM ops.service_catalog_pricing
     WHERE catalog_id = p_catalog_id AND tier_key = p_tier_key
       AND (effective_to IS NULL OR effective_to > now());
  END IF;

  IF v_pricing IS NULL THEN
    RETURN jsonb_build_object('status','BLOCKED','reason','no active pricing tier');
  END IF;
  IF p_quantity < COALESCE(v_pricing.min_quantity,1)
     OR (v_pricing.max_quantity IS NOT NULL AND p_quantity > v_pricing.max_quantity) THEN
    RETURN jsonb_build_object('status','BLOCKED','reason','quantity out of tier bounds');
  END IF;

  v_subtotal := v_pricing.list_price_minor_units * p_quantity;

  INSERT INTO ops.service_catalog_economic_events (
    catalog_id, tier_key, event_type, amount_minor_units, currency,
    actor_id, customer_ref, payload
  ) VALUES (
    p_catalog_id, v_pricing.tier_key, 'quote', v_subtotal, v_pricing.currency,
    p_actor_id, p_customer_ref,
    jsonb_build_object('quantity', p_quantity, 'billing_cycle', v_pricing.billing_cycle)
  ) RETURNING id INTO v_quote_id;

  PERFORM ops.fn_emit_telemetry('economics','quote_generated',
    jsonb_build_object('catalog_id', p_catalog_id, 'tier', v_pricing.tier_key,
                       'quantity', p_quantity, 'subtotal_minor_units', v_subtotal),
    'INFO','fn_quote_catalog_item', p_actor_id, NULL, p_catalog_id, NULL);

  RETURN jsonb_build_object(
    'status','REAL','quote_id', v_quote_id,
    'catalog_id', p_catalog_id, 'tier_key', v_pricing.tier_key,
    'tier_name', v_pricing.tier_name, 'currency', v_pricing.currency,
    'billing_cycle', v_pricing.billing_cycle,
    'unit_price_minor_units', v_pricing.list_price_minor_units,
    'quantity', p_quantity, 'subtotal_minor_units', v_subtotal,
    'internal_cost_minor_units', v_pricing.internal_cost_minor_units * p_quantity,
    'margin_minor_units', v_subtotal - (v_pricing.internal_cost_minor_units * p_quantity)
  );
END; $$;

-- Provisional pricing tiers (require validation before ACTIVE lifecycle)
INSERT INTO ops.service_catalog_pricing
  (catalog_id, tier_key, tier_name, currency, billing_cycle, list_price_minor_units, internal_cost_minor_units, min_quantity, max_quantity, notes, evidence_ref)
VALUES
  ('OR-RB-001','starter','Reading Buddy Starter','AUD','one_off', 49900, 24000, 1, 1, 'PROVISIONAL','github:01_seed.sql'),
  ('OR-RB-001','family','Reading Buddy Family','AUD','one_off',129900, 65000, 1, 4, 'PROVISIONAL','github:01_seed.sql'),
  ('OR-RB-001','provider','Reading Buddy Provider','AUD','monthly',249900,130000, 1, NULL, 'PROVISIONAL','github:01_seed.sql'),
  ('AHC-SP-001','discovery','AHC Discovery Pack','AUD','one_off', 750000, 280000, 1, 1, 'PROVISIONAL','github:01_seed.sql'),
  ('AHC-SP-001','workflow','AHC Workflow Uplift','AUD','one_off',1850000, 720000, 1, 1, 'PROVISIONAL','github:01_seed.sql'),
  ('AHC-SP-001','program','AHC Program','AUD','quarterly',4500000,1900000, 1, 1, 'PROVISIONAL','github:01_seed.sql'),
  ('WFA-WF-001','team','WFA Team','AUD','monthly', 199900, 95000, 1, 1, 'PROVISIONAL','github:01_seed.sql'),
  ('WFA-WF-001','division','WFA Division','AUD','monthly', 599900, 280000, 1, 1, 'PROVISIONAL','github:01_seed.sql'),
  ('WFA-WF-001','enterprise','WFA Enterprise','AUD','annual',9999900,4200000, 1, 1, 'PROVISIONAL','github:01_seed.sql')
ON CONFLICT (catalog_id, tier_key) DO UPDATE SET
  list_price_minor_units = EXCLUDED.list_price_minor_units,
  internal_cost_minor_units = EXCLUDED.internal_cost_minor_units;
