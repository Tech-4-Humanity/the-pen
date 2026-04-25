# DRA / Resilience / Atlas Audit — What's Actually in Supabase and S3

**Scan date:** 2026-04-22
**Scope:** Content-level regex match across every research-adjacent table in Supabase S1 (118 tables) + every object key in all 64 S3 buckets
**Patterns matched:** `\mDRA\M`, `drug.?resilien`, `drug.?respons`, `\mPRAX\M`, `\matlas\M`, `resilience`

---

## SUPABASE — 14 tables, 24 rows

### Study-identity layer

| Table | Row key | Value |
|---|---|---|
| `public.ass_study_cards` | `study_id='DRA'` | `study_name='Drug Resilience Atlas'`, status=drafted, target_n=500, current_n=44, ethics_ref=`ETH-DRA — Full HREC` |
| `public.ass_ethics_applications` | `ETH-DRA` | Linked to DRA, risk=high, body=University HREC with addiction/recovery expertise, status=drafted |
| `research.study_id_map` | id=13, id=60 | Both map `DRA → DRA` canonical (from `gain_studies` and `ass_study_cards`) |
| `research.t4h_study_registry` | 1 row | `study_id='DRA'`, study_name="Drug Resilience Atlas", design=Case-series, RDTI-DRA, status=active, ethics=ETH-DRA, source=`public.ass_study_cards`, evidence=VERIFIED |

### Taxonomy layer

| Table | Row key | Value |
|---|---|---|
| `public.t4h_research_area` | `A3` | "Extreme AI Effects", notes: *"Container: ASS-2 + DRA + psychedelics."* |
| `public.t4h_research_area` | `DRUG_INTERACT` | Title: *"Drug / Substance Interactions (Drug Resistance Atlas)"* — note **Resistance** spelling, not Resilience |
| `public.t4h_research_subarea` | `A3-S4` | Title: *"DRA - Drug Resilience Atlas"* |

### Artefact layer (all "MISSING" / "PRETEND" status — auto-seed slots never populated)

| Asset code | Title | Status |
|---|---|---|
| `R-A3-A3-S4-AST-DATASET` | Extreme AI Effects \| DRA - Drug Resilience Atlas \| Dataset | MISSING |
| `R-A3-A3-S4-AST-ABSTRACT` | " \| Abstract | MISSING |
| `R-A3-A3-S4-AST-PAPER` | " \| Research paper | PARTIAL |
| `R-A3-A3-S4-AST-POSTER` | " \| Poster (A0) | MISSING |
| `R-A3-A3-S4-AST-ASSESS` | " \| Assessment | MISSING |
| `R-A3-A3-S4-AST-PRESS` | " \| Press release | MISSING |
| `R-A3-A3-S4-AST-BRIEF` | " \| 1-pager / policy brief | PARTIAL |
| `R-A3-A3-S4-AST-SLIDES` | " \| Slide set (2-3) | MISSING |

### Indirect / contextual references

| Table | Row | What it says |
|---|---|---|
| `public.ai_sweetspots_uber_registry` | `SS_CLUSTER_B_ALTERED_STATES` | Cluster card says "44 DRA cases" as evidence source |
| `public.research_chunks` | id 0d0c9... | Portfolio-group reference chunk (incidental "DRA" string) |
| `public.research_items` | `EXT-003` | Title: *"Drug Resistance Atlas (N=11241)"* — note **Resistance** again, plus incorrectly-attributed n=11,241 (which is ASS-2's n, not DRA's) |
| `public.research_sublayers` | `T3` — "Clinical Populations" | Text includes "Drug-Reaction-AI (DRA) protocol" — **fourth spelling** |
| `public.research_topics` | row 63 | "T07-S03 — Resilience Atlas Integration" under CARE |
| `public.research_publication_register` | 2 rows | LinkedIn articles: "Australia's Floating Future: From Risk to **Resilience**" (unrelated), "The Atlas of Sleeper Tech" (unrelated) |
| `public.t4h_research_commercial_class` | `research_to_commercial` | Mentions "Neural Market Intelligence / Resilience Atlas (as dashboards)" |

---

## 🚨 THE BIG FINDING — Four different expansions of "DRA" exist right now in Supabase

| # | Expansion | Where it appears |
|---|---|---|
| 1 | **Drug Resilience Atlas** | `ass_study_cards`, `t4h_study_registry`, `t4h_research_subarea A3-S4`, all 8 `t4h_research_asset` seed rows, `study_id_map` |
| 2 | **Drug Resistance Atlas** | `t4h_research_area DRUG_INTERACT`, `research_items EXT-003` |
| 3 | **Drug-Reaction-AI (DRA) protocol** | `research_sublayers T3` Clinical Populations |
| 4 | **Drug Response × AI** | The paper §5.1 you flagged earlier (in the .docx output, not yet in Supabase) |

