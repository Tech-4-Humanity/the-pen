# OWNYOURAI / OWNMYAI Revenue, LLM, Email Sequence and Command Centre Wiring Payload

Status: BUILD PACK REAL. Runtime remains PARTIAL until Stripe, email, LLM, Supabase and live repo deployment keys are applied.

## 1. Stripe products and prices

Create `lib/audit/stripe-catalog.ts`:

```ts
export type StripeOfferKey =
  | 'ownyourai_mini_report'
  | 'ownyourai_team_review'
  | 'ownyourai_board_audit'
  | 'ownyourai_enterprise_diagnostic'
  | 'ownmyai_personal_report'
  | 'ownmyai_confidence_session'
  | 'ownmyai_family_plan';

export const stripeCatalog: Record<StripeOfferKey, any> = {
  ownyourai_mini_report: {
    brand: 'OwnYourAI', name: 'AI Readiness Mini Report', amountAud: 49,
    env: 'STRIPE_PRICE_OWNYOURAI_MINI_REPORT', mode: 'payment', fulfilment: 'paid_report'
  },
  ownyourai_team_review: {
    brand: 'OwnYourAI', name: 'Team / Founder Review', amountAud: 395,
    env: 'STRIPE_PRICE_OWNYOURAI_TEAM_REVIEW', mode: 'payment', fulfilment: 'booking_plus_report'
  },
  ownyourai_board_audit: {
    brand: 'OwnYourAI', name: 'Board / Executive AI Audit', amountAud: 1950,
    env: 'STRIPE_PRICE_OWNYOURAI_BOARD_AUDIT', mode: 'payment', fulfilment: 'executive_audit'
  },
  ownyourai_enterprise_diagnostic: {
    brand: 'OwnYourAI', name: 'Enterprise Diagnostic', amountAud: null,
    env: 'STRIPE_PRICE_OWNYOURAI_ENTERPRISE_DIAGNOSTIC', mode: 'quote', fulfilment: 'enterprise_quote'
  },
  ownmyai_personal_report: {
    brand: 'OwnMyAI', name: 'Personal AI Control Report', amountAud: 29,
    env: 'STRIPE_PRICE_OWNMYAI_PERSONAL_REPORT', mode: 'payment', fulfilment: 'paid_report'
  },
  ownmyai_confidence_session: {
    brand: 'OwnMyAI', name: '1:1 AI Confidence Session', amountAud: 195,
    env: 'STRIPE_PRICE_OWNMYAI_CONFIDENCE_SESSION', mode: 'payment', fulfilment: 'booking_plus_report'
  },
  ownmyai_family_plan: {
    brand: 'OwnMyAI', name: 'Family / Professional AI Plan', amountAud: 495,
    env: 'STRIPE_PRICE_OWNMYAI_FAMILY_PLAN', mode: 'payment', fulfilment: 'family_plan'
  }
};

export function offerKeyFromTier(brand: string, tier?: string): StripeOfferKey | null {
  const t = String(tier || '').toLowerCase();
  if (brand === 'OwnMyAI') {
    if (t.includes('family')) return 'ownmyai_family_plan';
    if (t.includes('confidence') || t.includes('session')) return 'ownmyai_confidence_session';
    return 'ownmyai_personal_report';
  }
  if (t.includes('enterprise') || t.includes('regulated')) return 'ownyourai_enterprise_diagnostic';
  if (t.includes('board') || t.includes('executive')) return 'ownyourai_board_audit';
  if (t.includes('team') || t.includes('founder')) return 'ownyourai_team_review';
  return 'ownyourai_mini_report';
}

export function priceIdForOffer(key: StripeOfferKey | null) {
  if (!key) return null;
  const env = stripeCatalog[key].env;
  return process.env[env] || null;
}
```

Create `app/api/checkout/create/route.ts`:

```ts
import { NextResponse } from 'next/server';
import { offerKeyFromTier, priceIdForOffer, stripeCatalog } from '@/lib/audit/stripe-catalog';

export async function POST(req: Request) {
  const body = await req.json().catch(() => ({}));
  const brand = body.brand || 'OwnYourAI';
  const key = body.offer_key || offerKeyFromTier(brand, body.suggested_offer_tier);
  const offer = key ? stripeCatalog[key] : null;
  if (!offer) return NextResponse.json({ ok: false, error: 'unknown_offer' }, { status: 400 });
  if (offer.mode === 'quote') return NextResponse.json({ ok: true, mode: 'quote', booking_url: process.env.BOOKING_URL_ENTERPRISE || null, offer });

  const stripeKey = process.env.STRIPE_SECRET_KEY;
  const price = priceIdForOffer(key);
  if (!stripeKey || !price) {
    return NextResponse.json({ ok: true, mode: 'booking_fallback', offer, missing: { stripeKey: !stripeKey, priceId: !price }, booking_url: brand === 'OwnMyAI' ? process.env.BOOKING_URL_OWNMYAI : process.env.BOOKING_URL_OWNYOURAI });
  }

  const origin = req.headers.get('origin') || process.env.NEXT_PUBLIC_SITE_URL || 'https://ownyourai.org';
  const form = new URLSearchParams();
  form.set('mode', 'payment');
  form.set('line_items[0][price]', price);
  form.set('line_items[0][quantity]', '1');
  form.set('success_url', `${origin}/thanks?paid=1&session_id={CHECKOUT_SESSION_ID}`);
  form.set('cancel_url', `${origin}/report/${body.public_report_token || ''}?cancelled=1`);
  if (body.email) form.set('customer_email', body.email);
  form.set('metadata[brand]', brand);
  form.set('metadata[report_id]', body.report_id || '');
  form.set('metadata[offer_key]', key);

  const res = await fetch('https://api.stripe.com/v1/checkout/sessions', {
    method: 'POST', headers: { Authorization: `Bearer ${stripeKey}`, 'Content-Type': 'application/x-www-form-urlencoded' }, body: form
  });
  const data = await res.json();
  return NextResponse.json({ ok: res.ok, mode: 'stripe', session: data, checkout_url: data.url || null }, { status: res.ok ? 200 : 500 });
}
```

Create `app/api/checkout/webhook/route.ts`:

```ts
import { NextResponse } from 'next/server';
import { supabaseInsert } from '@/lib/supabase/server';

export async function POST(req: Request) {
  const raw = await req.text();
  let event: any;
  try { event = JSON.parse(raw); } catch { return NextResponse.json({ ok:false, error:'invalid_json' }, { status:400 }); }
  await supabaseInsert('site_followup_events', {
    step_key: `stripe_${event.type || 'event'}`,
    status: 'received',
    subject: 'Stripe webhook received',
    body: raw.slice(0, 4000),
    evidence: { classification: 'PARTIAL', note: 'Signature verification must be enabled in production with STRIPE_WEBHOOK_SECRET.' }
  });
  return NextResponse.json({ ok:true, received:true });
}
```

## 2. LLM-enhanced reports

Create `lib/audit/llm-report.ts`:

```ts
export async function enhanceReportWithLLM(input: any, score: any, deterministic: any) {
  const provider = process.env.AI_REPORT_LLM_PROVIDER;
  const key = process.env.AI_REPORT_LLM_API_KEY;
  const model = process.env.AI_REPORT_LLM_MODEL || 'default';
  if (!provider || !key) return { ok:false, mode:'deterministic', narrative: deterministic, blocker:'missing_llm_env' };

  const safePayload = {
    brand: input.brand, audience_type: input.audience_type, industry_overlay: input.industry_overlay,
    scores: score, desired_outcome: input.desired_outcome, main_risk_or_concern: input.main_risk_or_concern,
    current_ai_tools: input.current_ai_tools, data_sensitivity: input.data_sensitivity,
    regulated_industry: input.regulated_industry, board_visibility: input.board_visibility
  };
  const prompt = `Write a practical AI audit report. Keep it factual, commercially useful, privacy-aware and non-alarmist. Use this JSON only:\n${JSON.stringify(safePayload)}`;

  try {
    if (provider === 'openai_compatible') {
      const res = await fetch(process.env.AI_REPORT_LLM_BASE_URL || 'https://api.openai.com/v1/chat/completions', {
        method: 'POST', headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ model, messages: [{ role: 'system', content: 'You generate concise, practical audit reports.' }, { role: 'user', content: prompt }], temperature: 0.3 })
      });
      const data = await res.json();
      const text = data.choices?.[0]?.message?.content;
      if (text) return { ok:true, mode:'llm', narrative: { ...deterministic, narrative_summary: text.slice(0, 900), narrative_full: { ...deterministic.narrative_full, llm_report: text } }, provider, model };
    }
    return { ok:false, mode:'deterministic', narrative: deterministic, blocker:'unsupported_provider' };
  } catch (e:any) {
    return { ok:false, mode:'deterministic', narrative: deterministic, blocker:e.message };
  }
}
```

