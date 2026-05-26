-- T4H Data Pod Runtime v1.0 — canonical schema
-- Deployed: 2026-05-26 to Supabase S1 (lzfgigiyqpuuxslsygjt)
-- Migration name: pods_runtime_v1_0_schema
-- Per GLOBAL_RULE_KERNEL_V6: RLS all tables, archive never delete, telemetry-bound,
-- evidence-receipted, runtime-traceable, cluster bound to core.cluster_registry.

CREATE SCHEMA IF NOT EXISTS pods;

-- Cluster registration (canonical home for reality_ledger.cluster_id)
INSERT INTO core.cluster_registry (
  cluster_id, cluster_name, priority, description,
  home_entity, home_schema, ledger_sink, closure_rule,
  evidence_type, archive_after_days, is_active
) VALUES (
  'data-pods',
  'T4H Data Intelligence Pod System',
  'P1',
  'POD-00 Chief of Staff orchestrating 12 LLM/GDrive pods for compounding cognition',
  'pods.pod_registry',
  'pods',
  'public.reality_ledger',
  'archived_when_pod.status=archived_and_all_runs_terminal',
  'execution_trace',
  365,
  true
)
ON CONFLICT (cluster_id) DO UPDATE SET
  updated_at = now(),
  is_active = true,
  description = EXCLUDED.description;

-- ============================================================
-- 1. pod_registry — canonical list of pods
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.pod_registry (
  pod_id text PRIMARY KEY,
  pod_name text NOT NULL,
  pod_role text NOT NULL,
  pod_class text NOT NULL CHECK (pod_class IN ('LLM','GDRIVE','CONTROL')),
  priority integer NOT NULL DEFAULT 5,
  authority text NOT NULL DEFAULT 'autonomous',
  hitl boolean NOT NULL DEFAULT false,
  status text NOT NULL DEFAULT 'registered'
    CHECK (status IN ('registered','active','paused','quarantined','archived')),
  description text,
  upstream text[] DEFAULT '{}',
  downstream text[] DEFAULT '{}',
  config jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);

-- ============================================================
-- 2. pod_runs — execution log
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.pod_runs (
  run_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pod_id text NOT NULL REFERENCES pods.pod_registry(pod_id),
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  status text NOT NULL DEFAULT 'running'
    CHECK (status IN ('running','succeeded','failed','partial','quarantined')),
  trigger text,
  input_delta jsonb,
  output_summary jsonb,
  receipt_hash text,
  evidence jsonb,
  error text
);
CREATE INDEX IF NOT EXISTS pod_runs_pod_started_idx
  ON pods.pod_runs(pod_id, started_at DESC);

