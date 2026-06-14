/**
 * pen-executor.mjs - Real inbox dispatcher
 * Reads inbox/*.json, routes by fn, calls Supabase enqueue_job, writes real receipts.
 * Hardened 2026-06-13: missing inbox is a clean no-work state, not a runtime failure.
 */
import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY =
  process.env.SUPABASE_SERVICE_ROLE ||
  process.env.SUPABASE_SERVICE_ROLE_KEY;

const now = new Date();
const ts  = now.toISOString();
const day = ts.substring(0, 10);

const OUT_DIR  = `outputs/runtime/${day}`;
const RCPT_DIR = `receipts/runtime/${day}`;
fs.mkdirSync(OUT_DIR,  { recursive: true });
fs.mkdirSync(RCPT_DIR, { recursive: true });
fs.mkdirSync('receipts/runtime', { recursive: true });

// helpers
function writeReceipt(taskId, status, detail = {}) {
  const receipt = {
    request_id: `req-${day.replaceAll('-','')}-${Math.floor(Math.random()*99999)}`,
    task_id: taskId,
    timestamp_utc: ts,
    source: 'pen-executor',
    status,
    reality_classification: status === 'PASS' ? 'REAL' : 'FAILED',
    ...detail,
    recovery: { required: status !== 'PASS', action: status !== 'PASS' ? 'inspect_inbox' : 'none' }
  };
  const rcptPath = `${RCPT_DIR}/${taskId}-receipt.json`;
  fs.writeFileSync(rcptPath, JSON.stringify(receipt, null, 2));
  fs.writeFileSync('receipts/runtime/latest.json', JSON.stringify(receipt, null, 2));
  return rcptPath;
}

async function supabaseRpc(fn, params) {
  if (!SUPABASE_URL || !SUPABASE_KEY) throw new Error('SUPABASE_URL / SUPABASE_SERVICE_ROLE not set');
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify(params)
  });
  const text = await res.text();
  let data; try { data = JSON.parse(text); } catch { data = text; }
  if (!res.ok) throw new Error(`RPC ${fn} ${res.status}: ${JSON.stringify(data)}`);
  return data;
}

// fn handlers
async function handle_enqueue_job(job) {
  const p = job.payload || {};
  const result = await supabaseRpc('enqueue_job', {
    p_biz_key:             job.idempotency_key,
    p_job_type:            job.action || p.fn || 'generic',
    p_source_type:         'system',
    p_required_outcome:    p.objective || job.action || 'execute',
    p_target_ref:          p.target_ref || null,
    p_priority:            Math.min(5, Math.max(1, job.priority ?? 3)),
    p_autonomy_tier:       'AUTONOMOUS',
    p_product_code:        p.product_code || null,
    p_revenue_tag:         p.revenue_tag  || null,
    p_estimated_value_aud: p.estimated_value_aud || null,
    p_metadata:            p
  });
  return { job_id: result, enqueued: true };
}

async function handle_sql_query(job) {
  const result = await supabaseRpc('enqueue_job', {
    p_biz_key:             job.idempotency_key,
    p_job_type:            'sql_query',
    p_source_type:         'system',
    p_required_outcome:    'query_result',
    p_target_ref:          null,
    p_priority:            Math.min(5, Math.max(1, job.priority ?? 3)),
    p_autonomy_tier:       'AUTONOMOUS',
    p_product_code:        null,
    p_revenue_tag:         null,
    p_estimated_value_aud: null,
    p_metadata:            job.payload || {}
  });
  return { job_id: result, enqueued: true };
}

const HANDLERS = {
  enqueue_job: handle_enqueue_job,
  sql_query:   handle_sql_query,
  ddl_apply:   handle_enqueue_job,
  deploy:      handle_enqueue_job,
  http_call:   handle_enqueue_job
};

// main: scan inbox. Missing inbox is clean empty state.
const inboxEntries = fs.existsSync('inbox')
  ? fs.readdirSync('inbox', { withFileTypes: true })
      .filter(e => e.isFile() && e.name.endsWith('.json'))
      .map(e => e.name)
  : [];

if (inboxEntries.length === 0) {
  console.log('Inbox empty or missing');
  writeReceipt('auto-push-task', 'PASS', { evidence: ['Inbox empty or missing - clean no-work state'] });
  fs.writeFileSync(`${OUT_DIR}/inbox-dispatch-summary.json`, JSON.stringify({ ts, passed: 1, failed: 0, skipped: 0, results: [], note: 'empty_or_missing_inbox_clean_exit' }, null, 2));
  process.exit(0);
}

const results  = [];
const SEEN     = new Set();

for (const file of inboxEntries) {
  const filePath = path.join('inbox', file);
  let job;
  try { job = JSON.parse(fs.readFileSync(filePath, 'utf8')); }
  catch (e) { console.error(`Parse error ${file}:`, e.message); continue; }

  const key = job.idempotency_key || file.replace('.json','');
  if (SEEN.has(key)) { console.log(`Duplicate skip: ${key}`); continue; }
  SEEN.add(key);

  // idempotency: skip if already receipted today
  if (fs.existsSync(`${RCPT_DIR}/${key}-receipt.json`)) {
    console.log(`Already done today: ${key}`);
    results.push({ file, key, status: 'SKIP_IDEMPOTENT' });
    continue;
  }

  const handler = HANDLERS[job.fn];
  if (!handler) {
    console.warn(`Unknown fn "${job.fn}" - skipping ${file}`);
    results.push({ file, key, status: 'SKIPPED', reason: `unknown fn: ${job.fn}` });
    continue;
  }

  console.log(`[${job.fn}] ${key}...`);
  try {
    const detail = await handler(job);
    writeReceipt(key, 'PASS', {
      evidence: ['enqueue_job RPC OK', `job_id: ${JSON.stringify(detail.job_id)}`],
      detail
    });
    results.push({ file, key, status: 'PASS', job_id: detail.job_id });
    console.log(`  v ${key}`);
  } catch (err) {
    writeReceipt(key, 'FAIL', { error: err.message });
    results.push({ file, key, status: 'FAIL', error: err.message });
    console.error(`  x ${key}: ${err.message}`);
  }
}

const passed  = results.filter(r => r.status === 'PASS').length;
const failed  = results.filter(r => r.status === 'FAIL').length;
const skipped = results.filter(r => ['SKIPPED','SKIP_IDEMPOTENT'].includes(r.status)).length;

console.log(`\nSummary: ${passed} passed / ${failed} failed / ${skipped} skipped`);
fs.writeFileSync(`${OUT_DIR}/inbox-dispatch-summary.json`,
  JSON.stringify({ ts, passed, failed, skipped, results }, null, 2));

fs.writeFileSync('receipts/runtime/latest.json', JSON.stringify({
  request_id: `req-${day.replaceAll('-','')}-summary`,
  task_id: 'inbox-dispatch',
  timestamp_utc: ts,
  source: 'pen-executor',
  status: failed > 0 ? 'PARTIAL' : 'PASS',
  reality_classification: 'REAL',
  summary: { passed, failed, skipped, total: results.length },
  results,
  recovery: { required: failed > 0, action: failed > 0 ? 'inspect_failed_receipts' : 'none' }
}, null, 2));

if (failed > 0) process.exit(1);
