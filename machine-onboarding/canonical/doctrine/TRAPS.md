# Canonical Session Traps

Status: ACTIVE
Owner: The Pen
Companion: `MACHINE_REALITY_INDEX.yaml doctrine.traps_d`
Update policy: every onboarded session that discovers a new trap MUST append it here as part of writeback.

## Index

| ID | Severity | One-line |
|----|----------|----------|
| TRAPS-D-1 | HIGH | reality_ledger.cluster_id is FK to core.cluster_registry; invalid value -> sqlstate 23503 |
| TRAPS-D-2 | HIGH | SKS deployment is on S1, not S2, despite HRE PDF recommending S2 |
| TRAPS-D-3 | MEDIUM | supabase_rest_proxy POST can return empty result without raising; verify via SQL read |
| TRAPS-D-4 | HIGH | troy-sql-executor masks RETURNING + pg errors; always read back |
| TRAPS-D-5 | LOW | Leading SQL comment breaks read tool output; split statements |
| TRAPS-D-6 | HIGH | github_bulk_dispatch requires inline content; 5+ file batches may error; cap at 1-2 files per dispatch |
| TRAPS-D-7 | CRITICAL | Drafted files in /home/claude/ are NOT deployed; verify HEAD via github_file_read before claiming REAL |

## Details

### TRAPS-D-1 - reality_ledger.cluster_id FK constraint
Discovery: v3 doctrine deployment, first INSERT.
Repro: sqlstate 23503 on invalid cluster_id.
Safe path: resolve from canonical/doctrine/CLUSTERS.yaml or use NULL.

### TRAPS-D-2 - SKS S1 vs S2
Discovery: v3 validation pass.
Safe path: to_regclass('ops.standard_knowledge_register') on S1.

### TRAPS-D-3 - REST POST silent empty result
Discovery: v3 ledger write attempt #1.
Safe path: prefer supabase_sql_write_gated; always read back after REST POST.

### TRAPS-D-4 - troy-sql-executor masks RETURNING
Discovery: TRAPS-B v2 (3), reconfirmed during v3 validation.
Safe path: never rely on RETURNING; follow up with SELECT.

### TRAPS-D-5 - SQL leading comment breaks read tool
Discovery: v3 validation multi-statement read.
Repro: supabase_sql_read with leading -- returns command:'--' rows_affected:N instead of rows.
Safe path: strip leading comments; one statement per call.

### TRAPS-D-6 - github_bulk_dispatch batching limits
Discovery: v3.1 redeploy attempts.
Repro: (a) content_ref rejected with code:invalid_type. (b) batches of 5-14 files inline error with generic tool execution error.
Safe path:
1. Always inline full content string per job.
2. Cap batches at 1-2 files per dispatch.
3. After each dispatch, verify one commit SHA via github_file_read.

### TRAPS-D-7 - Drafted != deployed
Discovery: v3.1 second-pass validation found 11 'completed' files at 404 on HEAD.
Repro: Previous session declared 14 files drafted in /home/claude/ but only 3 had been dispatched.
Root cause: Drafts in container filesystem do not commit themselves. Tool context can run out before dispatch.
Safe path:
1. Treat every drafted file as PARTIAL until github_bulk_dispatch returns a commit SHA.
2. After every dispatch, immediately github_file_read at least one file to confirm HEAD.
3. NEVER write a ledger row claiming REAL until all referenced commit SHAs verified live.
4. SESSION_REQUIREMENTS.md sec 14: 'No claiming done when only packaging occurred.'
