# T4H Apps Script Runtime — Runbook v1.0.0

**Status:** PRODUCTION-READY • **Tier:** NORMAL • **Cadence:** 5 min triggers
**Governance:** GLOBAL_RULE_KERNEL_V6 compliant
**Constitution clauses satisfied:**
- `autonomous_continuity` — no session/workstation/manual dependency
- `distributed_identity` — actor_id, execution_id, nonce per receipt
- `ledger.states` — REAL / PARTIAL / BLOCKED only
- `recovery_layer` — chunked + checkpoint + tiered self-heal
- `telemetry_native_governance` — every state transition writes evidence

---

## 0. What this is

A Google Apps Script runtime that scans Drive, writes governed receipts to a
Spreadsheet ledger + Supabase, runs unattended via 5-minute time triggers, and
self-heals using a tiered timing model. Bootstrap completes in seconds.
runtimeMain processes one chunk per invocation with checkpoint resume — kills
the 6-minute Apps Script execution ceiling problem for good.

## 1. Install (one-time, ~3 min)

### 1a. Create the script project
1. Open https://script.google.com → **New Project**.
2. Rename project to `T4H Runtime Drive`.
3. Click the **Project Settings** (gear icon) → **Show "appsscript.json"** = ON.
4. Replace `appsscript.json` contents with the file at
   `runtime/apps-script/appsscript.json` from this repo.
5. Replace `Code.gs` contents with `runtime/apps-script/Runtime.gs`.

### 1b. Configure Supabase sink (optional but recommended)
In **Project Settings → Script Properties**, add:

| Property        | Value                                                          |
|-----------------|----------------------------------------------------------------|
| `SUPABASE_URL`  | `https://lzfgigiyqpuuxslsygjt.supabase.co`                     |
| `SUPABASE_KEY`  | service-role key (kept in T4H secrets vault, **not in repo**)  |

Without these, the runtime falls back to sheet-only mode (still REAL per kernel).

### 1c. Provision the Supabase table
Run `runtime/supabase/reality_ledger.sql` against Supabase project
`lzfgigiyqpuuxslsygjt`. Creates the table, indexes, RLS policy, and the two
views (`v_runtime_health`, `v_runtime_survivability`).

### 1d. Run bootstrap
In the Apps Script editor:
1. Function dropdown → `bootstrap` → **Run**.
2. Grant scopes when prompted (Drive, Sheets, ScriptApp, external_request).
3. Logs should show within seconds:
   ```
   BOOTSTRAP COMPLETE
   https://docs.google.com/spreadsheets/d/.../edit
   Duration: <2000>ms
   ```
4. Open the spreadsheet URL — confirm 4 sheets exist:
   `reality_ledger`, `heartbeat`, `drive_inventory`, `failures`.
5. Confirm trigger installed: **Triggers** (clock icon) → `runtimeMain` every 5 minutes.

### 1e. Prove it's running
Wait 5 minutes. Then:
1. Run `selftest` from the function dropdown.
2. Logs print a JSON object — expect `triggers_installed: 1`, `healthy_ticks ≥ 1`,
   `processed_total ≥ 1`.

## 2. Operational verbs

| Function          | Purpose                                                 |
|-------------------|---------------------------------------------------------|
| `bootstrap()`     | First-time install. Idempotent. Safe to re-run.         |
| `runtimeMain()`   | One scan chunk. Auto-invoked by 5-min trigger.          |
| `selftest()`      | Manual health probe. Writes `selftest_pass` receipt.    |
| `panicShutdown()` | Deletes all triggers, logs BLOCKED receipt. Surgical.   |
| `quarantine()`    | Flags runtime quarantined. Does not delete triggers.    |
| `reset()`         | Clears checkpoint + heartbeat + healthy_ticks. Restart. |

## 3. Tiered timing model (this runtime = NORMAL)

| Tier   | warn | heal | reroute | block |
|--------|------|------|---------|-------|
| HOT    | 1 m  | 3 m  | 5 m     | 10 m  |
| HIGH   | 3 m  | 10 m | 15 m    | 30 m  |
| **NORMAL** | **10 m** | **30 m** | **60 m** | **120 m** |
| LOW    | 30 m | 2 h  | 4 h     | 6 h   |

