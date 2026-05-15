# Service Catalog Runtime — Smoke Test Results

**Date:** 2026-05-16  
**Project:** Supabase S1 `lzfgigiyqpuuxslsygjt`  
**Branch:** main  
**Runtime:** ops.*

## Test 1 — fn_classify_session (4 cases)

| Input | Expected | Got |
|---|---|---|
| `last_refresh_at = now() - 20d` | `STALE`, `mutation_allowed=false`, age 1,728,000s | `STALE`, `false`, `1,728,000` ✅ |
| `last_refresh_at = now() - 10m` | `CURRENT`, `mutation_allowed=true`, age 600s | `CURRENT`, `true`, `600` ✅ |
| contradiction flag | `CONTRADICTED`, `mutation_allowed=false` | `CONTRADICTED`, `false` ✅ |
| (not registered) | not applicable | (gate test below) |

## Test 2 — fn_mutation_gate (4 cases)

| Session state | Expected | Got |
|---|---|---|
| STALE | `allowed=false`, `reason=session_stale` | ✅ |
| CURRENT | `allowed=true`, `execution_nonce` returned | ✅ (nonce `efee3170-…`) |
| CONTRADICTED | `allowed=false`, `reason=session_contradicted` | ✅ |
| Unregistered session | `allowed=false`, `reason=session_not_registered` | ✅ |

## Test 3 — fn_quote_catalog_item

| Catalog | Tier | Qty | Result | Subtotal AUD | Margin AUD |
|---|---|---|---|---|---|
| OR-RB-001 | starter | 1 | REAL | 499.00 | 259.00 |
| OR-RB-001 | starter | 2 | BLOCKED `quantity out of tier bounds` ✅ | — | — |
| OR-RB-001 | family | 3 | REAL | 3,897.00 | 1,947.00 |
| AHC-SP-001 | discovery | 1 | REAL | 7,500.00 | 4,700.00 |
| WFA-WF-001 | team | 1 | REAL | 1,999.00 | 1,049.00 |
| NO-SUCH-ITEM | — | 1 | BLOCKED `unknown catalog_id` ✅ | — | — |

## Test 4 — fn_record_contradiction

T4H Remote MCP Clean stale claim → contradiction recorded (id `9707c1a4-…`), severity HIGH, status OPEN. Authority pending bucket shows it.

## Test 5 — fn_runtime_tick

First tick: `marked_stale=0`, `quarantined=0`, `contamination receipts_missing_sha=1`, `catalog_decayed=0`. Runtime receipt written.

## Test 6 — Command Centre views

| View | Live? | Sample |
|---|---|---|
| `ops.v_cc_runtime_health` | ✅ | 2 sessions_current, 3 stale, 2 contradictions, 3 catalog gaps (MISSING_SLA), 0 errors 24h |
| `ops.v_cc_freshness` | ✅ | sessions/catalog/audits split |
| `ops.v_cc_catalog_overview` | ✅ | 3 items × 3 tiers × 2 quotes_30d |
| `ops.v_cc_economic_health` | ✅ | quotes_30d totals per catalog_id |
| `ops.v_cc_authority_pending` | ✅ | 2 contradictions + 3 catalog_gaps |
| `ops.v_catalog_gaps` | ✅ | All 3 items: `MISSING_SLA` |

## Test 7 — pg_cron schedule

| jobid | jobname | schedule |
|---|---|---|
| 320 | ops_runtime_tick | `*/5 * * * *` |
| 321 | ops_session_sweep_hourly | `7 * * * *` |
| 322 | ops_audit_sweep_daily | `17 3 * * *` |
| 323 | ops_contamination_scan_daily | `23 4 * * *` |
| 324 | ops_freshness_decay_daily | `37 5 * * *` |

## Result

**status: REAL**

All seven test categories pass. Gates enforce. Sweepers run. Quotes generate. Contradictions register. Telemetry emits. Cron live.

## Known PARTIAL items (not test failures, real gaps)

- All 3 catalog items report `MISSING_SLA` (audit_status=PARTIAL) — by design, surfaces in `v_catalog_gaps`
- Pricing tiers marked PROVISIONAL — need commercial validation before any item moves to ACTIVE
- 2 open contradictions about T4H Remote MCP Clean status — pending resolution
- 1 historical receipt without `instruction_sha` — flagged by `fn_scan_contamination`
