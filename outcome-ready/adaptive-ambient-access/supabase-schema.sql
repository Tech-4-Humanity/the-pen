-- OR-AAA-001: Adaptive Ambient Access Schema
-- Deploy to: lzfgigiyqpuuxslsygjt
-- Schema: public (or ndis if exists)

CREATE TABLE IF NOT EXISTS aaa_participants (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ndis_number   TEXT UNIQUE NOT NULL,
  name          TEXT NOT NULL,
  plan_tier     TEXT NOT NULL DEFAULT 'T1',
  active        BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aaa_ambient_windows (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_id  UUID NOT NULL REFERENCES aaa_participants(id) ON DELETE CASCADE,
  day_of_week     INT[] NOT NULL, -- 0=Sun..6=Sat
  start_time      TIME NOT NULL,
  end_time        TIME NOT NULL,
  support_type    TEXT NOT NULL,
  auto_connect    BOOLEAN NOT NULL DEFAULT false,
  active          BOOLEAN NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aaa_trigger_rules (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_id  UUID NOT NULL REFERENCES aaa_participants(id) ON DELETE CASCADE,
  trigger_type    TEXT NOT NULL, -- 'schedule'|'location'|'wearable'|'manual'
  condition_json  JSONB NOT NULL DEFAULT '{}',
  action          TEXT NOT NULL, -- 'connect'|'alert'|'log'
  active          BOOLEAN NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aaa_support_log (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_id  UUID NOT NULL REFERENCES aaa_participants(id),
  window_id       UUID REFERENCES aaa_ambient_windows(id),
  trigger_id      UUID REFERENCES aaa_trigger_rules(id),
  initiated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at        TIMESTAMPTZ,
  support_type    TEXT,
  delivery_method TEXT, -- 'ambient'|'manual'|'trigger'
  ndis_line_item  TEXT, -- e.g. '07_002_0106_8'
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aaa_subscriptions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_id  UUID NOT NULL REFERENCES aaa_participants(id),
  stripe_sub_id   TEXT UNIQUE,
  tier            TEXT NOT NULL,
  status          TEXT NOT NULL DEFAULT 'active',
  current_period_end TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE aaa_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE aaa_ambient_windows ENABLE ROW LEVEL SECURITY;
ALTER TABLE aaa_trigger_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE aaa_support_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE aaa_subscriptions ENABLE ROW LEVEL SECURITY;

-- Service role bypass
CREATE POLICY "service_all" ON aaa_participants USING (true);
CREATE POLICY "service_all" ON aaa_ambient_windows USING (true);
CREATE POLICY "service_all" ON aaa_trigger_rules USING (true);
CREATE POLICY "service_all" ON aaa_support_log USING (true);
CREATE POLICY "service_all" ON aaa_subscriptions USING (true);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_aaa_windows_participant ON aaa_ambient_windows(participant_id);
CREATE INDEX IF NOT EXISTS idx_aaa_log_participant ON aaa_support_log(participant_id);
CREATE INDEX IF NOT EXISTS idx_aaa_log_initiated ON aaa_support_log(initiated_at DESC);
