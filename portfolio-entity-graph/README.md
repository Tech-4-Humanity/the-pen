# Portfolio Entity Graph v1

Status: PARTIAL until deployed and runtime receipts are returned.

This package replaces the fixed 30-business registry with a discovery-first entity graph. The portfolio is fluid and includes businesses, brands, products, market wrappers, sites, repos, domains, deployments, agents, dashboards, datasets, campaigns, offers, research streams, personal assets, duplicates, stale artifacts, and infrastructure.

## Build sequence

1. Inventory importers
2. Entity classifier
3. Relationship graph
4. Stage scorer
5. Duplicate resolver
6. Sell-readiness scorer
7. Whitelabel-readiness scorer
8. Command Centre graph surface
9. Reality Ledger binding
10. Autonomous prioritisation engine

## Execution order

Discover -> Classify -> Relate -> Stage -> Prioritise -> Execute -> Evidence -> Promote/Demote

## Files

- schema.sql: core database schema
- scoring.sql: scoring functions and summary views
- seed_vercel_inventory.json: observed Vercel inventory sample from connected tooling
- bridge_envelope.json: bridge-ready invocation envelope
- acceptance_gates.md: REAL/PARTIAL gates

## Current truth

Architecture and repo package can be committed here. Runtime is not REAL until Supabase schema execution, importer execution, Command Centre exposure, and Reality Ledger receipt are returned.
