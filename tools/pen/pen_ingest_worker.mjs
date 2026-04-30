#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';

const ROOT = process.env.BRIDGE_ROOT || process.cwd();
const INBOX_DIR = path.join(ROOT, 'inbox');
const RECEIPT_DIR = path.join(ROOT, 'receipts', 'runtime');
const WORKER_ID = process.env.BRIDGE_WORKER_ID || 'bridge_ingest_worker.mjs';
const TARGET_KEY = process.env.BRIDGE_IDEMPOTENCY_KEY || '';
const REQUIRED = ['idempotency_key', 'origin', 'destination'];

function nowIso() { return new Date().toISOString(); }
function hash(s) { return crypto.createHash('sha256').update(s).digest('hex'); }
function safe(s) { return String(s || 'missing').toLowerCase().replace(/[^a-z0-9._-]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 160); }
async function exists(p) { try { await fs.access(p); return true; } catch { return false; } }

async function jobs() {
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
    note: controlled ? 'Validated only. Controlled operations require approved runner.' : 'Local bridge ingestion validated and receipt produced.'
  };
}

async function receipt(jobName) {
  const sourcePath = path.join(INBOX_DIR, jobName);
  const raw = await fs.readFile(sourcePath, 'utf8');
  let job;
  try { job = JSON.parse(raw); } catch (e) { job = { idempotency_key: jobName.replace(/\.json$/, ''), origin: 'unknown', destination: 'bridge-runner', purpose: 'parse failure', parse_error: e.message }; }
  const validation = validate(job);
  const classification = classify(job);
  await fs.mkdir(RECEIPT_DIR, { recursive: true });
  const key = job.idempotency_key || jobName.replace(/\.json$/, '');
  const out = path.join(RECEIPT_DIR, `${safe(key)}.receipt.json`);
  if (await exists(out)) {
    return { job: jobName, idempotency_key: key, receipt_path: path.relative(ROOT, out), receipt_created: false };
  }
  const body = {
    idempotency_key: key,
    status: validation.valid ? 'processed' : 'invalid',
    processed_at: nowIso(),
    worker: WORKER_ID,
    destination: 'bridge-runner',
    source_path: `inbox/${jobName}`,
    source_sha256: hash(raw),
    evidence_state: validation.valid ? classification.evidence_state : 'PARTIAL',
    validation,
    classification,
    outputs: { parsed_json: true, receipt_written: true, external_calls_made: false, bridge_lane: true },
    errors: validation.valid ? [] : [`Missing required fields: ${validation.missing.join(', ')}`],
    next: validation.valid ? ['Bind to audit/evidence register.', 'Promote only receipt-writing scope to REAL.'] : ['Correct payload and resubmit.']
  };
  await fs.writeFile(out, `${JSON.stringify(body, null, 2)}\n`, 'utf8');
  return { job: jobName, idempotency_key: key, receipt_path: path.relative(ROOT, out), receipt_created: true, evidence_state: body.evidence_state };
}

async function main() {
  const list = await jobs();
  const results = [];
  for (const j of list) results.push(await receipt(j));
  console.log(JSON.stringify({ worker: WORKER_ID, processed_at: nowIso(), jobs_found: list.length, results }, null, 2));
}
main().catch(e => { console.error(e.stack || e.message); process.exit(1); });
