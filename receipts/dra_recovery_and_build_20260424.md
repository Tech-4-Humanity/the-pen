# DRA Recovery and Build Receipt — 2026-04-24

## Status
PARTIAL — executable handoff created and verified. Runtime execution across Supabase, Notion, and web deploy still requires bridge runner execution and receipts.

## What was received
The uploaded thread `Pasted text(147).txt` shows a stalled Drug Resilience Atlas recovery flow. The assistant repeatedly asked for confirmation instead of producing a bridge-ready job. The useful facts were extracted and converted into a concrete execution payload.

## Verified assets
- Pen repo: `TML-4PM/the-pen`
- Bridge job file: `bridge_jobs/dra_recovery_and_build_20260424.json`
- Commit creating bridge job: `deaa37c8d88fe3ea638ea45a3dd8491f7f75352b`
- Job file verified on `main`
- Atlas repo visible: `TML-4PM/atlas-aus-pulse`
- Known site: `https://atlas-aus-pulse.lovable.app`

## What the job must complete
1. Search all stores for DRA terms: GitHub, Supabase, Notion, atlas repo/site, MCP-accessible Mac/Drive exports.
2. Build canonical DRA schema.
3. Seed V1 substance x population matrix.
4. Populate Notion DRA Master Index.
5. Wire Atlas web surface.
6. Add research expansion loop.
7. Write evidence and Reality Ledger receipts.

## Canonical DRA V1 scope
Substances:
- Cannabis
- MDMA
- Methamphetamine
- Cocaine
- Opiates
- Alcohol
- Nicotine

Population lenses:
- ADHD
- Autism
- Dyslexia
- Indigenous populations
- Elderly
- Neurotypical baseline

Core dimensions:
- primary neurochemical pathway
- felt deficit or state sought
- in-use effect
- crash or rebound effect
- neurotype-specific landing pattern
- functional gain
- functional harm
- dependency risk
- cognitive load
- executive function effect
- emotional volatility
- harm-reduction notes
- evidence status

## Truth classification
This receipt is REAL for the GitHub handoff and verified file existence.
The DRA system itself remains PARTIAL until the bridge runner executes and returns runtime receipts for Supabase, Notion, and Atlas site deployment.

## Next required runtime receipt
The next receipt must include:
- Supabase migration commit or SQL execution receipt
- row counts for DRA tables
- Notion update receipt with page/database identifiers
- Atlas route/component commit SHA
- smoke test output proving a queryable substance x population matrix
- Reality Ledger entries for each execution step
