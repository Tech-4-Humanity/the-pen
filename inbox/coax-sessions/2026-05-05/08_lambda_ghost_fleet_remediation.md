# Lambda Ghost-Fleet Remediation
**Generated**: 2026-05-05 by COAX
**Source**: ops.coverage_gap WHERE gap_type='UNUSED_LAMBDA' (174 rows)
**Confirmed sample**: troy-reminders — Active in AWS, zero executions in 30 days

---

## What this is
174 Lambda functions sit in `Active` state in `ap-southeast-2`, registered to QUEUE patterns, with **zero runtime job references**. AWS sees them as live; the system sees them as dead.

This is the long-tail of the same PRETEND-engine signal that flagged mcp-command-centre, the-pen, and t4h-remote-mcp-server-clean earlier. Same disease, different host.

## Why you can't ignore it
- **Free tier consumption**: 854K/1M requests already used (per memory). Ghost Lambdas are runtime-zero but cold-storage isn't free at this fleet size.
- **Drift signal**: 174 functions claiming readiness without proof = system can't tell what's real.
- **Strip-Consume blocker**: SPEC-003 Layer 2 (logic extraction) needs to know which Lambdas belong to which business. Ghost Lambdas confuse that mapping.
- **Audit risk**: any AWS bill review that questions "what does this fleet do" has no answer for 174 of them.

## Triage classes (proposed)

| Class | Definition | Action |
|---|---|---|
| **GHOST** | Zero invocations 90 days, no inbound trigger configured | Archive code to S3, delete Lambda |
| **DORMANT** | Zero invocations 30 days, has trigger but trigger source is dead | Archive Lambda, mark trigger source for repair |
| **ON_DEMAND** | Zero invocations 30 days but explicitly designed manual-run | Tag `lifecycle=on-demand`, exclude from gap sweep |
| **WAITING** | Zero invocations <30 days, fresh deploy | Watch list, recheck in 30 days |
| **ALIVE** | Has invocations in last 30 days | Remove from gap list |

## Sample evidence (troy-reminders)
```
FunctionName: troy-reminders
ARN:          arn:aws:lambda:ap-southeast-2:140548542136:function:troy-reminders
Runtime:      python3.11
LastModified: 2026-03-02
State:        Active
Logs (24h):   0 events
Logs (30d):   0 events
```
**Verdict**: GHOST or DORMANT depending on whether anything was meant to invoke it.

## Recommended sequence

### Phase 1 — Survey (1 day, no destructive ops)
- For each of 174 Lambdas: pull 30-day invocation count + trigger config
- Classify into the 5 buckets above
- Output: `lambda_ghost_audit_2026-05-05.csv` to TML-4PM/the-pen/inbox/

### Phase 2 — Tag (1 day, LOG-ONLY)
- Apply tag `lifecycle=GHOST|DORMANT|ON_DEMAND|WAITING|ALIVE` to each function
- Update `mcp_lambda_registry` rows with classification
- Resolve coverage_gap rows for ALIVE + ON_DEMAND classes

### Phase 3 — Archive (HITL gated)
- For each GHOST: download function code + env config (redacted) to `s3://t4h-deliverables/lambda-archive/<fn>/`
- Write `archive_lifecycle` row in ops schema
- Delete Lambda function only after archive verified

### Phase 4 — Repair triggers (DORMANT class)
- For each DORMANT Lambda, identify the dead trigger source
- This is the upstream — fixing the trigger usually unblocks something Troy was building before

## Cost-of-doing-nothing
None of these are paying you. None of them are running. They're noise drowning out the 156 Lambdas that *do* run. Every gap-sweep, every health-check, every audit has to wade through 174 false positives.

## Next concrete action
Run Phase 1 survey. Single bridge call per Lambda × 174 = ~5 minutes of bridge time, produces a definitive triage table. No deletes. Nothing to roll back. If you say go, COAX runs it now.
