// Doolittles Runtime — experience layer over Synal.
// Loop: signal -> intent -> catalogue match -> work -> evidence -> replay.
//
// ENGINEERING NOTE (kernel-aligned): this is .mjs, not .ts, by deliberate choice.
// TML-4PM/the-pen has no TypeScript build config (Vercel framework=null,
// buildCommand=null, verified via vercel_project_inspect). Shipping a .ts that
// cannot execute in-repo would be PRETEND. Zero-build ESM executes everywhere
// the-pen already runs (Node 24.x, Vercel, CI) — REAL over decorative.
//
// ANTI-FABRICATION DISCIPLINE: the canonical catalogue is
//   public.v_master_product_catalog  (S1 lzfgigiyqpuuxslsygjt, 303 rows)
// sellable/Stripe-wired subset = 22 items on S2 (pflisxkcxbzboxwidywf).
// This runtime NEVER hardcodes catalogue rows. It consumes a CatalogueAdapter.
// A fixture adapter exists ONLY to exercise matcher logic in the local test and
// is structurally marked source:"fixture" so it can never masquerade as live
// data — the exact failure mode of the prior catalog_master "102 rows" fabrication.

/** @typedef {{ outcome:string, audience:string, urgency:string, proof:string, raw:string }} ParsedIntent */
/** @typedef {{ id:string, name:string, price:number|null, tier:string|null, delivery_window:string|null, outcome_tags:string[], sellable:boolean }} ServicePack */
/** @typedef {{ action:string, owner:string, state:string, source:string, evidence:string, ts:string }} ProofStep */

const URGENCY = [
  [/\b(now|today|urgent|asap|immediately|critical|emergency)\b/i, 'immediate'],
  [/\b(this week|soon|priority|fast)\b/i, 'near-term'],
];

const AUDIENCE = [
  [/\b(board|director|exec|leadership|investor)\b/i, 'leadership'],
  [/\b(customer|client|user|public|market)\b/i, 'external'],
  [/\b(team|staff|internal|ops)\b/i, 'internal'],
];

const PROOF = [
  [/\b(receipt|evidence|audit|ledger|prove|proof|verifiable)\b/i, 'evidence-required'],
];

function pick(text, table, fallback) {
  for (const [re, label] of table) if (re.test(text)) return label;
  return fallback;
}

const STOP = new Set(['the','a','an','to','for','of','and','or','i','we','need','want','get','our','my','with','please','can','you']);

function tokens(s) {
  return String(s).toLowerCase().match(/[a-z0-9]+/g)?.filter(t => t.length > 2 && !STOP.has(t)) ?? [];
}

/**
 * Parse free-text intent into a structured operational request.
 * @param {string} raw
 * @returns {ParsedIntent}
 */
export function parseIntent(raw) {
  const text = String(raw ?? '').trim();
  if (!text) throw new Error('parseIntent: empty intent');
  return {
    raw: text,
    outcome: text,
    audience: pick(text, AUDIENCE, 'unspecified'),
    urgency: pick(text, URGENCY, 'standard'),
    proof: pick(text, PROOF, 'standard'),
  };
}

/**
 * Deterministic outcome -> pack matcher. Pure; depends only on inputs.
 * @param {ParsedIntent} intent
 * @param {ServicePack[]} packs
 * @returns {{ pack:ServicePack, score:number, matched:string[] }[]}
 */
export function matchPacks(intent, packs) {
  const want = new Set(tokens(intent.outcome));
  const ranked = [];
  for (const p of packs) {
    const tags = new Set((p.outcome_tags ?? []).flatMap(tokens));
    const matched = [...want].filter(t => tags.has(t));
    let score = matched.length;
    if (intent.proof === 'evidence-required' && p.sellable) score += 0.5;
    if (score > 0) ranked.push({ pack: p, score, matched });
  }
  return ranked.sort((a, b) =>
    b.score - a.score || String(a.pack.id).localeCompare(String(b.pack.id))
  );
}

const now = () => new Date().toISOString();

