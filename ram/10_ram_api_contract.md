# RAM API Contract

All routes go through the T4H bridge. Writes require `allowWrite=true` and `dryRun=false`. Reads default to `service_role` PostgREST. Receipts mirror the package stem.

## Conventions

- Path style: `/ram/<noun>/<verb>`
- All bodies are JSON
- All responses include `status`, `evidence_state`, and `receipt_stem`
- All write endpoints write to `audit.log` and (where applicable) `public.reality_ledger`
- Idempotency via `dedupe_key` on enqueue

## Endpoints

### POST /ram/ingest
Discover and register a single asset (or batch).

Request body fields: source_system, source_uri, asset_type, original_name, metadata.
Response fields: status, asset_id, canonical_name, evidence_state, receipt_stem.

### POST /ram/normalize
Apply canonical naming. Deterministic, reversible via lineage. Body: asset_id, force. Response includes previous_name, canonical_name, lineage_id.

### POST /ram/validate
Run typed checks: link liveness, repo presence, deploy probe, hash dedupe, naming compliance. Body: asset_id, checks[]. Response: validation_score, status, checks{}, evidence[].

### POST /ram/uplift
Generate enriched companion artifacts (manifest, sidecar meta, summary) without modifying the original.

### POST /ram/package
Build a PKG_<project>_<purpose>_<YYYYMMDD-HHMM>.zip against listed asset ids.

### POST /ram/portfolio/generate
Emit one or more ram_portfolio_cards from validated assets. Body: brand, audience.

### POST /ram/reuse/mine
Extract reusable components (widgets, prompts, schemas, sales phrases) from validated assets.

### POST /ram/watch/scan
Nightly orphan/drift/ghost/dead-link sweep. Writes to ram_watch_events.

### GET /ram/assets
List assets with filter: source_system, evidence_state, asset_type, package_stem.

### GET /ram/portfolio/:brand
Return portfolio cards for a brand. Public surface uses v_ram_portfolio_real only.

### GET /ram/evidence/:asset_id
Return full evidence trail and validation history.

### POST /ram/dev/inspect
Submit a package for dev inspection. Body: package_stem, checks[]. Writes to ram_dev_inspections. Returns RCPT_ram_dev-inspection_<stem>.

### POST /ram/prod/promote
Promote a package to prod. Requires prior REAL ram_dev_inspections row. Writes to ram_prod_promotions and public.reality_ledger (status=REAL).

## Envelope rules

- troy-sql-executor calls use NESTED envelope
- All other RAM bridge calls use TOP-LEVEL envelope
- Multi-statement SQL forbidden; use run_sql RPC for DDL
- Verify writes via PostgREST direct read; troy-sql-executor masks pg errors and RETURNING

## Status semantics

- REAL: executed, receipted, ledger-written, telemetry-verified
- PARTIAL: scaffolded but unproven against internal data
- BLOCKED: explicit dependency, bounded reason

The RAM API will return PARTIAL for any endpoint until dogfood completion.
