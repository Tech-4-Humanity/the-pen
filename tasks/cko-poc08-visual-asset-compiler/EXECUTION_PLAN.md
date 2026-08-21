# POC-08 Visual Asset Compiler and Research Atlas

Canonical issue: #245

## Baseline

POC-01 through POC-07 are REAL.

Final POC-03→07 run:

- Run ID: `20260720T224823Z`
- Source CKO: `cko:pdf:7b72f182832a49a6253aea05`
- S3: `s3://t4h-archive-140548542136/knowledge-runtime/poc03-07/20260720T224823Z/`
- Receipt SHA-256: `c3b8b8695951f6ed381a064e915affcf485e309b3b496c24005463042a519e60`
- State: REAL

## Objective

Add a standalone Image Compiler Adapter to the Canonical Knowledge Compiler and use the Google Drive `OIKOS Journey` folder as the proving dataset.

The result must convert images, posters, screenshots, diagrams and infographics into first-class CKOs with integrity evidence, visual extraction, relationships, chronology, policy decisions, search registration, S3 evidence and receipts.

## Canonical data contract

Every compiler, adapter, worker and downstream compiler consumes and emits the same provider-neutral canonical envelope. A compiler does not return a special object because its source or output format is different. It receives canonical data, transforms or enriches the payload, appends evidence and lineage, and returns canonical data.

```text
canonical envelope in
→ validate contract
→ inspect object_type and payload_type
→ execute adapter/compiler capability
→ append facts, derived fields, evidence, confidence and lineage
→ validate contract
→ canonical envelope out
```

The same contract applies whether the payload represents an input, intermediate state or output, including:

- image, PDF, document, spreadsheet, slide, audio, video or chat;
- asset discovery, OCR, classification, relationship, chronology or movement decision;
- CKO, website page, publication manifest, audit pack or runtime receipt.

Adapters may add or replace typed payload sections, but must not create a competing envelope, identity system or provenance model.

### Minimum canonical envelope

```yaml
schema_version: t4h.canonical-envelope.v1
envelope_id: env:<type>:<stable-id>
object_id: <stable canonical identity>
object_type: asset | knowledge_object | relationship | timeline_event | plan | publication | receipt
payload_type: <registered MIME or semantic payload type>
state: discovered | extracted | compiled | validated | planned | published | rejected
source:
  provider: google_drive | s3 | github | filesystem | chat | generated
  source_id: <provider identity>
  source_uri: <provider-neutral or provider URI>
  parent_ids: []
payload:
  data: {}
  binary_ref: null
integrity:
  content_sha256: null
  byte_size: null
  mime_declared: null
  mime_detected: null
facts: []
derivations: []
relationships: []
timeline: []
classification: {}
confidence:
  overall: null
  fields: {}
evidence: []
lineage:
  parents: []
  compiler_runs: []
policy:
  decisions: []
  review_required: false
telemetry: {}
receipt_refs: []
created_at: <RFC3339>
updated_at: <RFC3339>
```

### Truth and confidence rules

- Source-observed values are facts and must identify their evidence source.
- Model-generated or rule-generated values are derivations, never facts.
- Every inferred field must contain confidence and evidence references.
- Missing values remain null or unknown; they are not guessed to satisfy a schema.
- Runtime readback overrides local state, plans and documentation.
- Supabase persistence is optional and must not block compilation or release.
- S3 or another durable provider-neutral store must contain enough data and receipts to reconstruct a run.

### Compiler invariants

1. Stable object identity survives file movement, renaming, publication and provider migration.
2. Payload formats may change; envelope semantics do not.
3. Every compiler stage is idempotent for the same input content hash, configuration hash and compiler version.
4. Every stage preserves upstream evidence and lineage.
5. Every output identifies its exact input envelope IDs and content hashes.
6. Binary assets are referenced, not silently embedded into metadata records.
7. CSV, JSON, JSONL, Parquet, SQL and HTML are serialisations or products of canonical data, not alternative sources of truth.
8. A publication page, movement plan or receipt is also a canonical envelope with a registered object and payload type.

## Architectural boundary

```text
source connector
→ canonical asset discovery envelope
→ format adapter, including Image Adapter
→ Canonical Knowledge Compiler
→ canonical knowledge envelope
→ validation and policy
→ relationship and chronology envelopes
→ search and memory
→ movement/publication compiler envelopes
→ receipt envelope
```

Do not create a competing canonical-object system.

- Canonical Asset Register: repository inventory truth serialised from canonical envelopes
- Image Compiler Adapter: visual payload processing
- Canonical Knowledge Compiler: CKO payload production
- Movement Planner: reversible plan payload production
- Atlas Publication Compiler: static publication payload production
- Receipt Compiler: runtime proof and readback payload production

## Execution stages

### POC-08.0 Security and source freeze

Capture folder metadata and permissions, preserve a pre-change inventory, remove public writer access after named-editor verification, and separate canonical evidence from publication copies.

Emit canonical envelopes for the source root, folder hierarchy, permissions and source-freeze receipt.

### POC-08.1 Recursive discovery

Crawl all descendants and create one canonical asset discovery envelope per asset or folder.

Required serialisations:

- `asset_register.csv`
- `asset_register.json`
- `asset_register.parquet`
- `canonical_envelopes/discovery/*.json`
- `folder_structure.csv`
- `source_inventory_receipt.json`

