# TrustOS AML Risk Engine v0.1 Bridge Payload

Status: PARTIAL — package compiled and posted-ready. Production deployment still requires calibration against real client data, legal review of obligation mappings, and live-source API credentials.

## Contents

- `workbooks/trustos_aml_risk_seed_v0_1.xlsx` — Excel pilot workbook with domains, factors, overrides, mitigations, event triggers, scenarios, pilot inputs, dashboard, and source register.
- `data/factor_catalogue.json` — machine-readable domain and factor catalogue.
- `data/factor_catalogue.csv` — importable factor table.
- `schema/supabase_schema.sql` — Supabase/Postgres schema.
- `runtime/risk_engine.ts` — TypeScript scoring function.
- `runtime/sample_input.json` — example customer input.
- `papers/aim_objectives.md` — short paper/positioning note.
- `bridge/inbox/trustos_aml_risk_engine_v0_1.json` — bridge-runner job descriptor.
- `receipts/manifest.json` — generated file ledger and checksums.

## Pilot Aim

Build and test an evidence-based, event-driven AML/CTF risk engine that removes unnecessary subjective human assessment, automates source gathering, and leaves humans accountable for thresholds, approvals, and enhanced due diligence.

## Primary Sources

- AUSTRAC CDD: https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/your-amlctf-program/customer-due-diligence
- AUSTRAC risk assessment: https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/your-amlctf-program/develop-your-amlctf-programs/step-2-identify-and-assess-your-risks
- AUSTRAC SOF/SOW: https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/your-amlctf-program/customer-due-diligence/source-funds-and-source-wealth
- AUSTRAC ECDD: https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/your-amlctf-program/customer-due-diligence/enhanced-customer-due-diligence
- FATF Recommendations: https://www.fatf-gafi.org/en/publications/Fatfrecommendations/Fatf-recommendations.html
- FATF Virtual Assets: https://www.fatf-gafi.org/en/publications/Fatfrecommendations/targeted-update-virtual-assets-vasps-2025.html

## Bridge Runner Instructions

1. Pull this payload from the Pen inbox.
2. Validate file hashes in `receipts/manifest.json`.
3. Import `schema/supabase_schema.sql` into the pilot Supabase project.
4. Import `data/factor_catalogue.json` into `trustos_domains` and `trustos_risk_factors`.
5. Deploy `runtime/risk_engine.ts` into the scoring service.
6. Run `runtime/sample_input.json` through the scoring function.
7. Produce runtime receipt with:
   - import counts
   - schema migration status
   - scoring test output
   - dashboard/workbook presence
   - errors and recovery action if any

## Classification

- Workbook generated: REAL
- Local payload compiled: REAL
- GitHub post: connector-receipted for text artefacts
- Runtime deployment: ASPIRATIONAL until bridge runner executes
