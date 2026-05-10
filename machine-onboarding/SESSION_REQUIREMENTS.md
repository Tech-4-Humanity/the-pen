# Machine Onboarding Session Requirements

Status: ACTIVE
Owner: The Pen
Applies to: all AI machines, bridge workers, agent sessions, onboarding runs, audit loops, HITL review loops, and execution handoffs.

## Core rule

A machine session is not trusted because it completed once. It is trusted only when its search, audit, analysis, execution, and evidence loop survives review without material error.

If HITL finds one real error in one scan, the machine must redo the full search, audit, and analysis cycle from first principles. No patch-only fix. No narrow correction. No simulated completion.

## Required session loop

Every onboarded machine must run this loop before claiming completion:

1. Search
   - Locate all relevant source material, files, repos, threads, tasks, receipts, prior decisions, and dependencies available to the machine.
   - Record what was searched, what was not accessible, and why.

2. Audit
   - Compare discovered material against the stated intent, canonical rules, known execution doctrine, and current asset state.
   - Identify duplicates, contradictions, stale assumptions, dead tasks, missing receipts, weak evidence, and unclosed handoffs.

3. Analysis
   - Convert the audit into decisions, actions, gaps, risks, owner paths, and evidence requirements.
   - Distinguish REAL, PARTIAL, BLOCKED, and invalid claims.

4. Execution or handoff
   - Execute directly where authorised.
   - Otherwise package a bridge-ready payload with intent, assets, code, dependencies, run instructions, rollback notes, and evidence expectations.

5. Receipt
   - Store a machine-readable and human-readable receipt.
   - Include commit IDs, issue IDs, bridge receipt IDs, URLs, hashes, logs, or command output where available.

6. Close
   - Close only when completion is evidenced.
   - If completion cannot be evidenced, declare PARTIAL or BLOCKED with the exact dependency.

## HITL error rule

One verified HITL error in one scan means the whole scan is invalidated.

Mandatory response:

- redo full search
- redo full audit
- redo full analysis
- refresh evidence
- update gaps
- regenerate the action ledger
- replace or supersede the prior receipt
- record the error as a machine onboarding defect

The machine may not say "fixed" unless the full cycle has been rerun and evidenced.

## Error classes that trigger full redo

A full redo is required when HITL identifies any of the following:

- missed source that was reasonably available
- wrong status classification
- false REAL claim
- missing receipt
- stale or duplicated task treated as current
- wrong repo, branch, folder, product, or business target
- unsearched dependency presented as checked
- incomplete audit scope
- contradiction with canonical Pen rules
- skipped bridge handoff where bridge was required
- failure to bind output to evidence

## Tight completion standard

Completion requires all fields below:

```yaml
status: REAL | PARTIAL | BLOCKED
result: what changed or what was proven
evidence:
  - type: commit_id | url | api_response | cli_output | bridge_receipt | hash | repro_steps
    value: evidence value
gaps:
  - remaining gap or "none"
next_action: exact next machine action or "closed"
elevation: why this improves the system
pressure_flags:
  stagnation: true | false
  drag: true | false
  regression: true | false
score:
  execution: 0.0-1.0
  evidence: 0.0-1.0
  economic: 0.0-1.0
  reuse: 0.0-1.0
  delta: 0.0-1.0
ledger:
  task_id: stable task id
  intent: original user/system intent
  execution: what was actually run
  output: asset, code, doc, issue, PR, bridge package, or receipt
  status: REAL | PARTIAL | BLOCKED
  evidence: typed evidence list
```

## Non-negotiables

- No REAL without evidence.
- No close without receipt.
- No audit without source list.
- No HITL defect without full rerun.
- No patch-only recovery after a verified scan error.
- No pretending a bridge handoff happened when only a prompt was written.
- No treating unavailable tools as final failure when another authorised execution path exists.

## Machine onboarding acceptance test

A machine passes onboarding only if it can:

1. ingest the stated intent
2. find all available context
3. audit against canonical rules
4. identify gaps honestly
5. execute or package the bridge handoff
6. return typed evidence
7. recover from a HITL-discovered error by rerunning the whole cycle
8. produce a durable receipt

Anything less is PARTIAL.