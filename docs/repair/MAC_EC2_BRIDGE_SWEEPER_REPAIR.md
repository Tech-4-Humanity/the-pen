# Mac / EC2 / Bridge Sweeper Repair Runbook

Status: repair actions generated
Evidence state: PARTIAL until runtime receipts land
Scope: repair worker pickup and execution path for continuous sweeper system

## Current observed state

| Layer | State |
|---|---|
| GitHub inbox jobs 001-012 | queued/committed |
| Master bridge/Mac handoff | committed |
| Worker runtime receipt | not observed |
| Direct bridge runtime receipt | not observed |
| Likely failure class | worker polling / runner bootstrap / bridge invocation path |

## Target outcome

Restore proof-producing execution for:

1. Mac endpoint worker
2. EC2 fallback worker
3. Bridge direct invoke path
4. GitHub inbox polling
5. receipts/runtime writeback

## Required repair artefacts

The following jobs are queued:

| Job | Path | Purpose |
|---|---|---|
| 013 | `inbox/repair-mac-endpoint-worker-013.json` | Diagnose/start Mac endpoint worker |
| 014 | `inbox/repair-ec2-runner-worker-014.json` | Diagnose/start EC2 worker fallback |
| 015 | `inbox/repair-bridge-invoke-path-015.json` | Diagnose bridge/API/Lambda invoke path |
| 016 | `inbox/repair-worker-receipt-writeback-016.json` | Verify receipt writeback to GitHub |

## Repair sequence

1. Run `repair-worker-receipt-writeback-016` first if any worker exists.
2. Run `repair-mac-endpoint-worker-013` on Mac endpoint.
3. If Mac unavailable, run `repair-ec2-runner-worker-014`.
4. Run `repair-bridge-invoke-path-015` to prove bridge runtime.
5. Re-run `force-execute-bridge-mac-sweeper-010`.
6. Confirm final receipt under `receipts/runtime/bridge-mac-complete-sweeper-system-009/`.

## Done state

Runtime is only COMPLETE when receipts exist for:

- `worker-bootstrap-mac-011`
- `direct-bridge-invoke-012`
- `force-execute-bridge-mac-sweeper-010`
- `bridge-mac-complete-sweeper-system-009`

If receipts still do not land, classify as infrastructure failure and emit exact blocker.

## No-go actions

Do not perform without human gate:

- deletes
- IAM edits
- credential rotation
- payment actions
- RLS changes
- deploys to production
- external outreach

Archive is permitted. Delete is not.
