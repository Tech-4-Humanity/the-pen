-- ============================================================================
-- Content Signal OS — Teardown (rollback-first)
-- Reverses 20260518_content_signal_os_schema.sql + seed completely.
-- Destructive: GATED. Run only on explicit instruction.
-- ============================================================================
drop schema if exists content_signal cascade;
