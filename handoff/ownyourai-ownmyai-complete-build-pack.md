# OWNYOURAI / OWNMYAI Complete Build Pack

Status: PARTIAL until live repo deployment and keys are applied.

## Purpose
This pack gives the builder enough to implement the full OwnYourAI and OwnMyAI audit, intake, report, pricing, benchmark and sales-follow-up engine without further human design input.

## Runtime target
- Domains: ownyourai.org, ownmyai.org
- Required routes: /audit, /audit/healthcare, /audit/government, /audit/saas, /benchmarks, /benchmarks/healthcare, /benchmarks/government, /benchmarks/saas, /contact, /thanks, /report/[token]
- Required APIs: POST /api/intake, GET /api/intake/health, GET /api/report/[token], POST /api/report/upgrade, POST /api/checkout/create, POST /api/checkout/webhook

## Core flow
1. Visitor completes audit or contact form.
2. API validates input, blocks honeypot, rate checks, stores intake.
3. Audit submissions generate deterministic scores.
4. System creates report, public token, narrative, pricing recommendation, benchmark result and agent follow-up draft.
5. User sees instant result and CTA.
6. Internal notification and Command Centre views expose the pipeline.

## Files to create in target Next.js repo

### Routes
```txt
app/audit/page.tsx
app/audit/[overlay]/page.tsx
app/benchmarks/page.tsx
app/benchmarks/[overlay]/page.tsx
app/contact/page.tsx
app/thanks/page.tsx
app/report/[token]/page.tsx
app/api/intake/route.ts
app/api/intake/health/route.ts
app/api/report/[token]/route.ts
app/api/report/upgrade/route.ts
app/api/checkout/create/route.ts
app/api/checkout/webhook/route.ts
```

### Libraries
```txt
lib/audit/scoring.ts
lib/audit/narrative.ts
lib/audit/adaptive-pricing.ts
lib/audit/industry-overlays.ts
lib/audit/benchmarking.ts
lib/audit/sales-routing.ts
lib/audit/agent-followup.ts
lib/audit/proposal-seed.ts
lib/audit/notifications.ts
lib/supabase/server.ts
```

## Environment variables
```txt
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
INTAKE_NOTIFY_TO=
INTAKE_NOTIFY_FROM=
RESEND_API_KEY=
BOOKING_URL_OWNYOURAI=
BOOKING_URL_OWNMYAI=
BOOKING_URL_ENTERPRISE=
INTAKE_ALLOWED_ORIGINS=https://ownyourai.org,https://www.ownyourai.org,https://ownmyai.org,https://www.ownmyai.org
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=
AI_REPORT_LLM_PROVIDER=
AI_REPORT_LLM_API_KEY=
AI_REPORT_LLM_MODEL=
```

## Acceptance status
- Build pack: REAL
- Deployed site: BLOCKED until target repo and Vercel deploy prove live
- Supabase persistence: BLOCKED until keys applied
- Email: BLOCKED until provider key applied
- Stripe: OPTIONAL/BLOCKED until keys applied
