# Production Drop V1 — Runtime Language Operating System

This is the production-shaped implementation package for LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.

It turns the language ontology into a runnable service pattern:

- database schema
- CSV seeds
- TypeScript runtime library
- API contract
- smoke tests
- GitHub Actions validation
- Bridge execution envelope
- service catalogue readiness gate
- Command Centre semantic exception model

## What this is

A runtime semantic control layer for resolving human words into governed state transitions.

It prevents false completion by requiring closure levels:

- closed_for_operator
- closed_for_bridge
- closed_for_runtime
- closed_for_human

## What can run tonight

1. Apply `sql/001_runtime_language_schema.sql` to Supabase/Postgres.
2. Load CSVs from `seeds/`.
3. Run `src/runtime-language.ts` from any Node/TS worker or Bridge function.
4. Run `tests/runtime-language.test.ts` as the smoke test.
5. Use `bridge/bridge-execution-envelope.json` as the Bridge payload.
6. Add service catalogue language readiness checks to product onboarding.

## Status

closed_for_operator: COMPLETE
closed_for_bridge: PENDING
closed_for_runtime: OPEN
closed_for_human: OPEN

This package is not allowed to claim full closure until Bridge ingests it and runtime evidence exists.
