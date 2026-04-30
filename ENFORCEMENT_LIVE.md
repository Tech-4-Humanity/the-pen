# ENFORCEMENT_LIVE — runtime truth

```yaml
doc:
  version: "1.0"
  parent: "MCP_EXECUTION_CONTRACT.md"
  wins_over: ["GLOBAL_RULE.md", "MCP_EXECUTION_CONTRACT.md"]   # runtime > law on conflict
  scope: "What is *actually* enforcing right now, by SQL probe"
  last_change: "2026-04-30"
  guarantee: "Every claim below resolves to a SELECT you can run yourself"
```

This doc is the runtime backstop. If the two parents say one thing and the database says another, **the database is the truth and this doc reports it**. Everything below is bound to a probe — paste the SQL, see the answer.

---

## 1. The two enforcement engines (live, hourly)

Two independent systems verify reality every hour. Both already exist; both are green as of 2026-04-30 09:17 UTC.

### 1.1 `core.contract_sections` — high-level rule verifier

| Section | Status | What it checks |
|---|---|---|
| `S0_CORE` | REAL | meta — present + reachable |
| `S1_REGISTRY` | REAL | `core.registry_entities` row count |
| `S2_CUSTOMER_30S` | REAL | meta |
| `S3_EXEC_CHAIN` | REAL | active cron job count |
| `S4_PROOF` | REAL | evidence exists |
| `S5_ENFORCEMENT` | REAL | meta — this very loop |
| `S6_CLASSIFY` | REAL | classification constraint exists |
| `S7_MVS` | REAL | `core.registry_entities` minimum viable surface |
| `S8_FIRST_TARGET` | REAL | `core.v_asset_drift` row count |
| `S9_SUCCESS` | REAL | success-record count ≥ threshold |
| `S10_IDEMPOTENT` | REAL | `public.email_idempotency` table present |
| `S11_ROLLBACK` | REAL | `core.rollback_snapshots` table present |
| `S12_KILLSWITCH` | REAL | `public.cap_secrets` table present |
| `S13_RDTI` | REAL | `t_require_rdti_tag` trigger present on registry |
| `S14_BROADCAST` | REAL | `public.t4h_canonical_changes` row count |
| `S15_AUTONOMY_TIER` | REAL | distinct `autonomy_tier` ≥ 2 |

**Driver:** `cron.job 251` — `contract-v2-verify-hourly` at `:17` past every hour, fires `ops.rpc_contract_verify()`.
**Log:** `core.contract_verifications` — last 24h shows **384 REAL** verdicts, zero PARTIAL or PRETEND.

```sql
-- live status of every section
SELECT section_id, status, last_verified_at,
       LEFT(verify_sql, 80) AS verify_preview
FROM   core.contract_sections
ORDER  BY section_id;

-- 24h verdict distribution
SELECT result_status, count(*)
FROM   core.contract_verifications
WHERE  verified_at > now() - interval '24 hours'
GROUP  BY 1;
```

### 1.2 `public.reality_verification_jobs` — operational probe verifier

Every row is a `(system, component, check_query, expected_result)` tuple. `fn_run_verification()` runs them all, compares actual JSONB output to expected JSONB, writes PASS/FAIL → `public.reality_ledger`.

**Driver:** `cron.job 213` — `cc-reality-verification-hourly` at `:12` past every hour.
**Log:** `public.reality_ledger`.

```sql
-- current ledger by system
SELECT system, status, count(*)
FROM   public.reality_ledger
GROUP  BY 1, 2
ORDER  BY 1, 2;

-- failing probes only
SELECT system, component, evidence, last_verified
FROM   public.reality_ledger
WHERE  status <> 'REAL'
ORDER  BY last_verified DESC;
```

### 1.3 Bridge selftest — `troy-sql-executor` health

`fn_run_sql_selftest` runs 11 cases through `run_sql` RPC every hour at `:07`. Currently `11/11 PASS`, last transition `PASS→PASS`, gap < 15min.

