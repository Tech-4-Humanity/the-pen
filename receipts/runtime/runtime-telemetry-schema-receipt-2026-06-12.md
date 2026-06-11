# Runtime Telemetry Schema Receipt — ops.work_queue breach

status: PARTIAL

result: Repo evidence shows `ops.work_queue` is a designed dependency, but not proven as a deployed Supabase table. The most likely classification is planned/assumed schema, not successfully deployed. It is not safe to treat dashboard counts from this table as REAL.

## Evidence

### GitHub repo access
- Repository: `TML-4PM/the-pen`
- Repository visibility: private
- Connector permissions: admin/maintain/pull/push/triage available in prior repo lookup

### References found
The repo contains multiple references to `ops.work_queue`, including:

- `SYMBIO/wq-rescue-dispatcher.md`
- `lambdas/troy-runtime-proof-sweeper/DEPLOY.md`
- `tools/runtime-proof-sweeper/hourly_schedule.md`
- `lambdas/troy-runtime-proof-sweeper/index.js`
- `tools/runtime-proof-sweeper/README.md`
- `tools/runtime-proof-sweeper/backlog_reconciliation.sql`
- `.github/workflows/agl-bootstrap.yml`
- `repair/agl-bootstrap-ddl-001.json`

### Direct file evidence

#### `repair/agl-bootstrap-ddl-001.json`
The repair payload contains SQL:

```sql
CREATE UNIQUE INDEX IF NOT EXISTS idx_work_dedupe ON ops.work_queue (idempotency_key);
CREATE SCHEMA IF NOT EXISTS core;
CREATE TABLE IF NOT EXISTS core.widgets (...);
```

This attempts an index on `ops.work_queue`, but does not create `ops` or `ops.work_queue`.

Classification: broken/partial DDL. It assumes the table already exists.

#### `tools/runtime-proof-sweeper/backlog_reconciliation.sql`
This file creates `public.fn_runtime_proof_sweeper_kick()` and inserts into `ops.work_queue`.

It explicitly states:

- the function enqueues an hourly sweeper job into `ops.work_queue`
- the dispatcher should pick it up
- Lambda `troy-runtime-proof-sweeper` executes it
- queued jobs may sit `ready` until Lambda is deployed

But this file does not define `CREATE SCHEMA ops` or `CREATE TABLE ops.work_queue`.

Classification: planned runtime queue integration, missing canonical table migration.

#### `lambdas/troy-runtime-proof-sweeper/index.js`
The Lambda reads and updates:

```js
.from('work_queue').schema('ops')
```

It queries statuses including:

- `claimed`
- `in_progress`
- `done`
- `verified`
- `blocked`

It also attempts to write audit evidence to:

```js
.from('log').schema('audit')
```

Classification: executable worker code exists, but depends on tables/schemas not proven deployed.

## Determination

`ops.work_queue` is not entirely fabricated by dashboards. It exists as a repo-level intended runtime dependency.

However, there is no repo evidence found in this sweep proving a canonical migration that creates the table. The DDL discovered assumes the table exists. User-supplied Supabase validation says the deployed database has no `ops` schema and no `ops.work_queue` table.

Therefore:

- planned but never deployed: LIKELY
- migrated in another environment: UNPROVEN
- entirely fabricated by dashboards: NO, but dashboard counts are synthetic/unproven if table absent

## Gaps

- No live Supabase schema inventory receipt committed.
- No bridge invoke 200 receipt committed.
- No deployment inventory receipt committed.
- No actual task count SQL receipt committed.
- No recovery-state receipt committed.
- No canonical migration creating `ops.work_queue` found in repo sweep.
- No canonical table contract found linking `public.agent_tasks`, `public.job_queue`, and `ops.work_queue`.

## Required replacement: synthetic counts → live schema validation

Dashboards and governance reports must not hardcode, infer, or hallucinate queue counts. They must perform schema-aware checks first.

Required rule:

```text
IF schema/table missing THEN status = BLOCKED, count = null, evidence = schema_missing
ELSE query live aggregate counts and attach SQL receipt
```

## Runtime receipt package required

### 1. Schema inventory

Required SQL:

```sql
select table_schema, table_name
from information_schema.tables
where table_schema in ('public','ops','audit','governance','consentx','sweep','cron')
order by table_schema, table_name;
```

### 2. Bridge invoke 200

Required receipt:

```json
{
  "status": "REAL",
  "check": "bridge_invoke",
  "http_status": 200,
  "timestamp": "<utc>",
  "response_hash": "<sha256>",
  "target": "bridge_runtime"
}
```

If bridge returns 401/403/500, receipt status must be BLOCKED.

### 3. Deployment inventory

Required checks:

- Vercel deployment status
- GitHub commit SHA
- runtime endpoint health
- Lambda deployment status if Lambda remains part of runtime

### 4. Actual task counts

Required SQL must classify known live tables separately:

```sql
select 'public.agent_tasks' as source, status, count(*)
from public.agent_tasks
group by status
union all
select 'public.job_queue' as source, coalesce(status,'NO_STATUS') as status, count(*)
from public.job_queue
group by coalesce(status,'NO_STATUS');
```

Do not merge these into `ops.work_queue` unless a migration maps them.

### 5. Recovery state

Required fields:

- stale claimed count
- stale in_progress count
- blocked count by reason
- failed count by error
- last successful recovery timestamp
- receipt path for last recovery event

If table absent, recovery state is BLOCKED with reason `QUEUE_TABLE_MISSING`.

## Next action

1. Create canonical migration for `ops.work_queue`, or remove all references and map runtime to existing live tables.
2. Patch dashboard logic to fail closed on absent schemas.
3. Run live schema inventory and bridge invoke checks.
4. Commit runtime receipt package under `receipts/runtime/`.
5. Only then reclassify runtime from PARTIAL to REAL.

## Score

execution: 0.62

evidence: 0.68

economic: 0.44

reuse: 0.71

delta: 0.80

overall: 0.63

ledger:
  task_id: runtime-telemetry-schema-receipt-2026-06-12
  intent: find references to ops.work_queue, classify deployment state, and define runtime receipt package
  execution: repo sweep + receipt creation
  output: receipts/runtime/runtime-telemetry-schema-receipt-2026-06-12.md
  status: PARTIAL
  evidence: GitHub search/fetch results and user-supplied Supabase validation
  score: 0.63
