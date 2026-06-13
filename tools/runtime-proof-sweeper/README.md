# runtime-proof-sweeper

Hourly system-wide queue reconciler. Built per [the-pen#145](https://github.com/TML-4PM/the-pen/issues/145), extended by [the-pen#187](https://github.com/TML-4PM/the-pen/issues/187), 2026-06-14.

## Purpose

Fix the whole execution loop, not one ticket at a time. Every hour:

1. Enumerate every open issue, PR, inbox item, handoff and `ops.work_queue` row.
2. Classify each by runtime proof: **REAL** | **PARTIAL** | **BLOCKED**. `PRETEND` is never a close state.
3. Detect GitHub-only proof where commit/issue exists but runtime receipt does not.
4. Detect Bridge payloads without Bridge receipts.
5. Detect worker pickup failure.
6. Requeue stale `work_queue` rows non-destructively.
7. Write machine-readable receipt under `receipts/runtime-proof-sweeper/run-{YYYY-MM-DDTHH}.json`.
8. Write or update a `reality_ledger` entry per run.
9. Update Command Centre runtime-proof view if connected.

## Loop

`inbox -> worker -> bridge -> receipt -> ledger -> close`

## Classification rules

See [`classification_rules.json`](./classification_rules.json).

Short version:

- **REAL**: runtime receipt exists, ledger row exists, and evidence binds to the work item.
- **PARTIAL**: GitHub issue/commit/PR or queue row exists, but runtime receipt is absent.
- **BLOCKED**: bounded blocker named: `missing-permission`, `missing-secret`, `missing-route`, `missing-worker`, `missing-runtime`, `dependency-failure`, `receipt-mismatch`, `ontology-drift`.

## Schedule

Hourly via scheduler/worker. If pg_cron, Lambda, worker route, or Bridge dispatch is missing, emit a BLOCKED receipt rather than silently passing.

See [`hourly_schedule.md`](./hourly_schedule.md) for schedule state.

## Receipts

Every run writes to `receipts/runtime-proof-sweeper/run-{YYYY-MM-DDTHH}.json` matching [`receipt_schema.json`](./receipt_schema.json).

Bootstrap receipt: [`../../../receipts/runtime-proof-sweeper/bootstrap.json`](../../../receipts/runtime-proof-sweeper/bootstrap.json).

## Operating doctrine

- No destructive actions.
- No duplicate noise.
- PRETEND prohibited.
- Commit proof is not runtime proof.
- Bounded BLOCKED beats false completion.
- Close only with runtime proof, receipt proof and visible ledger/Command Centre state.

## Current state

Status: PARTIAL.

Reason: tooling and control issue exist, but a live worker run and receipt are still required for REAL.
