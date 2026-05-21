# Survivability Continuity Rule

## Canonical rule

72h survivability means the runtime operates successfully for 72 continuous hours with active health checks, telemetry continuity, automatic recovery, replay validation, and escalation on failure.

A broken system left untouched for 72h is a failed survivability test, not a pass.

## Required pass conditions

A 72h survivability claim can only be classified REAL when all of the following are true:

1. Health checks remain green or recover within the policy threshold.
2. Telemetry ledger has no unexplained gaps beyond the accepted heartbeat interval.
3. Failed jobs are retried and either recovered or escalated with evidence.
4. Queue continues processing without deadlock.
5. Evidence writer continues creating receipts for runtime actions.
6. Recovery replay is tested and produces deterministic result.
7. No critical launch gate silently changes state without evidence.
8. Operator brief shows continuity, incidents, recovery actions and unresolved blockers.

## Fail conditions

Any of the following invalidates a 72h survivability claim:

1. Runtime broken for 72h.
2. Silent telemetry gap.
3. Stuck queue without escalation.
4. Receipt writer offline.
5. Recovery untested.
6. Manual discovery of failure after the test window.
7. Critical error not surfaced to operator brief.
8. Claiming REAL without continuous evidence.

## Required receipt fields

Every survivability receipt must include:

- `start_time`
- `end_time`
- `heartbeat_count`
- `incident_count`
- `recovered_incident_count`
- `unresolved_incidents`
- `telemetry_gap_report`
- `replay_result`
- `recovery_result`
- `final_classification`

## Classification

- `REAL`: successful continuity is proven by runtime receipts, telemetry, recovery/replay proof and operator brief evidence.
- `PARTIAL`: some runtime proof exists, but continuity, recovery, replay or telemetry coverage is incomplete.
- `MISSING`: no valid survivability test has been started or recorded.
- `REJECTED`: the system was broken, silent, unrecovered, or merely left unattended.

## Enforcement

This rule applies to all work entering the Pen, all runtime handovers, all launch gates, all deployment claims, and all future references to 72h survivability.

72h is a successful-continuity proof, not a waiting period.
