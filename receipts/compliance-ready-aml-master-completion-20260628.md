# Compliance Ready AML Master Workbook Completion Receipt

## Status

**Classification:** REAL for workbook generation and GitHub receipt.

**Workbook:** `Compliance-Ready-AML-Master.xlsx`

**Scope:** Compliance Ready powered by Oikos — unified AML/Digital Proof workbook for accountants, conveyancers and real estate.

## What was completed

The workbook was expanded from a basic sector workbook into a canonical AML operating model with retained source requirements, researched AUSTRAC references and sector-specific execution layers.

### Core principle

One canonical AML/Digital Proof model. Accountants, conveyancers and real estate are generated sector views. No forks.

### Preserved source material

The full uploaded requirement corpus was retained in the workbook under `98 Master Req Repository`.

### Canonical sheets added / completed

- `00 Dashboard`
- `01 Architecture Principles`
- `05 Sector Overview`
- `20 Conveyancers GTM`
- `30 Accountants GTM`
- `70 Roadmap Backlog`
- `89 Gaps Ideas Register`
- `90 Capability Registry`
- `91 Evidence Catalogue`
- `92 Integration Registry`
- `93 Commercial Packages`
- `94 Scope Classification`
- `95 Oikos Core Objects`
- `96 Decision Evidence Models`
- `97 Canonical Instructions`
- `98 Master Req Repository`
- `99 Sources`

## New model decisions

### Capability classifications

The workbook now uses the following classifications rather than hard exclusions:

- `MUST`
- `SHOULD`
- `MAY`
- `FUTURE`
- `OUT_OF_SCOPE`
- `SECTOR_SPECIFIC`
- `SHARED_OIKOS`

### Scope handling

Capabilities not relevant to this workbook are marked `OUT_OF_SCOPE`, not `NEVER`, so future convergence remains possible.

Examples:

- Vehicle Wallets → OUT_OF_SCOPE / Global Tyres workbook
- Fleet Management → OUT_OF_SCOPE / AI4Tradies or Global Tyres workbook
- Workshop Trust Scores → OUT_OF_SCOPE / Global Tyres workbook
- White Card Tracking → OUT_OF_SCOPE / AI4Tradies workbook
- PEXA Evidence Capture → SECTOR_SPECIFIC / Conveyancers
- SMSF Relationship Maps → SECTOR_SPECIFIC / Accountants

## Cross-sector capability additions

- Designated Service Decision Engine
- Geographic Link Test
- CDD Timing Gate
- Responsibility Matrix
- Reliance Logic
- Legal Privilege / Confidentiality Handling
- Evidence Quality Scoring
- Decision Ledger
- Cyber Fraud Layer
- Pricing Engine
- Evidence Reuse Engine
- Trust Score Framework

## Sector customisation

### Accountants

Positioned around client/entity/wealth proof, trusts, SMSFs, source of wealth, beneficial ownership, annual client refresh and practice integrations.

Primary integrations captured:

- XPM
- FYI
- CAS360
- APS
- MYOB AE
- BGL Simple Fund 360
- Class
- NowInfinity

### Conveyancers

Positioned around property transaction proof, PEXA evidence, VOI, settlement readiness, source-of-funds, trust accounts, foreign buyer risk and cyber fraud protection.

Primary integrations captured:

- PEXA
- InfoTrack
- triSearch
- LEAP
- Smokeball
- Actionstep
- Dye & Durham

### Real Estate

Retains existing NSW Property API harvest, Shire first-10 target pipeline and real estate GTM model. Adds property management AML, fake vendor protection, vendor/buyer/landlord/tenant proof concepts.

## Research sources embedded

Official AUSTRAC sources were embedded in `99 Sources`, including:

- Reform overview
- Obligations overview
- Enrolment overview
- Real estate program starter kit
- Conveyancing program starter kit
- Accounting program starter kit
- Professional designated services
- Real estate designated services
- Initial CDD overview
- Ongoing monitoring guidance
- Suspicious Matter Reports guidance
- Record keeping overview

## Verification

Workbook verification completed:

- Dashboard inspected successfully.
- Formula error scan returned no matches for common formula errors.
- Workbook exported to `/mnt/data/Compliance-Ready-AML-Master.xlsx`.

## Remaining planned work

1. Authenticate Conveyancer API.
2. Harvest conveyancer data.
3. Deduplicate and normalise conveyancer records.
4. Generate first 100 conveyancer targets.
5. Add accountant data sources once identified.
6. Generate first 100 accountant firm targets.
7. Build customer-facing Compliance Ready sales kit v2.

## Security note

Previously pasted API credentials and bearer tokens should be treated as exposed and rotated before production use.
