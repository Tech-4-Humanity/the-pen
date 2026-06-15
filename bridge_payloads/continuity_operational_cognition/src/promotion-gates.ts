import { EvidenceState, InstitutionalIntent } from '../types/continuity';

export type PromotionStage =
  | 'CAPTURED'
  | 'SHAPING'
  | 'STAGED'
  | 'OBSERVABLE'
  | 'HUMAN_VALIDATED'
  | 'CONTINUITY_TESTED'
  | 'TRUSTED'
  | 'PROMOTABLE'
  | 'PRODUCTION';

export type PromotionDecision = 'BLOCK' | 'HOLD' | 'ADVANCE' | 'PROMOTE';

export interface PromotionEvidence {
  runtime_receipt?: string;
  telemetry_receipt?: string;
  replay_receipt?: string;
  human_validation_receipt?: string;
  continuity_test_receipt?: string;
  rollback_path?: string;
  reality_status: EvidenceState;
  active_freeze_conflict?: boolean;
  unresolved_ambiguity?: boolean;
  orphaned_intent_risk?: boolean;
}

export interface PromotionAssessment {
  decision: PromotionDecision;
  allowed_stage: PromotionStage;
  reasons: string[];
  missing: string[];
}

export function assessPromotion(intent: InstitutionalIntent, evidence: PromotionEvidence): PromotionAssessment {
  const missing: string[] = [];
  const reasons: string[] = [];

  if (evidence.active_freeze_conflict) missing.push('active_freeze_conflict');
  if (evidence.unresolved_ambiguity) missing.push('unresolved_ambiguity');
  if (evidence.orphaned_intent_risk) missing.push('orphaned_intent_risk');
  if (intent.reality_status !== 'REAL' || evidence.reality_status !== 'REAL') missing.push('REAL_evidence_state');
  if (!evidence.runtime_receipt) missing.push('runtime_receipt');
  if (!evidence.telemetry_receipt) missing.push('telemetry_receipt');
  if (!evidence.rollback_path) missing.push('rollback_or_recovery_path');

  if (missing.length > 0) {
    reasons.push('Production is earned, not assumed. Intent cannot promote while evidence or freeze checks are incomplete.');
    return { decision: 'BLOCK', allowed_stage: 'STAGED', reasons, missing };
  }

  if (!evidence.human_validation_receipt) {
    return { decision: 'HOLD', allowed_stage: 'OBSERVABLE', reasons: ['Runtime exists but human validation is missing.'], missing: ['human_validation_receipt'] };
  }

  if (!evidence.continuity_test_receipt || !evidence.replay_receipt) {
    return { decision: 'HOLD', allowed_stage: 'HUMAN_VALIDATED', reasons: ['Human validation exists but continuity/replay proof is incomplete.'], missing: ['continuity_test_receipt', 'replay_receipt'].filter((m) => !(evidence as any)[m]) };
  }

  return { decision: 'PROMOTE', allowed_stage: 'PROMOTABLE', reasons: ['Promotion legitimacy requirements satisfied.'], missing: [] };
}
