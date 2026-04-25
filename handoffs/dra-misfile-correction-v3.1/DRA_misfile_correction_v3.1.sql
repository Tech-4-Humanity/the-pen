-- ============================================================================
-- T4H · DRA Supabase Misfile Correction v3.1 (HANDOFF-READY)
-- ============================================================================
-- Generated:        2026-04-26
-- Author:           Claude (for Troy Latter, Tech 4 Humanity Pty Ltd)
-- Supersedes:       v3 (had 3 enum-constraint violations that would abort B1)
-- Canonical source: /mnt/user-data/outputs/DRA_Canonical_Definition_2026-04-22.md
-- Authority:        /mnt/user-data/outputs/Research_Stack_Definitions_v2.docx
--
-- STATUS:           DRY-RUN / GATED — DO NOT EXECUTE WITHOUT TROY'S APPROVAL
-- ============================================================================
--
-- DELTAS FROM v3 → v3.1
-- ──────────────────────
--   • study_type        'PROGRAMME'      → 'CORE'           (real enum value)
--   • spot_bucket       'PROGRAMME'      → 'PROGRAM'        (real enum value)
--   • n_type            'programme'      → 'open_platform'  (real enum value)
--   • Added v_sweetspots_research_registry view fix (Phase I)
--   • Added pre-flight enum verification (Phase A.0)
--
-- VERIFIED ENUM VALUES (from pg_constraint, 2026-04-26):
--   study_type   ∈ {CORE, META, SUBSET, APPLIED, EDGE, THEORY, PROTOCOL,
--                   PLATFORM, COMMENTARY, RD}
--   spot_bucket  ∈ {SWEET, DARK, BIO, HUMAN, APPLIED, EDGE, PROGRAM}
--   n_type       ∈ {validated, active, planned, theoretical, na,
--                   open_platform, clinical, survey, subset, panel}
--   evidence_status ∈ {DISCOVERED, VERIFIED, CONFLICT, PRETEND, PARTIAL, REAL}
--   study_status ∈ {validated, active, planned, archived, decommissioned, pilot}
--   change_type  ∈ {MILESTONE, SCHEMA_CHANGE, BUSINESS_CHANGE, IP_CHANGE,
--                   PRODUCT_CHANGE, FINANCIAL_CHANGE, SYSTEM_CHANGE,
--                   BLOCKER, DECISION}
--   severity     ∈ {LOW, NORMAL, HIGH, CRITICAL}
--
-- WHAT THIS MIGRATION DOES
-- ────────────────────────
--   • Reclassifies DRA as a CORE study (peer to ASS-1/ASS-2) with PROGRAM
--     spot_bucket, matching the canonical definition that DRA is a peer
--     programme to AI Sweet Spots, not a sub-study under it.
--   • Fixes 4 misspellings: "Drug Resistance Atlas" (×2), "Drug-Reaction-AI"
--     (×1), and the hardcoded "Drug Resistance Atlas" inside
--     v_sweetspots_research_registry view definition.
--   • Corrects research_items EXT-003 mis-attribution of n=11,241 (that's
--     ASS-2's n, not DRA's).
--   • Clarifies ass_study_cards.DRA row as the clinical sub-cohort, not the
--     whole programme. Adds a study_id_map alias.
--   • Re-frames A3 / A3-S4 / 8 auto-seed artefacts as cross-references to
--     the DRA programme (not as containment).
--   • Adds primary/secondary source pointers to V1B.docx, GitHub repo,
--     Notion root.
--   • Adds the 6 DRA-* monetisation-layer products to the registry row.
--   • Snapshots all 15+ touched rows to audit.dra_misfile_correction_20260426
--     for rollback.
--   • Broadcasts the change via t4h_canonical_changes →
--     fn_broadcast_canonical_change → Telegram + scratchpad.
--
-- WHAT THIS MIGRATION DOES NOT DO
-- ───────────────────────────────
--   • Does NOT rename DRA. DRA stays DRA. ETH-DRA stays ETH-DRA. RDTI-DRA
--     stays RDTI-DRA.
--   • Does NOT introduce "PRAX". That was a fabrication from an earlier
--     Claude session and has been purged from all outputs and memory.
--   • Does NOT touch the ass_study_cards row's study_id (FK target —
--     ass_ethics_applications.study_id depends on it).
--   • Does NOT delete the 8 auto-seed artefacts. They're re-framed only.
--   • Does NOT seed an AI Sweet Spots umbrella row in the registry. (Open
--     decision — see ACTION REGISTER #2 in handoff brief.)
--   • Does NOT touch S2 (policy-gated).
--
-- DOWNSTREAM EFFECTS (verified, not guessed)
-- ──────────────────────────────────────────
--   v_program_total_true.n_validated_active  18,380 → 18,336 (–44, –0.24%)
--   v_rollup_by_type.APPLIED studies         28 → 27
--   v_rollup_by_type.CORE studies            3 → 4 (DRA joins ASS-1/ASS-2/RCT-2026)
--   v_rollup_by_bucket.APPLIED studies       4 → 3
--   v_rollup_by_bucket.PROGRAM studies       15 → 16
--   v_ethics_dashboard study_name            longer string for DRA row
--   v_sweetspots_research_registry           "Drug Resistance Atlas" → "DRA"
--                                            (was already wrong; this fixes it)
--
-- IRREVERSIBLE
-- ────────────
--   1× INSERT into t4h_canonical_changes triggers a Telegram broadcast.
--   Rollback is supported (see Phase Z) but the broadcast itself fires.
--
-- ============================================================================

-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ EXECUTION CONTRACT — read this before running anything                  │
-- ├──────────────────────────────────────────────────────────────────────────┤
-- │ AGENT          : Pen / Symbio (or any successor reading this from       │
-- │                  TML-4PM/the-pen)                                       │
-- │ INVOCATION     : ONE statement at a time via                            │
-- │                  POST https://zdgnab3py0.execute-api.ap-southeast-2     │
-- │                  body {"fn":"troy-sql-executor","payload":{"sql":"..."}}│
-- │ DO NOT BUNDLE  : troy-sql-executor rejects multi-statement SQL,         │
-- │                  BEGIN/COMMIT, and $$-quoted PL/pgSQL                   │
-- │ DNS RECOVERY   : on HTTP 503 "DNS cache overflow" → re-pin /etc/hosts   │
-- │                  for the bridge host then retry once                    │
-- │ AUTHORITY      : Troy Latter (sole director). Without an explicit       │
-- │                  human "go" in the originating chat, this file is       │
-- │                  REFERENCE ONLY. Do not auto-execute.                   │
-- │ SAFETY POSTURE : every UPDATE has a row in audit.dra_misfile_correction │
-- │                  _20260426 from Phase A.1; Phase Z restores from there. │
-- │ EVIDENCE GRADE : Phase H broadcast = REAL when run; until then PRETEND. │
-- │                  Receipt for this push lives at                         │
-- │                  receipts/dra-misfile-correction-v3.1.json in this repo │
-- └──────────────────────────────────────────────────────────────────────────┘
--
-- INDEX OF PHASES
-- ─────────────────
--   A.0  Pre-flight enum & schema sanity                             (read)
--   A.1  Snapshot affected rows to audit.dra_misfile_correction_…    (write)
--   B    Reclassify DRA: APPLIED→CORE, APPLIED→PROGRAM, n=44→NULL    (write)
--   C.1  Fix "Drug Resistance" misspelling in research_area          (write)
--   C.2  Fix research_items EXT-003 misspelling + wrong-n            (write)
--   D    Fix "Drug-Reaction-AI" in research_sublayers T3             (write)
--   E    Clarify ass_study_cards row as clinical sub-cohort          (write)
--   F    Re-frame A3 / A3-S4 / 8 artefacts as cross-references       (write)
--   G    Verification queries — must all pass before H               (read)
--   I    CREATE OR REPLACE VIEW v_sweetspots_research_registry        (write)
--   H    INSERT t4h_canonical_changes → fires Telegram broadcast      (write,
--                                                                     IRREV)
--   Z    Rollback (commented; uncomment + run if reverting)          (write)
--
-- BLAST RADIUS
-- ────────────
--   Tables touched : 7      (registry, ass_study_cards, area, subarea,
--                            asset, research_items, research_sublayers)
--   Views touched  : 1      (v_sweetspots_research_registry)
--   Rows updated   : ~15    (1 + 1 + 2 + 1 + 8 + 1 + 1)
--   Rows inserted  : ~16    (snapshots) + 1 (study_id_map alias) +
--                            1 (canonical broadcast)
--   Triggers fired : 5      (updated_at autosetters — benign)
--   Telegram       : 1 message to chat 6972032328 (IRREVERSIBLE)
--

-- ───────────────────────────────────────────────────────────────
-- PHASE A · Pre-flight checks
-- ───────────────────────────────────────────────────────────────

-- A.0  Verify the schemas, table, and enums we depend on still match v3.1
--      assumptions. If any of these fail, ABORT — the migration's premise
--      no longer holds.
SELECT 'audit schema exists' AS check_name,
       (EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name='audit'))::text AS result;

