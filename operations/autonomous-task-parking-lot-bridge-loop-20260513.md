# Autonomous Task Parking Lot with Bridge Loop

Date: 2026-05-13
Status: Runtime Candidate
Owner: Tech 4 Humanity ecosystem
Source: Grok thread / Command Centre continuity discussion

## Executive Summary

The current ecosystem is leaking knowledge, tasks, decisions, documents, and intent. The result is operational entropy: the founder loses thinking capacity because unfinished work, decisions, documents, and code pathways do not reliably carry forward.

This spec defines the missing operating layer:

- Autonomous Task Parking Lot
- Daily Document Sweeper
- Intent Capture Engine
- Job Carry-Forward Loop
- Dev/Prod Stage Gate Refreeze
- Runners and Sweepers Registry
- Reporting and Writing Workers
- Command Centre Continuity Surface
- Bridge/PEN handoff loop with receipts

The principle is simple:

Nothing important should quietly drift.

That must become code, not a slogan.

## Problems Identified

1. No active institutional memory

The system cannot reliably remember where things are, what has been built, what is a copy, what is a new product, what belongs in dev, and what should not go to prod.

2. Dev does not know clone vs product

A worker in development has no reliable way to know whether it is seeing:

- a copy
- a fork
- a duplicate
- an experiment
- a new product
- an already-existing product under a new wrapper

3. Not enough runners

There are not enough autonomous execution workers to move tasks through inspect > action > receipt > evidence.

4. Not enough sweepers

There are not enough sweepers scanning documents, repos, deployments, chats, downloads, and dashboards to bring back knowledge.

5. Reporting is missing

There is no consistent high-value reporting layer that tells the founder what matters, what changed, what is blocked, and what must be decided.

6. Writing is missing

There is no reliable writing layer turning raw threads, ideas, documents, reports, and decisions into usable assets.

7. Data is leaking everywhere

Documents, decisions, code, artefacts, chat threads, downloads, deployment notes, and product ideas are being created daily but not consistently indexed, summarised, tagged, and routed.

8. The seven-day pilot does not test anything by itself

A passive seven-day wait does not prove the system. The system must be used daily and must surface jobs from today/tomorrow as part of an active test.

9. Stage gates are broken

Nothing should go to production through the normal process until dev/prod gates are repaired. Refreeze is active.

## Required System Behaviour

The system must:

- capture tasks as soon as they appear
- classify intent correctly
- park unfinished work safely
- surface open jobs daily
- sweep new documents daily
- distinguish dev from prod
- detect duplicates and wrappers
- route work to Bridge/PEN/Dev/Prod correctly
- prevent accidental production pushes
- produce useful reports
- generate writing assets
- store receipts
- show status in Command Centre

## Core Objects

### Task

A unit of work extracted from chat, documents, repos, dashboards, or human instruction.

Fields:

- task_id
- source_type
- source_url_or_path
- captured_at
- owner
- business
- product
- wrapper
- intent
- requested_action
- status
- priority
- due_date
- carry_forward
- blocked_reason
- evidence_required
- receipt_ids
- next_action

### Intent

The meaning of the task.

Intent classes:

- WRITE
- BUILD
- FIX
- DEPLOY
- AUDIT
- SWEEP
- REPORT
- CLASSIFY
- ROUTE
- REMEMBER
- ESCALATE
- FREEZE
- PROMOTE
- RETIRE
- MONETISE

### Parking Lot

The canonical holding area for unfinished tasks.

Rules:

- every open task must have a next_action
- no task can sit without status
- stale tasks must be surfaced
- blocked tasks require bounded blockers
- tasks created today must be available tomorrow
- repeated tasks must be deduplicated or linked

### Sweeper

An autonomous worker that scans a source and extracts tasks, decisions, signals, and gaps.

Required sweepers:

- Document Sweeper
- GitHub Sweeper
- Vercel Sweeper
- Chat/Thread Sweeper
- Download Sweeper
- Command Centre Sweeper
- Revenue/Stripe Sweeper
- Stage Gate Sweeper

### Runner

An autonomous worker that moves tasks through execution.

Required runners:

- Bridge Runner
- PEN Runner
- Dev Runner
- Smoke Test Runner
- Report Runner
- Writing Runner
- Evidence Runner
- Recovery Runner

## Daily Document Sweeper

The highest-return immediate sweeper.

Purpose:

We are creating hundreds of documents and downloads daily but getting little knowledge back out of them. The Document Sweeper must turn document creation into reusable institutional memory.

Daily tasks:

1. Scan newly created/modified documents
2. Extract decisions, tasks, product ideas, risks, requirements, and receipts
3. Classify by business, product, wrapper, and intent
4. Detect duplicates and unfinished items
5. Push tasks into Parking Lot
6. Push knowledge into Memory Register
7. Flag urgent items for Morning Brief
8. Produce daily document sweep report

Outputs:

- document_sweep_report
- extracted_tasks
- extracted_decisions
- extracted_products
- duplicate_candidates
- bridge_ready_payloads
- memory_register_updates

## Morning and Evening Continuity Briefs

