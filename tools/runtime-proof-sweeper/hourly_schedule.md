# Hourly schedule

## Current scheduler binding

**Primary path:** pg_cron job `runtime_proof_sweeper_hourly` calls
`SELECT public.fn_runtime_proof_sweeper_kick()` every hour at minute `:15`.

The function:
1. INSERTs a row into `ops.work_queue` with `destination='troy-runtime-proof-sweeper'`,
   `status='ready'`, `last_heartbeat=NULL`, `dedupe_key='runtime-proof-sweeper:{YYYY-MM-DD-HH}'`.
2. The dispatcher cron `work_queue_dispatch_1min` picks it up within 60s.
3. The Lambda runs the sweep, writes the receipt to S3 + `reality_ledger`.
4. Reconcile updates the queue row to `done` with the receipt summary.

## Current state

```yaml
cron_job_id: pending_install
schedule: "15 * * * *"
function: public.fn_runtime_proof_sweeper_kick()
lambda_target: troy-runtime-proof-sweeper
state: BLOCKED — Lambda 'troy-runtime-proof-sweeper' not yet deployed
bounded_blocker:
  type: missing-worker
  detail: |
    The Lambda 'troy-runtime-proof-sweeper' has not been deployed yet.
    The hourly intake row will be created by pg_cron but will sit BLOCKED
    in ops.work_queue until the Lambda is wired. The first run was executed
    manually from a developer host on 2026-05-25T04:07:59Z.
  unblocked_by: deploy troy-runtime-proof-sweeper via troy-lambda-deploy with the script in tools/runtime-proof-sweeper/runtime_proof_sweeper.py
```

## Manual interim path

Until the Lambda is wired, run the sweeper from any host with `GITHUB_PAT` + `SUPABASE_SERVICE_KEY`:

```bash
export GITHUB_PAT="<pat>"
export SUPABASE_SERVICE_KEY="<service_role_key>"
python3 tools/runtime-proof-sweeper/runtime_proof_sweeper.py
```

The script writes a `reality_ledger` REAL entry on every run, so even without scheduler the receipt chain is honest.

## First-run receipt

`receipts/runtime-proof-sweeper/bootstrap.json` — bootstrap from 2026-05-25T04:08Z.
