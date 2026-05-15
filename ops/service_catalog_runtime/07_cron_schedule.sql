-- Service Catalog Runtime: pg_cron schedule
-- Date: 2026-05-16
-- jobids issued: 320 ops_runtime_tick (*/5), 321 ops_session_sweep_hourly (7 *),
--                322 ops_audit_sweep_daily (17 3 *), 323 ops_contamination_scan_daily (23 4 *),
--                324 ops_freshness_decay_daily (37 5 *)

SELECT cron.schedule('ops_runtime_tick',              '*/5 * * * *', $$SELECT ops.fn_runtime_tick();$$);
SELECT cron.schedule('ops_session_sweep_hourly',      '7 * * * *',   $$SELECT ops.fn_sweep_sessions(86400);$$);
SELECT cron.schedule('ops_audit_sweep_daily',         '17 3 * * *',  $$SELECT ops.fn_sweep_audit_artifacts(14);$$);
SELECT cron.schedule('ops_contamination_scan_daily',  '23 4 * * *',  $$SELECT ops.fn_scan_contamination();$$);
SELECT cron.schedule('ops_freshness_decay_daily',     '37 5 * * *',  $$SELECT ops.fn_decay_freshness(30);$$);
