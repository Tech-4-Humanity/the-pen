# CKO Runtime Program — POC-03 to POC-07

## Objective

Advance the Canonical Knowledge runtime from proven compilation into translation, policy validation, graph relationships, institutional retrieval and event-driven agent execution.

## Canonical sequence

1. POC-03 Canonical Translation Engine
2. POC-04 Validation and Policy Engine
3. POC-05 Relationship and Knowledge Graph Compiler
4. POC-06 Search and Institutional Memory Interface
5. POC-07 Event-Driven Ingestion and Agent Runtime

## Source baseline

- Supabase project: `jjsycelagfmuquvxryfo`
- Schema: `knowledge_runtime`
- Source CKO: `cko:pdf:7b72f182832a49a6253aea05`
- Source: assureME Compliance Ready Pricing Guide
- Evidence bucket: `t4h-archive-140548542136`
- Region: `ap-southeast-2`

## POC-03 acceptance

- Six versioned translation profiles.
- Six deterministic outputs from one source CKO.
- Source lineage and output SHA-256 on every result.
- Translation telemetry and receipts.
- S3 release, readback and reconciliation.
- Forced invalid-profile failure and recovery.

Profiles:

- `exec-summary-v1`
- `sales-catalog-v1`
- `website-pricing-v1`
- `compliance-safe-v1`
- `partner-summary-v1`
- `audit-summary-v1`

## POC-04 acceptance

- Versioned validation and policy rules.
- Deterministic PASS, FAIL and QUARANTINED decisions.
- Initial rules for disclaimer presence, source lineage, hash presence, prohibited guarantee language, PII and stale evidence.
- Recovery path for a failed disclaimer rule.
- Decision receipts and telemetry.

## POC-05 acceptance

- Versioned relationship types.
- Directed CKO and output relationships.
- Provenance, `derived_from`, `translated_to`, `validated_by`, `depends_on` and `supersedes` edges.
- Duplicate-edge prevention and relationship receipts.
- Impact traversal from source CKO to all derived outputs.

## POC-06 acceptance

- Search index over CKOs, translations, policies and relationships.
- Keyword retrieval with source lineage.
- Semantic-search field contract, with embeddings optional until an approved model is configured.
- Ranked retrieval result receipt.
- Institutional-memory query returning source, translations, validation state, graph links and receipts.

## POC-07 acceptance

- Event registry and ingestion queue.
- Idempotent event key and bounded retry policy.
- Routing across compiler, validator, translator, graph and search stages.
- Agent work-item generation only after validation gates pass.
- Dead-letter state and recovery.
- End-to-end execution receipt.

## Classification rules

- `REAL`: runtime execution, readback, hashes, telemetry and receipt all verified.
- `PARTIAL`: some runtime evidence exists but one or more acceptance gates remain.
- `BLOCKED`: execution attempted and a specific external or configuration dependency prevents completion.
- `ASPIRATIONAL`: design only; no runtime evidence.

No stage may be classified REAL from schema creation or planning alone.