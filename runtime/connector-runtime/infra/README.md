# connector-probe-runner — IaC

Daily Lambda that consumes `SCHEDULED` rows from `runtime.connector_probes` (Supabase project `lzfgigiyqpuuxslsygjt`), runs read-only probes against external connectors, and writes back `REAL` / `BLOCKED` rows with receipts.

Aligns with TML-4PM/the-pen **House Rules** §11 (Supabase = system of record), §17 (REAL/PARTIAL/BLOCKED only), §20 (archive-not-delete), §24 (transport-agnostic receipt contract), §25 (re-fetch-by-ID discipline).

## Layout

```
runtime/connector-runtime/infra/
├── template.yaml                 # SAM/CFN — Lambda + IAM + EventBridge + CloudWatch + SNS
├── lambda/
│   ├── handler.py                # Python 3.12 handler with Stripe/Canva/Spotify probes
│   └── requirements.txt          # boto3 (Lambda runtime provides this; pinned for sam build)
├── sql/
│   └── 02_connector_probe_rpc.sql   # PostgREST RPC wrappers in public schema
└── README.md                     # this file
```

The table itself (`runtime.connector_probes`), the `runtime.fn_connector_probe_enqueue()` function, and the `cron.job` named `connector-probe-daily` were applied as Supabase migration `connector_runtime_probe_ledger_v1` on 2026-05-15 and are already live.

## Prerequisites

- AWS CLI configured for account `140548542136`, region `ap-southeast-2`
- AWS SAM CLI ≥ 1.115 (`brew install aws-sam-cli`)
- Supabase project `lzfgigiyqpuuxslsygjt` already has the receipt-ledger migration applied (`runtime.connector_probes`, `runtime.fn_connector_probe_enqueue`, `cron.job` 319)
- Two pre-existing Secrets Manager secrets in `ap-southeast-2`

## Step 1 — Create the two secrets

```bash
# Supabase service role JWT
aws secretsmanager create-secret \
  --region ap-southeast-2 \
  --name t4h/connector-probe-runner/supabase \
  --secret-string '{"service_role_key":"<SUPABASE_SERVICE_ROLE_JWT>"}'

# Connector credentials (only include the ones you have; runner BLOCKED-rows
# on any missing keys, which is the correct behaviour)
aws secretsmanager create-secret \
  --region ap-southeast-2 \
  --name t4h/connector-probe-runner/connectors \
  --secret-string '{
    "stripe_api_key": "sk_live_or_test_...",
    "canva_access_token": "<OAuth bearer for Canva Connect API>",
    "spotify_client_id": "<Spotify app client id>",
    "spotify_client_secret": "<Spotify app client secret>"
  }'
```

Note: the bridge has a key-rotation rule documented at `TML-4PM/t4h-skills`. Tag both secrets with `system=t4h` and `audit=connector-runtime-audit-2026-05-15` so they show up in the rotation registry. Stripe should be a **restricted** key with only `rak_charge_read` / read-only scopes — the probe only calls `GET /v1/account`.

Capture both ARNs — you'll pass them as parameters in Step 3.

## Step 2 — Apply the PostgREST RPC wrappers

PostgREST exposes only the `public` schema by default. The migration in `sql/02_connector_probe_rpc.sql` adds two `SECURITY DEFINER` wrappers in `public` so the Lambda can call them via `/rest/v1/rpc/...`.

Apply it via the Supabase MCP `apply_migration` tool, or via psql:

```bash
psql "$SUPABASE_DB_URL" -f sql/02_connector_probe_rpc.sql
```

## Step 3 — Build and deploy the stack

```bash
cd runtime/connector-runtime/infra
sam build
sam deploy \
  --stack-name connector-probe-runner \
  --region ap-southeast-2 \
  --capabilities CAPABILITY_IAM \
  --resolve-s3 \
  --parameter-overrides \
    SupabaseSecretArn=arn:aws:secretsmanager:ap-southeast-2:140548542136:secret:t4h/connector-probe-runner/supabase-XXXXXX \
    ConnectorSecretsArn=arn:aws:secretsmanager:ap-southeast-2:140548542136:secret:t4h/connector-probe-runner/connectors-XXXXXX \
    AlertEmail=troy@tech4humanity.com.au
```

First deploy will email a SNS subscription confirmation to AlertEmail — accept it so failure alarms can fire.

## Step 4 — Verify end-to-end

```bash
# Force-trigger the enqueue function so there are SCHEDULED rows to probe
psql "$SUPABASE_DB_URL" -c "SELECT * FROM runtime.fn_connector_probe_enqueue();"

# Invoke the Lambda once manually
aws lambda invoke \
  --region ap-southeast-2 \
  --function-name connector-probe-runner \
  --payload '{}' \
  /tmp/probe-out.json
cat /tmp/probe-out.json

# Confirm rows landed
psql "$SUPABASE_DB_URL" -c \
  "SELECT connector, status, receipt_type, receipt_id, evidence, probed_at \
     FROM runtime.connector_probes \
    WHERE auditor = 'lambda:connector-probe-runner' \
    ORDER BY probed_at DESC LIMIT 20;"
```

Expected first-deploy outcome with no connector keys populated yet:
- Stripe, Canva, Spotify → `BLOCKED` with reason "no <key> in connector secrets"
- Tripadvisor, Booking, Lovable → `BLOCKED` with reason "no public REST account endpoint for safe-probe" (this is correct; they remain MCP-only)

Once real keys are added, Stripe / Canva / Spotify rows flip to `REAL` with their account/user IDs in `receipt_id`.

## Schedule

- pg_cron job `connector-probe-daily` runs at `0 18 * * *` UTC (jobid 319)
- This Lambda runs at `cron(5 18 * * ? *)` UTC — 5 minutes later — so SCHEDULED rows always exist when the Lambda fires.
- 18:00 UTC ≈ 04:00 AEDT / 05:00 AEDT (DST). Daily signal lands in Troy's morning window.

## Maintenance

### Adding a new connector probe

1. Add the credential to the connector secret JSON.
2. Add a `probe_<name>(creds) -> ProbeResult` function in `handler.py`.
3. Add it to the `PROBES` dict.
4. Add the connector to the `runtime.fn_connector_probe_enqueue()` array list in Supabase (a new migration updating the function, or an `ALTER FUNCTION` — keep migration history).
5. `sam build && sam deploy`.

### Failure response

The CloudWatch alarm `connector-probe-runner-errors` fires on any error in a 1h window. `connector-probe-runner-stale` fires if no invocation in 26h. Both publish to the `connector-probe-runner-alerts` SNS topic. Resolve by inspecting `/aws/lambda/connector-probe-runner` log group.

### Key rotation

When a connector key rotates, update the secret value — the Lambda re-fetches secrets on cold start. Force a cold start by publishing a new version or updating an env var. The bridge key-rotation runbook at `TML-4PM/t4h-skills` covers the canonical rotation flow.

## What this is NOT

- Not an MCP server — it does not expose tools to LLMs.
- Not a mutator — every probe is `GET`-only. The kernel's `unverifiable_execution_forbidden` rule means we never claim REAL for a connector we haven't successfully read from.
- Not a substitute for the MCP wrapper — for Tripadvisor/Booking/Lovable the runner correctly records `BLOCKED` and those connectors continue to be accessed only via their MCP clients.

## Provenance

- Authored: 2026-05-15 by Claude Opus 4.7
- Audit reference: `runtime/connector-runtime/01_verification_audit_2026-05-15.md`
- Receipt ledger entry: see `runtime.connector_probes` rows where `source_ref` contains `connector-runtime-audit-2026-05-15`
