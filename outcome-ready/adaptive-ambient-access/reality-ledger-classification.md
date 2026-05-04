# Adaptive Ambient Access — Reality Ledger Classification

**Project:** OR-AAA-001 | **Agent:** AAA-012 | **Updated:** 2026-05-04

## Classification

**Current State: PARTIAL**

| Artefact | Status | Evidence |
|---|---|---|
| README.md | REAL | Committed to TML-4PM/the-pen main |
| product-plan.md | REAL | Committed to TML-4PM/the-pen main |
| pricing.md | REAL | Committed to TML-4PM/the-pen main |
| coo-pod-charter.md | REAL | Committed to TML-4PM/the-pen main |
| build-backlog.md | REAL | Committed to TML-4PM/the-pen main |
| supabase-schema.sql | REAL | Committed — NOT YET DEPLOYED |
| scoring-rubric.md | REAL | Committed to TML-4PM/the-pen main |
| audit-scripts.md | REAL | Committed to TML-4PM/the-pen main |
| command-centre-widget-spec.md | REAL | Committed to TML-4PM/the-pen main |
| landing-page-copy.md | REAL | Committed to TML-4PM/the-pen main |
| stripe-products.json | REAL | Committed — NOT YET SEEDED |
| reality-ledger-classification.md | REAL | This file |

## Blocker to REAL

1. **Schema deployment** — run supabase-schema.sql against lzfgigiyqpuuxslsygjt
2. **Stripe seed** — invoke troy-stripe-executor with stripe-products.json
3. **Runtime test** — one participant journey through ambient window API
4. **NDIS log** — at least 1 row in aaa_support_log with ndis_line_item populated

## Completion Signal

When all 4 blockers resolved: update this file to REAL and write receipt to `receipts/or-aaa-001-complete.json`
