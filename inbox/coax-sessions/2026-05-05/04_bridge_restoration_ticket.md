# Bridge Restoration Ticket — Symbio (DEV exec)
**Owner**: COAX → Symbio | **Squad**: P10-G8 (Amy Holland) + P10-A3 (Isabelle Courtois) infra | P05-J9 (Earl Anderson) routing/health | P10-B4 (Ryan Taylor) HITL gate verifier
**Priority**: P1 — blocking all write operations across portfolio
**Generated**: 2026-05-05

---

## Symptom
- Anthropic MCP connector to `t4h-remote-mcp-server-clean.vercel.app/mcp` returns "Error occurred during tool execution" on every call
- Memory recent-update (02 May 26) says server itself is HEALTHY v3.4.1 / v3.5.0 — failure is at the **MCP wrapper / Streamable HTTP layer** between Claude.ai and the Vercel deployment
- Direct execution via canonical bridge `zdgnab3py0...amazonaws.com` reportedly still works; we just can't reach it from this Claude session through the connector
- API key `bk_tOH8...` returned 403 in earlier probe — burned, must be rotated

## Diagnostic Steps (in order, halt on first that fails)

### Step 1: Verify Vercel deployment is actually live
```bash
curl -i https://t4h-remote-mcp-server-clean.vercel.app/health
# Expect: 200 OK, JSON with version v3.5.0+
```
- If 200: server is up, problem is wrapper or auth → Step 2
- If 5xx or timeout: deployment dead, need redeploy → Step 4

### Step 2: Verify canonical bridge directly
```bash
curl -X POST https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke \
  -H "x-api-key: <ROTATED_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"action":"invoke_function","function_name":"troy-sql-executor-s2","payload":{"sql":"SELECT 1 AS ping;"}}'
```
- Expect: `{"rows":[{"ping":1}]}` or similar
- If working: bridge is fine, MCP wrapper is the only blocker → Step 3
- If 403: API key needs rotation in IAM → Step 5

### Step 3: Reconfigure MCP wrapper
- Pull `t4h-remote-mcp-server-clean` repo from `TML-4PM`
- Verify `vercel.json` routes `/mcp` to the Streamable HTTP handler
- Check that the handler resolves the Lambda invoke URL correctly (not pointing at dead `m5oqj21chd`)
- Push fix → redeploy → test from Claude.ai connector

### Step 4: Redeploy if Vercel is dead
- `vercel deploy --prod --token=$VERCEL_TOKEN` from local clone
- Wait for READY status
- Re-test Step 1

### Step 5: Rotate burned API key
- Revoke `bk_tOH8...` in API Gateway usage plans
- Generate new key, update Vercel env var `BRIDGE_API_KEY`
- Update Supabase `cap_secrets` row with new value, mark old as `is_deprecated=true`
- Redeploy MCP server with new env

## Verification Suite (post-fix)
| Check | Method | Expected |
|---|---|---|
| Health endpoint | curl /health | 200 OK |
| MCP tool call from Claude | `health_check` tool | non-error response |
| SQL read | `SELECT 1;` | rows returned |
| SQL write (gated) | dry-run insert into `ops.coax_inbox` | success with allowWrite=false → blocked correctly |
| HITL gate | attempt destructive op | blocked correctly |

## Definition of Done
1. Claude.ai MCP connector calls return non-error responses
2. SQL read returns real data within 2s
3. Gated writes correctly block when `allowWrite=false`
4. Burned API key removed from all surfaces
5. Receipt logged: SHA of fix commit + deployment URL + verified-by timestamp

## Blocker for everything downstream
Until this is fixed:
- ❌ Cannot verify RDTI lodgement evidence in MAAT
- ❌ Cannot dump Supabase rows for Strip-Consume
- ❌ Cannot pull live revenue/cost for Portfolio Re-rank
- ❌ Cannot deploy `ops.llm_session_register` schema
- ❌ Cannot run any pg_cron health checks

## Workaround Available (this session)
- Planning, drafting, framework-building all fine here
- Direct bash to public URLs works for Step 1 + Step 2 verification
- Can stage all DDL and SQL for batch-execution on bridge return
