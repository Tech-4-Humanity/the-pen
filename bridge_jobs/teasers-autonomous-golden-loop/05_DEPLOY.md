# DEPLOY.md

## Objective
Deploy Teasers as a Synal-compatible human effectiveness signal pack.

## Steps
1. Apply 04_schema.sql to Supabase.
2. Register Teasers pack in browser-agent runtime.
3. Register Synal widget slug: teasers-human-effectiveness.
4. Register MCP Bridge job: teasers_autonomous_golden_loop.
5. Execute smoke tests.
6. Write runtime receipt.

## REAL proof gates
- schema exists
- delivery event exists
- response event exists
- score event exists
- widget visible
- runtime receipt recorded

## Classification
Missing proof => PARTIAL.
Proof complete => REAL.
