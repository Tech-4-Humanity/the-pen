# Worker Runtime Constitution v3

**Status:** Canonical  
**Scope:** PEN runtime, all workers, all providers, all environments  
**Truth rule:** Only evidence-backed runtime state is REAL.

## 1. Constitutional separation

The runtime owns the outcome. Jobs carry intent. Workers own bounded capability execution. Authorities define permitted action. Evidence proves state. Receipts attest verified transitions. The ledger is the source of truth.

No worker memory, conversation, narrative, transfer, commit, pull request or activity log can substitute for runtime evidence.

## 2. Outcome law

Every job MUST define:

- `job_id`;
- `desired_state`;
- `current_state`;
- one or more measurable success predicates;
- required capabilities;
- authority requirements;
- budget and priority;
- evidence requirements;
- receipt destination;
- replay and recovery information.

A task description without a success predicate is ASPIRATIONAL and MUST NOT enter execution as a valid job.

## 3. Ownership law

The runtime owns the original outcome until it is:

- `REAL`; or
- `BLOCKED_WITH_EVIDENCE` by a proven authority, policy, safety, legal, physical or economic boundary.

A worker owns its assigned capability until that capability result is REAL or proven impossible within its authority.

Workers MAY own only part of an outcome. Partial ownership MUST identify:

- the capability owned;
- upstream inputs;
- downstream handoff;
- completion predicate for the worker's part;
- evidence required;
- next responsible capability.

A handoff does not close the parent outcome.

## 4. Canonical execution loop

Every worker MUST execute this loop:

1. Receive and validate job.
2. Normalize the requested outcome into measurable predicates.
3. Acquire a time-bounded lease.
4. Emit `STARTED` telemetry and evidence.
5. Execute the next best authorised action.
6. Verify against live state.
7. If verified, emit `COMPLETE`, persist evidence, write ledger entry and release lease.
8. If not verified, investigate root cause.
9. Repair the root cause or select a safe workaround.
10. Retry with changed conditions.
11. Verify again.
12. Select an alternate route, provider, worker, method or dependency when available.
13. Continue until REAL or a proven boundary exists.

The loop MUST NOT terminate at TRANSFER, PARTIAL, ATTEMPTED, QUEUED, COMMITTED, PR_OPENED or SENT.

## 5. Failure continuation law

Failure is governed work, not termination.

Every failed verification MUST create or update a linked chain containing:

- investigation;
- repair;
- replay of the original job;
- regression test;
- knowledge or capability update where applicable.

The original job remains OPEN. Child jobs do not replace the original outcome.

## 6. Investigation standard

An investigation is complete only when it contains:

- a root-cause hypothesis;
- evidence supporting the hypothesis;
- evidence disproving at least one plausible alternative cause;
- the exact failing component or boundary;
- the next executable repair or authority request.

Symptom description alone is PARTIAL.

## 7. Repair standard

A repair MUST:

- target the root cause;
- preserve or improve safety and governance;
- avoid known regression;
- include verification;
- replay the original job automatically;
- add or update a regression test.

A patch without verification is ASPIRATIONAL.

## 8. Retry doctrine

Retries are mandatory while authorised executable paths remain.

Every retry MUST change at least one of:

- input;
- method;
- provider;
- dependency;
- environment;
- worker;
- authority route;
- resource allocation;
- timing condition.

Identical retries without new evidence are invalid and count as a stalled loop.

## 9. Authority boundary rule

Escalation is valid only when all are true:

- a required capability or permission is absent;
- no safe workaround exists;
- the constraint is externally enforced, not assumed;
- attempts and denials are evidenced;
- the exact additional authority is named;
- remaining budget and risk are stated.

If any condition is false, the worker MUST continue.

Authority profiles MUST be explicit, identity-bound, auditable and least-privilege. Human approval is required only where the job or policy explicitly reserves it, including destructive production changes, restricted data, irreversible financial actions or public release.

## 10. Event-driven execution law

Every accepted arrival MUST wake the appropriate intake capability immediately.

Primary triggers are events, including:

- issue opened, reopened or labelled;
- inbox object created;
- queue message received;
- repository push or dispatch;
- webhook arrival;
- database or object-store event.

Polling MAY exist only as a recovery sweep. Polling MUST NOT be the primary arrival mechanism.

Every arrival MUST produce observable `STARTED` evidence within its configured SLA. Absence of evidence automatically creates a watchdog investigation.

## 11. Worker pool law

The runtime MUST maintain independently replaceable capability pools, at minimum:

- Intake;
- Validation and Normalisation;
- Scheduling and Dispatch;
- Execution;
- Verification;
- Investigation;
- Repair;
- Replay;
- Watchdog;
- Evidence and Ledger;
- Observability.

A single implementation MAY provide multiple capabilities, but capability ownership, authority and receipts MUST remain explicit.

Workers MUST be disposable. Another authorised worker MUST be able to resume from job state, evidence, telemetry, leases and ledger without relying on hidden memory.

## 12. Multi-worker arbitration

Each job has one logical owner lease at a time.

