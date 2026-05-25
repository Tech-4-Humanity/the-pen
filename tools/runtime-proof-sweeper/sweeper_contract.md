# sweeper_contract.md

## Operating contract for `runtime-proof-sweeper`

### Inputs (required, every run)

1. `public.reality_ledger` — full set of `status='REAL'` rows from last 60 days (`SELECT id, system, component, evidence, last_verified ...`).
2. GitHub search `org:TML-4PM is:issue is:open` and `is:pr is:open` (paginated).
3. `ops.work_queue` rows with `status IN ('submitted','accepted','triaged','ready','claimed','in_progress')`.

### Required actions per run

For each enumerated item:

1. **Detect runtime proof.** Match by token-overlap (≥ 3 distinctive tokens) against the ledger.
2. **Detect artifact-only proof.** Item has GitHub URL/commit but no ledger match.
3. **Detect bridge-payload-without-receipt.** `work_queue` row with `last_heartbeat > 10 min` but no reconciled response in `net._http_response`.
4. **Detect worker pickup failure.** `work_queue` row with `retry_count >= max_retries` and no terminal status.
5. **Detect staleness.** Buckets: `<1h`, `1-24h`, `24-72h`, `72h-7d`, `>7d`.
6. **Requeue or escalate non-destructively.** For BLOCKED `missing-worker:never_dispatched`, NULL the row's `last_heartbeat` so dispatcher re-fires. For repeated dispatch failures, attach a `error_detail.escalated=true` flag and stop re-firing.
7. **Write machine-readable receipt.** `receipts/runtime-proof-sweeper/run-{YYYY-MM-DDTHH}.json` matching `receipt_schema.json`.
8. **Update ledger.** One `reality_ledger` REAL entry per run, system=`runtime_proof_sweeper`, component=`hourly_run_{TS}`.
9. **Comment with new evidence only.** Skip if classification + evidence unchanged from previous run.

### Required reporting outputs

Each run's receipt JSON includes:

- `started`, `finished` ISO timestamps
- `totals`: count of issues, PRs, queue rows inspected
- `classifications`: per-bucket counts (REAL/PARTIAL/BLOCKED) for issues, PRs, queue
- `stale_24h`, `stale_72h` counts
- `oldest_unresolved`: top 50 oldest PARTIAL/BLOCKED items
- `blocked_by_reason`: counts per bounded blocker
- `requeue_attempts`: list of `{job_id, result}` for each non-destructive requeue
- `requeued_count`: integer total

### Acceptance gates (this contract is REAL when)

1. Hourly cron schedule exists OR a bounded BLOCKED receipt documents the scheduler gap.
2. First sweeper run has produced a receipt file.
3. `runtime-proof-missing` queue surface exists (the PARTIAL/BLOCKED counts in the receipt are the queue).
4. At least one stale item has been requeued or escalated non-destructively (or `requeued_count=0` with explicit "queue empty" note).
5. Command Centre widget spec exists (`command_centre_widget_spec.md`).
6. Receipt write path is exercised.
7. `reality_ledger` entry written.

### Reversibility & safety

- All actions are non-destructive: read, classify, comment, NULL heartbeat (which only requests re-attempt).
- No DELETEs. No status mutations to `done`/`closed`/`archived` without proof.
- No comments unless evidence changed.
- No human approval required for inspection, classification, non-destructive requeue, comment-with-new-evidence, receipt write, ledger write, schedule maintenance.

### Failure handling

- If GitHub API rate-limits, write partial receipt with `partial_run=true` and resume next hour.
- If Supabase REST fails, retry once with 5s backoff; if still failing, write BLOCKED receipt naming `missing-runtime:supabase_rest`.
- If runtime exception, write `error_detail` to receipt and continue with whatever data was collected.
