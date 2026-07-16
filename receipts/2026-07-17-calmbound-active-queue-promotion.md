# CalmBound Active Queue Promotion Receipt

Date: 2026-07-17
Repository: `TML-4PM/the-pen`
Status: REAL for queue promotion; PARTIAL for runtime execution

## Action

Promoted the CalmBound isolated runtime validation from passive `bridge_jobs/` storage into the active top-level `inbox/` queue.

## Active job

- `inbox/calmbound-runtime-validation-20260717.json`
- Commit: `c0426d633edb1de75030eefd4b59a53bb7c0ae63`
- Priority: P0
- Target: BRIDGE_RUNNER
- Production resources: false
- HITL: not required

## Required evidence

- `commissions/calmbound/runtime/receipts/ci-runtime-receipt.json`
- `commissions/calmbound/runtime/receipts/server.log`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.json`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.log`

## Truth boundary

Queue promotion is proven by the Git commit. Runtime execution, PostgreSQL migration, API smoke, event-ledger readback and cleanup remain PARTIAL until the required output receipts are committed.