```sql
SELECT * FROM ops.v_bridge_selftest_freshness;
-- is_fresh true → bridge SQL plane healthy
-- last_verdict PASS, last_ratio 11/11 → all RPC paths working
```

---

## 2. Probe pack — quick health scan

Paste any of these. They are all read-only and bridge-callable.

```sql
-- A. control_plane health
SELECT * FROM ops.v_bridge_selftest_freshness;

-- B. cron job health (active + recent failures)
SELECT count(*) FILTER (WHERE active)        AS active_jobs,
       count(*) FILTER (WHERE NOT active)    AS inactive_jobs
FROM   cron.job;

-- C. canonical_changes throughput (last 24h)
SELECT change_type, count(*)
FROM   public.t4h_canonical_changes
WHERE  created_at > now() - interval '24 hours'
GROUP  BY 1
ORDER  BY 2 DESC;

-- D. bridge invocations 24h (per fn)
SELECT function_name, last_invocation_status, invocation_count
FROM   public.mcp_lambda_registry
WHERE  is_callable = true
  AND  last_invoked_at > now() - interval '24 hours'
ORDER  BY last_invoked_at DESC NULLS LAST
LIMIT  20;

-- E. wave10 entities not at full reality
SELECT slug, lifecycle_stage, autonomy_tier, support_state_enabled
FROM   core.registry_entities
WHERE  support_state_enabled = false
   OR  autonomy_tier IS NULL
LIMIT  20;
```

---

## 3. Cron canonical map (what runs the system)

Snapshot of the load-bearing jobs as of 2026-04-30. All times UTC.

| jobid | name | schedule | duty |
|---|---|---|---|
| 213 | `cc-reality-verification-hourly` | `:12 hourly` | runs reality_verification_jobs, writes reality_ledger |
| 251 | `contract-v2-verify-hourly` | `:17 hourly` | runs contract_sections probes |
| 239 | `bridge_read_selftest_hourly` | `:07 hourly` | run_sql 11-case selftest |
| 243 | `bridge_selftest_freshness` | `*/15` | alerts if selftest stale |
| 149 | `arch_hourly_cycle` | `:05 hourly` | arch maturity reality emit |
| 230 | `cron-heartbeat-canary` | `* * * * *` | per-minute alive proof |
| 231 | `cron-watchdog-reactivate` | `*/5` | re-enables jobs that silently went `active=false` |
| 253 | `closedloop_db_heartbeat_1min` | `* * * * *` | bridge_orchestrator heartbeat |
| 261 | `subsystem_heartbeat_check_10m` | `*/10` | detects dead subsystems |
| 174 | `refresh-revenue-register` | `:07 hourly` | revenue rollup |
| 167 | `bridgerunner-dispatch` | `*/5` | bridge work dispatch |
| 196 | `spine-runner-eternal` | `*/2` | core orchestrator tick |
| 144 | `closure-main-loop` | `*/10` | task closure sweep |
| 244 | `wave20-sweeper` | `*/30` | wave-20 housekeeping (currently dormant per `WAVE21_ENABLED=OFF`) |
| 263–266 | `wave21_*` | `* * * * *` and `*/2` | governor + reaper + telemetry — DORMANT until kill-switch flipped |

Total active cron jobs as of probe: **198**.

```sql
SELECT count(*) FROM cron.job WHERE active = true;
```

---

## 4. Enforcement RPCs (stable contracts)

These are the public functions an operator may invoke directly through the bridge. All return-typed, all idempotent.

| RPC | Purpose | Bridge call |
|---|---|---|
| `ops.rpc_contract_verify()` | re-run all contract section probes | `{"fn":"troy-sql-executor","payload":{"sql":"SELECT * FROM ops.rpc_contract_verify();"}}` |
| `public.fn_run_verification()` | re-run reality_verification_jobs | `…{"sql":"SELECT public.fn_run_verification();"}` |
| `public.fn_run_sql_selftest('manual')` | bridge SQL plane selftest | `…{"sql":"SELECT public.fn_run_sql_selftest('manual');"}` |
| `public.fn_arch_emit_execution(slug, payload)` | emit reality event for an entity | per arch_hourly_cycle |
| `ops.fn_check_selftest_freshness()` | alerts if selftest stale | per `*/15` cron |
| `ops.enforce_closure(...)` | mark workstream closed | review params before fire |

