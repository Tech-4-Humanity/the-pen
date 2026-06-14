#!/usr/bin/env node

/**
 * T4H Corpus Delta Engine v1
 *
 * Compares a baseline corpus intelligence snapshot with a current snapshot.
 * Outputs: new / changed / disappeared / duplicated / contradicted / promoted / demoted.
 *
 * Usage:
 *   node corpus-intelligence/delta_engine.mjs baseline.json current.json > delta_output.json
 *
 * Snapshot shape:
 * {
 *   "snapshot_id": "run-001",
 *   "objects": [
 *     {
 *       "object_id": "optional-stable-id",
 *       "object_name": "Reading Buddy OCR",
 *       "object_type": "Asset",
 *       "state": "discovered",
 *       "summary": "...",
 *       "evidence": ["url-or-ref"],
 *       "scores": { ... },
 *       "relationships": [ ... ]
 *     }
 *   ]
 * }
 */

import fs from 'node:fs';
import crypto from 'node:crypto';

const LIFECYCLE_RANK = {
  discovered: 1,
  incubating: 2,
  active: 3,
  validated: 4,
  reusable: 5,
  recomposable: 6,
  promotion_ready: 7,
  promoted: 8,
  blocked: -1,
  parked: -2,
  deprecated: -3,
  superseded: -4,
  merged: -5,
  dead: -6,
};

const CONTRADICTION_CLASSES = [
  'naming_contradiction',
  'strategy_contradiction',
  'product_overlap',
  'market_conflict',
  'execution_conflict',
  'evidence_mismatch',
  'said_build_did_document_failure',
];

function readJson(path) {
  if (!path) throw new Error('Missing JSON path');
  return JSON.parse(fs.readFileSync(path, 'utf8'));
}

function norm(value) {
  return String(value ?? '').trim().toLowerCase().replace(/\s+/g, ' ');
}

function stableId(obj) {
  if (obj.object_id) return String(obj.object_id);
  const raw = `${norm(obj.object_type)}::${norm(obj.object_name)}`;
  return crypto.createHash('sha256').update(raw).digest('hex').slice(0, 16);
}

function fingerprint(obj) {
  const comparable = {
    object_name: obj.object_name ?? '',
    object_type: obj.object_type ?? '',
    state: obj.state ?? '',
    summary: obj.summary ?? '',
    evidence: obj.evidence ?? [],
    scores: obj.scores ?? {},
    relationships: obj.relationships ?? [],
    next_action: obj.next_action ?? '',
  };
  return crypto.createHash('sha256').update(JSON.stringify(comparable)).digest('hex');
}

function normaliseObjects(snapshot) {
  const objects = Array.isArray(snapshot.objects) ? snapshot.objects : [];
  return objects.map((obj) => ({
    ...obj,
    object_id: stableId(obj),
    _fingerprint: fingerprint(obj),
    _key: `${norm(obj.object_type)}::${norm(obj.object_name)}`,
  }));
}

function indexById(objects) {
  return new Map(objects.map((obj) => [obj.object_id, obj]));
}

function groupByKey(objects) {
  const grouped = new Map();
  for (const obj of objects) {
    if (!grouped.has(obj._key)) grouped.set(obj._key, []);
    grouped.get(obj._key).push(obj);
  }
  return grouped;
}

function scoreCard(obj) {
  const s = obj.scores ?? {};
  const evidence_strength = Number(s.evidence_strength ?? inferEvidenceStrength(obj));
  const source_count = Number(s.source_count ?? (Array.isArray(obj.evidence) ? obj.evidence.length : 0));
  const recency = Number(s.recency ?? 0.5);
  const reuse_potential = Number(s.reuse_potential ?? 0.5);
  const revenue_potential = Number(s.revenue_potential ?? 0.5);
  const execution_readiness = Number(s.execution_readiness ?? 0.5);
  const confidence = Number(s.confidence ?? 0.5);
  const portfolio_value_score = Number(
    s.portfolio_value_score ??
    weightedAverage([
      [evidence_strength, 0.16],
      [Math.min(source_count / 5, 1), 0.10],
      [recency, 0.10],
      [reuse_potential, 0.22],
      [revenue_potential, 0.22],
      [execution_readiness, 0.12],
      [confidence, 0.08],
    ])
  );
  return clampScores({ evidence_strength, source_count, recency, reuse_potential, revenue_potential, execution_readiness, confidence, portfolio_value_score });
}

