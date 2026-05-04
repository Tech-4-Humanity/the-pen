# AI for Tradies Commercial Pack

Status: PARTIAL until runtime deployment, Stripe account binding, Supabase execution, and API smoke tests are completed.

This pack expands the AI Tradies Operating System into a commercial, agent-driven product system.

## Contents

- `agent_architecture_120.md` — 120-agent operating model across Analyse, Write, Distribute, Convert, Execute, Track, Optimise, Retain, Govern, Loop.
- `pricing_stripe_model.md` — product tiers, add-ons, Stripe products/prices, billing model, and revenue logic.
- `stack_mapping.md` — mapping to Outcome Ready, Augmented Humanity Coach, and WorkFamilyAI.
- `api_contract.md` — REST API layer for intake, quote, booking, follow-up, review, metrics, and agent dispatch.
- `supabase_schema.sql` — canonical schema for businesses, jobs, agents, events, products, subscriptions, evidence, and ledger binding.
- `site_scaffold.md` — customer-facing site structure, copy blocks, CTAs, pages, sections, and conversion flow.
- `bridge_handoff.json` — bridge-ready payload for downstream build/execution.

## Core loop

Analyse → Write → Distribute → Convert → Execute → Track → Optimise → Retain → Govern → Loop

## Commercial intent

Turn fragmented trade-business admin into a reusable AI operating system that can be packaged for plumbers, electricians, builders, roofers, HVAC, landscapers, pest control, cleaners, painters, locksmiths, handymen, and specialist contractors.

## Reality status

- GitHub artefacts: REAL once committed and verified.
- Stripe products: PARTIAL until created in live/test Stripe.
- Supabase schema: PARTIAL until executed against project database.
- Site: PARTIAL until deployed to Vercel or equivalent.
- API layer: PARTIAL until implemented and smoke-tested.
- Bridge execution: PARTIAL until bridge runner returns execution receipt.

## Next execution target

Use `bridge_handoff.json` as the next machine-readable payload for the bridge runner or MCP execution layer.
