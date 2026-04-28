#!/usr/bin/env node
/**
 * PEN Inbox Ingestion Worker
 *
 * Consumes JSON jobs from inbox/ and writes immutable runtime receipts.
 * Safe by design: local file validation only, no external calls, no destructive operations.
 */

import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';

const ROOT = process.env.PEN_ROOT || process.cwd();
const INBOX_DIR = path.join(ROOT, 'inbox');
const RECEIPT_DIR = path.join(ROOT, 'receipts', 'runtime');
const WORKER_ID = process.env.PEN_WORKER_ID || 'pen_ingest_worker.mjs';
const TARGET_KEY = process.env.PEN_IDEMPOTENCY_KEY || '';
const REQUIRED_FIELDS = ['idempotency_key', 'origin', 'destination'];

function nowIso() {
  return new Date().toISOString();
}

function sha256(input) {
  return crypto.createHash('sha256').update(input).digest('hex');
}

function safeFilename(key) {
  return String(key || 'missing-key')
    .toLowerCase()
    .replace(/[^a-z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 160);
}

async function exists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

async function listJsonJobs() {
  await fs.mkdir(INBOX_DIR, { recursive: true });
  const names = await fs.readdir(INBOX_DIR);
  return names
    .filter((name) => name.endsWith('.json'))
    .filter((name) => !TARGET_KEY || name.includes(TARGET_KEY))
    .sort();
}

function validateJob(job) {
  const missing = REQUIRED_FIELDS.filter((field) => !job[field]);
  const warnings = [];
  if (!job.created_at) warnings.push('created_at missing');
  if (!job.reality_state && !job.evidence_state) warnings.push('reality/evidence state missing');
  if (!job.objective && !job.purpose) warnings.push('objective/purpose missing');
  return { valid: missing.length === 0, missing, warnings };
}

function classifyJob(job) {
  const tier = String(job.autonomy_tier || job.next_worker_command?.mode || '').toUpperCase();
  const requestedRestricted = Array.isArray(job.next_worker_command?.blocked_actions)
    ? job.next_worker_command.blocked_actions.length > 0
    : false;

  if (tier.includes('GATED') || tier.includes('BLOCKED') || requestedRestricted) {
    return {
      lane: 'CONTROLLED_LANE_PRESENT',
      evidence_state: 'PARTIAL',
      side_effects_executed: false,
      note: 'Receipt created. Controlled operations are not executed by this worker.'
    };
  }

  return {
    lane: 'AUTO_SAFE_LOCAL_VALIDATION',
    evidence_state: 'REAL',
    side_effects_executed: false,
    note: 'Job parsed and receipt produced by local validation worker.'
  };
}

async function writeReceipt(jobName, jobText, job, validation, classification) {
  await fs.mkdir(RECEIPT_DIR, { recursive: true });
  const key = job.idempotency_key || jobName.replace(/\.json$/, '');
  const receiptPath = path.join(RECEIPT_DIR, `${safeFilename(key)}.receipt.json`);

  if (await exists(receiptPath)) {
    const existing = JSON.parse(await fs.readFile(receiptPath, 'utf8'));
    return { receipt_path: path.relative(ROOT, receiptPath), created: false, receipt: existing };
  }

  const receipt = {
    idempotency_key: key,
    parent_job: job.parent_job || null,
    status: validation.valid ? 'processed' : 'invalid',
    processed_at: nowIso(),
    worker: WORKER_ID,
    source_path: `inbox/${jobName}`,
    source_sha256: sha256(jobText),
    evidence_state: validation.valid ? classification.evidence_state : 'PARTIAL',
    validation,
    classification,
    outputs: {
      parsed_json: true,
      receipt_written: true,
      external_calls_made: false,
      controlled_operations_executed: false
    },
    errors: validation.valid ? [] : [`Missing required fields: ${validation.missing.join(', ')}`],
    next: validation.valid
      ? [
          'Bind receipt to the audit/evidence register or repo-equivalent ledger.',
          'Treat this receipt as proof of ingestion and validation only.',
          'Controlled operations require the approved execution lane.'
        ]
      : ['Correct payload and resubmit under a new idempotency key.']
  };

  await fs.writeFile(receiptPath, `${JSON.stringify(receipt, null, 2)}\n`, 'utf8');
  return { receipt_path: path.relative(ROOT, receiptPath), created: true, receipt };
}

async function processJob(jobName) {
  const jobPath = path.join(INBOX_DIR, jobName);
  const jobText = await fs.readFile(jobPath, 'utf8');
  let job;

  try {
    job = JSON.parse(jobText);
  } catch (error) {
    job = {
      idempotency_key: jobName.replace(/\.json$/, ''),
      origin: 'unknown',
      destination: 'pen',
      objective: 'record parse failure',
      parse_error: error.message
    };
  }

  const validation = validateJob(job);
  const classification = classifyJob(job);
  const receiptResult = await writeReceipt(jobName, jobText, job, validation, classification);

  return {
    job: jobName,
    idempotency_key: job.idempotency_key,
    receipt_path: receiptResult.receipt_path,
    receipt_created: receiptResult.created,
    evidence_state: receiptResult.receipt.evidence_state,
    status: receiptResult.receipt.status,
    errors: receiptResult.receipt.errors
  };
}

async function main() {
  const jobs = await listJsonJobs();
  const results = [];
  for (const jobName of jobs) results.push(await processJob(jobName));

  const summary = {
    worker: WORKER_ID,
    processed_at: nowIso(),
    target_key: TARGET_KEY || null,
    jobs_found: jobs.length,
    results
  };

  process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
  process.exit(results.some((result) => result.status === 'invalid') ? 1 : 0);
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exit(1);
});
