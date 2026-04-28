# SPEC-004 Watchdog and Fallback Standard

**Purpose:** prevent accepted execution handoffs from dying silently.

## Watchdog rule

An execution issue is not accepted unless it has an active fallback loop:

1. **Heartbeat expectation** — executor must comment within the heartbeat window.
2. **Stale detection** — if no proof comment appears, issue is marked stale/blocked.
3. **Escalation** — watchdog posts an explicit failure comment with next action.
4. **Recovery route** — issue remains runnable from a single command.
5. **Final proof** — issue closes only after proof receipt exists.

## SPEC-004 heartbeat

- Issue: `TML-4PM/the-pen#29`
- Initial state: `accepted-to-dev`, `watchdog-active`, `no-hitl`, `bridge-ready`
- Required proof phrase: `EXIT_CODE=0`
- Required patch phrase: `SPEC004_PATCH_RESULT:`
- Maximum silent window: 2 hours

## Watchdog action if stale

Post comment:

```markdown
## Watchdog escalation — execution stale

No machine proof has been posted within the heartbeat window.

Required proof remains:
- `SPEC004_PATCH_RESULT: applied` or `already_applied`
- `EXIT_CODE=0`
- receipt under `receipts/`

Runner:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/TML-4PM/the-pen/main/handoffs/SPEC004/run_spec004_recovery.sh)
```

Reality Ledger: STALE / NOT COMPLETE.
```

## Closing rule

Do not close issue #29 unless a receipt contains the terminal tail and final classification.
