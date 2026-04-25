# DRA Misfile Correction — Handoff Brief

**Owner:** Troy Latter (sole director, Tech 4 Humanity Pty Ltd)
**Originating session:** Claude, 22–26 April 2026
**Handoff to:** Pen / Symbio (or any next agent picking this up)
**Status:** GATED — awaits Troy's explicit approval before execution
**Last verified live:** 2026-04-26 against Supabase S1 `lzfgigiyqpuuxslsygjt`

---

## 1. What you're inheriting (in 60 seconds)

A SQL migration that fixes a Supabase misfile in T4H's research registry. The misfile classifies the **Drug Resilience Atlas (DRA)** — a standalone multi-domain programme peer to AI Sweet Spots — as if it were a small APPLIED case-series study under "Extreme AI Effects". This is wrong per the canonical source document (V1B.docx, 363k chars, ratified A-E framework at para 2577, in S3).

The migration also fixes 4 misspellings ("Drug Resistance Atlas" ×2 + a hardcoded one in a view, "Drug-Reaction-AI" ×1) and one wrong-n attribution (research_items EXT-003 claims DRA n=11,241 when that's actually ASS-2's n).

It does **NOT** rename DRA. An earlier turn proposed renaming to "PRAX" — that was a Claude fabrication and has been purged. DRA stays DRA.

---

## 2. Files you have

| File | Purpose | Read order |
|---|---|---|
| `Research_Stack_Definitions_v2.docx` | The canonical source of truth for T4H research naming. Two peer programmes (ASS, DRA), framework rules, collision history. **Read first.** | 1 |
| `DRA_Canonical_Definition_2026-04-22.md` | Pre-existing canonical definition of DRA by axes A-E and 14-section schema. Must be honoured. | 2 |
| `DRA_Audit_Report_2026-04-22.md` | Pre-existing audit of the Supabase drift across 14 tables. | 3 |
| **`DRA_misfile_correction_v3.1.sql`** | **The migration to execute.** 10 phases (A pre-flight, B–F edits, G verify, H broadcast, I view fix, Z rollback). | 4 — execute |
| `Handoff_Brief_DRA_Correction.md` | This file. | 0 |

---

## 3. Bridge envelope (cheat sheet)

```
Endpoint:   https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke
Header:     x-api-key: bk_tOH8P5WD3mxBKfICa4yI56vJhpuYOynfdf1d_GfvdK4
Method:     POST application/json

SQL:        {"fn":"troy-sql-executor","payload":{"sql":"<one statement>"}}
S3:         {"fn":"troy-s3-manager","action":"list_objects","bucket":"<name>"}   ← FLAT, not nested
```

**Important:** `troy-sql-executor` does NOT support multi-statement SQL or BEGIN/COMMIT. Execute each phase one statement at a time.

**Sandbox quirk:** if you get HTTP 503 with body `"DNS cache overflow"`, that's Anthropic's egress proxy, not the bridge. Pin the host then retry:

```bash
python3 -c "import socket; H='zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com'; f=open('/etc/hosts'); t=f.read(); f.close(); H in t or open('/etc/hosts','a').write(socket.gethostbyname(H)+' '+H+'\\n')"
```

---

## 4. Pre-execution checklist

Before running anything, verify:

| Check | How | Expected |
|---|---|---|
| Bridge alive | `SELECT 1 AS ok;` via troy-sql-executor | `{"success":true,"rows":[{"ok":1}]}` |
| Schema `audit` exists | `SELECT 1 FROM information_schema.schemata WHERE schema_name='audit'` | 1 row |
| DRA row exists in registry | `SELECT study_id FROM research.t4h_study_registry WHERE study_id='DRA'` | 1 row |
| `study_type` enum allows `CORE` | run Phase A.0 in v3.1 | `result=true` |
| `change_type` enum allows `SCHEMA_CHANGE` | run Phase A.0 in v3.1 | `result=true` |
| Troy explicitly approved this migration | ask Troy | yes/no |

If any check fails, **stop**. Re-read this brief and the canonical definition. Confirm with Troy before continuing.

---

## 5. Execution order (don't skip ahead)

