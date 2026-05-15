# BRIDGE HANDOFF — House Rules Engine Production Activation

Status: READY_FOR_BRIDGE_EXECUTION
Product: PRODUCT_1_HOUSE_RULES_ENGINE
Date: 2026-05-16
Owner: Tech 4 Humanity autonomous execution layer

## Objective
Finish activation of the House Rules Engine as a runtime product, not a static artefact.

## Required execution path

1. Pull canonical package from `production/house-rules-engine/`.
2. Create or update Supabase runtime tables using `sql/001_house_rules_engine.sql`.
3. Seed house rules from `rules/house_rules.csv` and `rules/house_rules.yaml`.
4. Register bootstrap sources in runtime registry.
5. Create bootstrap receipt row for this activation.
6. Wire session-start contract: no bootstrap receipt = no execution.
7. Wire gap/search failure logging into discovery register.
8. Create Command Centre surface or widget stub for active rules, violations, gaps, and receipts.
9. Return receipts:
   - GitHub commit SHA
   - Supabase execution proof
   - rule count inserted
   - bootstrap source count inserted
   - receipt row id
   - Command Centre surface URL or stub path

## Acceptance criteria

- `hre_house_rules` exists and contains seeded rules.
- `hre_bootstrap_sources` exists and contains mandatory bootstrap documents.
- `hre_runtime_receipts` contains an activation receipt.
- `hre_discovery_gaps` exists for failed retrieval logging.
- `hre_service_catalogue` contains Product 1 entry.
- The runtime can answer: what rules are active, what evidence is required, what has not been loaded.

## Failure handling

If Bridge cannot execute a step:
- write exact blocker
- write missing authority/dependency
- write next executable fallback
- do not mark REAL

## Reality classification
PARTIAL until Bridge returns runtime receipts.
REAL only when Supabase execution + receipt + visible surface exist.
