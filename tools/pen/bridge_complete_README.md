# bridge complete

## What changed
`pen_ingest_worker.mjs` is now fully bridged to the `/dominate` self-healing contracts.

## Flow
1. **Watchdog first** — `watchdog_reclaim_stale_jobs()` runs before inbox processing. Stale CLAIMED/RUNNING jobs are reclaimed automatically. No HITL.
2. **Inbox scan** — reads `inbox/*.json` as before.
3. **Enqueue** — each job is pushed into pgmq shadow map via `enqueue_pen_job()` (idempotent).
4. **Heartbeat** — VT is extended immediately on pickup.
5. **Receipt written** — `receipts/runtime/<key>.receipt.json` written with full `/dominate` contract shape.
6. **pgmq complete** — `complete_pen_job()` archives message and sets final state.
7. **Evidence reconciled** — `reconcile_evidence()` writes to `audit.evidence_register`.
8. **Projection refreshed** — `refresh_command_centre_projection()` rebuilds Command Centre widget state.

## Command Centre green rule
Green only when receipt + evidence + projection are all fresh and current (see `command_centre_green_policy` view in Supabase).

## Environment variables required
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `BRIDGE_WORKER_ID` (optional, default: pen-ingest-worker-01)
- `BRIDGE_QUEUE_NAME` (optional, default: pen_jobs)
- `BRIDGE_VT_SECONDS` (optional, default: 300)
- `BRIDGE_MAX_CLAIM` (optional, default: 10)
- `BRIDGE_IDEMPOTENCY_KEY` (optional, filters inbox to one job)

## SQL required
Apply `pgmq_self_healing_finish.sql` to your Supabase instance before running.

## Remaining gap
Set `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` in GitHub Actions secrets to activate the Supabase bridge. Without them the worker falls back to local receipt-only mode.
