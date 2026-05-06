# 10_ram_dev-inspection_gate.md

## Purpose
RAM cannot move to prod based on planning artifacts alone.
This document defines the mandatory dev inspection gate.

## Inspection Scope
Dev inspection must verify:
- schema validity
- naming normalization safety
- duplicate detection correctness
- manifest generation correctness
- evidence binding integrity
- REAL/PARTIAL/BLOCKED classification logic
- package stem consistency
- recovery instructions presence
- bridge payload compatibility
- command centre widget renderability

## Required Runtime Tests
1. ingest internal package
2. normalize filenames
3. generate manifest
4. classify evidence state
5. create portfolio card
6. create validation report
7. emit receipt artifact
8. replay package generation

## Failure Conditions
BLOCK promotion if:
- PRETEND classification appears
- duplicate hash collisions unresolved
- receipt missing
- manifest missing
- environment tagging absent
- package stem mismatch
- orphan assets unresolved
- evidence classification inconsistent

## Promotion Rule
Prod promotion only allowed when:
- internal data exists in RAM tables
- at least one REAL evidence chain exists
- package replay succeeds
- validation report generated
- receipt exists

## Required Dev Outputs
- RCPT_ram_dev-inspection.json
- LOG_ram_dev-inspection.ndjson
- 73_validation_summary.json

## Required Prod Outputs
- RCPT_ram_prod-promotion.json
- LOG_ram_prod-promotion.ndjson

## Operational Doctrine
Dogfood-first means RAM proves itself against our own ecosystem before externalization.
