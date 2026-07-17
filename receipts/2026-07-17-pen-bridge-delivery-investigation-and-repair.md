# Pen → Bridge Delivery Investigation and Repair

Date: 2026-07-17
Repository: `TML-4PM/the-pen`
Branch: `main`
Status: PARTIAL

## Questions investigated

1. Is a live Pen worker polling `inbox/*.json`?
2. Did it see the three CalmBound job IDs?
3. Did it claim or move them?
4. Is the Bridge host online?
5. Can the Bridge identity read and write `TML-4PM/the-pen`?
6. Is the configured repository and branch correct?

## Findings

### 1. `inbox/*.json` was not the proven live intake path

The repository contains a GitHub Actions worker for top-level `inbox/*.json`, but it was configured on `ubuntu-latest`. The hosted-runner incident prevented that consumer from starting.

Historical runtime evidence identifies `bridge/intake/` as the live Pen consumer path. The poller `pen_intake_poll_5min` was reported running every five minutes and routing through `ops.fn_route_pen_intake_rows` into the work queue.

### 2. The three CalmBound inbox files were not valid worker requests

`workers/pen_worker.py` required `fn` or `action` plus a payload. The three CalmBound files used governed orchestration fields such as `target`, `execution`, `steps`, and `required_receipts`. A running worker would have rejected them before calling the Bridge.

Affected job IDs:

- `BOOTSTRAP-THE-PEN-SELF-HOSTED-RUNNER-20260717`
- `RECOVER-VERIFY-THE-PEN-SELF-HOSTED-RUNNER-20260717`
- `CALMBOUND-RUNTIME-VALIDATION-20260717`

No claim, move, bridge response, or runtime receipt was found for those jobs.

### 3. Current Bridge health and GitHub write capability remain unproven

The repository has historical evidence of successful Bridge dispatch, but no current receipt proves the Bridge host is online on 2026-07-17, can clone `TML-4PM/the-pen`, or can commit receipts to `main`.

The repaired live-intake task explicitly requires bounded evidence for:

- Bridge status;
- repository read;
- repository write or permission failure;
- runner service and online state;
- named workflow-step execution.

### 4. Repository and branch intent were correct

All three source jobs identify:

- repository: `TML-4PM/the-pen`
- branch: `main`

Host-side configuration is still subject to execution readback.

## Repairs applied

### A. Pen worker envelope normalisation

`workers/pen_worker.py` now converts `target: BRIDGE_RUNNER` orchestration envelopes into:

- bridge function: `organisation_accept`;
- payload containing job identity, objective, steps, receipts, acceptance gates, and the original source envelope;
- stable job-ID idempotency.

Commit: `ab295b01742ae2131d58418e70495d29f6f3280d`

### B. Live-path dispatch

Published an executable recovery item to the proven `bridge/intake/` path:

`bridge/intake/EXECUTE_CALMBOUND_RUNNER_AND_RUNTIME_RECOVERY_2026-07-17.json`

Commit: `dea6bbaa673be14986153fd23c4f26caf2adc64d`

This directs the live poller to verify Bridge health and GitHub identity, bootstrap the self-hosted runner, trigger CalmBound CI, run disposable PostgreSQL validation, and commit receipts.

### C. Pen worker runner dependency

`.github/workflows/pen-worker.yml` now targets:

`[self-hosted, linux, x64, t4h-bridge]`

instead of `ubuntu-latest`.

Commit: `843be777789482026606fb8bebad115f92d6b657`

## Expected evidence

- `receipts/2026-07-17-bridge-delivery-and-identity-check.json`
- `receipts/2026-07-17-the-pen-self-hosted-runner-bootstrap.json`
- `receipts/2026-07-17-the-pen-self-hosted-runner-health.json`
- `commissions/calmbound/runtime/receipts/ci-runtime-receipt.json`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.json`

## Current truth

### REAL

- Root routing mismatch identified.
- Invalid job-envelope mismatch identified.
- Worker normalisation repaired.
- Live `bridge/intake/` dispatch published.
- Pen worker moved away from GitHub-hosted runners.
- Repository/branch intent confirmed in source jobs.

### PARTIAL

- Live poller claim of the new intake item.
- Current Bridge host online state.
- Bridge GitHub read/write capability.
- Self-hosted runner registration.
- CalmBound runtime execution.

### BLOCKED

No further classification can be upgraded until the live dispatcher or Bridge commits a job-linked receipt.
