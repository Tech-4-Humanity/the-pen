# PEN Worker Patch — Signal Mining Action Mapping + Receipt Enforcement

Status: ready for PEN/WIP implementation
Date: 2026-04-25 Australia/Sydney
Trace: `signal-mining-exec-slice-01-chatgpt-20260425`

## Problem

Signal Mining jobs have been committed to `inbox/`, but no `receipts/runtime/` proof has appeared.

Observed evidence:

| Evidence | Status |
|---|---|
| Inbox job committed | REAL |
| Handover committed | REAL |
| Trigger job committed | REAL |
| Runtime receipt found | NO |
| Worker pickup verified | NO |

Likely causes:

1. Worker is not running.
2. Worker is running but action names are unmapped.
3. Worker executes but receipt writer is broken.
4. GitHub search/index cannot see receipts, but receipt still needs explicit verification.

## Required Actions

Implement or map these read-only research actions:

```text
research.signal_mining_slice_01_plan
research.signal_mining_extract_queries_v1
research.signal_mining_receipt_check
research.signal_mining_source_inventory
research.system_up_to_scratch_plan
research.signal_mining_execute_slice_01
research.signal_mining_worker_mapping
```

## Dispatch Behaviour

All unknown `research.signal_mining_*` actions must route to a safe default research dispatcher, not be ignored.

Pseudo-code:

```python
SIGNAL_MINING_ACTIONS = {
    "research.signal_mining_slice_01_plan",
    "research.signal_mining_extract_queries_v1",
    "research.signal_mining_receipt_check",
    "research.signal_mining_source_inventory",
    "research.system_up_to_scratch_plan",
    "research.signal_mining_execute_slice_01",
    "research.signal_mining_worker_mapping",
}

if action in SIGNAL_MINING_ACTIONS or action.startswith("research.signal_mining_"):
    result = run_signal_mining_research_job(job)
    write_runtime_receipt(job, result)
    return result
```

## Safe Default Worker

```python
def run_signal_mining_research_job(job: dict) -> dict:
    """Read-only worker for signal mining jobs."""
    action = job.get("action")
    payload = job.get("payload", {})
    key = job.get("idempotency_key")

    outputs = []

    if action == "research.signal_mining_receipt_check":
        outputs.append("Check receipts/runtime for matching idempotency keys")
    elif action == "research.signal_mining_worker_mapping":
        outputs.append("Confirm dispatcher maps signal_mining actions to read-only worker")
    elif action == "research.signal_mining_execute_slice_01":
        outputs.extend([
            "Read docs/SIGNAL_MINING_SLICE_01.md",
            "Run extraction queries over available repo/doc/chat sources",
            "Produce Top Loops, Broken Systems, Hidden Assets, High ROI Fixes",
        ])
    else:
        outputs.append("Research job accepted and queued for read-only execution")

    return {
        "status": "accepted",
        "mode": "read_only",
        "action": action,
        "idempotency_key": key,
        "outputs": outputs,
        "next": "execute extraction and write results receipt",
    }
```

## Receipt Writer Contract

Every worker path must write a receipt, even on failure.

Receipt path:

```text
receipts/runtime/<idempotency_key>.json
```

Receipt shape:

```json
{
  "idempotency_key": "signal-mining-exec-slice-01-chatgpt-20260425",
  "action": "research.signal_mining_execute_slice_01",
  "status": "accepted|running|complete|failed|blocked",
  "evidence_type": "REAL|PARTIAL|PRETEND",
  "started_at": "ISO-8601",
  "completed_at": "ISO-8601|null",
  "inputs": {
    "inbox_path": "inbox/signal-mining-handover-trigger-chatgpt-20260425.json",
    "spec_ref": "docs/SIGNAL_MINING_SLICE_01.md"
  },
  "outputs": [
    "what was produced"
  ],
  "errors": [],
  "next": []
}
```

## Failure Rules

| Failure | Required Receipt Status |
|---|---|
| action unmapped | `failed` |
| worker unavailable | `blocked` |
| source unavailable | `blocked` |
| no evidence found | `complete` with empty result, not pretend |
| partial extraction | `partial` |

## Minimum Receipt To Unblock Troy

If full execution cannot happen immediately, write this receipt first:

```json
{
  "idempotency_key": "signal-mining-exec-slice-01-chatgpt-20260425",
  "action": "research.signal_mining_execute_slice_01",
  "status": "blocked",
  "evidence_type": "REAL",
  "outputs": [
    "Inbox job received",
    "Handover received",
    "Worker action mapping missing or unverified"
  ],
  "errors": [
    "No runtime receipt was produced before manual patch handover"
  ],
  "next": [
    "Map action to read-only worker",
    "Run Slice 01 extraction",
    "Write completion receipt"
  ]
}
```

## Acceptance Criteria

Done only when:

- `receipts/runtime/signal-mining-exec-slice-01-chatgpt-20260425.json` exists
- Receipt includes `idempotency_key`
- Receipt links to spec and handover
- Status is not silently omitted
- If blocked, blocker is named with next action

## Do Not Do

- Do not delete inbox jobs.
- Do not mark complete without receipt.
- Do not build new infrastructure.
- Do not require Troy to paste/run/check manually.
