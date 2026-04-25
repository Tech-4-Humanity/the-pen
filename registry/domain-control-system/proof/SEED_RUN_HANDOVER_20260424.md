# Domain Control System — Seed Run Handover

Date: 2026-04-24  
Status: PARTIAL / READY FOR LIVE SEED  
System: Domain Control System / Domain Intelligence Product  
Repo: `TML-4PM/the-pen`  
Tracking issue: https://github.com/TML-4PM/the-pen/issues/8

## Executive Summary

The Domain Control System is now designed, coded, versioned, and pressure-test ready. It started as an AWS Route 53 hosted zone table and has been converted into an operational product loop:

AWS Route53 → Supabase registry → Lambda sync/health checks → risk scoring → Command Centre widget → Stripe checkout → audit export/report → lead capture → recurring monitoring.

The system is NOT yet Stripe-REAL because no real Stripe test checkout has been executed and no webhook receipt has landed. It is ready for seed execution once Stripe and Vercel environment variables are set.

## Current Reality Ledger

| Layer | Status | Evidence |
|---|---:|---|
| AWS hosted zone source | REAL | User-provided AWS Route 53 export |
| Supabase schema | REAL / READY | `registry/aws_hosted_zone_registry_20260424.sql` |
| GitHub artefacts | REAL | Commits listed below |
| Route53 sync Lambda | REAL CODE / NOT RUNTIME-PROVEN | `lambdas/t4h-route53-domain-sync/index.mjs` |
| Domain health Lambda | REAL CODE / NOT RUNTIME-PROVEN | `lambdas/t4h-domain-health-check/index.mjs` |
| Command Centre widget | REAL CODE / NOT MOUNTED | `widgets/domain-control-system-widget.html` |
| Risk scoring | REAL CODE | `lib/risk-score.mjs` |
| Stripe checkout | REAL CODE / SEED NOT RUN | `api/create-checkout-session.mjs` |
| Stripe webhook | REAL CODE / SEED NOT RUN | `api/stripe-webhook.mjs` |
| Branded report | REAL CODE / HTML-first PDF path | `api/pdf-report.mjs` |
| Live Stripe payment | NOT PROVEN | Requires Stripe test seed |
| Webhook receipt | NOT PROVEN | Requires deployed endpoint + Stripe test event |
| Notion database | BLOCKED / OPTIONAL | Requires parent page ID |

## Key Receipts

- Supabase schema seed: `646040330f6ac84e5b8ceb0f04ce2be237c60a00`
- Execution pack: `58931230798fe616592a7983f249b27f1e1c3c66`
- Route53 sync Lambda: `a0fe084e4007c066844c160b38694f920d081c85`
- Domain health Lambda: `2f83a30c14469279b8cf3a9464066735fd372a32`
- Package manifest: `d0adeb233da75daba22d95acb115652bc29b8952`
- Deploy script: `22a96ab0759103ff77e3cd71a5c64680730f938c`
- Prove script: `46d715cf64e5b082ef213b5b50353f13e24c4543`
- GitHub Actions workflow: `23a9b2ee7465fe05f05846bdb26b7cc5fcde308f`
- Command Centre widget: `4425d82a8aeaaaafc3d6fa599945cc7001df7b29`
- Stripe product map: `0bbc2660d69d8fcd6a63528ec0bec430400f6f84`
- Audit export API: `c91ead4a57bbeff15807583ae5e1333d1cdb633c`
- Lead capture widget: `f664f195670454d2990adfcdb1f4ed9a51735f32`
- Risk score engine: `2522ad3cd21db077f8db496321ad7967fce6e734`
- Stripe checkout API: `3805c54ff28bb005929710f4db93fd1450e812eb`
- Stripe webhook API: `0f91636ed36c71877198c8841164b39dee19d7b4`
- Branded report generator: `39b827fdea7e5c801b8ee95e2df4dc1c072a6295`

## Vercel Target

Team:

```text
troys-projects-t4h-machine
team_IKIr2Kcs38KGo8Zs60yNtm7Y
```

Primary project:

```text
mcp-command-centre
prj_q2sQjc1otYY2cyZpQWKtdIf4aHVy
```

Deployment state observed:

```text
mcp-command-centre has production deployments in READY state.
Latest observed production deployment: dpl_HmT3jt3NkFUn6mK8yNRqAN3QsF1N
```

## Required Environment Variables

### Vercel / API runtime

```bash
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRICE_AUDIT=
STRIPE_PRICE_CLEANUP=
STRIPE_PRICE_MONITOR=
STRIPE_PRICE_ENTERPRISE=
```

### GitHub Actions / AWS Lambda deployment

```bash
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
LAMBDA_EXEC_ROLE_ARN=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=ap-southeast-2
```

## Stripe Seed Run Plan

### Objective

Flip Stripe Revenue Loop from PARTIAL to REAL by producing three receipts:

