# AML/CTF v2 Completeness Lockdown - Execution Report

Date: 2026-06-28
Repository: TML-4PM/the-pen

## Executive status

The AML/CTF v2 canonical workbook has been merged, published to GitHub, verified by SHA, deployed through Vercel, and supported by runtime receipt files.

This is not a full operational platform completion. It is the completion of the documentation, publication, deployment, and receipt baseline.

## Completed - REAL

| Component | Status | Evidence |
|---|---|---|
| Main branch recovery | REAL | main restored to 02684498a5c88c5a073db26b4975c186411531b4 before workbook publication |
| Canonical workbook | REAL | HalesRedden_AML_CTF_Framework_v12_merged.xlsx |
| Workbook GitHub publication | REAL | efc3fc49f5d5ea1fec1d845d2e0f80edb26c94ef |
| Workbook SHA256 | REAL | a7a55b3cdfe54b2b026121f3aa46f4717248ee2e1160e676b04fba6689b6753c |
| Workbook payload path | REAL | payloads/aml_ctf_v2_completeness_lockdown/HalesRedden_AML_CTF_Framework_v12_merged.xlsx |
| Runtime receipts | REAL | receipts/runtime/*.json |
| Static dashboard page | REAL | generated/dashboards/aml_ctf_v2/index.html |
| Vercel production deployment | REAL previous deployment | dpl_HSsWqjBeeyJkTs6UE6r4QweEn5zi was READY |
| Latest Vercel deploy attempt | UNKNOWN | dpl_3pQQzbGjHpQg7eAKWQrtayLwreRN returned UNKNOWN on CLI inspect |

## Receipt files created

- receipts/runtime/aml_ctf_v2_completeness_lockdown_receipt.json
- receipts/runtime/deployment_manifest.json
- receipts/runtime/github_publication_receipt.json
- receipts/runtime/workbook_integrity_receipt.json
- receipts/runtime/vercel_deploy_receipt.json

## Dashboard page created

- generated/dashboards/aml_ctf_v2/index.html

The dashboard page records the canonical workbook, GitHub publication, Vercel deployment, and current operational gaps.

## Vercel status

Known READY deployment:

- Deployment ID: dpl_HSsWqjBeeyJkTs6UE6r4QweEn5zi
- Project ID: prj_VGPFRbXPULFkrjFjkkkoqYorjBZB
- Alias: the-pen-six.vercel.app

Latest CLI deploy attempt:

- Deployment ID: dpl_3pQQzbGjHpQg7eAKWQrtayLwreRN
- URL: the-kswio19q2-troys-projects-t4h-machine.vercel.app
- CLI inspect status: UNKNOWN
- Action required: inspect logs, rerun deployment if needed, and update Vercel receipt if the latest deployment reaches READY.

## Still PARTIAL

| Area | Status | Required next step |
|---|---|---|
| Population of new governance tabs | PARTIAL | Complete obligation, control, owner, evidence, trigger, dashboard and review-test mappings |
| Supabase runtime model | PENDING | Create schema and import canonical workbook model |
| Dashboard v2 live operational metrics | PARTIAL | Connect dashboard to generated model or runtime database |
| Generated artefacts | PARTIAL | Generate policies, procedures, insurer packs, review packs and training artefacts from workbook |
| Pilot execution | NOT STARTED | Run 25-entity pilot and capture calibration metrics |
| Latest Vercel deployment | UNKNOWN | Resolve dpl_3pQQzbGjHpQg7eAKWQrtayLwreRN |

## Final classification

Documentation framework: REAL
Canonical workbook publication: REAL
GitHub receipts: REAL
Static dashboard artefact: REAL
Previous production deployment: REAL
Latest Vercel deployment: UNKNOWN
Runtime operating platform: PARTIAL
Supabase operational layer: PENDING
Pilot execution: NOT STARTED

## Next execution order

1. Fix or replace latest Vercel deployment and update receipt.
2. Populate the newly added governance sheets in the workbook.
3. Generate master coverage matrix from workbook data.
4. Create Supabase schema and ingestion path.
5. Generate downstream artefacts from canonical workbook.
6. Run pilot calibration.
