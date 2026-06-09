# Research Decision Register Rollup v1.0

Date: 2026-06-05
Owner: Troy Latter / Tech 4 Humanity
Status: PARTIAL - rollup generated from seeded decision register

## Source

This rollup is based on:

- `research-library/00_agreed-taxonomy-one-pager-v1.md`
- `research-library/01_research-decision-register-v1.csv`
- supplied cutoff text and registry anchors in the conversation

It is not the final estate count. It is the current working register count.

---

## Current seeded register counts

| Status | Count |
|---|---:|
| KEEP | 29 |
| PARK | 1 |
| EMERGING | 1 |
| KILL | 0 |
| MERGE | 0 |
| DUPLICATE | 0 |
| PROMOTE | 0 |
| Total seeded rows | 31 |

---

## Counts by programme

| Programme / body of work | KEEP | PARK | EMERGING | Total seeded rows |
|---|---:|---:|---:|---:|
| AI Sweet Spots | 10 | 1 | 0 | 11 |
| Cognitive Diversity and Population Evidence | 3 | 0 | 0 | 3 |
| MyNeuralSignal and Signal Integrity | 3 | 0 | 0 | 3 |
| Unified Biological Intelligence and Living Stack | 2 | 0 | 0 | 2 |
| Digital Child Protection and Platform Regulation | 3 | 0 | 0 | 3 |
| Social Media Narrative Distribution and Commercialisation | 1 | 0 | 0 | 1 |
| Doolittles Translation and Communication Meaning | 6 | 0 | 1 | 7 |
| GCBAT and Validated Execution | 1 | 0 | 0 | 1 |

Current seeded register contains 8 of the 10 programmes. The two not yet explicitly seeded as independent programme rows are:

- ConsentX, Identity and Governance
- NEUROPAK and Intent Orchestration

They are currently represented indirectly through the Integrity Stack / governance mapping, but need explicit programme rows in the next import.

---

## What this proves

The useful operating move is now confirmed:

- The model is row-based.
- Emerging is not a theme.
- Social Media is preserved as a programme/topic surface.
- 15 topic families are an executive navigation layer.
- 117 accepted subtopics and 160+ candidate/extras are not yet fully loaded into the decision register.

---

## What remains to be loaded

### Missing explicit programme rows

| Programme | Required next rows |
|---|---|
| ConsentX, Identity and Governance | Consent actor models, ID Exchange, authority, revocation, audit, minor/guardian consent, organisational consent. |
| NEUROPAK and Intent Orchestration | Intent validation, readiness, BCI-adjacent orchestration, assistive intent, action gating, consent-bound intent. |

### Missing accepted taxonomy rows

The 117 accepted operational subtopics have not yet been fully imported row-by-row. Current register is only seeded with 31 rows.

### Missing candidate / extras rows

The 160+ broader estate has not yet been loaded. These must be classified as:

- EMERGING
- PARK
- MERGE
- KILL
- DUPLICATE
- PROMOTE
- KEEP

---

## Final one-page view target

The final artefact should produce this table with real counts:

| Programme | Topics | Subtopics | KEEP | MERGE | PARK | KILL | DUPLICATE | EMERGING | PROMOTE | Total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| AI Sweet Spots | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Cognitive Diversity and Population Evidence | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Digital Child Protection and Platform Regulation | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| MyNeuralSignal and Signal Integrity | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Unified Biological Intelligence and Living Stack | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| ConsentX, Identity and Governance | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| NEUROPAK and Intent Orchestration | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| GCBAT and Validated Execution | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Doolittles Translation and Communication Meaning | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Social Media Narrative Distribution and Commercialisation | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

---

## Reality Ledger

status: PARTIAL
result: Rollup generated from seeded decision register. Current register has 31 seeded rows with 29 KEEP, 1 PARK and 1 EMERGING.
evidence:
  - GitHub decision register CSV exists
  - rollup committed to GitHub
  - source register row count inspected before rollup creation
gaps:
  - 117 accepted rows not fully imported
  - 160+ candidate/extras rows not fully imported
  - ConsentX and NEUROPAK need explicit programme rows
  - killed / merged / duplicate counts are still zero because rows have not yet been classified, not because no such rows exist
next_action:
  - import remaining accepted taxonomy rows
  - import candidate/extras rows
  - generate final programme-by-status count table
  - create printable one-page agreement sheet
elevation:
  - converts the debate into a register-driven count model
pressure_flags:
  - zero KILL/MERGE/DUPLICATE means not yet loaded, not none
  - seeded counts must not be presented as final estate counts
score: 0.88
