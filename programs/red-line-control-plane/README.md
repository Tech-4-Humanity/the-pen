# Red-Line Control Plane

Status: PARTIAL

This package converts the current audit/runtime problem from scattered discussion into a concrete control-plane program inside `TML-4PM/the-pen`.

It is designed to move work through:

```text
scan -> classify -> repair -> receipt -> proof -> closure
```

It exists because passive dashboards and flat receipts are not enough. A receipt that only proves a file/comment exists is not the same as runtime execution, blocker handling, or closure.

## Included artefacts

- `receipt_lifecycle_v2.schema.json` — lifecycle receipt schema aligned to dispatch/acceptance/implementation/runtime/closure/blocker receipts.
- `audit_repair_dispatcher_v1.md` — operating specification for turning detected failures into repair jobs.
- `runtime_probe.sql` — SQL probes for `fn_github_push`, `http` extension, and `cap_secrets` readiness.
- `blocker_matrix.md` — current blocker matrix for #102, #106, #107, #108 and receipt drift.

## Reality state

PARTIAL until:

1. Runtime probes are executed through Bridge/troy-sql-executor.
2. `receipt_lifecycle_v2.schema.json` is adopted or supersedes the flat receipt schema.
3. #107 PRETEND receipt contamination is quarantined.
4. #108 schema chain is deployed or replaced with this v2 chain.
5. #102 audit repair dispatcher runs and emits runtime/blocker/closure receipts.

## Current evidence

- `global/GLOBAL_RULE.md` confirms `the-pen` as canonical.
- `global/MCP_EXECUTION_CONTRACT.md` confirms the bridge envelope.
- `global/ENFORCEMENT_LIVE.md` confirms historical working runtime path.
- `migrations/2026-04-24_fix_fn_github_push.sql` contains the `fn_github_push` implementation.
- `global/RECEIPT_SCHEMA.json` exists but is too flat for the two-way lifecycle in `receipts/README.md`.
- `receipts/README.md` defines the two-way lifecycle that this package operationalises.
