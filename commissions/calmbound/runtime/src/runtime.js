import crypto from 'node:crypto';

export class CalmBoundRuntime {
  constructor({ db, clock = () => new Date() }) {
    this.db = db;
    this.clock = clock;
  }

  async createHousehold({ name, timezone, ownerPersonId, correlationId }) {
    requireValue(name, 'name');
    requireValue(timezone, 'timezone');
    requireValue(ownerPersonId, 'ownerPersonId');

    return this.db.transaction(async (tx) => {
      const household = await tx.one(
        `insert into households (name, timezone, owner_person_id)
         values ($1,$2,$3)
         returning household_id as id, name, timezone, status,
                   owner_person_id as "ownerPersonId", created_at as "createdAt"`,
        [name, timezone, ownerPersonId]
      );

      await this.recordEvent(tx, {
        eventType: 'household.created',
        action: 'create',
        actor: { person_id: ownerPersonId },
        subject: { household_id: household.id },
        object: { type: 'household', id: household.id },
        outcome: { status: 'succeeded' },
        correlationId
      });

      return household;
    });
  }

  async activateMode({ householdId, modeDefinitionId, startsAt, endsAt, subjects = [], parameters = {}, actorPersonId, correlationId }) {
    for (const [key, value] of Object.entries({ householdId, modeDefinitionId, startsAt, actorPersonId })) requireValue(value, key);

    return this.db.transaction(async (tx) => {
      await this.assertAuthority(tx, actorPersonId, householdId, 'mode.activate');
      const mode = await tx.one(
        `insert into mode_instances
          (household_id, mode_definition_id, mode_definition_version, state, parameters, starts_at, ends_at, activated_by, correlation_id)
         values ($1,$2,'1.0.0','active',$3,$4,$5,$6,$7)
         returning mode_instance_id as id, mode_definition_id as "modeDefinitionId",
                   household_id as "householdId", state, starts_at as "startsAt", ends_at as "endsAt"`,
        [householdId, modeDefinitionId, JSON.stringify({ ...parameters, subjects }), startsAt, endsAt ?? null, actorPersonId, correlationId]
      );

      await this.recordEvent(tx, {
        eventType: 'mode.activated', action: 'activate', actor: { person_id: actorPersonId },
        subject: { household_id: householdId }, object: { type: 'mode_instance', id: mode.id },
        outcome: { status: 'succeeded' }, correlationId
      });
      return mode;
    });
  }

  async ingestEvent(envelope) {
    validateEnvelope(envelope);
    return this.db.transaction(async (tx) => {
      const existing = await tx.maybeOne('select integrity_hash from event_ledger where event_id=$1', [envelope.event_id]);
      const hash = integrityHash(envelope);
      if (existing) {
        if (existing.integrity_hash !== hash) throw conflict('event_id already exists with different payload');
        return { accepted: true, duplicate: true, event_id: envelope.event_id };
      }
      await insertEnvelope(tx, envelope, hash);
      return { accepted: true, duplicate: false, event_id: envelope.event_id };
    });
  }

  async assertAuthority(tx, personId, householdId, action) {
    const row = await tx.maybeOne(
      `select 1 from household_memberships
       where household_id=$1 and person_id=$2 and status='active'
         and (role_type in ('owner','guardian','authorised_adult') or scope @> $3::jsonb)
       limit 1`,
      [householdId, personId, JSON.stringify({ actions: [action] })]
    );
    if (!row) throw forbidden('authority denied');
  }

  async recordEvent(tx, { eventType, action, actor, subject, object, outcome, correlationId }) {
    const now = this.clock().toISOString();
    const envelope = {
      event_id: crypto.randomUUID(), event_type: eventType, event_version: '1.0.0',
      occurred_at: now, recorded_at: now, source: { service: 'calmbound-reference-runtime', version: '0.1.0' },
      actor, subject, object, action, outcome,
      correlation_id: correlationId ?? crypto.randomUUID(), causation_id: null,
      policy_version: '1.0.0', model_version: null, data_classification: 'household_operational',
      evidence_refs: [], metadata: {}
    };
    await insertEnvelope(tx, envelope, integrityHash(envelope));
    return envelope;
  }
}

async function insertEnvelope(tx, e, hash) {
  await tx.none(
    `insert into event_ledger
      (event_id,event_type,event_version,occurred_at,recorded_at,source,actor,subject,object,action,outcome,
       correlation_id,causation_id,policy_version,model_version,data_classification,evidence_refs,metadata,integrity_hash)
     values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19)`,
    [e.event_id,e.event_type,e.event_version,e.occurred_at,e.recorded_at,e.source,e.actor,e.subject,e.object,e.action,e.outcome,
     e.correlation_id,e.causation_id ?? null,e.policy_version ?? null,e.model_version ?? null,e.data_classification,
     e.evidence_refs ?? [],e.metadata ?? {},hash]
  );
}

function integrityHash(value) {
  return crypto.createHash('sha256').update(stableStringify(value)).digest('hex');
}
function stableStringify(value) {
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(',')}]`;
  if (value && typeof value === 'object') return `{${Object.keys(value).sort().map(k => `${JSON.stringify(k)}:${stableStringify(value[k])}`).join(',')}}`;
  return JSON.stringify(value);
}
function validateEnvelope(e) {
  for (const key of ['event_id','event_type','event_version','occurred_at','recorded_at','source','actor','subject','object','action','outcome','correlation_id','data_classification','evidence_refs']) requireValue(e[key], key);
}
function requireValue(value, field) {
  if (value === undefined || value === null || value === '') throw badRequest(`${field} is required`);
}
function typedError(statusCode, message) { const error = new Error(message); error.statusCode = statusCode; return error; }
const badRequest = (m) => typedError(400, m);
const forbidden = (m) => typedError(403, m);
const conflict = (m) => typedError(409, m);
