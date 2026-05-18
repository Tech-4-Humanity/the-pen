# Pen Runtime Operational Stack

Status: REAL (files committed)

## Purpose
The Pen Runtime is the execution fabric connecting GitHub issues → Bridge workers → Supabase receipts → Reality Ledger.

## Worker Pools

| Worker | Role |
|---|---|
| intake-scanner | Scan GitHub issues/files/commits for OPEN/PARTIAL/BLOCKED items |
| dev-puller | Pull buildable tasks into Dev/Symbio lane |
| bridge-router | Dispatch execution/validation to Bridge |
| receipt-harvester | Reconcile receipts back into The Pen |
| smoke-tester | Run runtime health checks |
| stale-sweeper | Retry or block stale PARTIAL items |
| prod-gate | Synapse promotion only after REAL gates pass |
| movement-reporter | Post cycle counts to Command Centre |

## Operational Doctrine

```yaml
canonical_queue: GitHub/The Pen
build_lane: Dev/Symbio
execution_fabric: Bridge
prod_gate: Synapse
truth_layer: Reality Ledger + GitHub receipts
human_mirror: Notion optional
alert_layer: Slack optional
```

## Cycle
1. intake-scanner reads all OPEN/PARTIAL issues
2. dev-puller routes buildable tasks to Dev lane
3. bridge-router dispatches execution
4. Workers execute and write receipts
5. receipt-harvester reconciles receipts into ledger
6. stale-sweeper handles anything > TTL
7. prod-gate promotes REAL items to Synapse
8. movement-reporter logs cycle metrics

## Reality Gate
Nothing is REAL until a Bridge receipt with commit SHA or runtime evidence exists.
