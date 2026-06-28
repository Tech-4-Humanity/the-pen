/*
 * RoutineOps seed loader
 * Applies routines.seed.json into routineops_routines and routineops_routine_steps.
 *
 * Usage:
 *   SUPABASE_DB_URL=postgres://... npx tsx routineops/scripts/load-seed.ts
 *
 * Runtime status:
 *   This script is an executable loader scaffold. It is not a live seed receipt until run
 *   against a database and the verification query returns expected counts.
 */

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import postgres from 'postgres';

type SeedStep = {
  order: number;
  type: string;
  label: string;
  payload?: Record<string, unknown>;
  required?: boolean;
};

type SeedRoutine = {
  id: string;
  display_name: string;
  domain: string;
  intent: string;
  risk_level: 'low' | 'medium' | 'high';
  verification_rule?: Record<string, unknown>;
  fallback_rule?: Record<string, unknown>;
  steps: SeedStep[];
};

type SeedFile = {
  schema_version: string;
  routines: SeedRoutine[];
};

const dbUrl = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;

if (!dbUrl) {
  throw new Error('SUPABASE_DB_URL or DATABASE_URL is required');
}

const seedPath = path.resolve(process.cwd(), 'routineops/seeds/routines.seed.json');
const seed = JSON.parse(fs.readFileSync(seedPath, 'utf8')) as SeedFile;

if (!Array.isArray(seed.routines) || seed.routines.length !== 25) {
  throw new Error(`Expected 25 routines, found ${seed.routines?.length ?? 0}`);
}

const sql = postgres(dbUrl, { max: 1 });

async function main() {
  await sql.begin(async (tx) => {
    for (const routine of seed.routines) {
      await tx`
        insert into routineops_routines (
          id,
          display_name,
          domain,
          intent,
          version,
          risk_level,
          verification_rule,
          fallback_rule,
          status
        ) values (
          ${routine.id},
          ${routine.display_name},
          ${routine.domain},
          ${routine.intent},
          1,
          ${routine.risk_level},
          ${tx.json(routine.verification_rule || {})},
          ${tx.json(routine.fallback_rule || {})},
          'active'
        )
        on conflict (id) do update set
          display_name = excluded.display_name,
          domain = excluded.domain,
          intent = excluded.intent,
          risk_level = excluded.risk_level,
          verification_rule = excluded.verification_rule,
          fallback_rule = excluded.fallback_rule,
          updated_at = now()
      `;

      await tx`delete from routineops_routine_steps where routine_id = ${routine.id}`;

      for (const step of routine.steps) {
        await tx`
          insert into routineops_routine_steps (
            routine_id,
            step_order,
            step_type,
            label,
            payload,
            required
          ) values (
            ${routine.id},
            ${step.order},
            ${step.type},
            ${step.label},
            ${tx.json(step.payload || {})},
            ${step.required !== false}
          )
        `;
      }
    }
  });

  const [counts] = await sql<[{ routines: number; steps: number }]>`
    select
      (select count(*)::int from routineops_routines) as routines,
      (select count(*)::int from routineops_routine_steps) as steps
  `;

  console.log(JSON.stringify({
    status: 'PARTIAL_UNTIL_RECEIPTED_BY_RUNNER',
    expected_routines: 25,
    actual_routines: counts.routines,
    actual_steps: counts.steps,
    ok: counts.routines >= 25 && counts.steps > 0
  }, null, 2));
}

main()
  .catch((error) => {
    console.error(JSON.stringify({ ok: false, error: String(error?.message || error) }, null, 2));
    process.exitCode = 1;
  })
  .finally(async () => {
    await sql.end({ timeout: 5 });
  });