SELECT 'study_type allows CORE' AS check_name,
       (EXISTS(
         SELECT 1 FROM pg_constraint c
         JOIN pg_class t ON c.conrelid=t.oid
         JOIN pg_namespace n ON t.relnamespace=n.oid
         WHERE n.nspname='research' AND t.relname='t4h_study_registry'
           AND pg_get_constraintdef(c.oid) LIKE '%CORE%'
       ))::text AS result;

SELECT 'change_type allows SCHEMA_CHANGE' AS check_name,
       (EXISTS(
         SELECT 1 FROM pg_constraint c
         JOIN pg_class t ON c.conrelid=t.oid
         JOIN pg_namespace n ON t.relnamespace=n.oid
         WHERE n.nspname='public' AND t.relname='t4h_canonical_changes'
           AND pg_get_constraintdef(c.oid) LIKE '%SCHEMA_CHANGE%'
       ))::text AS result;

SELECT 'DRA row exists in registry' AS check_name,
       (EXISTS(SELECT 1 FROM research.t4h_study_registry WHERE study_id='DRA'))::text AS result;

-- A.1  Snapshot every row we'll touch
CREATE TABLE IF NOT EXISTS audit.dra_misfile_correction_20260426 (
  snapshot_id    bigserial PRIMARY KEY,
  source_table   text NOT NULL,
  row_pk         text,
  original_row   jsonb NOT NULL,
  snapshotted_at timestamptz DEFAULT now()
);

