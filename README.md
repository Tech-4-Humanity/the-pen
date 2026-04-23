# The Pen

The Pen — universal intake gate for all T4H systems, and the canonical control-layer repo for autonomous execution doctrine.

## Start here — the canonical doc hierarchy (read in order)

| # | File | Role |
|---|---|---|
| 1 | [`global/GLOBAL_RULE.md`](global/GLOBAL_RULE.md) | The law: no direct GitHub, MCP bridge only, credential isolation, receipts mandatory |
| 2 | [`global/MCP_EXECUTION_CONTRACT.md`](global/MCP_EXECUTION_CONTRACT.md) | The envelope: exact payload shape for the bridge |
| 3 | [`global/ENFORCEMENT_LIVE.md`](global/ENFORCEMENT_LIVE.md) | The runtime: verified working path + troubleshooting. **Wins if doctrine disagrees.** |
| 4 | [`global/ACTOR_COMPLIANCE.md`](global/ACTOR_COMPLIANCE.md) | Behaviour standard for AI actors |
| 5 | [`global/RECEIPT_SCHEMA.json`](global/RECEIPT_SCHEMA.json) | Receipt format |
| 6 | [`receipts/README.md`](receipts/README.md) | Two-way receipt rule for job-flow work |

## The one-line canonical path

Any actor writing to a TML-4PM repo:

```sql
SELECT public.fn_github_push('TML-4PM/<repo>', '<path>', '<content>', '<message>', 'main');
```

Invoked through `troy-sql-executor` via the bridge. See `global/ENFORCEMENT_LIVE.md` for the exact HTTP envelope.

## Extension: Funnel Deployment Pack

This repo also includes a **5-funnel revenue capture system** designed to:
- capture demand with minimal friction
- route leads into Supabase
- trigger execution pipelines
- return verifiable receipts

### Funnel set
1. AHC (Book Troy)
2. BCI Advisory
3. Reading Buddy Pilot
4. AI for Tradies Audit
5. Augmented Memories

### Core pattern
Page → Form → API → Supabase → Command Centre → Receipt

### Expected outcome
- Working lead ingestion system
- Trackable pipeline
- Repeatable deployment pattern across all 30 T4H businesses

## Status

- Doctrine: **ACTIVE — ENFORCED** (v2 as of 2026-04-24)
- Runtime: **REAL_AUTONOMOUS** — verified commits `9425776984…` (lock) + `c673da8c98…` (replay)
- Funnel pack: **PEN PAYLOAD READY**
