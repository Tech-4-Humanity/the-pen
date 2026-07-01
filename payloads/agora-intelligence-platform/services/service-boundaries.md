# Agora Service Boundaries

Status: PARTIAL  
Runtime: not yet deployed  
Receipt: GitHub text artefact only

## api-gateway

Purpose: Single public API surface for web, admin, creator, and enterprise clients.

Responsibilities:
- Route requests to internal services.
- Enforce tenant context.
- Standardise receipt envelopes.
- Expose health and version metadata.
- Provide stable API contracts while internal services evolve.

Non-responsibilities:
- Long-running model inference.
- Media storage.
- Graph persistence.
- Evidence signing.

## media-service

Purpose: Register, store, normalise, and track media assets.

Responsibilities:
- Create media asset records.
- Track upload state.
- Store S3/IPFS references.
- Generate checksums.
- Trigger transcription and moderation jobs.

Non-responsibilities:
- Direct AI debate generation.
- Direct graph extraction.
- Tenant billing.

## transcription-service

Purpose: Convert media into canonical text.

Responsibilities:
- Accept transcription jobs.
- Store segmented transcripts.
- Track provider, model, language, confidence, and processing status.
- Emit receipts for every transcription job.

Non-responsibilities:
- Narrative analysis.
- Persona generation.
- Public publishing.

## graph-rag-service

Purpose: Extract entities and relationships, store graph objects, and retrieve evidence-backed context.

Responsibilities:
- Entity extraction.
- Relationship extraction.
- Embedding generation.
- Vector retrieval.
- Community detection.
- Graph search.
- Retrieval context generation for debate engine.

Non-responsibilities:
- UI rendering.
- Media upload.
- Credential issuance.

## debate-engine

Purpose: Generate multi-perspective, evidence-backed debates.

Responsibilities:
- Build debate plans.
- Select personas.
- Orchestrate rounds.
- Require citations when configured.
- Return structured debate output.
- Emit receipts.

Non-responsibilities:
- Raw media processing.
- Permanent evidence storage.
- Legal assertions.

## evidence-service

Purpose: Generate receipt bundles and exportable evidence packs.

Responsibilities:
- Create receipts.
- Create evidence packs.
- Compute checksums.
- Record artefact manifests.
- Support export formats.
- Maintain supersession chains.

Non-responsibilities:
- Model inference.
- UI generation.
- Payment processing.

## moderation-service

Purpose: Apply safety, policy, privacy, and publication controls.

Responsibilities:
- Classify media, transcripts, comments, and generated outputs.
- Flag sensitive content.
- Track reviewer decisions.
- Control publication state.

Non-responsibilities:
- Suppressing evidence records.
- Altering raw evidence without receipt.

## wallet-service

Purpose: Represent creator, researcher, participant, and tenant claims as wallet-held credentials.

Responsibilities:
- Wallet records.
- Credential references.
- Proof references.
- Revocation state.
- Exportable identity-linked receipt chains.

Non-responsibilities:
- Replacing primary authentication.
- Holding unencrypted secrets.

## dependency graph

```text
web/admin/creator/enterprise
  -> api-gateway
api-gateway
  -> media-service
  -> transcription-service
  -> graph-rag-service
  -> debate-engine
  -> evidence-service
  -> moderation-service
media-service
  -> transcription-service
  -> moderation-service
  -> evidence-service
transcription-service
  -> graph-rag-service
  -> evidence-service
graph-rag-service
  -> debate-engine
  -> evidence-service
debate-engine
  -> evidence-service
wallet-service
  -> evidence-service
```

## receipt rule

Every service response that changes state must return or reference a receipt. If no receipt is emitted, the action is PARTIAL at best.
