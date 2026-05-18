# Pen Poller Governance

**Last updated:** 2026-05-15  
**Classification:** REAL  
**Owner:** Tech 4 Humanity / TML-4PM

---

## Architecture

The Pen inbox operates as a fully autonomous loop. No human-in-the-loop (HITL) is required or expected for inbox execution.

```
inbox/*.json committed
        ↓
pen-inbox-dispatch.yml (on: push to inbox/**)
        ↓
bridge invoke (autonomous, no HITL)
        ↓
receipts/final/*.final.receipt.json written
        ↓
git commit → Vercel redeploy (if applicable)
        ↓  
[30min] pen-queue-cron.yml sweeps any missed payloads
        ↓
receipts/final/*.sweep.receipt.json written
```

---

## Workflows

### `pen-inbox-dispatch.yml` — Primary executor
- **Trigger:** push to `inbox/**` on main
- **Behaviour:** detects changed inbox payloads → executes via bridge → writes receipts/final + receipts/runtime → commits
- **Idempotent:** skips payloads with existing final receipts
- **HITL:** ❌ None
- **Hard gates:** destructive terms (drop table, truncate, delete from, destroy, refund, IAM, secret) → BLOCKED receipt, no execution

### `pen-queue-cron.yml` — Safety sweep
- **Trigger:** every 30 minutes (`*/30 * * * *`) + `workflow_dispatch`
- **Behaviour:** sweeps all `inbox/*.json` for any un-receipted payloads → executes via bridge → writes receipts
- **Purpose:** catches any payloads missed by the primary executor (e.g. push fired before workflow was active)
- **HITL:** ❌ None
- **Previous:** was `*/2 * * * *` with missing scripts — no-op loop consuming Actions minutes. Fixed 2026-05-15.

---

## Receipt Chain

| File | Written by | Classification |
|---|---|---|
| `receipts/runtime/{key}.trigger-receipt.json` | pen-inbox-dispatch | PARTIAL (trigger only) |
| `receipts/final/{key}.final.receipt.json` | pen-inbox-dispatch or pen-queue-cron | REAL or PARTIAL |
| `receipts/runtime/{key}-receipt.json` | bridge-direct / manual | REAL |
| `state/pen_inbox_sweep.json` | pen-inbox-dispatch | Sweep summary |
| `state/pen_sweep_summary.json` | pen-queue-cron | Sweep summary |

---

## Bridge Envelope Format

```json
{
  "idempotency_key": "<payload idempotency_key>",
  "fn": "<data.fn or data.action>",
  "payload": { ...full job data... },
  "source": "the-pen",
  "mode": "AUTONOMOUS"
}
```

Bridge endpoint: `BRIDGE_INVOKE_URL` (GitHub secret)  
Bridge key: `BRIDGE_API_KEY` (GitHub secret)

---

## Idempotency

- Each payload has an `idempotency_key` field.
- If `receipts/final/{safe_key}.final.receipt.json` exists → skip. No re-execution.
- Re-run is only possible by deleting or archiving the final receipt.

---

## Known Gaps (as of 2026-05-15)

- `scripts/pen-drift-check.mjs` not present → drift check step skips gracefully
- Bridge envelope format (`fn` + `payload`) must match the registered Lambda handler — verify if new fn names added
- No dead-letter queue — failed payloads remain in inbox with a FAILED receipt; manual retry required

---

## History

| Date | Change |
|---|---|  
| 2026-05-14 | Last successful poller run (17:06 UTC) |
| 2026-05-15 | Root cause: pen-inbox-dispatch triggered on `inbox/**` push but did not execute — only emitted trigger receipt. pen-queue-cron ran every 2min but scripts missing → no-op. Fixed both. |
| 2026-05-15 | pen-inbox-dispatch now executes + receipts on push. pen-queue-cron now 30min sweep with same autonomous execution loop. |
