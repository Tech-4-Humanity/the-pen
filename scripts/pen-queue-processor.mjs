import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !key) {
  console.error('Missing Supabase env');
  process.exit(0);
}

const sb = createClient(url, key, { auth: { persistSession: false }});

const now = new Date().toISOString();

const { data: tasks } = await sb
  .from('pen_task_queue')
  .select('*')
  .in('status', ['queued','running'])
  .lte('next_run_at', now)
  .order('priority', { ascending: true })
  .limit(5);

for (const t of tasks || []) {
  const attempt = t.attempt_count + 1;
  const max = t.max_attempts;
  const nextDelaySec = Math.min(300, Math.pow(2, attempt) * 5); // exponential backoff capped
  try {
    await sb.from('pen_task_queue').update({ status: 'running', attempt_count: attempt, updated_at: now }).eq('id', t.id);

    // Execute task via local executor
    const { spawnSync } = await import('child_process');
    const res = spawnSync('node', ['scripts/pen-executor.mjs', t.task_id, 'execute'], { encoding: 'utf8' });

    if (res.status !== 0) throw new Error(res.stderr || 'executor failed');

    // Load latest receipt
    const latest = JSON.parse(fs.readFileSync('receipts/runtime/latest.json','utf8'));

    // Write ledger
    await sb.from('pen_execution_ledger').insert({
      request_id: latest.request_id,
      task_id: t.task_id,
      source: 'queue-processor',
      status: latest.status,
      reality_classification: latest.reality_classification,
      receipt: latest,
      output_refs: latest.outputs,
      log_refs: latest.logs
    });

    // Value event (log-only by default)
    await sb.from('pen_value_events').insert({
      task_id: t.task_id,
      request_id: latest.request_id,
      unit_amount_cents: 0,
      quantity: 1,
      monetisation_status: 'log_only'
    });

    await sb.from('pen_task_queue').update({ status: 'succeeded', updated_at: now }).eq('id', t.id);
  } catch (e) {
    const failed = attempt >= max;
    const next = new Date(Date.now() + nextDelaySec * 1000).toISOString();
    await sb.from('pen_task_queue').update({
      status: failed ? 'dead_letter' : 'queued',
      last_error: String(e),
      next_run_at: next,
      updated_at: now
    }).eq('id', t.id);
  }
}
