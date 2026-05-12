# Truth Spine Hardening Sprint

Status: PARTIAL until Bridge execution, Supabase writes, Vercel import, Stripe evidence, runway layer, and IP register are proven with receipts.

## Purpose

Close the six hard gaps from the Master Context Spine review:

1. Bridge/orchestration not proven end-to-end.
2. Revenue evidence not verified.
3. 49/50 Vercel projects untriaged.
4. No canonical runway/burn layer.
5. No active IP register.
6. Source of truth not enforced systemically.

## Acceptance Harness

A claim can move to REAL only when it has:

- typed evidence: api_response, db_result, cli_output, commit_id, url, hash, repro_steps, or payment_event
- a Reality Ledger row
- an owner
- a lifecycle state
- a receipt
- a repeatable query or replay path

## Required execution order

1. Apply `01_truth_spine_schema.sql` to Supabase.
2. Load `02_truth_spine_seed.sql`.
3. Run `03_truth_spine_harness.sql`.
4. Submit `04_bridge_payload.json` through the Bridge.
5. Return and store Bridge receipt in `bridge_execution_receipts`.
6. Import Vercel project inventory.
7. Import Stripe/product/revenue events.
8. Populate runway/burn and IP register.
9. Run harness again.
10. Write final Reality Ledger closure row.

## REAL / PARTIAL / BLOCKED rule

- REAL: all gates pass with receipts.
- PARTIAL: schema/assets exist but one or more runtime/evidence gates remain open.
- BLOCKED: missing credentials, unreachable Bridge, unavailable Supabase, unavailable Vercel, or unavailable Stripe.

## Current receipt

This folder is a GitHub-side execution package. It is not a Bridge runtime receipt by itself.
