# TAB-DRAIN EVENT-DRIVEN REGISTER PACK

## Intent
Compile and wrap the tab_drain upgrade into a single executable handoff: always-on, event-driven, Pen/Dev routed, Reality Ledger bound, monetisation aware.

## Source artifacts
- Uploaded `tab_drain.html` local app
- Screenshot state: 56 remaining, 8 review, 44 register, 4 library
- GitHub issues: #69 core system, #70 bulk register, #71 event-driven routing

## Required final behaviour
Every tab/bookmark/doc/chat/deploy URL becomes an event. The UI is not the system. The event stream is the system.

## Event states
RAW -> TRIAGE -> REGISTERED -> DEV_ROUTED -> EXECUTING -> EVIDENCE_BOUND -> REAL -> MONETISED -> AUTOMATED -> ARCHIVED

## Immediate routing rule
All REVIEW and REGISTER items from the current session become REGISTERED and route to Pen/Dev. LIBRARY items become KNOWLEDGESET and still emit events. Nothing sits idle.

## Event payload contract
```json
{
  "event_id": "uuid",
  "event_type": "tab.item.registered",
  "source": "tab_drain",
  "source_session": "bookmarks_09_05_2026 - tool tezt 2",
  "source_bucket_original": "REVIEW|REGISTER|LIBRARY|ARCHIVE|KILL",
  "target_state": "REGISTERED",
  "target_system": "pen_dev",
  "execution_mode": "EXTRACT_THEN_ROUTE",
  "owner_agent": "portfolio_intake_agent",
  "reality_status": "PARTIAL",
  "evidence_required": true,
  "monetisation_flag": true,
  "payload": {
    "title": "string",
    "url": "string",
    "domain": "string",
    "business_id": "optional",
    "product_id": "optional",
    "value_score": 0,
    "signal_score": 0,
    "reuse_score": 0,
    "monetisation_score": 0
  }
}
```

## Supabase event table
```sql
create table if not exists public.tab_drain_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  session_id uuid,
  item_id uuid,
  source text not null default 'tab_drain',
  target_system text not null default 'pen',
  routing_state text not null default 'PENDING' check (routing_state in ('PENDING','ROUTED','ACKED','FAILED','BLOCKED')),
  payload jsonb not null default '{}'::jsonb,
  evidence_required boolean default true,
  monetisation_flag boolean default false,
  created_at timestamptz default now(),
  routed_at timestamptz,
  receipt_url text,
  error text
);

create index if not exists tab_drain_events_state_idx on public.tab_drain_events(routing_state, created_at);
create index if not exists tab_drain_events_type_idx on public.tab_drain_events(event_type, created_at);
```

## Front-end patch requirement
Every local UI action calls `emitTabDrainEvent()`:
- import session
- classify item
- register item
- reassign item
- mark done
- kill item
- library item
- comment
- discussion
- score
- evidence
- bulk register
- send to Pen
- send to Dev

## Bridge routing
- `tab.item.registered` -> Pen intake
- `tab.item.execution.requested` -> Dev execution queue
- `tab.item.evidence.bound` -> Reality Ledger
- `tab.item.monetisation.flagged` -> revenue/opportunity registry
- `tab.bulk.registered` -> batch import receipt

## Acceptance criteria
1. Current 52 actionable items become REGISTERED.
2. Current 4 library items become KNOWLEDGESET.
3. Every item emits at least one event row.
4. Pen/Dev receipt is stored against the event.
5. Command Centre can show live PENDING/ROUTED/ACKED/FAILED/BLOCKED counts.
6. No manual review queue remains as a passive sink.

## Reality Ledger
status: PARTIAL
result: Compiled executable register/event pack committed to GitHub.
evidence: GitHub commit receipt plus issues #69, #70, #71.
gaps: Supabase runtime execution and Bridge ACK still required outside this connector session.
next_action: Pen/Bridge executor applies SQL, patches UI emitter, imports current export/localStorage, and returns ACK receipts.
elevation: tab_drain becomes an always-on event intake fabric for portfolio execution and monetisation.
pressure_flags: runtime_ack_required, bridge_execution_pending, no_passive_review_allowed.
score: 0.78
