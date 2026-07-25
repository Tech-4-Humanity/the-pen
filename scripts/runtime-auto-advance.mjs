import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = path.resolve('projects/the-watcher-sessions');
const manuscriptPath = path.join(root, 'manuscript', 'the-watcher-sessions.md');
const runtimeDir = path.join(root, 'runtime');
const receiptsDir = path.join(root, 'receipts');
fs.mkdirSync(runtimeDir, { recursive: true });
fs.mkdirSync(receiptsDir, { recursive: true });

if (!fs.existsSync(manuscriptPath)) {
  console.error('AUTO_ADVANCE_BLOCKED: canonical manuscript missing');
  process.exit(1);
}

const manuscript = fs.readFileSync(manuscriptPath, 'utf8');
const chapterMatches = [...manuscript.matchAll(/^### Chapter\s+(\d+)\s+—\s+(.+)$/gm)];
const chapterCount = chapterMatches.length;
const wordCount = manuscript.trim().split(/\s+/).filter(Boolean).length;
const hash = crypto.createHash('sha256').update(manuscript).digest('hex');

const sprint = chapterCount < 10
  ? 'sprint-1-complete-act-i'
  : chapterCount < 18
    ? 'sprint-2-act-ii'
    : chapterCount < 26
      ? 'sprint-3-act-iii'
      : 'editorial-and-publication';

const state = {
  status: chapterCount >= 26 ? 'PARTIAL' : 'PARTIAL',
  project: 'the-watcher-sessions',
  chapter_count: chapterCount,
  word_count: wordCount,
  manuscript_sha256: hash,
  current_sprint: sprint,
  completion_rule: 'REAL only after complete manuscript, editorial evidence, publication assets, site deployment and receipts',
  target_site: 'https://ai-era-thinking.lovable.app/',
  updated_at: new Date().toISOString()
};

fs.writeFileSync(path.join(runtimeDir, 'state.json'), JSON.stringify(state, null, 2) + '\n');
fs.writeFileSync(path.join(receiptsDir, 'latest-runtime-receipt.json'), JSON.stringify({
  receipt_type: 'runtime_auto_advance',
  ...state
}, null, 2) + '\n');

try {
  execFileSync(process.execPath, ['scripts/bundle.mjs'], { stdio: 'inherit' });
} catch (error) {
  console.error('AUTO_ADVANCE_BLOCKED: bundle creation failed');
  process.exit(error.status || 1);
}

console.log(JSON.stringify({ status: 'REAL', action: 'runtime:auto-advance', sprint, chapter_count: chapterCount, word_count: wordCount, manuscript_sha256: hash }, null, 2));
