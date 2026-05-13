# Runtime Core Level 5/6/7 Pack

Status: PARTIAL until executed against live Supabase/Bridge and smoke receipts are returned.

## Purpose
This pack lifts the ecosystem from project-by-project execution into a canonical operational cognition substrate.

It provides:
- canonical object registry
- append-only event fabric
- runtime job queue model
- telemetry spine
- evidence and Reality Ledger binding
- AGRO-compatible governance objects
- economics and signal engine tables
- graph cognition tables
- reconciliation and recovery views/functions
- bridge-ready execution payload
- smoke tests and verification queries

## Storage Ownership
| Layer | Store |
|---|---|
| Canonical truth | Supabase/Postgres |
| Event history | runtime.events append-only table |
| Evidence | audit.evidence_register + audit.reality_ledger |
| Governance | governance.governance_objects + policies |
| Runtime jobs | runtime.jobs + runtime.job_attempts |
| Telemetry | runtime.telemetry_events |
| Graph | graph.nodes + graph.edges |
| Economics | economics.signals + economics.object_economics |
| Large artifacts | S3/R2/Supabase Storage by reference |
| Intent/receipts/code | GitHub/the-pen |
| UI | Vercel or Command Centre projection only |

## Files
- `01_runtime_core_schema.sql` — canonical schemas/tables/functions/views
- `02_runtime_core_seed.sql` — baseline runtime classes, policies, checks, and starter objects
- `03_runtime_core_api_contract.md` — API/event/receipt contract
- `04_bridge_execution_payload.json` — bridge-ready invocation payload
- `05_smoke_tests.sql` — direct SQL smoke tests
- `06_worker_contract.ts` — TypeScript worker contract skeleton
- `07_reconciliation_rules.md` — drift/recovery rules
- `08_command_centre_widget_spec.md` — runtime health widget contract
- `09_reality_ledger_receipt.md` — receipt template and promotion criteria

## REAL promotion gates
This pack becomes REAL only after:
1. SQL migration executed successfully.
2. Seed executed successfully.
3. Smoke tests pass.
4. At least one object is created.
5. At least one event is appended.
6. Runtime state is derived from events.
7. Evidence receipt is written.
8. Reality Ledger row is written.
9. Reconciliation view returns PASS/FAIL state.
10. Bridge receipt is returned and stored.

## Canonical doctrine
Everything is an object.
Every object moves through events.
Every event emits telemetry or evidence.
Every claim binds to Reality Ledger.
Every runtime must be replayable, governable, recoverable, and economically measurable.