-- ============================================================
-- 3. memory_objects — canonical store
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.memory_objects (
  object_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  object_type text NOT NULL,
  source text NOT NULL,
  source_uri text,
  source_hash text,
  embedding_hash text,
  entity_hash text,
  entities jsonb NOT NULL DEFAULT '{}'::jsonb,
  signals jsonb NOT NULL DEFAULT '{}'::jsonb,
  relationships jsonb NOT NULL DEFAULT '[]'::jsonb,
  next_actions jsonb NOT NULL DEFAULT '[]'::jsonb,
  status text NOT NULL DEFAULT 'PARTIAL'
    CHECK (status IN ('REAL','PARTIAL','BLOCKED','ARCHIVED')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS memory_objects_source_hash_uq
  ON pods.memory_objects(source_hash) WHERE source_hash IS NOT NULL;
CREATE INDEX IF NOT EXISTS memory_objects_object_type_idx
  ON pods.memory_objects(object_type);

-- ============================================================
-- 4. entity_registry — canonical entities (dedup spine)
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.entity_registry (
  entity_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type text NOT NULL
    CHECK (entity_type IN ('product','project','person','idea','agent','offer',
                           'customer','signal','revenue','file')),
  canonical_name text NOT NULL,
  aliases text[] DEFAULT '{}',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  first_seen_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  reuse_count integer NOT NULL DEFAULT 1,
  archived_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS entity_registry_type_name_uq
  ON pods.entity_registry(entity_type, canonical_name);

-- ============================================================
-- 5. recovery_queue — LLP-02 output
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.recovery_queue (
  item_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_object_id uuid REFERENCES pods.memory_objects(object_id),
  title text NOT NULL,
  description text,
  signal text,
  completion_score numeric(3,2),
  revenue_score numeric(3,2),
  difficulty_score numeric(3,2),
  strategic_score numeric(3,2),
  urgency_score numeric(3,2),
  composite_score numeric(3,2),
  status text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','in_progress','recovered','dropped','archived')),
  recovered_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS recovery_queue_status_score_idx
  ON pods.recovery_queue(status, composite_score DESC);

-- ============================================================
-- 6. research_audit — LLP-03 output (RDTI/tax/grant evidence)
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.research_audit (
  audit_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_object_id uuid REFERENCES pods.memory_objects(object_id),
  project text,
  activity text,
  claim_text text,
  evidence jsonb,
  confidence numeric(3,2),
  tax_category text,
  fy text,
  audit_grade text CHECK (audit_grade IN ('A','B','C','D','F')),
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','reviewed','approved','rejected','archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 7. product_genome — LLP-04 output
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.product_genome (
  genome_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id text NOT NULL,
  markets text[],
  offers jsonb,
  customers jsonb,
  pricing jsonb,
  dependencies jsonb,
  gtm jsonb,
  signals jsonb,
  evidence jsonb,
  confidence numeric(3,2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS product_genome_product_uq
  ON pods.product_genome(product_id);

-- ============================================================
-- 8 & 9. knowledge_nodes / knowledge_edges — GDP-04 graph
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.knowledge_nodes (
  node_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  node_type text NOT NULL,
  label text NOT NULL,
  attributes jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS knowledge_nodes_type_label_uq
  ON pods.knowledge_nodes(node_type, label);

CREATE TABLE IF NOT EXISTS pods.knowledge_edges (
  edge_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_node_id uuid NOT NULL REFERENCES pods.knowledge_nodes(node_id),
  target_node_id uuid NOT NULL REFERENCES pods.knowledge_nodes(node_id),
  edge_type text NOT NULL,
  weight numeric(5,3) DEFAULT 1.0,
  attributes jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS knowledge_edges_source_idx
  ON pods.knowledge_edges(source_node_id);
CREATE INDEX IF NOT EXISTS knowledge_edges_target_idx
  ON pods.knowledge_edges(target_node_id);

-- ============================================================
-- 10. portfolio_health — GDP-02 output
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.portfolio_health (
  health_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id text NOT NULL,
  one_pager boolean DEFAULT false,
  pricing boolean DEFAULT false,
  deck boolean DEFAULT false,
  product_page boolean DEFAULT false,
  gtm boolean DEFAULT false,
  video boolean DEFAULT false,
  legal boolean DEFAULT false,
  evidence boolean DEFAULT false,
  classification text CHECK (classification IN ('REAL','PARTIAL','AT_RISK','STOP_SHIP')),
  gaps text[],
  last_scored_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS portfolio_health_business_uq
  ON pods.portfolio_health(business_id);

-- ============================================================
-- 11. narrative_memory — GDP-05 output
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.narrative_memory (
  narrative_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  arc text,
  source text,
  source_uri text,
  excerpt text,
  themes text[],
  uses text[],
  confidence numeric(3,2),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 12. opportunity_queue — LLP-06 output
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.opportunity_queue (
  opportunity_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source text,
  title text NOT NULL,
  description text,
  estimated_value_aud numeric(12,2),
  effort_score numeric(3,2),
  confidence numeric(3,2),
  recommended_action text,
  evidence jsonb,
  status text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','pursuing','won','lost','dropped','archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS opportunity_queue_status_value_idx
  ON pods.opportunity_queue(status, estimated_value_aud DESC NULLS LAST);

-- ============================================================
-- 13. executive_briefs — POD-00 daily output
-- ============================================================
CREATE TABLE IF NOT EXISTS pods.executive_briefs (
  brief_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brief_date date NOT NULL DEFAULT current_date,
  completed jsonb,
  new_evidence jsonb,
  new_products jsonb,
  portfolio_changes jsonb,
  high_value_recoveries jsonb,
  revenue_opportunities jsonb,
  emerging_patterns jsonb,
  risks jsonb,
  recommended_actions jsonb,
  receipt_hash text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS executive_briefs_date_idx
  ON pods.executive_briefs(brief_date DESC);

-- ============================================================
-- RLS — every table in the pods schema is RLS-enabled.
-- ============================================================
ALTER TABLE pods.pod_registry      ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.pod_runs          ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.memory_objects    ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.entity_registry   ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.recovery_queue    ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.research_audit    ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.product_genome    ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.knowledge_nodes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.knowledge_edges   ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.portfolio_health  ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.narrative_memory  ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.opportunity_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE pods.executive_briefs  ENABLE ROW LEVEL SECURITY;

-- authenticated read-only policy on every pods table
DO $$
DECLARE t text;
BEGIN
  FOR t IN SELECT table_name FROM information_schema.tables WHERE table_schema='pods'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I_authenticated_read ON pods.%I', t, t);
    EXECUTE format('CREATE POLICY %I_authenticated_read ON pods.%I FOR SELECT TO authenticated USING (true)', t, t);
  END LOOP;
END $$;
