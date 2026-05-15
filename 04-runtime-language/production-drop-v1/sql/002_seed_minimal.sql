-- ============================================================
-- Runtime Language OS — minimal working baseline seed
-- Idempotent via ON CONFLICT.
-- Applied to Supabase S1 (lzfgigiyqpuuxslsygjt) on 2026-05-16
-- ============================================================

insert into ops.ontology_state_transitions
  (id, from_state, to_state, verb, authority, evidence_required, failure_state, timeout_value, notes) values
  ('st_0001','received','normalised','normalise','agent',false,'invalid_input',interval '5 minutes','Input converted into canonical task shape.'),
  ('st_0002','normalised','compiled','compile','bridge',true,'compile_failed',interval '5 minutes','Bridge creates executable plan.'),
  ('st_0003','compiled','posted','post','bridge',true,'post_failed',interval '5 minutes','Artifact or instruction posted to target surface.'),
  ('st_0004','posted','executed','execute','runtime',true,'runtime_failed',interval '10 minutes','Runtime completes action and emits evidence.'),
  ('st_0005','executed','validated','validate','validator',true,'validation_failed',interval '10 minutes','Evidence checked against expectation.'),
  ('st_0006','validated','evidenced','record','evidence_engine',true,'evidence_missing',interval '5 minutes','Receipt is written.'),
  ('st_0007','evidenced','closed_for_human','surface','command_centre',true,'human_surface_missing',interval '24 hours','Human-visible status exists.')
on conflict (id) do update set notes = excluded.notes;

insert into ops.ontology_closure_chain (id, state, requires, evidence, may_claim_done, ordering) values
  ('cc_0001','closed_for_operator','work_done','artifact_or_log',true,1),
  ('cc_0002','closed_for_bridge','closed_for_operator+bridge_receipt','bridge_receipt',true,2),
  ('cc_0003','closed_for_runtime','closed_for_bridge+runtime_execution','runtime_receipt',true,3),
  ('cc_0004','closed_for_human','closed_for_runtime+visible_status','human_surface',true,4)
on conflict (id) do update set
  requires = excluded.requires,
  evidence = excluded.evidence,
  ordering = excluded.ordering;

insert into ops.ontology_connectors (id, name, surface, status, last_checked, notes) values
  ('conn_github','github','repo','healthy', now(), 'Canonical operator receipt surface. T4H MCP github_bulk_dispatch verified.'),
  ('conn_supabase','supabase','state_store','healthy', now(), 'Runtime state store via Official Supabase Claude Connector.'),
  ('conn_bridge','bridge','execution_spine','degraded', now(), 'Bridge keys 401. SQL routes via Supabase MCP. Bridge reserved for AWS/Vercel/GitHub.'),
  ('conn_notion','notion','human_surface','unknown', now(), 'Notion reachable; parent contracts pending.'),
  ('conn_command_centre','command_centre','dashboard','unknown', now(), 'Executive exception surfaces pending activation.'),
  ('conn_vercel','vercel','deploy_status','healthy', now(), 'Vercel deploy evidence via T4H MCP.')
on conflict (id) do update set
  status = excluded.status,
  last_checked = excluded.last_checked,
  notes = excluded.notes;

