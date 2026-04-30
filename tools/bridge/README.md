# Bridge / MCP Masking Fix — Runbook

**Date:** 2026-04-30
**Scope:** kill `command:null` masking everywhere; fix MCP server outage
**Tier:** STEP 1 = AUTO (config); STEP 2-3 = LOG; STEP 4 = GATED; STEP 5-6 = AUTO

---

## Root cause — what was actually happening

| Layer | Bug | Evidence |
|---|---|---|
| Vercel env | `T4H_BRIDGE_URL` points at decommissioned bridge `m5oqj21chd` (migrated to `zdgnab3py0` 2026-04-29) | Direct curl returned `HTTP 401 from m5oqj21chd... UNAUTHORIZED` |
| MCP `supabase_sql_read` | `blockedSql` rejects ANY `;` — even single trailing | `SELECT 1` works; `SELECT 1;` throws "only allows a single read-only statement" |
| MCP `fetchJson` | Throws `Error("HTTP 400: <text>")` — pg `code/message/details/hint` swallowed | line 40, index.js v3.2.0 |
| MCP `runSupabaseSql` | Sends `{query: sql}` — works for current `run_sql(query)` but fragile if RPC sig changes | line 41, index.js v3.2.0 |
| `troy-sql-executor` Lambda | Returns `{sql_error: "...", command: null}` instead of pg fields | TRAPS-B memory note 2026-04-29 |
| All Python/Node callers | Treated `command:null` as success, silently got `rows:[]` | the bug Troy reported |
| Anthropic MCP client | Wraps any tool error as `{"error":"Error occurred during tool execution","request_id":"req_..."}` — strips error text | external — out of our control |

The Anthropic-wrapper masking is what made every issue look identical. Direct
curl against the MCP server reveals real errors. `/diag` (added in patch)
makes triage one click.

---

## Files in this bundle

| File | Layer | Purpose |
|---|---|---|
| `bridge_sql.py` | Python client | Replaces legacy wrapper. Fail-fast on `command:null`, HTTP non-2xx, `sql_error`, missing rows. Carries `code/message/details/hint`. |
| `bridgeSql.mjs` | Node client | Same contract for JS. |
| `troy_sql_executor_handler.py` | Lambda source | Rewritten handler — surfaces real pg fields from `psycopg.Error.diag`. statusCode 400 on pg fail (not 200). |
| `troy-sql-executor.zip` | deploy artifact | Built from above (sha256 9a7597967bc00373952f433e3bc59a361f6bb5ac5c807af3786de7c16c86a0fe) |
| `zip_b64.txt` | deploy artifact | base64 of zip for `troy-lambda-deploy` payload |
| `index_patched.js` | MCP server | v3.3.0 — fixes `;` rejection, fetchJson masking, RPC param fallback, adds `/diag` |
| `test_bridge_sql_offline.py` | tests | 13 cases covering every error branch (all passing) |
| `deploy_bridge_fix.py` | runner | End-to-end deploy script |

---

## Deploy order

### STEP 0 — fix Vercel env (AUTO, ~30 sec) — UNBLOCKS EVERYTHING

This alone restores `t4h_bridge_invoke`. Do this first.

Project: `t4h-remote-mcp-server-clean` (Vercel team `team_IKIr2Kcs38KGo8Zs60yNtm7Y`).

Update env vars:

```
T4H_BRIDGE_URL = https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke
T4H_BRIDGE_KEY = <value from cap_secrets.BRIDGE_API_KEY where is_canonical=true and is_deprecated=false>
                  (len=57, prefix bk_gfTUR..., updated 2026-04-23)
```

Trigger a redeploy (or set env vars to apply on next request — Vercel reads on cold start).

**Verify:** `curl -fsSL https://t4h-remote-mcp-server-clean.vercel.app/healthz` should still return 200, and `t4h_bridge_invoke {fn:troy-sql-executor, payload:{sql:"SELECT 1"}}` from Anthropic chat should now succeed (no more 401).

---

### STEP 1 — push patched MCP server to GitHub (LOG)

Repo: `TML-4PM/t4h-remote-mcp-server-clean`, branch `main`, file `index.js`.

