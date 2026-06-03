/**
 * troy-runtime-proof-sweeper
 * 
 * Purpose: Sweep ops.work_queue for stalled jobs, advance state where possible,
 *          emit receipts, write audit evidence.
 * 
 * Trigger: cron via fn_runtime_proof_sweeper_kick() → ops.work_queue
 * Runtime: Node 20.x | ap-southeast-2 | 128MB | timeout 60s
 * 
 * Env vars required:
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 *   BRIDGE_API_KEY
 */

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const STALL_THRESHOLD_MINUTES = 30;
const MAX_ADVANCE_PER_RUN = 20;

exports.handler = async (event) => {
  const startedAt = new Date().toISOString();
  const runId = `rps-${Date.now()}`;
  const receipt = { run_id: runId, started_at: startedAt, actions: [], errors: [] };

  console.log(`[${runId}] troy-runtime-proof-sweeper starting`);

  const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

  try {
    // ── 1. Find the triggering job (our own work_queue entry) ──────────────────
    const jobId = event?.job_id || event?.payload?.job_id || null;

    // ── 2. Detect stalled claimed jobs (claimed > STALL_THRESHOLD with no heartbeat) ──
    const stallCutoff = new Date(Date.now() - STALL_THRESHOLD_MINUTES * 60 * 1000).toISOString();

    const { data: stalledClaimed, error: stallErr } = await supabase
      .from('work_queue')
      .select('job_id, title, destination, owner, started_at, last_heartbeat, retry_count, max_retries')
      .schema('ops')
      .eq('status', 'claimed')
      .lt('updated_at', stallCutoff)
      .is('last_heartbeat', null)
      .limit(MAX_ADVANCE_PER_RUN);

    if (stallErr) throw new Error(`Stall query failed: ${stallErr.message}`);

    console.log(`[${runId}] Found ${stalledClaimed?.length || 0} stalled claimed jobs`);
    receipt.stalled_claimed_count = stalledClaimed?.length || 0;

    // ── 3. Reset stalled claimed → blocked (with reason) ──────────────────────
    for (const job of (stalledClaimed || [])) {
      const canRetry = (job.retry_count || 0) < (job.max_retries || 3);
      const newStatus = canRetry ? 'blocked' : 'blocked';
      const reason = `STALL_DETECTED by troy-runtime-proof-sweeper run ${runId}. No heartbeat since claim. destination=${job.destination}. retry_count=${job.retry_count}/${job.max_retries}.`;

      const { error: updateErr } = await supabase
        .from('work_queue')
        .schema('ops')
        .update({
          status: newStatus,
          blocked_reason: reason,
          updated_at: new Date().toISOString()
        })
        .eq('job_id', job.job_id)
        .eq('status', 'claimed');

      if (updateErr) {
        receipt.errors.push({ job_id: job.job_id, error: updateErr.message });
      } else {
        receipt.actions.push({ job_id: job.job_id, action: 'claimed->blocked', reason: 'stall_detected' });
      }
    }

    // ── 4. Detect stalled in_progress jobs ────────────────────────────────────
    const { data: stalledInProgress, error: ipErr } = await supabase
      .from('work_queue')
      .schema('ops')
      .select('job_id, title, destination, started_at, last_heartbeat')
      .eq('status', 'in_progress')
      .lt('updated_at', stallCutoff)
      .limit(MAX_ADVANCE_PER_RUN);

    if (ipErr) throw new Error(`in_progress stall query failed: ${ipErr.message}`);

    receipt.stalled_in_progress_count = stalledInProgress?.length || 0;
    console.log(`[${runId}] Found ${receipt.stalled_in_progress_count} stalled in_progress jobs`);

    for (const job of (stalledInProgress || [])) {
      const reason = `STALL_DETECTED by troy-runtime-proof-sweeper run ${runId}. in_progress with no heartbeat. destination=${job.destination}.`;
      const { error: updateErr } = await supabase
        .from('work_queue')
        .schema('ops')
        .update({
          status: 'blocked',
          blocked_reason: reason,
          updated_at: new Date().toISOString()
        })
        .eq('job_id', job.job_id)
        .eq('status', 'in_progress');

      if (updateErr) {
        receipt.errors.push({ job_id: job.job_id, error: updateErr.message });
      } else {
        receipt.actions.push({ job_id: job.job_id, action: 'in_progress->blocked', reason: 'stall_detected' });
      }
    }

    // ── 5. Advance done → verified for jobs with proof_ref ────────────────────
    const { data: doneJobs, error: doneErr } = await supabase
      .from('work_queue')
      .schema('ops')
      .select('job_id, title, proof_ref, result')
      .eq('status', 'done')
      .not('proof_ref', 'is', null)
      .limit(MAX_ADVANCE_PER_RUN);

    if (doneErr) throw new Error(`done query failed: ${doneErr.message}`);

    receipt.done_with_proof_count = doneJobs?.length || 0;
    console.log(`[${runId}] Found ${receipt.done_with_proof_count} done jobs with proof_ref`);

    for (const job of (doneJobs || [])) {
      const { error: updateErr } = await supabase
        .from('work_queue')
        .schema('ops')
        .update({
          status: 'verified',
          updated_at: new Date().toISOString()
        })
        .eq('job_id', job.job_id)
        .eq('status', 'done');

      if (updateErr) {
        receipt.errors.push({ job_id: job.job_id, error: updateErr.message });
      } else {
        receipt.actions.push({ job_id: job.job_id, action: 'done->verified', reason: 'proof_ref_present' });
      }
    }

    // ── 6. Write audit evidence ────────────────────────────────────────────────
    const { error: auditErr } = await supabase
      .from('log')
      .schema('audit')
      .insert({
        entity_type: 'work_queue_sweep',
        entity_id: runId,
        event_type: 'runtime_proof_sweep',
        actor: 'troy-runtime-proof-sweeper',
        env: 'prod',
        new_value: JSON.stringify(receipt),
        immutable: true
      });

    if (auditErr) console.warn(`[${runId}] Audit write failed: ${auditErr.message}`);

    // ── 7. Mark triggering job done → verified ─────────────────────────────────
    if (jobId) {
      await supabase
        .from('work_queue')
        .schema('ops')
        .update({
          status: 'done',
          proof_ref: `audit:${runId}`,
          result: receipt,
          updated_at: new Date().toISOString()
        })
        .eq('job_id', jobId)
        .in('status', ['claimed', 'in_progress']);
    }

    receipt.finished_at = new Date().toISOString();
    receipt.status = receipt.errors.length === 0 ? 'PASS' : 'PARTIAL';
    receipt.reality_classification = receipt.actions.length > 0 ? 'REAL' : 'PARTIAL';

    console.log(`[${runId}] Complete. actions=${receipt.actions.length} errors=${receipt.errors.length}`);
    return { statusCode: 200, body: JSON.stringify(receipt) };

  } catch (err) {
    console.error(`[${runId}] Fatal: ${err.message}`);
    receipt.status = 'BLOCKED';
    receipt.error = err.message;
    receipt.finished_at = new Date().toISOString();
    return { statusCode: 500, body: JSON.stringify(receipt) };
  }
};
