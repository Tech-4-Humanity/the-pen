# AI Lead Action Kit - Wave 10 Package

Status: PARTIAL / BRIDGE READY
Created: 2026-05-01
Owner: Tech 4 Humanity / AHC / AI for Tradies

## Product
50 Qualified Leads + Action Kit

## Goal
Create a customer-buyable product where signup, payment, welcome email, portal access, lead display, rules upload, dynamic pricing, proposal generation, reporting, cancellation, export, and telemetry are wired as one lifecycle.

## Current build expectation
This package is the hardened handoff for Bridge execution. It is not a claim that production credentials are present. Bridge must bind live secrets and runtime systems.

## Minimum Wave 10 gate
- Signup works
- Payment clears
- Welcome email sends with real links
- Dashboard opens and shows leads
- YAML upload triggers rules and dynamic pricing
- Agent researches/builds proposal outputs
- Basic reporting is ready
- Cancellation rules and data export are set
- Telemetry logs customer, product, cost, and support events
- Support surface is agent-driven, not static
- Brand/product language is checked before promotion

## Known final blockers
- Live outbound email/SMS provider credentials
- Real search/data hooks such as Google/LinkedIn/directory APIs
- Actual dollar cost feeds for data, compute, messaging, and support
- Full dashboard upsell UX

## Run order
1. Apply database schema in db/schema.sql
2. Deploy API endpoints from api_contract.md
3. Deploy customer portal from portal_spec.md
4. Configure product YAML from product_config.yaml
5. Run harness from test_harness.md
6. Send customer email from customer_email.html
7. Confirm telemetry and cost events in reporting_spec.md
8. Bridge returns evidence receipts

## Reality status
PARTIAL until Bridge executes with credentials and returns evidence IDs.

## Evidence required for REAL
- GitHub commit receipt
- DB migration result
- deployed URL
- test order ID
- payment event ID or sandbox payment event
- email send receipt
- portal loaded event
- lead pack generated event
- rules upload event
- report generated event
- cancellation/export tested events
- cost model summary
