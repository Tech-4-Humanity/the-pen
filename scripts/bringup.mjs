import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve('projects/the-watcher-sessions');
const runtimeDir = path.join(root, 'runtime');
fs.mkdirSync(runtimeDir, { recursive: true });

const state = {
  status: 'PARTIAL',
  project: 'the-watcher-sessions',
  target_site: 'https://ai-era-thinking.lovable.app/',
  branch: process.env.GITHUB_HEAD_REF || process.env.GITHUB_REF_NAME || 'story/the-watcher-sessions-rewrite',
  current_sprint: 'act-ii-draft',
  next_action: 'advance manuscript and refresh bundle',
  updated_at: new Date().toISOString()
};

fs.writeFileSync(path.join(runtimeDir, 'state.json'), JSON.stringify(state, null, 2) + '\n');
console.log(JSON.stringify({ status: 'REAL', action: 'bringup', runtime_state: path.relative(process.cwd(), path.join(runtimeDir, 'state.json')) }, null, 2));
