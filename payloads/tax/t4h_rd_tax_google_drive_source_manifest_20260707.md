# T4H AU R&D Tax Reconstruction — Google Drive Source Manifest

## Status

REAL for Google Drive discovery. PARTIAL for runtime ingestion until bridge worker consumes these source IDs and writes receipts.

## Purpose

Use Google Drive as a data/evidence source lane for the FY23, FY24 and FY25-current AU R&D tax reconstruction job.

Primary runtime job idempotency key:

`t4h-rd-tax-fy23-fy25-supabase-maat-factors-reconstruction-20260512`

Tracking issue: `TML-4PM/the-pen#219`

## Key Drive findings

### 1. Accountant pack covering FY2022-23 through FY2025-26

Drive file ID: `1_3qpfhcRPhglT4IORgJBot4g48dmnXK-`

Title: `T4H_Accountant_Pack_March2026.docx`

Important extracted facts:

- Entity: Tech 4 Humanity Pty Ltd.
- ABN shown: `61 605 746 618`.
- Period covered: FY2022-23, FY2023-24, FY2024-25, FY2025-26 YTD.
- Data source stated: MAAT system / Supabase SSOT.
- Views referenced: `v_rdti_by_fy`, `v_pl_t4h_by_fy`, `maat_bas_periods`, `maat_invoice_register`, `maat_div7a_rates`.
- Authoritative register: `maat_report_registry`, report code `FIN-PL-BAS`.

### 2. CFO Gap Analysis — prior year RDTI risk

Drive file IDs:

- `1G7biam-ss2wUugkFrsk5XP9YFU88_clK`
- `1XiwBSQrRs-ujm8tZrQ683vQ66HmdYcP6`

Title: `T4H_CFO_Gap_Analysis_Mar2026.docx`

Important extracted facts:

- Prior-year RDTI flagged CRITICAL.
- $1.83M claimed in `rd_evidence_matrix` for FY22-23 and FY23-24, but no confirmed lodgements found.
- MAAT records:
  - FY22-23: $432,600 spend / $195,097 rebate claimed.
  - FY23-24: $1,397,800 spend / $608,393 rebate claimed.
  - FY22-23: no AusIndustry registration on record.
  - FY23-24: programs registered: `7D-DCP` and `ASS`, covering FY2023/24 to FY2024/25.
  - FY23-24 timesheets: 2,795.6 hours / 108 entries reconstructed from invoices.
- Required action in source doc: confirm FY22-23 and FY23-24 RDTI lodgements with AusIndustry.

### 3. FY2024-25 final AusIndustry lodgement pack

Drive file IDs:

- `1eYpBA1_y0S2k41L4Qi9kkljmceekkaV9`
- `1p43ZvskxKBkH7yBv5nSo15pSOGyiEI7g`
- `1zpcUwbAzquamzSv8xWs0or5-asSHV_IW`

Title: `T4H_RDTI_AusIndustry_LodgementPack_FINAL_20260320.docx`

Important extracted facts:

- FY2024-25 AusIndustry registration pack.
- ABN shown: `61 605 746 618`.
- Source: MAAT / Supabase project `lzfgigiyqpuuxslsygjt`.
- Status: validated `21/21` against live data on 20 March 2026.
- Evidence anchors:
  - `maat_invoice_register`: 40 invoices at $500/hour.
  - `maat_timesheets`: 299 entries / 3,184.52 hours.
  - `rdti_narrative_register`: R01-R10 portal-ready activity text.
- Total eligible R&D expenditure: `$2,136,791`.
- RDTI refundable offset at 43.5%: `$929,504`.
- Bank R&D: 527 transactions totalling `$544,541`.
- MAAT processed 6,038 transactions across 10 bank accounts with SHA256 deduplication, BAS label automation, and RDTI cost-classification pipelines.
- Registered activity examples include `R10 — MAAT Financial Intelligence System — R&D Evidence Automation` under programme `ASS`.

### 4. Cover letter to Gordon / Hales Redden

Drive file IDs:

- `1qmlJyPHS7dbmWFRgb36potS0ef4Bw57q`
- `1DoqF0igzqVMueDSjpW-ACOvcTWJ2xFkq`

Title: `T4H_CoverLetter_Gordon_RDTI_Pack_20260320.docx`

Important extracted facts:

