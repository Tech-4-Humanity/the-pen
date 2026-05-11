# Ecosystem OS Blocker Burndown Register

Status: ACTIVE / PARTIAL
Issue: #76
Task ID: ecosystem-os-catalogue-control-tower-2026-05-11

## Purpose
Convert the remaining PARTIAL/BLOCKED statuses into explicit closeable work units with proof gates. This prevents vague status drift and gives Bridge/Command Centre a deterministic execution checklist.

## Current blocker table

| Area | Current status | Why not REAL | Required execution | Proof gate | Close condition |
|---|---|---|---|---|---|
| Runtime orchestration | PARTIAL | Orchestration is specified but not running as a state machine | Create orchestration state tables, event queue, retry/escalation rules, and execution views | Smoke test creates an orchestration run and advances state | Run record exists with state transitions and evidence |
| Autonomous completion | PARTIAL | Monitoring model exists, but no autonomous polling/escalation loop is live | Add monitor loop that checks Issue #76, repo files, receipts, and stale states | Monitor emits stale/healthy status and posts/update evidence | No stale blocker can sit unreported |
| Bridge canonicalisation | BLOCKED pending receipt | Connector commits exist but canonical MCP Bridge/fn_github_push receipt missing | Submit bridge envelope via MCP Bridge and capture receipt | Receipt includes commit_sha, content_sha/hash, html_url, receipt path | Receipt attached to Issue #76 and ledger row |
| Control tower runtime | PARTIAL | Widget/control spec exists conceptually, not deployed/rendered | Create Command Centre widget spec + source query/view | Widget shows maturity, evidence, blockers, and next action | Visible dashboard or widget artefact committed and linked |
| Full ecosystem OS | PARTIAL | Core substrate exists, but runtime proof is incomplete | Combine ontology, signal, governance, orchestration, evidence, economics and dashboard | End-to-end test: object -> signal -> orchestration -> evidence -> dashboard | All components return structured output and are ledger-bound |

## Immediate execution order

1. Bridge canonicalisation receipt
2. Runtime orchestration schema
3. Autonomous monitor loop spec
4. Control tower widget/view
5. End-to-end proof harness

## REAL gate definition

The system can only move to REAL when the following evidence exists:

```yaml
runtime_orchestration:
  required: true
  proof:
    - orchestration_run_id
    - state_transition_log
    - retry_or_escalation_rule

autonomous_completion:
  required: true
  proof:
    - monitor_run_id
    - stale_check_result
    - issue_update_or_receipt

bridge_canonicalisation:
  required: true
  proof:
    - bridge_receipt_id
    - commit_sha
    - content_sha
    - html_url

control_tower_runtime:
  required: true
  proof:
    - widget_slug_or_view_name
    - data_source_query
    - screenshot_or_url_if_available

full_ecosystem_os:
  required: true
  proof:
    - end_to_end_test_id
    - ledger_row_id
    - command_centre_visibility
```

## Status classification rule

- PARTIAL: design exists or connector commit exists, but runtime execution proof is missing.
- BLOCKED: required external/runtime dependency is unavailable or no receipt exists.
- REAL: execution happened, evidence exists, and closure row is bound.

## Current truth

```yaml
status: PARTIAL
result: blocker burndown register created
execution: connector file commit
output: blocker register for five remaining statuses
evidence:
  - github_connector_commit_pending_return
  - issue_76_tracking
gaps:
  - bridge receipt still missing
  - runtime execution still missing
  - command centre visibility still missing
  - ledger row still missing
next_action: submit bridge envelope and attach receipt
elevation: converts vague PARTIAL/BLOCKED statuses into closeable execution gates
pressure_flags:
  - bridge_receipt_missing
  - runtime_not_proven
  - dashboard_not_visible
score: 0.72
```

## Final closure rule
Do not close Issue #76 until all five blocker rows are either REAL or explicitly BLOCKED with a bounded reason and assigned recovery path.
