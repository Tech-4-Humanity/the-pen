# Receipt — CalmBound Reference Runtime Tranche

**Date:** 2026-07-14  
**Repository:** `TML-4PM/the-pen`  
**Branch:** `main`  
**Status:** REAL for source generation and GitHub publication; PARTIAL for execution; BLOCKED for production classification

## Published artefacts

| Artefact | Path | Commit |
|---|---|---|
| Runtime package manifest | `commissions/calmbound/runtime/package.json` | `128ac89c15a957d15feb1cccfd327506271b1191` |
| Runtime core | `commissions/calmbound/runtime/src/runtime.js` | `eb37d9b980ebc185d90c5d66778bb8839df96113` |
| HTTP service | `commissions/calmbound/runtime/src/server.js` | `5f2e7145ae2fcbf0d785ab48584bc81c03e6479b` |
| Migration runner | `commissions/calmbound/runtime/scripts/migrate.js` | `7d65bb766fd955de8807a910b15135f7a02205ed` |
| Contract tests | `commissions/calmbound/runtime/test/runtime.test.js` | `0ef4391a7cf6553f2d6e72f6149499a98e7dc405` |
| Telemetry specification | `commissions/calmbound/runtime/telemetry-v1.0.yaml` | `83eff634ec4315869ff5b1e9f5e9f89370995d47` |
| Threat model | `commissions/calmbound/runtime/threat-model-v1.0.md` | `c4b84c8fb1f7e638f08cccf2ceda4cdd71106058` |
| Operating guide | `commissions/calmbound/runtime/README.md` | `2049316ba1cb3306452f038c2fc41de4278ee068` |

The initial HTTP service commit `9306c84f6632c3f0fa9ce264fed8108c9278435b` was superseded by commit `5f2e7145ae2fcbf0d785ab48584bc81c03e6479b`, which added the missing `node:crypto` import after read-back inspection.

## Scope implemented in source

- Transactional household creation
- Event receipt emission
- Household mode activation
- Contextual authority denial
- Canonical event-envelope persistence
- Event idempotency
- Conflicting-payload drift detection
- Integrity hashing
- Checksum-protected SQL migration runner
- Health endpoint
- Contract tests for receipts, authority denial and event replay
- Telemetry and alert definitions
- Phase 1 threat model and release gates

## Evidence classification

### REAL

- Source artefacts generated
- Source artefacts committed to GitHub `main`
- GitHub returned commit SHAs
- The HTTP service was read back and one identified defect was repaired
- All writes were additive and recoverable by Git revert

### PARTIAL

- Static syntax validation
- Dependency installation
- Test execution
- PostgreSQL migration execution
- OpenAPI conformance validation
- API smoke tests
- Telemetry observation
- Recovery exercise

### BLOCKED for production

Production classification requires verified identity, contextual permissions, database execution, RLS review, secrets management, security tests, privacy and child-impact assessment, deployment telemetry and rollback evidence.

## Recovery

Revert the individual listed commits. The corrected HTTP service commit is canonical; do not restore the superseded version.

## Next execution action

Run this package in an isolated CI or sandbox with disposable PostgreSQL, capture syntax, test, migration, smoke-test, telemetry and rollback receipts, then fix every observed failure before deployment.

## Truth statement

This receipt proves that the reference runtime tranche was generated, inspected, corrected and published. It does not prove that dependencies install, tests pass, migrations execute, or a runtime is live.
