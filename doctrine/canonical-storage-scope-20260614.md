# Canonical Storage Scope

Date: 2026-06-14
Status: PARTIAL until runtime receipts, Supabase registry rows, S3 immutable artefacts, and 72h survivability evidence exist.
Scope: This doctrine is committed so the chat-level operating model survives in GitHub.

## In-scope systems

| System | Role | Authority |
|---|---|---|
| Notion | Human-readable docs, intent, decisions, status, narrative state | Narrative truth |
| Google Drive | Shared working files, research, source capture, handoff artefacts | Working truth |
| Local Mac | Temporary execution/display workspace | No authority |
| S3 | Immutable archive, evidence, retained artefacts | Evidentiary truth |
| Supabase | Canonical index, registry, metadata, lineage, status | System truth |

## Operating rule

All future search, audit, handoff, indexing, and receipt work must treat Notion, Google Drive, local Mac, S3, and Supabase as the default system boundary where tool access permits.

## Authority model

```text
Intent / explanation           -> Notion
Working files / collaboration  -> Google Drive
Temporary execution            -> Local Mac
Immutable evidence             -> S3
Canonical registry             -> Supabase
```

## Evidence classification

| Class | Meaning |
|---|---|
| REAL | Live runtime receipt, telemetry continuity, recovery validation, replay/evidence, economic proof, graph integrity, and 72h unattended runtime evidence exist. |
| PARTIAL | Doctrine, structure, or intent exists, but runtime evidence is incomplete. |
| PRETEND | Claim without evidence. Not accepted as build foundation. |

## Required runtime follow-through

1. Create Supabase registry tables/rows for canonical systems, artefacts, hashes, lineage, status, and receipts.
2. Archive final artefacts to S3 with immutable versioning/evidence metadata.
3. Keep Notion as narrative state and decision log.
4. Keep Google Drive as collaborative working layer and source capture.
5. Treat the local Mac as transient only.
6. Emit runtime receipts under receipts/runtime/ when a worker executes.
7. Promote from PARTIAL to REAL only after telemetry continuity, deterministic recovery, replay validation, graph coherence, economic proof, and 72h unattended survivability pass.

## Non-negotiables

- No PRETEND claims.
- No unindexed final artefacts.
- No long-term authority on local Mac.
- Broken workloads are fixed immediately; 72h survivability starts only after working state.
- HITL only for destructive/legal actions.
