import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import crypto from 'node:crypto';
import { execFileSync, spawnSync } from 'node:child_process';

export const REPO = 'TML-4PM/the-pen';
export const ROOT = process.cwd();
export const RUNTIME_DIR = path.join(ROOT, '.runtime');
export const RECEIPTS_DIR = path.join(RUNTIME_DIR, 'receipts');
export const STATE_PATH = path.join(RUNTIME_DIR, 'state.json');

export function ensureDirs() {
  fs.mkdirSync(RECEIPTS_DIR, { recursive: true });
}

export function now() {
  return new Date().toISOString();
}

export function run(cmd, args = [], options = {}) {
  const result = spawnSync(cmd, args, {
    cwd: options.cwd || ROOT,
    encoding: 'utf8',
    env: { ...process.env, ...(options.env || {}) },
    stdio: options.inherit ? 'inherit' : 'pipe'
  });
  return {
    ok: result.status === 0,
    status: result.status,
    stdout: (result.stdout || '').trim(),
    stderr: (result.stderr || '').trim()
  };
}

export function requireCommand(command, args = ['--version']) {
  const result = run(command, args);
  return { command, ...result };
}

export function readJSON(file, fallback = {}) {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); } catch { return fallback; }
}

export function writeJSON(file, value) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
}

export function sha256File(file) {
  const hash = crypto.createHash('sha256');
  hash.update(fs.readFileSync(file));
  return hash.digest('hex');
}

export function listFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...listFiles(full));
    else out.push(full);
  }
  return out.sort();
}

export function emitReceipt(stage, data) {
  ensureDirs();
  const receipt = {
    schema_version: '1.0',
    run_id: process.env.T4H_RUN_ID || `runtime-${Date.now()}`,
    stage,
    timestamp: now(),
    repository: REPO,
    cwd: ROOT,
    host: os.hostname(),
    ...data
  };
  const file = path.join(RECEIPTS_DIR, `${stage}.json`);
  writeJSON(file, receipt);
  console.log(JSON.stringify(receipt, null, 2));
  return receipt;
}

export function gitRoot() {
  const r = run('git', ['rev-parse', '--show-toplevel']);
  return r.ok ? r.stdout : null;
}

export function gitStatus() {
  return run('git', ['status', '--short']).stdout;
}

export function awsIdentity() {
  const r = run('aws', ['sts', 'get-caller-identity', '--output', 'json']);
  if (!r.ok) return { ok: false, error: r.stderr || r.stdout };
  try { return { ok: true, ...JSON.parse(r.stdout) }; }
  catch { return { ok: false, error: 'invalid AWS identity JSON' }; }
}

export function findCandidateExport() {
  const candidates = [
    path.join(ROOT, 'runtime/issue-267/fy2425-fresh-export'),
    path.join(ROOT, 'runtime/issue-267'),
    path.join(ROOT, 'dist'),
    path.join(ROOT, 'build')
  ];
  return candidates.find(p => fs.existsSync(p) && fs.statSync(p).isDirectory()) || null;
}
