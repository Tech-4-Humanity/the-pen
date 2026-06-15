export type CognitionType =
  | 'INTENT'
  | 'DECISION'
  | 'FRAMEWORK'
  | 'GOVERNANCE_RULE'
  | 'CONTRADICTION'
  | 'DRIFT'
  | 'PLAYBOOK_CANDIDATE'
  | 'RITUAL_CANDIDATE'
  | 'HUMAN_STATE_SIGNAL'
  | 'OPERATIONAL_PAIN'
  | 'FREEZE_CANDIDATE';

export interface RawDocument {
  source_ref: string;
  title: string;
  text: string;
  created_at?: string;
}

export interface RecoveredCognition {
  source_ref: string;
  cognition_type: CognitionType;
  title: string;
  summary: string;
  extracted_intent?: string;
  semantic_cluster?: string;
  confidence: number;
  continuity_relevance: number;
  playbook_candidate: boolean;
  unresolved: boolean;
  contradictory: boolean;
  human_review_required: boolean;
  evidence_state: 'REAL' | 'PARTIAL' | 'PRETEND';
}

const patterns: Array<{ type: CognitionType; rx: RegExp; cluster: string }> = [
  { type: 'INTENT', rx: /\b(we need to|need to|should build|build|wire|codify|automate|sweeper)\b/i, cluster: 'execution_intent' },
  { type: 'GOVERNANCE_RULE', rx: /\b(must|never|no orphaned intent|freeze|production is earned|receipt|required|evidence)\b/i, cluster: 'governance' },
  { type: 'DRIFT', rx: /\b(drift|stale|forgotten|unresolved|quietly|parking lot|buried|not getting knowledge back)\b/i, cluster: 'continuity_drift' },
  { type: 'HUMAN_STATE_SIGNAL', rx: /\b(calm|clarity|overwhelm|fragmentation|residue|relief|easier|simpler|nicer|cognitive load)\b/i, cluster: 'human_state' },
  { type: 'PLAYBOOK_CANDIDATE', rx: /\b(checklist|playbook|framework|taxonomy|2042|2500|questions)\b/i, cluster: 'playbook' },
  { type: 'FREEZE_CANDIDATE', rx: /\b(reefreeze|re-freeze|stage gate|do not push|prod|production)\b/i, cluster: 'promotion_governance' },
];

export function recoverCognition(doc: RawDocument): RecoveredCognition[] {
  const sentences = doc.text.split(/(?<=[.!?])\s+|\n+/).map((s) => s.trim()).filter(Boolean);
  const recovered: RecoveredCognition[] = [];

  for (const sentence of sentences) {
    for (const p of patterns) {
      if (p.rx.test(sentence)) {
        recovered.push({
          source_ref: doc.source_ref,
          cognition_type: p.type,
          title: doc.title,
          summary: sentence.slice(0, 500),
          extracted_intent: p.type === 'INTENT' ? sentence : undefined,
          semantic_cluster: p.cluster,
          confidence: 0.72,
          continuity_relevance: p.type === 'DRIFT' || p.type === 'GOVERNANCE_RULE' ? 0.9 : 0.7,
          playbook_candidate: p.type === 'PLAYBOOK_CANDIDATE' || p.type === 'GOVERNANCE_RULE',
          unresolved: /\b(need|should|unresolved|missing|not yet|gap)\b/i.test(sentence),
          contradictory: /\b(but|however|contradiction|conflict)\b/i.test(sentence),
          human_review_required: p.type === 'GOVERNANCE_RULE' || p.type === 'FREEZE_CANDIDATE',
          evidence_state: 'PARTIAL',
        });
        break;
      }
    }
  }

  return recovered;
}

export function buildContinuityRecoveryDigest(items: RecoveredCognition[]) {
  const byType = items.reduce<Record<string, number>>((acc, item) => {
    acc[item.cognition_type] = (acc[item.cognition_type] || 0) + 1;
    return acc;
  }, {});
  return {
    recovered_count: items.length,
    by_type: byType,
    promotion_candidates: items.filter((i) => i.playbook_candidate).slice(0, 10),
    drift_candidates: items.filter((i) => i.cognition_type === 'DRIFT').slice(0, 10),
    human_review_required: items.filter((i) => i.human_review_required).slice(0, 10),
  };
}
