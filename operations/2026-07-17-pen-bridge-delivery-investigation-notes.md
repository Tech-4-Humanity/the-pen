# Pen → Bridge Delivery Investigation Notes

**Date:** 2026-07-17  
**Repository:** `TML-4PM/the-pen`  
**Branch:** `main`  
**Status:** PARTIAL — routing defects repaired; live execution evidence still pending

## Purpose

Record the investigation into why CalmBound execution jobs did not produce receipts, identify the broken links, document the repairs, and define the exact evidence required before the execution path is classified REAL.

## What was originally posted

The CalmBound work created three governed execution envelopes:

- `inbox/calmbound-runtime-validation-20260717.json`
- `inbox/bootstrap-the-pen-self-hosted-runner-20260717.json`
- `inbox/recover-and-verify-the-pen-self-hosted-runner-20260717.json`

These files targeted `BRIDGE_RUNNER`, referenced repository `TML-4PM/the-pen`, branch `main`, and declared required runtime receipts.

## Root cause 1 — wrong execution surface

The proven live Pen consumer historically polls:

- `bridge/intake/`

The three CalmBound jobs were posted to:

- `inbox/`

Top-level `inbox/*.json` depends on `.github/workflows/pen-worker.yml`. That workflow had been routed through GitHub-hosted Actions and was unable to start because no runner was allocated.

Therefore the jobs were present in GitHub but not proven delivered to the live Bridge dispatcher.

## Root cause 2 — invalid worker job schema

`workers/pen_worker.py` originally required either:

```json
{
  "fn": "...",
  "payload": {}
}
```

or an `action` field.

The CalmBound envelopes instead contained governed orchestration fields such as:

- `job_id`
- `target`
- `repository`
- `branch`
- `objective`
- `steps` or `execution`
- `required_receipts`
- `acceptance`

An executing worker would therefore have rejected the jobs before calling the Bridge with `ERROR: no fn or action in job`.

## Root cause 3 — consumer depended on the failed hosted-runner path

`.github/workflows/pen-worker.yml` used `ubuntu-latest`.

This was the same hosted-runner allocation path that produced job records without allocating a runner or starting the first step. Therefore even valid top-level inbox jobs had no reliable consumer.

## Repairs applied

### Worker envelope normalisation

`workers/pen_worker.py` now recognises governed envelopes where:

```json
"target": "BRIDGE_RUNNER"
```

It normalises them into a Bridge invocation using:

- function: `organisation_accept`
- stable idempotency key: original `job_id`
- payload: original governed envelope plus source metadata

Commit:

- `ab295b01742ae2131d58418e70495d29f6f3280d`

### Live intake submission

A new executable recovery and validation item was placed into the proven live intake path:

- `bridge/intake/EXECUTE_CALMBOUND_RUNNER_AND_RUNTIME_RECOVERY_2026-07-17.json`

Commit:

- `dea6bbaa673be14986153fd23c4f26caf2adc64d`

This item requires the dispatcher to verify:

1. current Bridge health;
2. repository read access;
3. repository receipt-write access;
4. configured repository and branch;
5. self-hosted runner registration;
6. self-hosted runner service state;
7. runner visibility and labels;
8. named workflow-step execution;
9. CalmBound PostgreSQL, API, ledger, cleanup, and rollback validation.

### Pen worker rerouted to self-hosted execution

`.github/workflows/pen-worker.yml` now uses:

```yaml
runs-on: [self-hosted, linux, x64, t4h-bridge]
```

Commit:

- `843be777789482026606fb8bebad115f92d6b657`

This removes the broken GitHub-hosted runner dependency from future top-level inbox processing.

### Existing investigation receipt

- `receipts/2026-07-17-pen-bridge-delivery-investigation-and-repair.md`
- commit `171cfb1651d87fb8ac4dd6b9506a25ed28ea6a33`

## Chase results

| Question | Finding |
|---|---|
| Is a live worker polling `inbox/*.json`? | Not proven. The Actions-based consumer could not start. |
| Did it see the three CalmBound job IDs? | No claim, move, response, or receipt evidence found. |
| Did it claim or move them? | No. The files remained source artefacts. |
| Is the Bridge host online now? | Historical operation is evidenced; current health is not yet proven. |
| Can the Bridge clone and commit receipts? | Not yet proven; now an explicit execution gate. |
| Is repository/branch correct? | Job intent is `TML-4PM/the-pen` on `main`; host-side configured readback remains pending. |

## Required receipts

The execution path must publish bounded evidence to these or equivalent canonical paths:

- `receipts/2026-07-17-bridge-delivery-and-identity-check.json`
- `receipts/2026-07-17-the-pen-self-hosted-runner-bootstrap.json`
- `receipts/2026-07-17-the-pen-self-hosted-runner-health.json`
- `receipts/2026-07-17-the-pen-self-hosted-runner-recovery.json`
- `commissions/calmbound/runtime/receipts/ci-runtime-receipt.json`
- `commissions/calmbound/runtime/receipts/server.log`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.json`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.log`

A permission or connectivity failure must also produce a receipt rather than remain silent.

## Classification rules

- No receipt = not REAL.
- A file in `inbox/` or `bridge/intake/` proves publication, not execution.
- A job is claimed only when claim identity and timestamp are recorded.
- A Bridge call is proven only by request/response evidence or a bounded failure receipt.
- A runner is REAL only when GitHub reports it online and a named step starts.
- CalmBound runtime validation is REAL only after PostgreSQL migration, API smoke, ledger readback, cleanup, rollback, and receipts execute.

## Current truth

### REAL

- Wrong queue identified.
- Worker schema mismatch identified.
- Worker envelope normalisation implemented.
- Live intake item published.
- Pen worker moved to `t4h-bridge`.
- Repository and branch intent are explicit.
- Investigation and repair evidence is committed.

### PARTIAL

- Live intake poller claim of the new item.
- Current Bridge health.
- Bridge GitHub read/write identity.
- Host repository and branch configuration readback.
- Self-hosted runner registration and online state.
- Named workflow-step execution.
- CalmBound PostgreSQL/API/rollback validation.

### BLOCKED

- Production readiness until all runtime, security, recovery, telemetry, and evidence gates pass.

## Next valid state change

The next upgrade must be based on an actual committed receipt showing one of:

1. intake item claimed and routed;
2. Bridge unavailable or permission failure with bounded evidence;
3. runner registered and online;
4. named workflow step started;
5. runtime validation completed or failed at a named step.

Until that occurs, status remains PARTIAL rather than assumed successful.