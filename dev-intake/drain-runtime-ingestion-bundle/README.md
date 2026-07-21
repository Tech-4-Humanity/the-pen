# DRAIN Runtime Ingestion — Canonical Dev Bundle

## Status

**Classification:** PARTIAL  
**Disposition:** TRANSFER  
**Owner:** Dev runtime  
**Runtime Principal:** Pen / GRK runtime  
**Source:** Complete ChatGPT thread and six attached artefacts, compiled 2026-07-21.

## Purpose

Transfer the DRAIN work into the governed Pen development path without continuing implementation in the conversation surface.

DRAIN is an event-driven intake and organisational-memory fabric. Every tab, bookmark, document, chat, repository, deployment or URL becomes a canonical event, is normalised into semantic objects, mapped through a Touch Map, routed to execution, bound to evidence and promoted through the Reality Ledger.

Canonical lifecycle:

`RAW -> TRIAGE -> REGISTERED -> DEV_ROUTED -> EXECUTING -> EVIDENCE_BOUND -> REAL -> MONETISED -> AUTOMATED -> ARCHIVED`

## Included source artefacts

1. `source/00_event-driven-register-pack.md`
2. `source/tab_drain.html`
3. `source/drain_touch_map_engine.py`
4. `source/table-of-tables-schema.md`
5. `source/01_drain-cognitive-archaeology-vignette.md`
6. `source/02_drain-mcp-execution-receipt-and-next-phase.md`

These files are source evidence. They are not all runtime-proven.

## Existing verified GitHub work

- Repository: `TML-4PM/the-pen`
- PR #249: `Add canonical thread-runtime submission path`
- Merge commit: `0be0c8906df43579c9c6fb7ae46ac9a43e63028c`
- Existing runtime paths:
  - `tools/thread_runtime_submit.py`
  - `thread-envelope.json`

A GitHub commit proves the artefact exists. It does not prove runtime operation.

## Current truth state

### REAL

- The attached source artefacts exist in this bundle.
- The Pen thread submission operator and canonical envelope exist in GitHub through merged PR #249.
- The event contract, local UI, semantic extraction engine and persistence design are preserved here.

### PARTIAL

- DRAIN event emission is specified but not proven across every UI action.
- The touch-map engine executes as dependency-light Python but has no production persistence receipt in this bundle.
- The table-of-tables schema is a design specification, not a confirmed live migration.
- Pen/S3 runtime submission requires authenticated execution and independent readback.

### BLOCKED / missing evidence

- No live Bridge ACK.
- No authenticated S3 `PutObject` plus independent `GetObject` receipt included here.
- No production queue telemetry.
- No Command Centre readback.
- No verified ingestion of the current 52 actionable and 4 library items.
- GitHub references #69, #70, #71 and earlier `proof_pot` artefacts require repository verification before being treated as canonical evidence.

## Dev acceptance target

1. Import and preserve all six source artefacts.
2. Validate the existing `tools/thread_runtime_submit.py` path against the canonical envelope.
3. Run local idempotency and readback tests.
4. Run authenticated S3 submission using:

```bash
export T4H_THREAD_BACKEND=s3
export T4H_THREAD_S3_BUCKET=t4h-archive-140548542136
export T4H_THREAD_S3_PREFIX=thread-runtime/current
python3 tools/thread_runtime_submit.py --input thread-envelope.json
```

5. Independently read the S3 object and verify its canonical content hash.
6. Return the submission ID, idempotency key, content hash, backend, object path, readback result and receipt.
7. Route the DRAIN source package into Pen/Dev as canonical objects.
8. Wire every DRAIN UI action to an event emitter.
9. Persist runs, sources, objects, candidates, touch maps, changes, metrics and receipts.
10. Surface live queue and Reality Ledger counts in Command Centre.

## Required runtime invariants

- No receipt means not REAL.
- Unobserved change means not REAL.
- Runtime readback overrides memory and documentation.
- Supabase is optional and must not block ingestion.
- Local durable spool or S3 is the primary submission path.
- Facts and assumptions remain separate.
- Planned work is never recorded as completed.
- Idempotency derives from source system, source thread reference and content hash.
- An unchanged submission returns its existing receipt.
- A conflicting object is blocked rather than overwritten silently.
- No manual review queue remains a passive sink.

## Core runtime objects

- `drain_runs`
- `drain_sources`
- `drain_objects`
- `drain_table_candidates`
- `drain_touch_map`
- `drain_changes`
- `drain_daily_metrics`
- `drain_receipts`
- `tab_drain_events`
- runtime workers, jobs, queues, dependencies, telemetry and authority records

## Routing contract

- `tab.item.registered` -> Pen intake
- `tab.item.execution.requested` -> Dev execution queue
- `tab.item.evidence.bound` -> Reality Ledger
- `tab.item.monetisation.flagged` -> opportunity registry
- `tab.bulk.registered` -> batch import receipt

## Exact next executable action

Execute the existing provider-neutral submission operator against the canonical `thread-envelope.json` from an authenticated environment, verify readback, then bind the receipt to the Pen Reality Ledger. Do not begin wider feature development until this ingestion path is proven.

## Compact ingestion YAML

```yaml
schema_version: pen.dev-intake.bundle.v1
bundle_id: drain-runtime-ingestion-20260721
source_system: chatgpt
source_thread_ref: drain-event-intake-runtime-thread
classification: PARTIAL
disposition: TRANSFER
owner: dev-runtime
runtime_principal: pen-grk
canonical_repository: TML-4PM/the-pen
canonical_branch: main
source_count: 6
truth_rules:
  receipt_required_for_real: true
  runtime_readback_wins: true
  supabase_required: false
submission:
  operator: tools/thread_runtime_submit.py
  envelope: thread-envelope.json
  preferred_backend: s3
  bucket: t4h-archive-140548542136
  prefix: thread-runtime/current
next_action: execute authenticated submission, independently read back, and return receipt
```
