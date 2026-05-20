# Bridge Runner Contract — the-pen

## Status
ACTIVE — GitHub Actions native runner (mirror of TML-4PM/mcp-command-centre@e922356)

## Execution Path
```
bridge/payloads/*.json commit
  → .github/workflows/bridge-runner.yml triggers
  → payload read + request_id extracted
  → Bridge endpoint invoked (POST with x-api-key)
  → receipt written to bridge/receipts/{request_id}.receipt.json
  → receipt committed back to repo [skip ci]
```

## Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| `bridge-runner.yml` | push to `bridge/payloads/*.json` | Execute payloads, write receipts |
| `bridge-runner-heartbeat.yml` | cron every 15 min | Prove runner is alive |
| `bridge-runner-diagnostics.yml` | manual dispatch | Check secrets, connectivity, inventory |

## Required Repo Secrets

Set at: `Settings → Secrets → Actions`

| Secret | Purpose |
|---|---|
| `BRIDGE_ENDPOINT` | Bridge HTTP endpoint URL |
| `BRIDGE_API_KEY` | Auth header value |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Supabase service role key |

## Receipt Status Values
- `REAL` — Bridge returned 2xx, receipt written with response
- `PARTIAL` — Runner ran, Bridge returned non-2xx
- `BLOCKED` — Secrets not configured or endpoint unreachable
- `SKIPPED` — No changed payload files in push

## Parity Notes
the-pen is the universal intake gate — all T4H work flows through here. This runner gives the-pen the same payload→receipt loop as mcp-command-centre, so any payload committed to `bridge/payloads/` is executed and receipted without any session, workstation, or manual trigger.

## Anti-patterns Eliminated
- ❌ Silent payload drops
- ❌ EventBridge rule disabled without notice
- ❌ Lambda poller with stale SSM state
- ❌ Receipt never written
- ❌ False REAL without HTTP proof
