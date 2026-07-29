# FY24/25 RDTI evidence pack preparation

Status: **PARTIAL — preparation area only**

Owner: Tech 4 Humanity Pty Ltd / Troy Latter  
Examination reference: `2425-AP00-063-843`  
Registration reference: `PYV4R3VPW`  
Related issue: [#307](https://github.com/TML-4PM/the-pen/issues/307)

## Purpose

This directory is the controlled assembly area for recreating the FY24/25 RDTI response and evidence packs from primary evidence.

Nothing in this directory is submission-ready merely because it is present. A source becomes **REAL** only after source readback, evidence binding, validation, hashing, and reconciliation.

## Current financial control state

| Item | Current control | Classification |
|---|---:|---|
| Labour | $677,750 | PARTIAL — modeled timesheet requires evidence corroboration |
| Contractors | $0 | INVALIDATED/CLOSED |
| DCC legal costs | $0 | INVALIDATED |
| Non-labour ceiling | $200,041 | PARTIAL |
| Detailed non-labour located | $193,175 | PARTIAL |
| Remaining stated gap | $6,866 | PARTIAL — recalculate after full account reconciliation |

## Preparation structure

- `inputs/source_manifest.csv` — controlled source inventory.
- `inputs/legacy-packs/` — superseded packs retained for contradiction analysis only.
- `inputs/drafts/` — working drafts, never submission-ready by default.
- `research/study_research_index.csv` — online research and study evidence links.
- `gallery/image_gallery_index.csv` — online images and exhibit metadata.
- `registers/pack_component_register.csv` — every expected pack component, including placeholders.
- `registers/supersession_register.csv` — invalidated and superseded assertions.
- `submission/README.md` — gated output area.
- `receipts/README.md` — execution, hashing and readback evidence.

## Pack families to recreate

1. ATO submission evidence pack.
2. Contemporaneous R&D activity pack.
3. Financial reconciliation pack.
4. Evidence and exhibit register.
5. Supersession and contradiction ledger.
6. Gap and submission-readiness report.
7. Director attestation, generated only after final evidence and figures are locked.
8. Additional packs or annexures as discovered.

## Rules

- Do not commit bank statements, invoices, personal records, credentials, signatures or confidential source documents to GitHub.
- GitHub stores schemas, privacy-safe indexes, manifests, hashes, redacted extracts and build logic.
- Original evidence belongs in the approved evidence store; record its stable URI and hash here.
- Online research and gallery items require URL, capture date, owner, relevance, rights/status and immutable capture reference.
- Modeled, reconstructed and contemporaneous records must remain distinguishable.
- Do not infer missing evidence.
- Contractors remain $0 and DCC remains $0 unless explicitly re-authorised with valid primary evidence.
- No pack may be marked REAL until totals reconcile and an independent readback receipt exists.

## Immediate next gate

Populate the source, research and gallery indexes; reconcile the modeled timesheet against actual dated activity evidence; then build the first evidence-bound CA1 chronology.