Every register row must resolve back to its canonical envelope ID.

### POC-08.2 Integrity and metadata

Record SHA-256, byte-signature MIME, extension, size, dimensions, colour mode, EXIF, page count/duration and invalid/truncated state.

Append integrity and metadata to the existing asset envelope rather than creating an unrelated record.

Required serialisations:

- `hashes.csv`
- `image_metadata.csv`
- `invalid_assets.csv`
- `mime_conflicts.csv`
- `canonical_envelopes/integrity/*.json`

### POC-08.3 Duplicate intelligence

Exact duplicates require SHA-256 equality. Near duplicates use perceptual hash, dimensions, OCR and visual similarity.

Duplicate status is a relationship and evidence-backed derivation. It must not overwrite asset identity.

Required serialisations:

- `perceptual_hashes.csv`
- `duplicates.csv`
- `image_similarity_groups.csv`
- `asset_families.csv`
- `canonical_envelopes/relationships/duplicate-*.json`

Probable-master selection must record score, evidence, decision rule and review state.

### POC-08.4 OCR and visual claims

Route by visual mode and extract visible text, claims, metrics, entities, audience, version, privacy and sensitivity findings.

OCR observations are facts when directly extracted. Summaries, interpreted claims, audiences and meanings are derivations with confidence and evidence.

Required serialisations:

- `image_text_extraction.jsonl`
- `image_descriptions.jsonl`
- `visual_claims.csv`
- `canonical_envelopes/extraction/*.json`
- review queues

### POC-08.5 Image CKO compilation

Transform enriched asset envelopes into stable `cko:image:*` knowledge-object envelopes while preserving the source asset envelope ID and all upstream lineage.

Compiler runs must include configuration hash, compiler version, input hashes, output hash, telemetry, policy decisions, durable-store write/readback, recovery and receipts.

Acceptance set:

- PNG
- JPG
- HEIF
- SVG
- screenshot
- infographic/chart
- exact duplicate
- near duplicate
- MIME mismatch
- invalid-file recovery

### POC-08.6 Classification and graph

Relate images to themes, topics, subtopics, studies, hypotheses, variables, measures, methods, findings, frameworks, products, businesses, policies, publication families, claims and RDTI activities.

All classifications and relationships are canonical envelopes or embedded references with:

- stable identity;
- source and target object IDs;
- relationship type;
- fact or derivation status;
- confidence;
- supporting evidence;
- valid-time and system-time where available.

### POC-08.7 Chronology

Store Drive-created, Drive-modified, filesystem, EXIF/capture, filename generation, upload, research-event and publication dates separately.

Do not collapse distinct dates into a single timestamp. Emit three ordered views from the same canonical timeline-event envelopes:

1. evidence chronology;
2. research chronology;
3. publication chronology.

Required serialisations:

- `timeline.csv`
- `timeline_evidence.json`
- `date_conflicts.csv`
- `chronology_review_queue.csv`
- `canonical_envelopes/timeline/*.json`

### POC-08.8 Movement planner

Generate reversible KEEP, MOVE, RENAME, MERGE, QUARANTINE, ARCHIVE and REVIEW plan envelopes. Preserve original IDs, names, paths and parent relationships.

A movement plan is data, not an executed mutation. Each action must include preconditions, expected post-state, rollback action, evidence, confidence and approval policy.

Required serialisations:

- `movement_plan.csv`
- `movement_plan.json`
- `canonical_envelopes/plans/*.json`

### POC-08.9 Release and receipt

Reconcile counts, upload canonical envelopes and serialised products to S3, independently read back, verify hashes, execute forced recovery and emit the final receipt envelope.

REAL requires:

- discovered input count reconciliation;
- every output traceable to canonical input envelope IDs;
- durable write and independent readback;
- content-hash verification;
- runtime telemetry;
- recovery exercise;
- final receipt and ledger entry.

## POC-09 Research Atlas

Use canonical envelopes to render the first production vertical slice:

- Theme 01 Human–AI Cognition & Performance
- Topic 001 Cognitive Performance
- Working Memory Optimisation

Theme 01 becomes the gold master. Themes 02–08 must be generated from the same renderer and component system.

The Atlas consumes canonical data envelopes and emits publication envelopes. HTML, JSON manifests, search indexes and page assets are deterministic serialisations or products of those envelopes.

REAL requires canonical-data generation, image/PDF first-class views, S3/CloudFront deployment, HTTP/readback verification, source-to-page lineage and receipts.

## Immediate order

1. Security/source freeze.
2. Implement and validate `t4h.canonical-envelope.v1`.
3. Recursive asset inventory into discovery envelopes.
4. Raw-byte download and SHA-256.
5. MIME and integrity validation.
6. Image metadata and perceptual hashes.
7. Exact/near duplicate relationship envelopes.
8. OCR and visual extraction.
9. Image CKO compilation and readback.
10. Classification graph and three chronologies.
11. Reversible movement plan envelopes.
12. Theme 01 Atlas vertical slice.
13. S3 release, independent readback and final reconciliation.

## Current truth

```yaml
visual_asset_compiler:
  artefact_exists: true
  github_status: REAL
  production_runtime: NOT_PROVEN
  classification: PARTIAL
canonical_data_contract:
  specification_status: REAL_ON_MERGE
  runtime_status: NOT_PROVEN
```
