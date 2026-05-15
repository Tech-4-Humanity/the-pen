# Blocker Matrix — Red-Line Control Plane

Last updated: 2026-05-15T21:26:26Z
Probe run: rcpt-probe-2026-05-15-001
Reality state: PARTIAL (4 of 6 blockers cleared by probe)

## Probe-confirmed runtime preconditions

| Component | Required | Observed | Status |
|---|---|---|---|
| `fn_github_push` | exists in `pg_proc` | `proname=fn_github_push`, returns `jsonb`, body 3488 bytes | REAL |
| `http` extension | installed | `extname=http` | REAL |
| `t4h_canonical_changes` | table exists | 26 cols, 3,240 rows total, 2,744 last 7d | REAL |
| `cap_secrets.GITHUB_PAT` | present, not deprecated | `is_deprecated=false` | REAL |
| `cap_secrets.GITHUB_TOKEN` | present, not deprecated | `is_deprecated=false` | REAL |
| `cap_secrets` overall | populated | 417 rows total | REAL |

Conclusion: the runtime path `fn_github_push → http → GitHub → t4h_canonical_changes` is **structurally REAL**. The remaining blockers are not missing infrastructure — they are schema drift, contamination, and dispatcher absence.

## Active blockers

### B-01 — Receipt model drift (CRITICAL)

| Field | Value |
|---|---|
| Severity | CRITICAL |
| Reality | PARTIAL |
| Surface | `public.t4h_canonical_changes` |
| Evidence | Schema has 26 flat columns: `id, created_at, change_type, title, summary, affected[], evidence_ref, author, broadcast_to[], broadcast_at, broadcast_ok, memory_key, severity, change_hash, body_md, audiences[], is_rd, project_code, business_keys[], sealed, sealed_at, rollback_of, emit_status, llm_source, thread_id`. No lifecycle phase column, no parent_receipt_id, no direction, no repair object, no runtime object. |
| Drift | Runtime writes one flat row per push. v2 schema requires lifecycle phases (`dispatch | acceptance | implementation | runtime | closure | blocker | repair | probe`). |
| Repair | Add columns `receipt_type`, `parent_receipt_id`, `direction`, `reality_state`, `runtime jsonb`, `repair jsonb`, `blockers text[]`. Migration owner: `migrations/2026-05-16_receipt_lifecycle_v2.sql` (not yet drafted). |
| Linked issue | #108 |
| Closure receipt type | `implementation` then `runtime` |

### B-02 — #107 PRETEND receipt contamination

| Field | Value |
|---|---|
| Severity | HIGH |
| Reality | BLOCKED |
| Surface | Historical rows in `t4h_canonical_changes` where `change_type` was set without corresponding HTTP receipt. |
| Repair | Quarantine RPC: `public.fn_receipt_quarantine(p_change_hash text)` — flags `sealed=false, emit_status='quarantined'`. Not yet created. |
| Linked issue | #107 |
| Closure receipt type | `blocker → repair → closure` chain |

### B-03 — #106 runtime route status

| Field | Value |
|---|---|
| Severity | MEDIUM |
| Reality | PARTIAL |
| Surface | Runtime invocation path (Bridge vs direct connector). |
| Evidence | This probe was executed via Supabase Official Connector, not the Bridge. Bridge keys are 401 across all combinations (see user memory). |
| Decision | Bridge reserved for AWS/Vercel/GitHub; SQL via Supabase connector is canonical. Update `global/MCP_EXECUTION_CONTRACT.md` accordingly. |
| Linked issue | #106 |
| Closure receipt type | `implementation` |

### B-04 — #108 asset/deploy chain ambiguity

| Field | Value |
|---|---|
| Severity | MEDIUM |
| Reality | PARTIAL |
| Surface | `programs/red-line-control-plane/` itself once schema v2 is adopted by the runtime function. |
| Repair | Once `t4h_canonical_changes` has lifecycle columns, fold v2 into `global/RECEIPT_SCHEMA.json` and deprecate the flat schema. |
| Linked issue | #108 |

### B-05 — Audit/repair dispatcher absent

| Field | Value |
|---|---|
| Severity | HIGH |
| Reality | PARTIAL |
| Surface | No autonomous loop reading the receipt table for failures and emitting repair jobs. |
| Repair | See `audit_repair_dispatcher_v1.md`. Required: pg_cron job + RPC `fn_red_line_dispatcher_tick()` that scans for `reality_state IN ('PARTIAL','BLOCKED','FAILED')` and emits repair receipts. |
| Linked issue | #102 |

### B-06 — Probe results not persisted as receipts

| Field | Value |
|---|---|
| Severity | LOW |
| Reality | CLOSED — see `runtime_receipts/2026-05-15_probe_run_001.json` |
| Closure | This commit. |

## Closure path

```text
B-06  →  CLOSED (this commit)
B-03  →  needs MCP_EXECUTION_CONTRACT amendment
B-01  →  needs migration 2026-05-16_receipt_lifecycle_v2.sql
B-02  →  needs fn_receipt_quarantine + scan of historical rows
B-05  →  needs fn_red_line_dispatcher_tick + pg_cron schedule
B-04  →  resolves automatically when B-01 lands
```

When all six are CLOSED, program reality_state flips to REAL.