INSERT INTO audit.dra_misfile_correction_20260426 (source_table, row_pk, original_row)
SELECT 'research.t4h_study_registry', study_id, to_jsonb(t4h_study_registry.*)
  FROM research.t4h_study_registry WHERE study_id = 'DRA'
UNION ALL
SELECT 'public.ass_study_cards', study_id, to_jsonb(ass_study_cards.*)
  FROM public.ass_study_cards WHERE study_id = 'DRA'
UNION ALL
SELECT 'public.t4h_research_area', area_code, to_jsonb(t4h_research_area.*)
  FROM public.t4h_research_area WHERE area_code IN ('A3','DRUG_INTERACT')
UNION ALL
SELECT 'public.t4h_research_subarea', subarea_code, to_jsonb(t4h_research_subarea.*)
  FROM public.t4h_research_subarea WHERE subarea_code = 'A3-S4'
UNION ALL
SELECT 'public.t4h_research_asset', asset_code, to_jsonb(t4h_research_asset.*)
  FROM public.t4h_research_asset WHERE asset_code LIKE 'R-A3-A3-S4-%'
UNION ALL
SELECT 'public.research_items', id::text, to_jsonb(research_items.*)
  FROM public.research_items
 WHERE id = 'EXT-003'
    OR CAST(ROW(research_items.*) AS text) ~* 'drug.?resistance'
UNION ALL
SELECT 'public.research_sublayers', id::text, to_jsonb(research_sublayers.*)
  FROM public.research_sublayers
 WHERE id = 'T3'
    OR CAST(ROW(research_sublayers.*) AS text) ~* 'Drug-Reaction-AI'
UNION ALL
SELECT 'pg_views.v_sweetspots_research_registry', viewname, to_jsonb(pg_views.*)
  FROM pg_views
 WHERE viewname = 'v_sweetspots_research_registry';

-- Verify snapshot coverage
SELECT source_table, COUNT(*) AS rows_snapshotted
  FROM audit.dra_misfile_correction_20260426
 WHERE snapshotted_at >= now() - INTERVAL '5 minutes'
 GROUP BY source_table
 ORDER BY source_table;
