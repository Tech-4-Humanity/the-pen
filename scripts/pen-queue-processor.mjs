/**
 * pen-queue-processor.mjs
 *
 * Polls pen_task_queue for queued/running rows past next_run_at.
 * Dispatches each task directly via Supabase enqueue_job RPC (no executor spawn).
 * Writes pen_execution_ledger + pen_value_events rows per task.
 * Updates task to succeeded or dead_letter with exponential back-off.
 *
 * Cron: every 2 minutes via pen-queue-cron.yml
 */

import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

// ── env ──────────────────────────────────────────────────────────────────────
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_ROLE;
const BRIDGE_URL   = process.env.BRIDGE_INVOKE_URL;
const BRIDGE_KEY   = process.env.BRIDGE_API_KEY;
const BATCH_SIZE   = 10;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('[pen-queue-processor] SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY missing — exit 0');
  process.exit(0);
}

const sb  = createClient(SUPABASE_URL, SUPABASE_KEY, { auth: { persistSession: false } });
const now = new Date().toISOString();
const day = now.substring(0, 10);

// ── output dirs ──────────────────────────────────────────────────────────────
const OUT_DIR  = `outputs/runtime/${day}`;
const RCPT_DIR = `receipts/runtime/${day}`;
fs.mkdirSync(OUT_DIR,  { recursive: true });
fs.mkdirSync(RCPT_DIR, { recursive: true });

// ── helpers ──────────────────────────────────────────────────────────────────
function backoffSec(attempt) {
  return Math.min(300, Math.pow(2, attempt) * 5);
}

async function rpc(fn, params) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_KEY,
      Authorization: `Bearer ${SUPABASE_KEY}`,
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify(params),
  });
  const text = await res.text();
  let data;
  try { data = JSON.parse(text); } catch { data = text; }
  if (!res.ok) throw new Error(`RPC ${fn} ${res.status}: ${JSON.stringify(data)}`);
  return data;
}

async function bridgeCall(payload) {
  if (!BRIDGE_URL || !BRIDGE_KEY) throw new Error('BRIDGE_INVOKE_URL or BRIDGE_API_KEY missing');
  const res = await fetch(BRIDGE_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': BRIDGE_KEY,
    },
    body: JSON.stringify(payload),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`Bridge ${res.status}: ${text.substring(0, 500)}`);
  try { return JSON.parse(text); } catch { return text; }
}

function writeReceipt(taskId, status, detail = {}) {
  const reqId = `req-${day.replaceAll('-', '')}-${Math.floor(Math.random() * 99999).toString().padStart(5, '0')}`;
  const receipt = {
    request_id: reqId,
    task_id: taskId,
    timestamp_utc: now,
    source: 'pen-queue-processor',
    status,
    reality_classification: status === 'PASS' ? 'REAL' : 'FAILED',
    ...detail,
    recovery: { required: status !== 'PASS', action: status !== 'PASS' ? 'inspect_queue' : 'none' },
  };
  const rcptPath = `${RCPT_DIR}/${taskId}-receipt.json`;
  fs.writeFileSync(rcptPath, JSON.stringify(receipt, null, 2));
  fs.writeFileSync('receipts/runtime/latest.json', JSON.stringify(receipt, null, 2));
  return { reqId, rcptPath };
}

// ── task dispatcher ───────────────────────────────────────────────────────────
async function dispatchTask(task) {
  const meta = task.metadata || {};
  const fn   = task.task_type || meta.fn || 'enqueue_job';

  // Route: known bridge-native fns go to bridge; everything else enqueues via RPC
  const bridgeFns = new Set(['http_call', 'webhook', 'external_api']);

  if (bridgeFns.has(fn) && BRIDGE_URL && BRIDGE_KEY) {
    // Flat bridge envelope — fn + job fields at top level
    const response = await bridgeCall({
      fn,
      idempotency_key: task.biz_key || task.task_id,
      ...meta,
    });
    return { dispatched_via: 'bridge', fn, response };
  }

  // Default: enqueue_job RPC
  const jobId = await rpc('enqueue_job', {
    p_biz_key:             task.biz_key || task.task_id,
    p_job_type:            fn,
    p_source_type:         'queue-processor',
    p_required_outcome:    task.required_outcome || meta.objective || fn,
    p_target_ref:          meta.target_ref || null,
    p_priority:            Math.min(5, Math.max(1, task.priority ?? 3)),
    p_autonomy_tier:       'AUTONOMOUS',
    p_product_code:        meta.product_code || null,
    p_revenue_tag:         meta.revenue_tag  || null,
    p_estimated_value_aud: meta.estimated_value_aud || null,
    p_metadata:            meta,
  });

  return { dispatched_via: 'rpc', fn, job_id: jobId };
}

