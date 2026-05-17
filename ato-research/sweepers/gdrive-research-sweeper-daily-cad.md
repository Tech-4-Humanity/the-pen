# CAD — Daily GDrive Research Sweeper

Status: PARTIAL until Bridge or worker executes a test run and writes a receipt.

## 1. Mission

Create the first continuous-cycle proof for the ATO/R&D evidence system.

The sweeper must run daily and turn Google Drive research material into structured, timestamped, challenge-ready evidence objects.

The goal is not folder backup. The goal is audit reconstruction:

**Drive file -> evidence object -> project linkage -> challenge/defence mapping -> receipt -> dashboard.**

## 2. Current problem

The estate contains research artefacts, websites, experiment registers, pricing assets, RFT/RFQ material and chat exports, but the system does not yet prove continuous unattended capture.

That creates reconstruction risk.

## 3. Command

Run once now as a smoke test, then schedule daily at 06:00 Australia/Sydney.

## 4. Inputs

### Required source families

- Google Drive research folders
- Google Drive pricing/product folders
- Google Drive RFT/RFQ folders
- Google Drive exported chats and PDFs
- Google Drive website/domain evidence folders
- Experiment register source/export files

### Search terms / classification hints

- R&D
- RDTI
- ATO
- research
- experiment
- hypothesis
- uncertainty
- prototype
- evidence
- pricing
- price
- SKU
- Stripe
- RFT
- RFQ
- tender
- proposal
- Augmented Humanity Coach
- HoloOrg
- WorkFamilyAI
- Augmented Memories
- AI Sweet Spots
- MyNeuralSignal
- Outcome Ready
- Reading Buddy

## 5. Outputs

The worker must produce these objects or files:

1. `evidence_events`
2. `evidence_objects`
3. `experiment_lifecycle_updates`
4. `pricing_snapshots`
5. `rft_rfq_actions`
6. `challenge_register_updates`
7. `daily_reconciliation_receipt`

If Supabase is unavailable, write JSONL to GitHub receipt path and mark runtime state as PARTIAL.

## 6. Evidence object schema

```json
{
  "evidence_id": "evd_<date>_<hash>",
  "source_system": "google_drive",
  "source_url": "",
  "drive_file_id": "",
  "file_name": "",
  "mime_type": "",
  "created_at_source": "",
  "modified_at_source": "",
  "detected_at_utc": "",
  "sha256": "",
  "business_id": "",
  "project_id": "",
  "experiment_id": "",
  "evidence_type": "research|pricing|rft_rfq|website|chat_export|product|other",
  "claim_window": "pre_period|fy24_25|fy25_26|unknown",
  "rdt_relevance": "high|medium|low|unknown",
  "truth_status": "REAL|PARTIAL|BLOCKED",
  "confidence": 0.0,
  "summary": "",
  "challenge_vectors": [],
  "defence_notes": [],
  "gap_flags": []
}
```

## 7. Runtime algorithm

1. Load configuration.
2. Authenticate to Google Drive through Bridge-authorised connector or service account.
3. Enumerate target folders and/or Drive query results.
4. For each file:
   - collect metadata
   - compute content hash where possible
   - classify by filename, folder path, MIME type, and searchable text preview where available
   - link to known business/project/experiment/product
   - detect claim window
   - assign evidence type and RDT relevance
   - create or update evidence object idempotently
5. Write gap row for anything unclassified.
6. Produce receipt.
7. Write receipt to GitHub and/or Supabase.
8. Return structured summary to Bridge.

## 8. Idempotency

Key:

`source_system + drive_file_id + modified_at_source + sha256`

If the same key exists, do not duplicate. Update `last_seen_at_utc` only.

## 9. Failure rules

- Missing Google credentials -> BLOCKED with precise missing dependency.
- Drive API unavailable -> PARTIAL with retry note.
- Supabase unavailable -> write GitHub JSONL receipt and mark PARTIAL.
- Classification uncertain -> create evidence object with `truth_status=PARTIAL` and `gap_flags=["needs_classification"]`.
- No files found -> still write receipt with sources checked.

## 10. Receipt schema

```json
{
  "run_id": "gdrive_sweeper_<timestamp>",
  "status": "REAL|PARTIAL|BLOCKED",
  "started_at_utc": "",
  "ended_at_utc": "",
  "sources_checked": [],
  "files_seen": 0,
  "files_created": 0,
  "files_updated": 0,
  "files_unchanged": 0,
  "gaps_created": 0,
  "errors": [],
  "receipt_paths": [],
  "next_run_due": ""
}
```

## 11. Receipt paths

Markdown:

`receipts/runtime/ato-research/gdrive-research-sweeper/YYYY-MM-DD.md`

JSON:

`receipts/runtime/ato-research/gdrive-research-sweeper/YYYY-MM-DD.json`

## 12. Bridge invocation envelope

```json
{
  "action": "invoke_function",
  "function_name": "troy-gdrive-research-sweeper",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "smoke_test_then_schedule",
    "schedule": "daily_0600_australia_sydney",
    "sources": [
      "google_drive_research",
      "google_drive_pricing_products",
      "google_drive_rft_rfq",
      "google_drive_chat_exports",
      "google_drive_website_domain_evidence",
      "experiment_register_sources"
    ],
    "output_targets": [
      "github_receipts",
      "supabase_evidence_ledger",
      "command_centre_status"
    ],
    "fallback": {
      "if_supabase_unavailable": "write_github_receipt_jsonl",
      "if_drive_unavailable": "blocked_precise_dependency"
    },
    "idempotency_key_fields": [
      "source_system",
      "drive_file_id",
      "modified_at_source",
      "sha256"
    ]
  },
  "metadata": {
    "request_id": "ato_gdrive_sweeper_daily_cad_v1",
    "source": "chatgpt",
    "created_for": "ATO Research continuous evidence cycle",
    "truth_requirement": "first_run_receipt_required_before_REAL"
  }
}
```

## 13. Smoke test acceptance criteria

The first run is acceptable only if it returns:

- run id
- source locations checked
- file count, even if zero
- at least one receipt path
- structured status
- error list, even if empty
- next run due or scheduler status

## 14. Daily schedule acceptance criteria

The scheduled job is acceptable only if:

- scheduler exists
- timezone declared
- last run visible
- next run visible
- failed run creates an alert/gap, not silence

## 15. Command Centre widget requirements

Widget: `ato_gdrive_sweeper_status_v1`

Fields:

- last_run_status
- last_run_time
- files_seen
- evidence_created
- gaps_created
- next_run_due
- latest_receipt_url
- top_unclassified_items

## 16. Reality Ledger classification

Current state: PARTIAL

REAL only after:

1. Worker runs.
2. Receipt exists.
3. At least one output target is written.
4. Result is replayable.
5. Schedule or next-run mechanism is visible.

## 17. Test run instruction

Bridge should execute this CAD in smoke-test mode immediately.

If the worker does not exist, Bridge must create a build task named:

`build_troy_gdrive_research_sweeper_worker`

and return BLOCKED/PARTIAL with the exact missing component.

## 18. Ledger

```yaml
status: PARTIAL
result: CAD created for daily Google Drive research sweeper and smoke-test execution.
evidence:
  - canonical CAD committed to GitHub
gaps:
  - no worker receipt yet
  - no scheduler receipt yet
  - no Drive API execution proof yet
next_action:
  - run Bridge smoke test
  - inspect receipt
  - promote to REAL only if output exists
elevation: This is the missing continuous-cycle engine for ATO/R&D evidence.
pressure_flags:
  - months_of_stall
  - continuous_cycle_missing
  - reconstruction_risk
score: 0.74
```
