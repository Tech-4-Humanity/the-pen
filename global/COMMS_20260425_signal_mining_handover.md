2026-04-25T23:45:00+10:00 — HANDOVER: Signal Mining Slice 01 (research-first)

Owner: Troy (via ChatGPT)
Routing: /pen /wip /symbio
Trace: signal-mining-slice-01-research-plan-chatgpt-20260425
Primary commit: 01f8e21f8af39ea7642551242400d901cb5d6b50
Spec commit: 4640bf20a6c198b76c78f011d8a283a941ec75be
Worker-mapping commit: 8dc186a3a3c1b423fcef1b1eee665fe077351932

Intent:
- Research and plan signal mining across LLM chats, docs, repos and system activity.
- No new infra. Mining-first. Graph tests + simulations.

Required Actions (no ambiguity):
1) Map actions to workers:
   - research.signal_mining_slice_01_plan
   - research.signal_mining_extract_queries_v1
   - research.signal_mining_receipt_check
   - research.signal_mining_source_inventory
   - research.system_up_to_scratch_plan
2) Execute Slice 01 in READ-ONLY mode per docs/SIGNAL_MINING_SLICE_01.md
3) Write receipts to receipts/runtime/ for each action with idempotency_key
4) Produce output tables (Top Loops, Broken Systems, Hidden Assets, High ROI Fixes)

Acceptance:
- Receipt exists for each job (idempotency_key present)
- Evidence links back to commits/messages
- No dashboards, no infra builds

Blockers to resolve:
- If no worker mapping → implement mapping
- If worker runs without receipt → fix receipt writer

Note:
- Chat URL not available from sandbox; use idempotency_key + commit SHA as trace.
