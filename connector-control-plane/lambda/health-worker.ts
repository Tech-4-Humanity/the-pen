import { pgSelect, pgInsert } from './lib/supabase-client';
import { buildReceipt } from './lib/receipt';

interface Connector {
  connector_id: string;
  name: string;
  health_url: string | null;
  enabled: boolean;
  provider: string;
}

const ACTOR = 'system:ccp-health-worker';

async function probe(c: Connector): Promise<{ ok: boolean; status: number | null; ms: number; body?: string }> {
  if (!c.health_url) return { ok: false, status: null, ms: 0, body: 'no_health_url' };
  const t0 = Date.now();
  try {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), 10_000);
    const res = await fetch(c.health_url, { signal: ctrl.signal });
    clearTimeout(timer);
    const body = await res.text().catch(() => '');
    return { ok: res.ok, status: res.status, ms: Date.now() - t0, body: body.slice(0, 512) };
  } catch (e) {
    return { ok: false, status: null, ms: Date.now() - t0, body: (e as Error).message };
  }
}

export async function handler(): Promise<{ probed: number; healthy: number; degraded: number }> {
  const connectors = await pgSelect<Connector>('ccp_connectors', 'enabled=eq.true&select=*');
  let healthy = 0, degraded = 0;

  for (const c of connectors) {
    const started = Date.now();
    const result = await probe(c);
    const state = result.ok ? 'REAL' : 'PARTIAL';
    if (result.ok) healthy++; else degraded++;

    const receipt = buildReceipt({
      actor_id: ACTOR,
      intent: 'health_probe',
      connector: c.connector_id,
      evidence: {
        connector: c.name,
        provider: c.provider,
        status_code: result.status,
        latency_ms: result.ms,
        snippet: result.body,
      },
      state,
      started_at: started,
      error: result.ok ? null : `health_probe_failed:${result.status ?? 'no_response'}`,
    });

    await pgInsert('ccp_receipts', receipt);
    await pgInsert('ccp_health_snapshots', {
      connector_id: c.connector_id,
      healthy: result.ok,
      latency_ms: result.ms,
      status_code: result.status,
      observed_at: new Date().toISOString(),
    });
  }

  return { probed: connectors.length, healthy, degraded };
}
