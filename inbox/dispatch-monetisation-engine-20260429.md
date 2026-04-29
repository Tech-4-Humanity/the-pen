# PEN inbox dispatch — monetisation-architecture-engine
utc: 2026-04-29
priority: HIGH
target_handoff: handoffs/2026-04-29-monetisation-architecture-engine.md
mirror_source: TML-4PM/mcp-command-centre/handoffs/pen/2026-04-29-monetisation-architecture-engine.md
state: PARTIAL → READY-FOR-PEN
expected_artefacts:
  - supabase/migrations/2026_04_29_monetisation_engine.sql
  - scripts/import_skus_from_csv.py
  - scripts/scoring_engine.py
  - api/sku_activation_endpoints.py
  - cc/widgets/monetisation_revenue_loop.tsx
  - stripe/dry_run_mapper.json
gates:
  - schema_apply: GATED (dry-run SELECT first)
  - stripe_create: BLOCKED (creds tier)
  - widget_publish: LOG
proof_gates:
  - rows in core.sku_registry > 0
  - rows in core.bundle_registry >= 4
  - cc view v_monetisation_pipeline returns counts