The brief must not be generic.

Morning Brief must include:

- unfinished jobs from yesterday
- jobs created today/overnight
- blocked jobs needing decision
- prod risks
- revenue opportunities
- stale tasks
- document sweep findings
- top three actions

Evening Brief must include:

- what changed today
- what was completed
- what remains open
- what should carry forward
- what needs Bridge/PEN/Dev/Prod
- evidence receipts
- next morning queue

Phrase upgrade:

Nothing important should quietly drift — including unfinished jobs from yesterday.

## Refreeze / Stage Gate Rules

Refreeze is active until stage gates are fixed.

Rules:

- do not push to prod by default
- dev changes must be classified before promotion
- every promotion must have evidence
- production requires approval gate unless explicitly autonomous-safe
- duplicate/copy/product status must be known before deployment
- smoke tests required before prod
- rollback path required before prod
- Reality Ledger receipt required after prod

Stage gates:

1. Intake
2. Classification
3. Dev Build
4. Dev Smoke Test
5. Evidence Check
6. Promotion Review
7. Prod Deploy
8. Prod Smoke Test
9. Reality Ledger Receipt
10. Monitoring / Recovery

## Intent Capture Engine

Getting intents right in code is the hard part. This system must treat intent classification as a first-class runtime component.

Intent capture must identify:

- what the human wants
- what system should act
- whether this is a write/build/fix/deploy/audit/sweep/report/remembrance task
- whether prod is allowed
- whether Bridge is required
- whether GitHub/PEN is the right surface
- whether human approval is required
- what evidence is needed

Intent output:

```json
{
  "intent_class": "BUILD|WRITE|FIX|DEPLOY|AUDIT|SWEEP|REPORT|CLASSIFY|ROUTE|REMEMBER|ESCALATE|FREEZE|PROMOTE|RETIRE|MONETISE",
  "business": "string",
  "product": "string",
  "wrapper": "string",
  "environment": "dev|prod|unknown|not_applicable",
  "risk_level": "low|medium|high|critical",
  "requires_human": true,
  "requires_bridge": true,
  "evidence_required": ["commit", "url", "runtime_log", "receipt"],
  "next_action": "string"
}
```

## Command Centre Improvements

Command Centre should become the active cockpit for continuity, not just a dashboard.

New widgets required:

1. Parking Lot

Shows open tasks, stale tasks, blocked tasks, and carry-forward queue.

2. Today/Tomorrow Jobs

Shows jobs from today that must be brought forward tomorrow.

3. Document Sweeper Pulse

Shows documents scanned, tasks extracted, decisions found, duplicates detected.

4. Stage Gate Board

Shows what is in intake, dev, smoke test, promotion, prod, blocked, and recovered.

5. Runner/Sweeper Health

Shows last run, next run, failure count, and receipts.

6. Memory Leak Monitor

Shows unclassified artefacts, orphan docs, orphan deployments, orphan repos, and lost decisions.

7. Writing Queue

Shows items that need articles, reports, product pages, campaign copy, or bridge docs.

8. Reporting Queue

Shows briefs, weekly reports, campaign reports, revenue reports, and status reports.

## Bridge Loop

Every significant task must be bridge-ready.

Loop:

1. Capture intent
2. Classify task
3. Park task
4. Assign runner/sweeper
5. Execute where possible
6. Store receipt
7. Update status
8. Surface result in Command Centre
9. Carry forward unfinished work

## Supabase Schema Draft

Tables:

- task_parking_lot
- task_intents
- task_events
- task_receipts
- memory_register
- document_sweep_runs
- document_sweep_items
- runner_registry
- sweeper_registry
- stage_gate_items
- continuity_briefs
- command_centre_widgets
- reality_ledger_bindings

## Acceptance Criteria for REAL

This system is REAL only when:

- tasks are captured into a live table
- at least one Document Sweeper run is evidenced
- unfinished jobs carry into the next brief
- Command Centre shows Parking Lot widget
- stage gate board exists
- at least one Bridge/PEN handoff is created from a parked task
- receipts are stored
- stale tasks are detected
- prod gate prevents unsafe promotion

Until then, status is PARTIAL / Runtime Candidate.

## Immediate Build Plan

1. Create task_parking_lot schema
2. Create intent taxonomy seed
3. Create document_sweeper spec and runner payload
4. Create Parking Lot Command Centre widget spec
5. Create Morning/Evening Brief templates
6. Create stage gate schema
7. Create bridge handoff payload
8. Create execution issue in PEN
9. Run first document sweep
10. Produce first carry-forward brief

## Reality Ledger

status: PARTIAL
result: Autonomous Task Parking Lot + Bridge Loop specified and ready for runtime implementation
evidence: GitHub file commit required
gaps: no live Supabase tables, no active sweeper, no Command Centre widget, no runtime receipts yet
next_action: create execution issue and deploy schema/widget via Bridge
elevation: converts drifting chats/documents/jobs into an active operational memory and execution surface
pressure_flags: high entropy, memory leakage, missing reporting, broken stage gates
score: 0.86
