-- QUEUE SEED: ALL 29 JOBS
-- Source: dev/ promotion wave (commits c2cffbb + a6c7683)
-- Execute via: troy-sql-executor AFTER 20260507_queue_control_plane_v1.sql
-- Idempotent: YES (on conflict do nothing)

insert into public.t4h_job_queue
  (idempotency_key, job_key, priority, status, payload, source_path, env)
values

-- TIER 1: IMMEDIATE (priority 10)
('blood-donor-execution-hunt-20260506', 'blood_donor_execution_hunt', 10, 'QUEUED',
 '{"governed":true,"dry_run_only":true,"artifacts":["docs/blood-donor/DRY_RUN_PLAN.md","docs/blood-donor/GOVERNANCE_GUARDRAILS.md","command-centre/widgets/blood_donor_status_widget.json"]}'::jsonb,
 'dev/blood_donor_execution_hunt/job.md', 'dev'),

('mcp-google-drive-control-plane-20260506', 'mcp_google_drive_control_plane', 10, 'QUEUED',
 '{"issues":18,"primary_fix":"env_var_name_mismatch","tables":["t4h_secret_registry","t4h_connector_health"],"acceptance":"google_drive_probe_green_or_blocked_receipt"}'::jsonb,
 'dev/mcp_google_drive_control_plane/job.md', 'dev'),

-- TIER 2: CRITICAL INFRASTRUCTURE (priority 20)
('queue-control-plane-v1-20260507', 'queue_control_plane_v1', 20, 'QUEUED',
 '{"migration":"supabase/migrations/20260507_queue_control_plane_v1.sql","acceptance":"v_job_state_counts_returns_rows"}'::jsonb,
 'dev/queue_control_plane_v1/job.md', 'dev'),

('bridge-recovery-20260506', 'bridge_recovery', 20, 'QUEUED',
 '{"path":"actor->MCP->troy-sql-executor->fn_github_push->GitHub","acceptance":"full_path_real_or_each_step_has_named_blocker"}'::jsonb,
 'dev/bridge_recovery/job.md', 'dev'),

('coax-assignment-engine-20260428', 'coax_assignment_engine', 20, 'QUEUED',
 '{"spec":"handoffs/COAX_AssignmentEngine_BridgeDevPack_20260428.md"}'::jsonb,
 'dev/coax_assignment_engine/job.md', 'dev'),

-- TIER 3: COMMERCIAL (priority 30)
('close-funnel-system-001', 'close_funnel_system', 30, 'QUEUED',
 '{"lambda":"t4h-lead-webhook","table":"public.leads","stripe_price":"price_1TPXHrD6fFdhmypRl0fmEGMu","acceptance":"test_payment_creates_lead_row"}'::jsonb,
 'dev/close_funnel_system/job.json', 'dev'),

('innovateme-master-operating-model-20260428', 'innovateme_master_operating_model_closeout', 30, 'QUEUED',
 '{"actions":9,"rdti":true,"acceptance":"story_pages_render_and_stripe_checkout_creates_in_test"}'::jsonb,
 'dev/innovateme_master_operating_model_closeout/job.md', 'dev'),

('innovateme-golden-loop-replay-20260428', 'innovateme_golden_loop_replay', 30, 'QUEUED',
 '{"depends_on":"innovateme_master_operating_model_closeout","gates":7,"acceptance":"all_7_runtime_gates_real"}'::jsonb,
 'dev/innovateme_golden_loop_replay/job.md', 'dev'),

('monetisation-architecture-engine-20260429', 'monetisation_architecture_engine', 30, 'QUEUED',
 '{"spec":"handoffs/2026-04-29-monetisation-architecture-engine.md"}'::jsonb,
 'dev/monetisation_architecture_engine/job.md', 'dev'),

('cto-in-your-pocket-20260501', 'cto_in_your_pocket_product_wrapper', 30, 'QUEUED',
 '{"spec":"handoffs/CTO_In_Your_Pocket_Product_Wrapper_20260501.md"}'::jsonb,
 'dev/cto_in_your_pocket_product_wrapper/job.md', 'dev'),

('ops-solo-cto-pricing-20260430', 'ops_solo_cto_control_layer_pricing', 30, 'QUEUED',
 '{"spec":"handoffs/OPS_SoloCTO_ControlLayer_Priorities_Pricing_Handoff_20260430.md"}'::jsonb,
 'dev/ops_solo_cto_control_layer_pricing/job.md', 'dev'),

('holoorg-pricing-page-catalog-20260424', 'holoorg_pricing_page_catalog', 30, 'QUEUED',
 '{"csv":"handoffs/RPT_HoloOrg_Commercial_Launch_Matrix_Gap_Addendum_20260424.csv","output":"web/holoorg/pricing/"}'::jsonb,
 'dev/holoorg_pricing_page_catalog/job.md', 'dev'),

('vignette-commerce-engine', 'vignette_commerce_engine', 30, 'QUEUED',
 '{"spec_dir":"handoffs/vignette-commerce-engine/"}'::jsonb,
 'dev/vignette_commerce_engine/job.md', 'dev'),