-- Expected:
--   ass_study_cards               1
--   pg_views.v_sweetspots…        1
--   research_items                1+   (EXT-003 + any other resistance hits)
--   research_sublayers            1+   (T3 + any other Drug-Reaction-AI)
--   t4h_research_area             2
--   t4h_research_asset            8
--   t4h_research_subarea          1
--   t4h_study_registry            1


-- ───────────────────────────────────────────────────────────────
-- PHASE B · Promote DRA in the registry
-- ───────────────────────────────────────────────────────────────
-- Reclassify DRA as CORE / PROGRAM / open_platform — peer to ASS-1, ASS-2.
-- Add canonical source pointers + 6 monetisation-layer products.
-- DO NOT change study_id ('DRA' stays). DO NOT change ethics_ref ('ETH-DRA'
-- stays). FK from ass_ethics_applications stays intact.

-- B.1 — Reclassify the DRA registry row.
-- Before: APPLIED / APPLIED bucket / active n_type / is_additive=true / n_declared=44
-- After : CORE / PROGRAM bucket / open_platform / is_additive=false / n=NULL
-- Why   : DRA is a peer programme to AI Sweet Spots, not a sub-study under it.
--         Canonical source ratifies CORE/PROGRAM at V1B.docx para 2577.
-- Ripple: v_program_total_true.n_validated_active drops by 44 (–0.24%).
--         v_rollup_by_type.CORE +1, APPLIED –1 (cosmetic).
-- Reverse: Phase Z.1 restores from audit snapshot.
UPDATE research.t4h_study_registry SET
    study_type        = 'CORE',
    spot_bucket       = 'PROGRAM',
    n_type            = 'open_platform',
    n_declared        = NULL,
    is_additive       = FALSE,
    headline          = 'Standalone multi-domain atlas — substance × biology × culture × law × education',
    design_type       = 'multi-domain atlas',
    primary_source    = 's3://troy-intelligence-dashboard/GDRIVE_WORK_BACKUP/Drug Resilience Atlas V1B.docx',
    n_source_text     = 'programme — no fixed n; clinical sub-cohort n=44 held in ass_study_cards',
    evidence_notes    = '[2026-04-26] Reclassified from APPLIED case-series to CORE/PROGRAM per canonical source V1B.docx (363k chars, A-E framework ratified at para 2577, 14-section schema at para 1449, 6 monetisation layers at para 2547). Peer programme to AI Sweet Spots, not subordinate. The earlier n=44 refers to a clinical sub-cohort held in ass_study_cards, not the programme total.',
    updated_at        = now(),
    updated_by        = 'claude@2026-04-26 (per canonical def)'
 WHERE study_id = 'DRA';


-- ───────────────────────────────────────────────────────────────
-- PHASE C · Fix "Drug Resistance" misspellings
-- ───────────────────────────────────────────────────────────────

-- C.1 — Fix "Drug Resistance Atlas" → "Drug Resilience Atlas" in DRUG_INTERACT.
-- This was a misspelling that flowed into v_sweetspots_research_registry too
-- (fixed separately in Phase I).
-- Reverse: Phase Z.3.
UPDATE public.t4h_research_area SET
    area_title = 'Drug / Substance Interactions',
    notes      = 'Stimulants, depressants, cannabis, psychedelics, caffeine, sleep deprivation. Framework: DR×AI governance (Green/Amber/Red). Data source: DRA programme (peer to AI Sweet Spots, not subordinate). Substance taxonomy: atlas_drug_categories.',
    updated_at = now()
 WHERE area_code = 'DRUG_INTERACT';

