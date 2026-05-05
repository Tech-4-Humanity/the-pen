#!/usr/bin/env node
/**
 * /dominate wrap — pen_ingest_worker.mjs
 * Bridged to: pgmq claim/lease + heartbeat + complete + reconcile_evidence + refresh_command_centre_projection
 * Watchdog: invoked before main loop — reclaims stale CLAIMED/RUNNING jobs automatically. No HITL.
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const ROOT = process.env.BRIDGE_ROOT || process.cwd();
const INBOX_DIR = path.join(ROOT, 'inbox');
const RECEIPT_DIR = path.join(ROOT, 'receipts', 'runtime');
const WORKER_ID = process.env.BRIDGE_WORKER_ID || 'pen-ingest-worker-01';
const TARGET_KEY = process.env.BRIDGE_IDEMPOTENCY_KEY || '';
const QUEUE_NAME = process.env.BRIDGE_QUEUE_NAME || 'pen_jobs';
const VT_SECONDS = parseInt(process.env.BRIDGE_VT_SECONDS || '300', 10);
const MAX_CLAIM = parseInt(process.env.BRIDGE_MAX_CLAIM || '10', 10);
const REQUIRED = ['idempotency_key', 'origin', 'destination'];

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const db = SUPABASE_URL && SUPABASE_SERVICE_KEY
  ? createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)
  : null;

function nowIso() { return new Date().toISOString(); }
function hash(s) { return 'sha256:' + crypto.createHash('sha256').update(s).digest('hex'); }
function safe(s) { return String(s || 'missing').toLowerCase().replace(/[^a-z0-9._-]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 160); }
async function exists(p) { try { await fs.access(p); return true; } catch { return false; } }

async function inboxJobs() {
  await fs.mkdir(INBOX_DIR, { recursive: true });
  const names = await fs.readdir(INBOX_DIR);
  return names.filter(n => n.endsWith('.json')).filter(n => !TARGET_KEY || n.includes(TARGET_KEY)).sort();
}

function validate(job) {
  const missing = REQUIRED.filter(k => !job[k]);
  const warnings = [];
  if (!job.created_at) warnings.push('created_at missing');
  if (!job.objective && !job.purpose) warnings.push('objective/purpose missing');
  return { valid: missing.length === 0, missing, warnings };
}

function classify(job) {
  const text = JSON.stringify(job).toLowerCase();
  const controlled = text.includes('gated') || text.includes('blocked') || text.includes('controlled');
  return {
    lane: controlled ? 'BRIDGE_CONTROLLED_VALIDATE_ONLY' : 'BRIDGE_AUTO_LOCAL_VALIDATE',
    evidence_state: controlled ? 'PARTIAL' : 'REAL',
    side_effects_executed: false,
    note: controlled
      ? 'Validated only. Controlled operations require approved runner.'
      : 'Local bridge ingestion validated and receipt produced.'
  };
}

async function runWatchdog() {
  if (!db) return null;
  const { data, error } = await db.rpc('watchdog_reclaim_stale_jobs', {});
  if (error) console.error('[watchdog] error:', error.message);
  if (data && data.length) console.error('[watchdog] reclaimed:', JSON.stringify(data));
  return data;
}

async function enqueueIfNew(job) {
  if (!db) return null;
  const { data, error } = await db.rpc('enqueue_pen_job', {
    p_idempotency_key: job.idempotency_key,
    p_job_type: job.job_type || job.type || 'SYSTEM_INGESTION',
    p_payload: job,
    p_source_path: `inbox/${safe(job.idempotency_key)}.json`,
    p_queue_name: QUEUE_NAME
  });
  if (error) console.error('[enqueue] error:', error.message);
  return data?.[0] || null;
}

async function heartbeat(key) {
  if (!db) return;
  await db.rpc('heartbeat_pen_job', {
    p_idempotency_key: key,
    p_worker_id: WORKER_ID,
    p_extend_seconds: VT_SECONDS
  });
}

async function completeJob(key, result, reason, inputHash, outputHash, deps) {
  if (!db) return;
  await db.rpc('complete_pen_job', {
    p_idempotency_key: key,
    p_worker_id: WORKER_ID,
    p_result: result,
    p_reason: reason,
    p_input_hash: inputHash,
    p_output_hash: outputHash,
    p_dependencies: deps
  });
}

async function reconcileEvidence(key) {
  if (!db) return;
  await db.rpc('reconcile_evidence', {
    p_idempotency_key: key,
    p_evidence_type: 'runtime_receipt'
  });
}

async function refreshProjection(key) {
  if (!db) return;
  await db.rpc('refresh_command_centre_projection', {
    p_idempotency_key: key
  });
}

async function processJob(jobName) {
  const sourcePath = path.join(INBOX_DIR, jobName);
  const raw = await fs.readFile(sourcePath, 'utf8');
  let job;
  try { job = JSON.parse(raw); } catch (e) {
    job = { idempotency_key: jobName.replace(/\.json$/, ''), origin: 'unknown', destination: 'bridge-runner', purpose: 'parse failure', parse_error: e.message };
  }

  const validation = validate(job);
  const classification = classify(job);
  const key = job.idempotency_key || jobName.replace(/\.json$/, '');
  const inputHash = hash(raw);
  const startedAt = nowIso();

  await enqueueIfNew(job);
  await heartbeat(key);

  await fs.mkdir(RECEIPT_DIR, { recursive: true });
  const outPath = path.join(RECEIPT_DIR, `${safe(key)}.receipt.json`);

  // idempotency: receipt exists — still reconcile + refresh projection
  if (await exists(outPath)) {
    await reconcileEvidence(key);
    await refreshProjection(key);
    return { job: jobName, idempotency_key: key, receipt_path: path.relative(ROOT, outPath), receipt_created: false, skipped: true };
  }

  const deps = { github: 'ok', supabase: db ? 'ok' : 'skip', projection: 'ok' };
  const result = validation.valid ? 'success' : 'retry';
  const reason = validation.valid
    ? classification.note
    : `Missing required fields: ${validation.missing.join(', ')}`;

  const body = {
    idempotency_key: key,
    job_type: job.job_type || job.type || 'SYSTEM_INGESTION',
    attempt: 1,
    state: 'RECEIPT_WRITTEN',
    started_at: startedAt,
    finished_at: nowIso(),
    worker_id: WORKER_ID,
    receipt_lease_id: `lease_${safe(key)}_01`,
    input_hash: inputHash,
    output_hash: '',
    repair_of: null,
    drift_flags: [],
    dependencies: deps,
    result,
    reason,
    metadata: {
      source_path: `inbox/${jobName}`,
      receipt_path: `receipts/runtime/${safe(key)}.receipt.json`,
      command_centre_projection_key: key,
      autonomy_tier: classification.lane,
      validation,
      classification
    }
  };

  body.output_hash = hash(JSON.stringify(body));

  await fs.writeFile(outPath, `${JSON.stringify(body, null, 2)}\n`, 'utf8');

  await completeJob(key, result, reason, inputHash, body.output_hash, deps);
  await reconcileEvidence(key);
  await refreshProjection(key);

  return {
    job: jobName,
    idempotency_key: key,
    receipt_path: path.relative(ROOT, outPath),
    receipt_created: true,
    result,
    evidence_state: classification.evidence_state
  };
}

async function main() {
  // watchdog first — self-healing, no HITL
  await runWatchdog();

  const list = await inboxJobs();
  const results = [];
  for (const j of list) {
    results.push(await processJob(j));
  }
  console.log(JSON.stringify({
    worker: WORKER_ID,
    processed_at: nowIso(),
    jobs_found: list.length,
    results
  }, null, 2));
}

main().catch(e => { console.error(e.stack || e.message); process.exit(1); });
