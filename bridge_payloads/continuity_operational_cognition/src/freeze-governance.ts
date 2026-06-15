export type FreezeType = 'PILOT_FREEZE' | 'PROMOTION_FREEZE' | 'EXPANSION_FREEZE' | 'ONTOLOGY_FREEZE' | 'NOISE_FREEZE' | 'TRUST_FREEZE' | 'RECOVERY_FREEZE';

export interface FreezeScope {
  scope_key: string;
  freeze_type: FreezeType;
  reason: string;
  allowed_actions: string[];
  blocked_actions: string[];
  exit_conditions: string[];
  status: 'ACTIVE' | 'ENDED' | 'ABORTED';
}

export interface FreezeDecision {
  allowed: boolean;
  reason: string;
  action: 'ALLOW' | 'HOLD' | 'DEFER_WITH_CONFIDENCE';
}

export function evaluateFreeze(scope: FreezeScope | undefined, requestedAction: string): FreezeDecision {
  if (!scope || scope.status !== 'ACTIVE') return { allowed: true, action: 'ALLOW', reason: 'No active freeze scope.' };
  const request = requestedAction.toLowerCase();
  const held = scope.blocked_actions.some((entry) => request.includes(entry.toLowerCase()));
  if (held) return { allowed: false, action: 'DEFER_WITH_CONFIDENCE', reason: 'Deferred by active freeze: ' + scope.reason };
  const allowed = scope.allowed_actions.some((entry) => request.includes(entry.toLowerCase()));
  if (allowed) return { allowed: true, action: 'ALLOW', reason: 'Action is allowed inside freeze.' };
  return { allowed: false, action: 'HOLD', reason: 'Action not explicitly allowed inside freeze. Freeze protects signal integrity.' };
}

export const continuityPilotFreeze: FreezeScope = {
  scope_key: 'continuity_pilot_7_day_v2_1',
  freeze_type: 'PILOT_FREEZE',
  reason: 'Protect behavioural signal while testing cognitive relief and continuity trust.',
  allowed_actions: ['use current ritual', 'manual tracking', 'scratchpad capture', 'blocking defect fix', 'Day 3 review', 'Day 7 synthesis'],
  blocked_actions: ['new widget', 'new agent', 'ontology redesign', 'extra metric', 'new dashboard', 'campaign expansion', 'feature addition'],
  exit_conditions: ['Day 7 synthesis complete', 'ritual too heavy', 'safety issue', 'user ends pilot'],
  status: 'ACTIVE',
};
