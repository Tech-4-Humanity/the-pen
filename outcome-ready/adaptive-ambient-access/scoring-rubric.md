# Adaptive Ambient Access — Scoring Rubric

**Project:** OR-AAA-001 | **Agent:** AAA-007

## Reality Classification Rubric

Each AAA output is scored across 5 dimensions. Total score determines reality state.

| Dimension | Weight | REAL (3) | PARTIAL (2) | PRETEND (1) |
|---|---|---|---|---|
| Artefact exists | 20% | File committed to repo | Draft exists locally | Described only |
| Schema deployed | 20% | Tables live in Supabase | Migration written not run | Schema designed |
| Runtime proof | 25% | API call succeeds with real data | Mock response accepted | No test run |
| NDIS compliance | 20% | Audit log populated, line items correct | Log exists, items incomplete | Compliance described |
| Stripe connected | 15% | Checkout tested, webhook fires | Products seeded, no checkout | Products described |

## Scoring

| Total Score | Reality State |
|---|---|
| 2.7 – 3.0 | REAL |
| 2.0 – 2.69 | PARTIAL |
| < 2.0 | PRETEND |

## Current OR-AAA-001 Score

| Dimension | Score | Evidence |
|---|---|---|
| Artefact exists | 2 | 12 files being committed now (PARTIAL→REAL on merge) |
| Schema deployed | 1 | Schema written, not yet deployed |
| Runtime proof | 1 | No test run yet |
| NDIS compliance | 1 | Audit log in schema, not populated |
| Stripe connected | 1 | Products not yet seeded |

**Current: PARTIAL (1.4) — target REAL after Sprint 1 completion**
