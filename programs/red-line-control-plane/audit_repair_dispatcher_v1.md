# Audit/Repair Dispatcher v1

Status: SPEC (PARTIAL — RPC not yet implemented)
Owner: Red-Line Control Plane
Depends on: `receipt_lifecycle_v2.schema.json`, `t4h_canonical_changes` schema v2 migration (B-01).

## Purpose

Close the loop:

```text
run → fail → detect → classify → repair → re-run → receipt → close
```

No human in the loop for `safe_to_auto_run=true` repairs. Human override path reserved for legal/destructive/financial boundary breaches per GLOBAL_RULE_KERNEL_V6 §autonomy_boundary.

## Tick contract

RPC: `public.fn_red_line_dispatcher_tick() returns jsonb`

Inputs: none (reads state from `t4h_canonical_changes`).

Processing order, every tick:

1. **Scan** — select rows where `reality_state IN ('PARTIAL','BLOCKED','FAILED')` AND `sealed=false` AND `created_at > now() - interval '14 days'`.
2. **Classify** — for each row, derive `error_type` from `(change_type, severity, body_md::jsonb)`. Map to a known repair class (table below).
3. **Dispatch** — if `safe_to_auto_run=true` and `attempt_count < 3`, emit a `repair` receipt (`receipt_type='repair'`, `parent_receipt_id=<original>`) and call the repair agent RPC.
4. **Wait** — repair agent executes asynchronously; emits its own `runtime` receipt on completion.
5. **Re-probe** — on next tick, scan for `runtime` receipts whose parent is still `PARTIAL/BLOCKED` and re-evaluate.
6. **Close** — when re-probe returns REAL, emit `closure` receipt linking original → repair → runtime → closure.
7. **Escalate** — if `attempt_count >= 3` or `safe_to_auto_run=false`, emit `blocker` receipt with `repair_status='needs_human'` and route to `chat_closeout` digest.

Schedule: pg_cron, every 5 minutes (`*/5 * * * *`). Job name: `red_line_dispatcher_tick`.

## Repair class table

| error_type | repair_agent | safe_to_auto_run | max_attempts |
|---|---|---|---|
| `schema_drift` | `fn_apply_schema_migration` | false | 1 |
| `stale_receipt` | `fn_receipt_revalidate` | true | 3 |
| `pretend_contamination` | `fn_receipt_quarantine` | true | 1 |
| `runtime_401` | `fn_credential_rotate_check` | false | 1 |
| `http_timeout` | `fn_github_push` (retry) | true | 3 |
| `orphan_compute` | `fn_terminate_orphan` | true | 1 |
| `unknown` | none | false | 0 |

All repair agents must:

- accept `p_parent_receipt_id text`
- emit a `repair` receipt before starting
- emit a `runtime` receipt with raw output on completion
- never mutate without `change_hash` deduplication

## Receipt chain example (B-02 quarantine)

```text
rcpt-blocker-107-001        (receipt_type=blocker,        reality_state=BLOCKED)
  └─ rcpt-repair-107-001    (receipt_type=repair,         reality_state=PARTIAL,   repair.status=running)
       └─ rcpt-runtime-107-001  (receipt_type=runtime,    reality_state=REAL,      runtime.executed=true)
            └─ rcpt-closure-107-001 (receipt_type=closure, reality_state=REAL,     status=COMPLETE)
```

Each link uses `parent_receipt_id`. Full chain replayable via:

```sql
WITH RECURSIVE chain AS (
  SELECT id, change_hash, body_md, created_at
  FROM public.t4h_canonical_changes
  WHERE change_hash = $1
  UNION ALL
  SELECT c.id, c.change_hash, c.body_md, c.created_at
  FROM public.t4h_canonical_changes c
  JOIN chain p ON (c.body_md::jsonb->>'parent_receipt_id') = p.change_hash
)
SELECT * FROM chain ORDER BY created_at;
```

## Economic guard

Per GLOBAL_RULE_KERNEL_V6 §economic_self_regulation:

- Reject repair dispatch if same `(error_type, target)` has triggered 10+ repairs in 24h without a closure receipt — emit `orphan_compute` blocker instead.
- Decay rows from the scan window after 14 days; emit `blocker` with `repair_status='needs_human'` if still not REAL.

## Telemetry

Every tick emits one `probe` receipt summarising:

```json
{
  "receipt_type": "probe",
  "system": "red_line_dispatcher",
  "runtime": {
    "executed": true,
    "probe_name": "dispatcher_tick",
    "result_summary": "scanned=N, dispatched=M, escalated=K, closed=J"
  }
}
```

No tick is unobserved. No execution without a receipt. No receipt without an origin chain.

## Open implementation items

1. Draft `migrations/2026-05-16_receipt_lifecycle_v2.sql` (adds lifecycle columns to `t4h_canonical_changes`).
2. Implement `public.fn_red_line_dispatcher_tick()`.
3. Implement repair agents listed above (incremental, lowest-risk first: `fn_receipt_quarantine`, then `fn_receipt_revalidate`).
4. Schedule pg_cron job.
5. Add dispatcher tick to `chat_closeout` digest payload.
