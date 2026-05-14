# LLM Lake Every Thread Final Execution Contract

## Status
PARTIAL until runtime execution receipts prove full corpus ingestion and every-thread analysis.

## Non-negotiable objective
Continue execution until the complete thread corpus is ingested, analysed, summarised, classified, receipt-linked, and written into the Reality Ledger.

No clarification loop. No simulated completion. No summary-only stopping point. Human loop only if credentials, legal authority, destructive mutation, or external spend boundary blocks execution.

## Source runtime
- S3 bucket: `s3://llm-history-lake-140548542136-ap-southeast-2`
- Expected objects: `conversations.json`, `projects.json`, `users.json`
- Uploaded starter bundle: `llm_lake_ingest_bundle(1).zip`

## Required execution sequence
1. Inspect bucket and write object manifest with hashes, sizes, timestamps.
2. Validate presence of required objects.
3. Apply SQL schema from `sql/001_llm_lake_schema.sql`.
4. Run ingest command:
   ```bash
   python3 -m pip install -r requirements.txt
   python3 -m src.llm_lake_ingest --config config/llm_lake_ingest.json
   python3 -m src.validate_ingest --config config/llm_lake_ingest.json
   ```
5. Generate every-thread analysis schema/tables.
6. Analyse every conversation/thread.
7. Extract all unresolved actions and bridge handoffs.
8. Link existing receipts where available.
9. Create missing receipt register.
10. Map every thread to business/product/domain where possible.
11. Generate corpus-level reports.
12. Write evidence register rows.
13. Write Reality Ledger rows.
14. Emit final receipt.

## Required tables or equivalent materialised outputs
- `runtime.llm_thread_summary`
- `runtime.llm_thread_intent`
- `runtime.llm_thread_task`
- `runtime.llm_thread_bridge_handoff`
- `runtime.llm_thread_receipt_link`
- `runtime.llm_thread_gap`
- `runtime.llm_thread_business_map`
- `runtime.llm_thread_cluster`
- `runtime.llm_thread_economic_signal`
- `runtime.llm_thread_reuse_pattern`
- `runtime.llm_thread_validation_result`

## Per-thread minimum fields
- source_system
- source_object
- source_hash
- thread_id
- title
- created_at
- updated_at
- message_count
- primary_intent
- secondary_intents
- intense_summary
- decisions_made
- assets_requested
- assets_produced
- businesses_referenced
- products_referenced
- bridge_handoffs_requested
- bridge_handoff_status
- receipts_found
- receipts_missing
- unresolved_actions
- blockers
- pressure_flags
- economic_value_path
- reuse_pattern
- reality_state
- evidence_uris
- next_executable_action
- confidence_score
- validation_status

## Corpus outputs
- `reports/llm-lake/all-thread-executive-summary.md`
- `reports/llm-lake/unresolved-execution-backlog.csv`
- `reports/llm-lake/bridge-handoff-queue.csv`
- `reports/llm-lake/missing-receipt-register.csv`
- `reports/llm-lake/thread-business-map.csv`
- `reports/llm-lake/thread-cluster-map.csv`
- `reports/llm-lake/monetisation-opportunity-map.csv`
- `reports/llm-lake/reuse-pattern-register.csv`
- `reports/llm-lake/reality-ledger-summary.json`

## Required receipts
- `receipts/runtime/llm-lake-ingest.receipt.json`
- `receipts/runtime/llm-lake-ingest.validation.receipt.json`
- `receipts/runtime/llm-thread-analysis.receipt.json`
- `receipts/runtime/llm-thread-analysis.validation.receipt.json`
- `receipts/runtime/llm-lake-final.receipt.json`

## REAL promotion gates
REAL only when all are true:
- Required S3 objects were read.
- Manifest hashes were recorded.
- Supabase schema writes succeeded.
- Ingest count is greater than zero.
- Thread analysis count equals ingested conversation/thread count.
- Every analysed thread has a summary and classification.
- Evidence register rows exist.
- Reality Ledger rows exist.
- Final validation receipt reports PASS.

## BLOCKED gates
Classify BLOCKED only with bounded reason if:
- S3 credentials missing or bucket inaccessible.
- Supabase URL/service-role missing.
- Bridge runner unavailable.
- Required corpus objects absent.
- Network/runtime dependency failure prevents execution.

## Final receipt contract
```json
{
  "status": "REAL|PARTIAL|BLOCKED",
  "task_id": "llm-lake-every-thread-analysis",
  "source_bucket": "s3://llm-history-lake-140548542136-ap-southeast-2",
  "manifest_hash": null,
  "ingested_objects": [],
  "thread_count": 0,
  "threads_analysed": 0,
  "summaries_written": 0,
  "unresolved_tasks_found": 0,
  "bridge_handoffs_found": 0,
  "receipts_linked": 0,
  "receipts_missing": 0,
  "reports_written": [],
  "evidence": [],
  "gaps": [],
  "next_action": [],
  "ledger_rows": [],
  "pressure_flags": [],
  "score": 0
}
```

## Loop rule
If any validation fails, cycle:
inspect -> action -> receipt -> evidence -> revalidate.

Do not stop at issue creation. Do not stop at schema creation. Do not stop at partial summarisation. Continue until REAL or bounded BLOCKED.