'use strict';
const { createClient } = require('@supabase/supabase-js');

const sb = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

exports.handler = async (event) => {
  try {
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : (event.body ?? event);
    const { id, promote_to, payload = {}, force = false } = body;

    if (!id) return respond(400, { ok: false, error: 'id is required' });

    // Fetch item
    const { data: item, error: fetchErr } = await sb
      .from('ops_predev')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchErr || !item) return respond(404, { ok: false, error: 'item not found' });

    if (!force && item.status !== 'ready')
      return respond(409, { ok: false, error: `status is '${item.status}', not ready. Use force:true to override.` });

    if (item.status === 'promoted')
      return respond(200, { ok: true, id, queue_id: item.promoted_queue_id, status: 'promoted', existing: true });

    // Resolve fn
    const fn = promote_to || item.promote_to;
    let queue_id = null;

    // Enqueue to agent_work_queue if fn specified
    if (fn) {
      const { data: qrow, error: qErr } = await sb
        .from('agent_work_queue')
        .insert({
          queue_key:    'predev',
          business_key: item.business_key || 'T4H',
          order_key:    id,
          job_type:     fn,
          job_status:   'pending',
          priority:     item.priority,
          payload: {
            ...payload,
            predev_id:    id,
            title:        item.title,
            source_type:  item.source_type,
            source_ref:   item.source_ref,
            pillar:       item.pillar,
            is_rd:        item.is_rd,
            project_code: item.project_code,
          },
        })
        .select('id')
        .single();

      if (qErr) {
        console.error('queue insert error:', qErr);
        return respond(500, { ok: false, error: `queue insert failed: ${qErr.message}` });
      }
      queue_id = qrow?.id;
    }

    // Flip status — DB trigger fires unblock cascade automatically
    const { error: updateErr } = await sb
      .from('ops_predev')
      .update({ status: 'promoted', promoted_queue_id: queue_id })
      .eq('id', id);

    if (updateErr) throw updateErr;

    // Write system receipt row for audit
    await sb.from('ops_predev').insert({
      title:       `RECEIPT: promoted "${item.title.slice(0,80)}"`,
      item_type:   'pen',
      status:      'promoted',
      source_type: 'agent',
      source_ref:  id,
      notes:       JSON.stringify({ promoted_id: id, queue_id, fn, ts: new Date().toISOString() }),
      priority:    5,
    });

    return respond(200, { ok: true, predev_id: id, queue_id, fn: fn || null, status: 'promoted' });

  } catch (err) {
    console.error('predev-promote error:', err);
    return respond(500, { ok: false, error: err.message || 'internal error' });
  }
};

function respond(statusCode, body) {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  };
}
