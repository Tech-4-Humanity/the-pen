# Follow The Money™ / Jersey of the Day™ v1.0

## Purpose

Create an open source civic transparency engine that turns daily headlines into visible influence maps: sponsor jerseys, impact jerseys, team cards, polls, and source packs.

The core visual question is simple:

- Who funds it?
- Who promotes it?
- Who benefits?
- Who pays?
- Who is affected?

The jersey is the meme. The atlas is the product. The open source framework is the distribution engine. Tech4Humanity is the trust layer.

## Daily product

Every day the system ingests Australian headlines, classifies the issue, identifies the teams, maps public evidence, generates jerseys/cards/polls, and publishes a shareable public page.

Outputs per issue:

1. Headline summary
2. Issue category
3. Team map
4. Sponsor jersey
5. Impact jersey
6. Poll of the day
7. Evidence/source pack
8. Confidence and caveat block
9. Public archive page
10. Social image pack

## Canonical flow

```text
Headline -> Issue -> Actors -> Evidence -> Teams -> Jerseys -> Poll -> Archive -> Atlas
```

## Safety rule

Never claim that a donation or association proves control unless legally established. Use careful language:

- received donations from
- publicly supported by
- associated with
- policy-aligned actor
- reported interest
- likely beneficiary
- affected group
- unresolved evidence

## First country pack

Australia.

Initial public data classes:

- AEC political donation disclosures
- lobbying registers
- parliamentary registers
- public grants and procurement
- public company disclosures
- union and NGO public reporting
- think tank disclosures where available
- media statements and policy documents
- court and inquiry documents where relevant

## First ten issues

1. Nuclear energy
2. Negative gearing
3. ISIS brides / repatriation
4. Vaping
5. Gambling advertising
6. NDIS reform
7. Superannuation tax
8. Housing supply
9. AUKUS / defence spending
10. Social media age limits

## Issue schema

```yaml
issue:
  id: aus-2026-06-02-negative-gearing
  title: Negative gearing reform
  country: Australia
  date: 2026-06-02
  category: housing
  headline: Government signals negative gearing changes
  status: draft

teams:
  - id: keep-negative-gearing
    name: Keep It
    position: Retain negative gearing
    sponsors: []
    advocates: []
    beneficiaries: []
    impacted_groups: []
    confidence: medium

  - id: change-negative-gearing
    name: Change It
    position: Restrict or remove negative gearing
    sponsors: []
    advocates: []
    beneficiaries: []
    impacted_groups: []
    confidence: medium

evidence:
  donations: []
  lobbying: []
  public_statements: []
  policy_documents: []
  media_sources: []

warnings:
  - Correlation is not causation.
  - Donations do not prove control.
  - Impact mapping is explanatory, not a legal finding.
```

## Open source modules

```text
headline-ingestor/
issue-classifier/
actor-registry/
influence-mapper/
jersey-generator/
poll-generator/
evidence-pack-builder/
country-packs/australia/
templates/
public-archive/
atlas-view/
```

## Poll of the day model

Avoid cheap yes/no rage bait. Ask values-based questions.

Example:

```yaml
poll:
  question: What should matter most in this decision?
  options:
    - national security
    - rights of children
    - rule of law
    - public confidence
    - diplomatic obligations
```

## Brand lock

All public outputs carry:

```text
Follow The Money™
Jersey of the Day™
Powered by Tech4Humanity
Generated from public data. Visualisation only. Check sources.
```

## Reality Ledger

status: PARTIAL
result: v1.0 concept, schema, product flow, safety language, modules and initial issue set created and committed to canonical repo.
evidence: GitHub commit receipt from TML-4PM/the-pen.
gaps:
  - no runtime headline ingestion deployed yet
  - no jersey renderer deployed yet
  - no evidence connector running yet
  - no poll publishing surface deployed yet
  - no 72h survivability proof
next_action:
  - create issue template files
  - create initial Australia country pack
  - create JSON schema
  - create first nuclear demo issue
  - create bridge execution envelope
score: 0.62
