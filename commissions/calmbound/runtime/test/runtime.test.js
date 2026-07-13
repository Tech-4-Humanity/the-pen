import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import { CalmBoundRuntime } from '../src/runtime.js';

function fakeDb() {
  const state = { events: new Map(), households: [], modes: [], memberships: new Set() };
  const tx = {
    async one(sql, params) {
      if (sql.includes('insert into households')) {
        const row = { id: crypto.randomUUID(), name: params[0], timezone: params[1], status: 'active', ownerPersonId: params[2], createdAt: new Date().toISOString() };
        state.households.push(row);
        return row;
      }
      if (sql.includes('insert into mode_instances')) {
        const row = { id: crypto.randomUUID(), householdId: params[0], modeDefinitionId: params[1], state: 'active', startsAt: params[3], endsAt: params[4] };
        state.modes.push(row);
        return row;
      }
      throw new Error('unexpected one query');
    },
    async maybeOne(sql, params) {
      if (sql.includes('household_memberships')) return state.memberships.has(`${params[1]}:${params[0]}`) ? { ok: 1 } : null;
      if (sql.includes('event_ledger')) return state.events.get(params[0]) || null;
      return null;
    },
    async none(sql, params) {
      if (sql.includes('insert into household_memberships')) state.memberships.add(`${params[1]}:${params[0]}`);
      if (sql.includes('insert into event_ledger')) state.events.set(params[0], { integrity_hash: params[18] });
    }
  };
  return { state, transaction: async (fn) => fn(tx) };
}

test('createHousehold emits a receipt and creates owner membership', async () => {
  const db = fakeDb();
  const runtime = new CalmBoundRuntime({ db });
  const owner = crypto.randomUUID();
  const household = await runtime.createHousehold({ name: 'Test Home', timezone: 'Australia/Sydney', ownerPersonId: owner });
  assert.equal(household.name, 'Test Home');
  assert.equal(db.state.events.size, 1);
  assert.equal(db.state.memberships.has(`${owner}:${household.id}`), true);
});

test('mode activation denies an unauthorised actor', async () => {
  const db = fakeDb();
  const runtime = new CalmBoundRuntime({ db });
  await assert.rejects(() => runtime.activateMode({
    householdId: crypto.randomUUID(), modeDefinitionId: 'kids_visit', startsAt: new Date().toISOString(), actorPersonId: crypto.randomUUID()
  }), /authority denied/);
});

test('event ingestion is idempotent and detects drift', async () => {
  const db = fakeDb();
  const runtime = new CalmBoundRuntime({ db });
  const envelope = {
    event_id: crypto.randomUUID(), event_type: 'test.event', event_version: '1.0.0', occurred_at: new Date().toISOString(), recorded_at: new Date().toISOString(),
    source: { service: 'test' }, actor: { type: 'system' }, subject: {}, object: {}, action: 'test', outcome: { status: 'ok' },
    correlation_id: crypto.randomUUID(), data_classification: 'test', evidence_refs: []
  };
  assert.equal((await runtime.ingestEvent(envelope)).duplicate, false);
  assert.equal((await runtime.ingestEvent(envelope)).duplicate, true);
  await assert.rejects(() => runtime.ingestEvent({ ...envelope, action: 'changed' }), /different payload/);
});
