# One Source, Multiple Lifecycle Objects

## Status
Evidence state: PARTIAL
Enforcement mode: ADVISORY_NON_BLOCKING

This doctrine is now canonical guidance for PEN, Symbio, Gatekeeper, and Synapse workflows. It is not yet a hard runtime gate until validator telemetry and enforcement receipts exist.

## Rule
One source of truth. Multiple lifecycle objects. No duplicated work.

## Canonical Model

| Object | Role | Rule |
|---|---|---|
| PEN artifact | Source of intent, doctrine, constraints, and source evidence | Must remain the canonical source for the work item |
| Symbio issue | Execution wrapper | Must derive tasks from PEN, not rewrite or reinterpret the PEN artifact |
| Gatekeeper review | Evidence validation | Must verify receipts, telemetry, replay, recovery, and traceability |
| Synapse promotion | Runtime promotion | Must only receive evidence-proven artefacts |

## Required Behaviour

When a PEN artifact already exists:

1. Use the PEN artifact as the source of intent.
2. Generate or update the Symbio issue as an execution wrapper only.
3. Link the Symbio issue back to the PEN artifact and commit receipt.
4. Extract actionable tasks from PEN instead of creating a second planning document.
5. Continue delivery without waiting for doctrine cleanup.
6. Consolidate duplicated planning opportunistically when the worker next touches the item.
7. Return receipts for each lifecycle object and runtime action.

## Non-Blocking Constraint

This doctrine must reduce friction. It must not become a bottleneck.

Until a validator is explicitly promoted to hard-gate mode:

- Existing PEN artifacts remain valid.
- Existing Symbio issues remain valid.
- Existing builds may continue.
- Runtime recovery work must not wait.
- No active ticket should be paused solely because PEN and Symbio contain overlapping language.
- Duplicated planning should be consolidated when naturally touched.

## Evidence Classification Rules

| Condition | Classification |
|---|---|
| Doctrine committed only | PARTIAL |
| Validator scaffold committed | PARTIAL |
| Validator emits telemetry and receipts | PARTIAL/REAL depending on runtime evidence |
| Validator blocks unsafe duplication with recovery route | REAL candidate |
| Runtime policy enforced across PEN/Symbio/Gatekeeper/Synapse | REAL |

## Anti-Regression Rule

This doctrine is intended to prevent duplicated labour, not prevent delivery.

If a worker detects duplicated PEN/Symbio content, it must:

1. select PEN as source of intent
2. treat Symbio as execution wrapper
3. continue the build
4. add traceability if needed
5. avoid creating another planning object
6. return receipts

## ROKC Binding

This doctrine is an input to the Recursive Operational Knowledge Compiler.

ROKC should compile this as a governance pattern:

- repeated duplicated planning is entropy
- entropy should be detected
- detection should create consolidation guidance
- consolidation must remain non-blocking unless hard-gate mode is explicitly enabled

## Source Receipts

- ROKC PEN artifact commit: `5c8dc8d43ff1bf72a0e31b92c23268f4109fbd15`
- Symbio build issue: `TML-4PM/the-pen#201`
- Operating correction comment: `4705459913`
- Non-blocking clarification comment: `4705475413`

## Current Reality

This doctrine is real as a committed artifact once merged/committed.
It is not yet real as universal runtime enforcement.
