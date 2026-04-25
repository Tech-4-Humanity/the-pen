# Accento / Augmented Memories Wave 10 Execution Pack

Status: PEN_PAYLOAD_READY
Date: 2026-04-24
Owner ecosystem: Tech 4 Humanity, 30-business model

## Purpose

This pack converts the Accento / Augmented Memories concept into a production-oriented Supabase, RLS, MCP Bridge, first-product, monetisation, telemetry, and proof bundle.

The core idea is one shared memory graph used across all 30 T4H businesses:

- capture any memory input
- bind it to people, places, organisations, events, assets, consent, and signals
- expose it through private, shared, public, partner, memorial, work, education, health, tourism, and place-aware experiences
- monetise through subscriptions, one-off memorial/legacy packs, partner/place network, enterprise licensing, services, and ethical aggregated insight

## Contents

| File | Role |
|---|---|
| `supabase/001_accento_memory_graph.sql` | Production Supabase DDL, RLS, functions, enums, views, indexes, seed rows |
| `supabase/002_accento_smoke_tests.sql` | Smoke tests and proof queries |
| `bridge/mcp_bridge_payload.json` | Canonical MCP Bridge execution envelope for SQL deployment |
| `product/first_deployable_product.md` | First deployable product definition: Accento Memory Places MVP |
| `product/30_business_mapping.md` | Mapping of the schema and experience layer to all 30 businesses |
| `product/monetisation_stack.md` | Monetisation model across all layers |
| `ops/autonomous_golden_loop.md` | Build → enforce → prove → recover → monetise → replicate loop |
| `receipts/RECEIPT_AccentoAugmentedMemories_Wave10_20260424.json` | Machine-readable deposit receipt |
| `receipts/RECEIPT_AccentoAugmentedMemories_Wave10_20260424.md` | Human-readable receipt |

## First deployable product

**Accento Memory Places MVP**

A location-aware memory layer where people can create private, shared-circle, or public memories attached to places, discover memory density nearby, and optionally use QR/NFC anchors for partner or memorial contexts.

## Wave 10 gates

This pack includes:

- Production schema
- RLS-first table design
- Reality Ledger classification hooks
- ConsentX/Far-Cage/GC-BAT alignment
- Place graph / JustPoint compatibility
- Memorial, family, work, education, health, travel, venue and museum pathways
- MCP Bridge payload
- Smoke test script
- Deployment receipt
- Replication plan across the 30-business ecosystem

## Runtime note

This repository is the handoff and control layer. The SQL should be executed through the MCP Bridge using `troy-sql-executor`, then proven with the smoke tests in `supabase/002_accento_smoke_tests.sql`. The Mac is treated only as an endpoint.
