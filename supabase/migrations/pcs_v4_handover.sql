-- pcs_v4_handover.sql
-- Both-SHA invariant handover / reality ledger binding
-- Prerequisite: pcs_v1_migration.sql, pcs_v2_secrets_migration.sql, pcs_v3_url_census.sql

BEGIN;

CREATE SCHEMA IF NOT EXISTS ledger;

-- ─────────────────────────────────────────
-- ledger.reality_ledger
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ledger.reality_ledger (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id         UUID REFERENCES core.pen_tasks(id),
  cycle_id        TEXT,
  status          TEXT NOT NULL DEFAULT 'PARTIAL'
                    CHECK (status IN ('REAL','PARTIAL','BLOCKED','FAIL','PRETEND')),
  result          TEXT,
  evidence        JSONB,   -- [{type, value, uri, commit_sha}]
  gaps            JSONB,   -- [string]
  next_actions    JSONB,   -- [string]
  pressure_flags  TEXT[],
  score           NUMERIC(4,2),
  source_sha      TEXT,    -- git SHA of source that triggered this entry
  bridge_sha      TEXT,    -- git SHA of bridge receipt commit
  recorded_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reality_ledger_status  ON ledger.reality_ledger(status);
CREATE INDEX IF NOT EXISTS idx_reality_ledger_task    ON ledger.reality_ledger(task_id);

-- ─────────────────────────────────────────
-- ledger.handover_envelope
-- Carries both-SHA invariant: source_sha + bridge_sha must both be non-null for REAL
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ledger.handover_envelope (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ledger_id       UUID NOT NULL REFERENCES ledger.reality_ledger(id),
  from_actor      TEXT NOT NULL,
  to_actor        TEXT NOT NULL,
  payload         JSONB,
  source_sha      TEXT NOT NULL,
  bridge_sha      TEXT,
  status          TEXT NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING','ACCEPTED','REJECTED','EXPIRED')),
  handover_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  accepted_at     TIMESTAMPTZ,
  CONSTRAINT both_sha_for_real CHECK (
    status != 'ACCEPTED' OR (source_sha IS NOT NULL AND bridge_sha IS NOT NULL)
  )
);

-- ─────────────────────────────────────────
-- bootstrap reality ledger entry for pcs_v1-v4 deployment
-- ─────────────────────────────────────────
INSERT INTO ledger.reality_ledger
  (cycle_id, status, result, evidence, gaps, next_actions, score)
VALUES (
  'PCS-V1-V4-DEPLOY-001',
  'PARTIAL',
  'pcs_v1-v4 SQL files committed to repo — awaiting Supabase apply',
  '[{"type": "github_commit", "value": "files committed to supabase/migrations/"}]',
  '["Supabase apply not yet run", "Bridge receipt pending", "pcs_v2 ARNs not populated"]',
  '["Apply migrations in order v1→v4 against lzfgigiyqpuuxslsygjt", "Run Bridge receipt worker", "Close #120 and #108 after apply"]',
  0.60
);

COMMIT;
