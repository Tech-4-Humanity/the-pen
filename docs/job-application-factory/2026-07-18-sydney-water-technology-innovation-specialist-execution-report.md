# Job Application Factory — Sydney Water Execution Report

## Status

**Package:** `Troy_Latter_Sydney_Water_Technology_and_Innovation_Specialist_FINISHED_VALIDATED.zip`  
**Employer:** Sydney Water  
**Role:** Technology and Innovation Specialist  
**S3 prefix:** `Sydney Water - Technology and Innovation Specialist/`  
**Current classification:** PARTIAL — package is locally validated; authenticated S3 redeployment and live readback remain required.

## Purpose of this report

This report records the full execution history, defects identified during review, corrections made, validation controls added, and the updated four-template standard for the Job Application Factory.

## Role positioning

The Sydney Water application is positioned around:

- emerging technology assessment;
- innovation strategy and roadmaps;
- research and innovation program delivery;
- stakeholder workshops and problem framing;
- university, industry, supplier and government collaboration;
- grants and external funding;
- business adoption and transition into business-as-usual;
- customer, operational and environmental outcomes.

The application does not claim a water-sector degree, water-sector employment, awarded grants, or qualifications that have not been evidenced.

## Position-description review

The full Sydney Water position description was reviewed. Key requirements incorporated into the package include:

- coordination of technology pilot trials;
- management of research and innovation initiatives;
- emerging technology scanning across AI, robotics, sensing, IoT and treatment technologies;
- management of memberships and external partnerships;
- robust technology evaluation;
- transition of research outcomes into business-as-usual;
- reporting for Board, Executive and R&D Tax purposes;
- state and federal grants and industry partnerships;
- innovation culture, workshops, events and communications;
- relationships with WSAA, universities, CSIRO, utilities and industry partners;
- complex multidisciplinary project management;
- commercial acumen, networking and contract management;
- accountability, agility, innovation, collaborative research, stakeholder engagement, business writing and influencing.

## Defects identified and corrected

### 1. Incomplete first package

The initial Sydney Water output was a placeholder package with non-functional validation and deployment scripts. It did not meet the Job Application Factory runtime standard.

**Correction:** The package was rebuilt with complete employer-branded HTML, evidence-led infographic, manifest, real validator, exact-prefix deployment, bucket-policy merge, S3 checks, HTTP checks, live readback and receipt generation.

### 2. Visible ATS keyword sections

A prior application exposed ATS terms as a visible section. This is now prohibited across the factory.

**Correction:** Relevant language is integrated naturally into summaries, capabilities, experience and achievements. Validators block `ATS Keywords` headings or dumps.

### 3. Selection criteria missing

The detailed Sydney Water position description required a separate selection-criteria response.

**Correction:** `selection-criteria.html` was added with six structured evidence responses covering multidisciplinary technology delivery, technology evaluation, business-as-usual adoption, stakeholder engagement, grants and partnerships, and commercial/contract management.

### 4. Visible STAR letters

The first selection-criteria layout displayed S/T/A/R circles. These distracted from the evidence.

**Correction:** Visible STAR lettering was removed. The responses retain logical situation-task-action-result progression through readable evidence blocks.

### 5. Runtime validation footer exposed to the employer

The landing page displayed internal factory language such as validated ZIP, exact-prefix deployment, HTTP checks and stale-content contamination.

**Correction:** Internal runtime language was removed from employer-facing pages. A professional contact footer now provides LinkedIn, Tech4Humanity, TroyLatter.com and WorkFamilyAI links.

### 6. Infographic opened as an ineffective raw image

Normal navigation opened `infographic.png` directly. On large desktop displays the tall image appeared isolated, narrow and surrounded by black browser space.

**Correction:** `infographic.html` now provides a responsive, employer-branded presentation frame. It scales the image to a readable width, keeps the full-resolution PNG available separately, includes navigation, and presents consistently with the other application pages.

## Four-template standard

### Template 1 — Cover Letter

Requirements:

- employer branded;
- role and organisation specific;
- concise and print-ready;
- honest transferability statements;
- no unsupported qualifications or sector claims;
- naturally uses role terminology;
- links to the other application assets.

### Template 2 — CV

Requirements:

- tailored executive or specialist profile selected from the role;
- evidence-led achievements and metrics;
- role requirements integrated naturally;
- no visible ATS keyword section;
- no web-only clutter when printed;
- no fabricated certifications, budgets, teams or employment history.

### Template 3 — Infographic

Requirements:

- evidence-led and distinct from the CV and cover letter;
- skills/capability matrix;
- structured examples;
- delivery metrics;
- capability heatmap;
- industry or partnership fit;
- no portrait unless a verified user image is intentionally supplied;
- presented through responsive `infographic.html`;
- full-resolution `infographic.png` retained as a downloadable asset.

### Template 4 — Selection Criteria

Requirements:

- created when the role or position description requires criteria responses;
- maps directly to required qualifications, experience, capabilities and accountabilities;
- structured evidence without visible S/T/A/R labels;
- acknowledges transferable sector experience honestly;
- addresses qualification alternatives exactly as stated;
- supported by validation for required criteria coverage.

## Validation controls

The Sydney Water validator now checks:

- all required files exist and are non-empty;
- employer and role appear across core pages;
- required role concepts are present;
- no visible ATS section exists;
- stale employer and role content is absent;
- all relative navigation links resolve;
- selection criteria contains six or more evidence cards;
- key criteria are represented;
- infographic is at least 1200 × 1600;
- `infographic.html` embeds the PNG responsively;
- core pages link to `infographic.html`, not directly to the PNG;
- professional contact links are present;
- internal runtime footer language is absent.

## Deployment workflow

The included deployment script:

1. executes local validation;
2. checks authenticated AWS access;
3. deletes only the exact package prefix;
4. uploads the complete employer-facing package;
5. merges a package-specific public-read statement into the existing bucket policy;
6. verifies every required S3 object;
7. performs HTTP 200 checks;
8. performs live company, role, selection-criteria, infographic and footer-link readback;
9. checks live pages for stale content and internal runtime language;
10. writes and uploads `deployment-receipt.json`;
11. returns `STATUS=REAL` only when all checks pass.

## Package contents

- `index.html`
- `cover-letter.html`
- `cv.html`
- `selection-criteria.html`
- `infographic.html`
- `infographic.png`
- `build-manifest.json`
- `validate-package.sh`
- `deploy-and-verify.sh`
- `deployment-receipt.json`

## Factory process update

Every role pasted into the Job Application Factory is an execution request. No separate strategy response is required. Positioning, profile selection, keyword alignment, selection criteria, visual improvements, validation changes and deployment safeguards must be implemented directly in the package.

A role is not REAL merely because a ZIP exists. REAL requires:

- complete validated ZIP;
- authenticated upload;
- exact-prefix replacement;
- policy merge;
- S3 object verification;
- HTTP 200 for all public assets;
- live role/company/content readback;
- no stale content;
- receipt generation and persistence.

## Current next action

Download the rebuilt single package, run its included `validate-package.sh` and `deploy-and-verify.sh`, and retain the resulting `deployment-receipt.json`. The package remains PARTIAL until that receipt returns `STATUS=REAL`.
