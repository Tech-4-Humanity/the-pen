# Worker Runtime v3 Enforcement Matrix

This document maps constitutional laws to executable controls. A law without a passing control remains ASPIRATIONAL.

| Law | Runtime control | Required evidence | Failure action |
|---|---|---|---|
| Valid job | JSON schema rejects missing outcome, predicates, authority, budget or receipt destination | validation result, job hash | quarantine invalid job |
| Event-driven arrival | issue/webhook/object/queue event invokes Intake immediately | event ID, workflow/run/trace ID, STARTED timestamp | watchdog investigation |
| STARTED receipt | first durable action records lease and worker identity | receipt path/hash, lease ID | requeue and repair receipt path |
| Single logical owner | atomic time-bounded lease | owner ID, lease expiry, heartbeat | expire lease and requeue |
| Outcome verification | predicate runs against live state | query/API/readback result | investigate and continue loop |
| Changed retry | retry record differs in method/input/provider/environment/etc. | retry diff, attempt ID | reject identical retry as stalled |
| Root-cause investigation | hypothesis, supporting proof and alternative disproof required | evidence bundle | investigation remains PARTIAL |
| Repair verification | repair must replay original job and run regression | commit/config diff, replay result | rollback or continue repair |
| Authority escalation | structured authority-gap predicate validates all conditions | denial logs, exact capability, workaround evidence | reject escalation and continue |
| Receipt truth | receipt schema plus independent predicate verification | receipt hash, verification readback | mark receipt invalid |
| Ledger write | append-only ledger acknowledges accepted state transition | ledger ID/hash | job remains non-terminal |
| No silent failure | wrapper/finalizer writes local durable failure evidence on every exit | exit code, local receipt, publish retry state | watchdog republishes/requeues |
| Partial auto-loop | non-terminal state automatically queues continuation | parent/child linkage, next action | mark scheduler defect |
| Dead-letter recovery | failed delivery enters governed dead-letter queue | DLQ record, retry count | Repair Worker claims DLQ item |
| Replay | original immutable inputs can be rerun | input hashes, replay command, output comparison | mark unreplayable and investigate |
| Economic boundary | explicit budget is debited per iteration | cost ledger, remaining budget | choose cheaper route or evidence block |
| Preemption | resumable checkpoint written before lease release | checkpoint hash, handoff receipt | reject preemption |
| Deduplication | stable job fingerprint coalesces equivalent outcomes | fingerprint and canonical parent | link duplicate to parent |
| BLOCKED expiry | blocker evidence has freshness/expiry | checked-at timestamp, policy/permission readback | requeue when stale |
| Regression permanence | every repaired incident creates automated test | test path, run result | repair cannot be REAL |
| Canonical #255 test | Issue #255 produces Intake, execution and final readback without chat | issue comment, inbox job, receipts, ledger | P0 runtime repair loop |

## Minimum automated test suite

1. Reject a job without a success predicate as ASPIRATIONAL.
2. Accept an issue event and emit STARTED evidence.
3. Expire a worker lease and allow a replacement worker to resume.
4. Reject an identical retry with no new evidence.
5. Reject BLOCKED without external denial proof.
6. Reject COMPLETE when live predicate fails.
7. Reject COMPLETE without ledger confirmation.
8. Simulate worker death and prove local receipt publication/requeue.
9. Repair a failure, replay the original job and run its permanent regression.
10. Replay `TML-4PM/the-pen#255` until an independently generated final receipt exists.

## Deployment gate

No worker-runtime release may be classified REAL unless:

- all applicable tests pass;
- event arrival produces STARTED evidence;
- one success path and one failure-repair-replay path are demonstrated;
- ledger and runtime readback agree;
- unresolved controls are explicitly classified ASPIRATIONAL or BLOCKED_WITH_EVIDENCE.
