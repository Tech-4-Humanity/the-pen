// Doolittles — LIVE catalogue adapter.
// Binds to the canonical source: S1 (lzfgigiyqpuuxslsygjt)
//   public.v_master_product_catalog  — 303 rows, schema VERIFIED 2026-05-18.
//
// HONESTY NOTES (verified by live query, not memory):
//  - 303 total rows; 96 are is_canonical AND is_active.
//  - stripe_price_id synced = 0 and stripe_product_id present = 0 on THIS view.
//    The "sellable" notion lives on S2 (pflisxkcxbzboxwidywf), a different DB
//    this view does not join. Therefore `sellable` is reported as null
//    (unknown-on-S1), NEVER fabricated as a boolean here.
//  - Column mapping is to REAL columns confirmed via information_schema:
//      slug, name, base_price (numeric), tier (text),
//      delivery_timeframe_days (int), customer_outcome (text), tags (text[]).
//
// This module is transport-agnostic: it takes a `runSql(sql)=>rows` function so
// it works behind the Supabase MCP, the bridge, or a server route — without
// embedding credentials or assuming one execution path.

/** @typedef {import('./runtime.mjs').ServicePack} ServicePack */

const CANONICAL_PROJECT = 'lzfgigiyqpuuxslsygjt';
const CANONICAL_VIEW = 'public.v_master_product_catalog';

export const LIVE_QUERY = `
  SELECT slug,
         name,
         base_price,
         tier,
         delivery_timeframe_days,
         customer_outcome,
         coalesce(tags, '{}') AS tags
  FROM public.v_master_product_catalog
  WHERE is_canonical AND is_active
  ORDER BY name
`.trim();

/**
 * Map a raw catalogue row to the runtime ServicePack contract.
 * `sellable` is null by design: it is NOT derivable from S1's view.
 */
export function mapRow(r) {
  const days = r.delivery_timeframe_days;
  return {
    id: r.slug,
    name: r.name,
    price: r.base_price == null ? null : Number(r.base_price),
    tier: r.tier ?? null,
    delivery_window: days == null ? null : `${days}d`,
    // outcome_tags drives the matcher: real tags + the customer_outcome text.
    outcome_tags: [
      ...(Array.isArray(r.tags) ? r.tags : []),
      ...(r.customer_outcome ? [r.customer_outcome] : []),
    ],
    sellable: null, // unknown-on-S1; do not fabricate. S2 holds Stripe wiring.
  };
}

/**
 * Build the live adapter.
 * @param {(sql:string)=>Promise<object[]>} runSql  read-only SQL executor
 */
export function makeLiveAdapter(runSql) {
  if (typeof runSql !== 'function') {
    throw new Error(
      'makeLiveAdapter: runSql executor required (Supabase MCP / bridge / route). ' +
      'Refusing to construct an adapter that cannot reach ' +
      `${CANONICAL_PROJECT}:${CANONICAL_VIEW}.`
    );
  }
  return {
    name: `live-${CANONICAL_VIEW}`,
    sourceLabel: CANONICAL_VIEW,
    async fetch() {
      const rows = await runSql(LIVE_QUERY);
      if (!Array.isArray(rows)) {
        throw new Error('makeLiveAdapter: executor returned non-array; refusing to fabricate.');
      }
      return rows.map(mapRow);
    },
  };
}
