-- True Trust executable registry schema
-- Idempotent schema for business, service catalogue, products, journeys, tasks, evidence and receipts.
CREATE TABLE IF NOT EXISTS tt_business_registry (
  business_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  stage TEXT NOT NULL,
  status TEXT NOT NULL,
  owner TEXT NOT NULL,
  category TEXT,
  positioning TEXT,
  launch_priority TEXT DEFAULT 'MEDIUM',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tt_service_catalogue (
  service_id TEXT PRIMARY KEY,
  business_id TEXT NOT NULL REFERENCES tt_business_registry(business_id),
  name TEXT NOT NULL,
  buyer TEXT,
  purpose TEXT NOT NULL,
  inputs JSONB DEFAULT '[]'::jsonb,
  outputs JSONB DEFAULT '[]'::jsonb,
  dependencies JSONB DEFAULT '[]'::jsonb,
  evidence_required JSONB DEFAULT '[]'::jsonb,
  risk_level TEXT DEFAULT 'medium',
  automation_status TEXT DEFAULT 'catalog_draft',
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tt_product_catalogue (
  product_id TEXT PRIMARY KEY,
  business_id TEXT NOT NULL REFERENCES tt_business_registry(business_id),
  name TEXT NOT NULL,
  buyer TEXT NOT NULL,
  offer_type TEXT NOT NULL,
  package_summary TEXT NOT NULL,
  included_services JSONB DEFAULT '[]'::jsonb,
  required_assets JSONB DEFAULT '[]'::jsonb,
  pricing_model TEXT,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tt_journey_assets (
  journey_id TEXT PRIMARY KEY,
  business_id TEXT NOT NULL REFERENCES tt_business_registry(business_id),
  name TEXT NOT NULL,
  persona TEXT,
  trigger_stack JSONB DEFAULT '[]'::jsonb,
  hidden_value JSONB DEFAULT '[]'::jsonb,
  services_used JSONB DEFAULT '[]'::jsonb,
  outcome_proof JSONB DEFAULT '[]'::jsonb,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tt_execution_tasks (
  task_id TEXT PRIMARY KEY,
  business_id TEXT NOT NULL REFERENCES tt_business_registry(business_id),
  workstream TEXT NOT NULL,
  title TEXT NOT NULL,
  output TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'todo',
  authority TEXT DEFAULT 'internal',
  blocker TEXT,
  evidence JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tt_reality_receipts (
  receipt_id TEXT PRIMARY KEY,
  business_id TEXT NOT NULL REFERENCES tt_business_registry(business_id),
  status TEXT NOT NULL,
  result TEXT NOT NULL,
  evidence JSONB NOT NULL DEFAULT '[]'::jsonb,
  gaps JSONB NOT NULL DEFAULT '[]'::jsonb,
  next_action TEXT NOT NULL,
  score NUMERIC(4,2),
  created_at TIMESTAMPTZ DEFAULT now()
);