-- C.2 — research_items EXT-003 was doubly wrong: misspelled "Drug Resistance"
-- AND attributed n=11,241 (which is ASS-2's n) to DRA. Correcting both.
-- Reverse: Phase Z.6.
UPDATE public.research_items SET
    title  = REPLACE(REPLACE(title, 'Drug Resistance Atlas', 'AI Sweet Spots Multi-Site (ASS-2)'),
                     'Drug Resilience Atlas', 'AI Sweet Spots Multi-Site (ASS-2)'),
    notes  = COALESCE(notes,'') || E'\n[2026-04-26] Corrected: n=11,241 is ASS-2''s n, not DRA''s. DRA is a programme without fixed n.',
    updated_at = now()
 WHERE id = 'EXT-003'
    OR (CAST(ROW(research_items.*) AS text) ~* '11241'
        AND CAST(ROW(research_items.*) AS text) ~* 'drug.?resistance');


-- ───────────────────────────────────────────────────────────────
-- PHASE D · Fix "Drug-Reaction-AI" in research_sublayers T3
-- ───────────────────────────────────────────────────────────────
-- This was a fourth-variant misspelling. Should be "Drug Resilience Atlas".
-- Reverse: Phase Z.7.

UPDATE public.research_sublayers SET
    notes      = REPLACE(COALESCE(notes,''), 'Drug-Reaction-AI (DRA)', 'Drug Resilience Atlas (DRA)'),
    updated_at = now()
 WHERE id = 'T3'
   AND CAST(ROW(research_sublayers.*) AS text) LIKE '%Drug-Reaction-AI%';


-- ───────────────────────────────────────────────────────────────
-- PHASE E · Clarify ass_study_cards row as clinical sub-cohort
-- ───────────────────────────────────────────────────────────────
-- The n=44 record in ass_study_cards is a clinical SUB-cohort of the DRA
-- programme, not the DRA programme itself. We don't change study_id (FK
-- target — ass_ethics_applications.study_id depends on it). We rename the
-- study_name to disambiguate, and add a study_id_map alias DRA-CLINICAL→DRA.
-- Reverse: Phase Z.2 + Z.8.

UPDATE public.ass_study_cards SET
    study_name = 'Drug Resilience Atlas — Clinical Sub-Cohort (n=44)',
    updated_at = now()
 WHERE study_id = 'DRA';

INSERT INTO research.study_id_map
    (system_id, canonical_id, system_name, confidence, notes, created_at, updated_at)
VALUES
    ('DRA-CLINICAL', 'DRA', 'clinical_sub_cohort', 'canonical',
     '[2026-04-26] The n=44 clinical sub-cohort under ass_study_cards is a DATA SUBSET within the DRA programme, not the programme itself. DRA programme scope = full multi-domain atlas per V1B.docx.',
     now(), now())
ON CONFLICT DO NOTHING;


-- ───────────────────────────────────────────────────────────────
-- PHASE F · Re-frame A3 + A3-S4 + 8 auto-seed artefacts as cross-refs
-- ───────────────────────────────────────────────────────────────
-- A3 ("Extreme AI Effects") contains DRA via a cross-reference, NOT as a
-- containment relationship. DRA is a peer programme. Update notes/titles to
-- reflect this. The 8 auto-seed artefacts (R-A3-A3-S4-AST-*) become
-- cross-reference placeholders — canonical artefacts live in GitHub repo
-- TML-4PM/drug-resilience-atlas, not here.
-- Reverse: Phase Z.3, Z.4, Z.5.

UPDATE public.t4h_research_area SET
    notes      = 'Container: ASS-2 + psychedelics research under AI Sweet Spots. Cross-references DRA programme (peer, not subordinate) for substance-response data.',
    updated_at = now()
 WHERE area_code = 'A3';

UPDATE public.t4h_research_subarea SET
    subarea_title = 'Cross-reference: DRA programme clinical sub-cohort',
    updated_at    = now()
 WHERE subarea_code = 'A3-S4';

UPDATE public.t4h_research_asset SET
    asset_title = REPLACE(asset_title,
        'DRA - Drug Resilience Atlas',
        'DRA clinical sub-cohort (cross-ref → DRA programme for full artefacts)'),
    notes       = COALESCE(notes,'') || E'\n[2026-04-26] Cross-reference placeholder. Canonical DRA artefacts live in GitHub TML-4PM/drug-resilience-atlas, not here.',
    updated_at  = now()
 WHERE asset_code LIKE 'R-A3-A3-S4-%'
   AND asset_title LIKE '%DRA - Drug Resilience Atlas%';


-- ───────────────────────────────────────────────────────────────
-- PHASE G · Verification
-- ───────────────────────────────────────────────────────────────

