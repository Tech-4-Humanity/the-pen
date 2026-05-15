import type { APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { pgInsert } from './lib/supabase-client';
import { buildReceipt, ReceiptState } from './lib/receipt';

export async function handler(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> {
  let body: Record<string, unknown>;
  try { body = JSON.parse(event.body ?? '{}') as Record<string, unknown>; }
  catch { return { statusCode: 400, body: JSON.stringify({ error: 'invalid_json' }) }; }

  for (const f of ['actor_id', 'intent', 'state', 'evidence']) {
    if (!body[f]) return { statusCode: 400, body: JSON.stringify({ error: `missing_${f}` }) };
  }

  const state = body.state as ReceiptState;
  if (!['REAL', 'PARTIAL', 'BLOCKED'].includes(state)) {
    return { statusCode: 400, body: JSON.stringify({ error: 'invalid_state' }) };
  }

  const receipt = buildReceipt({
    actor_id: body.actor_id as string,
    intent: body.intent as string,
    connector: (body.connector as string | null) ?? null,
    evidence: body.evidence as Record<string, unknown>,
    state,
    started_at: body.started_at ? Date.parse(body.started_at as string) : Date.now(),
    cost_micros: (body.cost_micros as number | undefined) ?? 0,
    error: (body.error as string | null) ?? null,
  });

  await pgInsert('ccp_receipts', receipt);
  return {
    statusCode: 201,
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ execution_id: receipt.execution_id, evidence_hash: receipt.evidence_hash }),
  };
}
