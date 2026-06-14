# Drug Resilience Atlas (DRA) — Handoff

Date: 2026-06-02
Owner: Troy Latter / Tech 4 Humanity
Source Drive URL: https://drive.google.com/file/d/1P-JcQFlxe68chPqXrr4UXwZdK6o0TlLJ/view?usp=sharing
Uploaded asset: altered-states-grid.html

## Intent
Add the uploaded Altered States Atlas dashboard into the Drug Resilience Atlas (DRA) workstream and prepare equivalent Vercel deployment packaging.

## Current asset
- Single-file HTML dashboard.
- Title: Altered States Atlas.
- Function: interactive multi-lens matrix for drug/substance/outcome signals.
- Filters: audience lens, gender, age, metric, palette.
- Views: Issue × Drug heatmap, top signals, demographic slices, ripple effects, mixed evidence/category cleanup.

## DRA mapping
Recommended product name: Drug Resilience Atlas (DRA).
Recommended component name: DRA Altered States Atlas.

Canonical structure proposed:

```text
dra/
  README.md
  public/
    index.html
  src/
    altered-states-grid.html
  evidence/
  methodology/
  datasets/
  receipts/
```

## Required next build
1. Rename user-facing shell from Altered States Atlas to Drug Resilience Atlas where appropriate.
2. Preserve Altered States Atlas as a module/view label.
3. Add provenance panel for Drive/source, evidence class, data version, and generated date.
4. Replace synthetic data with versioned dataset once available.
5. Prepare Vercel static app deployment.
6. Add README with research warning, non-clinical disclaimer, and evidence classification.
7. Add receipt after deployment URL exists.

## Evidence classification
| Area | Classification | Notes |
|---|---:|---|
| Uploaded HTML asset | REAL | Asset provided in current session. |
| GitHub handoff | REAL | This file is the Pen handoff receipt. |
| Vercel deployment | PARTIAL | Pending target project/deploy execution. |
| Runtime telemetry | MISSING | No deployed runtime yet. |

## Deployment request
Deploy as a Vercel static app similar to the uploaded dashboard, preferably under a DRA-specific project or existing T4H research/atlas project.

## Receipt
This handoff is the GitHub/Pen receipt for DRA ingestion.
