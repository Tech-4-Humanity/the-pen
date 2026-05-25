/**
 * pen-queue-processor.mjs
 *
 * Polls pen_task_queue for queued/running rows past next_run_at.
 * Dispatches each task directly via Supabase enqueue_job RPC.
 * Writes pen_execution_ledger + pen_value_events rows per task.
 * Updates task to succeeded or dead_letter with exponential back-off.
 * Hardened: missing Supabase config is BLOCKED, not silent success.
 * Hardened: receipts include replay lineage so retries remain traceable.
 */

import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_ROLE;
const BRIDGE_URL = process.env.BRIDGE_INVOKE_URL;
const BRIDGE_KEY = process.env.BRIDGE_API_KEY;
const BATCH_SIZE = 10;
const now = new Date().toISOString();
const day = now.substring(0, 10);
const OUT_DIR = `outputs/runtime/${day}`;
const RCPT_DIR = `receipts/runtime/${day}`;
fs.mkdirSync(OUT_DIR, { recursive: true });
fs.mkdirSync(RCPT_DIR, { recursive: true });

function reqId() {
  return `req-${day.replaceAll('-', '')}-${Math.floor(Math.random() * 99999).toString().padStart(5, '0')}`;
}

function receiptPath(taskId, requestId) {
  return `${RCPT_DIR}/${taskId}-${requestId}-receipt.json`;
}

function writeReceipt(taskId, status, detail = {}) {
  const request_id = detail.request_id || reqId();
  const path = receiptPath(taskId, request_id);
  const receipt = {
    request_id,
    task_id: taskId,
    timestamp_utc: now,
    source: 'pen-queue-processor',
    status,
    reality_classification: detail.reality_classification || (status === 'PASS' ? 'REAL' : status === 'BLOCKED' ? 'PARTIAL' : 'PARTIAL'),
    evidence: detail.evidence || [],
    detail: detail.detail || {},
    error: detail.error || null,
    lineage: detail.lineage || null,
    recovery: detail.recovery || { required: status !== 'PASS', action: status === 'PASS' ? 'none' : 'inspect_queue' }
  };
  fs.writeFileSync(path, JSON.stringify(receipt, null, 2));
  fs.writeFileSync('receipts/runtime/latest.json', JSON.stringify(receipt, null, 2));
  return { request_id, path, receipt };
}

if (!SUPABASE_URL || !SUPABASE_KEY) {
  const blocked = writeReceipt('queue-sweep', 'BLOCKED', {
    reality_classification: 'PARTIAL',
    evidence: ['Supabase runtime configuration missing'],
    error: 'SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing',
    recovery: { required: true, action: 'restore_supabase_runtime_configuration' }
  });
  console.error('[pen-queue-processor] BLOCKED:', JSON.stringify(blocked.receipt, null, 2));
  process.exit(1);
}

const sb = createClient(SUPABASE_URL, SUPABASE_KEY, { auth: { persistSession: false } });

function backoffSec(attempt) {
  return Math.min(300, Math.pow(2, attempt) * 5);
}

function lineageFor(task, taskId, attempt, request_id, previousReceiptRef = null) {
  const meta = task.metadata || {};
  return {
    original_task_id: meta.original_task_id || taskId,
    original_request_id: meta.original_request_id || null,
    replay_request_id: attempt > 1 ? request_id : null,
    retry_attempt: attempt,
    previous_receipt_ref: previousReceiptRef || meta.previous_receipt_ref || null,
    new_receipt_ref: receiptPath(taskId, request_id),
    final_state: null
  };
}

async function rpc(fn, params) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_KEY,
      Authorization: `Bearer ${SUPABASE_KEY}`,
      'Content-Type': 'application/json',
      Accept: 'application/json'
    },
    body: JSON.stringify(params)
  });
  const text = await res.text();
  let data;
  try { data = JSON.parse(text); } catch { data = text; }
  if (!res.ok) throw new Error(`RPC ${fn} ${res.status}: ${JSON.stringify(data)}`);
  return data;
}

async function bridgeCall(payload) {
  if (!BRIDGE_URL || !BRIDGE_KEY) throw new Error('Bridge configuration missing');
  const res = await fetch(BRIDGE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-api-key': BRIDGE_KEY },
    body: JSON.stringify(payload)
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`Bridge ${res.status}: ${text.substring(0, 500)}`);
  try { return JSON.parse(text); } catch { return text; }
}

async function dispatchTask(task) {
  const meta = task.metadata || {};
  const fn = task.task_type || meta.fn || 'enqueue_job';
  const bridgeFns = new Set(['http_call', 'webhook', 'external_api']);
  if (bridgeFns.has(fn) && BRIDGE_URL && BRIDGE_KEY) {
    const response = await bridgeCall({ fn, idempotency_key: task.biz_key || task.task_id, ...meta });
    return { dispatched_via: 'bridge', fn, response };
  }
  const jobId = await rpc('enqueue_job', {
    p_biz_key: task.biz_key || task.task_id,
    p_job_type: fn,
    p_source_type: 'queue-processor',
    p_required_outcome: task.required_outcome || meta.objective || fn,
    p_target_ref: meta.target_ref || null,
    p_priority: Math.min(5, Math.max(1, task.priority ?? 3)),
    p_autonomy_tier: 'AUTONOMOUS',
    p_product_code: meta.product_code || null,
    p_revenue_tag: meta.revenue_tag || null,
    p_estimated_value_aud: meta.estimated_value_aud || null,
    p_metadata: meta
  });
  return { dispatched_via: 'rpc', fn, job_id: jobId };
}

