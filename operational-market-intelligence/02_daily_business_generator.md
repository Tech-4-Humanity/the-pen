# Daily Business Generator

## Aim

Create one new business per day from external news and market signals automatically.

This extends Operational Market Intelligence Orchestration from signal-to-product into signal-to-business creation.

## Operating doctrine

Default loop:

`WORLD_EVENT -> SIGNAL -> PRESSURE -> GAP -> PRODUCT -> BUSINESS_SURFACE -> OFFER -> CAMPAIGN -> LEAD_CAPTURE -> TELEMETRY -> REVENUE_TEST -> REALITY_LEDGER`

## Human loop policy

Phase 1: one human yes/no gate.

The system must generate a daily business candidate and present a concise approval card:

- signal source
- business concept
- target buyer
- pain solved
- first offer
- first landing surface
- expected revenue path
- risks
- kill criteria
- proceed: YES/NO

No long discussion. No open-ended review. One binary gate.

Phase 2: no human loop after quality threshold.

The human gate is removed only after:

- 14 consecutive daily candidates generated
- 10 accepted or auto-acceptable candidates
- 5 launched surfaces or campaign stubs
- no critical brand/safety/legal errors
- measurable telemetry for at least 5 candidates
- Reality Ledger entries complete for all candidates

## Daily sequence

1. Sweep high-trust sources.
2. Score signals by urgency, market pain, regulation, emotional heat, buyer clarity, monetisation speed, and fit with existing assets.
3. Pick top signal or signal cluster.
4. Generate business candidate.
5. Check whether it should be:
   - new standalone business
   - product under existing business
   - campaign wrapper
   - lead magnet
   - internal capability only
6. Create canonical artefacts:
   - business brief
   - offer brief
   - buyer profile
   - risk register
   - first landing copy
   - first campaign copy
   - telemetry plan
   - revenue path
7. Present yes/no card during Phase 1.
8. On yes, push to build queue.
9. On no, archive with reason and feed rejection learning.
10. Write Reality Ledger.

## Candidate scoring

Minimum launch score: 0.78.

Scored dimensions:

- signal strength
- buyer pain
- market urgency
- existing asset leverage
- speed to landing page
- speed to first offer
- regulatory/legal risk
- brand fit
- economic upside
- repeatability

## Hard blockers

Do not auto-launch if:

- legal advice is required
- medical advice is implied
- financial advice is implied
- regulated credentialing is required
- spend exceeds approved threshold
- domain purchase/payment required
- use of protected third-party identity/brand creates risk

In those cases, create a gated candidate and preserve all non-blocked artefacts.

## First application

ABC NDIS fraud article should generate either:

1. Outcome Ready Plan Protection Pack, if treated as product expansion.
2. NDIS Integrity Shield, if treated as a standalone business surface.
3. Provider Trust Ledger, if treated as a B2B compliance/assurance product.

Recommended first candidate: NDIS Integrity Shield.

Reason: this converts fraud news into a clear trust/compliance business surface while still reusing Outcome Ready assets.

## Reality classification

Status: PARTIAL

Reason: doctrine and artefact are committed. Runtime sweeps, candidate scoring, human gate UI, telemetry, and launch automation still require bridge deployment and proof.
