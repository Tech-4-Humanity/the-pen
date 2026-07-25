import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawnSync } from 'node:child_process';

const root = path.resolve('projects/the-watcher-sessions');
const dist = path.join(root, 'dist');
const bundleRoot = path.join(dist, 'the-watcher-sessions-deploy');
fs.rmSync(bundleRoot, { recursive: true, force: true });
fs.mkdirSync(bundleRoot, { recursive: true });

const include = ['README.md', 'manuscript', 'story-bible', 'editorial', 'publishing', 'site', 'runtime', 'receipts'];
for (const entry of include) {
  const source = path.join(root, entry);
  if (!fs.existsSync(source)) continue;
  fs.cpSync(source, path.join(bundleRoot, entry), { recursive: true });
}

const zipPath = path.join(dist, 'the-watcher-sessions-deploy.zip');
fs.rmSync(zipPath, { force: true });
const zip = spawnSync('zip', ['-qr', zipPath, path.basename(bundleRoot)], { cwd: dist, encoding: 'utf8' });
if (zip.error || zip.status !== 0) {
  console.error(zip.stderr || zip.error?.message || 'zip failed');
  process.exit(1);
}

const bytes = fs.readFileSync(zipPath);
const receipt = {
  status: 'REAL',
  artifact: path.relative(process.cwd(), zipPath),
  bytes: bytes.length,
  sha256: crypto.createHash('sha256').update(bytes).digest('hex'),
  created_at: new Date().toISOString()
};
fs.mkdirSync(path.join(root, 'receipts'), { recursive: true });
fs.writeFileSync(path.join(root, 'receipts', 'bundle-receipt.json'), JSON.stringify(receipt, null, 2) + '\n');
console.log(JSON.stringify(receipt, null, 2));