-- 25 test cases (one per implementation workstream)
insert into ops.ontology_test_cases (id, workstream, description, expected_outcome, status) values
  ('tc_01','01_nouns','create ontology node loader for nouns','noun rows present with required fields','pending'),
  ('tc_02','02_verbs','create verb registry and canonical action resolver','verb -> action mapping resolves','pending'),
  ('tc_03','03_states','create state registry and state validator','illegal transition rejected','pending'),
  ('tc_04','04_closure','implement closure chain engine','human closure requires runtime closure','pending'),
  ('tc_05','05_evidence','implement evidence type registry and validator','REAL requires typed evidence','pending'),
  ('tc_06','06_authority','implement authority resolver','unauthorised state change blocked','pending'),
  ('tc_07','07_escalation','implement escalation rules and timeout detector','timeout creates escalation receipt','pending'),
  ('tc_08','08_offboarding','implement offboarding capture and authority removal','authority removed after transfer','pending'),
  ('tc_09','09_personal_vocabulary','implement Troy vocabulary profile resolver','no hitl maps to autonomous execution allowed','pending'),
  ('tc_10','10_relationships','implement ontology edge loader','edges validate source/target exist','pending'),
  ('tc_11','11_state_transitions','implement transition engine','evidence-required transition fails without evidence','pending'),
  ('tc_12','12_runtime_surfaces','implement surface registry','closure target requires matching surface','pending'),
  ('tc_13','13_intents','implement intent classifier and canonical action router','finish_task routes to closure engine','pending'),
  ('tc_14','14_obligations','implement obligation checker','task without owner fails','pending'),
  ('tc_15','15_receipts','implement receipt writer and schema validator','receipt ids unique and required fields enforced','pending'),
  ('tc_16','16_failure_patterns','implement failure classifier','operator_done_only -> PARTIAL','pending'),
  ('tc_17','17_human_signal','implement human language signal detector','waiting maps to blocked','pending'),
  ('tc_18','18_execution_grammar','implement verb-to-action runtime grammar','send requires acknowledgement','pending'),
  ('tc_19','19_executive_surfaces','implement executive queries/widgets','exceptions surface by default','pending'),
  ('tc_20','20_translation_map','implement profile-aware translator','profile-specific mapping overrides generic','pending'),
  ('tc_21','21_workflow_patterns','implement workflow pattern registry','pattern expands into ordered steps','pending'),
  ('tc_22','22_ownership_graph','implement ownership graph and failure owner resolver','handoff requires next_owner','pending'),
  ('tc_23','23_closure_chain','implement closure progression guard','higher closure cannot skip lower','pending'),
  ('tc_24','24_runtime_objects','implement runtime object model','required fields enforced','pending'),
  ('tc_25','25_language_drift','implement drift detector and remediation queue','detects multiple meanings for same term','pending')
on conflict (id) do update set
  description = excluded.description,
  expected_outcome = excluded.expected_outcome;

insert into ops.ontology_reviewers (id, reviewer, role, status, notes) values
  ('rev_bridge_operator','bridge_operator','bridge','unassigned','Test Bridge ingest and receipt emission.'),
  ('rev_runtime_operator','runtime_operator','runtime','unassigned','Test runtime table reads/writes and observability.'),
  ('rev_human_reviewer','human_reviewer','human','unassigned','Verify Command Centre surfacing.'),
  ('rev_external_agent','external_agent','external','unassigned','Independent connector validation.')
on conflict (id) do nothing;

-- Operator receipt for production drop v1
insert into ops.ontology_receipts
  (id, task_id, receipt_type, closure_level, actor, classification, evidence, status) values
  ('receipt_op_20260516_prod_drop_v1',
   'language_ontology_contract_v1_20260515',
   'operator',
   'closed_for_operator',
   'claude_opus_4_7',
   'PARTIAL',
   jsonb_build_object(
     'repo','TML-4PM/the-pen',
     'contract_path','04-runtime-language/LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.md',
     'production_drop_path','04-runtime-language/production-drop-v1',
     'schema_applied','ops.ontology_* additive migration runtime_language_production_drop_v1_schema',
     'issue','#113'
   ),
   'PARTIAL')
on conflict (id) do nothing;

-- Runtime receipt — schema applied, seed loaded
insert into ops.ontology_receipts
  (id, task_id, receipt_type, closure_level, actor, classification, evidence, status) values
  ('receipt_rt_20260516_prod_drop_v1',
   'language_ontology_contract_v1_20260515',
   'runtime',
   'closed_for_runtime',
   'supabase_s1',
   'REAL',
   jsonb_build_object(
     'project_id','lzfgigiyqpuuxslsygjt',
     'migration','runtime_language_production_drop_v1_schema',
     'seed_rows','closure_chain:4, state_transitions:7, connectors:6, test_cases:25, reviewers:4'
   ),
   'REAL')
on conflict (id) do nothing;

insert into ops.ontology_receipt_ledger (receipt_id, task_id, event, current_hash, payload) values
  ('receipt_op_20260516_prod_drop_v1',
   'language_ontology_contract_v1_20260515',
   'operator_receipt_written',
   md5('receipt_op_20260516_prod_drop_v1:operator_receipt_written'),
   jsonb_build_object('actor','claude_opus_4_7','source','runtime_language_production_drop_v1')),
  ('receipt_rt_20260516_prod_drop_v1',
   'language_ontology_contract_v1_20260515',
   'runtime_receipt_written',
   md5('receipt_rt_20260516_prod_drop_v1:runtime_receipt_written'),
   jsonb_build_object('actor','supabase_s1','source','runtime_language_production_drop_v1'));
