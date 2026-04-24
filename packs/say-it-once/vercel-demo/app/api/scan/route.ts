import { NextResponse } from 'next/server';

const ROLE_OUTPUTS = [
  { role: 'HR', interpretation: 'No new hires unless critical; assess internal capacity and burnout risk.', tool: 'Workforce action note', variance: 'MEDIUM' },
  { role: 'Finance', interpretation: 'Set budget cap, track spend, classify cost centre and forecast impact.', tool: 'Excel budget guardrail', variance: 'HIGH' },
  { role: 'IT', interpretation: 'Create Kanban board, identify dependencies, access, environments, and milestone risks.', tool: 'Kanban delivery board', variance: 'LOW' },
  { role: 'Operations', interpretation: 'Create pilot rollout plan, process checkpoints, and service readiness tasks.', tool: 'Pilot execution plan', variance: 'MEDIUM' },
  { role: 'Risk', interpretation: 'Open risk register and require Friday checkpoint.', tool: 'Risk register', variance: 'HIGH' }
];

function scoreDecision(input: string) {
  const ambiguity = ['lean', 'fast', 'soon', 'critical', 'simple', 'later'].filter(w => input.toLowerCase().includes(w)).length;
  const timing = /\b(friday|monday|march|april|today|tomorrow|next month|\d{1,2})\b/i.test(input) ? 1 : 0;
  const functionsImpacted = Math.min(9, 4 + ambiguity + timing);
  const rolesImpacted = functionsImpacted * 9;
  const systemsTouched = Math.max(8, functionsImpacted * 2);
  const missRatePct = Math.min(68, 20 + functionsImpacted * 3);
  const driftScore = Math.min(100, 35 + ambiguity * 12 + functionsImpacted * 5 + missRatePct / 2);
  const driftRisk = driftScore > 75 ? 'HIGH' : driftScore > 50 ? 'MEDIUM' : 'LOW';

  return {
    decision_id: `sio_${Date.now()}`,
    input,
    blast_radius: { functions_impacted: functionsImpacted, roles_impacted: rolesImpacted, systems_touched: systemsTouched, tool_outputs: ROLE_OUTPUTS.length, miss_rate_pct: Math.round(missRatePct), drift_score: Math.round(driftScore), drift_risk: driftRisk },
    role_outputs: ROLE_OUTPUTS,
    simulation: {
      without: ['Email sent to leadership only', 'Role assumptions diverge', 'Budget and staffing risks surface late', 'Project drift appears after checkpoint'],
      with: ['Role outputs generated immediately', 'Snaps assigned to workers', 'Risk and cost controls visible', 'Execution begins same day']
    }
  };
}

export async function POST(req: Request) {
  const body = await req.json().catch(() => ({}));
  const input = body.input || 'We are starting Project Atlas on 30 March. Keep it lean. No new hires unless critical.';
  return NextResponse.json(scoreDecision(input));
}
