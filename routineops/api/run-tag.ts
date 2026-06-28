/*
 * RoutineOps /run-tag API skeleton
 * Runtime contract: trigger -> routine lookup -> run receipt.
 * This file is framework-neutral TypeScript for porting into Next.js, Vercel, Lambda or MCP bridge.
 */

export type RunTagRequest = {
  tag_uid?: string;
  routine_id?: string;
  profile_id?: string;
  household_id?: string;
  trigger_source?: 'nfc' | 'qr' | 'voice' | 'web' | 'schedule' | 'webhook' | 'manual';
  context?: Record<string, unknown>;
};

export type RoutineStep = {
  type: string;
  label: string;
  payload?: Record<string, unknown>;
  required?: boolean;
};

export type RunTagResponse = {
  ok: boolean;
  run_id: string;
  routine_id: string;
  display_name: string;
  status: 'started';
  confidence: number;
  steps: RoutineStep[];
  verification_required: boolean;
  fallback: string;
  receipt: {
    classification: 'PARTIAL';
    reason: string;
    created_at: string;
  };
};

const seededRoutines: Record<string, { display_name: string; steps: RoutineStep[]; fallback: string }> = {
  morning_launch: {
    display_name: 'Morning Launch',
    fallback: 'manual_confirm',
    steps: [
      { type: 'checklist', label: 'Bag, bottle, lunch, homework', required: true },
      { type: 'timer', label: 'Ten-minute launch timer', payload: { minutes: 10 }, required: false },
      { type: 'points', label: 'Award launch points', payload: { value: 10 }, required: false }
    ]
  },
  bedtime_winddown: {
    display_name: 'Bedtime Wind-down',
    fallback: 'manual_confirm',
    steps: [
      { type: 'speak', label: 'Start bedtime mission', payload: { text: 'Bedtime wind-down started.' }, required: false },
      { type: 'checklist', label: 'Teeth, PJs, bag packed', required: true },
      { type: 'log', label: 'Record bedtime routine start', required: true }
    ]
  },
  job_start: {
    display_name: 'Job Start',
    fallback: 'manual_confirm',
    steps: [
      { type: 'log', label: 'Start job timer', required: true },
      { type: 'checklist', label: 'Confirm scope, site safety, before photos', required: true }
    ]
  }
};

function makeId(prefix: string): string {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;
}

export async function runTag(input: RunTagRequest): Promise<RunTagResponse> {
  const routineId = input.routine_id || 'morning_launch';
  const routine = seededRoutines[routineId] || seededRoutines.morning_launch;

  return {
    ok: true,
    run_id: makeId('run'),
    routine_id: routineId,
    display_name: routine.display_name,
    status: 'started',
    confidence: 0.5,
    steps: routine.steps,
    verification_required: true,
    fallback: routine.fallback,
    receipt: {
      classification: 'PARTIAL',
      reason: 'API skeleton only. Not REAL until connected to persistent ledger, telemetry and recovery tests.',
      created_at: new Date().toISOString()
    }
  };
}

export async function handler(request: Request): Promise<Response> {
  if (request.method !== 'POST') {
    return Response.json({ ok: false, error: 'Method not allowed' }, { status: 405 });
  }

  let body: RunTagRequest;
  try {
    body = await request.json();
  } catch {
    return Response.json({ ok: false, error: 'Invalid JSON body' }, { status: 400 });
  }

  if (!body.tag_uid && !body.routine_id) {
    return Response.json({ ok: false, error: 'tag_uid or routine_id is required' }, { status: 400 });
  }

  const result = await runTag(body);
  return Response.json(result, { status: 200 });
}
