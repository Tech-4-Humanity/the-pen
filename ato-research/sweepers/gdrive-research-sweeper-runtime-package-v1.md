# GDrive Research Sweeper — Runtime Package v1

Status: PARTIAL → becomes REAL after first runtime execution receipt.

## Intent

Stop reconstructing. Sweep Google Drive daily and convert research, pricing, RFT/RFQ, experiment, and site evidence files into structured evidence objects automatically.

## Bridge Invocation Payload

```json
{
  "action": "invoke_function",
  "function_name": "troy-gdrive-research-sweeper",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "execute",
    "sources": [
      "research",
      "pricing",
      "rft_rfq",
      "experiment_register",
      "chat_exports",
      "website_evidence"
    ],
    "google_drive": {
      "root_folders": [
        "/Research",
        "/ATO",
        "/AI Sweet Spots",
        "/Augmented Humanity Coach",
        "/HoloOrg",
        "/WorkFamilyAI",
        "/RFT",
        "/Pricing"
      ],
      "modified_since": "-24h"
    },
    "classify": true,
    "create_evidence_objects": true,
    "write_receipts": true,
    "write_gaps": true,
    "write_command_centre": true,
    "receipt_path": "receipts/runtime/ato-research/gdrive-research-sweeper/"
  },
  "metadata": {
    "request_id": "gdrive_sweeper_test_001",
    "source": "chatgpt",
    "timestamp_utc": "2026-05-17T00:00:00Z"
  }
}
```

## Worker Flow

```text
Google Drive
↓
Find changed files for the last 24h
↓
Extract metadata
↓
Classify by research/project/product/RFT/evidence type
↓
Link to project, experiment, claim, website, pricing, RFT/RFQ
↓
Create evidence object
↓
Write ledger rows
↓
Write receipt
↓
Update Command Centre
```

## Minimal SQL Tables

```sql
create table if not exists evidence_events (
  id uuid primary key,
  source_system text,
  source_url text,
  file_name text,
  event_type text,
  detected_at timestamptz default now()
);

create table if not exists evidence_objects (
  id uuid primary key,
  project_id text,
  evidence_type text,
  source_system text,
  title text,
  truth_status text,
  confidence numeric,
  created_at timestamptz default now()
);

create table if not exists evidence_gaps (
  id uuid primary key,
  title text,
  reason text,
  status text,
  created_at timestamptz default now()
);
```

## Test Receipt Shape

```yaml
status: REAL
run_id: gdrive_sweeper_test_001
files_scanned: 284
new_files: 14
updated_files: 23
evidence_objects_created: 31
linked_to_projects:
  - AI Sweet Spots
  - HoloOrg
  - Augmented Humanity Coach
  - WorkFamilyAI
rft_items_detected: 4
pricing_changes_detected: 2
gaps:
  - orphan PDF in /Research/tmp
receipt_written: true
command_centre_updated: true
duration_seconds: 41
```

## First Success Criteria

1. Run once manually through Bridge.
2. Produce a real receipt.
3. Verify evidence objects exist.
4. Schedule daily 06:00 Australia/Sydney.
5. Failed classification creates gap rows, not silence.

## Reality Classification

Current status: PARTIAL

REAL requires:

- Bridge invocation response
- worker execution receipt
- evidence rows written or explicit no-change receipt
- scheduler confirmation
- receipt stored under `receipts/runtime/ato-research/gdrive-research-sweeper/`

## Next Action

Bridge must build/run the worker from this package and return the first receipt.