1. Checkout session URL
2. Stripe test payment completion
3. Webhook event receipt

### Precondition

Create Stripe products/prices in Stripe test mode and populate Vercel env variables:

```text
STRIPE_PRICE_AUDIT=price_test_...
STRIPE_PRICE_CLEANUP=price_test_...
STRIPE_PRICE_MONITOR=price_test_...
STRIPE_PRICE_ENTERPRISE=price_test_...
```

### Seed Command

Against the deployed Command Centre API target:

```bash
curl -X POST https://<mcp-command-centre-domain>/api/create-checkout-session \
  -H 'Content-Type: application/json' \
  -d '{"sku":"dcs_audit_once"}'
```

Expected result:

```json
{
  "url": "https://checkout.stripe.com/c/pay/cs_test_..."
}
```

### Payment Seed

Use Stripe test card:

```text
4242 4242 4242 4242
Any future expiry
Any CVC
```

Expected Stripe event:

```text
checkout.session.completed
```

### Webhook Expected Receipt

Expected webhook log payload:

```json
{
  "id": "cs_test_...",
  "amount": 49000,
  "sku": "dcs_audit_once"
}
```

## Seed Failure Cases To Test

### Invalid SKU

```bash
curl -X POST https://<domain>/api/create-checkout-session \
  -H 'Content-Type: application/json' \
  -d '{"sku":"bad_sku"}'
```

Expected:

```json
{"error":"invalid sku"}
```

### Missing price variable

Unset `STRIPE_PRICE_AUDIT` and repeat valid request.

Expected:

```json
{"error":"invalid sku"}
```

### Missing webhook secret

Send Stripe test event with no `STRIPE_WEBHOOK_SECRET`.

Expected:

```text
Webhook Error
```

## Hardening Required Before Public Launch

### 1. Raw body webhook handling

Stripe webhook verification usually requires the raw request body. The current webhook handler is structurally correct, but deployment framework must preserve raw body. If mounted into Next.js App Router, use this style:

```js
import { NextResponse } from 'next/server';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export async function POST(req) {
  const sig = req.headers.get('stripe-signature');
  const rawBody = await req.text();

  let event;
  try {
    event = stripe.webhooks.constructEvent(rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    return new NextResponse(`Webhook Error: ${err.message}`, { status: 400 });
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    console.log('Stripe success:', {
      id: session.id,
      amount: session.amount_total,
      sku: session.metadata?.sku
    });
  }

  return NextResponse.json({ received: true });
}
```

### 2. Persist webhook receipts

Webhook should write to Supabase evidence table or Reality Ledger:

```text
intent → checkout_session_created → payment_completed → report_exported → REAL/PARTIAL/PRETEND
```

### 3. PDF renderer

Current report route emits branded HTML. Production PDF can use:

- browser print-to-PDF
- Playwright/Puppeteer in controlled runtime
- Vercel-compatible PDF service
- or HTML-first report export as V1

### 4. Email delivery

After payment:

```text
webhook → generate report → email link → store receipt
```

## Product Packaging

### Product 1 — Domain Audit Snapshot

Price: AUD 490 one-time  
SKU: `dcs_audit_once`  
Outcome: CSV/HTML/PDF audit with risk score and kill list.

### Product 2 — Domain Cleanup Pack

Price: AUD 1900 one-time  
SKU: `dcs_cleanup_pack`  
Outcome: full cleanup plan and implementation support.

### Product 3 — Domain Governance Monitor

Price: AUD 290/month  
SKU: `dcs_monitor_monthly`  
Outcome: continuous monitoring and monthly report.

### Product 4 — Enterprise Domain Intelligence

Price: AUD 2400/month  
SKU: `dcs_enterprise_monthly`  
Outcome: multi-account AWS Route53 monitoring, governance workflows, reporting, and priority support.

## Customer Promise

Most organisations have domain drift. This product answers:

- What domains do we actually own/control?
- Which domains are active, parked, dead, mail-only, or risky?
- Which domains should be canonical?
- Which should be killed?
- Which domains represent security, brand, or cost risk?
- Can we prove it with evidence?

## Operator Expectations

The next operator should not redesign this system. They should:

1. Mount files into `mcp-command-centre`.
2. Set Vercel env vars.
3. Create Stripe test prices.
4. Run checkout seed.
5. Confirm webhook receipt.
6. Store proof in GitHub issue #8.
7. Only then mark Stripe revenue loop REAL.

## Closeout Decision

Current state is good enough to hand to the Pen/dev operator. It is not honest to mark Stripe as REAL until a test checkout and webhook receipt exist.

Final classification:

```text
Domain Intelligence Product: PARTIAL / READY TO SEED
Risk + Report Engine: REAL CODE
Stripe Revenue Loop: PARTIAL / WAITING FOR SEED TRANSACTION
Command Centre Target: REAL
```