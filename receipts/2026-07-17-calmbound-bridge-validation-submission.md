# Receipt — CalmBound Bridge Validation Submission

**Date:** 2026-07-17  
**Repository:** `TML-4PM/the-pen`  
**Status:** PARTIAL

## REAL

- GitHub-hosted Actions was bypassed as the sole validation path.
- A bridge-runner execution contract was published.
- The contract uses disposable PostgreSQL 16 and no production credentials.
- Syntax, dependency installation, contract tests, schema application, API health, household creation, owner membership readback, mode activation, event-ledger readback and rollback are explicit gates.
- Machine-readable receipt and command-log paths are mandatory.

## Job

- Path: `bridge_jobs/calmbound_runtime_postgres_validation_20260717.json`
- Commit: `2d44390edca0efcaa0ffb66124e8a65f90d89db8`
- Target: `T4H_BRIDGE_RUNNER`
- Priority: `P0`

## Required result paths

- `commissions/calmbound/runtime/receipts/ci-runtime-receipt.json`
- `commissions/calmbound/runtime/receipts/server.log`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.json`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.log`

## Truth boundary

The job definition and submission are REAL. Runtime execution remains PARTIAL until the bridge publishes the required receipt and logs. No PostgreSQL, API, event-ledger or rollback success is claimed by this submission receipt.

## Recovery

The execution contract may delete only its disposable Docker container and disposable database. Any failure must produce a PARTIAL or FAILED receipt with the failing command, exit code, evidence paths and recovery action.