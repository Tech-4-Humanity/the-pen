import { InstitutionalIntent, CoherenceSignals } from '../types/continuity';

export interface SpeedoInput {
  intents: InstitutionalIntent[];
  signals?: CoherenceSignals;
}

export interface SpeedoResult {
  operational_coherence: number;
  state: 'CALM' | 'WATCH' | 'DRIFTING' | 'HOT';
  explanation: string[];
}

function clamp(n: number): number {
  return Math.max(0, Math.min(100, Math.round(n)));
}

export function calculateContinuitySpeedo(input: SpeedoInput): SpeedoResult {
  const open = input.intents.filter((i) => i.state === 'OPEN' || i.state === 'IN_PROGRESS');
  const overdue = open.filter((i) => i.continuity_deadline && new Date(i.continuity_deadline).getTime() < Date.now()).length;
  const trustSensitive = open.filter((i) => i.human_state_impact === 'TRUST_SENSITIVE').length;
  const ambiguous = open.filter((i) => i.human_state_impact === 'AMBIGUOUS').length;
  const pretend = open.filter((i) => i.reality_status === 'PRETEND').length;
  const avgResidue = open.length ? open.reduce((sum, i) => sum + i.attention_residue_score, 0) / open.length : 0;

  let score = 100;
  score -= overdue * 12;
  score -= trustSensitive * 7;
  score -= ambiguous * 8;
  score -= pretend * 20;
  score -= avgResidue * 3;
  if (input.signals?.mental_fragmentation) score -= input.signals.mental_fragmentation * 2;
  if (input.signals?.continuity_trust) score += input.signals.continuity_trust * 1.5;

  const operational_coherence = clamp(score);
  const state = operational_coherence >= 80 ? 'CALM' : operational_coherence >= 65 ? 'WATCH' : operational_coherence >= 45 ? 'DRIFTING' : 'HOT';

  const explanation = [
    `${open.length} open continuity intents`,
    `${overdue} overdue continuity obligations`,
    `${trustSensitive} trust-sensitive open intents`,
    `${ambiguous} ambiguous open intents`,
    `${pretend} PRETEND open claims`,
  ];

  return { operational_coherence, state, explanation };
}
