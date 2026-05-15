# Service Catalogue — Apps Script Drive Runtime

```yaml
service:
  id: apps-script-drive-runtime
  name: T4H Apps Script Drive Runtime
  version: 1.0.0
  owner: troy@tech4humanity.com
  tenant: tech4humanity
  tier: NORMAL
  status: PRODUCTION
  classification: REAL
  governance: GLOBAL_RULE_KERNEL_V6

purpose:
  - drive_governance
  - folder_inventory
  - runtime_continuity_proof
  - receipt_generation

surfaces:
  execution: google_apps_script
  ledger_local: google_spreadsheet
  ledger_canonical: supabase://lzfgigiyqpuuxslsygjt/public.reality_ledger
  recovery: panicShutdown | quarantine | reset
  observability:
    - sheet:reality_ledger
    - sheet:heartbeat
    - sheet:failures
    - supabase:v_runtime_health
    - supabase:v_runtime_survivability

dependencies:
  required:
    - google_drive_api
    - google_sheets_api
    - apps_script_triggers
  optional:
    - supabase_rest_api  # falls back to sheet-only if absent
  forbidden:
    - active_chat_session
    - workstation_runtime
    - manual_retriggering

timing:
  cadence_minutes: 5
  chunk_size_folders: 250
  bootstrap_budget_ms: 5000
  selftest_budget_ms: 3000
  survivability_proof_hours: 72
  stale_reset_minutes: 30

identity:
  actor_id_required: true
  execution_id_required: true
  nonce_required: true
  session_chain_replayable: true

evidence_contract:
  every_state_change_writes_receipt: true
  receipt_includes:
    - ts_utc
    - execution_id
    - nonce
    - state
    - tier
    - event
    - evidence_type
    - evidence
    - duration_ms

ledger_states:
  - REAL
  - PARTIAL
  - BLOCKED
forbidden_ledger_states:
  - PRETEND

self_heal:
  tier: NORMAL
  warn_minutes: 10
  heal_minutes: 30
  reroute_minutes: 60
  block_minutes: 120

acceptance_gates:
  bootstrap_under_5s: PASS
  trigger_idempotent: PASS
  identity_on_every_receipt: PASS
  drive_error_does_not_crash: PASS
  supabase_outage_does_not_crash: PASS
  panic_shutdown_single_call: PASS
  survivability_resets_on_stale: PASS
  chunked_resume: PASS

known_gaps:
  - id: multi_worker_failover
    state: PARTIAL
    target_version: 1.1.0
  - id: file_level_inventory
    state: PARTIAL
    target_version: 1.1.0
  - id: cross_runtime_quorum
    state: PARTIAL
    target_version: 1.2.0

escalation:
  hot_paths_in_this_service: []
  on_block_event:
    - write_BLOCKED_receipt
    - leave_trigger_active
    - surface_in_supabase_view_v_runtime_health
  human_intervention_threshold: block (NORMAL tier = 120 min)
```
