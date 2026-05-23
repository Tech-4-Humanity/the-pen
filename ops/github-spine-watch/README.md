# GitHub Spine Watch

Purpose: remove Troy from the detection path.

Loop:
1. Poll failed workflow runs and check-runs.
2. Classify failure signature.
3. Attach parent incident (#135).
4. Write receipt.
5. Retry safe failures.
6. Escalate only after repair exhaustion.

Closure gates:
- heartbeat pass
- queue verify pass
- runtime proof pass
- drift checks pass
- no UNKNOWN class remaining

Human role: escalation only.