```bash
# Set canonical key once
export BRIDGE_API_KEY=$(  curl -sS -X POST https://t4h-remote-mcp-server-clean.vercel.app/mcp ...  )
# (or just paste it from Vercel env)

# Push via fn_github_push through the bridge:
python3 deploy_bridge_fix.py --skip-deploy
```

Or manually in the GitHub UI: replace `index.js` contents with `index_patched.js`. Commit message: `fix(masking): kill command:null + ; rejection + surface pg fields + /diag (v3.3.0)`.

Vercel auto-deploys on push to main. Wait ~60s.

**Verify:**

```bash
curl -fsSL https://t4h-remote-mcp-server-clean.vercel.app/diag | jq
# Should return JSON with env_present, supabase_ping (real result or full pg error fields), bridge_ping
```

---

### STEP 2 — push canonical clients to TML-4PM/the-pen (LOG)

```bash
python3 deploy_bridge_fix.py --skip-deploy
```

Pushes:
- `tools/bridge/bridge_sql.py`
- `tools/bridge/bridgeSql.mjs`

Update any internal callers' imports to use these.

---

### STEP 3 — deploy patched troy-sql-executor Lambda (GATED)

Dry-run first:

```bash
python3 deploy_bridge_fix.py --skip-github           # builds + dry-runs deploy
python3 deploy_bridge_fix.py --skip-github --execute # flips Lambda code + verifies
```

Behavioural change: pg errors now return HTTP 400 with `{ok:false, code, message, details, hint}` instead of HTTP 200 with `{sql_error: "...", command: null}`.

This is **strictly better** — old clients that swallowed `r.ok` will now correctly fail loud. New `bridge_sql.py` clients handle both shapes either way.

**Verify:**

```bash
python3 deploy_bridge_fix.py --baseline-only
# Expect:
#   ok_select    http=200  command='SELECT'  code=None      msg=None
#   bad_relation http=400  command=None       code='42P01'   msg='relation ... does not exist'
#   bad_syntax   http=400  command=None       code='42601'   msg='syntax error...'
```

---

### STEP 4 — re-run Anthropic chat probes (AUTO)

After STEP 0 alone, the MCP tools should work in Anthropic chat. Smoke:

| Tool | Expected after STEP 0 only | Expected after STEP 1 too |
|---|---|---|
| `health_check` | works (already does) | works |
| `supabase_sql_read {sql:"SELECT 1"}` | works | works |
| `supabase_sql_read {sql:"SELECT 1;"}` | **still fails** (`;` blocked) | works |
| `t4h_bridge_invoke {fn:troy-sql-executor, payload:{sql:"SELECT 1;"}}` | works | works |
| `aws_lambda_inspect {functionName:"troy-sql-executor"}` | works | works |

---

## Rollback

| Step | Rollback |
|---|---|
| 0 (Vercel env) | restore prior values from Vercel deploy history |
| 1 (MCP push) | `git revert` the commit; Vercel auto-redeploys prior |
| 2 (clients push) | `git revert` in `the-pen` |
| 3 (Lambda) | `troy-lambda-deploy` with the prior version's zip — keep the previous `troy-sql-executor.zip` cached before flipping |

---

## Why this is "kill the masking"

| Old behaviour | New behaviour |
|---|---|
| `troy-sql-executor` returns `{sql_error: "syntax error", command: null}` HTTP 200 | returns `{ok:false, code:"42601", message:"syntax error", details:..., hint:...}` HTTP 400 |
| Python wrapper: `if data.get("error"): ...` then silently returns `rows:[]` on `command:null` | Raises `BridgeSqlError(where="command_null", code, message, details, hint)` — never silent |
| Node wrapper: `if (!r.ok) throw new Error(...)` swallows pg fields | `throw new BridgeSqlError({http_status, code, message, details, hint, where, body})` |
| MCP `supabase_sql_read`: `Error("HTTP 400: <text>")` | `BridgeFetchError` with parsed pg fields, surfaced through `/mcp` 500 path |
| MCP `/mcp` 500: `{ok:false, error:"MCP_REQUEST_FAILED", message: err.message}` | adds `code, details, hint, where, http_status, url, body_preview` |
| No way to triage Vercel env from outside | `GET /diag` returns env presence + live supabase + bridge pings with full error context |
