# CalmBound Self-Hosted Runner Execution Handoff

**Date:** 2026-07-17  
**Repository:** `TML-4PM/the-pen`  
**Branch:** `main`  
**Status:** PARTIAL — implementation complete; runtime receipts pending

## Objective

Restore executable CI for CalmBound without relying on GitHub-hosted runner allocation.

The chosen alternative is a repository-level self-hosted GitHub Actions runner on the existing bridge host, labelled:

```text
self-hosted
linux
x64
t4h-bridge
```

## Completed work

### Runner implementation

- Bootstrap script: `ops/github-actions/bootstrap_t4h_bridge_runner.sh`
- Bootstrap queue job: `inbox/bootstrap-the-pen-self-hosted-runner-20260717.json`
- Recovery queue job: `inbox/recover-and-verify-the-pen-self-hosted-runner-20260717.json`

### Workflow rerouting

`.github/workflows/calmbound-runtime-ci.yml` now targets:

```yaml
runs-on: [self-hosted, linux, x64, t4h-bridge]
```

The workflow is restricted to trusted `main` pushes and manual dispatch. Pull-request code is not executed on the persistent bridge host.

### Validation queue

- Active runtime validation job: `inbox/calmbound-runtime-validation-20260717.json`
- Passive bridge contract: `bridge_jobs/calmbound_runtime_postgres_validation_20260717.json`

## Required execution chain

```text
Bridge host refreshed
  -> runner installed or existing installation detected
  -> actions.runner service active
  -> runner visible online in GitHub
  -> runner labels confirmed
  -> CalmBound workflow dispatched
  -> first named workflow step starts
  -> source syntax validation executes
  -> contract tests execute
  -> disposable PostgreSQL starts
  -> schema applies
  -> API smoke path executes
  -> event and owner-membership readback succeeds
  -> rollback executes
  -> receipts and logs are committed
```

## Required receipts

The workstream may advance only when execution produces the applicable evidence files:

- `receipts/2026-07-17-the-pen-self-hosted-runner-bootstrap.json`
- `receipts/2026-07-17-the-pen-self-hosted-runner-bootstrap.log`
- `receipts/2026-07-17-the-pen-self-hosted-runner-recovery.json`
- `receipts/2026-07-17-the-pen-self-hosted-runner-recovery.log`
- `commissions/calmbound/runtime/receipts/ci-runtime-receipt.json`
- `commissions/calmbound/runtime/receipts/server.log`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.json`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.log`

## Failure classifications

| Observed condition | Classification |
|---|---|
| Runner registration absent | `SELF_HOSTED_RUNNER_REGISTRATION_BLOCK` |
| Runner service inactive | `SELF_HOSTED_RUNNER_SERVICE_FAILURE` |
| Registered runner offline | `SELF_HOSTED_RUNNER_CONNECTIVITY_FAILURE` |
| Workflow remains queued with runner online | `SELF_HOSTED_RUNNER_LABEL_OR_QUEUE_MISMATCH` |
| Named workflow step starts and fails | `WORKFLOW_STEP_FAILURE` |
| PostgreSQL step starts and fails | `POSTGRES_VALIDATION_FAILURE` |
| API step starts and fails | `API_SMOKE_FAILURE` |
| Rollback step starts and fails | `ROLLBACK_VALIDATION_FAILURE` |

No code, test, database, deployment, credential or application failure may be inferred before a named workflow step begins.

## Current truth

| Area | State |
|---|---|
| CalmBound strategy and specifications | REAL |
| Implementation artefacts | REAL |
| Reference runtime source | REAL |
| Local syntax validation | REAL |
| Local contract tests | REAL — 3 passed, 0 failed |
| GitHub hosted-runner dependency | REMOVED |
| Self-hosted runner design | REAL |
| Bootstrap implementation | REAL |
| Recovery implementation | REAL |
| Workflow rerouting | REAL |
| Active bridge/inbox jobs | REAL |
| Runner registered and online | PARTIAL — receipt absent |
| First named workflow step | PARTIAL — receipt absent |
| PostgreSQL/API/rollback validation | PARTIAL — receipt absent |
| Production readiness | BLOCKED |

## Evidence rule

This handoff proves design, implementation, publication and queueing. It does not prove that the bridge host has registered the runner, that GitHub reports it online, or that any CI step has executed.

The next legitimate state change must be based on a committed runtime receipt, not elapsed time or assumed bridge activity.
