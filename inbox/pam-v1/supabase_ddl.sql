-- ============================================================
-- PORTFOLIO AUDIENCE MATRIX (PAM) -- SUPABASE DDL v1.0
-- 2026-05-13 | Tech 4 Humanity Pty Ltd
-- ============================================================

CREATE SCHEMA IF NOT EXISTS pam;

CREATE TABLE IF NOT EXISTS pam.acquisition_archetypes (
  id SERIAL PRIMARY KEY,
  code INTEGER UNIQUE NOT NULL,
  archetype TEXT NOT NULL,
  description TEXT,
  primary_signal TEXT,
  typical_sources TEXT,
  contactability TEXT,
  compliance_risk TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pam.cohort_taxonomy (
  id SERIAL PRIMARY KEY,
  cohort_slug TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  acquisition_priority TEXT,
  outreach_channel TEXT,
  lifecycle_entry TEXT,
  lifecycle_exit TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pam.brands (
  id SERIAL PRIMARY KEY,
  business_slug TEXT UNIQUE NOT NULL,
  business_name TEXT NOT NULL,
  portfolio_group TEXT,
  status TEXT DEFAULT 'idea',
  audience_mode TEXT,
  primary_acquisition_type INTEGER,
  secondary_acquisition_types TEXT,
  geography_scope TEXT DEFAULT 'national',
  cohort_1 TEXT,
  cohort_2 TEXT,
  cohort_3 TEXT,
  practitioner_required BOOLEAN DEFAULT FALSE,
  provider_required BOOLEAN DEFAULT FALSE,
  customer_required BOOLEAN DEFAULT FALSE,
  signal_source_types TEXT,
  outreach_channels TEXT,
  contactability_level TEXT,
  compliance_risk TEXT DEFAULT 'low',
  monetisation_model TEXT,
  operational_readiness TEXT DEFAULT 'idea',
  hero_message TEXT,
  primary_cta TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pam.sources (
  id SERIAL PRIMARY KEY,
  source_slug TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  source_type TEXT,
  target_cohorts TEXT,
  geography TEXT,
  data_quality TEXT,
  scrape_difficulty TEXT,
  legal_risk TEXT,
  primary_fields TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pam.audience_entities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL,
  business_name TEXT,
  contact_name TEXT,
  category TEXT,
  city TEXT,
  state TEXT,
  website TEXT,
  email TEXT,
  phone TEXT,
  abn TEXT,
  source_slug TEXT,
  brand_slug TEXT,
  cohort_slug TEXT,
  ai_readiness_score INTEGER,
  outreach_status TEXT DEFAULT 'raw',
  enrichment_state TEXT DEFAULT 'raw',
  evidence_state TEXT DEFAULT 'PARTIAL',
  scrape_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ae_brand ON pam.audience_entities(brand_slug);
CREATE INDEX IF NOT EXISTS idx_ae_cohort ON pam.audience_entities(cohort_slug);
CREATE INDEX IF NOT EXISTS idx_ae_source ON pam.audience_entities(source_slug);
CREATE INDEX IF NOT EXISTS idx_ae_status ON pam.audience_entities(outreach_status);

CREATE TABLE IF NOT EXISTS pam.signal_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id UUID,
  signal_type TEXT NOT NULL,
  signal_source TEXT,
  signal_value TEXT,
  strength NUMERIC(3,2),
  geo_cluster TEXT,
  captured_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pam.activation_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_slug TEXT,
  cohort_slug TEXT,
  channel TEXT,
  status TEXT DEFAULT 'draft',
  launched_at TIMESTAMPTZ,
  closed_at TIMESTAMPTZ,
  target_count INTEGER,
  sent_count INTEGER,
  open_count INTEGER,
  reply_count INTEGER,
  demo_count INTEGER,
  convert_count INTEGER,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pam.engagement_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activation_run_id UUID,
  entity_id UUID,
  event_type TEXT NOT NULL,
  channel TEXT,
  occurred_at TIMESTAMPTZ DEFAULT NOW(),
  evidence_payload JSONB
);

CREATE TABLE IF NOT EXISTS pam.suppression_registry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT,
  phone TEXT,
  suppression_reason TEXT,
  suppressed_at TIMESTAMPTZ DEFAULT NOW(),
  source TEXT
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_suppress_email ON pam.suppression_registry(email) WHERE email IS NOT NULL;

CREATE TABLE IF NOT EXISTS pam.graph_nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  node_type TEXT NOT NULL,
  entity_ref UUID,
  slug TEXT,
  label TEXT,
  properties JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pam.graph_edges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  edge_type TEXT NOT NULL,
  from_node UUID,
  to_node UUID,
  weight NUMERIC(5,4) DEFAULT 1.0,
  evidence_ref UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ge_from ON pam.graph_edges(from_node);
CREATE INDEX IF NOT EXISTS idx_ge_to ON pam.graph_edges(to_node);
CREATE INDEX IF NOT EXISTS idx_ge_type ON pam.graph_edges(edge_type);

CREATE TABLE IF NOT EXISTS pam.geo_clusters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  region TEXT,
  state TEXT,
  interest_type TEXT,
  signal_density INTEGER DEFAULT 0,
  last_updated TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pam.intelligence_layers (
  id SERIAL PRIMARY KEY,
  layer_slug TEXT UNIQUE NOT NULL,
  layer_name TEXT,
  description TEXT,
  data_inputs TEXT,
  outputs TEXT,
  priority TEXT,
  status TEXT DEFAULT 'idea',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON SCHEMA pam IS 'Portfolio Audience Matrix - canonical audience acquisition and intelligence layer for Tech 4 Humanity portfolio';
