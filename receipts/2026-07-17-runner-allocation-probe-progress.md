# Receipt — GitHub Actions Runner Allocation Probe Progress

**Date:** 2026-07-17  
**Repository:** `TML-4PM/the-pen`  
**Status:** PARTIAL

## REAL

- A minimal repository-level GitHub Actions probe was published at `.github/workflows/runner-allocation-probe.yml`.
- The probe contains one unconditional job and one unconditional shell step.
- The probe triggers on changes to its own workflow file and through `workflow_dispatch`.
- Commit: `52bcd1ccba37ac410c5207a4699ed8557c9a20fb`.
- A rerun request for CalmBound run `29267235197` was accepted by GitHub.

## Probe purpose

The probe isolates runner allocation from application code, dependencies, PostgreSQL, credentials, and deployment logic.

Expected successful evidence:

- runner allocated;
- step `Runner allocated` starts;
- output includes `classification=RUNNER_ALLOCATED`.

Expected zero-step evidence:

- job record created;
- runner absent;
- step count zero;
- no usable log blob.

That outcome must be classified as `ZERO_STEP_RUNNER_START_FAILURE`, not as a workflow, test, code, dependency, database, or application failure.

## Current observation block

After publishing the probe, GitHub connector requests for workflow jobs, commit-associated workflow runs, commit combined status, and commit readback returned upstream HTTP 502 errors.

Therefore no claim is made that the probe passed or failed. The commit publication receipt is available, but the Actions execution result is currently unobserved.

## Current classification

- Probe publication: REAL
- Rerun request accepted: REAL
- Runner allocation result: PARTIAL / UNOBSERVED
- Actions run/status API availability: BLOCKED by upstream 502 responses

## Next evidence gate

Read the probe run and job metadata when GitHub Actions endpoints recover. Record runner name, step count, conclusion, and log availability. Only then classify the execution result.
