# POC-08 Image Compiler Adapter — Symbio DEV Handoff

## Truth state

**Classification: PARTIAL / READY_FOR_DEV**

The repository contains a complete POC-08 execution plan, but no executable Image Compiler Adapter implementation was found.

Existing evidence:

- Canonical Pen issue: `TML-4PM/the-pen#245`
- Planning commit: `5cac719f3d31c911d6ff60482ede70ff8596d5d4`
- Plan path: `tasks/cko-poc08-visual-asset-compiler/EXECUTION_PLAN.md`
- POC-01 through POC-07 baseline: REAL according to issue receipts
- POC-08 executable adapter: NOT PROVEN
- `cko:image:*` runtime output: NOT PROVEN
- Image test-set receipts: NOT PROVEN
- S3 release/readback: NOT PROVEN

## Objective

Implement the first bounded executable vertical slice of the Image Compiler Adapter under the existing Canonical Knowledge Compiler. Do not create a competing CKO system.

## Phase 1 acceptance slice

Support and prove:

1. PNG
2. JPG
3. SVG
4. MIME mismatch
5. invalid/corrupt image recovery
6. exact duplicate detection

For each accepted image emit:

- stable `cko:image:*` identifier;
- source SHA-256;
- detected MIME and extension comparison;
- dimensions and colour mode where available;
- canonical metadata payload;
- compiler run ID;
- validation/policy result;
- receipt with independent readback.

## Required implementation paths

Create or extend the existing CKC structure with:

- image format adapter;
- image canonical schema;
- test fixtures;
- deterministic compiler tests;
- local durable receipt path;
- optional S3 release adapter;
- reconciliation receipt.

Exact paths should follow the current CKC layout discovered during implementation rather than inventing a parallel tree.

## Safety boundaries

- No source image deletion, move, rename or overwrite.
- Preserve original identifiers, paths and hashes.
- Quarantine corrupt or conflicting inputs.
- Supabase may index outputs but must not block compilation or acceptance.
- GitHub and local/S3 receipts must permit reconstruction.

## REAL gate

REAL requires:

- executable adapter committed;
- six-case acceptance set executed;
- deterministic IDs and hashes;
- one duplicate safely deduplicated;
- one corrupt input safely quarantined/recovered;
- independent output readback;
- receipts committed or immutably stored;
- GitHub readback of implementation commit and test evidence.

## Next phase after Phase 1

Only after the bounded slice is REAL:

- HEIF support;
- perceptual hashing and near-duplicate grouping;
- OCR and visual claims;
- relationship graph and chronology;
- OIKOS Journey recursive asset register;
- Theme 01 Research Atlas publication.
