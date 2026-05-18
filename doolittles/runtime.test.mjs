// Doolittles runtime — local execution test. Zero deps. `node runtime.test.mjs`.
// Proves the loop logic round-trips and that fixture runs can NEVER claim the
// live catalogue as their source (anti-fabrication guard).

import { runDoolittles, fixtureAdapter, liveAdapter, parseIntent, matchPacks } from './runtime.mjs';

let pass = 0, fail = 0;
const ok = (cond, msg) => { if (cond) { pass++; console.log('  PASS', msg); } else { fail++; console.log('  FAIL', msg); } };

console.log('Doolittles runtime — local round-trip test\n');

// 1. Intent parsing
const i = parseIntent('I need an urgent reading pilot for the board with full evidence');
ok(i.urgency === 'immediate', `urgency parsed: ${i.urgency}`);
ok(i.audience === 'leadership', `audience parsed: ${i.audience}`);
ok(i.proof === 'evidence-required', `proof parsed: ${i.proof}`);

// 2. Empty intent rejected
let threw = false;
try { parseIntent('   '); } catch { threw = true; }
ok(threw, 'empty intent rejected');

// 3. Full round-trip on fixture
const intents = [
  'urgent reading pilot for a school, need proof',
  'book Troy for a leadership advisory session',
  'audit my tradie business for automation',
];
for (const t of intents) {
  const r = await runDoolittles(t, fixtureAdapter);
  ok(r.matches.length >= 1, `"${t.slice(0,32)}…" matched ${r.matches.length} pack(s)`);
  ok(r.proof.length >= 6, `proof chain has ${r.proof.length} steps`);
  ok(r.catalogueSource === 'fixture', `source honest: ${r.catalogueSource}`);
  const liesAboutSource = r.proof.some(s => s.source === 'public.v_master_product_catalog');
  ok(!liesAboutSource, 'no fixture step claims live catalogue as source');
  const everyStepTyped = r.proof.every(s => ['REAL','PARTIAL','BLOCKED'].includes(s.state));
  ok(everyStepTyped, 'every proof step carries a typed state');
}

// 4. Deterministic matcher
const a = matchPacks(parseIntent('reading pilot school'), await fixtureAdapter.fetch());
const b = matchPacks(parseIntent('reading pilot school'), await fixtureAdapter.fetch());
ok(JSON.stringify(a) === JSON.stringify(b), 'matcher is deterministic');
ok(a[0].pack.id === 'FX-RBP', `top match for reading pilot = ${a[0]?.pack.id}`);

// 5. Live adapter refuses to fabricate
let liveThrew = false;
try { await liveAdapter().fetch(); } catch { liveThrew = true; }
ok(liveThrew, 'unbound live adapter refuses to fabricate catalogue');

console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail === 0 ? 0 : 1);
