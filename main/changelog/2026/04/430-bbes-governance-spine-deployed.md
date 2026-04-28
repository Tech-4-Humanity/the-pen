# BBES governance spine deployed

_Change #430 · 2026-04-27 · NORMAL · SCHEMA_CHANGE_

Author: `claude+troy`

Hash: `cf4f39d9ef20ac2f5a19d9baf9c49ca81e3bfdf908079757382ca961e2d07deb`

## Summary

Extended canonical_changes (hash, body_md, audiences, sealed, rollback_of). Added gov_doc_register, gov_emit_queue, gov_metric_snapshot. 10 functions, 12 views, 4 cron jobs.

## Affected

- `public.t4h_canonical_changes`
- `public.gov_doc_register`
- `public.gov_emit_queue`
- `public.gov_metric_snapshot`
- `public.change_emit`
- `public.change_seal`
- `public.gov_sop_synth`
- `public.gov_audit_pack`
- `public.gov_capture_metrics`

## Business keys

- `tech-for-humanity`

## Evidence

gov_smoke proven: sop_synth created doc d770a5b8 (1275 chars); change_seal locked id=429; mutation rejected

---
_Auto-emitted by gov_emit_drain · 2026-04-28 00:12:13.221757+00_