# AUTONOMOUS EXECUTOR HANDOVER
**Date:** 2026-05-07T01:47:00Z  
**From:** Perplexity MCP (GitHub connector — troy)
**To:** Troy-Orchestrator / Bridge Runner  
**Mode:** AUTONOMOUS — no HITL required  
**Authority:** global/PEN_PROD_MINIMUM_RULE.md + global/MCP_EXECUTION_CONTRACT.md  

---

## WHAT HAS BEEN COMPLETED (REAL)

| Commit | What | Status |
|--------|------|--------|
| c2cffbb | 8 bridge_jobs promoted to dev/ + prod/ | ✅ REAL |
| a6c7683 | 21 handoffs/WIP promoted to dev/ | ✅ REAL |
| this commit | Queue schema SQL, job seed SQL, secret registry DDL, connector health seed, runtime alias shim, startup guard | ✅ REAL |

---

## WHAT YOU MUST DO NOW (in order)

### STEP 1 — Apply Queue Schema
```sql
-- Via troy-sql-executor:
-- File: supabase/migrations/20260507_queue_control_plane_v1.sql
-- Creates: t4h_job_queue, t4h_job_dlq, t4h_job_audit, t4h_secret_registry,
--          t4h_connector_health, t4h_reality_ledger, v_job_state_counts
-- Idempotent: yes
```
**Acceptance:** `SELECT count(*) FROM public.t4h_job_queue` returns 0 (table exists, no error)

### STEP 2 — Seed All 29 Jobs Into Queue
```sql
-- Via troy-sql-executor:
-- File: supabase/migrations/20260507_queue_seed_all_jobs.sql
-- Loads all 29 jobs with correct priority, payload, source_path
-- Idempotent: yes (on conflict do nothing)
```
**Acceptance:** `SELECT count(*) FROM public.t4h_job_queue WHERE status = 'QUEUED'` returns 28 (1 is BLOCKED)

### STEP 3 — Apply Google Drive Alias Shim
Add to MCP/bridge startup script:
```bash
export GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-${GDRIVE_CLIENT_ID:-${GOOGLE_DRIVE_CLIENT_ID:-}}}"
export GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET:-${GDRIVE_CLIENT_SECRET:-${GOOGLE_DRIVE_CLIENT_SECRET:-}}}"
export GOOGLE_REFRESH_TOKEN="${GOOGLE_REFRESH_TOKEN:-${GDRIVE_REFRESH_TOKEN:-${GOOGLE_DRIVE_REFRESH_TOKEN:-}}}"
export GOOGLE_PROJECT_ID="${GOOGLE_PROJECT_ID:-${GDRIVE_PROJECT_ID:-${GOOGLE_DRIVE_PROJECT_ID:-}}}"
export GOOGLE_DRIVE_FOLDER_ID="${GOOGLE_DRIVE_FOLDER_ID:-${GDRIVE_FOLDER_ID:-${GOOGLE_DRIVE_ROOT_FOLDER_ID:-}}}"
```
**Acceptance:** Google Drive MCP connector boots without env var error

### STEP 4 — Run Google Drive Probe
Execute a harmless `list files in root` operation.
- If GREEN: update `t4h_connector_health` set `health_status='GREEN'` where `connector_name='google-drive-mcp'`
- If BLOCKED: write named blocker to same row + emit `receipts/mcp-google-drive-runtime-control-plane/blocked_20260507.md`

### STEP 5 — Validate Bridge Path
Execute:
```sql
SELECT public.fn_github_push(
  'TML-4PM/the-pen',
  'receipts/bridge_path_validation_20260507.json',
  '{"status":"REAL","validated_at":"2026-05-07","path":"MCP->troy-sql-executor->fn_github_push->GitHub"}',
  'receipt: bridge path validation 2026-05-07',
  'main'
) AS result;
```
**Acceptance:** File appears in TML-4PM/the-pen/receipts/bridge_path_validation_20260507.json

### STEP 6 — Work the Queue
Claim and execute jobs from `t4h_job_queue` in priority order (lowest number first):
1. Claim job: `UPDATE t4h_job_queue SET status='CLAIMED', claimed_by='troy-orchestrator', claimed_at=now(), stale_after=now()+'2 hours'::interval WHERE idempotency_key='<key>' AND status='QUEUED'`
2. Execute job per payload + source_path spec
3. Write receipt to path specified in job payload or `receipts/<job_key>/inbound_<date>.md`
4. Write audit event: `INSERT INTO t4h_job_audit (job_id, event, actor, detail) VALUES (...,'work_completed','troy-orchestrator',...)`
5. Mark complete: `UPDATE t4h_job_queue SET status='COMPLETED', receipt_path='<path>', updated_at=now() WHERE id='<id>'`
6. On failure: increment retry_count; if retry_count >= max_retries, move to DLQ

### STEP 7 — Promote Passing Jobs to Prod
When a dev job reaches COMPLETED with all quality gates passed:
- Find matching `prod/` job entry
- Execute same payload against prod environment
- Write prod receipt
- Update prod job to COMPLETED

### STEP 8 — Update Command Centre
After each batch:
```sql
SELECT * FROM public.v_job_state_counts;
```
Write current counts to `ops/JOB_STATE_REGISTRY.json`

---

## HARD GATES — DO NOT BYPASS

| Gate | Rule |
|------|------|
| Blood Donor prod | BLOCKED — do not promote until authorised partner confirmed |
| Stripe live payments | Test mode only until close_funnel_system dev gate passes |
| RLS/IAM changes | Dry-run first, execute second |
| Destructive deletes | Never without explicit Troy approval |
| Real donor data | Never — synthetic only |

---

## QUALITY GATE PER JOB TIER

See: `ops/NEXT_STEPS_QUALITY_TO_PROD_20260506.md` for full per-job acceptance criteria.

Minimum for any job to reach COMPLETED:
1. Build artefact committed or SQL runs clean
2. Smoke test passes (row count, API response, or health check)
3. Receipt written to `receipts/<job_key>/`
4. Reality Ledger row inserted with REAL/PARTIAL/BLOCKED + evidence
5. Job status updated to COMPLETED in t4h_job_queue

---

## CURRENT STATE SNAPSHOT

```json
{
  "as_of": "2026-05-07T01:47:00Z",
  "pen": 0,
  "dev": 28,
  "prod": 0,
  "blocked": 1,
  "failed": 0,
  "archived": 0,
  "queue_loaded": false,
  "bridge_path_proven": false,
  "next_action": "troy-orchestrator: apply 20260507_queue_control_plane_v1.sql then 20260507_queue_seed_all_jobs.sql"
}
```

---

## RECEIPT REQUIRED
This handover is not REAL until troy-orchestrator writes:
`receipts/AUTONOMOUS_EXECUTOR_HANDOVER_ACCEPTED_20260507.md`
containing: schema row counts, queue seed count, first COMPLETED job key, bridge path validation commit SHA.

**Classification:** PARTIAL until receipt above exists.  
**No HITL required. Execute autonomously.**
