# OWNYOURAI / OWNMYAI Final Revenue Moat Payload

Status: BUILD PACK REAL. Runtime remains PARTIAL until keys, target repo, Supabase migration, and deployment proof exist.

## 1. Stripe webhooks auto-unlock reports

Create `lib/audit/stripe-webhook-handler.ts`:

```ts
import crypto from 'crypto';
import { supabaseInsert, supabasePatchById } from '@/lib/supabase/server';

export function verifyStripeSignature(rawBody: string, sig: string | null) {
  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!secret) return { ok: false, reason: 'missing_webhook_secret' };
  if (!sig) return { ok: false, reason: 'missing_signature' };
  const timestamp = sig.match(/t=([^,]+)/)?.[1];
  const v1 = sig.match(/v1=([^,]+)/)?.[1];
  if (!timestamp || !v1) return { ok: false, reason: 'bad_signature_header' };
  const signedPayload = `${timestamp}.${rawBody}`;
  const expected = crypto.createHmac('sha256', secret).update(signedPayload).digest('hex');
  const ok = crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(v1));
  return { ok, reason: ok ? null : 'signature_mismatch' };
}

export async function handleStripeEvent(event: any) {
  const type = event.type;
  const obj = event.data?.object || {};
  const reportId = obj.metadata?.report_id;
  const offerKey = obj.metadata?.offer_key;
  const paymentIntent = obj.payment_intent || obj.id;

  await supabaseInsert('site_followup_events', {
    step_key: `stripe_${type}`,
    status: 'received',
    subject: `Stripe ${type}`,
    body: JSON.stringify({ reportId, offerKey, paymentIntent }).slice(0, 4000),
    evidence: { classification: 'REAL', provider: 'stripe', event_id: event.id }
  });

  if (type === 'checkout.session.completed' && reportId) {
    await supabasePatchById('ai_audit_reports', reportId, {
      payment_status: 'paid',
      report_status: 'paid',
      stripe_checkout_session_id: obj.id,
      stripe_payment_intent_id: paymentIntent,
      upgraded_at: new Date().toISOString(),
      evidence: { stripe: { classification: 'REAL', event_id: event.id, offerKey } }
    });
    return { ok: true, unlocked: true, reportId };
  }

  if (type === 'checkout.session.expired' && reportId) {
    await supabasePatchById('ai_audit_reports', reportId, { payment_status: 'expired', report_status: 'expired' });
  }
  return { ok: true, unlocked: false };
}
```

Patch `lib/supabase/server.ts`:

```ts
export async function supabasePatchById(table: string, id: string, payload: Record<string, unknown>) {
  const cfg = supabaseConfig();
  if (!cfg) return { ok: false, blocked: true, reason: 'missing_supabase_env' };
  const res = await fetch(`${cfg.url}/rest/v1/${table}?id=eq.${encodeURIComponent(id)}`, {
    method: 'PATCH',
    headers: { apikey: cfg.key, Authorization: `Bearer ${cfg.key}`, 'Content-Type': 'application/json', Prefer: 'return=representation' },
    body: JSON.stringify(payload)
  });
  const data = await res.json().catch(() => null);
  return { ok: res.ok, status: res.status, data };
}
```

Replace `app/api/checkout/webhook/route.ts`:

```ts
import { NextResponse } from 'next/server';
import { verifyStripeSignature, handleStripeEvent } from '@/lib/audit/stripe-webhook-handler';

export async function POST(req: Request) {
  const raw = await req.text();
  const sig = req.headers.get('stripe-signature');
  const verified = verifyStripeSignature(raw, sig);
  if (!verified.ok) return NextResponse.json({ ok: false, error: verified.reason }, { status: 400 });
  const event = JSON.parse(raw);
  const result = await handleStripeEvent(event);
  return NextResponse.json(result);
}
```

## 2. PDF generator paid deliverable

Create `lib/audit/pdf-report.ts`:

```ts
export function htmlReport(report: any) {
  return `<!doctype html><html><head><meta charset="utf-8"><title>${report.brand} AI Audit Report</title>
  <style>body{font-family:Arial,sans-serif;max-width:820px;margin:40px auto;line-height:1.5;color:#111}h1,h2{color:#111}.score{display:inline-block;padding:12px 18px;border:1px solid #ddd;margin:6px}.cta{padding:16px;background:#f3f3f3}</style></head><body>
  <h1>${report.brand} AI Audit Report</h1>
  <p>${report.narrative_summary || ''}</p>
  <h2>Scorecard</h2>
  <div class="score">Readiness: ${report.readiness_score}</div><div class="score">Risk: ${report.risk_score}</div><div class="score">Opportunity: ${report.opportunity_score}</div>
  <h2>Top Risks</h2><ul>${(report.top_risks || []).map((x:string)=>`<li>${x}</li>`).join('')}</ul>
  <h2>Top Opportunities</h2><ul>${(report.top_opportunities || []).map((x:string)=>`<li>${x}</li>`).join('')}</ul>
  <h2>Recommendations</h2><ul>${(report.recommendations || []).map((x:string)=>`<li>${x}</li>`).join('')}</ul>
  <div class="cta"><strong>Recommended next step:</strong> ${report.suggested_offer_tier || ''} — ${report.suggested_next_action || ''}</div>
  </body></html>`;
}

export function pseudoPdfBuffer(report: any) {
  // Safe fallback: HTML deliverable with PDF-ready layout. Replace with Playwright/Puppeteer in target repo if supported.
  return Buffer.from(htmlReport(report), 'utf8');
}
```

Create `app/api/report/pdf/[token]/route.ts`:

```ts
import { NextResponse } from 'next/server';
import { supabaseSelectByToken } from '@/lib/supabase/server';
import { pseudoPdfBuffer } from '@/lib/audit/pdf-report';

export async function GET(_: Request, { params }: { params: { token: string } }) {
  const result = await supabaseSelectByToken(params.token);
  if (!result.ok || !result.data) return NextResponse.json({ ok: false, error: 'not_found' }, { status: 404 });
  const r = result.data;
  if (r.payment_status !== 'paid' && r.report_status !== 'paid') {
    return NextResponse.json({ ok: false, error: 'payment_required' }, { status: 402 });
  }
  const buf = pseudoPdfBuffer(r);
  return new Response(buf, { headers: { 'Content-Type': 'text/html; charset=utf-8', 'Content-Disposition': `attachment; filename="${r.brand}-AI-Audit-Report.html"` } });
}
```

## 3. CRM sync deal tracking

Create `lib/audit/crm-sync.ts`:

```ts
import { supabaseInsert } from '@/lib/supabase/server';

export async function syncDealToCrm(input: any, report: any) {
  const payload = {
    name: input.name,
    email: input.email,
    organisation: input.organisation,
    brand: report.brand,
    offer: report.suggested_offer_tier,
    value: report.recommended_price,
    stage: report.payment_status === 'paid' ? 'won' : 'qualified',
    source: 'ownyourai_audit',
    report_id: report.id
  };

  if (process.env.HUBSPOT_PRIVATE_APP_TOKEN) {
    const res = await fetch('https://api.hubapi.com/crm/v3/objects/deals', {
      method: 'POST',
      headers: { Authorization: `Bearer ${process.env.HUBSPOT_PRIVATE_APP_TOKEN}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ properties: { dealname: `${payload.organisation || payload.email} - ${payload.offer}`, amount: String(payload.value || 0), dealstage: payload.stage, pipeline: process.env.HUBSPOT_PIPELINE_ID || undefined } })
    });
    return { ok: res.ok, provider: 'hubspot', status: res.status };
  }

  await supabaseInsert('site_followup_events', { step_key: 'crm_sync_pending', status: 'pending', subject: 'CRM sync pending', body: JSON.stringify(payload), evidence: { classification: 'PARTIAL', reason: 'missing_crm_env' } });
  return { ok: false, provider: 'none', blocked: true };
}
```

Patch `/api/intake` after report creation:

```ts
import { syncDealToCrm } from '@/lib/audit/crm-sync';
await syncDealToCrm(input, report);
```

## 4. Benchmark publishing authority moat

Create `lib/audit/benchmark-publishing.ts`:

```ts
export function benchmarkAuthorityContent(overlay = 'general') {
  const titleMap:any = {
    healthcare: 'AI in Healthcare: Administrative Relief Without Privacy Drift',
    government: 'AI in Government: Better Service With Stronger Accountability',
    saas: 'AI Changes SaaS Economics: Why Chatbots Are Not Strategy',
    general: 'The AI Readiness Gap: Why Hidden AI Use Becomes Board Risk'
  };
  const bodyMap:any = {
    healthcare: 'Healthcare AI value is real, but privacy, consent, clinical safety and record keeping cannot be afterthoughts.',
    government: 'Public sector AI must improve service without weakening auditability, fairness, accessibility or trust.',
    saas: 'SaaS teams must redesign product, pricing, support and delivery around agentic capability, not bolt on chatbots.',
    general: 'Hidden AI use is already inside organisations. The leadership task is to make it visible, governable and useful.'
  };
  return { title: titleMap[overlay] || titleMap.general, body: bodyMap[overlay] || bodyMap.general, cta: `/audit/${overlay === 'general' ? '' : overlay}`.replace(/\/$/, '') };
}
```

Create pages:

`app/benchmarks/[overlay]/page.tsx`:

```tsx
import { benchmarkAuthorityContent } from '@/lib/audit/benchmark-publishing';
export default function BenchmarkOverlay({ params }: { params: { overlay: string } }) {
  const c = benchmarkAuthorityContent(params.overlay);
  return <main style={{maxWidth:900,margin:'0 auto',padding:32,fontFamily:'system-ui'}}><h1>{c.title}</h1><p>{c.body}</p><h2>Benchmark status</h2><p>Percentiles are published only when the cohort is large enough to be defensible. Early cohorts show directional signals only.</p><a href={c.cta}>Take the audit</a></main>;
}
```

`app/authority/[overlay]/page.tsx`:

```tsx
import { benchmarkAuthorityContent } from '@/lib/audit/benchmark-publishing';
export default function AuthorityArticle({ params }: { params: { overlay: string } }) {
  const c = benchmarkAuthorityContent(params.overlay);
  return <main style={{maxWidth:900,margin:'0 auto',padding:32,fontFamily:'system-ui'}}><h1>{c.title}</h1><p>{c.body}</p><p>The benchmark exists to turn vague AI anxiety into practical comparison: readiness, risk and opportunity.</p><p>Take the audit to see where you sit and what to do next.</p><a href={c.cta}>Start audit</a></main>;
}
```

## 5. Supabase migration additions

Create `supabase/migrations/20260424_revenue_moat_additions.sql`:

```sql
alter table public.ai_audit_reports add column if not exists pdf_generated_at timestamptz;
alter table public.ai_audit_reports add column if not exists crm_sync_status text default 'pending';
alter table public.ai_audit_reports add column if not exists crm_deal_id text;

