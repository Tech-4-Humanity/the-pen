# Synal Store Build Spec

## Contract
Finish the Synal Store build package to production-ready handoff. No HITL unless blocked by authority, credentials, destructive action, external paid spend, legal or safety.

## Product thesis
Synal Store sells installable intelligence: browser-native helpers, widgets, signal collectors, micro-agents and proof/evidence utilities.

## Required surfaces
- Landing page
- Product catalogue
- Pricing page
- Install flow
- Product registry
- Event capture
- Evidence receipts
- Agent queue
- Command Centre widget
- Chrome extension stub
- Smoke tests

## First 12 products
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

## Build gates
- Product has SKU, price, category and active flag.
- User action writes event.
- Event can be converted to agent queue item when applicable.
- Output writes evidence receipt.
- Evidence receipt classifies REAL, PARTIAL or PRETEND.
- Command Centre can show health, installs, events and receipts.
- Extension can capture current tab, save intent and push event payload.

## Runtime contract
User action -> Synal Store event -> queue/action -> evidence receipt -> dashboard -> billing event.

## Completion receipt
Return issue comment with commits, files, smoke status, blockers and next executor command.