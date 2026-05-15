# Runtime Language Operating System — Production Drop v1

**Status:** `closed_for_operator` (repo) + `closed_for_runtime` (Supabase S1)
**Owner:** Troy Latter / Tech 4 Humanity
**Issue:** [#113](https://github.com/TML-4PM/the-pen/issues/113)
**Companion contract:** [`../LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.md`](../LANGUAGE_AND_ONTOLOGY_CONTRACT_V1.md)

## What this is

The executable layer that ChatGPT failed to land. Closes the SQL gap recorded in the FAIL receipt by:

1. Shipping an idempotent, additive SQL migration that builds the runtime ontology schema.
2. Seeding the working baseline (closure chain, state transitions, connectors, test cases, reviewers).
3. Providing 30 CSV seed files covering nouns through receipt ledger.
4. Providing a TypeScript spine (resolver, closure engine, transition engine, drift detector).
5. Providing the Bridge execution envelope and OpenAPI contract.
6. Providing CI validation of CSV and SQL assets.

## Directory shape

```
production-drop-v1/
  README.md                                       <- you are here
  sql/
    001_runtime_language_schema.sql               <- additive migration (applied to S1)
    002_seed_minimal.sql                          <- working baseline seed (applied to S1)
  seeds/
    01_NOUNS.csv ... 30_RECEIPT_LEDGER.csv        <- 30 corpus files
  src/
    types.ts
    ontology-loader.ts
    language-resolver.ts
    closure-engine.ts
    transition-engine.ts
    drift-detector.ts
    runtime-language.ts                           <- public entrypoint
  tests/
    runtime-language.test.ts
  api/
    openapi.yaml                                  <- POST /resolve /transition /closure, GET /exceptions /health
  bridge/
    bridge-execution-envelope.json                <- Bridge ingest contract
  receipts/
    RECEIPT_001_INITIAL_DROP.md                   <- operator + runtime receipts
  .github/workflows/
    ontology-validation.yml                       <- CI checks
  package.json
  tsconfig.json
```

## What is live on Supabase S1 (`lzfgigiyqpuuxslsygjt`)

Applied via the Official Supabase Claude Connector (`apply_migration` + `execute_sql`).

**Tables (schema `ops`):**
- `ontology_nodes` — 13 rows (existing) + new columns `domain`, `metadata`
- `ontology_edges` — 4 rows (existing) + new column `authority_required`
- `ontology_translation` — 11 rows (existing)
- `ontology_runtime_state` — 0 rows + new columns `closure_level`, `next_owner`, `failure_owner`, `metadata`, `created_at`
- `ontology_receipts` — 6 rows + new columns `actor`, `classification`, `receipt_hash`
- `ontology_drift` — 5 rows + new columns `detected_in`, `resolved`
- `ontology_state_transitions` — **NEW**, 7 rows
- `ontology_closure_chain` — **NEW**, 4 rows
- `ontology_assertions` — **NEW**, 0 rows
- `ontology_test_cases` — **NEW**, 25 rows
- `ontology_connectors` — **NEW**, 6 rows
- `ontology_reviewers` — **NEW**, 4 rows
- `ontology_receipt_ledger` — **NEW**, 2 rows

**Views:**
- `v_runtime_language_semantic_exceptions` — detects operator/bridge/runtime closure gaps
- `v_runtime_language_drift_active` — unresolved drift events
- `v_runtime_language_health` — single-row dashboard

**Trigger:** `fn_set_updated_at()` maintains `updated_at` on nodes, runtime_state, translation, reviewers, test_cases.

## How to verify (read-only)

```sql
select * from ops.v_runtime_language_health;
select * from ops.v_runtime_language_semantic_exceptions;
select * from ops.ontology_closure_chain order by ordering;
select * from ops.ontology_connectors order by status, name;
select * from ops.ontology_test_cases where status = 'pending' order by id;
```

## Closure status

| Level | State | Evidence |
|---|---|---|
| `closed_for_operator` | ✅ | This commit + receipts/RECEIPT_001_INITIAL_DROP.md |
| `closed_for_bridge` | ⏳ | Pending Bridge ingest receipt on issue #113 |
| `closed_for_runtime` | ✅ | Supabase migration `runtime_language_production_drop_v1_schema` applied. Health view returns expected counts. |
| `closed_for_human` | ⏳ | Pending Command Centre surfacing |

## Next actions

1. Bridge consumes issue #113 and emits Bridge receipt.
2. Command Centre surfaces `ops.v_runtime_language_semantic_exceptions` and `ops.v_runtime_language_health`.
3. Reviewers assigned to 25 test cases (see `seeds/29_REVIEWERS.csv`).
4. Drift detector runs across recent LLM/GitHub/Drive corpora.