function inferEvidenceStrength(obj) {
  const count = Array.isArray(obj.evidence) ? obj.evidence.length : 0;
  if (count >= 5) return 0.9;
  if (count >= 3) return 0.7;
  if (count >= 1) return 0.45;
  return 0.15;
}

function weightedAverage(items) {
  const totalWeight = items.reduce((sum, [, weight]) => sum + weight, 0);
  return items.reduce((sum, [value, weight]) => sum + clamp01(value) * weight, 0) / totalWeight;
}

function clamp01(value) {
  if (!Number.isFinite(value)) return 0;
  return Math.max(0, Math.min(1, value));
}

function clampScores(scores) {
  return {
    ...scores,
    evidence_strength: clamp01(scores.evidence_strength),
    recency: clamp01(scores.recency),
    reuse_potential: clamp01(scores.reuse_potential),
    revenue_potential: clamp01(scores.revenue_potential),
    execution_readiness: clamp01(scores.execution_readiness),
    confidence: clamp01(scores.confidence),
    portfolio_value_score: clamp01(scores.portfolio_value_score),
  };
}

function deltaItem(obj, deltaType, summary, previousState = undefined, currentState = undefined) {
  return {
    object_id: obj.object_id,
    object_name: obj.object_name,
    object_type: obj.object_type,
    delta_type: deltaType,
    previous_state: previousState,
    current_state: currentState ?? obj.state,
    summary,
    evidence: obj.evidence ?? [],
    scores: scoreCard(obj),
    next_action: obj.next_action ?? defaultNextAction(deltaType, obj),
  };
}

function defaultNextAction(deltaType, obj) {
  switch (deltaType) {
    case 'new': return 'Classify, score, and decide active/incubating/parked/dead.';
    case 'changed': return 'Review change and update registry.';
    case 'disappeared': return 'Confirm whether item was intentionally removed, merged, or lost.';
    case 'duplicated': return 'Merge duplicates or create canonical object.';
    case 'contradicted': return 'Resolve contradiction class and choose source of authority.';
    case 'promoted': return 'Move to next operational/commercial gate.';
    case 'demoted': return 'Repair, park, or kill based on evidence.';
    default: return 'Review.';
  }
}

function stateRank(state) {
  return LIFECYCLE_RANK[norm(state)] ?? 0;
}

function detectContradiction(prev, curr) {
  const contradictions = [];
  if (norm(prev.object_name) !== norm(curr.object_name) && norm(prev.object_type) === norm(curr.object_type)) {
    contradictions.push('naming_contradiction');
  }
  if (norm(prev.state) === 'active' && ['dead', 'deprecated', 'superseded'].includes(norm(curr.state))) {
    contradictions.push('strategy_contradiction');
  }
  if (norm(prev.summary) && norm(curr.summary) && norm(prev.summary) !== norm(curr.summary)) {
    const prevSaysDoc = norm(prev.summary).includes('document') || norm(prev.summary).includes('issue');
    const currSaysBuild = norm(curr.summary).includes('build') || norm(curr.summary).includes('runtime');
    if (prevSaysDoc && currSaysBuild) contradictions.push('said_build_did_document_failure');
  }
  const prevEvidence = new Set((prev.evidence ?? []).map(norm));
  const currEvidence = new Set((curr.evidence ?? []).map(norm));
  if (prevEvidence.size && currEvidence.size && [...prevEvidence].every((e) => !currEvidence.has(e))) {
    contradictions.push('evidence_mismatch');
  }
  return contradictions.filter((c) => CONTRADICTION_CLASSES.includes(c));
}

