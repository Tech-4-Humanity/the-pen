#!/usr/bin/env node

/**
 * T4H Corpus Intelligence Runner Stub
 *
 * Contract-first runner. It does not pretend extraction has run.
 * It defines the receipts, gates, delta classes, and output shape the real runner must satisfy.
 */

const now = new Date().toISOString();
const runId = `corpus-intel-${now}`;

const output = {
  run_id: runId,
  status: 'CONTRACT_READY_RUNTIME_PENDING',
  purpose: 'Extract missed business value, reusable assets, weak signals, recomposition candidates, and operational deltas.',
  anti_summary_gate: {
    rule: 'Fail if high-frequency obvious portfolio centres dominate before weak signals, hidden assets, orphan opportunities, contradictions, and recomposition candidates.',
    status: 'NOT_EVALUATED'
  },
  phase_1_sources: [
    'github_issue',
    'github_repo_docs',
    'single_chat_export_bundle'
  ],
  outputs_required: [
    'CORPUS_AUDIT_V1',
    'ASSET_REGISTRY_DELTA',
    'SHADOW_REGISTER_DELTA',
    'MARKET_CUSTOMER_DELTA',
    'PRODUCT_RECOMPOSITION_CANDIDATES',
    'OPERATIONAL_DELTA_V1',
    'GRAPH_EDGES',
    'NEXT_ACTIONS',
    'RECEIPTS'
  ],
  delta_classes: [
    'new',
    'changed',
    'disappeared',
    'duplicated',
    'contradicted',
    'promoted',
    'demoted',
    'merged',
    'superseded'
  ],
  scoring_required: [
    'evidence_strength',
    'source_count',
    'recency_score',
    'reuse_potential',
    'revenue_potential',
    'execution_readiness',
    'confidence'
  ],
  recomposition_chain: 'asset -> capability -> product -> customer_segment -> market -> revenue_path -> next_action',
  build_rule: 'reuse_before_build; build_delta_only',
  command_interpreter: {
    triggers: ['go', 'next', 'build', 'finish', 'create', 'complete', 'launch', 'deploy'],
    interpretation: 'reuse-first autonomous execution with verification and receipt; ask only at authority boundary'
  },
  no_hitl_boundary: [
    'new_credentials',
    'new_secrets',
    'new_external_authority',
    'legal_acceptance',
    'money_movement',
    'irreversible_external_commitment'
  ],
  survivability_target_hours: 36,
  survivability_checks: [
    'scheduled_run',
    'ingestion_success',
    'extraction_success',
    'registry_update',
    'receipt_written',
    'fault_detected',
    'retry_attempted',
    'recovery_verified',
    'escalation_only_at_authority_boundary'
  ],
  receipt_contract: {
    run_id: runId,
    source_set: [],
    object_counts: {},
    deltas_found: [],
    actions_created: [],
    files_written: [],
    issues_created_or_updated: [],
    blockers: [],
    next_run_trigger: null,
    status: 'PARTIAL_CONTRACT_ONLY'
  },
  next_action: 'Wire phase-1 ingestion from GitHub issues, repo docs, and one chat export bundle; then generate CORPUS_AUDIT_V1 from real sources.'
};

console.log(JSON.stringify(output, null, 2));
