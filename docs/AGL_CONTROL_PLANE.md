# AGL_CONTROL_PLANE.md
## Tech 4 Humanity — AGL Execution Control Plane

**Version**: 1.0 (2026-04-24)
**Status**: ACTIVE — ENFORCED

---

## What this is

The AGL Control Plane governs all system execution via the queue-first pattern.
No actor executes directly. All work is enqueued, processed by the worker, receipted.

## The loop

```
OBSERVE → EVALUATE → DECIDE → ACT → VERIFY → LEARN
```

Every action is one pass of this loop. No shortcuts.

---

## Execution path (canonical)

```
ANY ACTOR (Claude, Mac, cron, human)
  → enqueue_job (ops.work_queue)
  → Pen GitHub Action worker
  → bridge Lambda
  → Supabase / GitHub
  → receipt written
  → audit.log row
```

**Direct SQL is blocked.** All writes go via queue.

---

## Queue contract

| Field | Required | Notes |
|---|---|---|
| fn | yes | must be `enqueue_job` |
| action | yes | verb.noun e.g. `agl.bootstrap` |
| idempotency_key | yes | unique, stable, human-readable |
| payload | yes | the actual work |
| priority | yes | 1=highest 10=lowest |
| meta.actor | yes | who issued it |
| meta.source | yes | which system |
| meta.ts | yes | ISO timestamp |

---

## Container DNS constraint

Claude's execution container has DNS blocked.
**All bridge calls from Claude go via Pen inbox commit.**

Pattern:
1. Claude writes job JSON to `inbox/<idempotency_key>.json`
2. Pen worker picks up on next run
3. Worker executes, writes receipt to `receipts/runtime/`
4. audit.log row written

This is REAL. Proven. Do not route around it.

---

## Bootstrap (one-time, idempotent)

Job `agl-bootstrap-ddl-001` committed to inbox 2026-04-24.
Creates:
- `ops.work_queue` unique index on `idempotency_key`
- `core` schema
- `core.widgets` table
- Seed row: `bridge_runner_control_plane`

Re-running is safe (all IF NOT EXISTS / ON CONFLICT DO NOTHING).

---

## Definition of DONE

| Check | Must be true |
|---|---|
| Queue row exists | receipt in `receipts/runtime/` |
| Worker processed | no stuck RUNNING state |
| audit.log written | row present |
| No duplicates | idempotency_key unique index enforced |

Fail any → not live.

---

## Related docs

- `global/GLOBAL_RULE.md` — immutable law
- `global/MCP_EXECUTION_CONTRACT.md` — payload envelope
- `global/ENFORCEMENT_LIVE.md` — runtime reality
- `global/ACTOR_COMPLIANCE.md` — actor behaviour standard
