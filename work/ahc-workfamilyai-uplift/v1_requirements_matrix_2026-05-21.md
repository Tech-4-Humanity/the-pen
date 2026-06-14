# AHC / WorkFamilyAI v1.0 Requirements Matrix

Date: 2026-05-21
Classification: PARTIAL until bridge receipt exists
Purpose: preserve thread requirements and prevent repeated rework.

## Proven Artifacts

| Artifact | Commit | Purpose |
|---|---|---|
| bridge handoff payload | 796aeb55f3aad3cec6f4e5171be36c3352a5f9aa | original intake |
| runtime inventory schema | d59885de71632c1b122142ded0ab7ee1adffa566 | inventory contract |
| telemetry ledger schema | abb37150cdc623612ae92c4b6d9616868481967d | telemetry table skeleton |
| nested CFN root | 9566d8a099c4110a8549a089cf897d0c3b9b0527 | infrastructure root |
| validation scorecard | 23ee9866ef3a50e0590f5fd9f4e8f8bf8d03350a | validation summary |
| v1 alive payload | c32be443c5fdf04a7ea2e03d76d3009a7a627026 | deployment intake |

## Requirement Coverage

| Area | Requirement | Current State | Required Evidence |
|---|---|---|---|
| Governance | REAL/PARTIAL/PRETEND maintained | present in schema and payloads | final receipt classification |
| Runtime | live inventory of repos, surfaces, workers, queues, tables and receipts | schema only | runtime_inventory.json |
| Agent Truth | reconcile 49 vs 81 agent count | known conflict recorded | canonical_agent_roster.json |
| Telemetry | ledger structure exists | SQL committed | migration receipt or blocked error |
| Infrastructure | nested CFN root exists | root only | child templates |
| Recovery | recovery-first order accepted | specified, not proven | replay/recovery receipt |
| Operations | idempotent handoff | present | bridge receipt |
| Business | monetisation pathway | partly specified | monetisation_package.md |

## Functional Views

### IT
Needs canonical runtime inventory, child infrastructure templates, telemetry deployment path, queue traceability, endpoint truth, and drift removal.

### Operations
Needs receipts, blocked-state reasons, queue replay evidence, orphan reporting, and reconciliation.

### Business
Needs reusable paid packages: diagnostic, command centre, managed survivability, workforce governance, telemetry and recovery compliance.

### Governance
Needs no promotion of unsupported claims, clear evidence state, and staged recoverability before longer autonomy windows.

## Required Outputs

| Output | Path |
|---|---|
| runtime_inventory.json | work/ahc-workfamilyai-uplift/runtime_inventory.json |
| canonical_agent_roster.json | work/ahc-workfamilyai-uplift/canonical_agent_roster.json |
| system_graph.json | work/ahc-workfamilyai-uplift/system_graph.json |
| orphan_report.md | work/ahc-workfamilyai-uplift/orphan_report.md |
| monetisation_package.md | work/ahc-workfamilyai-uplift/monetisation_package.md |
| queue-fabric.yaml | work/ahc-workfamilyai-uplift/nested-cfn/queue-fabric.yaml |
| telemetry.yaml | work/ahc-workfamilyai-uplift/nested-cfn/telemetry.yaml |
| runtime-workers.yaml | work/ahc-workfamilyai-uplift/nested-cfn/runtime-workers.yaml |
| recovery-runtime.yaml | work/ahc-workfamilyai-uplift/nested-cfn/recovery-runtime.yaml |
| governance.yaml | work/ahc-workfamilyai-uplift/nested-cfn/governance.yaml |
| bridge receipt | receipts/runtime/ahc-workfamilyai-v1-requirements-receipt.json |