---

## 5. The five hard runtime invariants

These are what the cron jobs above are actually checking. If any goes red, the system halts new writes until repaired.

1. **Bridge SQL plane reachable** — `ops.v_bridge_selftest_freshness.is_fresh = true`. Goes red → `troy-sql-executor` writes blocked.
2. **Contract sections all REAL** — `core.contract_sections.status = 'REAL'` for all 16. Goes red → corresponding capability claims as PARTIAL/PRETEND.
3. **Cron heartbeat present** — `cron.job 230` writes a row every minute. Goes silent > 3min → `cron-watchdog-reactivate` flips other dead jobs back on; if 230 itself is dead, the whole scheduler is broken.
4. **Bridge orchestrator heartbeat** — `cron.job 253` reports `OK` per minute. Goes silent → autonomy lanes pause.
5. **Idempotency table present** — `public.email_idempotency` and natural-key guards (`memory_key`, content-SHA, `ON CONFLICT`) wired on every write path. Goes missing → S10 flips to PRETEND.

---

## 6. Trap appendix (live runtime gotchas, in addition to GLOBAL_RULE §8)

These are observed behaviours, not theoretical risks.

**T16 — `$body$` collision in `fn_github_push`.** Pushing markdown that contains literal `$body$` example text closes the dollar-quoted SQL literal early, returning `sqlstate 42601 syntax error at or near ".."`. Fix: pick a unique tag (`$DOCBODY_<date>_xxx$`) and grep the doc for collision before fire. Witnessed 2026-04-30 pushing `MCP_EXECUTION_CONTRACT.md`.

**T17 — `mcp_lambda_registry.callable_reason` for `troy-sql-executor` lies about envelope.** Registry says `{fn, sql}`. Actual is `{fn, payload:{sql}}`. Fix queued (single UPDATE row). Until fixed, trust `MCP_EXECUTION_CONTRACT.md §2`.

**T18 — `troy-sql-executor` masks RETURNING.** INSERT/UPDATE return `count: 1, rows: []` even on success. Always verify writes via PostgREST direct read. Documented in `GLOBAL_RULE.md §8 trap 13`.

**T19 — `cc.v_registry_drift` does not have a column called `drift_status`.** Earlier docs assume one. Probe the view first before composing aggregate queries against it:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_schema='cc' AND table_name='v_registry_drift';
```

**T20 — `closedloop.v_subsystem_heartbeat` does not exist.** It's referenced in scratch but the actual heartbeat read is `closedloop.heartbeat` table or `cron.job 261` log output. Don't assume views from older session notes.

---

## 7. Self-verification of this very document

```sql
-- This doc is committed to TML-4PM/the-pen and logged here:
SELECT id, created_at, title, change_hash, evidence_ref
FROM   public.t4h_canonical_changes
WHERE  memory_key = 'enforcement-live-v1-deploy';
```

If the row above does not exist, this document is not yet sealed. If it exists but the `change_hash` does not match the file you are reading, you are on a stale copy — re-fetch from the canonical commit listed in `evidence_ref`.

---

## 8. When to update this doc

When **any** of these change:
- A new `core.contract_sections` row is added (rule list above grows).
- A cron job in §3 is added, retired, or rescheduled.
- A new RPC is added to §4 or one is deprecated.
- A new trap is observed in production (append to §6, never delete).

Update path: edit local → push via `fn_github_push` (with unique tag, see T16) → seal `t4h_canonical_changes` row keyed on `memory_key='enforcement-live-v<n>-deploy'` → verify via PostgREST per trap T18.

End.
