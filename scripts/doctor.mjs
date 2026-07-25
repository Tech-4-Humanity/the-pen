import fs from 'node:fs';
import path from 'node:path';

const required = [
  'projects/the-watcher-sessions/README.md',
  'projects/the-watcher-sessions/manuscript/the-watcher-sessions.md',
  'projects/the-watcher-sessions/story-bible/rewrite-brief.md',
  'projects/the-watcher-sessions/editorial/act-1-review.md',
  'projects/the-watcher-sessions/site/ai-era-thinking-integration.md'
];

const missing = required.filter((file) => !fs.existsSync(path.resolve(file)));
if (missing.length) {
  console.error('DOCTOR_BLOCKED');
  for (const file of missing) console.error(`missing: ${file}`);
  process.exit(1);
}

const manuscript = fs.readFileSync('projects/the-watcher-sessions/manuscript/the-watcher-sessions.md', 'utf8');
const chapters = [...manuscript.matchAll(/^### Chapter\s+\d+/gm)].length;
if (chapters < 6) {
  console.error(`DOCTOR_BLOCKED: expected at least 6 canonical chapters, found ${chapters}`);
  process.exit(1);
}

console.log(JSON.stringify({ status: 'REAL', check: 'doctor', chapters, required_files: required.length }, null, 2));