Plus `research_topics T07-S03` says "Resilience Atlas Integration" under CARE — which is yet another context (suggests it's also part of the CARE protocol somehow, not just A3).

---

## S3 — 13 real hits across 7 buckets

Out of 70 pattern matches, 57 were "DRAFT" / "drawing" / "Drake" noise. Real references below:

### Primary source files (the actual Drug Resilience Atlas drafts)

| Bucket | Object |
|---|---|
| `troy-intelligence-dashboard` | `GDRIVE_WORK_BACKUP/Drug Resilience Atlas V1.docx` |
| `troy-intelligence-dashboard` | `GDRIVE_WORK_BACKUP/Drug Resilience Atlas V1B.docx` |
| `troy-intelligence-dashboard` | `GDRIVE_WORK_BACKUP/DRA initial.docx` |

### A folder scaffold (empty)

| Bucket | Object |
|---|---|
| `t4h-ip-static` | `resilienceatlas/.folder` — **bucket scaffold exists, never populated** |

### Unrelated "Atlas" references

| Bucket | Object | What it is |
|---|---|---|
| `troy-intelligence-dashboard` | `single "／capture" endpoint in Atlas Bridge.docx` | Different "Atlas Bridge" concept |
| `troy-intelligence-dashboard` | `unified Atlas Alignment Protocol Implementation Pack (v2.docx` | Different "Atlas" — alignment protocol |
| `troy-ses-emails` | `mind-atlas.io/AMAZON_SES_SETUP_NOTIFICATION` | `mind-atlas.io` — separate product/brand |
| `sydney-vault` | `gdrive-personal-purge-2026-01-14/Troy Latter - Atlassian.docx` | Atlassian (the company), not Atlas |
| `sydney-vault-professional-2026` | `cv-vault/mac-downloads/Troy Latter - Atlassian.gdoc` | Same — Atlassian |
| `tech4humanity-mac-backups` | `NOPSEMA-00223 - RFT/Magic Quadrant for API Management.pdf` | Contains "Atlas" string somewhere in filename chain — false positive |

---

## WHAT THIS MEANS (observed, not prescribed)

1. **There is no single canonical record for what DRA is.** The database contains four expansions in four different tables. The study record (`ass_study_cards`) says "Drug **Resilience** Atlas". The taxonomy (`t4h_research_area`) says "Drug **Resistance** Atlas". The clinical sublayer (`research_sublayers`) says "Drug-**Reaction**-AI protocol". The paper §5.1 says "Drug **Response** × AI". These are genuinely different things, or the same thing named inconsistently — I can't tell from the data alone.

2. **The n=44 in `ass_study_cards` is real.** But `research_items EXT-003` claims "Drug Resistance Atlas (N=11241)" — which is ASS-2's n, not DRA's. This is a data error somewhere.

3. **`t4h_research_asset` has 8 auto-seeded slots for DRA artefacts, all PRETEND/MISSING.** They were created 2026-02-23 and never populated. The study has real content (n=44 cases, drafts in S3) but the artefact slots show empty.

4. **S3 has two draft documents** (`Drug Resilience Atlas V1.docx` and `V1B.docx`) plus one early document (`DRA initial.docx`). These pre-date the Supabase records.

5. **`resilienceatlas/.folder`** in `t4h-ip-static` — IP bucket has a directory stubbed out but never populated.

6. **`research_topics T07-S03 "Resilience Atlas Integration" under CARE**" — suggests the Resilience Atlas has (or was intended to have) a relationship with the Indigenous CARE protocol. I cannot tell from the data what this relationship is.

7. **Multiple "Atlas" concepts exist that are NOT the DRA.** `mind-atlas.io` appears to be a separate product with SES email routing. "Atlas Bridge" and "Atlas Alignment Protocol" are separate framework-level concepts in working documents.

---

## WHAT I HAVE NOT DONE

- Not read the contents of `Drug Resilience Atlas V1.docx` / `V1B.docx` / `DRA initial.docx` (only the filenames were enumerated)
- Not searched `public.t4h_research_page_sections` body content (0 hits but table only has 4 cols — `page_code`, `section_type`, `content`, `updated_at` — content regex may have missed)
- Not searched `bci_research_papers`, `bci_research_publications`, or `book_research*` tables (they're in the 118 but may have returned 0 hits)
- Not searched non-research-prefixed tables that might also contain DRA references (e.g. `llm_scratchpad`, `t4h_canonical_changes` full body, `maat_*` financial tables)
- Not opened any of the S3 documents to check their actual content
- Not scanned the Supabase S2 project at all (you flagged it as policy-gated)

## Decisions I need from you before I do anything else

1. **What is DRA actually?** The canonical definition. Is it the study (n=44 recovery cohort) or the framework (§5.1 of the paper) or both or something else? The data has four expansions — which is right?
2. **Do I read the source docx files from S3?** They'd settle the question in #1.
3. **Anything you want me to do beyond reporting?** I haven't written, renamed, or modified anything in this turn. Just reported.