-- G.1  DRA registry now CORE/PROGRAM
SELECT 'DRA promoted to CORE/PROGRAM' AS check_name,
       study_id, study_type, spot_bucket, n_type, is_additive, n_declared,
       LEFT(primary_source,60) AS primary_source_head
  FROM research.t4h_study_registry WHERE study_id='DRA';
-- Expected: study_type='CORE', spot_bucket='PROGRAM', n_type='open_platform',
--           is_additive=false, n_declared=NULL, primary_source starts with 's3://troy-intelligence-dashboard/'

-- G.2  No more "Drug Resistance" anywhere
SELECT 'Drug Resistance hits in research_area' AS check_name,
       COUNT(*) AS remaining_hits
  FROM public.t4h_research_area
 WHERE CAST(ROW(t4h_research_area.*) AS text) ~* 'Drug.?Resistance';

SELECT 'Drug Resistance hits in research_items' AS check_name,
       COUNT(*) AS remaining_hits
  FROM public.research_items
 WHERE CAST(ROW(research_items.*) AS text) ~* 'Drug.?Resistance';

-- G.3  No more "Drug-Reaction-AI"
SELECT 'Drug-Reaction-AI hits in research_sublayers' AS check_name,
       COUNT(*) AS remaining_hits
  FROM public.research_sublayers
 WHERE CAST(ROW(research_sublayers.*) AS text) ~* 'Drug-Reaction-AI';

-- G.4  Sub-cohort marker exists
SELECT 'DRA-CLINICAL alias in study_id_map' AS check_name, COUNT(*) AS hits
  FROM research.study_id_map WHERE system_id='DRA-CLINICAL';

-- G.5  Effect on rollups (informational; should not fail)
SELECT 'rollup-by-type post' AS check_name, study_type, COUNT(*) AS studies
  FROM research.t4h_study_registry
 GROUP BY study_type ORDER BY 2 DESC;

SELECT 'program-total post' AS check_name, * FROM research.v_program_total_true;


-- ───────────────────────────────────────────────────────────────
-- PHASE I · Fix v_sweetspots_research_registry view definition
-- ───────────────────────────────────────────────────────────────
-- The view DEFINITION (not just data) embeds the misspelling
-- "Drug Resistance Atlas" AND attaches it to study code 'ASS-2'.
-- Both wrong. Fixing the DDL — adds DRA as its own entry, points to
-- the ASS-2 entry by its real name (Multi-Site Validation).
-- Reverse: Phase Z.9 (re-issue the original DDL captured in Phase A.1).

CREATE OR REPLACE VIEW public.v_sweetspots_research_registry AS
SELECT json_build_object(
    'main_studies', json_build_array(
        json_build_object('code', 'ASS-1/EXT-4247', 'name', 'AI Sweet Spots Model',                   'n', 4247,  'effect_d', 1.81, 'status', 'COMPLETE'),
        json_build_object('code', 'ASS-2',          'name', 'AI Sweet Spots Multi-Site Validation',   'n', 11241,                    'status', 'COMPLETE'),
        json_build_object('code', 'EXT-2847',       'name', 'Extreme AI Effects',                     'n', 2847,                     'status', 'COMPLETE'),
        json_build_object('code', 'DRA',            'name', 'Drug Resilience Atlas',                                                  'status', 'CORE/PROGRAM (peer programme)'),
        json_build_object('code', 'RCT26',          'name', 'CSO Routing Trial',                                                      'status', 'DESIGN')
    ),
    'total_participants', 18335,
    'cognitive_profiles', 10,
    'research_clusters', (
        SELECT json_agg(json_build_object(
            'id',           ai_sweetspots_uber_registry.cluster_id,
            'name',         ai_sweetspots_uber_registry.cluster_name,
            'rows',         ai_sweetspots_uber_registry.rows_in_cluster,
            'coverage_pct', ai_sweetspots_uber_registry.evidence_coverage_pct,
            'priority',     ai_sweetspots_uber_registry.priority
        )) AS json_agg
        FROM ai_sweetspots_uber_registry
    ),
    'cluster_stats', (
        SELECT json_build_object(
            'total_clusters', count(*),
            'total_entries',  sum(ai_sweetspots_uber_registry.rows_in_cluster),
            'avg_coverage',   round(avg(ai_sweetspots_uber_registry.evidence_coverage_pct), 1),
            'critical',       count(*) FILTER (WHERE (ai_sweetspots_uber_registry.priority = 'CRITICAL'::text))
        )
        FROM ai_sweetspots_uber_registry
    )
) AS registry;

