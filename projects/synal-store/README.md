# Synal Store — Installable Intelligence

Status: READY FOR BUILD
Owner: Tech 4 Humanity / Synal
Execution repo: TML-4PM/the-pen
Canonical issue: #6

## Purpose

Synal Store is the commercial marketplace for small installable intelligence products: widgets, browser helpers, signals, spirals, Snaps, micro-agents, evidence widgets and consent/memory utilities.

The core product is not one app. It is a repeatable operating pattern:

User action -> widget / extension / form -> Supabase event -> agent / Lambda / workflow -> result -> evidence receipt -> dashboard -> billing event.

## Build target

Create a production-ready package under `projects/synal-store/` with:

- commercial product catalogue
- pricing and bundle model
- Supabase registry and evidence schema
- Command Centre widget
- Chrome extension stub for Snaps / Spiral / Signal Button
- API event contracts
- install flow documentation
- smoke test checklist
- runbook

## First products to ship

1. Snaps
2. AgentSnaps
3. SuperSnaps
4. Spiral
5. Signal Button
6. Teasers
7. Daily Brief Widget
8. Website Critic
9. Six-Page Funnel Kit
10. Offer Builder
11. Proof-of-Done Widget
12. ConsentX Lite

## Completion definition

A product is not complete unless it has:

- install path
- price
- user action
- execution path
- evidence receipt
- recovery path
- upgrade path

## Reality Ledger requirement

Every execution writes:

intent -> execution -> output -> classification -> evidence

Classification values: REAL, PARTIAL, PRETEND.

## Next executor command

Build the package in this folder, create the missing files listed in BUILD_SPEC.md, run smoke tests, then post a completion receipt back to issue #6.
