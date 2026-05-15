import { randomUUID, createHash } from 'crypto';

export type ReceiptState = 'REAL' | 'PARTIAL' | 'BLOCKED';

export interface Receipt {
  execution_id: string;
  actor_id: string;
  runtime_id: string;
  state: ReceiptState;
  intent: string;
  connector: string | null;
  evidence: Record<string, unknown>;
  evidence_hash: string;
  started_at: string;
  finished_at: string;
  duration_ms: number;
  cost_micros: number;
  error: string | null;
}

export function buildReceipt(args: {
  actor_id: string;
  intent: string;
  connector: string | null;
  evidence: Record<string, unknown>;
  state: ReceiptState;
  started_at: number;
  cost_micros?: number;
  error?: string | null;
}): Receipt {
  const finished = Date.now();
  const evidence = args.evidence ?? {};
  const evidence_hash = createHash('sha256').update(JSON.stringify(evidence)).digest('hex');
  return {
    execution_id: randomUUID(),
    actor_id: args.actor_id,
    runtime_id: process.env.AWS_LAMBDA_FUNCTION_NAME ?? 'local',
    state: args.state,
    intent: args.intent,
    connector: args.connector,
    evidence,
    evidence_hash,
    started_at: new Date(args.started_at).toISOString(),
    finished_at: new Date(finished).toISOString(),
    duration_ms: finished - args.started_at,
    cost_micros: args.cost_micros ?? 0,
    error: args.error ?? null,
  };
}
