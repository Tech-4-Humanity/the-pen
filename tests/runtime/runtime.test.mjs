import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';

function sha256(file) {
  return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
}

function isArchiveBucket(name) {
  return /archive|evidence|private/i.test(name);
}

test('sha256 changes when file content changes', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 't4h-test-'));
  const file = path.join(dir, 'x.txt');
  fs.writeFileSync(file, 'one');
  const first = sha256(file);
  fs.writeFileSync(file, 'two');
  const second = sha256(file);
  assert.notEqual(first, second);
});

test('archive bucket safety classifier catches private targets', () => {
  assert.equal(isArchiveBucket('t4h-archive-140548542136'), true);
  assert.equal(isArchiveBucket('customer-public-site'), false);
});

test('bootstrap launcher is self-locating', () => {
  const text = fs.readFileSync('BOOTSTRAP.command', 'utf8');
  assert.match(text, /find_repo/);
  assert.match(text, /git clone/);
  assert.match(text, /npm run doctor/);
  assert.match(text, /npm run bringup/);
  assert.match(text, /npm run runtime:auto-advance/);
});
