# BOOTSTRAP RULE: Probe Before Trust (v1, 2026-05-17)

**Authority:** Troy directive 2026-05-17 — the many assumptions and inability to follow onboarding is 30 percent waste.
**Kernel basis:** GLOBAL_RULE_KERNEL_V6 — runtime_truth_over_claims, evidence_over_assertion, REAL_requires_typed_evidence.

## The failure pattern (named so it can be caught)
Every blocker resolved in the 2026-05-15..17 sessions was a STALE LEDGER CLAIM trusted as fact, not a real wall:

| Claimed (ledger/memory) | Actual (one probe) | Probe cost |
|---|---|---|
| bridge cannot do IAM | aws-cli put-function-concurrency RC=0 to 5 worked | 1 call |
| VERCEL_TOKEN expired/invalid | GET /v2/user returned 200 | 1 call |
| troy-vercel-executor exists | ResourceNotFound — never existed | 1 call |
| dual-header bridge auth required | single x-api-key 200; dual 401 | 2 calls |
| TML-4PM is a GitHub org | /orgs/TML-4PM 404; it is a USER | 1 call |
| dra.tech4humanity.com is the target | not owned; .com.au/.net are | 1 dig |

Six walls. ~5 minutes of probes. Multiple prior sessions burned re-diagnosing instead of testing. That is the 30 percent.

## Rule
A reality_ledger row with status=BLOCKED is a HYPOTHESIS, not a constraint. Before treating ANY blocker as real:

1. **Probe first.** A BLOCKED claim about a credential, permission, endpoint, or resource MUST be re-tested with one live call before any remediation, consolidation, or re-diagnosis is written. The probe IS the work; skipping it is the waste.
2. **Typed evidence only.** expired, stopped, no permission, not callable are claims. status_code=200, ResourceNotFoundException, a commit_sha, a change_id are evidence. Only evidence updates classification.
3. **Distrust your own prior session.** If memory or ledger says X is impossible, the first action is the cheapest test that would prove X possible. Confidence from a past session is not runtime truth.
4. **One probe closes or confirms.** Probe succeeds means the block was stale, proceed. Probe fails with typed evidence means NOW it is real, log the evidence not the assumption.
5. **No cascade trust.** The bridge-cannot-do-IAM claim was used to wall 5 unrelated blockers. One false root assumption metastasises. Probe each surface independently.

## Onboarding sequence (corrected)
1. Pin bridge DNS to /etc/hosts.
2. Read reality_ledger WHERE status=BLOCKED.
3. For each BLOCKED row: run the single cheapest probe that would falsify it BEFORE planning any work. Most will falsify.
4. Only the probe-confirmed-real blockers get remediation effort.

This file is canonical. Deviation = the 30 percent waste, by definition.