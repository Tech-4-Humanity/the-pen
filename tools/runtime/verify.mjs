import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { ROOT, emitReceipt, listFiles, readJSON, run, sha256File, STATE_PATH } from './lib.mjs';

const state = readJSON(STATE_PATH, {});
const source = process.env.T4H_DEPLOY_SOURCE || state.output;
const bucket = process.env.T4H_TARGET_BUCKET || state.websiteBucket || state.archiveBucket;
const prefix = process.env.T4H_TARGET_PREFIX ?? (state.websiteBucket ? '' : state.archivePrefix || '');
const liveUrl = process.env.T4H_LIVE_URL || state.liveUrl || null;

if (!source || !fs.existsSync(source)) {
  emitReceipt('verify', { classification: 'BLOCKED', reason: 'deployment source missing', source });
  process.exit(1);
}
if (!bucket) {
  emitReceipt('verify', { classification: 'BLOCKED', reason: 'target bucket missing', source });
  process.exit(1);
}

const localFiles = listFiles(source).filter(f => path.basename(f) !== '.gitkeep');
const verifyDir = fs.mkdtempSync(path.join(os.tmpdir(), 't4h-runtime-readback-'));
const s3Uri = `s3://${bucket}/${prefix ? `${prefix.replace(/^\/+|\/+$/g, '')}/` : ''}`;
const readback = run('aws', ['s3', 'sync', s3Uri, verifyDir, '--only-show-errors']);

const rows = localFiles.map(file => {
  const rel = path.relative(source, file);
  const remote = path.join(verifyDir, rel);
  const localHash = sha256File(file);
  const exists = fs.existsSync(remote);
  const remoteHash = exists ? sha256File(remote) : null;
  return { path: rel, local_sha256: localHash, readback_sha256: remoteHash, match: exists && localHash === remoteHash };
});

let endpoint = null;
if (liveUrl) {
  const http = run('curl', ['-fsSIL', '--max-time', '30', liveUrl]);
  endpoint = { url: liveUrl, ok: http.ok, response: http.stdout || http.stderr };
}

const allMatched = rows.length > 0 && rows.every(r => r.match);
const classification = readback.ok && allMatched && (!endpoint || endpoint.ok) ? 'REAL' : 'PARTIAL';
emitReceipt('verify', {
  classification,
  source,
  s3_uri: s3Uri,
  readback: { ok: readback.ok, stderr: readback.stderr, directory: verifyDir },
  objects: rows,
  endpoint
});

if (classification !== 'REAL') process.exit(1);
