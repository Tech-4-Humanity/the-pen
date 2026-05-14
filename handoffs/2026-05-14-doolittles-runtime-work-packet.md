# Doolittles Runtime Work Packet

Date: 2026-05-14
Owner: Troy Latter / Tech 4 Humanity
Status: PARTIAL
Purpose: Convert the Doolittles/Synal conversation into executable work.

## Result

The audit showed that Doolittles is the translation and alignment layer for Synal. The next work is a demo that proves one human instruction can become structured work, routed actions, evidence, and a visible ledger.

## Why this helps

It turns conversation into work. It gives Troy visibility. It stops ideas dying in chat. It creates a reusable pattern for every future long discussion.

## Demo slice

Input:
- one user instruction

Runtime:
- create intent object
- create work packets
- route to agent lanes
- create execution states
- bind evidence
- display timeline

UI panels:
- Doolittles chat
- Synal orchestration flow
- Reality Ledger
- replay timeline

## Work packages

1. Conversation-to-work extractor
2. Doolittles intent object schema
3. Runtime registry schema
4. Evidence ledger binding
5. Demo surface route
6. Buddy/Research registry seed
7. Duplicate/drift cleanup queue

## First payloads

Recovered audit assets to seed:
- Buddy Platform V2 PRD
- Wave C deployment summary
- Reading/Maths parity addendum
- Reading Buddy expansion roadmap
- AGRO governance runtime spec
- SS-A / SS-B / Extreme research thread

## Acceptance tests

- A conversation becomes at least 12 structured work items.
- A demo command creates a canonical intent object.
- Intent creates routed work packets.
- Work packets create ledger rows.
- Ledger classifies REAL, PARTIAL, BLOCKED, or PRETEND_REJECTED.
- Demo route renders chat, flow, ledger, and timeline.
- Recovered Buddy/Research assets appear as registry objects.

## Bridge payload

```json
{
  "task_id": "doolittles-runtime-demo-20260514",
  "intent": "Turn Doolittles/Synal conversation into executable demo, registry, work queue, and evidence ledger.",
  "status": "PARTIAL",
  "priority": "HIGH",
  "work_packages": [
    "conversation_to_work_extractor",
    "intent_object_schema",
    "runtime_registry_schema",
    "evidence_ledger_binding",
    "demo_surface_route",
    "buddy_research_registry_seed",
    "duplicate_drift_cleanup"
  ],
  "evidence_required": [
    "commit_id",
    "schema_apply_receipt",
    "demo_run_id",
    "ledger_row_ids",
    "deployment_or_preview_url"
  ],
  "next_action": "Bridge or dev executor should create schema, seed objects, expose demo route, and return receipts."
}
```

## Reality Ledger

status: PARTIAL
result: Work packet created for bridge/dev execution.
evidence: file audit plus GitHub persistence attempt.
gaps: live runtime not yet deployed; Supabase and bridge execution not proven in this session.
next_action: consume this packet in bridge/dev and return receipts.
elevation: Converts discussion into execution surface.
pressure_flags: runtime_drift, duplicate_assets, receipt_fragmentation.
score: 0.78