/**
 * Run the full Doolittles loop and return a Signal Theatre frame.
 * @param {string} rawIntent
 * @param {{ name:string, sourceLabel:string, fetch:()=>Promise<ServicePack[]> }} adapter
 * @returns {Promise<{ intent:ParsedIntent, matches:any[], proof:ProofStep[], replay:string[], catalogueSource:string }>}
 */
export async function runDoolittles(rawIntent, adapter) {
  const proof = [];
  const log = (action, state, source, evidence) => {
    const step = { action, owner: 'doolittles-runtime', state, source, evidence, ts: now() };
    proof.push(step);
    return step;
  };

  log('signal.received', 'REAL', 'user-intake', `intent_len=${String(rawIntent ?? '').length}`);

  const intent = parseIntent(rawIntent);
  log('intent.parsed', 'REAL', 'doolittles-runtime',
      `outcome|audience=${intent.audience}|urgency=${intent.urgency}|proof=${intent.proof}`);

  const packs = await adapter.fetch();
  // Source honesty is structural: the proof step records exactly where packs
  // came from. A fixture run can NEVER report the live catalogue as its source.
  log('catalogue.loaded', adapter.sourceLabel === 'fixture' ? 'PARTIAL' : 'REAL',
      adapter.sourceLabel, `packs=${packs.length} adapter=${adapter.name}`);

  const matches = matchPacks(intent, packs);
  log('catalogue.matched',
      matches.length ? 'REAL' : 'PARTIAL',
      adapter.sourceLabel,
      `matched_packs=${matches.length}`);

  const work = matches.slice(0, 3).map((m, i) => ({
    seq: i + 1, pack_id: m.pack.id, pack: m.pack.name,
    price: m.pack.price, tier: m.pack.tier, window: m.pack.delivery_window,
    rationale: m.matched,
  }));
  log('work.proposed', work.length ? 'REAL' : 'BLOCKED', 'doolittles-runtime',
      `work_items=${work.length}`);

  const replay = proof.map(s => `${s.ts} ${s.action} [${s.state}] <- ${s.source} :: ${s.evidence}`);
  log('replay.assembled', 'REAL', 'doolittles-runtime', `steps=${proof.length + 1}`);

  return {
    intent,
    matches: work,
    proof,
    replay,
    catalogueSource: adapter.sourceLabel,
  };
}

/**
 * FIXTURE adapter — synthetic packs to exercise matcher logic ONLY.
 * Structurally marked source:"fixture". Never represents live catalogue truth.
 */
export const fixtureAdapter = {
  name: 'fixture-v1',
  sourceLabel: 'fixture',
  async fetch() {
    return [
      { id: 'FX-AHC',  name: 'AHC — Book Troy',          price: 2500, tier: 'advisory', delivery_window: '2w', outcome_tags: ['coach','advisory','leadership','strategy','book'], sellable: true },
      { id: 'FX-RBP',  name: 'Reading Buddy Pilot',       price: 4900, tier: 'pilot',    delivery_window: '4w', outcome_tags: ['reading','school','pilot','literacy','kids'],     sellable: true },
      { id: 'FX-TRAD', name: 'AI for Tradies Audit',      price: 1500, tier: 'audit',    delivery_window: '1w', outcome_tags: ['tradie','audit','automation','quote','field'],     sellable: true },
      { id: 'FX-BCI',  name: 'BCI Advisory',              price: null, tier: 'advisory', delivery_window: '3w', outcome_tags: ['bci','signal','research','advisory','neural'],     sellable: false },
      { id: 'FX-MEM',  name: 'Augmented Memories',        price: 990,  tier: 'product',  delivery_window: '2w', outcome_tags: ['memory','augmented','capture','recall'],          sellable: true },
    ];
  },
};

/**
 * LIVE adapter spec — bounded follow-up. Binds to the canonical catalogue.
 * Intentionally throws until wired so it can never silently fabricate.
 */
export function liveAdapter(fetchRows) {
  return {
    name: 'live-v_master_product_catalog',
    sourceLabel: 'public.v_master_product_catalog',
    async fetch() {
      if (typeof fetchRows !== 'function') {
        throw new Error(
          'liveAdapter not bound: supply a fetchRows() reading S1 ' +
          'public.v_master_product_catalog (303 rows). Refusing to fabricate.'
        );
      }
      return fetchRows();
    },
  };
}
