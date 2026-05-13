CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS runtime;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS governance;
CREATE SCHEMA IF NOT EXISTS graph;
CREATE SCHEMA IF NOT EXISTS economics;
CREATE SCHEMA IF NOT EXISTS memory;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS core.objects (
  object_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_type TEXT NOT NULL,
  canonical_slug TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  lifecycle_state TEXT DEFAULT 'RAW',
  evidence_state TEXT DEFAULT 'PARTIAL',
  source_authority TEXT DEFAULT 'supabase',
  owner_actor_id TEXT,
  payload JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  version INT DEFAULT 1
);

CREATE TABLE IF NOT EXISTS runtime.events (
  event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID REFERENCES core.objects(object_id),
  event_type TEXT NOT NULL,
  actor_id TEXT,
  source_system TEXT,
  payload JSONB DEFAULT '{}'::jsonb,
  evidence_refs JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS runtime.jobs (
  job_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID REFERENCES core.objects(object_id),
  intent_type TEXT,
  runtime_state TEXT DEFAULT 'queued',
  priority INT DEFAULT 5,
  queue_name TEXT DEFAULT 'default',
  worker_id TEXT,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS runtime.job_attempts (
  attempt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID REFERENCES runtime.jobs(job_id),
  status TEXT,
  logs TEXT,
  telemetry JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS runtime.telemetry_events (
  telemetry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID REFERENCES core.objects(object_id),
  metric_name TEXT,
  metric_value NUMERIC,
  dimensions JSONB DEFAULT '{}'::jsonb,
  recorded_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit.evidence_register (
  evidence_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID REFERENCES core.objects(object_id),
  evidence_type TEXT,
  evidence_uri TEXT,
  evidence_hash TEXT,
  source_system TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit.reality_ledger (
  ledger_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID REFERENCES core.objects(object_id),
  status TEXT CHECK (status IN ('REAL','PARTIAL','BLOCKED')),
  execution_summary TEXT,
  evidence_count INT DEFAULT 0,
  economic_signal BOOLEAN DEFAULT false,
  telemetry_signal BOOLEAN DEFAULT false,
  recovery_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS governance.policies (
  policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_name TEXT,
  severity TEXT,
  rules JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS graph.nodes (
  node_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID REFERENCES core.objects(object_id),
  node_type TEXT,
  embedding vector(1536)
);

CREATE TABLE IF NOT EXISTS graph.edges (
  edge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_object UUID REFERENCES core.objects(object_id),
  to_object UUID REFERENCES core.objects(object_id),
  relationship_type TEXT,
  weight NUMERIC DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS economics.object_economics (
  economics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  object_id UUID REFERENCES core.objects(object_id),
  monthly_revenue NUMERIC DEFAULT 0,
  monthly_cost NUMERIC DEFAULT 0,
  conversion_rate NUMERIC DEFAULT 0,
  ltv NUMERIC DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now()
);
