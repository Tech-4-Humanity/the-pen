# Connector Control Plane — Runbook

**Owner:** Tech 4 Humanity Pty Ltd · ABN 70 666 271 272  
**On-call:** ops@tech4humanity.com  
**Region:** ap-southeast-2 · **Account:** 140548542136  
**Repo of record:** TML-4PM/the-pen · path: `connector-control-plane/`

## 1. What this service does
Routes user intents to the lowest-cost healthy connector with deterministic fallback, writes a typed receipt for every execution, and probes connectors every 5 minutes. Canonical ledger is Supabase (`public.ccp_*`); hot state is DynamoDB (`ccp-state`).

## 2. Deploy
```
cd connector-control-plane/cdk
npm ci
npx cdk synth --all
npx cdk deploy --all --require-approval never
```
Or trigger the GitHub Actions workflow `ccp-deploy` with `stage=deploy`.

## 3. Apply schema
```
psql "$SUPABASE_DB_URL" -f connector-control-plane/db/001_schema.sql
psql "$SUPABASE_DB_URL" -f connector-control-plane/db/002_seed.sql
psql "$SUPABASE_DB_URL" -f connector-control-plane/db/003_indexes.sql
```

## 4. Common incidents

### 4.1 DLQ depth alarm fires (`ccp-dlq-depth`)
1. Inspect DLQ: `aws sqs receive-message --queue-url $CCP_DLQ_URL --max-number-of-messages 10`
2. Inspect last receipts: `select * from ccp_receipts order by finished_at desc limit 20;`
3. If schema or auth: rotate Supabase secret, redeploy.
4. If connector down: mark `enabled=false` in `ccp_connectors`, raise with provider.

### 4.2 Lambda error alarm fires (`ccp-*-errors`)
1. CloudWatch Logs Insights:
   ```
   fields @timestamp, @message
   | filter @message like /ERROR/
   | sort @timestamp desc
   | limit 50
   ```
2. Reproduce locally with the offending event JSON.

### 4.3 Health probes returning PARTIAL repeatedly
1. `select * from v_ccp_connector_health where last_healthy = false;`
2. Confirm `health_url` is correct.
3. If transient: leave; alarm self-clears.
4. If sustained > 30 min: disable connector and escalate.

## 5. Rollback
```
npx cdk deploy ConnectorControlPlane --rollback
```
Schema rollbacks are forward-only: write a new migration `00N_*.sql`.

## 6. Decommission
1. Disable the API Gateway routes.
2. `npx cdk destroy --all`.
3. Archive `ccp_receipts` to S3 via `pg_dump`.
4. Drop tables only after 90 days.
