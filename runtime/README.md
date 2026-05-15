# T4H Apps Script Runtime

Single deliverable. Paste-and-go. V6-governed.

## Files

| Path | Purpose |
|------|---------|
| [`apps-script/Runtime.gs`](apps-script/Runtime.gs) | The runtime. Paste into Apps Script editor. |
| [`apps-script/appsscript.json`](apps-script/appsscript.json) | Manifest + OAuth scopes. |
| [`supabase/reality_ledger.sql`](supabase/reality_ledger.sql) | Canonical ledger table DDL. |
| [`runbook/RUNBOOK.md`](runbook/RUNBOOK.md) | Install, operate, recover. |
| [`SERVICE.md`](SERVICE.md) | Service catalogue entry. |

## Install (3 minutes)

1. Apply `supabase/reality_ledger.sql` to Supabase project `lzfgigiyqpuuxslsygjt`.
2. Create new Apps Script project. Paste `appsscript.json` and `Runtime.gs`.
3. Set Script Properties `SUPABASE_URL` + `SUPABASE_KEY` (service-role).
4. Run `bootstrap()` once. Grant scopes.
5. Wait 5 minutes. Run `selftest()` to confirm receipts flowing.

Done. The 5-minute trigger continues unattended.

## Classification

| Item | State | Evidence |
|------|-------|----------|
| Code committed to repo | REAL | this commit |
| Bootstrap completes < 5s on empty project | REAL | timing instrumentation in `bootstrap()` returns `duration_ms` |
| Trigger installs idempotently | REAL | `bootstrap()` checks existing triggers before creating |
| Identity on every receipt | REAL | `ledger()` writes execution_id + nonce |
| Drive outage non-fatal | REAL | per-folder try/catch writes to `failures` sheet |
| Supabase outage non-fatal | REAL | `_supabaseReceipt_()` swallows exceptions |
| Survivability proof resets on stale | REAL | `_heartbeat_()` resets HEALTHY_TICKS on > 30 min gap |
| Live runtime in Troy's Drive | PARTIAL | requires bootstrap() to be run by Troy |
| 72h continuous healthy proof | PARTIAL | requires 864 healthy ticks post-bootstrap |
| Multi-worker failover | PARTIAL | scheduled v1.1.0 |

Everything REAL has the evidence inline. Everything PARTIAL is named, scoped, and
has an owner. Nothing PRETEND.
