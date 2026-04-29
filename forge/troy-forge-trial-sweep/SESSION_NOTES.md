# Forge Trial Sweep — Lane 3 Closure

**Session**: 2026-04-29
**Project**: OUTRD-FORGE-001
**Status**: REAL · end-to-end verified

## What was built

| Component | Identifier |
|---|---|
| Lambda | `troy-forge-trial-sweep` (py3.12, 512MB, 300s) |
| ARN | `arn:aws:lambda:ap-southeast-2:140548542136:function:troy-forge-trial-sweep` |
| S3 bucket | `tech4humanity-forge` (AES256, versioned, RDTI-tagged) |
| CFN stack | `t4h-forge-trial-bucket` (CREATE_COMPLETE) |
| Receipt | `s3://tech4humanity-forge/trials/receipts/forge-alpha-trial-20260429-001.json` |
| Receipt ETag | `f95ba7f17e12162b1193835db857c53d` (693 bytes) |

## Actions

- `forge.run_trial_sweep` — list S3 prefix, sample N (default 250), write receipt
- `forge.seed_and_sweep` — seed 500-record fixture, then sweep
- `forge.read_receipt` — read receipt JSON back from S3 by run_id

## Bridge envelope (TOP-LEVEL)

```json
{"fn":"troy-forge-trial-sweep","action":"forge.run_trial_sweep","run_id":"...","sample_n":250}
```

Not nested under `payload`. Confirmed via VERSION_PROBE_v2 method.

## Findings worth carrying forward

1. **Bridge envelope shape is per-Lambda.** `troy-sql-executor` reads NESTED (`payload.sql`). `troy-lambda-deploy`, `troy-cfn-deployer`, and custom forge pods read TOP-LEVEL. Probe with `{"fn":"X","action":"VERSION_PROBE_v2"}` top-level — "unknown action" means top-level is correct.
2. **`troy-code-pusher` cannot create.** `create_if_missing` flag IGNORED → falls through to `UpdateFunctionCode` → ResourceNotFoundException. Use `troy-lambda-deploy` for create.
3. **`troy-cfn-deployer` template key.** Wants `template` as base64-encoded string. The error message hints (`template_body`, `template_body_b64`) are misleading.
4. **`mcp_lambda_registry` cascades to `core.registry_entities` via `trg_lambda_registry_sync`,** which fires the S13 RDTI gate (`t_require_rdti_tag`). Cascade does NOT pass metadata so registry INSERT fails opaquely as `sql_error/command:null` via troy-sql-executor. Pre-create the entity row with `metadata.is_rd` + `metadata.project_code` before the registry insert. `WHERE NOT EXISTS` in the cascade then skips.
5. **`troy-sql-executor` masks RAISE EXCEPTIONs as generic `sql_error`.** Debug via PostgREST direct path (`SUPABASE_URL/rest/v1/<table>`) which surfaces the actual P0001 + hint.
6. **`mcp_lambda_registry.business_key` FK** → `t4h_brand_map.brand_code`. Only `T4H` (uppercase) exists. `t4h-core` will silently fail.

## Audit trail

- `mcp_lambda_registry` row, `is_callable=true`, `invocation_count=1`, `last_invocation_status=success`
- `t4h_canonical_changes` × 3 entries (registration, completion, envelope-shape gotcha)
- `core.registry_entities` row `lambda.troy-forge-trial-sweep`, autonomy=GATED, RDTI metadata
- `ops.execution_ledger` row via `fn_lambda_invoke_to_ledger` trigger