Patch `/api/intake` after deterministic narrative generation:

```ts
import { enhanceReportWithLLM } from '@/lib/audit/llm-report';

const llm = await enhanceReportWithLLM({ ...input, brand }, score, narr);
const finalNarr = llm.narrative;
// use ...finalNarr instead of ...narr in reportPayload
// add generation_mode: llm.ok ? 'llm_enhanced' : 'deterministic'
// add evidence.llm = { ok: llm.ok, mode: llm.mode, blocker: llm.blocker || null }
```

## 3. Auto email sequences live

Create `lib/audit/email-sequences.ts`:

```ts
import { supabaseInsert } from '@/lib/supabase/server';
import { notifyInternal } from '@/lib/audit/notifications';

export function sequenceFor(input:any, score:any) {
  const brand = input.brand || 'OwnYourAI';
  if (brand === 'OwnMyAI') return 'ownmyai_personal_nurture';
  if (score.risk_score >= 70) return 'ownyourai_high_risk';
  if (score.opportunity_score >= 70) return 'ownyourai_high_opportunity';
  return 'ownyourai_free_audit_nurture';
}

export function sequenceSteps(type:string, report:any) {
  const url = report.public_report_token ? `/report/${report.public_report_token}` : '/audit';
  return [
    { step_key:'immediate', delayHours:0, subject:'Your AI audit snapshot is ready', body:`Your audit snapshot is ready. Open it here: ${url}` },
    { step_key:'24h', delayHours:24, subject:'What your AI score means', body:'The useful question is not whether AI is being used. It is whether it is visible, governed and creating measurable value.' },
    { step_key:'3d', delayHours:72, subject:'The common AI mistake to avoid', body:'Most teams add tools before they define ownership, data boundaries and workflow value.' },
    { step_key:'7d', delayHours:168, subject:'Turn your audit into an action plan', body:'The next step is a practical review that turns your score into a roadmap.' }
  ];
}

export async function createAndOptionallySendSequence(input:any, report:any, score:any) {
  if (!input.marketing_opt_in) return { ok:false, skipped:true, reason:'no_marketing_consent' };
  const type = sequenceFor(input, score);
  const seq = await supabaseInsert('site_followup_sequences', { intake_event_id: report.intake_event_id, report_id: report.id, sequence_type:type, status:'pending', consent_basis:'marketing_opt_in', evidence:{ classification:'REAL' } });
  const sequenceId = seq.data?.[0]?.id;
  for (const step of sequenceSteps(type, report)) {
    const scheduled = new Date(Date.now() + step.delayHours * 3600_000).toISOString();
    await supabaseInsert('site_followup_events', { sequence_id: sequenceId, step_key: step.step_key, status: step.delayHours === 0 ? 'ready' : 'scheduled', scheduled_for: scheduled, subject: step.subject, body: step.body, evidence:{ classification:'REAL' } });
  }
  if (process.env.AUTO_SEND_IMMEDIATE_EMAIL === 'true' && input.email) {
    await notifyInternal({ subject: `AUTO EMAIL READY: ${input.email}`, text: sequenceSteps(type, report)[0].body });
  }
  return { ok:true, sequence_type:type };
}
```

Patch `/api/intake` after report insert:

