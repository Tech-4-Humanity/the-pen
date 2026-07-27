# OIKOS R&D Tax Audit Visual Research Exhibition — Lossless Handover

Date: 2026-07-26
Status: CONTINUE
Priority: Build the bounded audit exhibition before broader enterprise tooling.

## Critical correction

This thread exists to build the R&D tax audit visual research exhibition from the OIKOS Journey image collection. The exhibition is separate from the site that houses research data, studies, hypotheses and user stories.

Do not expand this bounded work into a general enterprise knowledge operating system, browser platform, Synal architecture or institutional-memory programme before the audit exhibition is usable.

## Primary objective

Create a live, evolving audit evidence exhibition that functions simultaneously as:

1. a guided visual research story;
2. a browsable gallery and timeline;
3. a formal audit evidence library.

The site may be public while evolving. Editorial changes must affect metadata and ordering, not destroy or silently rewrite source evidence.

## Canonical source

- Google Drive folder: `OIKOS Journey`
- Folder ID: `1zRntgc-Zay0BH5etxH-FYup6q5zCPfo4`
- URL: `https://drive.google.com/drive/folders/1zRntgc-Zay0BH5etxH-FYup6q5zCPfo4`
- Connected Drive identity: `troy@tech4humanity.com.au`

## Canonical GitHub artefacts

- Repository: `TML-4PM/the-pen`
- POC-08 commit: `5cac719f3d31c911d6ff60482ede70ff8596d5d4`
- Message: `Add POC-08 visual asset compiler and Atlas execution plan`
- Canonical-envelope PR: `#276`
- Canonical-envelope commits:
  - `a7cd1d320acd2c3d9bd0b992a486ad74ccfc6406`
  - `8761f96332450b516cfcc9bebd3ec44a29e82d99`

Current truth:

```yaml
visual_asset_compiler:
  specification: REAL
  production_runtime: NOT_PROVEN
  classification: PARTIAL

canonical_envelope:
  specification: REAL
  github_readback: REAL
  runtime_implementation: NOT_PROVEN
  classification: PARTIAL
```

## Architectural boundary

Continue POC-08. Do not create a competing canonical-object system.

Every compiler, adapter, worker and publisher consumes and emits the same provider-neutral canonical envelope. Images, PDFs, registers, chronology events, movement plans, publications and receipts are typed payloads inside the same envelope.

## Required Drive structure

The following direct child folders have already been created under OIKOS Journey:

| Folder | Drive ID |
|---|---|
| 00_REGISTER_AND_ADMIN | `1x0ZAmhMLqK4cLEllWfN0uWeiPj_kxVyl` |
| 01_RESEARCH_FOUNDATIONS | `1rFteFunczdj5tBDdGFze6FJ78fMf3ayj` |
| 02_T4H_ECOSYSTEM | `1igeBZ3g4ToDGUM_2_2pD_H1t7bAs0dU0` |
| 03_FRAMEWORKS_AND_HYPOTHESES | `1LWe53MS_ji4ti3Rds7GLAaOxi2O_C9y2` |
| 04_OIKOS_EVOLUTION | `1mHYUmfoQ34dfn7nIX9ZssLGQv91TQx0b` |
| 05_OUTCOME_READY | `1IpoWHE8fbTS_YeEbq8S20i37hDezr5bj` |
| 06_TRUST_IDENTITY_AND_CONSENT | `1WU4GlM1puL4KM8GXqaYwJ7FPcGBmChRp` |
| 07_RDTI_AND_AUDIT_EVIDENCE | `1-BVwgGBYRzuGC4rceDRXncfof_PAhM-H` |
| 08_ORGANISATIONAL_INTELLIGENCE | `1121bZp7MrcZqiAh3vmkrafT5rzhCAlYU` |
| 09_FUTURE_OF_WORK | `1dONKm4aWWGbt1ni5g2V40Gi3QAM6FqP5` |
| 10_POSTERS_AND_STUDIES | `1pQGmMtb-mbVb8Rq65AcmrwJOG_iThyDz` |
| 11_FINAL_EXHIBITION_SELECTION | `1a7ZJVYF12OmETHDxXZiJbmnZUPtXt3yq` |
| 90_DUPLICATES_AND_ALTERNATES | `1IuMMy9GPgPCJDXFBjugwwNFOJaMW886-` |
| 99_UNCLASSIFIED_INTAKE | `1jdtnn8sKoFgRHNR35Bkq7slxCUQ2NtQ4` |

No source files should be moved until the canonical register exists.

## Required audit exhibition

### Core pages and modes

- Home / who we are / what we do / why this is here
- Guided story
- Gallery
- Timeline
- Research tracks
- Evidence library
- Full-screen exhibit viewer
- Archive
- Exhibition
- Working set
- External/internal research resources
- Surveys and assessments
- Get involved / contact

Do not add a blog.

### Research tracks

The initial structure must support at least:

- Research foundations
- Dr Doolittle
- Sinai
- Multi-agent orchestration
- Human–AI communication
- Memory and cognition
- Safety and assurance
- OIKOS evolution
- Outcome Ready
- Trust, identity and consent
- Organisational intelligence
- Future of work
- RDTI and audit evidence
- Posters and studies
- Prototype progression

### Editorial behaviour

The user must be able to change the story over time by editing metadata:

- chapter
- section
- display order
- featured
- hidden
- needs review
- notes
- duplicate/master relationship

Archive completeness and narrative order are separate concerns.

## Canonical asset register

The register must include, at minimum:

- Exhibit ID
- Envelope ID
- Object ID
- Original filename
- Current filename
- Drive file ID
- Original path
- Drive-created and Drive-modified dates
- EXIF/capture date
- Research-event date
- Publication date
- Theme
- Research track
- Chapter
- Section
- Display order
- Artifact type
- Phase
- Evidence type
- Duplicate group
- Relationship role
- SHA-256
- Perceptual hash
- Declared/detected MIME
- Dimensions and size
- Summary
- Why it matters
- Research question
- Related R&D activity
- Related exhibits and documents
- Related sites/resources
- Confidence
- Status
- Recommended destination
- Featured/hidden/review flags
- Notes

## Evidence rules

Every exhibit must distinguish:

- contemporaneous evidence;
- later explanatory annotation;
- reconstructed chronology;
- working draft;
- final outcome;
- derived visual summary.

Do not infer missing values merely to satisfy a schema. Store date types separately. Every inference needs confidence and evidence references.

## Known findings

- The source set contains at least 100 assets across PNG, WebP, HEIF and PDF.
- The collection broadly spans March to July 2026.
- Clear streams include research foundations, T4H ecosystem, frameworks, OIKOS, Outcome Ready, trust/identity/consent, organisational intelligence, future of work, RDTI and posters/studies.
- Multiple probable duplicate families were identified from equal file size and near timestamps.
- One suspicious file requires quarantine review: `ChatGPT Image Jun 25, 2026, 08_15_13 PM.png`, reported at 45 bytes.
- Metadata-only inspection is not sufficient to claim exact duplicates or complete chronology.

## Work packages

### WP-01 — Complete asset crawl

Enumerate all descendants and produce:

- `asset_register.csv`
- `asset_register.json`
- `asset_register.parquet`
- `folder_structure.csv`
- `source_inventory_receipt.json`

### WP-02 — Integrity and metadata

Download originals and produce raw-byte SHA-256, MIME validation, dimensions, EXIF and invalid/truncated records.

### WP-03 — Duplicate intelligence

Establish exact duplicates by SHA-256 and near duplicates by perceptual hash, OCR, dimensions and visual similarity. Keep all files; assign relationships such as MASTER, Derived, Generated, Alternative, Draft, Published, Social, Presentation or Unknown.

### WP-04 — OCR and visual interpretation

Extract visible text, claims, metrics, entities, audiences, versions, summaries and sensitivity findings.

### WP-05 — Chronology

Produce separate source, research-event and publication chronologies, with conflicts and review queue.

### WP-06 — Classification and chaptering

Assign themes, tracks, phases, chapters, sections and recommended display order.

### WP-07 — Draft live audit site/tool

Generate and deploy a working S3/CloudFront exhibition from the current image collection. It should be useful immediately even before the entire corpus is perfected.

### WP-08 — Editorial loop

Provide rapid metadata-driven reordering, hiding, featuring and notes, followed by site regeneration.

### WP-09 — Movement plan

Generate reversible KEEP, MOVE, RENAME, MERGE, QUARANTINE, ARCHIVE and REVIEW actions. Preserve original IDs, names and paths.

### WP-10 — Final receipt

Reconcile counts, hashes and published objects; verify S3 and HTTP readback; emit final receipt.

## Definition of done

The bounded audit exhibition is complete only when:

- the asset register covers the entire source set;
- integrity and duplicate analysis are complete;
- chronology is explicit and confidence-labelled;
- the live site exists and is readable;
- every exhibit has provenance and evidence type;
- editorial sequencing can change without destructive source moves;
- S3/CloudFront deployment has independent readback;
- counts and hashes reconcile;
- a final runtime/deployment receipt exists.

## Runtime status

A governed T4H GPT TML echo was attempted from this conversation and returned:

```text
FORBIDDEN: This conversation does not support developer MCPs
```

Do not misclassify this as runtime execution. GitHub and Google Drive connector operations remain available; full runtime ownership must be established in a compatible execution context.

## Workbook

The companion workbook is:

`OIKOS_RDTI_Audit_Exhibition_Lossless_Handover_20260726.xlsx`

It contains executive summary, scope boundaries, thread chronology, decisions, asset schema, Drive structure, evidence/gaps, site specification, source/resource registry, work packages, risks, receipts, worker handover and status dashboard.