console.log(`[pen-queue-processor] starting batch ${BATCH_SIZE} at ${now}`);

const { data: tasks, error: fetchErr } = await sb
  .from('pen_task_queue')
  .select('*')
  .in('status', ['queued', 'running'])
  .lte('next_run_at', now)
  .order('priority', { ascending: true })
  .limit(BATCH_SIZE);

if (fetchErr) {
  writeReceipt('queue-fetch', 'BLOCKED', {
    reality_classification: 'PARTIAL',
    evidence: ['Queue fetch failed'],
    error: fetchErr.message,
    recovery: { required: true, action: 'inspect_supabase_queue_access' }
  });
  console.error('[pen-queue-processor] queue fetch error:', fetchErr.message);
  process.exit(1);
}

if (!tasks || tasks.length === 0) {
  writeReceipt('queue-sweep', 'PASS', {
    evidence: ['Queue query succeeded', 'No due tasks found'],
    detail: { processed: 0 }
  });
  console.log('[pen-queue-processor] queue empty');
  process.exit(0);
}

const results = [];

for (const task of tasks) {
  const taskId = task.task_id || String(task.id);
  const attempt = (task.attempt_count || 0) + 1;
  const maxAttempts = task.max_attempts || 3;
  const request_id = reqId();
  const baseLineage = lineageFor(task, taskId, attempt, request_id);

  await sb.from('pen_task_queue').update({ status: 'running', attempt_count: attempt, updated_at: now }).eq('id', task.id);

  try {
    const detail = await dispatchTask(task);
    const lineage = { ...baseLineage, final_state: 'PASS' };
    const { receipt, path } = writeReceipt(taskId, 'PASS', {
      request_id,
      evidence: ['dispatch OK', 'ledger insert attempted'],
      detail,
      lineage
    });

    const ledgerInsert = await sb.from('pen_execution_ledger').insert({
      request_id,
      task_id: taskId,
      source: 'queue-processor',
      status: 'PASS',
      reality_classification: 'REAL',
      receipt,
      output_refs: [],
      log_refs: [path]
    });
    if (ledgerInsert.error) throw ledgerInsert.error;

    await sb.from('pen_value_events').insert({
      task_id: taskId,
      request_id,
      unit_amount_cents: task.estimated_value_cents || 0,
      quantity: 1,
      monetisation_status: 'log_only'
    });

    await sb.from('pen_task_queue').update({ status: 'succeeded', updated_at: now }).eq('id', task.id);
    results.push({ taskId, status: 'PASS', request_id, receipt_ref: path, lineage });
  } catch (err) {
    const failed = attempt >= maxAttempts;
    const nextAt = new Date(Date.now() + backoffSec(attempt) * 1000).toISOString();
    const lineage = { ...baseLineage, final_state: failed ? 'dead_letter' : 'retry' };
    const { path } = writeReceipt(taskId, 'FAIL', {
      request_id,
      evidence: ['dispatch or ledger failed'],
      error: err.message,
      lineage,
      recovery: { required: true, action: failed ? 'inspect_dead_letter_queue' : 'retry_scheduled' }
    });

    await sb.from('pen_task_queue').update({
      status: failed ? 'dead_letter' : 'queued',
      last_error: String(err.message).substring(0, 2000),
      next_run_at: nextAt,
      updated_at: now,
      metadata: {
        ...(task.metadata || {}),
        original_task_id: lineage.original_task_id,
        original_request_id: lineage.original_request_id || request_id,
        previous_receipt_ref: path
      }
    }).eq('id', task.id);
    results.push({ taskId, status: failed ? 'dead_letter' : 'retry', request_id, receipt_ref: path, error: err.message, lineage });
  }
}

const passed = results.filter(r => r.status === 'PASS').length;
const failed = results.filter(r => r.status === 'dead_letter').length;
const retrying = results.filter(r => r.status === 'retry').length;
const summary = { ts: now, processed: results.length, passed, failed, retrying, results };
fs.writeFileSync(`${OUT_DIR}/queue-processor-summary.json`, JSON.stringify(summary, null, 2));
writeReceipt('queue-sweep', failed > 0 ? 'FAIL' : 'PASS', {
  request_id: `req-${day.replaceAll('-', '')}-summary`,
  evidence: ['queue processor summary generated'],
  detail: summary,
  recovery: { required: failed > 0, action: failed > 0 ? 'inspect_dead_letter_queue' : 'none' }
});
console.log(`[pen-queue-processor] done ${passed} passed / ${retrying} retrying / ${failed} dead`);
if (failed > 0 && passed === 0) process.exit(1);
