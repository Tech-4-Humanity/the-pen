# Provider-Neutral Runtime Ingress

## Decision

Supabase is an optional index and control-plane mirror. It is not required for thread acceptance, queueing, production promotion, execution, receipts, or recovery.

## Canonical flow

```text
Authorised source
  → Pen thread envelope
  → durable local/S3 inbox
  → queue adapter
  → authorised worker
  → Symbio DEV
  → Gatekeeper decision
  → Synapse PROD
  → provider readback
  → immutable receipt
  → optional Supabase index
```

## Truth hierarchy

1. Provider readback and runtime receipt.
2. Immutable S3 evidence.
3. GitHub source and contracts.
4. Queue and worker telemetry.
5. Supabase searchable index.

Loss of Supabase must not stop ingress, DEV, Gatekeeper, Synapse, rollback, or evidence recovery.

## Immediate operator

```bash
python3 tools/thread_runtime_submit.py --input thread.json
```

Default backend: local atomic spool under `runtime/thread-ingest/`.

S3 backend:

```bash
T4H_THREAD_BACKEND=s3 \
T4H_THREAD_S3_BUCKET=t4h-archive-140548542136 \
T4H_THREAD_S3_PREFIX=thread-runtime/current \
python3 tools/thread_runtime_submit.py --input thread.json
```

The operator:

- validates required identity fields;
- creates a deterministic content hash and idempotency key;
- writes one canonical envelope;
- safely deduplicates repeat submissions;
- emits a readback receipt;
- does not call Supabase.

## Production boundary

A thread submission does not itself authorise production. It creates a canonical Pen object and job input. Production remains:

```text
Pen → Symbio → verification → Gatekeeper → Synapse → provider readback
```

Bridge is selected only when native provider tooling is insufficient.

## Supabase mirror

A separate asynchronous indexer may copy envelope metadata into Supabase. Mirror failure must emit telemetry but must not reject or roll back the accepted envelope.

## State

- Provider-neutral local ingress: implemented.
- S3 ingress: implemented, requires AWS credentials and bucket access.
- Supabase dependency: removed from acceptance path.
- SQS/EventBridge dispatch: next adapter.
- Provider-backed production proof: still required for REAL end-to-end production.
