import fs from 'fs';
import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
const sb = (url && key) ? createClient(url, key, { auth: { persistSession: false }}) : null;

const checks = [];

// Check latest receipt exists
let latestOk = false;
try {
  const txt = fs.readFileSync('receipts/runtime/latest.json','utf8');
  const j = JSON.parse(txt);
  latestOk = !!j.request_id;
} catch {}
checks.push({ check_id: 'latest_receipt', check_type: 'artifact', status: latestOk ? 'PASS' : 'FAIL' });

// Check workflow file present
const wfOk = fs.existsSync('.github/workflows/pen-execution-worker.yml');
checks.push({ check_id: 'workflow_exists', check_type: 'config', status: wfOk ? 'PASS' : 'FAIL' });

// Check executor present
const execOk = fs.existsSync('scripts/pen-executor.mjs');
checks.push({ check_id: 'executor_exists', check_type: 'config', status: execOk ? 'PASS' : 'FAIL' });

// Optional: Supabase connectivity (light)
let sbOk = false;
if (sb) {
  try {
    const { error } = await sb.from('pen_execution_ledger').select('id').limit(1);
    sbOk = !error;
  } catch {}
}
checks.push({ check_id: 'supabase_connectivity', check_type: 'external', status: sbOk ? 'PASS' : 'WARN' });

// Persist to Supabase if available
if (sb) {
  for (const c of checks) {
    await sb.from('pen_drift_checks').insert({
      check_id: c.check_id,
      check_type: c.check_type,
      status: c.status,
      expected: {},
      actual: {},
      recovery_action: c.status === 'FAIL' ? 'Investigate and restore missing component' : null
    });
  }
}

// Also write local report
const day = new Date().toISOString().substring(0,10);
const p = `outputs/runtime/${day}/drift-check.json`;
fs.mkdirSync(`outputs/runtime/${day}`, { recursive: true });
fs.writeFileSync(p, JSON.stringify({ checks }, null, 2));

console.log('DRIFT CHECK COMPLETE', checks);