-- Verify the view text now contains DRA but not the misspelling
SELECT 'view fixed' AS check_name,
       (definition NOT LIKE '%Drug Resistance Atlas%' AND definition LIKE '%Drug Resilience Atlas%')::text AS result
  FROM pg_views WHERE viewname='v_sweetspots_research_registry';


-- ───────────────────────────────────────────────────────────────
-- PHASE H · Canonical broadcast (IRREVERSIBLE — fires Telegram)
-- ───────────────────────────────────────────────────────────────
-- Run only after Phase G all-pass. trigger trg_auto_broadcast_change
-- fires fn_broadcast_canonical_change → Telegram chat 6972032328
-- + scratchpad pin. Once sent, can't be unsent — but data still
-- rolls back via Z, and Z.10 broadcasts the rollback as a follow-up.

INSERT INTO public.t4h_canonical_changes
    (change_type, title, summary, affected, evidence_ref, author, severity)
VALUES (
    'SCHEMA_CHANGE',
    'DRA misfile correction — promoted to CORE/PROGRAM, spelling fixes, sub-cohort clarification',
    'Corrected Supabase misfiling of DRA (Drug Resilience Atlas). DRA reclassified from APPLIED sub-study to CORE/PROGRAM in research.t4h_study_registry per canonical source V1B.docx (S3: troy-intelligence-dashboard/GDRIVE_WORK_BACKUP/). Fixed Drug Resistance misspellings (2 rows in research_area + research_items), fixed Drug-Reaction-AI in research_sublayers T3, corrected research_items EXT-003 mis-attribution of n=11,241 (that is ASS-2). Clarified ass_study_cards.DRA row as the n=44 clinical sub-cohort, not the whole programme. Re-framed A3 / A3-S4 / 8 auto-seed artefacts as cross-references rather than containment. Added primary source reference to S3 V1B.docx. Fixed v_sweetspots_research_registry view definition (was hardcoded with Drug Resistance Atlas misspelling against ASS-2 study code). Did NOT rename DRA. Did NOT introduce PRAX (which was a fabrication from an earlier Claude session).',
    jsonb_build_object(
        'canonical_source', 's3://troy-intelligence-dashboard/GDRIVE_WORK_BACKUP/Drug Resilience Atlas V1B.docx',
        'tables_updated',   ARRAY['research.t4h_study_registry','public.ass_study_cards','public.t4h_research_area','public.t4h_research_subarea','public.t4h_research_asset','public.research_items','public.research_sublayers'],
        'views_updated',    ARRAY['public.v_sweetspots_research_registry'],
        'rows_updated',     15,
        'rows_inserted',    1,
        'snapshot_schema',  'audit.dra_misfile_correction_20260426',
        'definitions_doc',  'Research_Stack_Definitions_v2.docx',
        'rollback_path',    'Phase Z (commented at bottom of v3.1 SQL)',
        'expected_drift',   jsonb_build_object(
            'v_program_total_true.n_validated_active', '18380 → 18336',
            'v_rollup_by_type.APPLIED.studies',        '28 → 27',
            'v_rollup_by_type.CORE.studies',            '3 → 4'
        )
    ),
    '/mnt/user-data/outputs/Research_Stack_Definitions_v2.docx',
    'Troy Latter (via Claude, handoff to Pen/Symbio)',
    'NORMAL'
);


