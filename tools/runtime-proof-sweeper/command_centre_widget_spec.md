# Command Centre widget — runtime-proof-sweeper

## Widget name

`runtime_proof_sweeper_status`

## Source

```sql
SELECT * FROM public.v_runtime_proof_sweeper_latest;
```

## Display

Three‑row card on the Command Centre home grid:

```
┌─ 🔎 Runtime Proof Sweeper ────────────────────────────┐
│  Last run: {last_run}   ({age})                        │
│                                                         │
│  REAL: {REAL_count}     PARTIAL: {PARTIAL_count}        │
│  BLOCKED: {BLOCKED_count}  ⚠ stale>72h: {stale_72h}     │
│                                                         │
│  Requeued non-destructively this run: {requeued_count}  │
└─────────────────────────────────────────────────────────┘
```

## Drill-down route

Clicking the card opens `/sweeper/runs?from={last_run}` showing:
- `oldest_unresolved` table (top 50)
- `blocked_by_reason` bar chart
- Receipt JSON link

## State signalling

- Green: last_run < 90 min ago.
- Amber: 90 min < last_run < 180 min.
- Red: last_run > 180 min (cron likely stuck).

## Implementation status

| Component | Status | Path |
|---|---|---|
| Source view | INSTALLED | `public.v_runtime_proof_sweeper_latest` |
| Widget render code | TODO | `mcp-command-centre` repo — add card to home grid |
| Drill-down route | TODO | `/sweeper/runs` page |

The widget can be added in any future Command Centre build cycle; the view it
depends on is already live.