create or replace view public.v_ai_audit_paid_deliverables as
select id, created_at, brand, public_report_token, payment_status, report_status, pdf_generated_at, suggested_offer_tier, recommended_price
from public.ai_audit_reports
where payment_status = 'paid'
order by created_at desc;

insert into public.t4h_ui_snippet (slug, version, is_active, content) values
('ai-audit-paid-deliverables','1.0',true,$$
<section data-widget="ai-audit-paid-deliverables">
  <h2>Paid Audit Deliverables</h2>
  <p>Reports requiring PDF/report delivery after payment.</p>
  <pre data-query="v_ai_audit_paid_deliverables">select * from v_ai_audit_paid_deliverables limit 20;</pre>
</section>
$$)
on conflict (slug, version) do update set content=excluded.content, is_active=true;
```

## 6. Env additions

```txt
HUBSPOT_PRIVATE_APP_TOKEN=
HUBSPOT_PIPELINE_ID=
NEXT_PUBLIC_SITE_URL=
```

## 7. Smoke additions

```js
await check('/benchmarks/healthcare');
await check('/benchmarks/government');
await check('/benchmarks/saas');
await check('/authority/healthcare');
await check('/authority/government');
await check('/authority/saas');
```

## Final gates

REAL only when:
- Stripe webhook signature validates.
- checkout.session.completed updates report to paid.
- paid report download route returns deliverable.
- CRM sync writes to HubSpot or pending event.
- benchmark/authority routes return 200.
- Command Centre snippet exists for paid deliverables.
