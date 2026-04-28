# BBES governance spine deployed (asset architecture, 4 cron jobs, immutability)

_Change #432 · 2026-04-28 · NORMAL · SCHEMA_CHANGE_

Author: `claude+troy` · 🔒 Sealed @ 2026-04-28 00:03:56.325615+00

Hash: `34c070602e9151bd05b5baa4e83d12b1a0e5eb323780fe51ecd1ed361481693e`

## Summary

Cognitive-to-Capital governance layer interlocks with pre-existing v_gov_* scaffold. Adds: 11 columns to t4h_canonical_changes (hash, body_md, audiences, is_rd, project_code, business_keys, sealed, sealed_at, rollback_of, emit_status). 3 new tables (gov_doc_register, gov_emit_queue, gov_metric_snapshot). 3 new enums (gov_audience, gov_doc_type, gov_emit_status). 10 new functions (change_emit, change_seal, change_immut_check, gov_sop_synth, gov_sop_sweep, gov_audit_pack, gov_capture_metrics, gov_emit_drain_claim, gov_emit_complete + bbes_set_updated_at trigger). 12 new views (change_velocity, reality_drift, rollback_ratio, doc_debt, rdti_evidence_completeness, single_author_risk, anti_pattern_recurrence, emit_health, metric_dashboard, knowledge_graph, doc_register_active, change_to_revenue_lag). 4 cron jobs (282 metrics_weekly, 283 sop_sweep_weekly, 284 audit_pack_quarterly, 285 metric_capture_daily). Immutability via change_immut_check trigger - sealed changes cannot mutate body/title/affected/hash. Smoke verified: gov_sop_sweep produced 101 SOPs covering all entities in canonical_changes; immutability blocked tampering with sealed change 429 (correct behaviour, NOT a bug). KNOWN ISSUE: bridge SELECT public.gov_capture_metrics() / public.gov_audit_pack() returns sql_error due to jsonb-return serialization quirk. Workaround: cron runs functions directly (no bridge involved); ad-hoc calls use DO block wrapper. Functions themselves verified working via individual SQL and via cron context.

## Affected

- `public.t4h_canonical_changes (extended +11 cols)`
- `public.gov_doc_register`
- `public.gov_emit_queue`
- `public.gov_metric_snapshot`
- `public.change_emit`
- `public.change_seal`
- `public.change_immut_check`
- `public.gov_sop_synth`
- `public.gov_sop_sweep`
- `public.gov_audit_pack`
- `public.gov_capture_metrics`
- `public.gov_emit_drain_claim`
- `public.gov_emit_complete`
- `public.v_gov_change_velocity`
- `public.v_gov_reality_drift`
- `public.v_gov_rollback_ratio`
- `public.v_gov_doc_debt`
- `public.v_gov_rdti_evidence_completeness`
- `public.v_gov_single_author_risk`
- `public.v_gov_anti_pattern_recurrence`
- `public.v_gov_emit_health`
- `public.v_gov_metric_dashboard`
- `public.v_gov_knowledge_graph`
- `public.v_gov_doc_register_active`
- `public.v_gov_change_to_revenue_lag`
- `cron.job:282:gov_metrics_weekly`
- `cron.job:283:gov_sop_sweep_weekly`
- `cron.job:284:gov_audit_pack_quarterly`
- `cron.job:285:gov_metric_capture_daily`

## Business keys

- `tech-for-humanity`

## Evidence

gov_sop_sweep produced 101 SOPs; immutability trigger blocks sealed-change mutation; cron 282-285 scheduled

---
_Auto-emitted by gov_emit_drain · 2026-04-28 00:12:13.221757+00_