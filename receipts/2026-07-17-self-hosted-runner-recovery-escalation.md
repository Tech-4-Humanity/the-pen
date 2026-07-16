# Self-Hosted Runner Recovery Escalation

Date: 2026-07-17
Repository: `TML-4PM/the-pen`
Status: PARTIAL

## Observation

No runtime-generated receipt currently proves that the `t4h-bridge` self-hosted runner is registered, online, servicing jobs, or starting named workflow steps.

The existing bootstrap queue item remains a valid execution instruction, but publication of that instruction is not runtime proof.

## Recovery action

A dedicated recovery and verification job has been added:

- `inbox/recover-and-verify-the-pen-self-hosted-runner-20260717.json`

The job distinguishes registration, service, connectivity, queue/label and workflow-step failures rather than reporting an undifferentiated CI failure.

## Required proof

The next status upgrade requires all of the following:

1. Runner installation detected or completed.
2. Runner service active.
3. GitHub reports the runner online.
4. Label `t4h-bridge` is present.
5. A named CalmBound workflow step starts.
6. Source tests execute.
7. PostgreSQL validation executes or produces a named step failure with logs.

## Truth statement

Self-hosted runner design, workflow routing and recovery instructions are REAL repository artefacts. Runner operation remains PARTIAL until runtime receipts and GitHub online/step evidence exist.
