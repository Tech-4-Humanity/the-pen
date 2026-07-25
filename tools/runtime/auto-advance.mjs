import fs from 'node:fs';
import path from 'node:path';
import { emitReceipt, listFiles, readJSON, run, sha256File, STATE_PATH } from './lib.mjs';

const state = readJSON(STATE_PATH, {});
const source = process.env.T4H_DEPLOY_SOURCE || state.output;
const websiteMode = Boolean(process.env.T4H_WEBSITE_BUCKET || state.websiteBucket);
const bucket = process.env.T4H_TARGET_BUCKET || process.env.T4H_WEBSITE_BUCKET || state.websiteBucket || state.archiveBucket;
const prefix = process.env.T4H_TARGET_PREFIX ?? (websiteMode ? '' : state.archivePrefix || '');
const distribution = process.env.T4H_CLOUDFRONT_DISTRIBUTION || state.cloudfrontDistribution || null;

if (!source || !fs.existsSync(source)) {
  emitReceipt('auto-advance', { classification: 'BLOCKED', reason: 'source directory unavailable', source });
  process.exit(1);
}
if (!bucket) {
  emitReceipt('auto-advance', { classification: 'BLOCKED', reason: 'target bucket unavailable' });
  process.exit(1);
}

const files = listFiles(source).filter(f => path.basename(f) !== '.gitkeep');
if (!files.length) {
  emitReceipt('auto-advance', {
    classification: 'PARTIAL',
    reason: 'source directory exists but contains no deployable files',
    source,
    missing: state.missing || []
  });
  process.exit(2);
}

if (websiteMode && /archive|evidence|private/i.test(bucket)) {
  emitReceipt('auto-advance', {
    classification: 'BLOCKED',
    reason: 'safety control refused public website deployment to archive/private bucket',
    bucket
  });
  process.exit(1);
}

const cleanPrefix = prefix ? prefix.replace(/^\/+|\/+$/g, '') : '';
const s3Uri = `s3://${bucket}/${cleanPrefix ? `${cleanPrefix}/` : ''}`;
const syncArgs = ['s3', 'sync', source, s3Uri, '--only-show-errors'];
if (process.env.T4H_SYNC_DELETE === '1') syncArgs.push('--delete');
const upload = run('aws', syncArgs);

let invalidation = null;
if (upload.ok && distribution) {
  const result = run('aws', ['cloudfront', 'create-invalidation', '--distribution-id', distribution, '--paths', '/*', '--output', 'json']);
  invalidation = { ok: result.ok, stdout: result.stdout, stderr: result.stderr };
}

const manifest = files.map(file => ({
  path: path.relative(source, file),
  size: fs.statSync(file).size,
  sha256: sha256File(file),
  s3_uri: `${s3Uri}${path.relative(source, file).split(path.sep).join('/')}`
}));

const classification = upload.ok && (!invalidation || invalidation.ok) ? 'PARTIAL' : 'BLOCKED';
emitReceipt('auto-advance', {
  classification,
  source,
  target: s3Uri,
  upload: { ok: upload.ok, stdout: upload.stdout, stderr: upload.stderr },
  invalidation,
  manifest,
  next_stage: upload.ok ? 'verify' : null
});

if (!upload.ok || (invalidation && !invalidation.ok)) process.exit(1);

const verify = run('node', ['tools/runtime/verify.mjs'], { inherit: true });
process.exit(verify.status ?? 1);
