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

## Architectural boundary

```text
source connector
→ asset discovery record
→ format adapter, including Image Adapter
→ Canonical Knowledge Compiler
→ CKO
→ validation and policy
→ relationship graph
→ search and memory
→ movement/publication compilers
→ receipts
```

Do not create a competing canonical-object system.

- Canonical Asset Register: repository inventory truth
- Image Compiler Adapter: visual processing
- Canonical Knowledge Compiler: CKO production
- Movement Planner: reversible repository changes
- Atlas Publication Compiler: static research portal generation

## Execution stages

### POC-08.0 Security and source freeze

Capture folder metadata and permissions, preserve a pre-change inventory, remove public writer access after named-editor verification, and separate canonical evidence from publication copies.

### POC-08.1 Recursive discovery

Crawl all descendants and emit:

- `asset_register.csv`
- `asset_register.json`
- `asset_register.parquet`
- `folder_structure.csv`
- `source_inventory_receipt.json`

### POC-08.2 Integrity and metadata

Record SHA-256, byte-signature MIME, extension, size, dimensions, colour mode, EXIF, page count/duration and invalid/truncated state.

Outputs:

- `hashes.csv`
- `image_metadata.csv`
- `invalid_assets.csv`
- `mime_conflicts.csv`

### POC-08.3 Duplicate intelligence

Exact duplicates require SHA-256 equality. Near duplicates use perceptual hash, dimensions, OCR and visual similarity.

Outputs:

- `perceptual_hashes.csv`
- `duplicates.csv`
- `image_similarity_groups.csv`
- `asset_families.csv`

### POC-08.4 OCR and visual claims

Route by visual mode and extract visible text, claims, metrics, entities, audience, version, privacy and sensitivity findings.

Outputs:

- `image_text_extraction.jsonl`
- `image_descriptions.jsonl`
- `visual_claims.csv`
- review queues

### POC-08.5 Image CKO compilation

Create stable `cko:image:*` objects with compiler runs, telemetry, policy decisions, Supabase persistence/readback, S3 release/readback, recovery and receipts.

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

### POC-08.7 Chronology

Store Drive-created, Drive-modified, filesystem, EXIF/capture, filename generation, upload, research-event and publication dates separately.

Outputs:

- `timeline.csv`
- `timeline_evidence.json`
- `date_conflicts.csv`
- `chronology_review_queue.csv`

### POC-08.8 Movement planner

Generate reversible KEEP, MOVE, RENAME, MERGE, QUARANTINE, ARCHIVE and REVIEW plans. Preserve original IDs, names and paths.

### POC-08.9 Release and receipt

Reconcile counts, upload outputs to S3, read back, verify hashes, execute forced recovery and emit the final receipt.

## POC-09 Research Atlas

Use canonical objects to render the first production vertical slice:

- Theme 01 Human–AI Cognition & Performance
- Topic 001 Cognitive Performance
- Working Memory Optimisation

Theme 01 becomes the gold master. Themes 02–08 must be generated from the same renderer and component system.

REAL requires canonical-data generation, image/PDF first-class views, S3/CloudFront deployment, HTTP/readback verification, source-to-page lineage and receipts.

## Immediate order

1. Security/source freeze.
2. Recursive asset inventory.
3. Raw-byte download and SHA-256.
4. MIME and integrity validation.
5. Image metadata and perceptual hashes.
6. Exact/near duplicate groups.
7. OCR and visual extraction.
8. Image CKO persistence and readback.
9. Graph and chronology.
10. Movement plan.
11. Theme 01 Atlas vertical slice.
12. S3 release and final reconciliation.
