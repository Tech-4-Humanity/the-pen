import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { ROOT, emitReceipt, run, sha256File } from './lib.mjs';

const dist = path.join(ROOT, 'dist');
fs.mkdirSync(dist, { recursive: true });
const zip = path.join(dist, 'T4H-The-Pen-Runtime-Bootstrap.zip');
if (fs.existsSync(zip)) fs.unlinkSync(zip);

const include = [
  'BOOTSTRAP.command',
  'package.json',
  'package-lock.json',
  'tools/runtime',
  'tests/runtime',
  'runtime.config.example.json',
  'README.RUNTIME.md'
].filter(p => fs.existsSync(path.join(ROOT, p)));

const result = run('zip', ['-qry', zip, ...include]);
if (!result.ok) {
  emitReceipt('bundle', { classification: 'BLOCKED', error: result.stderr || result.stdout, include });
  process.exit(1);
}

emitReceipt('bundle', {
  classification: 'REAL',
  bundle: path.relative(ROOT, zip),
  sha256: sha256File(zip),
  size: fs.statSync(zip).size,
  included: include,
  host: os.hostname()
});
