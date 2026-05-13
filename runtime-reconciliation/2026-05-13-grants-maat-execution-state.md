# Grants / MAAT / Command Centre Execution State — 2026-05-13

## Status
PARTIAL

## Why PARTIAL
The supplied transcript contains strong execution claims from Claude, including schema deployment, table/view/RPC confirmation, RLS confirmation, smoke testing, and active grant opportunity counts. However, this record is transcript evidence only until the MAAT Supabase instance is re-queried directly and receipts are captured.

## Source
User supplied browser/control-surface telemetry plus attached transcript extract titled around Grants - MAAT - R&D.

## Transcript claims captured

### Original intent
Build a proactive grant system that lives in MAAT, Supabase, and Command Centre.

Core instruction from prior thread:
- tables need to be in Supabase
- websites need to pull from Supabase, especially MAAT and Command Centre
- grant system lives in MAAT
- connect to data sources to pull information in
- dry run first
- fix blockers
- all enhancements approved

### Claimed build pack
Claude claimed a complete dry-run implementation pack with:
- `001_grants_full_ddl.sql`
- `supabase_db.py`
- `pipeline.py`
- `grant_pipeline_job.py`
- `bridge_tool_spec.json`
- `dry_run_validator.py`
- `.env.example`
- `requirements.txt`

### Claimed dry-run result
- 85/85 checks passed
- Zero SQLite
- Supabase/PostgREST blocker fixed by moving RPCs to public schema with `grants_*` prefix

### Claimed MAAT spine
`grants.grant_evidence_matrix` links:
- grant
- R&D project
- research study
- IP asset
- MAAT transaction
- evidence artefact

This is the key evidence/economic integrity chain.

### Claimed live database result
Claude later claimed execution completed against live Supabase:

```yaml
claimed_live_objects:
  schemas:
    - grants
    - cc
  tables:
    count: 10
    names:
      - opportunities
      - movements
      - themes
      - opportunity_themes
      - tasks
      - submissions
      - submission_checklist
      - submission_pack_versions
      - checklist_templates
      - grant_evidence_matrix
  rpc_functions:
    count: 5
    names:
      - grants_upsert_opportunities
      - grants_append_movements
      - grants_ensure_submissions
      - grants_ensure_default_checklist
      - grants_link_evidence
  cc_views:
    count: 8
    names:
      - v_grants_top10
      - v_grants_deadlines_60d
      - v_grants_changes_7d
      - v_grants_pipeline_by_stage
      - v_grants_submission_completeness
      - v_grants_evidence_matrix
      - v_grants_budget_vs_actual
      - v_grants_active_full
```

### Claimed data state
```yaml
claimed_data_state:
  active_opportunities: 24
  seed_themes: 17
  checklist_template_count: 1
  checklist_template_items: 8
  rls_enabled_on_tables: 10
  cc_views_returning_data: true
  rpc_functions_working: true
  smoke_test_chain:
    - upsert
    - movement
    - submission
    - checklist_8_items
    - evidence_link
```

### Claimed blocker fixed
Old schema had `movements.grant_id` as NOT NULL, blocking some operations. Claimed fix: made nullable.

## Outstanding items from transcript
```yaml
outstanding:
  - register_10_command_centre_queries_page_id_grants
  - register_ui_widgets_in_t4h_ui_snippet
  - update_memory_with_grants_system_state
  - reverify_live_supabase_objects
  - capture_runtime_receipts
  - wire_command_centre_grants_page_to_cc_views
```

## Runtime interpretation
This is not a grant side project. It is part of the commercialization/evidence runtime.

It binds:

```yaml
grants_runtime:
  to:
    - MAAT_financial_runtime
    - R&D_evidence_runtime
    - IP_asset_runtime
    - Command_Centre_reporting
    - proactive_opportunity_ingestion
    - submission_workflow
    - budget_vs_actual_tracking
```

## Why this matters
The grants system is a high-value economic loop because it converts research, IP, product work, and evidence artifacts into fundable opportunities.

The system should not be treated as admin. It should be treated as a revenue/evidence engine.

## Required verification SQL
Run against the MAAT/Ecosystem Supabase instance:

```sql
select schema_name
from information_schema.schemata
where schema_name in ('grants','cc')
order by schema_name;

select table_schema, table_name
from information_schema.tables
where table_schema = 'grants'
order by table_name;

select routine_schema, routine_name
from information_schema.routines
where routine_schema = 'public'
  and routine_name like 'grants_%'
order by routine_name;

select table_schema, table_name
from information_schema.views
where table_schema = 'cc'
  and table_name like 'v_grants_%'
order by table_name;

select count(*) as active_opportunities
from grants.opportunities
where coalesce(status, 'active') = 'active';
```

## Command Centre registration target
Create or verify grants CCQs for:
- Top 10 grant opportunities
- Deadlines next 60 days
- Recent changes last 7 days
- Pipeline by stage
- Submission completeness
- Evidence matrix
- Budget vs actual
- Active full grants list
- Task backlog
- Risk / missing evidence

## UI widget target
`t4h_ui_snippet` should receive a grants dashboard widget that reads from cc grants views and surfaces:
- active opportunities
- deadline pressure
- pipeline stage
- evidence completeness
- R&D/IP/MAAT linkage
- next required submission action

## Promotion criteria to REAL
```yaml
REAL_requires:
  - direct_supabase_verification_receipt
  - list_of_grants_tables_verified
  - list_of_cc_views_verified
  - list_of_public_grants_rpcs_verified
  - row_counts_captured
  - ccq_registration_receipt
  - t4h_ui_snippet_registration_receipt
  - command_centre_grants_page_render_proof
```

## Ledger
```yaml
ledger:
  task_id: grants_maat_execution_state_2026_05_13
  intent: preserve and classify grants/MAAT execution state from transcript telemetry
  execution: github_create_file
  status: PARTIAL
  evidence: pending_github_commit_sha
  pressure_flags:
    - transcript_execution_claims_not_runtime_verified_here
    - CCQ_registration_outstanding
    - widget_registration_outstanding
    - direct_database_receipt_required
  score: 0.89
  next_action:
    - reverify live Supabase grant objects
    - register grants CCQs
    - register t4h_ui_snippet widget
    - wire Command Centre grants page
    - capture runtime receipts
```
