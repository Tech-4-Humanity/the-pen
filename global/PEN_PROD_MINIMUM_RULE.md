# PEN PROD-MINIMUM RULE

Status: CANONICAL
Effective: 2026-05-04
Owner: TML-4PM

## Rule

Work must not be held in Pen or dev unless there is a hard gate.

The default target for any non-destructive, non-credential, non-payment, non-legal task is **prod-worthy minimum completion**.

Prod-minimum does **not** mean blind promotion.

Prod-minimum means the smallest safe, usable, tested, observable runtime state that is worthy of production.

Pen and dev are transit lanes, not parking bays.

## Meaning

| Lane | Purpose | Allowed dwell |
| --- | --- | --- |
| Pen | Intake, validation, dedupe, classification, routing | Only long enough to route or reject |
| Dev / Symbio | Build, repair, test, package, verify | Only long enough to prove prod-worthiness |
| Prod / Synapse | Minimum usable runtime with test evidence and observability | Default target after validation |
| Archive | Preserve superseded evidence | Never delete by default |

## Mandatory behaviour

1. Any accepted Pen job must be dispatched automatically unless it is blocked by a hard gate.
2. Dev must not accumulate work that has passed tests, validation, and prod-worthiness checks.
3. Dev may hold work only while tests, validation, packaging, or blocker remediation are active.
4. Nothing promotes to prod-minimum without passing the required validation gates.
5. Final state is not ACCEPTED. Final state is REAL, PARTIAL with blocker, BLOCKED with named gate, or FAILED with rollback and next action.
6. Every job must write a final receipt.
7. Counts must exist for Pen, Dev, Prod, Blocked, Failed, Archived.
8. The Command Centre must surface those counts.

## Prod-worthiness gates

A job may only move to PROD_MINIMUM when all applicable gates pass.

| Gate | Required proof |
| --- | --- |
| Build/package | Build completed or deployable artefact produced |
| Tests | Unit/smoke/integration tests relevant to the change pass |
| Validation | Expected output verified against the job objective |
| Idempotency | Safe re-run behaviour defined or proven |
| Observability | Logs, receipt path, runtime status, or health signal exists |
| Evidence binding | REAL/PARTIAL/BLOCKED/FAILED state written with evidence |
| Rollback | Rollback or archive path defined |
| Safety gate | No destructive, payment, credential, legal, or unapproved RLS/IAM action slipped through |

## Hard gates

Only these may hold work:

| Gate | Reason |
| --- | --- |
| Destructive delete | Requires explicit approval |
| RLS/security policy change | Requires dry-run then execute |
| IAM/credentials/secrets | Blocked unless safe scoped method exists |
| Payments/refunds/customer charge | Blocked unless explicitly authorised |
| Legal/compliance representation | Blocked unless reviewed |
| Test failure | Must remain in dev/repair until fixed or marked FAILED/PARTIAL |
| Unknown runtime target | Route to resolver, not idle Pen |

## Required state model

| State | Meaning |
| --- | --- |
| ACCEPTED | Pen has received and validated the job |
| DISPATCHED | Job has been sent to an executor |
| DEV_RUNNING | Build/repair/test is underway |
| DEV_COMPLETE | Build is deployable or packaged, but not yet prod-worthy |
| VALIDATING | Tests, smoke checks, safety checks, or evidence binding are running |
| PROD_MINIMUM | Runtime is live, safe, usable, tested, observable, and evidence-bound |
| REAL | Runtime evidence proves completion |
| PARTIAL | Work ran but final proof is incomplete or some acceptance criteria failed |
| BLOCKED | Named gate prevents execution or promotion |
| FAILED | Execution failed with error, impact, rollback, next |
| ARCHIVED | Superseded or closed without deletion |

## Anti-patterns

| Anti-pattern | Replacement |
| --- | --- |
| Accepted receipt only | Dispatch, execute, validate, final receipt |
| Waiting for user click | Autonomous execution unless hard-gated |
| Blind dev-to-prod promotion | Test-gated prod-minimum promotion |
| Dev as holding bucket | Active build/test/repair only |
| Manual status guessing | State-count file and Command Centre view |
| Evidence-free completion | REAL/PARTIAL/PRETEND binding |

## Operating directive

Do not ask whether to proceed for normal work.
Do not leave safe work in Pen.
Do not leave tested, validated, prod-worthy work in dev.
Do not promote untested or unvalidated work to prod.
Build, test, validate, bind evidence, promote only when prod-worthy, write final receipt, update counts.