// ── main ──────────────────────────────────────────────────────────────────────
console.log(`[pen-queue-processor] starting — batch ${BATCH_SIZE} @ ${now}`);

const { data: tasks, error: fetchErr } = await sb
  .from('pen_task_queue')
  .select('*')
  .in('status', ['queued', 'running'])
  .lte('next_run_at', now)
  .order('priority', { ascending: true })
  .limit(BATCH_SIZE);

if (fetchErr) {
  console.error('[pen-queue-processor] queue fetch error:', fetchErr.message);
  process.exit(1);
}

if (!tasks || tasks.length === 0) {
  console.log('[pen-queue-processor] queue empty — nothing to do');
  writeReceipt('queue-sweep', 'PASS', { evidence: ['Queue empty or no tasks due'] });
  process.exit(0);
}

console.log(`[pen-queue-processor] ${tasks.length} task(s) to process`);

const results = [];

for (const task of tasks) {
  const taskId  = task.task_id || String(task.id);
  const attempt = (task.attempt_count || 0) + 1;
  const maxAttempts = task.max_attempts || 3;

  // Mark running
  await sb.from('pen_task_queue')
    .update({ status: 'running', attempt_count: attempt, updated_at: now })
    .eq('id', task.id);

  try {
    const detail  = await dispatchTask(task);
    const { reqId } = writeReceipt(taskId, 'PASS', { evidence: ['dispatch OK'], detail });

    // Ledger
    await sb.from('pen_execution_ledger').insert({
      request_id:             reqId,
      task_id:                taskId,
      source:                 'queue-processor',
      status:                 'PASS',
      reality_classification: 'REAL',
      receipt:                { taskId, status: 'PASS', detail },
      output_refs:            [],
      log_refs:               [],
    });

    // Value event (log-only unless task carries monetisation data)
    await sb.from('pen_value_events').insert({
      task_id:              taskId,
      request_id:           reqId,
      unit_amount_cents:    task.estimated_value_cents || 0,
      quantity:             1,
      monetisation_status: 'log_only',
    });

    // Mark succeeded
    await sb.from('pen_task_queue')
      .update({ status: 'succeeded', updated_at: now })
      .eq('id', task.id);

    console.log(`  ✓ ${taskId} [${detail.dispatched_via}:${detail.fn}]`);
    results.push({ taskId, status: 'PASS' });

  } catch (err) {
    const failed = attempt >= maxAttempts;
    const nextAt = new Date(Date.now() + backoffSec(attempt) * 1000).toISOString();

    writeReceipt(taskId, 'FAIL', { error: err.message, attempt, maxAttempts });

    await sb.from('pen_task_queue').update({
      status:        failed ? 'dead_letter' : 'queued',
      last_error:    String(err.message).substring(0, 2000),
      next_run_at:   nextAt,
      updated_at:    now,
    }).eq('id', task.id);

    console.error(`  ✗ ${taskId}: ${err.message}${failed ? ' → dead_letter' : ` → retry @ ${nextAt}`}`);
    results.push({ taskId, status: failed ? 'dead_letter' : 'retry', error: err.message });
  }
}

// Summary
const passed      = results.filter(r => r.status === 'PASS').length;
const failed      = results.filter(r => r.status === 'dead_letter').length;
const retrying    = results.filter(r => r.status === 'retry').length;

const summary = { ts: now, processed: results.length, passed, failed, retrying, results };
fs.writeFileSync(`${OUT_DIR}/queue-processor-summary.json`, JSON.stringify(summary, null, 2));
fs.writeFileSync('receipts/runtime/latest.json', JSON.stringify({
  request_id:             `req-${day.replaceAll('-', '')}-summary`,
  task_id:                'queue-sweep',
  timestamp_utc:          now,
  source:                 'pen-queue-processor',
  status:                 failed > 0 ? 'PARTIAL' : 'PASS',
  reality_classification: 'REAL',
  summary,
  recovery: { required: failed > 0, action: failed > 0 ? 'inspect_dead_letter_queue' : 'none' },
}, null, 2));

console.log(`\n[pen-queue-processor] done — ${passed} passed / ${retrying} retrying / ${failed} dead`);

if (failed > 0 && passed === 0) process.exit(1);
