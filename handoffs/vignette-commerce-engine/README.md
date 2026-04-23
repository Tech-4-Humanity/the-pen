# Vignette Commerce Engine

Status: BRIDGE-READY / PARTIAL until deployed and proven.

Purpose: turn Related Vignettes from static cards into a click-aware, entitlement-aware, paywall-aware, telemetry-bound revenue surface.

## Required behaviour

1. Related vignette cards are clickable.
2. Free content opens immediately.
3. Paid content opens immediately when the user already owns the relevant product or subscription.
4. Locked content shows a preview when available, otherwise routes to checkout.
5. Every click writes telemetry.
6. Every purchase writes entitlement and Reality Ledger proof.
7. Command Centre can show clicks, lock-outs, conversion, revenue, and missing entitlement repair.

## Files in this pack

- `supabase_vignette_commerce_engine.sql` — schema, RLS, views, seed data, telemetry tables, repair queue.
- `api_routes.ts` — Next.js route handlers for related vignettes, logging, checkout, Stripe webhook, revenue stats, reconciliation.
- `RelatedVignettes.tsx` — drop-in React component with access badges, preview/paywall routing, prefetch, telemetry.
- `command_centre_widget.sql` — widget snippet for Command Centre revenue/conversion monitoring.
- `bridge_payload.json` — bridge runner invocation envelope for execution.
- `receipt.md` — permanent receipt for this handoff.

## Implementation path

1. Apply the Supabase SQL migration.
2. Install Stripe SDK if missing.
3. Add the API routes to the app routing layer.
4. Replace static related vignette card stack with `RelatedVignettes`.
5. Wire env vars:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `STRIPE_SECRET_KEY`
   - `STRIPE_WEBHOOK_SECRET`
   - `NEXT_PUBLIC_APP_URL`
6. Configure Stripe webhook for `/api/stripe/webhook`.
7. Add scheduled reconciliation job.
8. Register Command Centre widget.
9. Run smoke tests:
   - free vignette opens
   - included vignette opens
   - locked vignette previews
   - locked no-preview routes to checkout
   - paid checkout creates entitlement
   - purchase writes Reality Ledger row
   - revenue widget returns non-error JSON

## Reality Ledger classification

Initial state: PARTIAL

REAL only after:

- migration applied
- frontend deployed
- Stripe checkout succeeds in test mode
- webhook writes entitlement
- telemetry rows visible
- reconciliation finds no orphan paid sessions
- Command Centre widget loads

## Product notes

This is not a UI enhancement. It is a reusable content-commerce engine for AHC, HoloOrg, WorkFamilyAI, Reading Buddy, AI Sweet Spots, GC-BAT, ConsentX, and any product with staged vignettes, lessons, journeys, or scenario packs.
