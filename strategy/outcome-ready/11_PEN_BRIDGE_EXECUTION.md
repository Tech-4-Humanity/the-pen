# 11 — PEN / Bridge Execution Package

## Purpose

After HITL review, this set of bridge jobs deploys the spine of the two-brand operating model into the canonical T4H stack.

All jobs follow the canonical bridge envelope (`troy-sql-executor` uses nested payload; other Lambdas use top-level). Every execution writes to `t4h_canonical_changes` and `reality_ledger`.

## Pre-Flight Checks

1. Bridge DNS pinned (`/etc/hosts` step — already in session bootstrap)
2. `cap_secrets` rotation date for `bk_gfTUR` is in the future
3. `core.registry_entities` has an entry for `outcome_ready` business
4. `arch_wave_validation` baseline captured
5. RDTI tag confirmed if applicable

## Job 1 — Schema Deployment (DDL via `run_sql` RPC)

Create `outcome` schema and 5 tables + 2 views per `09_CRM_DATASET_SPEC.md`.

## Job 2 — Register Brands in `core.registry_entities`

Insert: `outcome_ready_master`, `thriving_biz`, `thriving_kids`.

## Job 3 — Register SKUs in `public.t4h_template_library`

For each SKU in `03_THRIVING_BIZ_CATALOGUE.md` and `04_THRIVING_KIDS_CATALOGUE.md`.

## Job 4 — Log Canonical Change

```sql
INSERT INTO public.t4h_canonical_changes
  (change_type, severity, title, description, source, project_code)
VALUES
  ('PRODUCT_CHANGE','HIGH',
   'Outcome Ready master programme + Thriving Biz + Thriving Kids brands established',
   'Brand hierarchy locked. Two-brand portfolio operationalised under Outcome Ready with calendar-driven attention windows (May–Jul Biz, Aug–Oct Kids).',
   'master_doc_pack_2026_05_13',
   'outcome-ready-2026');
```

## Job 5 — Reality Ledger Anchor

```sql
INSERT INTO public.reality_ledger
  (entity, status, evidence)
VALUES
  ('outcome_ready_programme',
   'PARTIAL',
   'Master docs drafted 2026-05-13. Schema not yet applied, no live revenue, HITL approval pending.');
```

PARTIAL until: schema deployed, first campaign run with telemetry, first conversion event captured, HITL approval received.

## Job 6 — Stamp Governance Kernel Entry

Confirm `stamp.governance_event` table signature before running.

## Job 7 — Telegram Broadcast

Use existing Telegram broadcaster Lambda (chat_id `6972032328`).

## Job 8 — Commit Doc Pack to PEN

Use `fn_github_push` with 7 args incl. attribution (`caller_llm`, `caller_session`).

## Acceptance Gates

| Gate | Criterion | Owner |
|------|-----------|-------|
| HITL approval | Troy signs off on all 12 docs | Troy |
| Schema deployed | All 5 tables + 2 views created and verified | Bridge |
| Brands registered | 3 entries in `core.registry_entities` | Bridge |
| Canonical change logged | Row in `t4h_canonical_changes` with PRODUCT_CHANGE / HIGH | Bridge |
| Reality ledger anchored | Row in `reality_ledger` for `outcome_ready_programme` | Bridge |
| Docs in PEN | All 12 files committed | Bridge |
| Internal notification sent | Telegram broadcast confirmed | Bridge |

## Rollback Plan

If anything fails or HITL rejects:
1. Drop `outcome.*` schema (no production data yet)
2. Revert `core.registry_entities` inserts
3. Append a CANCELLED row to `t4h_canonical_changes`
4. Update `reality_ledger` row to BLOCKED with reason

## What This Job Pack Does NOT Do

- Does not deploy any new Lambdas (everything reuses existing functions)
- Does not modify any production participant or customer data
- Does not push any marketing campaigns live
- Does not bill any customers
- Does not change any consent or privacy settings
- Does not make any binding commitments external to T4H

It is purely: docs in PEN, schema for CRM, brand registry entries, governance entries.

## CIP Exception Posture

Per global rule kernel: `cip_exception` applies — no new Lambdas being deployed here. If subsequent jobs require new Lambda deploys, each will need its own `cip.approvals` entry.
