# AI Tradies — Runtime Code

This is the actual executable code for the AI Tradies operating system,
not just the architecture spec.

## What's here

```
tradies/commercial_pack/runtime/
├── lambda/
│   ├── index.py              # production handler — accepts intake, writes job to Supabase
│   └── requirements.txt      # stdlib only — no extra deps
└── site/
    └── index.html            # production-grade single-file landing page + intake form
```

## Lambda: tradie-intake-handler

**Status: code committed. Not yet deployed as a new Lambda — deploy is a downstream step.**

### Contract

`POST` JSON body:

```json
{
  "business_id":    "<uuid>",
  "job_type":       "Burst pipe",
  "urgency":        "emergency",
  "source_channel": "web",
  "description":    "Water coming through ceiling",
  "customer": {
    "full_name":    "Jane Doe",
    "phone":        "+61400123456",
    "suburb":       "Bondi",
    "customer_type":"residential"
  }
}
```

Returns:

```json
{ "ok": true, "job_id": "uuid", "customer_id": "uuid" }
```

### Required env vars

| Name                          | Value                                                                  |
|-------------------------------|------------------------------------------------------------------------|
| `SUPABASE_URL`                | `https://lzfgigiyqpuuxslsygjt.supabase.co`                             |
| `SUPABASE_SERVICE_ROLE_KEY`   | Pulled from `cap_secrets` at deploy time (never hardcoded)             |

### Deploy via T4H bridge

```
fn: troy-cfn-deployer          # IAM-permissioned CFN deploy with CAPABILITY_NAMED_IAM
payload (TOP-LEVEL envelope):
{
  "stack_name": "ai-tradies-intake",
  "template_body": "<inline CloudFormation defining the Lambda + Function URL>",
  "parameters": [
    {"ParameterKey": "SupabaseUrl", "ParameterValue": "https://lzfgigiyqpuuxslsygjt.supabase.co"},
    {"ParameterKey": "SupabaseKey", "ParameterValue": "<from cap_secrets>"}
  ],
  "capabilities": ["CAPABILITY_NAMED_IAM"]
}
```

Why CFN not direct Lambda create: standing rule from prior IAM-escalation work —
`lovable-mcp-client` has no IAM writes; `troy-cfn-deployer` is the canonical path.

### RDTI tag at creation

Per build principle, tag the new Lambda with `is_rd=true, project_code=ai_tradies_intake_v1`
in `t4h_canonical_changes` at deploy time. The deploy is itself a `change_type=SYSTEM_CHANGE`
with `severity=NORMAL`.

### Rollback

Stack rollback if smoke test fails. Kill switch: set `ReservedConcurrentExecutions=0`
on `ai-tradies-intake` Lambda, same pattern as the bridge throttle was used.

## Site: tradies-ai landing page

**Status: code committed. Not yet deployed to Vercel.**

Single file, no build step. Drop on any static host (Vercel, S3 + CloudFront, Cloudflare Pages).
Before deploying, set two values that the inline script reads:

```html
<script>
  window.AI_TRADIES_INTAKE_URL  = "https://<lambda-function-url>";
  window.AI_TRADIES_BUSINESS_ID = "<uuid of the tradie business this page belongs to>";
</script>
```

These should be injected at the edge / via Vercel env so the same `index.html` can be
re-used per-tradie via subdomain or path.

### Deploy via Vercel

```
team_IKIr2Kcs38KGo8Zs60yNtm7Y  →  project: ai-tradies-landing  →  add as static
```

## What's still BLOCKED

- **Stripe products provisioning:** `troy-stripe-executor` Lambda is currently
  `status='STOPPED_PHASE1'` in `public.mcp_lambda_registry` AND has
  `ReservedConcurrentExecutions=0` on AWS. Both need to be lifted by an
  operator with IAM/registry write outside this layer before Stripe products
  can be created and back-filled into `tradie_products.stripe_product_id`.

- **Lambda deployment:** `troy-lambda-deploy` and `troy-cfn-deployer` are
  not callable from this session (is_callable=false). The actual deploy step
  requires a session with bridge-write authority.

Both are tracked in `public.reality_ledger` against system `ai_tradies`.
