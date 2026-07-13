# Receipt — CalmBound Implementation Artefacts Publication

**Date:** 2026-07-14  
**Repository:** `TML-4PM/the-pen`  
**Branch:** `main`  
**Status:** REAL for generation and GitHub publication; PARTIAL for runtime execution

## Published artefacts

| Artefact | Path | Commit |
|---|---|---|
| Capability Registry v1.0 | `commissions/calmbound/implementation/capability-registry-v1.0.json` | `0c983a8238362ee98e81420859f2261e0450faf9` |
| Household Ontology v1.0 | `commissions/calmbound/implementation/household-ontology-v1.0.json` | `8204c0e0f498f4ed4674a651c5b221c62cc85e72` |
| Event Taxonomy and Envelope v1.0 | `commissions/calmbound/implementation/event-taxonomy-and-envelope-v1.0.json` | `93a82502dc39d39c7cd0aa1edb025c0fab65a362` |
| Permission and Consent Model v1.0 | `commissions/calmbound/implementation/permission-consent-model-v1.0.json` | `f5d3ebdd60ca749114189355b9d9abbef8b8b372` |
| Rule Engine and Mode Registry v1.0 | `commissions/calmbound/implementation/rule-engine-and-mode-registry-v1.0.yaml` | `149bc8f1b6141707be16e0dc2db86372acdc838f` |
| OpenAPI Contract v1.0 | `commissions/calmbound/implementation/openapi-v1.0.yaml` | `f6482a92fb7bf4698a909909a214fbb5ac30c679` |
| Canonical Database Schema v1.0 | `commissions/calmbound/implementation/database-schema-v1.0.sql` | `ba9d50d44c45236991d0e8bfb08294892a0e62a8` |
| Validation and Acceptance v1.0 | `commissions/calmbound/implementation/validation-and-acceptance-v1.0.md` | `4cbbf2a2d79e90b8428965e55b1bcf84b0cc9d2e` |

## Scope completed

- Machine-readable capability registry
- Machine-readable household ontology and graph vocabulary
- Canonical event envelope and event taxonomy
- Permission, authority, consent, expiry and revocation model
- Rule grammar, priority model and initial household mode definitions
- Phase 1 OpenAPI contract
- PostgreSQL/Supabase-compatible canonical schema
- Validation gates and Phase 1 acceptance scenarios
- Explicit evidence requirements for REAL runtime classification

## Truth classification

### REAL

- All listed artefacts were generated.
- All listed artefacts were written to GitHub `main`.
- GitHub returned a commit SHA for every artefact.
- Existing prototype and strategy files were not overwritten or deleted.
- Recovery is available through individual Git reverts.

### PARTIAL

- SQL migration execution
- OpenAPI parser validation
- Runtime services
- Identity provider integration
- Contextual permission enforcement
- Event bus and event ledger execution
- OpenTelemetry traces
- Stripe test and production lifecycle
- Router and device enforcement
- Security, privacy, accessibility and child-impact testing
- Production deployment and household pilot

## Recovery

All writes are additive. Revert any listed commit to remove that artefact. No destructive operation was performed.

## Next executable work

Implement and validate the reference runtime against these contracts. The runtime must not be classified REAL until execution receipts, telemetry, readback verification and recovery evidence exist.

## Truth statement

This receipt proves the missing CalmBound implementation definitions were generated and published. It does not prove that a production runtime, database, payment system, router integration or consumer application is live.
