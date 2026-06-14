# Drug Resilience Atlas (DRA) — Handoff

Date: 2026-06-02
Owner: Troy Latter / Tech 4 Humanity
Source Drive URL: https://drive.google.com/file/d/1P-JcQFlxe68chPqXrr4UXwZdK6o0TlLJ/view?usp=sharing
Uploaded asset: altered-states-grid.html

## Intent
Add the uploaded Altered States Atlas dashboard into the Drug Resilience Atlas (DRA) workstream and prepare equivalent deployment packaging for the Vercel platform.

## Clarification
There is no workspace/team called “Vercel”. Vercel is the deployment platform. The available workspace identified in session was:

```text
Name: troy's projects
Slug: troys-projects-t4h-machine
Team ID: team_IKIr2Kcs38KGo8Zs60yNtm7Y
```

Any deployment wording should refer to deploying to the Vercel platform under the `troy's projects` workspace, not to a team named Vercel.

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
5. Prepare static app deployment to the Vercel platform under the correct `troy's projects` workspace/project context.
6. Add README with research warning, non-clinical disclaimer, and evidence classification.
7. Add receipt after deployment URL exists.

## Evidence classification
| Area | Classification | Notes |
|---|---:|---|
| Uploaded HTML asset | REAL | Asset provided in current session. |
| GitHub handoff | REAL | This file is the Pen handoff receipt. |
| Deployment target | PARTIAL | Platform identified; specific project/deploy execution pending. |
| Runtime telemetry | MISSING | No deployed runtime yet. |

## Deployment request
Deploy as a static app on the Vercel platform, using the correct workspace/project context. Do not refer to a team named “Vercel”; use `troy's projects` when referring to the workspace identified in session.

## Receipt
This handoff is the GitHub/Pen receipt for DRA ingestion and deployment clarification.
