-- ============================================================
-- ASSET REGISTER + SERVICE CATALOGUE V1
-- Applied: 2026-05-15 21:28 UTC to project lzfgigiyqpuuxslsygjt
-- Reality Ledger: public.reality_ledger id=da2d7850-79b8-4fa7-9cc1-366f690b630c
-- Cluster: CL_CATALOG_CANON
-- Status: PARTIAL (Stripe sync + loop scheduling pending)
-- ============================================================

-- 1. Asset type taxonomy
CREATE TABLE IF NOT EXISTS public.asset_type_catalogue (
  type_code   text PRIMARY KEY,
  family      text NOT NULL,
  subtype     text,
  description text,
  is_active   boolean NOT NULL DEFAULT true,
  sort_order  integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_asset_type_catalogue_family ON public.asset_type_catalogue (family);

-- 2. Master asset register
CREATE TABLE IF NOT EXISTS public.master_asset_register (
  asset_id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_code          text UNIQUE NOT NULL,
  type_code           text NOT NULL REFERENCES public.asset_type_catalogue(type_code),
  title               text NOT NULL,
  description         text,
  owner_business_key  text REFERENCES public.t4h_business_registry(business_key),
  research_asset_code text,
  status              text NOT NULL DEFAULT 'PARTIAL' CHECK (status IN ('REAL','PARTIAL','BLOCKED','RETIRED')),
  origin_uri          text,
  evidence_uri        text,
  source_system       text,
  external_id         text,
  tags                text[] NOT NULL DEFAULT '{}'::text[],
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_verified       timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_master_asset_register_type   ON public.master_asset_register (type_code);
CREATE INDEX IF NOT EXISTS idx_master_asset_register_status ON public.master_asset_register (status);
CREATE INDEX IF NOT EXISTS idx_master_asset_register_owner  ON public.master_asset_register (owner_business_key);

-- 3. Service catalogue
CREATE TABLE IF NOT EXISTS public.service_catalogue (
  service_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_code      text UNIQUE NOT NULL,
  service_name      text NOT NULL,
  business_key      text REFERENCES public.t4h_business_registry(business_key),
  product_family    text,
  delivery_mode     text,
  primary_asset_id  uuid REFERENCES public.master_asset_register(asset_id),
  status            text NOT NULL DEFAULT 'PARTIAL' CHECK (status IN ('REAL','PARTIAL','BLOCKED','RETIRED')),
  pricing_ready     boolean NOT NULL DEFAULT false,
  support_ready     boolean NOT NULL DEFAULT false,
  telemetry_ready   boolean NOT NULL DEFAULT false,
  delivery_ready    boolean NOT NULL DEFAULT false,
  evidence_ready    boolean NOT NULL DEFAULT false,
  metadata          jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_verified     timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_service_catalogue_business ON public.service_catalogue (business_key);
CREATE INDEX IF NOT EXISTS idx_service_catalogue_status   ON public.service_catalogue (status);

-- 4. Product / pricing registry
CREATE TABLE IF NOT EXISTS public.product_pricing_registry (
  product_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_code      text UNIQUE NOT NULL,
  product_name      text NOT NULL,
  service_code      text REFERENCES public.service_catalogue(service_code),
  business_key      text REFERENCES public.t4h_business_registry(business_key),
  sku               text,
  stripe_product_id text,
  stripe_price_id   text,
  price_aud         numeric(10,2),
  currency          text NOT NULL DEFAULT 'AUD',
  billing_period    text,
  status            text NOT NULL DEFAULT 'PARTIAL' CHECK (status IN ('REAL','PARTIAL','BLOCKED','RETIRED')),
  metadata          jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_verified     timestamptz,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_product_pricing_registry_service ON public.product_pricing_registry (service_code);

-- 5. Reconciliation loops
CREATE TABLE IF NOT EXISTS public.registry_reconciliation_loop (
  loop_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  loop_code       text UNIQUE NOT NULL,
  loop_name       text NOT NULL,
  loop_type       text NOT NULL,
  scope           text,
  schedule        text,
  source_systems  text[] NOT NULL DEFAULT '{}'::text[],
  target_table    text,
  detection_rule  text,
  response_action text,
  is_active       boolean NOT NULL DEFAULT true,
  last_run        timestamptz,
  last_status     text,
  last_evidence   jsonb,
  metadata        jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_registry_reconciliation_loop_type ON public.registry_reconciliation_loop (loop_type);

-- Control views
CREATE OR REPLACE VIEW public.v_service_catalogue_control AS
SELECT sc.service_code, sc.service_name, sc.business_key, br.business_name,
       sc.product_family, sc.delivery_mode, sc.status,
       sc.pricing_ready, sc.support_ready, sc.telemetry_ready, sc.delivery_ready, sc.evidence_ready,
       (sc.pricing_ready::int + sc.support_ready::int + sc.telemetry_ready::int + sc.delivery_ready::int + sc.evidence_ready::int) AS readiness_score,
       ARRAY_REMOVE(ARRAY[
         CASE WHEN NOT sc.pricing_ready   THEN 'pricing'   END,
         CASE WHEN NOT sc.support_ready   THEN 'support'   END,
         CASE WHEN NOT sc.telemetry_ready THEN 'telemetry' END,
         CASE WHEN NOT sc.delivery_ready  THEN 'delivery'  END,
         CASE WHEN NOT sc.evidence_ready  THEN 'evidence'  END
       ], NULL) AS gaps,
       sc.primary_asset_id, mar.asset_code AS primary_asset_code, mar.type_code AS primary_asset_type,
       sc.last_verified, sc.updated_at
FROM public.service_catalogue sc
LEFT JOIN public.master_asset_register mar ON mar.asset_id = sc.primary_asset_id
LEFT JOIN public.t4h_business_registry br  ON br.business_key = sc.business_key;

CREATE OR REPLACE VIEW public.v_master_asset_register_control AS
SELECT mar.asset_id, mar.asset_code, mar.title, mar.status, mar.type_code,
       tc.family, tc.subtype, mar.owner_business_key, br.business_name,
       mar.evidence_uri, mar.tags, mar.last_verified, mar.updated_at
FROM public.master_asset_register mar
JOIN public.asset_type_catalogue tc ON tc.type_code = mar.type_code
LEFT JOIN public.t4h_business_registry br ON br.business_key = mar.owner_business_key;

CREATE OR REPLACE VIEW public.v_master_asset_register_by_family AS
SELECT tc.family, count(*) AS asset_count,
       count(*) FILTER (WHERE mar.status = 'REAL')    AS real_count,
       count(*) FILTER (WHERE mar.status = 'PARTIAL') AS partial_count,
       count(*) FILTER (WHERE mar.status = 'BLOCKED') AS blocked_count
FROM public.master_asset_register mar
JOIN public.asset_type_catalogue tc ON tc.type_code = mar.type_code
GROUP BY tc.family
ORDER BY tc.family;
