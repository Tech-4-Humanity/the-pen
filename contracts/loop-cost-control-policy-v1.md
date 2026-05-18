# LOOP COST CONTROL POLICY v1

Status: ACTIVE
Created: 2026-05-18 Australia/Sydney
Scope: T4H catalogue, registry, document, service, demand, control, runtime and agent work.

## Purpose

Prevent unnecessary iteration, duplicate artefacts and avoidable spend. Work must converge through one active control issue, one canonical register and one deployment gate.

## Active control point

GitHub issue: https://github.com/TML-4PM/the-pen/issues/122
Contract: contracts/t4h-atomic-operating-catalogue-v1.md
Register: https://docs.google.com/spreadsheets/d/11GtsYKxZRud7wwl9eO_kZNIwg686VZu1d20KUyS1JUc

## Rules

1. Use the existing register before creating anything new.
2. Use issue #122 as the active control point for this programme.
3. Do not create duplicate catalogues, matrices, dashboards, registers or decks.
4. Do not run open-ended loops.
5. Do not repeat a search unless it targets a new source class or closes a named gap.
6. Do not start paid runtime, paid API calls, paid workers, deployment or public promotion without an explicit deployment gate.
7. Do not advance work using unproven claims.
8. If no new evidence appears, record PARTIAL or FAIL and stop that loop.

## Default loop limits

Every loop must declare:

- loop_id
- active_issue
- source registry
- max_cycles
- max_new_files
- max_external_calls
- expected_cost_aud
- stop_condition
- rollback_or_archive_path

Default values:

- max_cycles: 3
- max_new_files: 2
- max_external_calls: 12
- expected_cost_aud: 0
- stop condition: duplicate found, no new evidence, missing proof, or deployment boundary reached

## Stop conditions

Stop the current loop when any of these happen:

- the output already exists
- the register already has the row
- a source is duplicate or superseded
- no new evidence is produced
- the active issue is not linked
- evidence cannot be attached
- deployment or public promotion is required
- expected cost is above zero and not explicitly approved

## Cost containment sequence

1. Freeze duplicate creation.
2. Route work to issue #122.
3. Update existing register, not a new register.
4. Use metadata before full content fetch.
5. Batch writes.
6. Generate only the first three seed outputs before deployment gate.
7. Keep work at registry/document level unless deployment is approved.
8. Archive duplicate or superseded assets instead of maintaining parallel versions.

## Required loop receipt

```yaml
loop_control:
  active_issue: 122
  max_cycles: 3
  max_new_files: 2
  max_external_calls: 12
  expected_cost_aud: 0
  stop_on_duplicate: true
  stop_on_no_new_evidence: true
  deployment_gate_required: true
```

## Current instruction

Continue autonomous catalogue work until the deployment boundary. Cost control is mandatory now.
