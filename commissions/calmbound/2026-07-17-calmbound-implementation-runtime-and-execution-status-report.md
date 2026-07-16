# CalmBound — Implementation, Runtime and Execution Status Report

**Date:** 2026-07-17  
**Repository:** `TML-4PM/the-pen`  
**Branch:** `main`  
**Overall classification:** PARTIAL  
**Strategic package:** REAL  
**Implementation artefacts:** REAL  
**Reference runtime source:** REAL  
**Local source validation:** REAL  
**PostgreSQL/API execution:** PARTIAL  
**Production readiness:** BLOCKED

---

## 1. Executive summary

CalmBound has progressed from a strategy and product concept into a published implementation package with machine-readable architecture, a reference runtime, tests, telemetry and threat-model artefacts, CI definitions, a reusable zero-step Actions classification standard, an organisation-wide Actions audit utility, and a bridge-runner fallback path.

The remaining gap is no longer specification or source generation. The remaining gap is execution evidence for PostgreSQL migrations, API smoke testing, event-ledger readback, rollback, telemetry and deployment.

GitHub Actions did not provide usable execution evidence. The affected CalmBound jobs were created but did not receive a runner or start their first workflow step. This is classified as `ZERO_STEP_RUNNER_START_FAILURE`, not a code, test, dependency, database, deployment or application failure.

To avoid waiting on GitHub-hosted Actions, the validation workload was rerouted into the existing bridge-runner operating path and promoted into the active top-level inbox queue.

No production resources have been touched.

---

## 2. Canonical product and platform position

### Category

Household Coordination Infrastructure.

### Product

CalmBound.

### Acquisition wedge

Kids Visit Mode.

### Product kernel

`Person + Role + Space + Mode + Agreement + Permission + Signal + Evidence`

### Consumer promise

> Fewer reminders. Clearer expectations. Calmer homes.

### North-star metric

Meaningful household transitions coordinated per active household per week.

### Governance posture

- child rights and privacy by design;
- no surveillance by default;
- no child scoring;
- contextual authority rather than blanket authority;
- explicit consent receipts;
- recoverable and inspectable decisions;
- no silent escalation from consumer convenience into behavioural monitoring.

---

## 3. Published strategic foundation

The canonical strategic package was compiled, wrapped and published with additive, revertible commits.

Published components:

- Canonical Platform Specification v1.0
- Package README
- Implementation Manifest
- Source Disposition Register
- Phase 1 Execution Backlog
- Publication Receipt

Key commits:

| Artefact | Commit |
|---|---|
| Canonical specification | `a30c7ecd77d38fdd6aa2713fa310b249b68c2386` |
| Canonical specification receipt | `6d86de6ad960a697d556dd6e49d896ae95df48db` |
| Package README | `c914561d54e199404aa0e15c7ce4ecfd81f872a8` |
| Implementation manifest | `b4efe189d276b210697fe4775affad4843b71dc6` |
| Source disposition register | `d4f02a5fc7f8b4f5d12a5afdfbe804850a1458d9` |
| Phase 1 backlog | `c85e22a9a6335ebb059dc58d1946b5285be7453d` |
| Compile/wrap/post receipt | `8f11911e56a5646c9b78adadad8720d06f5cc09c` |

Classification: **REAL for strategy, packaging and publication.**

---

## 4. Published implementation artefacts

The missing implementation artefacts were subsequently generated and published.

Published components:

- Capability Registry v1.0
- Household Ontology v1.0
- Event Taxonomy and Canonical Event Envelope v1.0
- Permission and Consent Model v1.0
- Rule Engine and Household Mode Registry v1.0
- OpenAPI Contract v1.0
- Canonical PostgreSQL/Supabase Schema v1.0
- Validation and Acceptance Specification v1.0

Commits:

| Artefact | Commit |
|---|---|
| Capability Registry | `0c983a8238362ee98e81420859f2261e0450faf9` |
| Household Ontology | `8204c0e0f498f4ed4674a651c5b221c62cc85e72` |
| Event Taxonomy | `93a82502dc39d39c7cd0aa1edb025c0fab65a362` |
| Permission and Consent | `f5d3ebdd60ca749114189355b9d9abbef8b8b372` |
| Rule Engine and Modes | `149bc8f1b6141707be16e0dc2db86372acdc838f` |
| OpenAPI | `f6482a92fb7bf4698a909909a214fbb5ac30c679` |
| Database schema | `ba9d50d44c45236991d0e8bfb08294892a0e62a8` |
| Validation and Acceptance | `4cbbf2a2d79e90b8428965e55b1bcf84b0cc9d2e` |
| Implementation publication receipt | `39f0b73a5e740386ce3eddb7875e25553f59777c` |

Classification: **REAL for source generation and publication.**

---

## 5. Published reference runtime tranche

A reference runtime package was generated and published.

Published components:

- Runtime package manifest
- Transactional household runtime core
- HTTP service
- Checksum-protected migration runner
- Contract tests
- Telemetry specification
- Phase 1 threat model
- Runtime operating guide

Commits:

| Artefact | Commit |
|---|---|
| Package manifest | `128ac89c15a957d15feb1cccfd327506271b1191` |
| Runtime core | `eb37d9b980ebc185d90c5d66778bb8839df96113` |
| Corrected HTTP service | `5f2e7145ae2fcbf0d785ab48584bc81c03e6479b` |
| Migration runner | `7d65bb766fd955de8807a910b15135f7a02205ed` |
| Contract tests | `0ef4391a7cf6553f2d6e72f6149499a98e7dc405` |
| Telemetry specification | `83eff634ec4315869ff5b1e9f5e9f89370995d47` |
| Threat model | `c4b84c8fb1f7e638f08cccf2ceda4cdd71106058` |
| Operating guide | `2049316ba1cb3306452f038c2fc41de4278ee068` |
| Runtime tranche receipt | `826c7efb3bd3f998c13b3290527d373182081cd5` |

A source readback identified a missing `node:crypto` import in the HTTP service. The defect was corrected before the final tranche receipt.

Classification: **REAL for runtime source, package and corrective publication.**

---

## 6. Runtime correction and local validation

Source review identified a second concrete runtime defect: household creation set the owner identifier but did not create the owner membership required by the permission engine.

The defect was corrected transactionally and the tests were expanded.

Commits:

| Change | Commit |
|---|---|
| Transactional owner membership | `2faadc2d62243436862affd3affd154c17eed4d4` |
| Owner membership contract test | `7f769757677e8ec39343d9b318c47f3c26735ef9` |
| PostgreSQL/API/rollback smoke harness | `e114c1dbd396bf12d4512c0fc7eb45cdbdeb4dec` |
| Split source and PostgreSQL CI workflow | `23ea237ccb4173b055e74c6c1dc8d5d9d4bbbbf8` |
| Validation progress receipt | `7ebbaf5a62e6dd1cfaa5a4048a0aa16049495316` |

Observed local validation:

- `node --check src/runtime.js` — PASS
- `node --test test/*.test.js` — PASS
- Tests: 3
- Passed: 3
- Failed: 0

The tests prove:

1. Household creation emits an event receipt and creates owner membership.
2. Unauthorised mode activation is denied.
3. Event ingestion is idempotent and detects payload drift.

Classification: **REAL for local syntax validation and three contract tests.**

---

## 7. GitHub Actions incident

### Affected PR

PR `#231` — Validate CalmBound reference runtime in isolated PostgreSQL CI.

### Recorded runs

- `29266981601`
- `29267054505`
- `29267235197`

### Correct classification

`ZERO_STEP_RUNNER_START_FAILURE`

Canonical wording:

> GitHub created the job record but did not allocate a runner or start the first workflow step. No workflow, dependency, test, deployment, credential, database or application failure was observed.

The earlier phrase that both jobs “failed with zero exposed execution steps” was withdrawn because it incorrectly implied execution had started.

### Distinct condition

`ZERO_STEP_JOB_SKIPPED`

Canonical wording:

> GitHub evaluated the job-level condition and did not materialise workflow steps. This is a skipped-job/materialisation condition, not a runner-start failure.

These two conditions must not be conflated.

### Existing historical evidence

`issues/OPS-RUNNER-001-actions-runner-not-allocated.md` records multiple `the-pen` workflows with:

- run and job records created;
- no runner assigned;
- `steps=[]`;
- rapid terminal failure;
- no log blob;
- `BlobNotFound` on log retrieval.

Dominant unresolved causes remain:

- Actions disabled at organisation or repository level;
- Actions minutes exhausted;
- spending limit reached;
- hosted runner restricted or unavailable;
- approval or policy restriction.

Classification: **REAL for the observed zero-step runner-start incident.**

---

## 8. Organisation-wide Actions controls

Published controls:

### Classification standard

`ops/github-actions/zero-step-classification-standard-v1.md`

Commit:

`73e5b8a28740a4b5be8e3d7e5b0136d8cb4e3fd3`

### Organisation-wide auditor

`ops/github-actions/audit_zero_step_actions.py`

Commit:

`3cc3f93b8f45526befa96016e3445a2bc05f3b96`

### Diagnostic script

`ops/github-actions/diagnose_and_repair_actions_estate.sh`

Commit:

`3d45a881bbf5f7660e3d80506475385cfeb6cc53`

### Remediation runbook

`ops/github-actions/actions-estate-remediation-runbook-v1.md`

Commit:

`b5faa39cff0c7cfa59d3db7d2fb6c894c789dc83`

### Corrective supersession receipt

`receipts/2026-07-14-calmbound-runtime-validation-wording-supersession.md`

Commit:

`c62c46813fa69e7cb21a98b3459222af59e01618`

### Enforcement issues

- Issue `#232` — Restore GitHub Actions runner allocation and audit zero-step jobs across TML-4PM
- Issue `#236` — Apply zero-step classification standard to all future Actions incidents

The org-wide repository and workflow census is published, but a complete run-history audit across every repository has not yet executed because the current environment lacks an authenticated GitHub CLI and the connector does not expose an all-repository Actions run census in one call.

Classification: **REAL for terminology, audit tooling, runbook and enforcement publication. PARTIAL for full estate run-history execution.**

---

## 9. Clean runner-allocation probe

A minimal runner probe was published to isolate GitHub runner allocation from all application concerns.

Workflow:

`.github/workflows/runner-allocation-probe.yml`

Commit:

`52bcd1ccba37ac410c5207a4699ed8557c9a20fb`

Properties:

- one unconditional `ubuntu-latest` job;
- one unconditional shell step;
- no checkout;
- no dependencies;
- no secrets;
- no PostgreSQL;
- no application code;
- no deployment logic.

Progress receipt:

`receipts/2026-07-17-runner-allocation-probe-progress.md`

Commit:

`b93daed19cf7e907c0d5550f7f98653051b8f6d9`

GitHub accepted a rerun request for CalmBound run `29267235197`, but subsequent workflow-run, job and commit-status reads returned repeated upstream HTTP 502 errors.

Therefore the probe result remains **unobserved**, not passed or failed.

Classification: **REAL for probe publication and rerun request. PARTIAL for observation.**

---

## 10. Bridge-runner fallback path

GitHub-hosted Actions was removed as a single point of execution dependency.

### Passive bridge execution contract

`bridge_jobs/calmbound_runtime_postgres_validation_20260717.json`

Commit:

`2d44390edca0efcaa0ffb66124e8a65f90d89db8`

### Bridge submission receipt

`receipts/2026-07-17-calmbound-bridge-validation-submission.md`

Commit:

`30b6a278335d91605cf8d57e7fa738a92ca3c8a6`

### Active inbox promotion

`inbox/calmbound-runtime-validation-20260717.json`

Commit:

`c0426d633edb1de75030eefd4b59a53bb7c0ae63`

### Promotion receipt

`receipts/2026-07-17-calmbound-active-queue-promotion.md`

Commit:

`c25222e3804b1c1e10af6f72fee6e2539390fa0b`

The active job is configured as:

- priority P0;
- no HITL;
- target `BRIDGE_RUNNER`;
- isolated PostgreSQL only;
- no production resources;
- mandatory receipt and log publication.

Required execution outputs:

