import fs from 'node:fs/promises';
import crypto from 'node:crypto';
import pg from 'pg';

const { Client } = pg;
const schemaPath = new URL('../../implementation/database-schema-v1.0.sql', import.meta.url);
const sql = await fs.readFile(schemaPath, 'utf8');
const checksum = crypto.createHash('sha256').update(sql).digest('hex');
const client = new Client({ connectionString: process.env.DATABASE_URL });

if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL is required');

await client.connect();
try {
  await client.query('begin');
  await client.query(`create table if not exists schema_migrations (
    migration_id text primary key,
    checksum text not null,
    applied_at timestamptz not null default now()
  )`);
  const id = 'calmbound-database-schema-v1.0';
  const existing = await client.query('select checksum from schema_migrations where migration_id=$1', [id]);
  if (existing.rows[0]) {
    if (existing.rows[0].checksum !== checksum) throw new Error('Migration checksum drift detected');
    console.log(JSON.stringify({ status: 'SKIPPED', migration_id: id, checksum, reason: 'already_applied' }));
  } else {
    await client.query(sql);
    await client.query('insert into schema_migrations (migration_id, checksum) values ($1,$2)', [id, checksum]);
    console.log(JSON.stringify({ status: 'APPLIED', migration_id: id, checksum }));
  }
  await client.query('commit');
} catch (error) {
  await client.query('rollback');
  console.error(JSON.stringify({ status: 'FAILED', error: error.message, checksum }));
  process.exitCode = 1;
} finally {
  await client.end();
}
