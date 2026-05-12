# 10_ram_api_contract.md

RAM API surface. All endpoints route through the T4H bridge and require dual-auth (x-api-key + Authorization: Bearer).

## Ingest
POST /ram/ingest
- body: { source_system, source_uri, asset_type?, original_name?, metadata? }
- effect: insert into ram_assets, emit ram_watch_events(event_type='asset_discovered', severity='info').
- returns: { asset_id, canonical_name, evidence_state }

## Normalize
POST /ram/normalize
- body: { asset_id }
- effect: compute canonical_name (NN_topic-slug per semantic range), update ram_assets, write ram_asset_lineage.
- returns: { canonical_name, lineage_id }

## Validate
POST /ram/validate
- body: { asset_id, checks?: [link_liveness, repo_exists, deploy_probe, hash_dedupe, naming_compliance, evidence_presence] }
- effect: insert ram_asset_validation row per check, attach ram_asset_evidence.
- returns: { validation_score, status }

## Uplift
POST /ram/uplift
- body: { asset_id, audience: [exec,cto,gov,partner,investor,standards,humanitarian] }
- effect: generate ram_portfolio_cards bound to evidence_state=REAL only.

## Package
POST /ram/package
- body: { package_stem, purpose, asset_ids[], environment }
- effect: insert ram_packages row, mirror receipt stem.

## Portfolio
GET /ram/portfolio/:brand
- returns: portfolio_cards for brand where evidence_state='REAL'.

## Reuse
POST /ram/reuse
- body: { asset_id, component_type, component_name, reuse_target? }
- effect: insert ram_reuse_components.

## Watch
GET /ram/watch
- returns: ram_watch_events ordered desc, filter by severity.

## Dev Inspect
POST /ram/dev/inspect
- body: { package_stem, findings, status }
- effect: insert ram_dev_inspections, attach receipt_uri.

## Prod Promote
POST /ram/prod/promote
- body: { package_stem }
- gate: requires latest ram_dev_inspections.status='REAL' for stem.
- effect: insert ram_prod_promotions, status='REAL' if gate passes else 'BLOCKED'.

## Reality State
GET /ram/reality/:entity_name
- proxies t4h_reality_state classifier.

## Evidence rule
No write path produces evidence_state='REAL' without typed evidence (commit_id, api_response, db_result, hash, log, or receipt).
