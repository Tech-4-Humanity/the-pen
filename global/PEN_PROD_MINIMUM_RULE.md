# PEN PROD-MINIMUM RULE

Status: CANONICAL
Effective: 2026-05-04
Owner: TML-4PM

## Rule

Work must not be held in Pen or dev unless there is a hard gate.

The default destination for any non-destructive, non-credential, non-payment, non-legal task is prod-minimum completion.

Pen and dev are transit lanes, not parking bays.

## Meaning

| Lane | Purpose | Allowed dwell |
| --- | --- | --- |
| Pen | Intake, validation, dedupe, classification, routing | Only long enough to route or reject |
| Dev / Symbio | Build, repair, test, package | Only long enough to prove deployability |
| Prod / Synapse | Minimum usable runtime with evidence | Default target |
| Archive | Preserve superseded evidence | Never delete by default |

## Mandatory behaviour

1. Any accepted Pen job must be dispatched automatically unless it is blocked by a hard gate.
2. Dev must not accumulate work that can safely go to prod-minimum.
3. Final state is not ACCEPTED. Final state is REAL, PARTIAL with blocker, or BLOCKED with named gate.
4. Every job must write a final receipt.
5. Counts must exist for Pen, Dev, Prod, Blocked, Failed, Archived.
6. The Command Centre must surface those counts.

## Hard gates

Only these may hold work:

| Gate | Reason |
| --- | --- |
| Destructive delete | Requires explicit approval |
| RLS/security policy change | Requires dry-run then execute |
| IAM/credentials/secrets | Blocked unless safe scoped method exists |
| Payments/refunds/customer charge | Blocked unless explicitly authorised |
| Legal/compliance representation | Blocked unless reviewed |
| Unknown runtime target | Route to resolver, not idle Pen |

## Required state model

| State | Meaning |
| --- | --- |
| ACCEPTED | Pen has received and validated the job |
| DISPATCHED | Job has been sent to an executor |
| DEV_RUNNING | Build/repair/test is underway |
| DEV_COMPLETE | Build is deployable or packaged |
| PROD_MINIMUM | Runtime is live or minimally usable |
| REAL | Runtime evidence proves completion |
| PARTIAL | Work ran but final proof is incomplete |
| BLOCKED | Named gate prevents execution |
| FAILED | Execution failed with error, impact, rollback, next |
| ARCHIVED | Superseded or closed without deletion |

## Anti-patterns

| Anti-pattern | Replacement |
| --- | --- |
| Accepted receipt only | Dispatch and final receipt |
| Waiting for user click | Autonomous execution unless hard-gated |
| Dev as holding bucket | Prod-minimum promotion |
| Manual status guessing | State-count file and Command Centre view |
| Evidence-free completion | REAL/PARTIAL/PRETEND binding |

## Operating directive

Do not ask whether to proceed for normal work.
Do not leave safe work in Pen.
Do not leave deployable work in dev.
Push to prod-minimum, bind evidence, write final receipt, update counts.
