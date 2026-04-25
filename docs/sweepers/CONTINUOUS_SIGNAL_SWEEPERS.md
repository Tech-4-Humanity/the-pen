# Continuous Signal Sweepers

Status: queued for worker execution
Owner: T4H / Pen worker
Created by: ChatGPT
Date: 2026-04-26

## Purpose

Continuously mine past LLM chats, selected documents, Drive exports, meeting transcripts, GitHub activity, Notion/docs, and relevant external sources for high-value information, repeated intent, system gaps, product opportunities, risks, and executable work.

This is not passive storage. This is a repeating signal extraction and job-generation system.

## Active sweeper jobs

| ID | Inbox file | Action | Purpose | Status |
|---|---|---|---|---|
| 001 | `inbox/sweeper-llm-doc-signal-seed-001.json` | `sweeper.seed_signal_corpus` | Seed corpus from Google Drive export folder | queued |
| 002 | `inbox/sweeper-llm-chat-ingest-002.json` | `sweeper.ingest_llm_chats` | Exhaustive LLM chat ingestion | queued |
| 003 | `inbox/sweeper-external-enrich-003.json` | `sweeper.external_enrichment` | Enrich extracted entities from external sources | queued |
| 004 | `inbox/sweeper-permutation-engine-004.json` | `sweeper.generate_permutations` | Generate ranked candidate jobs from signals | queued |
| 005 | `inbox/sweeper-audit-queue-receipts-005.json` | `sweeper.audit_queue_and_receipts` | Validate queue pickup, audit rows, and receipts | queued |
| 006 | `inbox/sweeper-continuous-loop-006.json` | `sweeper.install_continuous_loop` | Install/verify recurring loop or self-requeue fallback | queued |

## Seed source

Google Drive folder:
`https://drive.google.com/drive/u/0/folders/1nMN2CLTpiIwrxdjN_nce3J5cb-bZNCBk`

Observed top-level corpus includes LinkedIn/export-style files and folders:

- `messages.csv`
- `Inferences_about_you.csv`
- `SearchQueries.csv`
- `LearningCoachMessages.csv`
- `learning_coach_messages.csv`
- `learning_role_play_messages.csv`
- `guide_messages.csv`
- `Comments.csv`
- `Reactions.csv`
- `Saved_Items.csv`
- `Profile Summary.csv`
- `Profile.csv`
- `Positions.csv`
- `Skills.csv`
- `Education.csv`
- `Publications.csv`
- `Connections.csv`
- `Company Follows.csv`
- `Ad_Targeting.csv`
- `Security Challenges.csv`
- `Logins.csv`
- nested folders: `Jobs`, `Articles`, `Services Marketplace`, `Verifications`

## Operating pattern

All execution follows the T4H inbox pattern:

```text
LLM / operator
  -> commit JSON to inbox/<idempotency_key>.json
  -> Pen GitHub Action / worker picks up
  -> worker executes bridge/job
  -> receipt written to receipts/runtime/
  -> audit.log row written
```

## Cadence

| Loop | Cadence | Purpose |
|---|---:|---|
| inventory delta | hourly | Detect changed files, new chats, new docs, new source hashes |
| deep extract | daily | Extract entities, intent, risks, jobs, product ideas, decisions |
| external enrichment | daily after extract | Validate/enrich only extracted entities |
| permutation generation | daily after enrichment | Generate candidate jobs from signal combinations |
| receipt audit | hourly | Detect missing receipts, stuck jobs, worker failures |
| full resweep | weekly | Re-run full graph and drift checks |

If native cron is unavailable, the loop must self-requeue using inbox tick jobs:

```text
inbox/sweeper-continuous-loop-tick-{iso_date_hour}.json
idempotency_key = sweeper-continuous-loop-tick-{iso_date_hour}
```

## Extraction targets

The sweepers must extract:

- repeated user intent
- explicit instructions and constraints
- product/business ideas
- system names and components
- URLs and surfaces
- people, companies, tools, partners
- risks, blockers, security concerns
- orphaned code or assets
- stale docs or contradictions
- candidate jobs for WIP/PEN
- missing onboarding/system knowledge
- commercial opportunities
- relationship and network signals
- agent routing requirements

## Signal graph layers

| Layer | Examples |
|---|---|
| identity | profile, skills, history, preferences |
| intent | repeated wants, decisions, goals |
| capability | what the system can/cannot do |
| product | offers, markets, customers, assets |
| infra | bridge, Pen, WIP, Supabase, Vercel, GitHub |
| ops | receipts, audit rows, failures, retries |
| commercial | leads, ICP, campaigns, partnerships |
| trust/security | credentials, RLS, legal, IAM, privacy |
| relationships | contacts, companies, follows, messages |
| memory/context | chat threads, summaries, decisions, handoffs |

## Job emission rules

Emit a candidate job only when:

- source evidence exists
- confidence >= 0.6
- value >= 0.7
- security/compliance issues are always emitted regardless of commercial value
- duplicates are blocked by idempotency keys
- completed jobs are not repeated unless source hashes changed

## Safety rules

- Originals are read-only
- Archive, never delete
- Redact private contact details and credentials in summaries
- Do not publish sensitive personal data
- No external outreach without human gate
- Human gate required for delete, deploy, RLS, IAM, credentials, payments, legal action, external outreach

## Definition of done

The sweeper set is done when:

1. all six inbox jobs exist on `main`
2. worker observes or claims each job
3. receipts are written under `receipts/runtime/`
4. audit rows exist for completed jobs
5. continuous loop manifest exists
6. missing/failed jobs are listed with retry actions
7. candidate jobs are generated into WIP/PEN pathways
8. no original source files are mutated

## Expected artifacts

- `inventory.jsonl`
- `source_hashes.jsonl`
- `signal_entities.jsonl`
- `signal_edges.jsonl`
- `thread_index.jsonl`
- `topic_splits.jsonl`
- `memory_signals.jsonl`
- `entity_enrichment.jsonl`
- `candidate_jobs_ranked.jsonl`
- `queue_status.json`
- `receipt_trace.json`
- `loop_manifest.json`
- `last_run_state.json`
- `audit_summary.md`

## Current proof commits

| Job | Commit |
|---|---|
| 001 seed corpus | `3523f0de59b064bf0c3dc0fb202e744900ec0fbd` |
| 002 chat ingest | `c80af075ed35a440e5fb312a09eac0b28f640df6` |
| 003 external enrich | `7edf599819e30e32dccda9ca8a5d3d164ebc5eb3` |
| 004 permutation engine | `c0098dd301f548fc039c03653b2c59532a540ab3` |
| 005 queue/receipt audit | `afc95daa5e2c8eea7037e2163b0eff781627004a` |
| 006 continuous loop | `ab8d30d917730d604f1e64d57ef031acdf096987` |

## Next worker action

The worker must process `sweeper-audit-queue-receipts-005` first if there is any uncertainty, then process or verify the continuous loop installer `sweeper-continuous-loop-006`.

If jobs are stuck, emit a repair job rather than asking the human to manually inspect.
