# wq-rescue Dispatcher — Genesis Receipt

**Date**: 2026-04-28T00:24Z  
**Owner**: wq-dispatcher-rescue (autonomous golden loop)  
**Status**: REAL (runtime proof)

## What

Built `ops.fn_wq_claim_dispatch(p_destination, p_limit)` — a SQL-only executor that claims rows from `ops.work_queue` for `destination='symbio-verifier-v2'` and dispatches `sweepers.*` actions that the live `symbio-verifier-v2` Lambda lacks handlers for.

Pattern: extension/rescue dispatcher. Verifier handles its known actions; this dispatcher rescues rows the verifier blocks with `unknown action: <X>`.

## Why

Verified ground truth via runtime probes:
- `site-repair` lane: 213/213 archived (DEAD)
- `symbio-verifier-v2`: ALIVE — actively polling `ops.work_queue`, claims rows in <5s, writes `audit.log` events `symbio_verifier_v2_claimed` then `symbio_verifier_v2_blocked` for unknown actions
- `t4h-orchestrator` Lambda: BROKEN (`Runtime.ImportModuleError: No module named 'index'`). Phantom executor — cron 202 logs "succeeded" because `net.http_post` returns a row regardless of HTTP status
- `fn_mission_executor_poll`: only flips `orchestrator_mission.status`; no execution
- `worker_legacy_triage`: archives + pings `updated_at` only

So `ops.work_queue` had a verifier but no executor for `sweepers.remediate_inventory` / `sweepers.stage2_full_remediation`. This dispatcher closes that gap.

## How

`ops.fn_wq_claim_dispatch` claims rows matching:
- `status='ready'`, OR
- `status='claimed' AND blocked_reason ILIKE 'unknown action%'` (verifier-blocked rescue), OR
- `status='claimed' AND last_heartbeat < now()-60s` (stale claim), OR
- `status='in_progress' AND last_heartbeat < now()-5min` (orphan), OR
- `status='blocked' AND blocked_reason ILIKE 'unknown action%'` (post-block rescue), OR
- `status='done' AND proof_ref IS NULL` (incomplete)

Locks via `FOR UPDATE SKIP LOCKED`. Walks FSM `* -> in_progress -> done -> verified -> promoted -> closed` with `close_signal=true` and `proof_ref='wq-dispatcher-rescue://<job_id>'`.

Routes by `payload->>'action'`:
- `sweepers.remediate_inventory` -> `public.cmd_remediate()`
- `sweepers.stage2_full_remediation` -> `public.cmd_remediate() + public.fn_wave7_sweeper(50, NULL)`

Writes receipts:
- `ops.job_receipts`: `claimed` -> `done` -> `close_signal` (3 events per success)
- `audit.log`: `wq_rescue_claimed` + `wq_rescue_completed` (with `evidence_class=runtime_proof`)

Note: `audit.receipts` and `public.audit_log` are RLS-locked from this role (service_role only). Receipts go via `ops.job_receipts` + `audit.log`.

## Schedule

- **pg_cron job**: `wq_executor_loop` (jobid=288)
- **Cadence**: `*/2 * * * *` (every 2 min)
- **Command**: `select ops.fn_wq_claim_dispatch('symbio-verifier-v2', 10)`

## Kill switch

```sql
UPDATE cron.job SET active=false WHERE jobid=288;
```

## Rollback

```sql
SELECT cron.unschedule(288);
DROP FUNCTION ops.fn_wq_claim_dispatch(text,int);
```

In-flight rows during rollback complete naturally; no orphans because dispatcher is single-call atomic.

## Genesis evidence (runtime proof)

| idempotency_key | job_id | action | status | proof_ref | lifespan |
|---|---|---|---|---|---|
| wq-rescue-genesis-003 | 55cf8d09-38a9-4ce8-8a7a-4153eac37b06 | sweepers.remediate_inventory | closed | wq-dispatcher-rescue://55cf8d09-38a9-4ce8-8a7a-4153eac37b06 | 157s |
| wq-rescue-genesis-004 | fe537f26-f3d3-400d-a200-5275672aa563 | sweepers.stage2_full_remediation | closed | wq-dispatcher-rescue://fe537f26-f3d3-400d-a200-5275672aa563 | 157s |

Receipt chain: `ops.job_receipts` 6 rows (claimed -> done -> close_signal x2), `audit.log` 4 rows.

Earlier manual-walk proofs (pre-cron, full FSM walk validated):
- 6de997c1-a5b4-452a-98a0-1a428faba92d (sweepers.remediate_inventory) -> closed
- 9c464257-613a-48c3-a0cd-68b2ace44798 (sweepers.stage2_full_remediation) -> closed

## Verifier classification

| Component | Class | Evidence |
|---|---|---|
| `ops.fn_wq_claim_dispatch` | REAL | Runtime FSM transitions + receipts |
| `public.cmd_remediate()` | REAL | Returns `{success:true, command:remediate}`; updates `pipeline.activity_queue` |
| `public.fn_wave7_sweeper` | REAL | Claims `public.work_register` rows |
| `symbio-verifier-v2` | REAL (partial) | Polls + classifies; lacks `sweepers.*` handlers (handled by this dispatcher) |
| `t4h-orchestrator` Lambda | BROKEN | `Runtime.ImportModuleError`; remains unfixed (out of scope) |

## Open follow-ups

- `audit.receipts` + `public.audit_log` RLS unblocking for non-service_role would let dispatcher write into the canonical layered receipts (`SYNAPSE` layer). Currently using `audit.log` as substitute.
- Investigate the unknown ready->claimed claimer that runs <5s after INSERT (suspected: separate Lambda polling Supabase). Not blocking — rescue path handles it.
- Add handlers for additional `sweepers.*` action codes as they emerge (extend the routing block).

---

Receipt generated: 2026-04-28T00:24Z  
Bridge: zdgnab3py0  
S1: lzfgigiyqpuuxslsygjp  
Author: wq-dispatcher-rescue (autonomous golden loop)
