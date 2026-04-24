# Queue Control Plane v1

Purpose: make PEN/worker/sweeper execution provable, repairable, and queue-first.

## Assets in this bundle

| file | purpose |
|---|---|
| `jobs/queue-health-check.json` | checks queue health and emits metrics receipt |
| `jobs/worker-heartbeat-audit.json` | verifies worker/sweeper liveness |
| `jobs/receipt-verify.json` | checks completed jobs have runtime receipts |
| `jobs/audit-reconcile.json` | reconciles work queue to audit log |
| `jobs/stale-jobs-requeue.json` | requeues stale running jobs safely |
| `jobs/dead-letter-move.json` | moves poison jobs to DLQ/archive path |
| `jobs/idempotency-audit.json` | detects duplicate or malformed idempotency |
| `jobs/schema-drift-check.json` | reports missing expected control-plane objects |
| `jobs/intent-compiler-bootstrap.json` | prepares intent-to-job-graph bootstrap |
| `jobs/verifier-worker-bootstrap.json` | prepares verification hard gate bootstrap |
| `jobs/synthetic-load-inject.json` | injects safe mixed test jobs |
| `instructions/WORKER_INSTRUCTIONS.md` | worker/sweeper operating rules |
| `instructions/USER_INSTRUCTIONS.md` | human operating rules |
| `receipts/queue-control-plane-v1-posted.json` | posting receipt for this bundle |

## Rule

Archive does not mean delete. All repair work must be idempotent and produce receipts.
