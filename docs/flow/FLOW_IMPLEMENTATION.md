# FLOW Implementation Note

FLOW is a hybrid trigger, multi-surface business movement engine.

It must not be implemented as a single scheduled loop.

## Trigger model

FLOW must support:
- Manual triggers
- Event triggers
- Scheduled triggers
- Agent triggers

All four are required.

## Execution flow

```text
[Manual / Event / Agent]
          │
          v
     flow_items
          │
          ├──────────────┐
          │              │
          v              v
EventBridge        External triggers
   (schedule)           (API)
          │              │
          └──────┬───────┘
                 v
        flow_orchestrator
                 │
       ┌─────────┼─────────┐
       │         │         │
       v         v         v
   evaluate   decide    log run
                 │
                 v
           update item
                 │
                 v
           write event
                 │
                 v
             Supabase
                 │
                 v
        Command Centre / UI
```

## Required tables
- flow_items
- flow_events
- flow_run_log

## Required views
- v_flow_board
- v_flow_pressure
- v_flow_onboarding_ramp
- v_flow_drain_and_miss

## Required APIs
- /api/flow/board
- /api/flow/pressure
- /api/flow/onboarding
- /api/flow/drain-miss
- /api/flow/run-log

## Required behaviour

- No item without a stage
- No item without next action or review
- All stale items surfaced
- All runs logged
- All movement recorded

## Completion rule

System is not complete until:
- a stale item is detected
- system reacts
- log is written
- UI reflects change

## Reality note

FLOW is:
- a business lifecycle engine
- enforced by automation
- visible through logs and pressure

If items still disappear, implementation is incomplete.
