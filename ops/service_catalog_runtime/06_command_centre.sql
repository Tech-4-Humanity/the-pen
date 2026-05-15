-- Service Catalog Runtime: Command Centre views + canonical graph seed
-- Deployed migration: service_catalog_runtime_06_command_centre
-- Date: 2026-05-16

CREATE OR REPLACE VIEW ops.v_cc_catalog_overview AS
SELECT
  ci.catalog_id, ci.name, ci.brand, ci.business_group, ci.lifecycle_stage,
  ci.audit_status, ci.authority_required, ci.risk_class, ci.support_model,
  ci.last_refreshed_at,
  EXTRACT(EPOCH FROM (now() - ci.last_refreshed_at))::integer AS age_seconds,
  cardinality(ci.fulfilment_steps) AS fulfilment_step_count,
  cardinality(ci.evidence_required) AS evidence_count,
  cardinality(ci.telemetry_required) AS telemetry_count,
  COALESCE(p.tier_count, 0) AS pricing_tier_count,
  COALESCE(q.quote_count_30d, 0) AS quote_count_30d,
  ops.fn_catalog_active_ready(ci.catalog_id) AS active_ready
FROM ops.service_catalog_items ci
LEFT JOIN (SELECT catalog_id, COUNT(*) AS tier_count FROM ops.service_catalog_pricing GROUP BY catalog_id) p ON p.catalog_id = ci.catalog_id
LEFT JOIN (SELECT catalog_id, COUNT(*) AS quote_count_30d FROM ops.service_catalog_economic_events
           WHERE event_type='quote' AND occurred_at > now()-interval '30 days' GROUP BY catalog_id) q ON q.catalog_id = ci.catalog_id;

CREATE OR REPLACE VIEW ops.v_cc_runtime_health AS
SELECT
  (SELECT COUNT(*) FROM ops.runtime_session_registry WHERE freshness_state='CURRENT') AS sessions_current,
  (SELECT COUNT(*) FROM ops.runtime_session_registry WHERE freshness_state<>'CURRENT') AS sessions_stale,
  (SELECT COUNT(*) FROM ops.runtime_contradiction_register WHERE status IN ('OPEN','BLOCKED')) AS open_contradictions,
  (SELECT COUNT(*) FROM ops.runtime_drift_register WHERE status IN ('OPEN','BLOCKED')) AS open_drift,
  (SELECT COUNT(*) FROM ops.service_catalog_items WHERE lifecycle_stage IN ('OFFER_READY','MARKET_READY','ACTIVE')) AS active_catalog_items,
  (SELECT COUNT(*) FROM ops.v_catalog_gaps) AS catalog_gap_count,
  (SELECT COUNT(*) FROM ops.runtime_execution_receipts WHERE status='REAL' AND created_at > now()-interval '24 hours') AS receipts_real_24h,
  (SELECT COUNT(*) FROM ops.runtime_execution_receipts WHERE status IN ('PARTIAL','BLOCKED','FAILED') AND created_at > now()-interval '24 hours') AS receipts_failed_24h,
  (SELECT COUNT(*) FROM ops.runtime_telemetry_events WHERE severity IN ('ERROR','CRITICAL') AND emitted_at > now()-interval '24 hours') AS telemetry_errors_24h,
  now() AS as_of;
