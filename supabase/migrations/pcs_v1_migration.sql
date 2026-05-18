-- pcs_v1_migration.sql
-- Core / Ops / Command Centre / Audit tables
-- Prerequisite: none

BEGIN;

-- ─────────────────────────────────────────
-- core.pen_tasks
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS core.pen_tasks (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issue_number  INTEGER NOT NULL,
  repo          TEXT NOT NULL,
  title         TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'OPEN'
                  CHECK (status IN ('OPEN','ACTIVE','PARTIAL','BLOCKED','REAL','CLOSED')),
  priority      TEXT NOT NULL DEFAULT 'MEDIUM'
                  CHECK (priority IN ('CRITICAL','HIGH','MEDIUM','LOW')),
  owner_lane    TEXT,
  body          TEXT,
  labels        TEXT[],
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pen_tasks_status   ON core.pen_tasks(status);
CREATE INDEX IF NOT EXISTS idx_pen_tasks_priority ON core.pen_tasks(priority);
CREATE INDEX IF NOT EXISTS idx_pen_tasks_repo     ON core.pen_tasks(repo);

-- ─────────────────────────────────────────
-- core.pen_receipts
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS core.pen_receipts (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id       UUID REFERENCES core.pen_tasks(id),
  receipt_type  TEXT NOT NULL,
  evidence_uri  TEXT,
  commit_sha    TEXT,
  payload       JSONB,
  status        TEXT NOT NULL DEFAULT 'PARTIAL'
                  CHECK (status IN ('REAL','PARTIAL','BLOCKED','FAIL')),
  score         NUMERIC(4,2),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────
-- ops.movement_ledger
-- ─────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE IF NOT EXISTS ops.movement_ledger (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id       UUID REFERENCES core.pen_tasks(id),
  from_status   TEXT,
  to_status     TEXT,
  actor         TEXT,
  note          TEXT,
  moved_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────
-- cc.command_centre_widgets
-- ─────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS cc;

CREATE TABLE IF NOT EXISTS cc.command_centre_widgets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  widget_name   TEXT UNIQUE NOT NULL,
  route         TEXT,
  data_source   TEXT,
  status        TEXT DEFAULT 'PARTIAL',
  last_updated  TIMESTAMPTZ DEFAULT now()
);

-- ─────────────────────────────────────────
-- audit.audit_logs  (hash-chained)
-- ─────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS audit;

CREATE TABLE IF NOT EXISTS audit.audit_logs (
  id            BIGSERIAL PRIMARY KEY,
  event_type    TEXT NOT NULL,
  actor         TEXT,
  target_table  TEXT,
  target_id     UUID,
  payload       JSONB,
  prev_hash     TEXT,
  this_hash     TEXT GENERATED ALWAYS AS (
                  md5(prev_hash || event_type || actor || target_table ||
                      COALESCE(target_id::TEXT,'') ||
                      COALESCE(payload::TEXT,''))
                ) STORED,
  logged_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;