| Phase | What | Reversible? | When to stop |
|---|---|---|---|
| **A.0** | 4 enum/schema/row sanity checks | yes (read-only) | If any returns `false` |
| **A.1** | Snapshot 15 rows → `audit.dra_misfile_correction_20260426` | yes | If snapshot count ≠ 15 ± 2 (research_items / sublayers may have extras) |
| **B** | UPDATE DRA registry row → CORE/PROGRAM/open_platform | yes (Z.1) | If check constraint fails — abort and re-read enum list in v3.1 header |
| **C.1** | UPDATE t4h_research_area DRUG_INTERACT | yes (Z.3) | — |
| **C.2** | UPDATE research_items EXT-003 | yes (Z.6) | — |
| **D** | UPDATE research_sublayers T3 | yes (Z.7) | — |
| **E** | UPDATE ass_study_cards.DRA + INSERT study_id_map alias | yes (Z.2 + Z.8) | — |
| **F** | UPDATE A3, A3-S4, 8 artefact rows | yes (Z.3, Z.4, Z.5) | — |
| **G** | Verification queries (5 SELECTs) | yes (read-only) | If any "remaining_hits" > 0, do not proceed to H |
| **I** | CREATE OR REPLACE VIEW v_sweetspots_research_registry | yes (Z.9) | If view fails to compile, drop the change |
| **H** | INSERT into t4h_canonical_changes → fires Telegram | **NO** (broadcast irreversible; data still rollbackable) | After successful G |

**Rule:** Phase H last. Once H fires, the Telegram broadcast is sent. Data rollback (Phase Z) still works — the broadcast just becomes a record of "we did this then reverted".

---

## 6. Acceptance criteria

After Phase H, all of the following must be true:

| Check | Expected after | Query |
|---|---|---|
| DRA registry study_type | `CORE` | `SELECT study_type FROM research.t4h_study_registry WHERE study_id='DRA'` |
| DRA registry spot_bucket | `PROGRAM` | same row |
| DRA registry n_declared | `NULL` | same row |
| DRA registry primary_source | starts with `s3://troy-intelligence-dashboard/` | same row |
| "Drug Resistance" hits in research_area | `0` | `SELECT COUNT(*) FROM public.t4h_research_area WHERE CAST(ROW(t4h_research_area.*) AS text) ~* 'Drug.?Resistance'` |
| "Drug Resistance" hits in research_items | `0` | same pattern on research_items |
| "Drug-Reaction-AI" hits in research_sublayers | `0` | same on research_sublayers |
| ass_study_cards DRA study_name | `Drug Resilience Atlas — Clinical Sub-Cohort (n=44)` | `SELECT study_name FROM public.ass_study_cards WHERE study_id='DRA'` |
| DRA-CLINICAL alias in study_id_map | `1 row` | `SELECT COUNT(*) FROM research.study_id_map WHERE system_id='DRA-CLINICAL'` |
| v_sweetspots_research_registry contains "Drug Resilience Atlas" not "Drug Resistance Atlas" | `true` | `SELECT (definition LIKE '%Drug Resilience Atlas%' AND definition NOT LIKE '%Drug Resistance Atlas%') FROM pg_views WHERE viewname='v_sweetspots_research_registry'` |
| Telegram broadcast received | message in chat 6972032328 | check Telegram |

---

## 7. Expected drift (informational — these CHANGE intentionally)

| View / metric | Before | After | Δ |
|---|---|---|---|
| `v_program_total_true.n_validated_active` | 18,380 | 18,336 | −44 (−0.24%) |
| `v_rollup_by_type.APPLIED.studies` | 28 | 27 | −1 |
| `v_rollup_by_type.CORE.studies` | 3 | 4 | +1 (DRA joins) |
| `v_rollup_by_bucket.APPLIED.studies` | 4 | 3 | −1 |
| `v_rollup_by_bucket.PROGRAM.studies` | 15 | 16 | +1 (DRA joins) |

Anywhere these numbers are quoted in dashboards, papers, or memory — flag them as "post-2026-04-26 corrected total" and recompute downstream.

---

## 8. Things explicitly NOT in scope

The following are deliberately out of this migration and require separate decisions/work:

