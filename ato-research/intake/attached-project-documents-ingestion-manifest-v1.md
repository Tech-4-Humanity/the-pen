# Attached Project Documents Ingestion Manifest v1

Status: PARTIAL

## Purpose

Bring the ATO/R&D project-space documents and chat-derived artefacts into the canonical research evidence system so they are not trapped in chat, uploads, or local project context.

This is the intake manifest for documents attached in the current project space and documents referenced from previous chats.

## Canonical target

Repository: `TML-4PM/the-pen`

Primary folder:

`ato-research/source-documents/`

Supporting folders:

- `ato-research/source-documents/ato-notices/`
- `ato-research/source-documents/research-registers/`
- `ato-research/source-documents/product-pricing/`
- `ato-research/source-documents/domain-structure/`
- `ato-research/source-documents/social-media-ban/`
- `ato-research/source-documents/house-rules/`
- `ato-research/source-documents/asset-registers/`
- `ato-research/source-documents/external-articles/`
- `ato-research/source-documents/screenshots/`
- `ato-research/source-documents/chat-derived/`

## Current project-space attachments to ingest

### ATO / Audit source documents

- `Statement of Issues.pdf`
- `Notice of Examination.pdf`
- `this-year-heres-what-the-ato-expects-you-to-document.txt`

### Asset / registry / pricing documents

- `00_research-asset-register-service-catalogue-v1-package.zip`
- `master-asset-matrix (2).html`
- `products and prices (1).pdf`
- `new url STRUCTURE - Domain level.pdf`
- `unified_standard_knowledge_system (1).xlsx`
- `f3f2805c-2c7a-49e2-bb9b-1298f580e997.html` — Experiment Register Search UI

### House rules / runtime governance documents

- `house-rules-engine-production (1).zip`
- `HOUSE RULES ENGINE.pdf`
- `AGENT HOUSE RULES — CANONICAL BOOTSTRAP (v2.pdf`

### Research / social policy documents

- `SM 3.0 - where shoulld the study go now _.pdf`

### Screenshots attached in project chat

- RFT Analysis Platform screenshot
- CV pricing / role pricing screenshot
- Additional ATO/pricing/platform screenshots from this thread

## Required metadata per ingested document

Every document must receive a sidecar metadata row/object:

```yaml
source_doc_id: <stable slug or uuid>
file_name: <original file name>
canonical_path: <repo path or storage path>
source_origin: chat_upload | project_space | drive | github | vercel | external_url | unknown
source_thread: ato-research-response
source_date_detected: <timestamp>
document_type: ato_notice | product_pricing | registry | house_rule | research_register | screenshot | article | chat_extract | unknown
claim_window: pre_fy25 | fy25 | post_fy25 | cross_period | unknown
rdt_relevance: high | medium | low | unknown
linked_projects:
  - <project ids>
linked_businesses:
  - <business ids>
linked_experiments:
  - <experiment ids>
truth_status: REAL | PARTIAL | BLOCKED
hash_required: true
classification_notes: <short note>
```

## Required ingestion cycle

1. Copy/source the document into canonical storage.
2. Preserve original filename in metadata.
3. Add canonical slug/path.
4. Generate SHA256 hash where possible.
5. Classify document type.
6. Link to project/business/experiment/product/RFT/RFQ where possible.
7. Create gap row where linkage is unclear.
8. Write receipt.

## Chat-derived artefacts to reconstruct

The following concepts from recent chats must be converted into source documents or registry rows:

- Evidence everywhere = evidence nowhere
- Evidence → index → linkage → defence
- Dollar → actor → uncertainty → experiment → evidence → challenge → defence
- Continuous-cycle gap note
- GDrive research sweeper daily spec
- GDrive research sweeper runtime package v1
- Product/pricing extraction notes
- RFT/RFQ June activity evidence note
- Experiment Register Search UI interpretation

## Runtime requirement

This manifest is not enough. A daily sweeper must ingest attached/project-space documents into this structure, then reconcile against Drive and GitHub.

## Reality classification

Current status: PARTIAL

REAL requires:

- documents copied or mirrored into canonical storage
- sidecar metadata created
- hashes recorded
- receipt written
- daily sweeper includes the attachment/project-space source

## Next action

Bridge should build or run an ingestion worker that consumes this manifest, copies the listed documents into canonical storage, creates metadata sidecars, and returns a receipt.
