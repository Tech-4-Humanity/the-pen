# BLOOD DONOR EXECUTION HUNT — GOVERNED DRY-RUN CONTROL PACKAGE

## Status
PARTIAL — GitHub control package lodged for bridge investigation and governed dry-run only.

## Intent
Investigate whether the blood donor mobilisation project has actually been picked up by the bridge, and repair the execution path if it has not.

Treat this as a deployed-system control task, not an ideation task.

## Safe Execution Boundary
This package must not contact real donors, make clinical eligibility decisions, process identifiable health data, or direct emergency health operations. It is limited to synthetic data, partner-readiness planning, operational telemetry, governance checks, and evidence logging until authorised partners and compliance controls are in place.

## Required Outcome
Bridge must prove one of two outcomes:

1. RUNNING: the existing project execution path is active and has receipts; or
2. FIXED/PARTIAL: the bridge path was missing or broken, and a bounded dry-run recovery package has been created with evidence.

## Failure Hunt Loop
Run:
inspect -> action -> receipt -> evidence

Do not stop at unavailable tools. If a connector, lambda, or queue is unavailable, log the blocker and create the next executable handoff.

## Checks Required
1. Confirm this GitHub file exists and can be read.
2. Search the repository for prior blood donor / blood mobilisation handoffs.
3. Check whether the bridge runner has a queue intake folder or documented pickup path.
4. If a queue path exists, create a queue item referencing this file.
5. If no queue path exists, create a bridge-ready invocation envelope as a markdown/json artifact.
6. Create a synthetic dry-run plan using fake demand events and fake donor cohorts only.
7. Create a Command Centre status record or widget spec showing execution status.
8. Write or prepare a Reality Ledger row with evidence.
9. Return a receipt with commit id, files created, blockers, and next executable action.

## Minimum Artifacts To Create Or Verify
- docs/blood-donor/EXECUTION_STATUS.md
- docs/blood-donor/DRY_RUN_PLAN.md
- docs/blood-donor/GOVERNANCE_GUARDRAILS.md
- handoffs/BLOOD_DONOR_BRIDGE_QUEUE_20260506.json
- command-centre/widgets/blood_donor_status_widget.json
- reality-ledger/blood_donor_execution_20260506.yaml

## Governance Guardrails
- No real donor outreach.
- No medical advice.
- No blood-type targeting against real people without authorised partner controls.
- No sale of donor data.
- No clinical eligibility scoring.
- No emergency response automation without human-authorised institutional control.
- All dry-runs use synthetic data.

## Bridge Queue Envelope Template
```json
{
  "task_id": "BLOOD_DONOR_EXECUTION_HUNT_20260506",
  "mode": "dry_run_governed",
  "source_repo": "TML-4PM/the-pen",
  "source_path": "handoffs/BLOOD_DONOR_EXECUTION_HUNT_20260506.md",
  "intent": "investigate_fix_and_prove_bridge_execution_path_for_blood_donor_project",
  "no_hitl": true,
  "constraints": [
    "synthetic_data_only",
    "no_real_donor_contact",
    "no_medical_decisioning",
    "evidence_required"
  ],
  "acceptance_criteria": [
    "github_receipt_created",
    "prior_handoff_search_completed",
    "bridge_queue_path_identified_or_bounded",
    "dry_run_artifacts_created",
    "reality_ledger_entry_created"
  ]
}
```

## Ledger
```yaml
task_id: BLOOD_DONOR_EXECUTION_HUNT_20260506
intent: investigate_fix_and_prove_blood_donor_bridge_execution
execution: github_handoff_created
output: handoffs/BLOOD_DONOR_EXECUTION_HUNT_20260506.md
status: PARTIAL
evidence:
  - type: github_file
    repo: TML-4PM/the-pen
    path: handoffs/BLOOD_DONOR_EXECUTION_HUNT_20260506.md
score: 0.72
gaps:
  - bridge runtime receipt still required
  - prior handoff not found in indexed repository search
  - synthetic dry-run execution not yet proven
next_action: bridge runner to consume this handoff and return receipt
```