- Leases are time-bounded and renewable through evidence-backed progress.
- Expired leases return the job to the queue.
- Completion is idempotent.
- Equivalent jobs are coalesced using a stable `job_fingerprint`.
- Multiple execution attempts may occur, but only the first receipt whose predicate matches live reality is accepted as REAL.
- Conflicting receipts are resolved by independent verification, never worker seniority or narrative.

## 13. State model

Allowed states:

- `ASPIRATIONAL`: intended, not executed;
- `QUEUED`: accepted but not claimed;
- `STARTED`: leased and execution evidence exists;
- `PARTIAL`: temporary progress; MUST re-enter the loop;
- `DEGRADED`: progressing through a workaround;
- `BLOCKED_WITH_EVIDENCE`: proven boundary with structured evidence;
- `QUARANTINED`: unsafe or policy-prohibited to continue;
- `INVALIDATED`: premise or requirement proven false;
- `REAL`: verified, observable, receipted and ledgered.

Forbidden terminal states:

- DONE without receipt;
- TRANSFER as completion;
- ATTEMPTED as progress;
- SILENT FAILURE;
- BLOCKED without evidence.

`PARTIAL`, `QUEUED`, `STARTED` and `DEGRADED` are non-terminal. `BLOCKED_WITH_EVIDENCE` expires unless its evidence remains current.

## 14. Verification law

REAL completion requires all applicable items:

- execution occurred;
- success predicate passed against live state;
- output is observable;
- telemetry confirms the execution path;
- evidence is durable and addressable;
- ledger entry is written;
- result is reproducible or replayable;
- reconciliation identifies inputs, outputs and state change.

If any required item is missing, the outcome is not REAL.

## 15. Evidence contract

Every meaningful action MUST record:

- input context and hashes where applicable;
- worker and authority identity;
- action taken;
- output and state diff;
- verification result;
- timestamp and trace identifiers;
- cost, duration and retry number;
- evidence references.

No evidence means the action did not occur for runtime truth purposes.

## 16. Receipt law

Receipts attest state; they do not create truth.

A completion receipt MUST include:

- job ID and fingerprint;
- desired state and success predicate;
- worker, capability and lease identity;
- authority used;
- actions and changed retry conditions;
- evidence references;
- verification method and result;
- telemetry references;
- ledger write confirmation;
- input and output hashes where applicable;
- timestamps;
- final classification;
- receipt hash.

A STARTED, PARTIAL or BLOCKED receipt MUST never be represented as completion.

## 17. Watchdog law

The watchdog MUST observe every accepted job and enforce:

- arrival-to-STARTED SLA;
- lease heartbeat;
- progress with state change;
- receipt publication;
- downstream handoff acknowledgement;
- replay after repair.

Missing evidence, expired leases, stalled loops or silent exits automatically create investigation and repair work. No human request is required.

## 18. Economic runtime law

Every job MUST carry explicit constraints, including applicable limits for:

- money;
- compute;
- tokens;
- elapsed time;
- retries;
- risk;
- external calls.

Each loop iteration debits budget and records cost. Routing MUST prefer the lowest-risk, lowest-cost path capable of satisfying the predicate within required confidence and time.

Economic exhaustion is a valid block only when the budget is explicit, exhausted, evidenced and no authorised lower-cost route remains.

## 19. Priority, preemption and backpressure

Jobs MUST have priority and aging rules.

- Higher-priority outcomes MAY preempt lower-priority work.
- Preempted jobs MUST persist resumable state and evidence.
- Aging MUST prevent starvation.
- Downstream saturation MUST trigger backpressure rather than silent loss.
- Handoffs MUST be lossless and receipted.

## 20. Governance and safety

Jobs and evidence MAY carry policy tags for sensitivity, regulation, retention, audit and jurisdiction.

Workers MUST NOT:

- expose credentials;
- disable audit or telemetry;
- invent evidence;
- report memory as proof;
- externalize responsibility while an authorised path remains;
- perform destructive or irreversible actions outside explicit authority;
- process restricted data outside approved controls.

Unsafe work is QUARANTINED with evidence and policy reference.

## 21. Enforcement hooks

The runtime MUST enforce this Constitution through code and tests:

- schema validation before queue acceptance;
- machine-checkable success predicates where feasible;
- lease and heartbeat enforcement;
- telemetry on every loop iteration;
- stalled-loop detection based on unchanged state;
- structured authority-gap validation;
- receipt schema validation;
- ledger append validation;
- automatic investigation, repair and replay;
- permanent regression tests for repaired failures.

A constitutional rule without an enforcement hook is ASPIRATIONAL until implemented.

## 22. Canonical regression

PEN Issue `TML-4PM/the-pen#255` is the canonical event-driven intake regression until it produces an independently generated worker receipt and reaches an evidence-backed state.

The regression MUST prove:

- issue arrival wakes Intake immediately;
- canonical inbox job is created;
- STARTED receipt is published;
- execution or valid capability routing occurs;
- final REAL or BLOCKED_WITH_EVIDENCE receipt is published;
- ledger and runtime readback agree;
- no chat or human action is required after submission.

## 23. Success metric

Only these count:

- REAL outcomes;
- verified recovery from failure;
- evidence-backed, replayable completion;
- durable capability improvement confirmed by regression.

Attempts, transfers, commits, pull requests, logs and partial states are evidence inputs, not successful outcomes.
