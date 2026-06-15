#!/usr/bin/env node

/**
 * One Source, Multiple Lifecycle Objects Validator
 *
 * Mode: advisory / non-blocking by default.
 * Purpose: detect duplicated planning between PEN artifacts and Symbio issues
 * without stopping active builds or recovery work.
 *
 * REAL enforcement requires runtime telemetry, receipts, and explicit hard-gate enablement.
 */

const fs = require('fs');
const crypto = require('crypto');

function readJsonOrText(path) {
  const raw = fs.readFileSync(path, 'utf8');
  try {
    return { raw, parsed: JSON.parse(raw), type: 'json' };
  } catch {
    return { raw, parsed: null, type: 'text' };
  }
}

function normalizeText(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[`*_#|>\[\](){}:;,.!?\-]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function tokenSet(text) {
  const stop = new Set([
    'the', 'and', 'or', 'to', 'of', 'a', 'an', 'is', 'are', 'in', 'for', 'with',
    'this', 'that', 'must', 'should', 'from', 'into', 'not', 'be', 'as', 'it'
  ]);
  return new Set(normalizeText(text).split(' ').filter(t => t.length > 3 && !stop.has(t)));
}

function jaccard(a, b) {
  const intersection = [...a].filter(x => b.has(x)).length;
  const union = new Set([...a, ...b]).size;
  return union === 0 ? 0 : intersection / union;
}

function hash(value) {
  return crypto.createHash('sha256').update(String(value || '')).digest('hex');
}

function validate({ penPath, symbioPath, mode = 'advisory' }) {
  const pen = readJsonOrText(penPath);
  const symbio = readJsonOrText(symbioPath);

  const penTokens = tokenSet(pen.raw);
  const symbioTokens = tokenSet(symbio.raw);
  const overlap = jaccard(penTokens, symbioTokens);

  const hasPenSource = /pen|source artifact|source of intent|inbox\//i.test(symbio.raw);
  const hasExecutionWrapperLanguage = /execution wrapper|build ticket|deliverables|definition of done|next action/i.test(symbio.raw);

  const findings = [];

  if (!hasPenSource) {
    findings.push({
      severity: 'warning',
      code: 'MISSING_PEN_TRACEABILITY',
      message: 'Symbio object should link back to PEN source artifact and receipt.'
    });
  }

  if (!hasExecutionWrapperLanguage) {
    findings.push({
      severity: 'info',
      code: 'MISSING_EXECUTION_WRAPPER_LANGUAGE',
      message: 'Symbio object should identify itself as execution wrapper, not second source of truth.'
    });
  }

  if (overlap > 0.55 && hasPenSource) {
    findings.push({
      severity: 'info',
      code: 'POSSIBLE_DUPLICATED_PLANNING',
      message: 'High overlap detected. Consolidate opportunistically, but do not block active work.'
    });
  }

  const hardGate = mode === 'hard-gate';
  const blocking = hardGate && findings.some(f => f.severity === 'error');

  return {
    validator: 'one_source_multiple_lifecycle_validator',
    mode,
    blocking,
    evidence_state: 'PARTIAL',
    doctrine: 'one_source_multiple_lifecycle_objects',
    pen_path: penPath,
    symbio_path: symbioPath,
    pen_hash: hash(pen.raw),
    symbio_hash: hash(symbio.raw),
    overlap_score: Number(overlap.toFixed(4)),
    findings,
    instruction: blocking
      ? 'Block only because hard-gate mode is explicitly enabled and an error exists.'
      : 'Do not block. Continue build, preserve PEN as source of intent, use Symbio as execution wrapper, return receipts.',
    receipt_required_for_real: true
  };
}

if (require.main === module) {
  const [penPath, symbioPath, mode = 'advisory'] = process.argv.slice(2);

  if (!penPath || !symbioPath) {
    console.error(JSON.stringify({
      error: 'Usage: node validators/one_source_multiple_lifecycle_validator.js <penPath> <symbioPath> [advisory|hard-gate]',
      blocking: false,
      instruction: 'Missing inputs are reported but do not block active work by default.'
    }, null, 2));
    process.exit(0);
  }

  try {
    const result = validate({ penPath, symbioPath, mode });
    console.log(JSON.stringify(result, null, 2));
    process.exit(result.blocking ? 1 : 0);
  } catch (error) {
    console.error(JSON.stringify({
      validator: 'one_source_multiple_lifecycle_validator',
      mode,
      blocking: false,
      evidence_state: 'PARTIAL',
      error: error.message,
      instruction: 'Validator failure must not block active work unless hard-gate recovery is explicitly configured.'
    }, null, 2));
    process.exit(0);
  }
}

module.exports = { validate };
