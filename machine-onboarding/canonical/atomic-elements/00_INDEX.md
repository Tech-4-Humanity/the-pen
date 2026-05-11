# Atomic Elements Registry

Status: ACTIVE
Owner: The Pen
Purpose: reusable execution primitives - the LEGO blocks of machine cognition.

These are the units machines compose to build systems. Each primitive is a self-contained YAML spec with inputs, outputs, invariants, and replay rules. Machines may instantiate primitives but must not silently mutate them.

## Index (seeded 2026-05-11)

| ID | Name | Purpose |
|----|------|---------|
| ATOM-EXEC-001 | bridge_receipt_pattern | Standard bridge receipt validation and ledger binding |
| ATOM-EXEC-002 | evidence_envelope | Typed evidence wrapper for any operational claim |
| ATOM-EXEC-003 | escalation_chain | Authority resolution and human-in-the-loop routing |
| ATOM-EXEC-004 | recovery_loop | Retry / replay / re-search / re-audit recovery state machine |
| ATOM-EXEC-005 | telemetry_block | Standard metric emission shape for any executed action |
| ATOM-EXEC-006 | preflight_check | Callable form of PREFLIGHT.md - codifies the 4-step session bootstrap |

## Rules

- Stable IDs (ATOM-EXEC-NNN) are never reused.
- Adding a primitive requires a ledger row classified REAL and tagged cluster_id = CL_BRIDGE_PEN.
- Modifying a primitive requires a supersedes link in the ledger.
- Deprecated primitives are marked, never deleted.

## Next seeds (planned)

| Planned ID | Name | Trigger |
|------------|------|---------|
| ATOM-EXEC-007 | postgrest_writeback_verifier | Wrap TRAPS-D-3 + D-4 safe path |
| ATOM-EXEC-008 | cluster_resolver | Map intent to cluster_id via selection_guidance |
| ATOM-EXEC-009 | rule_sweeper | Coherence simulation pass before doctrine commit |
| ATOM-EXEC-010 | economic_tagger | Attach cost/value/owner to any new asset |
