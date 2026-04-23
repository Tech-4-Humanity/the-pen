# Receipt Registry

This folder is the central place for durable receipts in `TML-4PM/the-pen`.

A receipt proves that a job, dispatch, handoff, implementation, deployment, runtime execution, or closure happened.

## Why this exists

Chat is not a durable system of record.
Issues are useful, but can become scattered.
Runtime logs prove execution, but are separate from documentation handoff.

This registry gives one place to find all receipt records.

## Two-way receipt rule

Every important job must have two directions of evidence:

### 1. Outbound receipt
Proves the job was sent, dispatched, handed off, or assigned.

### 2. Inbound receipt
Proves the job came back with implementation, runtime evidence, closure, blocker, or rejection.

A job is not fully tracked unless both directions are represented.

```text
OUTBOUND: sender → Pen / Bridge / executor
INBOUND: Pen / Bridge / executor → sender / registry
```

## Receipt types

### Dispatch receipt
Outbound. Proves that documentation, instructions, handoff packs, or specs were sent to a repo or execution surface.

### Acceptance receipt
Inbound. Proves that the receiver acknowledged or picked up the job.

### Implementation receipt
Inbound. Proves that code, schema, APIs, widgets, or infrastructure were created.

### Runtime receipt
Inbound. Proves that the implemented system actually ran and produced evidence.

### Closure receipt
Inbound. Proves that a job met its completion criteria.

### Blocker receipt
Inbound. Proves that the job could not complete and records the blocker.

## Required receipt files

Every major job should have:
- human-readable markdown receipt
- machine-readable JSON receipt

For two-way jobs, both outbound and inbound receipts are required.

## Naming pattern

```text
receipts/<system>/<job>/outbound/RECEIPT.md
receipts/<system>/<job>/outbound/RECEIPT.json
receipts/<system>/<job>/inbound/ACCEPTANCE_RECEIPT.md
receipts/<system>/<job>/inbound/ACCEPTANCE_RECEIPT.json
receipts/<system>/<job>/inbound/IMPLEMENTATION_RECEIPT.md
receipts/<system>/<job>/inbound/IMPLEMENTATION_RECEIPT.json
receipts/<system>/<job>/inbound/RUNTIME_RECEIPT.md
receipts/<system>/<job>/inbound/RUNTIME_RECEIPT.json
receipts/<system>/<job>/inbound/CLOSURE_RECEIPT.md
receipts/<system>/<job>/inbound/CLOSURE_RECEIPT.json
receipts/<system>/<job>/inbound/BLOCKER_RECEIPT.md
receipts/<system>/<job>/inbound/BLOCKER_RECEIPT.json
```

## Legacy compatibility

Older receipt paths may exist such as:

```text
receipts/flow/dispatch/RECEIPT.json
```

Do not delete them. Supersede them by creating the two-way structure and adding references to the legacy receipt.

## Machine-readable minimum fields

```json
{
  "receipt_type": "dispatch|acceptance|implementation|runtime|closure|blocker",
  "direction": "outbound|inbound",
  "system": "FLOW",
  "job_key": "flow_dispatch_to_pen",
  "source_repository": "TML-4PM/mcp-command-centre",
  "target_repository": "TML-4PM/the-pen",
  "sender": "",
  "receiver": "",
  "status": "ACTIVE|SUPERSEDED|BLOCKED|COMPLETE",
  "documents": [],
  "commits": [],
  "evidence": [],
  "blockers": [],
  "created_at_utc": "",
  "updated_at_utc": "",
  "search_tags": []
}
```

## Repeatable two-way process

```text
1. Create outbound receipt when work is sent.
2. Receiver creates acceptance receipt when picked up.
3. Receiver creates implementation receipt when artefacts are created.
4. Receiver creates runtime receipt when the system runs and produces evidence.
5. Receiver creates closure receipt when completion criteria pass.
6. Receiver creates blocker receipt instead of closure if work cannot complete.
7. Update registry/index when any receipt changes.
```

## Rule
If work matters, it gets a receipt.

If work is sent, it gets an outbound receipt.

If work returns, it gets an inbound receipt.

If runtime later proves execution, create a separate runtime receipt rather than overwriting the dispatch receipt.

If a receipt changes, the receipt index must change.