If `runtimeMain` produces no `tick_complete` receipt for **> 30 minutes**
(heal threshold for NORMAL), the survivability proof window resets and a
`survivability_reset` PARTIAL receipt is written.

72-hour survivability = **72 hours of healthy receipts**, not 72 hours of
broken-and-waiting. The proof window only counts forward from a healthy tick;
any stale gap > 30 min resets it.

## 4. Daily ops queries (Supabase)

```sql
-- Are we alive?
select * from public.v_runtime_health
 where runtime_id = 'apps-script-drive-runtime';

-- 7-day healthy ratio
select * from public.v_runtime_survivability
 where runtime_id = 'apps-script-drive-runtime';

-- Recent failures
select occurred_at, event, evidence, error
  from public.reality_ledger
 where state = 'BLOCKED'
   and runtime_id = 'apps-script-drive-runtime'
 order by occurred_at desc
 limit 20;

-- Scan progress (look for queue_remaining=0 → full sweep complete)
select occurred_at, event, evidence, folders_processed
  from public.reality_ledger
 where event in ('tick_complete','scan_complete')
   and runtime_id = 'apps-script-drive-runtime'
 order by occurred_at desc
 limit 10;
```

## 5. Self-heal decision tree

| Symptom                                       | Receipt event           | Tier action  | Manual step (only after `block`)           |
|-----------------------------------------------|-------------------------|--------------|--------------------------------------------|
| `runtime_exception` BLOCKED                   | logged with stack       | wait 1 cycle | Inspect `failures` sheet; run `selftest`   |
| `survivability_reset` PARTIAL                 | gap > 30 min            | auto-resume  | None — proof window restarts on next tick  |
| No new ledger rows for > 30 min               | n/a                     | manual probe | Run `selftest`; if BLOCKED → check triggers panel |
| Trigger missing                               | bootstrap re-runs idem  | re-install   | Run `bootstrap()` — won't duplicate        |
| Drive folder permission error                 | `failures` sheet row    | continues    | Skip folder; runtime carries on            |
| Supabase 401/5xx                              | sheet still REAL        | non-blocking | Rotate `SUPABASE_KEY` in Script Properties |

## 6. Acceptance gates (Apple-buys-tomorrow checklist)

- [x] Bootstrap < 5 s on empty project
- [x] First `runtimeMain` produces `tick_complete` REAL receipt
- [x] Spreadsheet ledger has 4 sheets with frozen header rows
- [x] Trigger installed once, idempotent on re-bootstrap
- [x] Identity layer: actor_id + execution_id + nonce on every receipt
- [x] Ledger states constrained to REAL/PARTIAL/BLOCKED (no PRETEND)
- [x] Survivability proof resets on > 30 min gap (not silently survives rot)
- [x] Drive folder error does not crash the runtime
- [x] Supabase outage does not crash the runtime
- [x] `panicShutdown()` deletes all triggers in one call
- [x] `reset()` clears state and allows clean restart
- [x] Full sweep completable via repeated 5-min ticks (chunked, no 6-min timeout)

## 7. What's deliberately NOT in v1.0.0

These are PARTIAL by design, scheduled for v1.1:

- **Multi-worker failover.** Currently single Apps Script worker. Bridge/Lambda
  alternate path is in t4h-remote-mcp-server-clean; wiring is one task away but
  out of scope for the runtime itself.
- **File-level inventory.** v1.0 captures folder structure + file counts only.
  File metadata extraction is a v1.1 chunk.
- **Cross-runtime quorum.** Requires multi-worker first.

Calling these PARTIAL is honest. Calling them done would be PRETEND.

## 8. Provenance

- Source: `TML-4PM/the-pen` → `runtime/apps-script/Runtime.gs`
- Ledger table: Supabase `lzfgigiyqpuuxslsygjt.public.reality_ledger`
- Constitution: `GLOBAL_RULE_KERNEL_V6` (user preferences, 2026-05-16)
- Author: Tech 4 Humanity Pty Ltd (ABN 70 666 271 272)
