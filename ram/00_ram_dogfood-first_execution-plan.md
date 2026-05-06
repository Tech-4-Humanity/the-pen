# RAM Dogfood-First Execution Plan

Status: PARTIAL until internal Tech 4 Humanity / Troy ecosystem data is ingested, validated, reportable, inspected in dev, and promoted with evidence.

## Canonical Name
RAM = Retro Assets Modernisation
Runtime/worker form: Retro Assets Moderniser

## Doctrine
RAM is not net-new. It attaches to the existing spine: the Pen, Bridge Runner, Reality Ledger, Command Centre, Supabase, WorkFamilyAI, FAR-CAGE, and product portfolio surfaces.

## Completion Rule
RAM is not complete when the schema exists or the plan is written.
RAM is complete only when our own data is:
- ingested
- normalized
- deduplicated
- validated
- evidence-bound
- reportable
- inspected in dev
- promoted to prod with receipts

## Dogfood Scope
Initial dataset sources:
- TML-4PM/the-pen
- TML-4PM/mcp-command-centre
- bridge payloads and receipts
- generated artifacts
- product plans
- documentation packs
- package manifests
- Reality Ledger-compatible receipts
- Command Centre widgets and snippets
- portfolio/capability documents

## Core Components
1. RAM Registry
2. RAM Clean
3. RAM Validate
4. RAM Lift
5. RAM Portfolio
6. RAM Reuse
7. RAM Revenue
8. RAM Watch
9. RAM Dev Inspection
10. RAM Prod Promotion

## Required Tables
- ram_assets
- ram_asset_versions
- ram_asset_hashes
- ram_asset_locations
- ram_asset_lineage
- ram_asset_validation
- ram_asset_evidence
- ram_asset_packages
- ram_asset_relationships
- ram_portfolio_cards
- ram_reuse_components
- ram_watch_events
- ram_revenue_opportunities
- ram_dev_inspections
- ram_prod_promotions

## Required Package Files
- 00_manifest.json
- 01_ram_schema.sql
- 02_ram_rls_policies.sql
- 10_ram_api_contract.md
- 20_ram_agent_specs.yaml
- 30_ram_normalizer_worker.py
- 31_ram_validator_worker.py
- 32_ram_portfolio_worker.py
- 40_ram_command-centre_widgets.tsx
- 50_ram_bridge_handoff.md
- 60_ram_deployment_notes.md
- 70_ram_reality-ledger_binding.json
- 71_runtime_receipt.json
- 72_execution_log.ndjson
- 73_validation_summary.json
- 80_ram_product-map.md
- 81_ram_commercial-offers.md
- 90_ram_recovery_instructions.md

## Execution Loop
Discover -> Classify -> Normalize -> Dedupe -> Validate -> Evidence-bind -> Uplift -> Portfolio-map -> Report -> Dev inspect -> Prod promote.

## Dev Inspection Gate
Dev must inspect:
- schema validity
- RLS policy safety
- duplicate detection correctness
- naming normalization safety
- evidence classification accuracy
- reportability of internal dataset
- widget render path
- bridge handoff payload format

## Prod Gate
Prod is blocked until:
- at least one internal repo is ingested
- at least one internal package is normalized
- at least one evidence report is generated
- at least one portfolio card is generated from real internal data
- Reality Ledger status is not PRETEND
- receipt exists

## Evidence Rule
No RAM output is REAL without typed evidence: commit id, API response, receipt, hash, log, or reproducible validation.

## Bridge Handoff
Bridge should create the package stem:
PKG_ram_dogfood-first_20260506.zip

Receipt stem:
RCPT_ram_dogfood-first_20260506.json

## Dev Handoff
Send to dev for inspection after package generation and internal-data ingestion.

## Prod Handoff
Send to prod only after dev inspection passes and Reality Ledger binding exists.
