# Operational Market Intelligence Orchestration

## Intent

Convert world events into operational economic movement continuously across existing and new surfaces.

This package turns external signals such as news articles, policy changes, research, complaints, social posts, regulator activity, competitor moves, and customer pain into an enforced progression system:

`RAW_SIGNAL -> PARSED -> CLASSIFIED -> GAP_EXTRACTED -> PRODUCT_MAPPED -> CONTENT_GENERATED -> CAMPAIGN_DEPLOYED -> LEADS_CAPTURED -> REVENUE_ATTRIBUTED -> RUNTIME_OPTIMISED`

The missing piece this closes is not ideation. The missing piece is enforced operational progression infrastructure.

Current failure mode:

- intelligence fragments
- inconsistent sweeps
- inconsistent analysis
- no canonical state machine
- no closure enforcement
- no telemetry continuity
- no economic attribution

Target state:

- autonomous market runtime
- every signal moves or escalates
- every market event becomes a product, campaign, telemetry, or reject-with-reason decision
- no permanent pending

## Core thesis

The goal is not to read articles.

The goal is to convert world events into operational economic movement continuously.

That means every relevant signal must be forced through:

1. ingest
2. parse
3. classify
4. pressure score
5. gap extract
6. product map
7. market wrapper
8. content/campaign generation
9. lead capture
10. telemetry
11. revenue attribution
12. optimisation or archival

## Canonical tables

- `signal_registry`
- `signal_entity`
- `signal_pressure`
- `signal_gap`
- `signal_product_map`
- `signal_campaign`
- `signal_telemetry`
- `signal_revenue`
- `signal_state_transition`
- `signal_runtime_ledger`

## First exemplar

ABC News NDIS fraud article, 5 May 2026:

`https://www.abc.net.au/news/2026-05-05/ndis-fraud-tactics-popping-up-around-australia/106622490`

Converted into:

- Outcome Ready signal
- NDIS fraud/integrity pressure
- Plan Watch product opportunity
- Integrity Shield provider wrapper
- Family Dashboard parent wrapper
- Evidence Vault feature
- Complaint Pack Generator
- campaign and lead-capture motions

## Enforcement principle

A signal is not valuable until it changes system state.

Valid end states:

- product feature created
- campaign created
- lead magnet created
- landing page created
- revenue opportunity created
- risk entered into watchlist
- rejected with reason
- archived with expiry

Invalid end states:

- discussed
- noted
- interesting
- pending forever
- to revisit

## Reality classification

Current package status: PARTIAL

Reason: schema and bridge handoff are committed, but runtime deployment, Supabase execution, sweep automation, telemetry and revenue attribution are not yet proven in production.

Upgrade to REAL only after:

- SQL deployed
- ABC signal inserted
- state transitions executed
- bridge receipt returned
- at least one campaign artefact generated
- telemetry endpoint/event path created
- revenue attribution path linked or explicitly stubbed with gated dependency
