# Time Allocation Engine — Spine Pack v1

status: PARTIAL
created: 2026-05-24
repo: TML-4PM/the-pen
runtime_class: signal-to-cost attribution engine

## Purpose

The Time Allocation Engine turns observed work signals into evidence-backed time, cost, and resource allocation records.

It is not a manual timesheet. It is an autonomous attribution layer that listens to work signals, classifies activity, allocates time across projects, and binds each allocation to evidence.

```text
conversation / browser / document / repo / receipt / voice / calendar / email
  -> signal_event
  -> activity_event
  -> allocation_decision
  -> project_time_ledger
  -> cost_allocation_ledger
  -> research / product / finance / audit reporting
```

## Product registration

product_id: time-allocation-engine
product_name: Time Allocation Engine
aliases: Observed Work Truth, Signal Timesheet, Resource Allocation Spine, Autonomous Timesheeting Engine
portfolio_location: AI Sweet Spots Research Hub, Self-Employed OS, WorkFamilyAI, FAR-CAGE, Reality Ledger, Command Centre
primary_use_cases: autonomous timesheeting, R&D evidence support, project cost apportionment, resource allocation, research costing, agent/human effort comparison, pricing and margin intelligence, portfolio economics

## Research registration

research_stream_id: observed-work-truth
research_questions:
- How accurately can work effort be inferred from live activity signals?
- Which signals are reliable enough for cost allocation?
- How should split attention be allocated across multiple projects?
- What confidence threshold is acceptable for finance, audit, and management reporting?
- How much invisible work leakage exists across the ecosystem?
- Which activities create the highest economic leverage per hour?

## Required runtime services

- signal-ingestor: normalise raw events into signal_event
- activity-classifier: convert signals into activity_event candidates
- allocation-engine: split time across projects/categories using confidence weights
- cost-engine: apply rates, overheads, project funding rules, and cost sharing
- evidence-binder: attach receipts, hashes, URLs, and supporting artefacts
- leakage-detector: detect uncategorised or low-confidence work time
- reviewer: flag low-confidence allocations for later correction
- command-centre-widget: surface today/week/project/cost/confidence views

## Canonical schema

```sql
create table if not exists signal_event (
  id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz not null,
  source text not null,
  actor_id text,
  session_id text,
  raw_ref text,
  raw_hash text,
  title text,
  url text,
  payload jsonb not null default '{}',
  topic_vector jsonb,
  project_mentions text[] default '{}',
  confidence numeric not null default 0.5,
  created_at timestamptz not null default now()
);

create table if not exists project_registry (
  id text primary key,
  name text not null,
  portfolio text,
  parent_project_id text references project_registry(id),
  funding_stream text,
  cost_centre text,
  default_rate_aud numeric,
  r_and_d_eligible boolean default false,
  active boolean default true,
  metadata jsonb not null default '{}'
);

create table if not exists activity_event (
  id uuid primary key default gen_random_uuid(),
  started_at timestamptz not null,
  ended_at timestamptz not null,
  actor_id text,
  session_id text,
  activity_type text not null,
  description text,
  source_signal_ids uuid[] not null default '{}',
  classifier_version text not null,
  confidence numeric not null,
  evidence_grade text check (evidence_grade in ('A','B','C','D')) default 'C',
  created_at timestamptz not null default now()
);

create table if not exists allocation_decision (
  id uuid primary key default gen_random_uuid(),
  activity_event_id uuid not null references activity_event(id),
  project_id text not null references project_registry(id),
  category text not null check (category in ('research','development','admin','sales','delivery','governance','finance','support','learning','other')),
  allocation_ratio numeric not null check (allocation_ratio >= 0 and allocation_ratio <= 1),
  allocated_seconds int not null,
  confidence numeric not null,
  allocation_method text not null,
  rationale text,
  model_version text not null,
  created_at timestamptz not null default now()
);

create table if not exists cost_allocation_ledger (
  id uuid primary key default gen_random_uuid(),
  allocation_decision_id uuid not null references allocation_decision(id),
  project_id text not null references project_registry(id),
  cost_category text not null,
  rate_aud numeric not null,
  allocated_hours numeric not null,
  allocated_cost_aud numeric not null,
  overhead_rate numeric default 0,
  total_cost_aud numeric not null,
  funding_stream text,
  cost_centre text,
  r_and_d_claimable boolean default false,
  created_at timestamptz not null default now()
);

create table if not exists time_evidence (
  id uuid primary key default gen_random_uuid(),
  allocation_decision_id uuid references allocation_decision(id),
  signal_event_id uuid references signal_event(id),
  evidence_type text not null,
  evidence_url text,
  evidence_hash text,
  evidence_grade text check (evidence_grade in ('A','B','C','D')) default 'C',
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists allocation_test_case (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  fixture jsonb not null,
  expected_allocations jsonb not null,
  tolerance numeric default 0.1,
  status text default 'pending',
  result jsonb,
  created_at timestamptz not null default now()
);
```

## Allocation model

Project weight:

```text
0.25 active_window_score
+ 0.20 semantic_topic_score
+ 0.20 explicit_project_mention_score
+ 0.15 repository_or_file_match_score
+ 0.10 calendar_context_score
+ 0.10 receipt_or_task_match_score
```

Normalise all candidate project weights so total allocation ratio equals 1.0.

Confidence tiers:
- 0.90 to 1.00: approved ledger write
- 0.75 to 0.89: ledger write with sample review
- 0.55 to 0.74: provisional allocation
- below 0.55: leakage bucket / unresolved

