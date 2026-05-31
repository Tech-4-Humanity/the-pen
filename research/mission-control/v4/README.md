# T4H Research Mission Control v4

Status: PARTIAL

This pack upgrades the research hub from a table catalogue into an operating model for research decisioning, evidence capture, asset generation, tax/R&D support, productisation, and business governance.

## Operating thesis

Research should not terminate in notes or reports. It should flow through:

```text
Theme -> Business Question -> Decision -> Activity -> Evidence -> Asset -> Product / Claim / Policy / Sale -> Receipt
```

## Business views included

- CEO: strategic differentiation, growth, partner leverage, board narrative.
- CTO: architecture, platforms, ingestion, automation, telemetry, reliability.
- Product: validated problems, customer journeys, feature evidence, reusable modules.
- Sales: proof points, objections, use cases, ROI stories, proposal assets.
- Marketing: narratives, campaigns, articles, visuals, audience pathways.
- Finance: cost allocation, ROI, capitalisation cues, budget linkage.
- Tax/R&D: eligible activities, contemporaneous evidence, labour/vendor/expense traceability.
- Legal/IP: invention capture, ownership, licensing, defensibility.
- Governance: ethics, privacy, consent, risk, audit trail.
- Operations: repeatable SOPs, owners, cadence, escalation.

## Core files expected in the v4 pack

- 00_manifest.md
- 01_operating_doctrine.md
- 02_research_mission_canvas.md
- 03_decision_engine.md
- 04_evidence_engine.md
- 05_business_care_model.md
- 06_tax_rd_care_model.md
- 07_asset_factory.md
- 08_monthly_close.md
- 09_command_centre_widget.md
- 10_bridge_handoff.json
- 11_supabase_schema.sql
- 12_reality_ledger.md
- worked_examples/
- templates/
- registers/

## Reality Ledger

status: PARTIAL
result: v4 operating manifest committed to GitHub canonical repo path.
evidence: GitHub create_file commit receipt from connector.
gaps:
- zip bundle not uploaded because current GitHub connector supports UTF-8 text files, not binary zip uploads.
- Bridge execution not confirmed yet.
- Supabase execution not confirmed yet.
next_action:
- Commit bridge handoff payload.
- Test available MCP/Bridge route.
- Route Supabase schema through Bridge executor when bridge authority is confirmed.
elevation: commit core files and preserve execution receipt.
pressure_flags:
- avoid table-only regression
- avoid simulated bridge/supabase completion
score: 0.72
