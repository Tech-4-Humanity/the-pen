# Receipt — CalmBound Runtime Validation Progress

**Date:** 2026-07-14  
**Repository:** `TML-4PM/the-pen`  
**Branch:** `main`  
**Status:** PARTIAL

## REAL

- Isolated CI workflow authored and published.
- PostgreSQL/API/rollback smoke harness authored and published.
- Runtime source reviewed.
- Missing transactional owner membership identified and corrected.
- Test harness updated to prove owner membership creation.
- Node syntax validation executed successfully in isolated local sandbox.
- Node test suite executed successfully in isolated local sandbox: 3 passed, 0 failed.
- Runtime, test, CI and smoke changes committed to `main`.

## Main commits

| Change | Commit |
|---|---|
| Transactional owner membership | `2faadc2d62243436862affd3affd154c17eed4d4` |
| Owner membership contract test | `7f769757677e8ec39343d9b318c47f3c26735ef9` |
| PostgreSQL/API/rollback smoke harness | `e114c1dbd396bf12d4512c0fc7eb45cdbdeb4dec` |
| Split source and PostgreSQL CI workflow | `23ea237ccb4173b055e74c6c1dc8d5d9d4bbbbf8` |

## GitHub Actions evidence

PR `#231` was created to execute the isolated workflow. Three workflow attempts were recorded:

- Run `29266981601` — failure before usable steps/logs.
- Run `29267054505` — failure before usable steps/logs.
- Run `29267235197` — both split jobs failed with zero exposed execution steps.

This pattern is classified as an Actions environment/account runner block, not a runtime test result. Job-log retrieval returned `BlobNotFound`; no code failure is inferred from missing logs.

The repository commit status also reports unrelated Vercel account deployment blocks.

## Local execution receipt

Executed with Node.js v22.16.0:

- `node --check src/runtime.js` — PASS
- `node --test test/*.test.js` — PASS
- Tests: 3
- Passed: 3
- Failed: 0

Covered:

1. Household creation emits an event receipt and creates the owner membership.
2. Unauthorised mode activation is denied.
3. Event ingestion is idempotent and detects payload drift.

## PARTIAL / BLOCKED

Not yet observed:

- Dependency installation through GitHub Actions.
- PostgreSQL schema execution.
- API health and smoke execution.
- Owner membership readback from PostgreSQL.
- Mode activation against PostgreSQL.
- Event ledger readback.
- OpenAPI lint execution.
- Rollback exercise.
- Uploaded CI receipt artifact.

Local PostgreSQL installation was attempted but the sandbox package network was unavailable, so database execution remains unproven.

## Recovery

All changes are additive and individually revertible. The CI rollback exercise targets disposable PostgreSQL only and is not configured against production.

## Next action

Restore or reroute an executable CI runner with PostgreSQL, run `.github/workflows/calmbound-runtime-ci.yml`, capture the JSON artifact, and repair any observed runtime or schema failure before deployment.

## Truth statement

This receipt proves source correction, source publication, local syntax validation and three passing contract tests. It does not prove PostgreSQL execution, API smoke success, telemetry, rollback, deployment or production readiness.
