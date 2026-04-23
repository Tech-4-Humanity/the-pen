import dns from 'node:dns/promises';
import tls from 'node:tls';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const TABLE = 'registry.aws_hosted_zone_registry';

async function supabaseFetchDomains() {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${TABLE}?select=id,hosted_zone_name,normalized_domain,canonical_status,domain_status,reality_state&archived_at=is.null`, {
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
    }
  });
  if (!res.ok) throw new Error(`Supabase fetch failed: ${res.status} ${await res.text()}`);
  return res.json();
}

async function supabasePatch(id, patch) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${TABLE}?id=eq.${id}`, {
    method: 'PATCH',
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation'
    },
    body: JSON.stringify(patch)
  });
  if (!res.ok) throw new Error(`Supabase patch failed: ${res.status} ${await res.text()}`);
  return res.json();
}

async function hasDns(domain) {
  try {
    const [a, mx] = await Promise.allSettled([dns.resolve4(domain), dns.resolveMx(domain)]);
    return {
      has_a: a.status === 'fulfilled' && a.value.length > 0,
      has_mx: mx.status === 'fulfilled' && mx.value.length > 0,
      mx_count: mx.status === 'fulfilled' ? mx.value.length : 0
    };
  } catch {
    return { has_a: false, has_mx: false, mx_count: 0 };
  }
}

async function checkHttps(domain) {
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 7000);
    const res = await fetch(`https://${domain}`, { method: 'GET', redirect: 'manual', signal: controller.signal });
    clearTimeout(timer);
    return { ok: true, status: res.status, location: res.headers.get('location') };
  } catch (err) {
    return { ok: false, error: err.name || err.message };
  }
}

function sslExpiry(domain) {
  return new Promise((resolve) => {
    const socket = tls.connect({ host: domain, port: 443, servername: domain, timeout: 7000 }, () => {
      const cert = socket.getPeerCertificate();
      socket.end();
      resolve(cert?.valid_to || null);
    });
    socket.on('error', () => resolve(null));
    socket.on('timeout', () => { socket.destroy(); resolve(null); });
  });
}

function classify({ dnsState, httpsState, currentCanonicalStatus }) {
  if (currentCanonicalStatus === 'kill') {
    return { domain_status: 'unknown', reality_state: 'PARTIAL' };
  }
  if (httpsState.ok) return { domain_status: httpsState.status >= 300 && httpsState.status < 400 ? 'redirect' : 'active', reality_state: 'REAL' };
  if (dnsState.has_mx && !dnsState.has_a) return { domain_status: 'mail_only', reality_state: 'REAL' };
  if (dnsState.has_a || dnsState.has_mx) return { domain_status: 'active', reality_state: 'PARTIAL' };
  return { domain_status: 'inactive', reality_state: 'PARTIAL' };
}

export const handler = async () => {
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) throw new Error('Missing Supabase env vars');
  const domains = await supabaseFetchDomains();
  const results = [];

  for (const row of domains) {
    const domain = row.normalized_domain || row.hosted_zone_name;
    const dnsState = await hasDns(domain);
    const httpsState = await checkHttps(domain);
    const ssl_valid_to = httpsState.ok ? await sslExpiry(domain) : null;
    const classification = classify({ dnsState, httpsState, currentCanonicalStatus: row.canonical_status });

    const patch = {
      ...classification,
      last_verified_at: new Date().toISOString(),
      notes: `health_check dns_a=${dnsState.has_a} dns_mx=${dnsState.has_mx} mx_count=${dnsState.mx_count} https=${httpsState.ok ? httpsState.status : 'fail'} ssl_valid_to=${ssl_valid_to || 'n/a'}`
    };

    const updated = await supabasePatch(row.id, patch);
    results.push({ domain, patch, updated: updated?.[0]?.id || row.id });
  }

  return { status: 'ok', checked_count: results.length, results };
};
