# POST — COG-001 BRIDGE PICKUP REQUEST

Date: 2026-05-06 Australia/Sydney
Status: READY_FOR_BRIDGE_PICKUP

## Request

Please pick up and process the existing COG-001 job package.

## Existing job package

Path:

`bridge/intake/COG-001-create-supabase-schema-2026-05-05.json`

Commit:

`84934fbae7c63ca1c7cfab45435616e5dfd3f195`

## Existing ledger

Path:

`bridge/intake/browser-audit-T29-agl-dominate-execution-ledger-2026-05-05.yaml`

Commit:

`66211c3be9bfdd138398e705b28b394cec98ec6d`

## Required outcome

The worker should process COG-001 using the instructions already contained in the job package and return a structured receipt.

The receipt must state whether the job succeeded or failed, include the task id, executor name, execution timestamp, verification summary, and any errors.

## Classification rule

- If runtime execution and verification succeeds, classify COG-001 as REAL.
- If the package is only staged or picked up without runtime proof, classify it as PARTIAL.
- If execution fails, classify it as FAIL and include the error.

## Next chain after a successful receipt

- COG-002 — seed_state_profile_data
- COG-003 — create_product_catalog_entries
- COG-004 — deploy_sovereignty_metrics
- COG-005 — build_synal_widgets
