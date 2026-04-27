'use strict';
const { createClient } = require('@supabase/supabase-js');

const sb = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const VALID_TYPES   = ['wip','pen'];
const VALID_STATUS  = ['parked','blocked','ready'];
const VALID_SOURCES = ['pen','wip','lambda','bridge','agent','manual'];
const VALID_PILLARS = ['01_MCP','02_JOBS','03_BUSINESS','04_RESEARCH','05_PERSONAL'];

exports.handler = async (event) => {
  try {
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : (event.body ?? event);

    const {
      title,
      item_type    = 'wip',
      source_type  = 'manual',
      source_ref,
      pillar,
      business_key,
      priority     = 3,
      blocked_by   = [],
      block_ref,
      promote_to,
      auto_promote = false,
      notes,
      is_rd        = false,
      project_code,
    } = body;

    // Validation
    if (!title || typeof title !== 'string' || !title.trim())
      return respond(400, { ok: false, error: 'title is required' });
    if (!VALID_TYPES.includes(item_type))
      return respond(400, { ok: false, error: `item_type must be one of: ${VALID_TYPES.join(',')}` });
    if (!Number.isInteger(priority) || priority < 1 || priority > 5)
      return respond(400, { ok: false, error: 'priority must be integer 1-5' });

    // Idempotency: dedupe on source_ref + source_type
    if (source_ref) {
      const { data: existing } = await sb
        .from('ops_predev')
        .select('id,status')
        .eq('source_ref', source_ref)
        .eq('source_type', source_type)
        .not('status', 'in', '("promoted","cancelled")')
        .limit(1);

      if (existing?.length) {
        return respond(200, { ok: true, id: existing[0].id, status: existing[0].status, existing: true });
      }
    }

    const status = (blocked_by?.length > 0) ? 'blocked' : 'parked';

    const { data, error } = await sb
      .from('ops_predev')
      .insert({
        title:        title.trim().slice(0, 500),
        item_type,
        status,
        priority,
        pillar:       VALID_PILLARS.includes(pillar) ? pillar : null,
        business_key: business_key || null,
        source_type:  VALID_SOURCES.includes(source_type) ? source_type : 'manual',
        source_ref:   source_ref || null,
        blocked_by:   Array.isArray(blocked_by) ? blocked_by : [],
        block_ref:    block_ref || null,
        promote_to:   promote_to || null,
        auto_promote: Boolean(auto_promote),
        notes:        notes || null,
        is_rd:        Boolean(is_rd),
        project_code: project_code || null,
      })
      .select('id,status,created_at')
      .single();

    if (error) throw error;

    return respond(200, { ok: true, id: data.id, status: data.status, created_at: data.created_at });

  } catch (err) {
    console.error('predev-ingest error:', err);
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