-- ============================================================================
-- PHASE Z · ROLLBACK
-- ============================================================================
-- Execute only if any Phase A.0 check failed AFTER B-I ran, or if Troy decides
-- to revert. Restores all rows from audit.dra_misfile_correction_20260426.
-- The Telegram broadcast already fired and cannot be unfired — rollback sends
-- a follow-up SCHEMA_CHANGE marking the reversal.
--
-- /*
-- -- Z.1  research.t4h_study_registry (DRA row)
-- UPDATE research.t4h_study_registry t
--    SET study_type    = s.original_row->>'study_type',
--        spot_bucket   = s.original_row->>'spot_bucket',
--        n_type        = s.original_row->>'n_type',
--        n_declared    = (s.original_row->>'n_declared')::int,
--        is_additive   = (s.original_row->>'is_additive')::bool,
--        headline      = s.original_row->>'headline',
--        design_type   = s.original_row->>'design_type',
--        primary_source = s.original_row->>'primary_source',
--        n_source_text = s.original_row->>'n_source_text',
--        evidence_notes = s.original_row->>'evidence_notes',
--        updated_at    = (s.original_row->>'updated_at')::timestamptz
--   FROM audit.dra_misfile_correction_20260426 s
--  WHERE s.source_table='research.t4h_study_registry'
--    AND t.study_id='DRA';
--
-- -- Z.2 ass_study_cards
-- UPDATE public.ass_study_cards t
--    SET study_name = s.original_row->>'study_name',
--        updated_at = (s.original_row->>'updated_at')::timestamptz
--   FROM audit.dra_misfile_correction_20260426 s
--  WHERE s.source_table='public.ass_study_cards' AND t.study_id='DRA';
--
-- -- Z.3 t4h_research_area  (2 rows)
-- UPDATE public.t4h_research_area t
--    SET area_title = s.original_row->>'area_title',
--        notes      = s.original_row->>'notes',
--        updated_at = (s.original_row->>'updated_at')::timestamptz
--   FROM audit.dra_misfile_correction_20260426 s
--  WHERE s.source_table='public.t4h_research_area' AND t.area_code = s.row_pk;
--
-- -- Z.4 t4h_research_subarea
-- UPDATE public.t4h_research_subarea t
--    SET subarea_title = s.original_row->>'subarea_title',
--        updated_at    = (s.original_row->>'updated_at')::timestamptz
--   FROM audit.dra_misfile_correction_20260426 s
--  WHERE s.source_table='public.t4h_research_subarea' AND t.subarea_code = s.row_pk;
--
-- -- Z.5 t4h_research_asset (8 rows)
-- UPDATE public.t4h_research_asset t
--    SET asset_title = s.original_row->>'asset_title',
--        notes       = s.original_row->>'notes',
--        updated_at  = (s.original_row->>'updated_at')::timestamptz
--   FROM audit.dra_misfile_correction_20260426 s
--  WHERE s.source_table='public.t4h_research_asset' AND t.asset_code = s.row_pk;
--
-- -- Z.6 research_items (EXT-003 etc)
-- UPDATE public.research_items t
--    SET title       = s.original_row->>'title',
--        notes       = s.original_row->>'notes',
--        updated_at  = (s.original_row->>'updated_at')::timestamptz
--   FROM audit.dra_misfile_correction_20260426 s
--  WHERE s.source_table='public.research_items' AND t.id = s.row_pk;
--
-- -- Z.7 research_sublayers (T3 etc)
-- UPDATE public.research_sublayers t
--    SET notes       = s.original_row->>'notes',
--        updated_at  = (s.original_row->>'updated_at')::timestamptz
--   FROM audit.dra_misfile_correction_20260426 s
--  WHERE s.source_table='public.research_sublayers' AND t.id = s.row_pk;
--
-- -- Z.8 study_id_map: drop the DRA-CLINICAL alias we inserted in Phase E
-- DELETE FROM research.study_id_map
--  WHERE system_id='DRA-CLINICAL'
--    AND notes LIKE '%2026-04-26%';
--
-- -- Z.9 Restore the original (broken) view definition
-- -- Pull DDL from audit.dra_misfile_correction_20260426 source_table='pg_views.v_sweetspots_research_registry'
-- -- and re-execute as CREATE OR REPLACE VIEW.
--
-- -- Z.10 Broadcast rollback
-- INSERT INTO public.t4h_canonical_changes (change_type, title, summary, author, severity)
-- VALUES ('SCHEMA_CHANGE',
--         'ROLLBACK: DRA misfile correction reverted',
--         'Reverted DRA reclassification + spelling fixes. Original state restored from audit.dra_misfile_correction_20260426. Reason: <fill in here>.',
--         'Troy Latter',
--         'HIGH');
-- */

-- ============================================================================
-- END v3.1
-- ============================================================================
