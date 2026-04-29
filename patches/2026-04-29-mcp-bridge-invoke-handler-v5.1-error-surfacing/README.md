# bridge handler v5.1 — error surfacing patch

## what
Patches `mcp-bridge-invoke-handler` (the API GW gate at `zdgnab3py0`) to surface real Postgres errors instead of returning a generic `error: "sql_error"` envelope.

## why
v5.0 `execSQL()` had two return paths that discarded actual error detail:
- `if (!res.ok)` → `error: "sql_error"`, no message, no status
- `if (data.error)` → `error: "sql_error"`, drops `data.error` + `data.sqlstate`

This made every SQL failure look identical and forced operators to bypass the bridge (use MCP rpc:run_sql) just to see what actually failed. TRAPS-B captures the workaround. This patch removes the need for the workaround.

## patch
- `error: data.error` instead of `error: "sql_error"` for run_sql-returned errors
- `error: data.message || data.error || http_<status>` for non-2xx responses, includes `http_status`
- `sqlstate` field passed through when present
- header bumped to `v5.1 — HARDENED + ERROR SURFACING`

See `index.mjs` (in this folder) for the full patched source.

## deploy
**BLOCKED on IAM.** `troy-lambda-deployer-role` lacks `lambda:GetFunctionConfiguration` on `mcp-bridge-invoke-handler` (the bridge gate intentionally excludes itself from auto-deploy — chicken-and-egg).

To deploy:
1. Manually attach `AWSLambda_FullAccess` (or scoped policy) to `troy-lambda-deployer-role` for the duration of the deploy
2. Re-zip `index.mjs` (this file): `zip patch.zip index.mjs`
3. Bridge call:
   ```bash
   curl -X POST https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke \
     -H "x-api-key: $BRIDGE_KEY" \
     -d '{"fn":"troy-lambda-deploy","function_name":"mcp-bridge-invoke-handler","zip_base64":"<base64-of-patch.zip>","publish":false}'
   ```
4. Detach the temporary IAM grant
5. Smoke test: send a deliberately invalid SQL via `troy-sql-executor` — should now return real error message + sqlstate

## smoke test (after deploy)
```bash
curl -X POST https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke \
  -H "x-api-key: $BRIDGE_KEY" \
  -d '{"fn":"troy-sql-executor","payload":{"sql":"SELECT * FROM nonexistent_table_xyz"}}'
```
- Pre-patch (v5.0): `{success:false, error:"sql_error", rows:[], count:0, command:null}`
- Post-patch (v5.1): `{success:false, error:"relation \"nonexistent_table_xyz\" does not exist", sqlstate:"42P01", rows:[], count:0, command:null}`

## rollback
Re-deploy v5.0 from `code_url` snapshot:
```
https://awslambda-ap-se-2-tasks.s3.ap-southeast-2.amazonaws.com/snapshots/140548542136/...
```
(snapshot URL was captured 2026-04-29 06:36:43 UTC — see receipts/2026-04-29-pen-unblock-via-mcp-direct.json for the full URL)
