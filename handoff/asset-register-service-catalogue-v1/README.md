# Asset Register + Service Catalogue v1

**Status:** PARTIAL (per Rule Kernel v6 — REAL gates not all met yet)
**Applied:** 2026-05-15 21:28 UTC
**Project:** lzfgigiyqpuuxslsygjt (S1)
**Reality Ledger:** `public.reality_ledger` id=`da2d7850-79b8-4fa7-9cc1-366f690b630c`
**Cluster:** `CL_CATALOG_CANON`
**Migration:** `asset_register_service_catalogue_v1`

## What landed

| Surface | Type | Rows |
|---|---|---:|
| `public.asset_type_catalogue` | table (taxonomy) | 57 |
| `public.master_asset_register` | table | 12 |
| `public.service_catalogue` | table | 10 |
| `public.product_pricing_registry` | table | 0 |
| `public.registry_reconciliation_loop` | table | 6 |
| `public.v_service_catalogue_control` | view | 10 |
| `public.v_master_asset_register_control` | view | 12 |
| `public.v_master_asset_register_by_family` | view | 2 families with rows |

## Families seeded (9)

1. Research & Evidence
2. Product & Commercial
3. Systems & Architecture
4. Governance & Integrity
5. Content & IP
6. AI Agents
7. Digital Surface
8. Financial & Operational
9. Strategic & Meta

## Reconciliation loops seeded (6)

| Loop | Type | Schedule |
|---|---|---|
| `loop.discovery.assets` | discovery | hourly |
| `loop.classification.assets` | classification | hourly |
| `loop.reconciliation.duplicates` | reconciliation | 6h |
| `loop.economic.product_mapping` | economic | 6h |
| `loop.reality.evidence` | reality | daily |
| `loop.survivability.catalogue` | survivability | 6h |

Loops are **declared, not yet scheduled.** pg_cron wiring is the next move.

## Canonical joins

- `master_asset_register.owner_business_key` → `t4h_business_registry.business_key`
- `service_catalogue.business_key` → `t4h_business_registry.business_key`
- `service_catalogue.primary_asset_id` → `master_asset_register.asset_id`
- `product_pricing_registry.service_code` → `service_catalogue.service_code`

## Why PARTIAL not REAL

Rule Kernel v6 says REAL requires: executed + replayable + receipted + ledger_written + telemetry_verified + runtime_observed + economically_validated.

The runtime ledger downgrades to PARTIAL because:

- `product_pricing_registry` empty — no Stripe sync yet → not `economically_validated`
- 6 loops defined but none scheduled via pg_cron → not `runtime_observed`
- Asset Discovery Loop has not run against GitHub/Vercel/Drive/Stripe/Supabase
- All 10 services PARTIAL with full 5-gap list (pricing/support/telemetry/delivery/evidence)

## Next moves to lift to REAL

1. pg_cron schedule for `loop.discovery.assets` (hourly)
2. Backfill `master_asset_register` from existing `public.research_asset_register` (asset_code, layer_code, evidence_uri)
3. Wire `loop.economic.product_mapping` to Stripe via bridge — populate `product_pricing_registry`
4. Import OutcomeReady SKU catalogue into `product_pricing_registry`
5. Surface `v_service_catalogue_control` on Command Centre
6. Re-run ledger write — trigger should promote to REAL once economic + runtime gates clear

## Replay

Full migration SQL at `supabase/migrations/2026-05-15_asset_register_service_catalogue_v1.sql`.
Idempotent — safe to re-apply.
