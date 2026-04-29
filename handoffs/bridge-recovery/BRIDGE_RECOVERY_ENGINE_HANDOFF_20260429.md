# Bridge Recovery Engine Handoff — 2026-04-29

## Purpose

This package exists because local sandbox/download handoff failed and the Bridge/PEN ecosystem needs a durable, visible, GitHub-native artefact in `TML-4PM/the-pen`.

The user asked to complete and send to the PEN. This file is the canonical handoff record for the Bridge Recovery Engine work, including the audit findings, operating rules, folder model, schema, runbook, and next execution actions.

## Source Context

A previous local delivery produced a `bridge-engine.tar.gz` bundle in the assistant sandbox. That failed on the user's Mac because the archive was not present in `~/Downloads`, comments were pasted into zsh, and scripts were not present in `~/the-pen/scripts/bridge/`.

The correct recovery is therefore: stop relying on local ephemeral files and persist the package into GitHub directly.

## Core Findings

- `TML-4PM/the-pen/inbox` contained 49 items when checked from the user's Mac.
- `TML-4PM/the-pen/bridge_jobs` contained 4 items.
- The observed gap is therefore 45 items that landed in inbox but did not cross into the bridge jobs path.
- Earlier PEN ingest summary showed 38 jobs found, with 32 invalid due to missing `origin` and `destination`.
- The broader Bridge universe spans more than the PEN: `mcp-command-centre`, `bridge-runner`, `bridge-worker-intake`, `t4h-remote-mcp-server-clean`, `symbio-dev-control-plane`, `symbio-synapse-ops`, `neural-ennead-dashboard`, `holo-org`, `troy-fire-orchestrator`, and related product repos.
- The phrase “sent to bridge” has been used loosely for staged jobs, payload files, handoff markdown, workflow triggers, MCP payloads, manual receipts, and runtime execution. These are not the same.

## Truth Rule

`sent to bridge` means CAPTURED only unless there is a runtime receipt.

Classification:

| Evidence | Status |
|---|---|
| No file anywhere | PRETEND |
| File exists, no receipt | PARTIAL |
| Receipt exists, no runtime proof | PARTIAL |
| Runtime receipt + execution log | REAL |

Only runtime receipt plus execution evidence is REAL.

## Canonical Layer Names

| Layer | Canonical Name | Role |
|---|---|---|
| PEN | the-pen | Pre-dev holding, triage, repair, staging. No direct prod path. |
| DEV | Symbio | Build, test, promote to prod or return to PEN/Bridge. |
| BRIDGE | bridge | Polymorphic: relay, fixer, dev, or prod-backup depending on context. |
| PROD | Synapse | Live: Vercel, Lambda, Supabase. Only Symbio or Bridge promotes here. |

`mee` is a product/personal employment engine, not an infrastructure layer.

## Folder Model for the-pen

```text
inbox/               staged or recovered jobs
bridge_ready/        valid jobs ready for execution
bridge_jobs/         existing bridge job path, preserved for compatibility
repair/              invalid schema or repair-required items
investigate/         unknown/orphan jobs
rebuild/             claimed but not found
receipts/runtime/    execution/runtime receipts
receipts/validation/ schema/staging receipts
receipts/system/     sweeps, audits, cron receipts
handoffs/            cross-system handoff payloads
ledger/              append-only truth copy
logs/                local and GitHub audit outputs
logs/llm_in/         imported JSONL from ChatGPT/Claude/Perplexity/etc.
```

## Minimum Valid Bridge Job Schema

```json
{
  "origin": "chatgpt|claude|perplexity|system|github|unknown",
  "destination": "the-pen|bridge|symbio|synapse|mcp-command-centre|bridge-runner|unknown",
  "idempotency_key": "stable-unique-key",
  "status": "queued|captured|repair|investigate|runtime_proven",
  "payload": {},
  "source_chat_title": "optional but strongly recommended",
  "source_thread_key": "optional but strongly recommended",
  "llm_actor": "ChatGPT|Claude|Perplexity|System|Unknown",
  "claim_phrase": "sent to bridge|pushed|moved|updated|wrapped|handoff",
  "created_at": "ISO-8601 timestamp"
}
```

## Required Engine Behaviour

1. Catch all artefacts across recent GitHub activity and optional LLM exports.
2. Normalize to the minimum bridge job schema.
3. Write registry before routing.
4. Route valid jobs to `bridge_ready/`.
5. Route invalid jobs to `repair/` with `repair_reason`.
6. Route unknown/orphan records to `investigate/`.
7. Emit validation/system receipts for sweeps.
8. Never call something REAL until runtime receipt exists.
9. Preserve old paths (`bridge_jobs/`) while introducing canonical `bridge_ready/`.
10. Avoid local-only artefacts as final handoff; everything durable goes to GitHub.

## Immediate Execution Actions

Create the following files next under `scripts/bridge/`:

- `config.sh`
- `run.sh`
- `catch.sh`
- `normalize.sh`
- `route.sh`
- `replay.sh`
- `receipt.sh`
- `query.sh`
- `schema.json`

Create workflow:

- `.github/workflows/bridge-recovery.yml`

Create docs:

- `docs/bridge/BRIDGE_RECOVERY_ENGINE_ARCHITECTURE.md`
- `docs/bridge/BRIDGE_SCHEMA_LOCK.md`

## Local Mac Run Instructions Once Scripts Exist

Paste commands only, not comments:

```bash
cd ~/the-pen
git pull
chmod +x scripts/bridge/*.sh
WINDOW=72h ./scripts/bridge/run.sh
```

Live count commands:

```bash
gh api repos/TML-4PM/the-pen/contents/inbox | jq length
gh api repos/TML-4PM/the-pen/contents/bridge_ready | jq length
gh api repos/TML-4PM/the-pen/contents/bridge_jobs | jq length
gh api repos/TML-4PM/the-pen/contents/repair | jq length
gh api repos/TML-4PM/the-pen/contents/investigate | jq length
gh api repos/TML-4PM/the-pen/contents/receipts/runtime | jq length
```

## Hard Blockers Remaining

- Runtime execution is not proven by this handoff alone.
- GitHub connector can create files but does not directly run local Mac scripts.
- Existing jobs still need schema normalization and replay.
- Current proof status of this package is PARTIAL until scripts and runtime receipts are committed and executed.

## Required Next Status

After scripts are committed and workflow exists:

- Handoff package: REAL as GitHub artefact.
- Recovery engine code: PARTIAL until run.
- Runtime execution: REAL only when `receipts/runtime/*.json` shows execution proof.

## Receipt

This file is the durable PEN receipt for the handoff request: complete and send to the PEN.
