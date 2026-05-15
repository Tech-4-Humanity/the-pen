# Red-Line Control Plane — Status

Updated: 2026-05-15T21:26:26Z

## Overall reality state: **PARTIAL**

| Layer | Reality | Evidence |
|---|---|---|
| Package artefacts | REAL | 5 commits in `programs/red-line-control-plane/` |
| Receipt schema v2 | REAL (defined) / PARTIAL (not yet enforced by runtime table) | `receipt_lifecycle_v2.schema.json` |
| Runtime probes | REAL (executed, receipt written) | `runtime_receipts/2026-05-15_probe_run_001.json` |
| Audit/repair dispatcher | PARTIAL (spec only) | `audit_repair_dispatcher_v1.md` |
| Blocker matrix | REAL | `blocker_matrix.md` |
| Migration to v2 schema | NOT STARTED | B-01 in matrix |
| Quarantine RPC | NOT STARTED | B-02 in matrix |

## To flip to REAL

Must land:

1. `migrations/2026-05-16_receipt_lifecycle_v2.sql` — add `receipt_type`, `parent_receipt_id`, `direction`, `reality_state`, `runtime jsonb`, `repair jsonb`, `blockers text[]` to `public.t4h_canonical_changes`.
2. `public.fn_receipt_quarantine(p_change_hash text)` — closes B-02.
3. `public.fn_red_line_dispatcher_tick()` + pg_cron `*/5 * * * *` — closes B-05.
4. Re-run `runtime_probe.sql` after migration; emit second probe receipt confirming new columns exist and accept lifecycle payloads.

When all four are committed, sealed in `t4h_canonical_changes`, and a closure receipt links them, this STATUS.md flips to REAL.

## Anti-talk guard

This program does not accept commentary as evidence. Per GLOBAL_RULE_KERNEL_V6 §evidence_layer, REAL requires `api_response | database_result | cli_output | commit_id | url | receipt | runtime_hash | telemetry_snapshot | execution_trace | recovery_log`. Every claim above is anchored to one of those.
