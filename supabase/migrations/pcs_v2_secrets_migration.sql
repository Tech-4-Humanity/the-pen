-- pcs_v2_secrets_migration.sql
-- cap_secrets → AWS Secrets Manager pointer table
-- Prerequisite: pcs_v1_migration.sql

BEGIN;

CREATE SCHEMA IF NOT EXISTS cap;

-- ─────────────────────────────────────────
-- cap.secrets  (pointers only — no plaintext values stored)
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cap.secrets (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  secret_name     TEXT UNIQUE NOT NULL,
  aws_secret_arn  TEXT,
  aws_region      TEXT NOT NULL DEFAULT 'ap-southeast-2',
  env             TEXT NOT NULL DEFAULT 'prod'
                    CHECK (env IN ('prod','staging','dev')),
  rotated_at      TIMESTAMPTZ,
  rotation_days   INTEGER DEFAULT 90,
  status          TEXT NOT NULL DEFAULT 'ACTIVE'
                    CHECK (status IN ('ACTIVE','ROTATING','REVOKED','UNKNOWN')),
  owner           TEXT,
  note            TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_cap_secrets_status ON cap.secrets(status);
CREATE INDEX IF NOT EXISTS idx_cap_secrets_env    ON cap.secrets(env);

-- ─────────────────────────────────────────
-- cap.rotation_log
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cap.rotation_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  secret_id   UUID NOT NULL REFERENCES cap.secrets(id),
  actor       TEXT,
  old_arn     TEXT,
  new_arn     TEXT,
  result      TEXT CHECK (result IN ('SUCCESS','FAIL','PARTIAL')),
  note        TEXT,
  rotated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- seed known secrets (ARNs to be filled by Bridge after key rotation)
INSERT INTO cap.secrets (secret_name, env, owner, note)
VALUES
  ('SUPABASE_SERVICE_KEY',    'prod', 'bridge',  'Supabase service role key — rotate via Bridge'),
  ('GITHUB_PAT',              'prod', 'bridge',  'GitHub PAT for The Pen — rotate after #106'),
  ('OPENAI_API_KEY',          'prod', 'bridge',  'OpenAI/ChatGPT API key'),
  ('ANTHROPIC_API_KEY',       'prod', 'bridge',  'Claude/Anthropic API key'),
  ('AWS_EVENTBRIDGE_KEY',     'prod', 'bridge',  'EventBridge publisher credentials'),
  ('VERCEL_DEPLOY_TOKEN',     'prod', 'bridge',  'Vercel deploy hook token')
ON CONFLICT (secret_name) DO NOTHING;

COMMIT;