Evidence grades:
- A: contemporaneous source proof such as commit, receipt, calendar event, document edit log, payment object
- B: system-generated logs such as browser telemetry, chat metadata, Drive metadata, email headers
- C: reconstructed summaries, classifier inference, aggregated topic vectors
- D: human memory or unsupported assertion

Finance/audit outputs require A or B support. C can enrich. D cannot anchor a claim.

## Test plan

1. Single project clean signal: one chat, one repo, one document all point to AI Sweet Spots. Expected allocation 95%+.
2. Split project work: one session supports Reading Buddy, AI Sweet Spots, and MyNeuralSignal. Expected proportional allocation.
3. Admin leakage: folder cleanup with no specific project. Expected shared overhead/admin, no false R&D claim.
4. Cost sharing: shared platform work used by five brands. Expected weighted split, total cost conserved.
5. Audit threshold: semantic-only evidence. Expected provisional status, not finance/audit truth.
6. Human correction: correction creates superseding allocation decision and preserves original.
7. Receipt binding: bridge/task receipt links to allocation as A-grade evidence.

## Command Centre widget

Widget name: Time Intelligence

Views:
- Today by project
- Today by category
- Week by project
- Cost by project
- R&D eligible time
- Leakage / uncategorised time
- Confidence distribution
- Evidence grade distribution
- Top invisible cost drivers

Cards:
- today_allocated_hours
- today_uncategorised_hours
- confidence_score
- highest_cost_project
- r_and_d_supported_hours
- leakage_percent
- evidence_grade_mix

## Deployment envelope

```json
{
  "task_id": "TAE-SPINE-DEPLOY-2026-05-24",
  "intent": "Deploy Time Allocation Engine as signal-to-cost attribution service",
  "target_spine": ["the-pen", "bridge", "command-centre", "notion", "supabase", "github"],
  "assets": {
    "repo": "TML-4PM/the-pen",
    "path": "spine/time-allocation-engine/00_time-allocation-engine-spine-pack.md",
    "schemas": ["signal_event", "activity_event", "allocation_decision", "cost_allocation_ledger", "time_evidence", "allocation_test_case"],
    "widget": "Time Intelligence",
    "product_id": "time-allocation-engine",
    "research_stream_id": "observed-work-truth"
  },
  "actions": [
    "create_supabase_tables",
    "seed_project_registry",
    "deploy_signal_ingestor",
    "deploy_activity_classifier",
    "deploy_allocation_engine",
    "deploy_cost_engine",
    "deploy_command_centre_widget",
    "create_test_fixtures",
    "run_initial_tests",
    "emit_reality_ledger_receipt"
  ],
  "success_criteria": {
    "tables_created": true,
    "widget_registered": true,
    "at_least_7_tests_created": true,
    "at_least_5_tests_passing": true,
    "sample_allocation_written": true,
    "receipt_written": true
  }
}
```

## Starter project registry seeds

- ai-sweet-spots: AI Sweet Spots, Research/Product, R&D eligible
- myneuralsignal: MyNeuralSignal, Signal/Neurotech, R&D eligible
- lifegraph-plus: LifeGraph+, Signal/Identity/Longitudinal Data, R&D eligible
- reading-buddy: Reading Buddy, Outcome Ready, R&D eligible
- outcome-ready: Outcome Ready, Product/Services
- workfamilyai: WorkFamilyAI, Workforce/Org Intelligence, R&D eligible
- gcbat: GC-BAT, Governance/Audit, R&D eligible
- consentx: ConsentX, Consent/Governance, R&D eligible
- far-cage: FAR-CAGE, Evidence/Reality Ledger, R&D eligible
- portfolio-admin: Portfolio Admin, Shared Services

## Operating rules

1. Never overwrite history. Corrections create superseding allocation decisions.
2. Never claim finance/audit truth without A/B grade evidence.
3. Split costs by benefit, not by arbitrary equal share, unless no better signal exists.
4. Low confidence does not block capture; it blocks final claim status.
5. Uncategorized time is itself a tracked cost signal.
6. The engine must support both human and agent work.
7. Every allocation must explain why it was assigned.
8. Every cost must reconcile to time, rate, and allocation ratio.
9. Every weekly report must show leakage.
10. Every deploy must emit a Reality Ledger receipt.

## First build backlog

P0:
- create Supabase schema
- seed project registry
- implement allocation algorithm v0.1
- create sample fixtures
- write first allocation rows
- create Reality Ledger receipt

P1:
- connect GitHub signals
- connect chat/LLM export signals
- connect Drive document metadata
- connect task/receipt records
- register Command Centre widget

P2:
- browser focus collector
- voice transcript collector
- calendar/email collector
- finance export pack
- weekly audit pack

## Reality Ledger

status: PARTIAL
result: Time Allocation Engine specified, registered as a product/research stream candidate, and prepared for deployment.
evidence:
- GitHub spine pack file in TML-4PM/the-pen
- Notion registration target identified: AI Sweet Spots Research Hub / Self-Employed OS Bridge Execution Pack
- Connector discovery confirmed GitHub, Notion, Drive, Vercel, Stripe available
- Runtime schema, tests, deployment envelope, and command-centre widget spec included

gaps:
- direct Bridge endpoint is not exposed as a callable connector in this session
- Supabase runtime is not directly exposed in this session
- Command Centre target repo/path not yet confirmed from connector search
- no deployed worker receipt yet
- no live sample allocations written yet

next_action:
- create GitHub issue as deployment ticket
- create Notion registration receipt under AI Sweet Spots Research Hub / Self-Employed OS
- apply SQL through available runtime executor
- run 7 allocation tests and emit receipts

score: 0.78
