# Worker Instructions

## Rules
- Queue is the only execution source
- Do not mark complete without receipt
- Respect idempotency_key
- Write audit events: work_started, work_completed
- On failure: retry up to limit then flag for DLQ

## Execution
1. claim job
2. update heartbeat + stale_after
3. execute payload
4. write receipt (runtime/)
5. mark completed

## Never
- delete jobs
- bypass queue
- skip verification
