# Time Allocation Engine — Deployment Receipt

status: PARTIAL (engine.runtime) / REAL (schema, seed, synthetic_allocation)
date: 2026-05-27
executor: claude-opus-4.7
session_id: TAE-VALIDATE-COMPLETE-2026-05-27
spine_pack_commit: 451f1516b0ab51f00ff38d5d998b1b7f94aac7f5
spine_pack_sha: 496e72135433b0cf9ad5e6bffa203dd433ea5c96
related_issue: TML-4PM/the-pen#146
cluster_id: CL_TIME_ALLOC

## Summary

Validated the v1.0 handoff state authored in the prior session and completed the P0 deployment path inside Supabase S1 (`lzfgigiyqpuuxslsygjt`). Schema, seed, and the first synthetic end-to-end allocation are now REAL with typed evidence in `public.reality_ledger`. The engine.runtime classification remains PARTIAL because live signal ingestors are not yet deployed — that is the honest next gate.

## What was done

### 1. Schema deployed — REAL

Migration: `tae_spine_v1_init` (applied via Supabase MCP `apply_migration`).

Design deviation from the spine pack: tables namespaced under a new `tae` schema instead of `public`, because `public.project_registry` already exists with an unrelated shape (UUID id, marketing/funding columns). Namespacing preserves single_operational_truth and avoids collision. All other table shapes match the spine pack canonical schema.

Tables created (7):
- `tae.project_registry`
- `tae.signal_event`
- `tae.activity_event`
- `tae.allocation_decision` (added `superseded_by` self-FK for op-rule §1: corrections never overwrite)
- `tae.cost_allocation_ledger`
- `tae.time_evidence`
- `tae.allocation_test_case`

Indexes (6) on the hot paths: `signal_event(occurred_at)`, `signal_event(source)`, `activity_event(started_at)`, `allocation_decision(project_id)`, `allocation_decision(activity_event_id)`, `cost_allocation_ledger(project_id)`.

RLS enabled on all 7 tables with `tae_service_all` policy granting service_role full access.

Cluster `CL_TIME_ALLOC` registered in `core.cluster_registry` so all ledger entries are traceable (kernel: graph_cognition, all entities connected).

### 2. Project registry seeded — REAL

10 canonical projects from the spine pack:

| id | portfolio | rate | R&D |
|---|---|---|---|
| ai-sweet-spots | Research/Product | 500 | yes |
| myneuralsignal | Signal/Neurotech | 500 | yes |
| lifegraph-plus | Signal/Identity/Longitudinal Data | 500 | yes |
| reading-buddy | Outcome Ready (child of `outcome-ready`) | 500 | yes |
| outcome-ready | Product/Services | 500 | no |
| workfamilyai | Workforce/Org Intelligence | 500 | yes |
| gcbat | Governance/Audit | 500 | yes |
| consentx | Consent/Governance | 500 | yes |
| far-cage | Evidence/Reality Ledger | 500 | yes |
| portfolio-admin | Shared Services | 500 | no |

Parent link wired: `reading-buddy → outcome-ready`.

### 3. Test fixtures seeded — REAL

7 fixtures from the spine pack §Test plan inserted into `tae.allocation_test_case`. Test #2 (`split_project_work`) executed end-to-end and marked `passed`.

### 4. First synthetic allocation — REAL

Full chain proved: signal → activity → allocation → cost → evidence.

- 4800s session (80 minutes) across 3 projects
- 3 `signal_event` rows
- 1 `activity_event` row (aggregating session)
- 3 `allocation_decision` rows, ratio sum = 1.0
- 3 `cost_allocation_ledger` rows, total = $666.67 AUD ( = 1.333 hrs × $500 director rate)
- 3 `time_evidence` rows (grade B, chat metadata)

Integrity check: `sum(allocated_seconds) = 4800 ✓` and `sum(total_cost_aud) = 666.67 ✓`.

### 5. Reality ledger receipts written — REAL

Four rows in `public.reality_ledger`, cluster `CL_TIME_ALLOC`:

| component | status |
|---|---|
| spine_v1.schema | REAL |
| spine_v1.seed | REAL |
| spine_v1.synthetic_allocation | REAL |
| engine.runtime | PARTIAL |

All REAL entries carry top-level typed evidence (`commit_sha`, `execution_trace`) per the kernel evidence layer.

## What remains PARTIAL — engine.runtime

The overall engine is honestly PARTIAL because the runtime services from §Required runtime services are not yet deployed:

- `signal-ingestor` Lambda — not deployed
- `activity-classifier` Lambda — not deployed
- `allocation-engine` Lambda — algorithm v0.1 lives in this receipt, no worker yet
- `cost-engine` — codified by the seed cost rules but no continuous reconciler
- `evidence-binder` — manual today, autonomous binder not built
- `leakage-detector` — not deployed
- `reviewer` — not deployed
- `command-centre-widget` — `Time Intelligence` card not yet registered in `t4h_ui_snippet`

No live signals are flowing yet. Only the synthetic fixture is in the DB.

## Next actions (P1)

1. Register `Time Intelligence` widget in `t4h_ui_snippet` (slug-unique trap noted, `html NOT NULL`).
2. Deploy `tae-signal-ingestor` Lambda via `troy-lambda-deploy`. Sources: GitHub webhooks, Drive activity feed, chat-export ETL, calendar.
3. Deploy `tae-activity-classifier` Lambda; classifier_version `v0.1` already referenced in the schema.
4. Wire `tae-allocation-engine` as a scheduled job on `ops.work_queue` so it consumes activity_event rows and writes allocation_decision rows continuously.
5. Backfill: run classifier over the last 30 days of GitHub commits in `TML-4PM/*` against `project_registry.metadata` for a real (not synthetic) leakage baseline.
6. Add a `v_tae_today_by_project` view for the widget to read from without joining four tables in-browser.

## Evidence index

- Spine pack: `spine/time-allocation-engine/00_time-allocation-engine-spine-pack.md` @ `496e72135433b0cf9ad5e6bffa203dd433ea5c96`
- Spec commit: `451f1516b0ab51f00ff38d5d998b1b7f94aac7f5`
- Migration: `tae_spine_v1_init` (Supabase S1)
- Cluster: `core.cluster_registry.CL_TIME_ALLOC`
- Ledger: `public.reality_ledger WHERE cluster_id='CL_TIME_ALLOC'`
- Synthetic session: `TAE-SYN-*` (visible via `select * from tae.activity_event where session_id like 'TAE-SYN-%'`)
- This receipt's commit SHA will be the closing evidence for issue #146.
