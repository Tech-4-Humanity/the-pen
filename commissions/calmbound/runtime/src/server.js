import Fastify from 'fastify';
import cors from '@fastify/cors';
import pg from 'pg';
import { CalmBoundRuntime } from './runtime.js';

const { Pool } = pg;
const app = Fastify({ logger: true, requestIdHeader: 'x-correlation-id', genReqId: (req) => req.headers['x-correlation-id'] || crypto.randomUUID() });
await app.register(cors, { origin: false });

const pool = new Pool({ connectionString: process.env.DATABASE_URL, max: Number(process.env.DB_POOL_MAX || 10) });
const db = createDb(pool);
const runtime = new CalmBoundRuntime({ db });

app.get('/health', async () => {
  const result = await pool.query('select now() as database_time');
  return { status: 'ok', service: 'calmbound-reference-runtime', version: '0.1.0', database_time: result.rows[0].database_time };
});

app.post('/v1/households', async (request, reply) => {
  const actor = requireActor(request);
  const household = await runtime.createHousehold({ ...request.body, ownerPersonId: actor, correlationId: request.id });
  return reply.code(201).send(household);
});

app.post('/v1/households/:householdId/modes', async (request, reply) => {
  const mode = await runtime.activateMode({
    householdId: request.params.householdId,
    ...request.body,
    actorPersonId: requireActor(request),
    correlationId: request.id
  });
  return reply.code(201).send(mode);
});

app.post('/v1/events', async (request, reply) => {
  const result = await runtime.ingestEvent(request.body);
  return reply.code(202).send(result);
});

app.setErrorHandler((error, request, reply) => {
  request.log.error({ err: error, correlation_id: request.id }, 'request failed');
  const statusCode = error.statusCode && error.statusCode >= 400 ? error.statusCode : 500;
  reply.code(statusCode).send({ error: statusCode === 500 ? 'internal_error' : error.message, correlation_id: request.id });
});

const port = Number(process.env.PORT || 3000);
const host = process.env.HOST || '0.0.0.0';
await app.listen({ port, host });

function requireActor(request) {
  const actor = request.headers['x-person-id'];
  if (!actor) {
    const error = new Error('x-person-id is required by the reference runtime');
    error.statusCode = 401;
    throw error;
  }
  return actor;
}

function createDb(pool) {
  const wrap = (client) => ({
    async one(text, params) {
      const result = await client.query(text, params);
      if (result.rows.length !== 1) throw new Error(`Expected one row, received ${result.rows.length}`);
      return result.rows[0];
    },
    async maybeOne(text, params) {
      const result = await client.query(text, params);
      if (result.rows.length > 1) throw new Error(`Expected at most one row, received ${result.rows.length}`);
      return result.rows[0] || null;
    },
    async none(text, params) { await client.query(text, params); }
  });
  return {
    async transaction(fn) {
      const client = await pool.connect();
      try {
        await client.query('begin');
        const value = await fn(wrap(client));
        await client.query('commit');
        return value;
      } catch (error) {
        await client.query('rollback');
        throw error;
      } finally {
        client.release();
      }
    }
  };
}
