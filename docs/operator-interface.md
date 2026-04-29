# T4H Operator Interface

## Purpose
This is the preferred process for moving valuable work through the control plane without tool sprawl.

## Three operating groups

| Group | Purpose | Canonical outputs |
|---|---|---|
| Ingress: WIP / Pen | Capture, structure, deduplicate, and queue intent | JSON job, idempotency key, priority, owner, acceptance tests |
| Execution: Bridge / Workers | Run allowed work through controlled compute | worker run, API call, bridge response, retry/dead-letter path |
| Proof: Receipts / Supabase / Command Centre | Prove outcome and expose state | receipt JSON, audit/evidence row, reality state, dashboard signal |

## Nine golden rules

| # | Rule | Meaning |
|---|---|---|
| 1 | Queue-first | Work enters a queue before execution. No direct hidden execution. |
| 2 | JSON-only intent | The machine contract is structured, parseable, and replayable. |
| 3 | Idempotency always | Every job has a stable key and replay-safe behaviour. |
| 4 | Bridge-first execution | APIs/Bridge/workers execute. Local machines are endpoints, not source of truth. |
| 5 | Receipts mandatory | Every meaningful action produces a receipt. No receipt means not done. |
| 6 | REAL / PARTIAL / PRETEND | Every claim is classified against evidence. |
| 7 | Gated destructive actions | Deploy/delete/RLS/IAM/payments/legal are blocked or dry-run gated. |
| 8 | Registry is truth | Durable objects belong in canonical registry/state, not chat memory alone. |
| 9 | Done equals proven | Done requires runtime proof, output, log, receipt, rollback path, and visible state. |

## Five operator commands

| Command | Use | Writes? | Evidence |
|---|---|---:|---|
| CREATE | Create a structured job in Pen/WIP | Yes, queue only | GitHub commit + inbox path |
| OBSERVE | Inspect queue, worker, receipts, state | No | Read result + timestamp/source |
| ROUTE | Change ownership, priority, target lane, or next system | Yes, non-destructive | Updated job/issue/comment/label |
| GATE | Approve or refuse risky action after dry-run evidence | Yes, controlled | approval/refusal receipt |
| SCALE | Reuse proven loop across brands/products/customers | Yes, template-driven | copied template + new receipts |

## Preferred flow

```text
Signal -> structured JSON -> Pen/WIP queue -> Bridge/worker -> receipt -> Supabase/audit -> Command Centre
```

## What moved in during this thread

| Artefact | Location | State |
|---|---|---|
| Signal-loop worker bundle request | inbox/pen-signal-loop-worker-bundle-20260429-001.json | REAL queue commit |
| Pen worker workflow | .github/workflows/pen-worker.yml | REAL file commit |
| Operator process | docs/operator-interface.md | REAL file commit |

## Current closure state

PARTIAL. Queue and workflow files exist. Worker/runtime receipt still requires successful runner execution and receipt file under receipts/runtime.

## Next valid action

OBSERVE first: inspect workflow run and receipts. If no receipt exists, CREATE only the missing runner/worker artefacts or open a tracked issue. Do not claim execution as complete until receipt exists.
