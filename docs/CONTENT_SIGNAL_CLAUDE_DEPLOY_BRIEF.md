# Content Signal OS — Deploy Brief & Runbook

**Source of truth:** `CONTENT_SIGNAL_HOUSE_RULES.md` @ commit `2b82c6bbf52153a148bd1310cec10ac20b9cfe40` (blob `49a4e9c6`).
**Target DB:** Supabase S1 `lzfgigiyqpuuxslsygjt` (canonical write target).
**Schema:** `content_signal` (new namespace — no collision with existing schemas).
**Canonical ledger:** `public.reality_ledger` id `d8808133-054c-47eb-a332-66ea982c1226` (PARTIAL, cluster `content-signal-os`).

## What deployed (non-HITL per house rules)

The house rules state: drafting, packaging, classification, cutdowns and recommendation do not require human approval; publishing does. This deploy covers exactly the non-HITL surface:

- 25 tables — full object model from the house rules' Required Tables list.
- `fn_register_topic_occurrence` — the 1/2/3/5+/10+ escalation engine.
- `fn_generate_package` — signal -> asset -> package -> HITL gates -> HELD queue.
- Seed: 5 brand voices, 3 POVs, 8 platforms, LinkedIn format rules, default image style.
- RLS forced on all 25 tables (locked-default; service_role bypasses).
- Reversible via `teardown/content_signal_os_teardown.sql`.

## What is deliberately NOT deployed (HITL / out of scope)

Per the house rules' Human Approval Rule, none of these run autonomously:

- Final article approval, final image approval, brand/POV confirmation.
- Sensitive policy/legal/regulatory content sign-off.
- Any destructive or paid distribution step.
- Live publishing handoff — `publishing_queue` rows are created `held`.

## Reality classification — PARTIAL (honest)

REAL (per house rules) requires all of: schema deployed, LinkedIn export ingested, LLM chat library ingested, signal detector running, >=1 package from mid-thread signal, approval queue created, publishing handoff proven, telemetry+receipts written.

Achieved: schema deployed, approval queue created, >=1 package from a real mid-thread signal, receipts written, smoke PASS.
Not yet: LinkedIn export ingest, LLM chat library ingest, a running signal-detector daemon, proven publishing handoff (HITL-gated by design).

Classified PARTIAL — not documentation-only (schema + engine + package generation executed with receipts), not REAL (ingestion + publishing-proof outstanding).

## Next builds to reach REAL

1. LinkedIn article export ingest -> `article_export_source` + signals.
2. LLM chat library ingest -> `llm_chat_source` + signals.
3. Conversation signal detector running as a scheduled/streaming job.
4. Publishing executor behind `approval_gate` (still HITL to publish).
5. Telemetry rollup cron -> `topic_performance_rollup` + `engagement_fact`.

## Re-run / rollback

- Migration and seed are idempotent — safe to re-apply.
- Rollback: run `teardown/content_signal_os_teardown.sql` (GATED — destructive).