- `commissions/calmbound/runtime/receipts/ci-runtime-receipt.json`
- `commissions/calmbound/runtime/receipts/server.log`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.json`
- `receipts/2026-07-17-calmbound-bridge-postgres-validation.log`

Classification: **REAL for queue submission and promotion. PARTIAL until runtime receipts appear.**

---

## 11. What is proven

### REAL

- product and platform strategy;
- canonical specification;
- implementation manifest and backlog;
- capability registry;
- household ontology;
- event taxonomy and envelope;
- permission and consent model;
- rule grammar and mode registry;
- OpenAPI contract;
- canonical PostgreSQL/Supabase schema;
- validation and acceptance specification;
- reference runtime source;
- HTTP service correction;
- migration runner source;
- contract test source;
- telemetry specification;
- threat model;
- operating guide;
- transactional owner membership correction;
- local syntax validation;
- three passing contract tests;
- smoke and rollback harness source;
- zero-step incident classification;
- organisation-wide audit tooling;
- remediation runbook;
- minimal runner probe publication;
- bridge-runner validation contract;
- active inbox promotion.

---

## 12. What remains unproven

### PARTIAL / BLOCKED

- dependency installation in an independent runtime;
- PostgreSQL 16 startup;
- schema execution;
- migration checksum readback;
- API health endpoint;
- household creation through the HTTP service;
- PostgreSQL owner membership readback;
- mode activation against PostgreSQL;
- event-ledger readback;
- OpenAPI lint in the execution environment;
- rollback exercise;
- database cleanup verification;
- uploaded CI artefact;
- runtime telemetry export;
- identity integration;
- row-level security enforcement;
- secrets handling;
- child-impact review;
- privacy review;
- deployment;
- production smoke testing;
- recovery and rollback in a deployed environment.

No production readiness claim is made.

---

## 13. Current truth table

| Domain | State | Evidence |
|---|---|---|
| Strategy | REAL | Canonical specification and receipts |
| Implementation artefacts | REAL | Published machine-readable contracts |
| Runtime source | REAL | Published reference runtime package |
| Source correction | REAL | Crypto import and owner membership fixes |
| Local tests | REAL | 3 passed, 0 failed |
| GitHub Actions runner | BLOCKED | Zero-step runner-start evidence |
| GitHub Actions API observation | BLOCKED | Repeated upstream 502 responses |
| Org-wide audit tooling | REAL | Published scripts and standard |
| Org-wide run-history census | PARTIAL | Requires authenticated execution environment |
| Bridge validation job | REAL | Passive and active queue artefacts published |
| Bridge execution | PARTIAL | No execution receipt yet |
| PostgreSQL validation | PARTIAL | Pending runtime receipt |
| API smoke validation | PARTIAL | Pending runtime receipt |
| Rollback validation | PARTIAL | Pending runtime receipt |
| Production | BLOCKED | Execution and governance gates incomplete |

---

## 14. Immediate next execution gate

The next legitimate state change is not another specification or planning document.

The next legitimate state change is an execution receipt from the active bridge job proving or disproving:

1. dependency installation;
2. syntax and contract tests;
3. PostgreSQL startup;
4. schema and migration execution;
5. API health;
6. household creation;
7. owner membership readback;
8. mode activation;
9. event receipt readback;
10. OpenAPI lint;
11. rollback;
12. database cleanup.

Any observed failure must be repaired and rerun before the relevant gate is upgraded to REAL.

---

## 15. Recovery and change safety

- All changes are additive and individually revertible.
- No production database is targeted.
- No production deployment is authorised by the current queue job.
- Disposable PostgreSQL is mandatory for validation.
- Git history preserves all package, runtime, test, workflow, incident and receipt changes.
- A failed validation run must emit a receipt and log rather than silently disappearing.

---

## 16. Final statement

CalmBound is no longer only a concept, microsite or strategy pack. It now has a canonical platform model, implementation contracts, reference runtime, tests, telemetry and governance artefacts, a corrected runtime core, an execution harness, an incident classification standard, and two independent validation routes.

The project remains **PARTIAL**, not because the design or implementation package is missing, but because PostgreSQL, API, rollback and deployment evidence has not yet been produced by an executable environment.

The next valid outcome is a receipted bridge execution result.
