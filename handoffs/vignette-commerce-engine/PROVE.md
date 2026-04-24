# PROVE PACK — Vignette Commerce Engine

Date: 2026-04-24
Classification before run: PARTIAL
Target classification after run: REAL

## Proof objective

Prove one complete revenue loop:

```text
click -> locked vignette -> preview -> checkout -> Stripe test payment -> webhook -> entitlement -> unlocked access -> telemetry -> Command Centre stats -> Reality Ledger REAL
```

## Required deploy gates

1. Supabase migration applied.
2. API routes deployed.
3. RelatedVignettes component mounted on at least one vignette page.
4. Stripe test checkout works.
5. Stripe webhook receives `checkout.session.completed`.
6. User entitlement is written idempotently.
7. Related endpoint returns `has_access=true` after purchase.
8. Telemetry rows visible.
9. Revenue widget returns count and amount.
10. Reality Ledger has a REAL proof row.

## Test user and product

```json
{
  "user_id": "test_user_001",
  "product_key": "vignette_premium_pack_001",
  "vignette_slug": "premium-vignette-001",
  "price_cents": 1999,
  "currency": "aud"
}
```

## Expected endpoint results

### 1. Related before purchase

`GET /api/vignettes/related?id=<seed_vignette_id>&user_id=test_user_001`

Expected:

```json
[
  {
    "slug": "premium-vignette-001",
    "paywall_type": "product",
    "has_access": false,
    "preview_available": true
  }
]
```

### 2. Checkout create

`POST /api/checkout/create`

```json
{
  "productId": "<product_uuid>",
  "userId": "test_user_001",
  "priceId": "<stripe_price_id>"
}
```

Expected:

```json
{
  "url": "https://checkout.stripe.com/..."
}
```

### 3. Webhook

Stripe event: `checkout.session.completed`

Expected entitlement:

```sql
select * from public.user_products where user_id = 'test_user_001';
```

Must return active product row.

### 4. Related after purchase

Expected:

```json
[
  {
    "slug": "premium-vignette-001",
    "has_access": true
  }
]
```

### 5. Revenue stats

`GET /api/stats/revenue`

Expected:

```json
{
  "purchase_count": 1,
  "revenue_cents": 1999,
  "currency": "aud"
}
```

## REALITY LEDGER upgrade rule

The system remains PARTIAL until all proof gates pass.

Insert REAL proof only after all checks pass:

```sql
insert into public.reality_ledger(type, status, payload)
values (
  'vignette_commerce_engine_proof',
  'REAL',
  jsonb_build_object(
    'user_id','test_user_001',
    'product_key','vignette_premium_pack_001',
    'proof','click_checkout_webhook_entitlement_unlock_telemetry_revenue',
    'proved_at', now()
  )
);
```

## Failure handling

| Failure | Likely cause | Fix |
|---|---|---|
| Related endpoint 500 | Supabase env missing | Verify SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY |
| Checkout URL missing | Stripe price/key mismatch | Verify STRIPE_SECRET_KEY and price ID |
| Webhook 400 | Signature secret mismatch | Recreate webhook secret in Vercel env |
| No entitlement | Webhook handler or metadata missing | Check session metadata includes user_id and product_id |
| Duplicate entitlement | Missing upsert key | Enforce `(user_id, product_id)` primary key |
| Widget zero revenue after purchase | ledger insert missing | Confirm billing event and reality ledger writes |

## Final proof statement

Only mark REAL when this exact statement is true:

> I clicked a locked related vignette, paid through Stripe test checkout, received access, reopened the related vignette, saw it unlocked, and confirmed telemetry, entitlement, revenue, and Reality Ledger proof rows exist.
