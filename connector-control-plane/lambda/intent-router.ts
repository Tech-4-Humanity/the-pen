import type { APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { pgSelect, pgInsert } from './lib/supabase-client';
import { buildReceipt } from './lib/receipt';

interface IntentRequest {
  actor_id: string;
  intent: string;
  payload?: Record<string, unknown>;
  capability_required?: string;
  cost_budget_micros?: number;
}

interface Connector {
  connector_id: string;
  name: string;
  base_url: string;
  capabilities: string[];
  cost_micros: number;
  priority: number;
  enabled: boolean;
}

async function selectConnectors(capability: string, budget: number | undefined): Promise<Connector[]> {
  const all = await pgSelect<Connector>(
    'ccp_connectors',
    `enabled=eq.true&capabilities=cs.{${capability}}&order=priority.asc`,
  );
  return budget == null ? all : all.filter(c => c.cost_micros <= budget);
}

async function callConnector(c: Connector, body: unknown): Promise<{ ok: boolean; status: number; data: unknown }> {
  const res = await fetch(`${c.base_url}/invoke`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  return { ok: res.ok, status: res.status, data };
}

export async function handler(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> {
  const started = Date.now();
  let req: IntentRequest;
  try { req = JSON.parse(event.body ?? '{}') as IntentRequest; }
  catch { return { statusCode: 400, body: JSON.stringify({ error: 'invalid_json' }) }; }

  if (!req.actor_id || !req.intent) {
    return { statusCode: 400, body: JSON.stringify({ error: 'missing_actor_id_or_intent' }) };
  }

  const capability = req.capability_required ?? req.intent;
  const candidates = await selectConnectors(capability, req.cost_budget_micros);

  if (candidates.length === 0) {
    const receipt = buildReceipt({
      actor_id: req.actor_id, intent: req.intent, connector: null,
      evidence: { capability, reason: 'no_eligible_connector' },
      state: 'BLOCKED', started_at: started, error: 'no_eligible_connector',
    });
    await pgInsert('ccp_receipts', receipt);
    return { statusCode: 503, body: JSON.stringify({ state: 'BLOCKED', execution_id: receipt.execution_id }) };
  }

  for (const c of candidates) {
    try {
      const r = await callConnector(c, req.payload ?? {});
      if (r.ok) {
        const receipt = buildReceipt({
          actor_id: req.actor_id, intent: req.intent, connector: c.connector_id,
          evidence: { capability, status: r.status, response: r.data },
          state: 'REAL', started_at: started, cost_micros: c.cost_micros,
        });
        await pgInsert('ccp_receipts', receipt);
        return {
          statusCode: 200,
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({ state: 'REAL', execution_id: receipt.execution_id, connector: c.name, data: r.data }),
        };
      }
      await pgInsert('ccp_receipts', buildReceipt({
        actor_id: req.actor_id, intent: req.intent, connector: c.connector_id,
        evidence: { capability, status: r.status, response: r.data },
        state: 'PARTIAL', started_at: started, cost_micros: c.cost_micros,
        error: `connector_returned_${r.status}`,
      }));
    } catch (e) {
      await pgInsert('ccp_receipts', buildReceipt({
        actor_id: req.actor_id, intent: req.intent, connector: c.connector_id,
        evidence: { capability, error: (e as Error).message },
        state: 'PARTIAL', started_at: started, error: (e as Error).message,
      }));
    }
  }

  const receipt = buildReceipt({
    actor_id: req.actor_id, intent: req.intent, connector: null,
    evidence: { capability, candidates: candidates.map(c => c.connector_id), reason: 'all_connectors_failed' },
    state: 'BLOCKED', started_at: started, error: 'all_connectors_failed',
  });
  await pgInsert('ccp_receipts', receipt);
  return { statusCode: 502, body: JSON.stringify({ state: 'BLOCKED', execution_id: receipt.execution_id }) };
}