-- SQL JOBS (priority 30 — run before InnovateME depends)
('outcome-ready-neuroprofile-engine-20260429', 'outcome_ready_neuroprofile_activity_engine', 30, 'QUEUED',
 '{"sql_source":"bridge_jobs/outcome_ready_neuroprofile_activity_engine_20260429.sql","must_run_first":true}'::jsonb,
 'dev/outcome_ready_neuroprofile_activity_engine/job.sql', 'dev'),

('outcome-ready-activity-seed-20260429', 'outcome_ready_activity_seed', 30, 'QUEUED',
 '{"sql_source":"bridge_jobs/outcome_ready_activity_seed_pack_10_more_20260429.sql","depends_on":"outcome_ready_neuroprofile_activity_engine"}'::jsonb,
 'dev/outcome_ready_activity_seed/job.sql', 'dev'),

('universal-funnel-system-v1', 'universal_funnel_system_v1', 30, 'QUEUED',
 '{"spec":"bridge_jobs/universal_funnel_system_v1.json"}'::jsonb,
 'dev/universal_funnel_system_v1/job.json', 'dev'),

-- TIER 4: RESEARCH (priority 40)
('dra-recovery-and-build-20260424', 'dra_recovery_and_build', 40, 'QUEUED',
 '{"tasks":7,"supabase_tables":9,"acceptance":"dra_substances_gte_7_rows_and_observations_gte_1"}'::jsonb,
 'dev/dra_recovery_and_build/job.json', 'dev'),

('dra-misfile-correction-v3-1', 'dra_misfile_correction_v3_1', 40, 'QUEUED',
 '{"depends_on":"dra_recovery_and_build","spec_dir":"handoffs/dra-misfile-correction-v3.1/"}'::jsonb,
 'dev/dra_misfile_correction_v3_1/job.md', 'dev'),

('research-engine-adhd-ai-drug-20260501', 'research_engine_adhd_ai_drug', 40, 'QUEUED',
 '{"spec":"handoffs/RPT_ResearchEngine_StrategyBridgeHandoff_ADHD-AI-Drug_20260501.md","feeds":"dra_recovery_and_build"}'::jsonb,
 'dev/research_engine_adhd_ai_drug/job.md', 'dev'),

('us-signal-browser-20260429', 'us_signal_browser', 40, 'QUEUED',
 '{"spec":"handoffs/2026-04-29-us-signal-browser-full-spec.md"}'::jsonb,
 'dev/us_signal_browser/job.md', 'dev'),

('linkedin-intelligence-audit-20260429', 'linkedin_intelligence_audit', 40, 'QUEUED',
 '{"spec_dir":"handoffs/linkedin-intelligence-audit-20260429/"}'::jsonb,
 'dev/linkedin_intelligence_audit/job.md', 'dev'),

-- TIER 5: BLOOD DONOR (priority 10 but BLOCKED until compliance)
('blood-donor-prod-20260506', 'blood_donor_execution_hunt_prod', 10, 'BLOCKED',
 '{"block_reason":"awaiting_authorised_partner_and_compliance_confirmation","dry_run_only":true}'::jsonb,
 'prod/blood_donor_execution_hunt/job.md', 'prod'),

-- TIER 6: REVIEW + CLOSE (priority 50)
('holoorg-simulations-closeout-20260424', 'holoorg_simulations_closeout', 50, 'QUEUED',
 '{"files":["handoffs/HoloOrg_Failure_Cases_Simulation_20260424.md","handoffs/HoloOrg_First_10_Customers_Simulation_20260424.md","handoffs/HoloOrg_Sample_Pricing_Page_Output_20260424.md"]}'::jsonb,
 'dev/holoorg_simulations_closeout/job.md', 'dev'),

('signal-mining-slice01-20260425', 'signal_mining_slice01_closeout', 50, 'QUEUED',
 '{"spec":"handoffs/signal-mining-slice-01-closure-chatgpt-20260425.md"}'::jsonb,
 'dev/signal_mining_slice01_closeout/job.md', 'dev'),

('augmented-humanity-org-profile', 'augmented_humanity_github_org_profile', 50, 'QUEUED',
 '{"spec_dir":"handoffs/augmented-humanity-github-org-profile/"}'::jsonb,
 'dev/augmented_humanity_github_org_profile/job.md', 'dev'),

('certification-os-rocket-20260426', 'certification_os_rocket', 50, 'QUEUED',
 '{"wip_dir":"WIP/Certification-OS-Rocket-20260426/"}'::jsonb,
 'dev/certification_os_rocket/job.md', 'dev'),

('predictive-capacity-activation', 'predictive_capacity_activation', 50, 'QUEUED',
 '{"spec_dir":"handoffs/predictive-capacity-activation/"}'::jsonb,
 'dev/predictive_capacity_activation/job.md', 'dev'),

('outcome-ready-site-rework-20260429', 'outcome_ready_site_rework', 50, 'QUEUED',
 '{"spec":"handoffs/outcome_ready_site_rework_build_handoff_20260429.md","deploy":"vercel"}'::jsonb,
 'dev/outcome_ready_site_rework/job.md', 'dev'),

('spec004', 'spec004', 50, 'QUEUED',
 '{"spec_dir":"handoffs/SPEC004/"}'::jsonb,
 'dev/spec004/job.md', 'dev')

on conflict (idempotency_key) do nothing;
