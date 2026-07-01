# Agora Operations Runbooks

Status: PARTIAL  
Runtime: not deployed  
Scope: pre-runtime operating procedures and recovery design.

## Operating states

| State | Meaning | Required evidence |
|---|---|---|
| ASPIRATIONAL | Idea or planned object only | Design note |
| PARTIAL | Built/configured but not fully proven | Artefact receipt |
| BLOCKED | Cannot continue without dependency | Blocker receipt and recovery route |
| REAL | Executed with runtime receipt and telemetry | Runtime receipt, logs, telemetry, validation |

## Incident classes

| Class | Description | Response |
|---|---|---|
| ingestion_failure | Media/comment/source material cannot be imported | retry, validate format, quarantine, emit receipt |
| transcription_failure | Transcript job fails or is low confidence | retry provider, lower model, queue review |
| extraction_failure | Entity/relationship extraction fails | retry with smaller batch, fallback parser, manual review |
| retrieval_failure | Graph/vector search unavailable | degrade to keyword search, mark citation gap |
| debate_failure | Debate engine fails or returns uncited output | rerun with stricter evidence mode, mark output PARTIAL |
| evidence_failure | Receipt or evidence pack generation fails | block publication, regenerate manifest |
| moderation_failure | Safety or publication review unavailable | keep restricted, queue review |
| deployment_failure | Service fails to deploy or health check | rollback, inspect logs, block promotion |

## Runbook: media ingestion failure

Trigger:
- Upload record created but storage reference missing.
- Checksum missing or mismatch.
- Media status stuck in `processing`.

Actions:
1. Mark media asset `BLOCKED`.
2. Emit ingestion failure receipt.
3. Verify source URI exists.
4. Recompute checksum if file present.
5. Retry storage operation.
6. If retry fails, quarantine source and create recovery task.

REAL exit criteria:
- Media status `indexed` or `restricted`.
- Storage receipt exists.
- Checksum receipt exists.

## Runbook: transcription failure

Trigger:
- Transcript job failed.
- Transcript confidence below threshold.
- Transcript created without segments.

Actions:
1. Mark transcript `PARTIAL` or `BLOCKED`.
2. Retry transcription provider.
3. If media is too large, segment media.
4. If language unknown, run language detection.
5. If still failing, queue human review.

REAL exit criteria:
- Transcript has full text or reviewed partial text.
- Segments exist where supported.
- Model/provider receipt exists.

## Runbook: graph extraction failure

Trigger:
- No entities extracted from non-empty transcript/comment set.
- Relationship extraction returns invalid schema.
- Merge creates duplicate or circular canonical entities.

Actions:
1. Validate source text.
2. Reduce batch size.
3. Run deterministic schema parser.
4. Quarantine bad extraction response.
5. Re-run extraction.
6. If unresolved, mark graph build PARTIAL.

REAL exit criteria:
- Entities and relationships have source_refs.
- Merge receipts exist.
- Deprecated/superseded objects retain audit chain.

## Runbook: debate generation failure

Trigger:
- Debate output lacks citations.
- Persona produces unsupported claims.
- Engine times out.

Actions:
1. Reject public publication.
2. Mark debate PARTIAL.
3. Re-run retrieval.
4. Reduce debate rounds.
5. Re-run with citation-required mode.
6. Store uncited claims as gaps, not facts.

REAL exit criteria:
- Debate has citations or explicit evidence gaps.
- Output receipt exists.
- Source refs are traceable to transcript/comment/media/graph objects.

## Runbook: evidence pack failure

Trigger:
- Evidence pack checksum missing.
- Artefact ref cannot be resolved.
- Export does not include receipt chain.

Actions:
1. Block export.
2. Regenerate manifest.
3. Recompute checksums.
4. Validate artefact refs.
5. Rebuild export.

REAL exit criteria:
- Evidence pack manifest exists.
- Checksums exist.
- Receipt chain is complete.

## Promotion gates

| Gate | Requirement |
|---|---|
| local | services start, health checks pass, sample data flows through |
| dev | receipts persist, schema migration applied, telemetry visible |
| staging | tenant isolation verified, export paths verified, failure recovery tested |
| production | 72h survivability, rollback path, cost guardrails, privacy review |

## Runtime telemetry requirements

- service health
- request count
- error count
- latency
- queue depth
- job age
- receipt creation count
- failed receipt count
- storage success/failure
- model call count
- model cost estimate

## Cost guardrails

- No unbounded transcript processing.
- No LLM extraction without input validation.
- No debate generation without max rounds.
- No embedding without tenant/project quota.
- No public export without receipt chain.

## Destructive action policy

Requires HITL:
- production deletion
- credential rotation
- public release claims
- legal/compliance certification language
- irreversible wallet/credential revocation
