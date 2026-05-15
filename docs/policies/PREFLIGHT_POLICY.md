# Pen Preflight Policy

**Status:** canonical — enforced by `process-issue-actions.yml`, `fn_github_issue_action`, and the runtime-truth house rule (#112).
**Authority:** GLOBAL_RULE_KERNEL_V6 § runtime_truth_layer + observability + execution_governance.
**Scope:** every worker, agent, lambda, MCP tool call, and human-issued execution.

## The rule (one sentence)

No execution without a runtime-truth probe in the previous 60 seconds; no claim of REAL without a typed receipt; no continuation past a failed preflight without an explicit recovery transition.

## Required preflight payload (every worker, every cycle)

```json
{
  "actor_id":       "<lambda or worker name>",
  "runtime_id":     "<vercel deployment id | aws request id>",
  "execution_id":   "<uuid v4>",
  "execution_nonce":"<sha256(intent + ts)>",
  "probe": {
    "mcp_health": "<result of T4H Remote MCP Clean:health_check>",
    "bridge_url": "<T4H_BRIDGE_URL from env>",
    "supabase_ping": "<SELECT 1 latency_ms>",
    "github_pat_alive": "<HEAD /user latency_ms or 401>"
  },
  "ts": "<ISO8601 UTC>"
}
```

If any probe field is `null`, `error`, or older than 60s: HALT with status `BLOCKED.preflight_stale` and write a `recovery_log` row to `ops.reality_ledger`.

## Probe sources (canonical)

| Probe | Tool / endpoint | Pass condition |
|---|---|---|
| MCP health | `T4H Remote MCP Clean:health_check` | `ok=true`, `version` matches deployed |
| Bridge | `GET https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/health` | HTTP 200 |
| Supabase | `SELECT 1` via `supabase_sql_read` | `result[0]['?column?']=1` |
| GitHub PAT | `GET https://api.github.com/user` with `cap_secrets.GITHUB_PAT` | HTTP 200 |
| Cron heartbeat | `SELECT max(updated_at) FROM ops.work_queue` < 5 min | within window |

## Implementation contract

1. **Lambdas** (AWS, ap-southeast-2): import `t4h_preflight.py` from `_canon/preflight/` in this repo. Call `t4h_preflight.run()` as the first statement of every handler. Failures emit to CloudWatch with `level=fatal` and a `BLOCKED` row to `ops.reality_ledger`.
2. **Postgres functions** that touch external systems (`fn_github_push`, `fn_github_issue_action`, etc.): begin with `PERFORM ops.fn_preflight_assert()`; on failure, raise `EXCEPTION 'BLOCKED.preflight_stale'`.
3. **MCP server** (Vercel `t4h-remote-mcp-server-clean`): the `/mcp` route runs `health_check` internally on every tool call when `MCP_ENFORCE_PREFLIGHT=true`.
4. **GitHub Actions workflows**: must start with a `preflight` job that calls the MCP health endpoint and gates all subsequent jobs on its `success` output.

## Recovery transitions

| Failed probe | Required action | Bounded retry |
|---|---|---|
| MCP health 5xx | Hit `https://t4h-remote-mcp-server-clean.vercel.app/api/redeploy` or re-trigger latest Vercel deployment | 3 attempts, 30s apart |
| Bridge 401 | Rotate `T4H_BRIDGE_KEY` from `cap_secrets` → AWS Secrets Manager; do **not** retry with the dead key | 1 attempt |
| Supabase ping timeout | Switch to read-replica via `SUPABASE_READ_URL`; flag `degraded` in telemetry | 5 attempts |
| GitHub 401 | Rotate `GITHUB_PAT` via `public.fn_rotate_github_pat`; block writes until 200 | 1 attempt |

## Telemetry contract

Every preflight (pass or fail) writes one row to `ops.reality_ledger` with:
- `intent = 'preflight:' || actor_id`
- `status` one of `REAL` (all green), `PARTIAL` (degraded), `BLOCKED` (any required probe failed)
- `evidence.probe` carries the full probe payload
- `coax_session` matches the worker's session ID

Query for the last 24h of failures:
```sql
SELECT actor_id, status, count(*)
FROM ops.reality_ledger
WHERE intent LIKE 'preflight:%' AND status != 'REAL' AND created_at > now() - interval '24 hours'
GROUP BY 1,2 ORDER BY 3 DESC;
```

## House rule alignment

This policy operationalises:
- #112 `HOUSE RULE: Inspect runtime truth, not memory`
- #111 `POSTMORTEM: treated proven infrastructure as hypothetical`
- #114 `Enforce Pen preflight across all workers and agent starts`
- GLOBAL_RULE_KERNEL_V6 `runtime_truth_layer`, `observability`, `execution_governance`

## Replay & audit

```
SELECT * FROM ops.reality_ledger
WHERE intent='preflight-policy-v1-canonical' AND status='REAL';
```

First commit of this file IS the activation event. Receipt: see commit hash on this file.
