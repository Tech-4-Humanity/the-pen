# Session Offboarding Runtime

Status: REAL (file committed)

## Purpose
Every session close must capture execution state, open work, learned patterns, and reusable assets so the next session can resume without drift.

## Offboarding Sequence

1. Write all open/partial work to Reality Ledger
2. Capture assets created this session (files, schemas, receipts)
3. Capture assets reused this session
4. List blockers and dependencies
5. List next actions in priority order
6. Write session close receipt
7. Post summary comment to active GitHub issue

## Offboarding Receipt Schema

```json
{
  "event": "session_close",
  "session_id": "<uuid>",
  "assets_created": [],
  "assets_reused": [],
  "work_completed": [],
  "work_open": [],
  "blockers": [],
  "next_actions": [],
  "closed_at": "<iso8601>"
}
```

## Acceptance Criteria
- Session close writes receipt
- Next session can open and find this receipt
- No work is lost between sessions
