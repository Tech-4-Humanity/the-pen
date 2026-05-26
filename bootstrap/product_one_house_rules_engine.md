# Product 1 — House Rules Engine

**Product position:** Product 1 in the canonical Product Loop sequence.
**Status:** Asset committed; bridge activation requested.
**Source issue:** [TML-4PM/the-pen#61](https://github.com/TML-4PM/the-pen/issues/61)

## What this is

The House Rules Engine codifies operating rules that apply across the T4H portfolio. The CSV asset at `rules/house/house_rules.csv` (commit `19a8847`) is the canonical seed.

## Product Loop application (nine views)

| View | Application |
|---|---|
| Signal | Rule violations / rule-applicable events surface from runtime telemetry |
| Consent | Rules respect existing privacy/consent boundaries; do not introduce new collection |
| Governance | Rule changes require canonical_changes audit row; rules are versioned |
| Orchestration | Bridge syncs rules CSV to Supabase, Command Centre surfaces them |
| Execution | Worker enforces rules on inbound work items / receipts |
| Outcomes | Receipts written for each rule application; ledger row per session |
| Distribution | Rules visible in Command Centre, exportable for portfolio-wide visibility |
| Revenue | Indirect — rules protect operational quality which sustains revenue |
| Experience | Rules surface to humans through Command Centre, not buried in code |

## Post-production layers (kernel-mandated)

- **Storage:** Supabase `public.house_rules` (per activation handoff)
- **Bootstrap:** this file + `bridge_handoffs/house_rules_engine_activation.md`
- **Distribution:** Command Centre widget
- **Evidence:** `receipts/runtime/house-rules-*.receipt.json`
- **Feedback:** Rule violations logged; rule revisions tracked in canonical_changes
- **Automation:** Bridge sync + Command Centre auto-refresh
- **Scaling:** CSV → Postgres scales linearly; no per-rule cost growth
- **Governance:** Rule changes through canonical change process
- **Recovery:** CSV is canonical source of truth, Supabase reconstructable
- **Monetisation:** Not directly monetised; enables monetised products
- **Replication:** Pattern reusable for Product 2+
- **Uplift:** Rule effectiveness measured through telemetry over time

## Receipt for closure of #61

This file + `bootstrap/README.md` + `bridge_handoffs/house_rules_engine_activation.md` complete the documented deliverables. Bridge sync to Supabase remains as the runtime activation step (separate execution).
