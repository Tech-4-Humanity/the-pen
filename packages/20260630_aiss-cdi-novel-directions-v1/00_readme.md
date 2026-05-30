# 2026-06-30 — AI Sweet Spots: CDI + Novel Directions (v1.0.0)

This package ships two production-ready, idempotent Supabase install scripts:

1) **ASS-CDI-001** — *Coordination Dividend Index (CDI)*: a repeatable instrument + scoring engine for measuring AI coordination scaffolding vs production assistance (CDI + Dependency Index) with privacy-safe cohort reporting.
2) **T4H Research Registry (Novel Directions)** — a single canonical registry that makes “Novel Directions” first-class (no “spares”, no “pipeline”), while keeping a stable map layer for structured programme cells.

This aligns to the **AI Sweet Spots Research IP Operating Model** (7×7 lattice / 49 canonical cells) and its separation of research assets from products/courses. fileciteturn5file17

## Counts we are standardising

- The public pipeline page states **“47 Novel Directions · 8 Domains”** and shows tier splits **13 / 15 / 19**. citeturn0view0  
- The internal **Novel Ideas & Research Expansion Register** also states **47 distinct novel research directions across 8 domains**. fileciteturn5file13

**Rule shipped in the schema:** store both `header_count` and `parsed_count` in a META row so Command Centre always shows a reconciled truth even when the webpage header drifts.

## Files

- `01_supabase_ass_cdi_install_v1.sql`
  - Creates CDI study scaffolding (`ass_*` tables), seeds ASS-CDI-001 + CDI-PULSE-001 instrument, installs scoring + triggers, adds privacy-safe views.

- `02_supabase_t4h_novel_directions_registry_v1.sql`
  - Creates a single canonical registry with record types:
    - `MAP_CELL` (structured programme cells)
    - `NOVEL_DIRECTION` (everything formerly described as “pipeline/spare/emerging”)  
    - `META` (counts, audits, version markers)
  - Includes novelty stage (`NOVEL | EXTENSION | APPLIED_HYPOTHESIS`), maturity + signal fields, business alignment, and impact views.

## Install order

1) Run `01_supabase_ass_cdi_install_v1.sql` in Supabase SQL Editor.
2) Run `02_supabase_t4h_novel_directions_registry_v1.sql` in Supabase SQL Editor.
3) Import any CSVs into the provided staging tables (optional), then run the promote blocks.

## Governance notes (non-negotiable)

- **Research assets are not products.** Products/courses are packaged interpretations. fileciteturn5file15
- Certain asset IDs must **never** be sold individually (e.g., raw dataset, cleaning rules, replication package). fileciteturn5file14

---

### Receipt

This repo write was performed via the GitHub connector (direct commit). In the Pen doctrine, the stronger path is `fn_github_push(...)` via Bridge; if you want full doctrinal receipts, run a follow-up bridge replay that mirrors these files into place.
