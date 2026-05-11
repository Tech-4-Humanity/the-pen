# Canonical Session Traps

Status: ACTIVE
Owner: The Pen
Companion: `MACHINE_REALITY_INDEX.yaml doctrine.traps_d`
Update policy: every onboarded session that discovers a new trap MUST append it here as part of writeback.

This file documents operational traps that have caused real failures. Each trap has a stable ID, a one-line summary, a reproduction signal, and the safe-path workaround. Machines load this file at preflight step 3.

## Index

| ID | Severity | One-line |
|----|----------|----------|
| TRAPS-D-1 | HIGH | `reality_ledger.cluster_id` is FK to `core.cluster_registry`; invalid value → sqlstate 23503 |
| TRAPS-D-2 | HIGH | SKS deployment is on S1, not S2, despite HRE PDF recommending S2 |
| TRAPS-D-3 | MEDIUM | `supabase_rest_proxy POST` can return empty result without raising; verify writes via SQL read |
| TRAPS-D-4 | HIGH | `troy-sql-executor` masks RETURNING clauses + pg errors; always read back after write |
| TRAPS-D-5 | LOW | Leading SQL comment breaks read tool output; split statements |
| TRAPS-D-6 | HIGH | `github_bulk_dispatch` requires inline `content` strings; `content_ref` is rejected. Batch large dispatches to avoid context overflow. |
| TRAPS-D-7 | CRITICAL | Drafted files in `/home/claude/` are NOT deployed. A v3.1 cycle declared 14 files "complete" while only 3 actually committed. Always verify HEAD before claiming deployment. |

## Details

### TRAPS-D-1 — `reality_ledger.cluster_id` FK constraint

**Discovery:** v3 doctrine deployment, first INSERT.
**Repro:** sqlstate 23503 on invalid cluster_id.
**Safe path:** resolve from `canonical/doctrine/CLUSTERS.yaml` or use NULL.

### TRAPS-D-2 — SKS S1 vs S2 location

**Discovery:** v3 validation pass.
**Safe path:** `to_regclass('ops.standard_knowledge_register')` on S1.

### TRAPS-D-3 — `supabase_rest_proxy POST` silent empty result

**Discovery:** v3 ledger write attempt #1.
**Safe path:** prefer `supabase_sql_write_gated`; always read back after REST POST.

### TRAPS-D-4 — `troy-sql-executor` masks RETURNING and pg errors

**Discovery:** TRAPS-B v2 (3), reconfirmed during v3 validation.
**Safe path:** never rely on RETURNING; follow up with SELECT.

### TRAPS-D-5 — SQL leading comment breaks read tool output

**Discovery:** v3 validation multi-statement read.
**Repro:** `supabase_sql_read(sql='-- comment\nSELECT ...')` returns `{command: '--', rows_affected: N}` instead of rows.
**Safe path:** strip leading comments; one statement per call.

### TRAPS-D-6 — `github_bulk_dispatch` rejects `content_ref`

**Discovery:** v3.1 redeploy attempt.
**Repro:** Passing `content_ref` instead of `content` returns `code: invalid_type, expected: string, received: undefined`.
**Safe path:** always inline the full `content` string. For large batches, split into 3–5 file dispatches to keep each call manageable.

### TRAPS-D-7 — Drafted ≠ deployed

**Discovery:** v3.1 second-pass validation found 11 "completed" files at 404 on HEAD.
**Repro:** Previous session declared "ENHANCE phase COMPLETED — 14 files drafted in /home/claude/" but only 3 had actually been dispatched.
**Root cause:** Drafts in container filesystem do not commit themselves. Tool context can run out before the dispatch fires.
**Safe path:**
1. Treat every drafted file as PARTIAL until github_bulk_dispatch returns a commit SHA.
2. After every dispatch, immediately `github_file_read` at least one file to confirm HEAD.
3. NEVER write a ledger row claiming REAL until all referenced commit SHAs have been verified live.
4. This is the exact failure mode SESSION_REQUIREMENTS.md §14 calls out: "No claiming 'done' when only packaging occurred." The packaging happened in the draft; the doing happened in the dispatch.
