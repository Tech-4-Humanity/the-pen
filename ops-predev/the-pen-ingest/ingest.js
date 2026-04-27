// /api/ingest.js — The Pen edge function
// Receives GitHub push webhooks, writes ops_predev rows via predev-ingest Lambda
// Deploy: Vercel edge runtime (the-pen project)

export const config = { runtime: 'edge' };

const WEBHOOK_SECRET = process.env.GITHUB_WEBHOOK_SECRET;
const INGEST_URL     = process.env.PREDEV_INGEST_URL; // Lambda API GW URL

export default async function handler(req) {
  if (req.method !== 'POST')
    return json({ ok: false, error: 'POST only' }, 405);

  // Signature verification
  const sig = req.headers.get('x-hub-signature-256');
  if (WEBHOOK_SECRET && sig) {
    const rawBody = await req.text();
    const valid = await verifySignature(rawBody, sig, WEBHOOK_SECRET);
    if (!valid) return json({ ok: false, error: 'invalid signature' }, 401);
    try {
      var body = JSON.parse(rawBody);
    } catch {
      return json({ ok: false, error: 'invalid JSON' }, 400);
    }
  } else {
    body = await req.json().catch(() => null);
    if (!body) return json({ ok: false, error: 'invalid JSON' }, 400);
  }

  // Only process push events with commits
  const commit = body?.head_commit;
  if (!commit) return json({ ok: true, skipped: 'no head_commit' }, 200);

  // Skip automated commits (receipts) to avoid loops
  const author = commit.author?.name || '';
  if (author.includes('github-actions') || commit.message?.startsWith('RECEIPT:'))
    return json({ ok: true, skipped: 'automated commit' }, 200);

  // Determine pillar from repo name or commit message
  const repoName  = body.repository?.full_name || '';
  const pillar    = inferPillar(repoName, commit.message);
  const bizKey    = inferBizKey(repoName);

  const ingestPayload = {
    title:        commit.message.split('\n')[0].trim().slice(0, 500),
    item_type:    'pen',
    source_type:  'pen',
    source_ref:   commit.id,
    pillar,
    business_key: bizKey,
    notes:        `Repo: ${repoName} | Commit: ${commit.url} | Author: ${author}`,
    priority:     3,
    auto_promote: false,
  };

  if (!INGEST_URL)
    return json({ ok: false, error: 'PREDEV_INGEST_URL not set' }, 500);

  const resp = await fetch(INGEST_URL, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify(ingestPayload),
  });

  const result = await resp.json().catch(() => ({ ok: false }));

  return json({
    ok:         result.ok,
    predev_id:  result.id,
    existing:   result.existing || false,
    commit:     commit.id.slice(0, 8),
    repo:       repoName,
  }, 200);
}

function inferPillar(repo, message = '') {
  const r = repo.toLowerCase();
  const m = message.toLowerCase();
  if (r.includes('mcp') || m.includes('[mcp]'))        return '01_MCP';
  if (r.includes('jobs') || m.includes('[jobs]'))       return '02_JOBS';
  if (r.includes('research') || m.includes('[rd]'))     return '04_RESEARCH';
  if (r.includes('ndis') || r.includes('outcome'))      return '03_BUSINESS';
  return null;
}

function inferBizKey(repo) {
  const r = repo.toLowerCase();
  if (r.includes('holoorg') || r.includes('holo-org')) return 'HOLOORG';
  if (r.includes('consent'))                            return 'CONSENTX';
  if (r.includes('workfamily'))                         return 'WORKFAMILYAI';
  if (r.includes('maat') || r.includes('factor'))       return 'T4H';
  return 'T4H';
}

async function verifySignature(body, sigHeader, secret) {
  const encoder    = new TextEncoder();
  const key        = await crypto.subtle.importKey(
    'raw', encoder.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']
  );
  const signature  = await crypto.subtle.sign('HMAC', key, encoder.encode(body));
  const hex        = 'sha256=' + Array.from(new Uint8Array(signature))
    .map(b => b.toString(16).padStart(2, '0')).join('');
  return hex === sigHeader;
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
