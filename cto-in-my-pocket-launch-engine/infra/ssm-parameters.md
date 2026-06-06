# CTO in My Pocket Launch Engine — SSM Parameter Inventory

Status: PARTIAL until parameters are created and verified in AWS.

## Naming Convention

```text
/ctoip/{environment}/{service}/{name}
```

Supported environments:

- dev
- staging
- prod

## Required Parameters

| Parameter | Type | Required | Purpose |
|---|---|---:|---|
| `/ctoip/dev/supabase/url` | String | Yes | Supabase project URL |
| `/ctoip/dev/supabase/service_role_key` | SecureString | Yes | Supabase service role access |
| `/ctoip/dev/openai/api_key` | SecureString | Yes | LLM report/recommendation generation |
| `/ctoip/dev/stripe/secret_key` | SecureString | Yes | Stripe checkout/session creation |
| `/ctoip/dev/stripe/webhook_secret` | SecureString | Yes | Stripe webhook verification |
| `/ctoip/dev/sendgrid/api_key` | SecureString | Yes | Transactional email send |
| `/ctoip/dev/jwt/signing_key` | SecureString | Yes | Internal API signing |
| `/ctoip/dev/reality-ledger/url` | String | Yes | Reality Ledger write endpoint |
| `/ctoip/dev/reality-ledger/api_key` | SecureString | Yes | Reality Ledger API access |
| `/ctoip/dev/command-centre/telemetry_url` | String | Yes | Command Centre telemetry endpoint |
| `/ctoip/dev/command-centre/api_key` | SecureString | Yes | Command Centre telemetry key |

Repeat the same names for staging and prod:

```text
/ctoip/staging/supabase/url
/ctoip/staging/supabase/service_role_key
/ctoip/staging/openai/api_key
/ctoip/staging/stripe/secret_key
/ctoip/staging/stripe/webhook_secret
/ctoip/staging/sendgrid/api_key
/ctoip/staging/jwt/signing_key
/ctoip/staging/reality-ledger/url
/ctoip/staging/reality-ledger/api_key
/ctoip/staging/command-centre/telemetry_url
/ctoip/staging/command-centre/api_key

/ctoip/prod/supabase/url
/ctoip/prod/supabase/service_role_key
/ctoip/prod/openai/api_key
/ctoip/prod/stripe/secret_key
/ctoip/prod/stripe/webhook_secret
/ctoip/prod/sendgrid/api_key
/ctoip/prod/jwt/signing_key
/ctoip/prod/reality-ledger/url
/ctoip/prod/reality-ledger/api_key
/ctoip/prod/command-centre/telemetry_url
/ctoip/prod/command-centre/api_key
```

## Creation Example

```bash
aws ssm put-parameter \
  --name /ctoip/dev/supabase/url \
  --type String \
  --value "https://example.supabase.co" \
  --overwrite

aws ssm put-parameter \
  --name /ctoip/dev/supabase/service_role_key \
  --type SecureString \
  --value "REPLACE_ME" \
  --overwrite
```

## Verification

```bash
aws ssm get-parameter --name /ctoip/dev/supabase/url
aws ssm get-parameter --name /ctoip/dev/supabase/service_role_key --with-decryption
```

## Reality Ledger

Do not mark SSM binding as REAL until all required parameters resolve successfully for the target environment.