```ts
import { createAndOptionallySendSequence } from '@/lib/audit/email-sequences';
await createAndOptionallySendSequence({ ...input, brand }, report, score);
```

## 4. Command Centre widgets

Create `supabase/migrations/20260424_ai_audit_command_centre_widgets.sql`:

```sql
create table if not exists public.t4h_ui_snippet (
  id uuid primary key default gen_random_uuid(),
  slug text not null,
  version text not null default '1.0',
  is_active boolean not null default true,
  content text not null,
  created_at timestamptz not null default now(),
  unique(slug, version)
);

insert into public.t4h_ui_snippet (slug, version, is_active, content) values
('ai-audit-revenue-watch','1.0',true,$$
<section data-widget="ai-audit-revenue-watch">
  <h2>AI Audit Revenue Watch</h2>
  <p>Tracks paid upgrade attempts, recommended offers and payment state.</p>
  <pre data-query="v_ai_audit_conversion_pipeline">select * from v_ai_audit_conversion_pipeline limit 20;</pre>
</section>
$$)
on conflict (slug, version) do update set content=excluded.content, is_active=true;

insert into public.t4h_ui_snippet (slug, version, is_active, content) values
('ai-audit-agent-queue','1.0',true,$$
<section data-widget="ai-audit-agent-queue">
  <h2>AI Audit Agent Queue</h2>
  <p>Draft follow-ups and sales actions awaiting review.</p>
  <pre data-query="v_ai_audit_agent_queue">select * from v_ai_audit_agent_queue limit 20;</pre>
</section>
$$)
on conflict (slug, version) do update set content=excluded.content, is_active=true;

insert into public.t4h_ui_snippet (slug, version, is_active, content) values
('ai-audit-benchmark-gaps','1.0',true,$$
<section data-widget="ai-audit-benchmark-gaps">
  <h2>Benchmark Gaps</h2>
  <p>Highlights low readiness, high risk and strong opportunity signals.</p>
  <pre data-query="v_ai_audit_benchmarkable_reports">select * from v_ai_audit_benchmarkable_reports order by created_at desc limit 20;</pre>
</section>
$$)
on conflict (slug, version) do update set content=excluded.content, is_active=true;
```

## 5. Docs to add

Create `docs/OWNYOURAI_REVENUE_AI_CC_WIRING.md` with:

```md
# OWNYOURAI / OWNMYAI Revenue, AI and Command Centre Wiring

## Runtime classification
- Stripe: PARTIAL until STRIPE_SECRET_KEY and price IDs exist.
- LLM: PARTIAL until AI_REPORT_LLM_* exists.
- Email sequences: REAL as queued records, SEND_ALLOWED only when AUTO_SEND_IMMEDIATE_EMAIL=true and provider env exists.
- Command Centre: REAL once migration inserts snippets into t4h_ui_snippet.

## Required env
STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
STRIPE_PRICE_OWNYOURAI_MINI_REPORT
STRIPE_PRICE_OWNYOURAI_TEAM_REVIEW
STRIPE_PRICE_OWNYOURAI_BOARD_AUDIT
STRIPE_PRICE_OWNMYAI_PERSONAL_REPORT
STRIPE_PRICE_OWNMYAI_CONFIDENCE_SESSION
STRIPE_PRICE_OWNMYAI_FAMILY_PLAN
AI_REPORT_LLM_PROVIDER=openai_compatible
AI_REPORT_LLM_API_KEY
AI_REPORT_LLM_MODEL
AI_REPORT_LLM_BASE_URL
AUTO_SEND_IMMEDIATE_EMAIL=false
RESEND_API_KEY
INTAKE_NOTIFY_TO
INTAKE_NOTIFY_FROM
```

## 6. Smoke test additions

Add to smoke script:

```js
await check('/api/checkout/create',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({brand:'OwnYourAI',suggested_offer_tier:'AI Readiness Mini Report',email:'smoke@example.com'})});
```

## Final status
This payload wires Stripe-ready products, LLM-enhanced reports, live queued email sequences and Command Centre widgets. It is safe: missing keys produce fallbacks, not crashes.
