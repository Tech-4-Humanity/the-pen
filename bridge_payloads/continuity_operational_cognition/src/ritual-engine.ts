import { InstitutionalIntent, MorningBrief, EveningClosure } from '../types/continuity';

function byWeight(a: InstitutionalIntent, b: InstitutionalIntent): number {
  return (b.continuity_cost + b.attention_residue_score) - (a.continuity_cost + a.attention_residue_score);
}

export function inferPosture(intents: InstitutionalIntent[]): string {
  const highDrift = intents.filter((i) => i.state === 'OPEN' && (i.attention_residue_score >= 7 || i.continuity_cost >= 7)).length;
  const trust = intents.filter((i) => i.continuity_class === 'HUMAN_TRUST' && i.state === 'OPEN').length;
  if (trust > 0) return 'follow-through and trust preservation';
  if (highDrift > 2) return 'closure and stabilization';
  return 'calm execution';
}

export function generateMorningBrief(intents: InstitutionalIntent[]): MorningBrief {
  const open = intents.filter((i) => i.state === 'OPEN' || i.state === 'IN_PROGRESS');
  const posture = inferPosture(open);
  const top = [...open].sort(byWeight).slice(0, 3);
  const drift = open
    .filter((i) => i.human_state_impact === 'TRUST_SENSITIVE' || i.human_state_impact === 'AMBIGUOUS' || i.attention_residue_score >= 7 || i.continuity_cost >= 7)
    .sort(byWeight)
    .slice(0, 3);

  return {
    posture,
    top_priorities: top.map((i) => `${i.title} — ${i.intent_description}`),
    quiet_drift: drift.map((i) => `${i.title} is creating continuity pressure. Next transition: ${i.next_expected_transition || 'clarify next step'}.`),
    reality_check: {
      REAL: open.filter((i) => i.reality_status === 'REAL').map((i) => i.title),
      PARTIAL: open.filter((i) => i.reality_status === 'PARTIAL').map((i) => i.title),
      PRETEND: open.filter((i) => i.reality_status === 'PRETEND').map((i) => i.title),
    },
    suggested_human_action: drift[0] ? `Resolve or clarify ${drift[0].title} before it quietly drifts further.` : 'Protect clarity first; no high-pressure drift detected.',
    protected_from_noise: open.filter((i) => i.continuity_class === 'NOISE' || i.continuity_class === 'EXPERIMENTAL').slice(0, 4).map((i) => i.title),
    closing_orientation: 'Protect clarity first. Nothing important should quietly drift.',
  };
}

export function generateEveningClosure(intents: InstitutionalIntent[]): EveningClosure {
  const closed = intents.filter((i) => i.state === 'CLOSED').slice(0, 5);
  const deferred = intents.filter((i) => i.state === 'DEFERRED' || i.continuity_class === 'NOISE' || i.continuity_class === 'EXPERIMENTAL').slice(0, 5);
  const open = intents.filter((i) => i.state === 'OPEN' || i.state === 'IN_PROGRESS');
  const posture = inferPosture(intents);
  return {
    posture,
    moved_forward: closed.length ? closed.map((i) => i.title) : ['Continuity was preserved; no major closure logged yet.'],
    no_longer_requires_attention: deferred.map((i) => `${i.title} — already captured for tomorrow or later review.`),
    can_wait_until_tomorrow: open.filter((i) => i.continuity_class !== 'CRITICAL_CONTINUITY' && i.continuity_class !== 'HUMAN_TRUST').slice(0, 5).map((i) => i.title),
    reality_check: {
      REAL: intents.filter((i) => i.reality_status === 'REAL').map((i) => i.title),
      PARTIAL: intents.filter((i) => i.reality_status === 'PARTIAL').map((i) => i.title),
      PRETEND: intents.filter((i) => i.reality_status === 'PRETEND').map((i) => i.title),
    },
    closing_note: 'Tomorrow begins with a clean orientation. Nothing important is being left to memory alone.',
  };
}
