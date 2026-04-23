# Receipt Registry

This folder is the central place for durable receipts in `TML-4PM/the-pen`.

A receipt proves that a job, dispatch, handoff, implementation, deployment, or runtime execution happened.

## Why this exists

Chat is not a durable system of record.
Issues are useful, but can become scattered.
Runtime logs prove execution, but are separate from documentation handoff.

This registry gives one place to find all receipt records.

## Receipt types

### Dispatch receipt
Proves that documentation, instructions, handoff packs, or specs were sent to a repo or execution surface.

### Implementation receipt
Proves that code, schema, APIs, widgets, or infrastructure were created.

### Runtime receipt
Proves that the implemented system actually ran and produced evidence.

### Closure receipt
Proves that a job met its completion criteria.

## Required receipt files

Every major job should have:
- human-readable markdown receipt
- machine-readable JSON receipt

## Naming pattern

```text
receipts/<system>/<job>/<receipt_type>.md
receipts/<system>/<job>/<receipt_type>.json
```

Example:

```text
receipts/flow/dispatch/RECEIPT.md
receipts/flow/dispatch/RECEIPT.json
receipts/flow/runtime/RUNTIME_RECEIPT.md
receipts/flow/runtime/RUNTIME_RECEIPT.json
```

## Machine-readable minimum fields

```json
{
  "receipt_type": "dispatch|implementation|runtime|closure",
  "system": "FLOW",
  "job_key": "flow_dispatch_to_pen",
  "target_repository": "TML-4PM/the-pen",
  "source_repository": "TML-4PM/mcp-command-centre",
  "status": "ACTIVE",
  "documents": [],
  "commits": [],
  "evidence": [],
  "created_at_utc": "",
  "updated_at_utc": "",
  "search_tags": []
}
```

## Rule
If work matters, it gets a receipt.

If a receipt changes, the receipt index must change.

If runtime later proves execution, create a separate runtime receipt rather than overwriting the dispatch receipt.
