# 99_ram_dogfood_completion_checklist.md

## Definition
RAM is REAL only when every box below is checked AND has typed evidence (commit_id, api_response, db_result, receipt, hash, log, url with 2xx).

## Closure status as of 2026-05-12
- Build artifacts lodged: YES (this package)
- Internal data ingested: NO -> RAM stays PARTIAL

## Checklist (Reality Ledger gates)

### Schema layer
- [ ] `public.ram_assets` exists with declared shape
- [ ] `public.ram_asset_locations` exists
- [ ] `public.ram_asset_hashes` exists
- [ ] `public.ram_asset_lineage` exists
- [ ] `public.ram_asset_validation` exists
- [ ] `public.ram_asset_evidence` exists
- [ ] `public.ram_packages` exists
- [ ] `public.ram_portfolio_cards` exists
- [ ] `public.ram_reuse_components` exists
- [ ] `public.ram_watch_events` exists
- [ ] `public.ram_dev_inspections` exists
- [ ] `public.ram_prod_promotions` exists
- [ ] RLS enabled on all 12 tables
- [ ] `v_ram_portfolio_real` view exists

### Runtime layer
- [ ] `ram-normalizer` Lambda deployed
- [ ] `ram-validator` Lambda deployed
- [ ] `ram-portfolio` Lambda deployed
- [ ] Bridge allowlist updated for `ram-*`
- [ ] Kill switch wired in `cap_secrets`
- [ ] RDTI tags applied (`is_rd=true`, `project_code=RAM-DGF-2026Q4`)

### UI layer
- [ ] 9 widgets registered in `t4h_ui_snippet`
- [ ] RAM Health widget rendering live data
- [ ] RAM Portfolio Map widget rendering at least one REAL card
- [ ] RAM Dev Inspection widget showing current status
- [ ] RAM Prod Promotion widget showing gate state

### Data layer (dogfood)
- [ ] At least one repo ingested from `TML-4PM`
- [ ] At least 25 assets normalised
- [ ] At least 10 assets with REAL evidence
- [ ] At least 5 portfolio cards generated
- [ ] At least one validation summary report
- [ ] No PRETEND state anywhere
- [ ] Counts pulled live from registry (never hardcoded)

### Gate layer
- [ ] Dev inspection submitted
- [ ] Dev inspection REAL (all 10 checks pass)
- [ ] `RCPT_ram_dev-inspection_*` written to `audit.log`
- [ ] Prod promotion submitted
- [ ] Prod promotion REAL
- [ ] `RCPT_ram_prod-promotion_*` written to `audit.log`
- [ ] `public.reality_ledger` row for RAM has status=REAL with typed evidence

### Telemetry layer
- [ ] FAR-CAGE records RAM agent actions
- [ ] STAMP approvals (where required) logged
- [ ] Telegram broadcasts dispatched
- [ ] All 10 telemetry streams active

## Completion declaration
When every box above is checked, AND each check is paired with typed evidence, RAM is REAL.

Until then, RAM is PARTIAL by doctrine, and the system honestly reports as such on every surface.

## Final rule
No human flips RAM to REAL.
RAM flips itself to REAL when its own gates pass.
That is the dogfood.