function compareSnapshots(baseline, current) {
  const baseObjects = normaliseObjects(baseline);
  const currObjects = normaliseObjects(current);
  const baseById = indexById(baseObjects);
  const currById = indexById(currObjects);
  const currByKey = groupByKey(currObjects);

  const deltas = {
    new: [],
    changed: [],
    disappeared: [],
    duplicated: [],
    contradicted: [],
    promoted: [],
    demoted: [],
  };

  for (const curr of currObjects) {
    const prev = baseById.get(curr.object_id);
    if (!prev) {
      deltas.new.push(deltaItem(curr, 'new', 'Object exists in current snapshot but not baseline.'));
      continue;
    }

    if (prev._fingerprint !== curr._fingerprint) {
      deltas.changed.push(deltaItem(curr, 'changed', 'Object fingerprint changed since baseline.', prev.state, curr.state));
    }

    const rankDelta = stateRank(curr.state) - stateRank(prev.state);
    if (rankDelta > 0) {
      deltas.promoted.push(deltaItem(curr, 'promoted', `Lifecycle state advanced from ${prev.state ?? 'unknown'} to ${curr.state ?? 'unknown'}.`, prev.state, curr.state));
    } else if (rankDelta < 0) {
      deltas.demoted.push(deltaItem(curr, 'demoted', `Lifecycle state regressed from ${prev.state ?? 'unknown'} to ${curr.state ?? 'unknown'}.`, prev.state, curr.state));
    }

    const contradictionClasses = detectContradiction(prev, curr);
    for (const klass of contradictionClasses) {
      deltas.contradicted.push(deltaItem(curr, 'contradicted', `Contradiction detected: ${klass}.`, prev.state, curr.state));
    }
  }

  for (const prev of baseObjects) {
    if (!currById.has(prev.object_id)) {
      deltas.disappeared.push(deltaItem(prev, 'disappeared', 'Object existed in baseline but not current snapshot.', prev.state, undefined));
    }
  }

  for (const [, group] of currByKey) {
    if (group.length > 1) {
      for (const obj of group) {
        deltas.duplicated.push(deltaItem(obj, 'duplicated', `Duplicate canonical key found ${group.length} times.`));
      }
    }
  }

  sortDeltaBuckets(deltas);

  return {
    run_id: `delta-${new Date().toISOString()}`,
    baseline_id: baseline.snapshot_id ?? baseline.run_id ?? 'baseline-unknown',
    current_id: current.snapshot_id ?? current.run_id ?? 'current-unknown',
    generated_at: new Date().toISOString(),
    deltas,
    receipt: buildReceipt(baseline, current, deltas),
  };
}

function sortDeltaBuckets(deltas) {
  for (const key of Object.keys(deltas)) {
    deltas[key].sort((a, b) => (b.scores?.portfolio_value_score ?? 0) - (a.scores?.portfolio_value_score ?? 0));
  }
}

function buildReceipt(baseline, current, deltas) {
  const objectCounts = {
    baseline: Array.isArray(baseline.objects) ? baseline.objects.length : 0,
    current: Array.isArray(current.objects) ? current.objects.length : 0,
  };
  const deltasFound = Object.fromEntries(Object.entries(deltas).map(([k, v]) => [k, v.length]));
  return {
    run_id: `receipt-${new Date().toISOString()}`,
    source_set: [baseline.snapshot_id ?? 'baseline', current.snapshot_id ?? 'current'],
    object_counts: objectCounts,
    deltas_found: deltasFound,
    actions_created: [],
    files_written: [],
    issues_created_or_updated: [],
    blockers: [],
    next_run_trigger: 'Run after next extractor snapshot or scheduled interval.',
  };
}

function main() {
  const [, , baselinePath, currentPath] = process.argv;
  if (!baselinePath || !currentPath) {
    console.error('Usage: node corpus-intelligence/delta_engine.mjs baseline.json current.json');
    process.exit(2);
  }
  const baseline = readJson(baselinePath);
  const current = readJson(currentPath);
  console.log(JSON.stringify(compareSnapshots(baseline, current), null, 2));
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { compareSnapshots };
