# Certification OS Rocket Pack

Date: 2026-04-26

## Status
Rocket-grade handoff for the HoloOrg 9x9 Certification OS.

## Destination
`TML-4PM/the-pen/WIP/Certification-OS-Rocket-20260426`

## Contents prepared
- Enhanced 81-level certification matrix retained
- Enhanced 9-level roll-up retained
- Provider summary retained
- All-staff baseline catalog retained
- 500-row certification expansion seed prepared
- 81 HoloOrg cluster reference prepared
- 1,219-row agent requirements seed prepared
- Supabase schema with RLS prepared
- Scoring engine and Reality Ledger function prepared
- Command Centre coverage and risk widgets prepared
- API contract prepared
- Bridge invocation payload prepared
- Revenue model prepared
- Runbook prepared

## Operating rule
Courses and certifications are for all staff across all business areas. Specialist credentials remain mapped to role clusters, but the all-staff baseline is treated as enterprise operating licence, not HR-only training.

## Reality Ledger Classification
Current state: PARTIAL.

Reason: artefacts and GitHub handoff are complete. Runtime becomes REAL only after Supabase deployment, CSV import, smoke tests, API binding, widget registration, and ledger evidence capture.

## Execution order
1. Apply schema/supabase_certification_os.sql
2. Apply engine/scoring_engine.sql
3. Import the certification, cluster, and agent requirement CSVs from the generated pack
4. Apply schema/seed_data.sql
5. Register widgets in Command Centre / t4h_ui_snippet
6. Expose API routes
7. Run smoke tests
8. Write Reality Ledger receipt

## Local pack
Generated local artefact: `RPT_CertificationOS_RocketPack_20260426.zip`

## Owner intent
Move this from enhanced files into a measurable, enforceable, monetisable Certification Operating System for the HoloOrg economy.