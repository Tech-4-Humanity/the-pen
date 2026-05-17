# GDrive Research Sweeper Daily — Canonical Spec

Status: PARTIAL until runtime job executes and receipt exists.

## Purpose

Defrost the ATO/R&D evidence system by creating a daily Google Drive research sweep that turns scattered Drive artefacts into structured evidence objects.

## Trigger

Daily at 06:00 Australia/Sydney.

## Sources

- Google Drive research folders
- pricing/product folders
- RFT/RFQ folders
- exported chats and PDFs
- experiment register source files
- website/domain evidence folders

## Required cycle

Drive file change -> classify -> evidence object -> project/experiment/product linkage -> gap/challenge mapping -> receipt -> Command Centre visibility.

## Output objects

1. `evidence_events`
2. `evidence_objects`
3. `experiment_lifecycle_updates`
4. `pricing_snapshots`
5. `rft_rfq_actions`
6. `challenge_register_updates`
7. `daily_reconciliation_receipt`

## Classification rules

Every discovered file must be tagged:

- project_id
- business_id
- evidence_type
- source_system = google_drive
- source_url
- file_name
- mime_type
- created_at
- modified_at
- detected_at
- sha256 if available
- rdt_relevance
- claim_window
- truth_status
- confidence
- gap_flag

## R&D claim linkage

Each item must attempt linkage to:

- research project
- experiment register row
- uncertainty/hypothesis
- activity period
- labour/spend where available
- output asset
- commercial pathway

## Failure rule

If a file cannot be classified, do not discard it. Write a gap row:

`status = NEEDS_CLASSIFICATION`

## Runtime proof required

The sweeper is not REAL until:

1. It runs unattended.
2. It writes at least one receipt.
3. It records sources checked.
4. It records number of files scanned.
5. It records created/updated evidence rows.
6. It records failures/gaps.
7. Receipt is committed or written to ledger.

## Bridge execution target

Function: `troy-gdrive-research-sweeper` or nearest available Bridge worker.

Fallback: create worker spec and queue in Pen inbox.

## Receipt path

`receipts/runtime/ato-research/gdrive-research-sweeper/YYYY-MM-DD.md`

## Reality classification

Current: PARTIAL

Reason: Canonical spec exists, but no runtime receipt yet.

## Next action

Build/queue the worker and require first daily-run receipt.
