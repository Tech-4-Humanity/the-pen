# runtime-proof-sweeper

Hourly system-wide queue reconciler. Built per [the-pen#145](https://github.com/TML-4PM/the-pen/issues/145), 2026-05-25.

## Purpose

Fix the whole execution loop, not one ticket at a time. Every hour:

1. Enumerate every open issue, PR, and `ops.work_queue` row.
2. Classify each by runtime proof: **REAL** | **PARTIAL** | **BLOCKED**. `PRETEND` is never a close state.
3. Requeue stale `work_queue` rows non-destructively (NULL their `last_heartbeat` so dispatcher re-fires).
4. Write machine-readable receipt under `receipts/runtime-proof-sweeper/run-{YYYY-MM-DDTHH}.json`.
5. Write a `reality_ledger` REAL entry per run.
6. Update `cc_runtime_proof_widget` view (if Command Centre widget connected).

## Loop

`inbox → worker → bridge → receipt → ledger → close`

## Classification rules

See [`classification_rules.json`](./classification_rules.json) — short version:

- **REAL** — a `public.reality_ledger` REAL entry exists with token-overlap ≥ 3 with the item's title+body keywords.
- **PARTIAL** — artifact exists (GitHub issue/commit/PR, or `work_queue` row mid-flight) but no runtime receipt yet.
- **BLOCKED** — bounded blocker named: `missing-permission`, `missing-secret`, `missing-route`, `missing-worker`, `missing-runtime`, `dependency-failure`.

## Schedule

Hourly via pg_cron job `runtime_proof_sweeper_hourly` calling `public.fn_runtime_proof_sweeper_kick()` which dispatches a `work_queue` row pointing to the Lambda `troy-runtime-proof-sweeper` (when deployed) or returns BLOCKED receipt if the Lambda is missing.

See [`hourly_schedule.md`](./hourly_schedule.md) for current schedule state.

## Receipts

Every run writes to `receipts/runtime-proof-sweeper/run-{YYYY-MM-DDTHH}.json` matching [`receipt_schema.json`](./receipt_schema.json).

Bootstrap receipt: [`../../../receipts/runtime-proof-sweeper/bootstrap.json`](../../../receipts/runtime-proof-sweeper/bootstrap.json).

## Operating doctrine

- **No destructive actions.** Sweeper only inspects, classifies, requeues (heartbeat-null), and comments-with-new-evidence.
- **No duplicate noise.** Comment only when the classification or evidence changed since last run.
- **PRETEND prohibited.** A close that lacks runtime proof is never permitted as REAL; demote to PARTIAL with bounded reason.
- **Bounded BLOCKED.** Every BLOCKED state names exactly which dependency is missing.

## Out of band

The sweeper does not delete, archive, close, or weaken any controls. Those require explicit operator authority.