- Recipient: Gordon McKirdy, Hales Redden.
- States FY2024-25 RDTI pack was lodged or ready for submission with AusIndustry; worker must verify exact lodgement state rather than assume lodged.
- Canonical FY2024-25 eligible expenditure: `$2,136,791`.
- RDTI refundable offset: `$929,504`.
- Bank R&D: AWS, Vercel, Supabase, AI APIs, cloud infrastructure — 324 transactions / `$544,541`.
- ABN correction note: `70 666 271 272` is ACN; ABN is `61 605 746 618`.
- Earlier figure `$533,425` omitted `$1.59M` director labour.
- FY2024-25 BAS: four quarters calculated in MAAT; total GST refundable `$22,798`; accountant review required before ATO lodgement.

### 5. Contemporaneous records pack and response to Statement of Issues

Drive file IDs:

- `1C6rYt0XFSut9RZUmdy8m-FfA8NkpX7kV`
- `1UD2auSe-QSvY3A_SMlHiVLmIxYFrj_it`
- `1VmonZtgQrAjNLI4O0TRQvg0nV74cgcEh`
- `1VZfyTX2QNMCLVOkoUBBFZujy3YXOLIm9`
- `1inToa8dJcrRuheiLEXLZGyGFTSBl3M3U`

Important extracted facts:

- CRP document reference: `T4H-RDTI-CRP-FY2425`.
- Compiled: 13 February 2026.
- AusIndustry registration deadline: 30 April 2026.
- Statement of Issues response reference: `2425-AP00-063-843`.
- Income year: 2024-2025.
- Examination core activity: `CA1 — Multi-Agent AI Orchestration`.
- Activity code: `PKK0VJBBH`.
- Evidence references use sub-experiment codes `MAO-001` through `MAO-008`.
- Seed response prepared for tax-agent review by Gordon McKirdy and Andrew Douglas (Hales Redden & Partners).

### 6. Official guidance files in Drive

Drive file IDs:

- `19IAwtVd7P_r2IqH1iEataPnXjU98L4WC` — R&D tax incentive schedule 2025 instructions.
- `1Ru2qKuI5rIWWL-V7WXK1g49XANkq4fmb` — Software-related activities and RDTI guide.
- `1plRc-GB2-8pv77uJHx-zbTjQm0J02Pus` — RDTI registration application form questions.
- `1oA_fD3Nco71X3cAidKeSU-Ztp0WDV0NC` — T4H R&D Tax Incentive Policy v1.0.

## Material changes to earlier package

The earlier placeholder model estimated FY24-25 current eligible R&D at approximately `$864,000`. Google Drive evidence points to a MAAT-validated canonical FY2024-25 eligible amount of `$2,136,791` and refundable offset of `$929,504`.

The runtime worker must therefore:

1. treat the earlier placeholder model as superseded for FY24-25;
2. use the Drive/MAAT final lodgement pack as the primary FY24-25 evidence source;
3. reconcile FY22-23/FY23-24 prior-year claims from CFO Gap Analysis and MAAT tables;
4. verify lodgement status before classifying any return/registration as lodged;
5. flag ABN/ACN discrepancy and use ABN `61 605 746 618` unless accountant confirms otherwise.

## Runtime action required

Update job `tax.rd_reconstruct_from_supabase` to also inspect these Google Drive file IDs and cross-link them to Supabase objects:

- `v_rdti_by_fy`
- `rd_evidence_matrix`
- `maat_timesheets`
- `maat_invoice_register`
- `rdti_narrative_register`
- `maat_report_registry`
- `maat_transactions`
- `maat_bas_periods`

## Required outputs after Drive + Supabase reconciliation

1. FY22-23, FY23-24, FY24-25 and FY25-26 YTD RDTI summary.
2. Split between lodged, ready-to-lodge, and unconfirmed-lodgement status.
3. Evidence table linking Supabase tables/views to Drive file IDs.
4. Corrected accountant-facing one-page status brief.
5. Updated gap register.
6. Runtime receipt under `receipts/runtime/`.

## Current classification

| Layer | State |
|---|---|
| Google Drive discovery | REAL |
| Drive source manifest | REAL after commit |
| Runtime ingestion | PENDING |
| Supabase reconciliation | PENDING |
| Tax lodgement status | PARTIAL / unverified |
