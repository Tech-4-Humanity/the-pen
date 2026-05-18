-- pcs_v3_url_census.sql
-- URL census landing zone
-- Prerequisite: pcs_v1_migration.sql

BEGIN;

CREATE SCHEMA IF NOT EXISTS census;

-- ─────────────────────────────────────────
-- census.url_registry
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS census.url_registry (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  url             TEXT UNIQUE NOT NULL,
  domain          TEXT,
  path            TEXT,
  repo            TEXT,
  surface         TEXT,
  status          TEXT NOT NULL DEFAULT 'UNKNOWN'
                    CHECK (status IN ('LIVE','DEAD','REDIRECT','PARTIAL','UNKNOWN')),
  last_checked    TIMESTAMPTZ,
  http_status     INTEGER,
  redirects_to    TEXT,
  owner           TEXT,
  note            TEXT,
  discovered_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_url_registry_domain  ON census.url_registry(domain);
CREATE INDEX IF NOT EXISTS idx_url_registry_status  ON census.url_registry(status);
CREATE INDEX IF NOT EXISTS idx_url_registry_repo    ON census.url_registry(repo);

-- ─────────────────────────────────────────
-- census.url_check_log
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS census.url_check_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  url_id      UUID NOT NULL REFERENCES census.url_registry(id),
  checked_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  http_status INTEGER,
  latency_ms  INTEGER,
  result      TEXT,
  checker     TEXT
);

-- seed known surfaces
INSERT INTO census.url_registry (url, domain, surface, owner, note)
VALUES
  ('https://mcp-command-centre.vercel.app',              'vercel.app',   'Command Centre',   'TML-4PM', 'Primary command centre UI'),
  ('https://github.com/TML-4PM/the-pen',                 'github.com',   'The Pen',          'TML-4PM', 'Canonical job queue repo'),
  ('https://github.com/TML-4PM/mcp-command-centre',      'github.com',   'MCP Command Ctr',  'TML-4PM', 'MCP command centre repo'),
  ('https://github.com/TML-4PM/t4h-research-hub',        'github.com',   'Research Hub',     'TML-4PM', 'ATO/RDTI research hub'),
  ('https://github.com/TML-4PM/mcp-protocol-standard',   'github.com',   'MCP Standard',     'TML-4PM', 'Agent house rules')
ON CONFLICT (url) DO NOTHING;

COMMIT;