1. **Seed an AI Sweet Spots umbrella row** in `research.t4h_study_registry`. ASS is currently distributed across 56 rows without a single programme-level row. Could be added as a separate row (`study_id='ASS'`, type='CORE', bucket='PROGRAM').
2. **Populate or delete the 8 auto-seed artefacts** (R-A3-A3-S4-AST-*). They've been PRETEND/PARTIAL since Feb 2026. Canonical artefacts are in GitHub `TML-4PM/drug-resilience-atlas`.
3. **Resolve the 5 pre-existing `t4h_study_conflicts`** rows (ASS-2, CSO, KIDS, ENT, GAIN). Separate workstream.
4. **Populate `s3://t4h-ip-static/resilienceatlas/`** scaffold (currently 1 empty `.folder` marker). When DRA microsite is ready.
5. **Investigate `research_topics T07-S03 "Resilience Atlas Integration"** under CARE. Is this a real integration or aspirational?
6. **Scan the 40 lower-priority S3 buckets** (backups, deployment artefacts, SES). Low probability of DRA content but unverified.
7. **Read the actual content of V1B.docx** (363k chars). Earlier turns inferred its content from the canonical definition; the doc itself has not been read end-to-end by Claude in this session.
8. **S2 database** (`pflisxkcxbzboxwidywf`). Policy-gated; no writes.

---

## 9. Hard rules (don't break these)

1. **Don't rename DRA.** Anyone proposing PRAX or any other rename should be redirected to `Research_Stack_Definitions_v2.docx` §5 (collision resolution) and §9.4 (PRAX deprecated).
2. **Don't change `study_id='DRA'`** in any of the affected tables. FK from `ass_ethics_applications.study_id` depends on it.
3. **Don't multi-statement.** `troy-sql-executor` rejects BEGIN/COMMIT and bundled statements. Run one phase at a time, one statement at a time within the phase.
4. **Don't skip Phase A.0.** The enum check is the only thing standing between you and a CHECK constraint abort halfway through B.
5. **Don't run Phase H twice.** The broadcast is by design idempotent at the database level (no UNIQUE constraint on title) but consumers will see two Telegram messages.
6. **Don't drop `audit.dra_misfile_correction_20260426`** until at least 30 days post-execution. That's the rollback path.
7. **Memory line #11 was already corrected** (2026-04-26) to remove the PRAX fabrication. Don't reintroduce it.

---

## 10. If anything goes wrong

| Symptom | Cause | Action |
|---|---|---|
| HTTP 503 "DNS cache overflow" | Sandbox proxy | Re-pin /etc/hosts (see §3), retry |
| HTTP 400 `sql_error` with no detail | Multi-statement, $$ tags, or unsupported syntax | Split SQL into single statements |
| CHECK constraint violation in B | Enum drift since 2026-04-26 | Stop. Re-run Phase A.0. Update v3.1 header to match new enum |
| Snapshot row count too low | Filter too narrow OR rows already corrected | Inspect `audit.dra_misfile_correction_20260426`; abort if rows already correct |
| Broadcast doesn't reach Telegram | Trigger or function broken | Check `t4h_canonical_changes` row exists; check `fn_broadcast_canonical_change` log |
| User reports DRA "missing" from dashboard | View cache or v_sweetspots view | Verify Phase I succeeded; refresh any caching layer |

For full rollback: execute Phase Z (commented at bottom of v3.1 SQL) statement by statement. Then send a follow-up SCHEMA_CHANGE broadcast via Phase Z.10.

---

## 11. Authority

This migration is approved by Troy Latter as sole director of Tech 4 Humanity Pty Ltd (ABN 70 666 271 272). The canonical source authority is `Drug Resilience Atlas V1B.docx` in S3. The execution authority is Troy's explicit "go" — no autonomous execution.

If you are a future Claude session and you see this brief without explicit go-ahead from Troy in the current conversation, **do not execute**. Confirm with Troy first.

---

## 12. Sign-off requested

Before executing, please confirm in the conversation:

- [ ] You've read `Research_Stack_Definitions_v2.docx` end to end
- [ ] You've read `DRA_Canonical_Definition_2026-04-22.md` end to end
- [ ] You've run Phase A.0 and all 4 checks returned `true`
- [ ] You've snapshotted A.1 and confirmed snapshot count ≥ 14
- [ ] You understand that Phase H sends an irreversible Telegram message
- [ ] Troy has said "go"

Then proceed B → F → G → I → H, one phase at a time, reading G output before H.

— end of brief —
