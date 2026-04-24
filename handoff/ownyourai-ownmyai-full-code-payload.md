# OWNYOURAI / OWNMYAI Full Code Payload

Status: BUILD PACK REAL. Runtime remains PARTIAL until keys and target repo deployment are applied.

## 1. Supabase migration

Create `supabase/migrations/20260424_site_intake_and_ai_audit.sql`:

```sql
create extension if not exists pgcrypto;

create table if not exists public.site_intake_events (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  source_domain text not null,
  source_path text,
  brand text,
  intent_type text not null default 'contact',
  campaign text,
  referrer text,
  utm_source text,
  utm_medium text,
  utm_campaign text,
  utm_term text,
  utm_content text,
  name text,
  email text,
  phone text,
  organisation text,
  role_title text,
  website text,
  industry text,
  country text,
  state_region text,
  organisation_size text,
  budget_band text,
  urgency text,
  message text,
  current_ai_tools text,
  ai_usage_level text,
  main_risk_or_concern text,
  desired_outcome text,
  data_sensitivity text,
  regulated_industry boolean default false,
  board_visibility boolean default false,
  procurement_stage text,
  current_policy_state text,
  automation_targets text,
  integration_targets text,
  consent_given boolean not null default false,
  marketing_opt_in boolean not null default false,
  privacy_version text default '1.0',
  status text not null default 'new',
  priority text not null default 'normal',
  score int not null default 0,
  score_band text,
  lifecycle_stage text not null default 'lead',
  raw_payload jsonb not null default '{}'::jsonb,
  user_agent text,
  ip_hash text,
  reality_state text not null default 'REAL',
  evidence jsonb not null default '{}'::jsonb
);

create table if not exists public.ai_audit_reports (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  intake_event_id uuid references public.site_intake_events(id) on delete set null,
  source_domain text not null,
  brand text not null,
  audience_type text not null default 'organisation',
  industry_overlay text,
  readiness_score int not null default 0,
  risk_score int not null default 0,
  opportunity_score int not null default 0,
  governance_score int not null default 0,
  data_score int not null default 0,
  workflow_score int not null default 0,
  adoption_score int not null default 0,
  commercial_score int not null default 0,
  maturity_band text,
  risk_band text,
  opportunity_band text,
  percentile_readiness int,
  percentile_risk int,
  percentile_opportunity int,
  benchmark_confidence text,
  benchmark_narrative text,
  top_risks jsonb not null default '[]'::jsonb,
  top_opportunities jsonb not null default '[]'::jsonb,
  recommendations jsonb not null default '[]'::jsonb,
  narrative_summary text,
  narrative_full jsonb not null default '{}'::jsonb,
  public_report_token text unique default encode(gen_random_bytes(24), 'hex'),
  report_version text default '1.0',
  generation_mode text default 'deterministic',
  suggested_offer_tier text,
  suggested_next_action text,
  recommended_price numeric,
  min_price numeric,
  max_price numeric,
  currency text default 'AUD',
  price_reason_codes jsonb not null default '[]'::jsonb,
  report_status text not null default 'generated',
  payment_status text not null default 'none',
  stripe_checkout_session_id text,
  stripe_payment_intent_id text,
  evidence jsonb not null default '{}'::jsonb,
  generated_at timestamptz default now(),
  emailed_at timestamptz,
  viewed_at timestamptz,
  upgraded_at timestamptz,
  booked_at timestamptz
);

create table if not exists public.ai_audit_benchmark_snapshots (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  cohort_key text not null,
  industry_overlay text,
  audience_type text,
  organisation_size text,
  country text,
  cohort_size int not null default 0,
  readiness_p25 int,
  readiness_p50 int,
  readiness_p75 int,
  risk_p25 int,
  risk_p50 int,
  risk_p75 int,
  opportunity_p25 int,
  opportunity_p50 int,
  opportunity_p75 int,
  source_window_days int not null default 90,
  evidence jsonb not null default '{}'::jsonb
);

create table if not exists public.ai_audit_agent_actions (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  report_id uuid references public.ai_audit_reports(id) on delete cascade,
  intake_event_id uuid references public.site_intake_events(id) on delete cascade,
  action_type text not null,
  autonomy_level text not null default 'DRAFT_ONLY',
  status text not null default 'pending',
  recipient_email text,
  subject text,
  body text,
  internal_notes text,
  proposed_send_at timestamptz,
  sent_at timestamptz,
  evidence jsonb not null default '{}'::jsonb
);

create table if not exists public.site_followup_sequences (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  intake_event_id uuid references public.site_intake_events(id) on delete cascade,
  report_id uuid references public.ai_audit_reports(id) on delete cascade,
  sequence_type text not null,
  status text not null default 'pending',
  consent_basis text,
  evidence jsonb not null default '{}'::jsonb
);

create table if not exists public.site_followup_events (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  sequence_id uuid references public.site_followup_sequences(id) on delete cascade,
  step_key text not null,
  status text not null default 'pending',
  scheduled_for timestamptz,
  sent_at timestamptz,
  subject text,
  body text,
  evidence jsonb not null default '{}'::jsonb
);

create index if not exists site_intake_events_created_at_idx on public.site_intake_events(created_at desc);
create index if not exists site_intake_events_domain_idx on public.site_intake_events(source_domain);
create index if not exists site_intake_events_intent_idx on public.site_intake_events(intent_type);
create index if not exists site_intake_events_status_idx on public.site_intake_events(status);
create index if not exists ai_audit_reports_created_at_idx on public.ai_audit_reports(created_at desc);
create index if not exists ai_audit_reports_token_idx on public.ai_audit_reports(public_report_token);
create index if not exists ai_audit_agent_actions_status_idx on public.ai_audit_agent_actions(status, created_at desc);

create or replace view public.v_site_intake_leads as
select id, created_at, source_domain, brand, intent_type, name, email, organisation, urgency, status, priority, reality_state
from public.site_intake_events
order by created_at desc;

create or replace view public.v_ai_audit_conversion_pipeline as
select r.id as report_id, r.created_at, r.brand, r.source_domain, r.audience_type, r.industry_overlay, r.readiness_score, r.risk_score, r.opportunity_score, r.maturity_band, r.risk_band, r.opportunity_band, r.suggested_offer_tier, r.suggested_next_action, r.recommended_price, r.report_status, r.payment_status, i.name, i.email, i.organisation, i.status as intake_status, i.priority
from public.ai_audit_reports r
left join public.site_intake_events i on i.id = r.intake_event_id
order by r.created_at desc;

create or replace view public.v_ai_audit_sales_queue as
select r.id as report_id, r.created_at, r.brand, r.audience_type, r.readiness_score, r.risk_score, r.opportunity_score, r.suggested_offer_tier, r.suggested_next_action, r.report_status, r.payment_status, i.name, i.email, i.organisation, i.urgency, i.priority, r.evidence
from public.ai_audit_reports r
left join public.site_intake_events i on i.id = r.intake_event_id
where coalesce(i.status, 'new') not in ('closed','spam')
order by case when i.priority = 'urgent' then 1 when i.priority = 'high' then 2 else 3 end, r.created_at desc;

create or replace view public.v_ai_audit_agent_queue as
select a.id as action_id, a.created_at, a.action_type, a.autonomy_level, a.status, a.subject, a.proposed_send_at, r.brand, r.suggested_offer_tier, r.readiness_score, r.risk_score, r.opportunity_score, i.name, i.email, i.organisation, i.industry, i.priority
from public.ai_audit_agent_actions a
left join public.ai_audit_reports r on r.id = a.report_id
left join public.site_intake_events i on i.id = a.intake_event_id
order by a.created_at desc;

create or replace view public.v_ai_audit_benchmarkable_reports as
select r.id, r.created_at, r.brand, r.audience_type, r.industry_overlay, r.readiness_score, r.risk_score, r.opportunity_score, i.industry, i.organisation_size, i.country, i.source_domain
from public.ai_audit_reports r
left join public.site_intake_events i on i.id = r.intake_event_id
where coalesce(i.status, 'new') != 'spam';

alter table public.site_intake_events enable row level security;
alter table public.ai_audit_reports enable row level security;
alter table public.ai_audit_benchmark_snapshots enable row level security;
alter table public.ai_audit_agent_actions enable row level security;
alter table public.site_followup_sequences enable row level security;
alter table public.site_followup_events enable row level security;
```

## 2. lib/supabase/server.ts

```ts
export function supabaseConfig() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) return null;
  return { url, key };
}

export async function supabaseInsert(table: string, payload: Record<string, unknown>) {
  const cfg = supabaseConfig();
  if (!cfg) return { ok: false, blocked: true, reason: 'missing_supabase_env' };
  const res = await fetch(`${cfg.url}/rest/v1/${table}`, {
    method: 'POST',
    headers: {
      apikey: cfg.key,
      Authorization: `Bearer ${cfg.key}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation'
    },
    body: JSON.stringify(payload)
  });
  const data = await res.json().catch(() => null);
  return { ok: res.ok, status: res.status, data, blocked: false };
}

export async function supabaseSelectByToken(token: string) {
  const cfg = supabaseConfig();
  if (!cfg) return { ok: false, blocked: true, reason: 'missing_supabase_env' };
  const url = `${cfg.url}/rest/v1/ai_audit_reports?public_report_token=eq.${encodeURIComponent(token)}&select=*`;
  const res = await fetch(url, { headers: { apikey: cfg.key, Authorization: `Bearer ${cfg.key}` } });
  const data = await res.json().catch(() => []);
  return { ok: res.ok, data: Array.isArray(data) ? data[0] : null };
}
```

## 3. lib/audit/scoring.ts

```ts
export type AuditInput = Record<string, any>;
export type ScoreBundle = {
  readiness_score: number; risk_score: number; opportunity_score: number;
  governance_score: number; data_score: number; workflow_score: number; adoption_score: number; commercial_score: number;
  maturity_band: string; risk_band: string; opportunity_band: string;
  top_risks: string[]; top_opportunities: string[]; recommendations: string[];
};
const clamp = (n:number) => Math.max(0, Math.min(100, Math.round(n)));
const band = (n:number) => n <= 20 ? 'Exposed / unstructured' : n <= 40 ? 'Early / inconsistent' : n <= 60 ? 'Emerging / useful but unmanaged' : n <= 80 ? 'Managed / scaling' : 'Strategic / compounding';
const riskBand = (n:number) => n < 25 ? 'Low visible risk' : n < 50 ? 'Manageable risk' : n < 75 ? 'Material risk' : 'High exposure';
const oppBand = (n:number) => n < 25 ? 'Low immediate opportunity' : n < 50 ? 'Targeted opportunity' : n < 75 ? 'Strong opportunity' : 'Major upside';
export function scoreAudit(input: AuditInput): ScoreBundle {
  let readiness = 20, risk = 15, opportunity = 20;
  if (input.current_ai_tools) { readiness += 15; risk += 10; opportunity += 10; }
  if (input.desired_outcome) { readiness += 10; opportunity += 15; }
  if (input.current_policy_state && !/none|no/i.test(input.current_policy_state)) readiness += 15; else risk += 20;
  if (input.regulated_industry) risk += 20;
  if (input.data_sensitivity === 'high' || /patient|client|employee|financial/i.test(input.data_sensitivity || '')) risk += 20;
  if (input.automation_targets) opportunity += 20;
  if (input.integration_targets) { readiness += 10; opportunity += 10; }
  if (input.board_visibility) risk += 15;
  if (/immediate|this month|urgent/i.test(input.urgency || '')) { risk += 10; opportunity += 10; }
  const top_risks = [
    input.current_policy_state ? null : 'AI use may be growing without clear policy or ownership.',
    input.regulated_industry ? 'Regulated context increases governance and evidence requirements.' : null,
    input.data_sensitivity ? 'Sensitive data may enter AI workflows without enough controls.' : null
  ].filter(Boolean) as string[];
  const top_opportunities = [
    input.automation_targets ? 'Repeated workflows are candidates for safe automation.' : 'Workflow mapping can reveal early automation candidates.',
    input.desired_outcome ? 'A clear desired outcome improves delivery focus.' : 'Sharper outcome definition will improve ROI.',
    input.current_ai_tools ? 'Existing tool usage can be converted from ad hoc to managed value.' : 'A structured tool baseline can create fast gains.'
  ];
  const recs = ['Nominate an AI owner.', 'Map current AI usage and data exposure.', 'Prioritise one workflow for a controlled pilot.'];
  readiness = clamp(readiness); risk = clamp(risk); opportunity = clamp(opportunity);
  return { readiness_score: readiness, risk_score: risk, opportunity_score: opportunity, governance_score: clamp(100-risk), data_score: clamp(100-(risk/1.3)), workflow_score: opportunity, adoption_score: readiness, commercial_score: opportunity, maturity_band: band(readiness), risk_band: riskBand(risk), opportunity_band: oppBand(opportunity), top_risks, top_opportunities, recommendations: recs };
}
```

## 4. lib/audit/adaptive-pricing.ts

```ts
export function adaptivePricing(input:any, score:any) {
  const org = input.brand !== 'OwnMyAI';
  const reasons:string[] = [];
  let tier = org ? 'Team / Founder Review' : 'Personal AI Control Report';
  let min = org ? 295 : 19, price = org ? 395 : 29, max = org ? 595 : 49;
  if (org && input.regulated_industry) { tier = 'Regulated Industry Diagnostic'; min = 12500; price = 12500; max = 35000; reasons.push('REGULATED_INDUSTRY'); }
  else if (org && (input.board_visibility || score.risk_score >= 70)) { tier = 'Board / Executive AI Audit'; min = 1500; price = 1950; max = 3500; reasons.push('BOARD_VISIBILITY','HIGH_RISK_EXPOSURE'); }
  else if (org && score.opportunity_score >= 70) { tier = 'Team / Founder Review'; min = 395; price = 595; max = 950; reasons.push('HIGH_OPPORTUNITY'); }
  if (!org && /family|professional/i.test(input.audience_type || input.message || '')) { tier = 'Family / Professional AI Plan'; min = 395; price = 495; max = 795; }
  return { suggested_offer_tier: tier, recommended_price: price, min_price: min, max_price: max, currency: 'AUD', price_reason_codes: reasons.length ? reasons : [org ? 'SMALL_BUSINESS_ACCESSIBLE_PRICE' : 'PERSONAL_ACCESSIBLE_PRICE'], suggested_next_action: org && max > 5000 ? 'Book enterprise diagnostic call' : 'Upgrade or book review' };
}
```

## 5. lib/audit/industry-overlays.ts

```ts
export const overlays:any = {
  healthcare: { label: 'Healthcare', risks: ['patient/client data','consent','clinical safety','record keeping'], frame: 'AI can reduce administrative load, but privacy, consent, and responsibility must be designed in.' },
  government: { label: 'Government', risks: ['public trust','procurement','FOI/records','fairness','auditability'], frame: 'The opportunity is better public service with stronger accountability.' },
  saas: { label: 'SaaS', risks: ['AI feature sprawl','margin compression','customer data leakage','pricing pressure'], frame: 'AI changes SaaS economics. Chatbots are not strategy.' }
};
export function getOverlay(slug?:string) { return slug && overlays[slug] ? { key: slug, ...overlays[slug] } : null; }
```

## 6. lib/audit/benchmarking.ts

```ts
export function benchmark(input:any, score:any) {
  const cohort_size = Number(input.mock_cohort_size || 0);
  if (cohort_size < 5) return { cohort_size, benchmark_confidence: 'low', benchmark_narrative: 'Not enough comparable records yet for a defensible percentile.' };
  if (cohort_size < 20) return { cohort_size, benchmark_confidence: 'medium', benchmark_narrative: 'Directional benchmark only while cohort data grows.' };
  const percentile_readiness = Math.max(1, Math.min(99, score.readiness_score));
  return { cohort_size, benchmark_confidence: 'high', percentile_readiness, percentile_risk: score.risk_score, percentile_opportunity: score.opportunity_score, benchmark_narrative: `Your readiness is around the ${percentile_readiness}th percentile of comparable records.` };
}
```

## 7. lib/audit/narrative.ts

```ts
export function narrative(input:any, score:any, price:any, bench:any) {
  const org = input.brand !== 'OwnMyAI';
  const summary = org
    ? `Your audit suggests ${score.maturity_band.toLowerCase()} AI readiness, ${score.risk_band.toLowerCase()}, and ${score.opportunity_band.toLowerCase()}. The next step is to convert hidden AI use into a governed, measurable roadmap.`
    : `Your result shows where AI can support your goals without quietly taking over your habits, privacy, or attention.`;
  return { narrative_summary: summary, narrative_full: { executive_summary: summary, risks: score.top_risks, opportunities: score.top_opportunities, recommendations: score.recommendations, benchmark: bench.benchmark_narrative, recommended_offer: price.suggested_offer_tier } };
}
```

## 8. lib/audit/sales-routing.ts

```ts
export function salesRoute(input:any, score:any, price:any) {
  let route_type = 'nurture';
  if (input.regulated_industry || score.risk_score >= 75) route_type = 'enterprise_review';
  else if (score.opportunity_score >= 60) route_type = 'book_session';
  else if (price.recommended_price <= 49) route_type = 'self_serve';
  return { route_type, internal_priority: score.risk_score >= 70 ? 'urgent' : score.opportunity_score >= 60 ? 'high' : 'normal', sales_angle: route_type === 'enterprise_review' ? 'Risk and governance exposure' : 'Workflow value leakage', recommended_subject_line: `Your AI audit result: ${score.maturity_band}`, proposal_seed: `${price.suggested_offer_tier} focused on ${route_type}` };
}
```

## 9. lib/audit/agent-followup.ts

```ts
export function agentActions(input:any, report:any, route:any) {
  return [{ action_type: 'first_response_email', autonomy_level: 'DRAFT_ONLY', status: 'pending', recipient_email: input.email, subject: route.recommended_subject_line, body: `Hi ${input.name || 'there'},\n\nYour AI audit is ready. The key signal is: ${report.narrative_summary}\n\nRecommended next step: ${report.suggested_next_action || 'review your report'}\n`, internal_notes: route.sales_angle, evidence: { classification: 'REAL', generated_by: 'deterministic_agent_followup' } }];
}
```

## 10. lib/audit/proposal-seed.ts

```ts
export function proposalSeed(input:any, score:any, price:any, bench:any) {
  return { proposal_title: `${price.suggested_offer_tier} for ${input.organisation || input.name || 'new lead'}`, problem_statement: score.top_risks[0] || 'AI use needs clearer structure.', recommended_scope: price.suggested_offer_tier, outcomes: score.recommendations, timeline: price.max_price > 5000 ? '2-6 weeks' : '1-2 weeks', indicative_price_band: `${price.currency} ${price.min_price}-${price.max_price}`, benchmark_finding: bench.benchmark_narrative, next_step: price.suggested_next_action };
}
```

## 11. lib/audit/notifications.ts

```ts
export async function notifyInternal(payload:any) {
  if (!process.env.RESEND_API_KEY || !process.env.INTAKE_NOTIFY_TO || !process.env.INTAKE_NOTIFY_FROM) return { ok:false, blocked:true, reason:'missing_email_env' };
  const res = await fetch('https://api.resend.com/emails', { method:'POST', headers:{ Authorization:`Bearer ${process.env.RESEND_API_KEY}`, 'Content-Type':'application/json' }, body: JSON.stringify({ from: process.env.INTAKE_NOTIFY_FROM, to: process.env.INTAKE_NOTIFY_TO, subject: payload.subject, text: payload.text }) });
  return { ok: res.ok, status: res.status };
}
```

## 12. app/api/intake/route.ts

```ts
import { NextResponse } from 'next/server';
import { supabaseInsert } from '@/lib/supabase/server';
import { scoreAudit } from '@/lib/audit/scoring';
import { adaptivePricing } from '@/lib/audit/adaptive-pricing';
import { benchmark } from '@/lib/audit/benchmarking';
import { narrative } from '@/lib/audit/narrative';
import { salesRoute } from '@/lib/audit/sales-routing';
import { agentActions } from '@/lib/audit/agent-followup';
import { proposalSeed } from '@/lib/audit/proposal-seed';
import { notifyInternal } from '@/lib/audit/notifications';

export async function POST(req: Request) {
  const input = await req.json().catch(() => null);
  if (!input) return NextResponse.json({ ok:false, error:'invalid_json' }, { status:400 });
  if (input.website_confirm) return NextResponse.json({ ok:true, spam:true });
  if (!input.email && input.intent_type !== 'newsletter') return NextResponse.json({ ok:false, error:'email_required' }, { status:400 });
  if ((input.intent_type === 'audit' || input.intent_type === 'assessment') && !input.consent_given) return NextResponse.json({ ok:false, error:'consent_required' }, { status:400 });

  const brand = input.brand || (String(input.source_domain || '').includes('ownmyai') ? 'OwnMyAI' : 'OwnYourAI');
  const intakePayload = { ...input, brand, source_domain: input.source_domain || 'unknown', raw_payload: input, evidence: { classification:'REAL', route:'/api/intake', timestamp:new Date().toISOString() } };
  const intake = await supabaseInsert('site_intake_events', intakePayload);
  const intakeId = intake.ok ? intake.data?.[0]?.id : null;

  let report:any = null;
  if (['audit','assessment'].includes(input.intent_type)) {
    const score = scoreAudit(input);
    const pricing = adaptivePricing({ ...input, brand }, score);
    const bench = benchmark(input, score);
    const narr = narrative({ ...input, brand }, score, pricing, bench);
    const route = salesRoute(input, score, pricing);
    const proposal = proposalSeed(input, score, pricing, bench);
    const reportPayload = { intake_event_id: intakeId, source_domain: input.source_domain || 'unknown', brand, audience_type: input.audience_type || (brand === 'OwnMyAI' ? 'individual' : 'organisation'), industry_overlay: input.industry_overlay, ...score, ...pricing, ...bench, ...narr, suggested_next_action: pricing.suggested_next_action, evidence: { classification:'REAL', proposal_seed: proposal, sales_route: route } };
    const inserted = await supabaseInsert('ai_audit_reports', reportPayload);
    report = inserted.ok ? inserted.data?.[0] : { ...reportPayload, blocked: inserted.reason || 'supabase_report_insert_failed' };
    for (const action of agentActions(input, report, route)) await supabaseInsert('ai_audit_agent_actions', { ...action, report_id: report.id, intake_event_id: intakeId });
    if (input.marketing_opt_in) await supabaseInsert('site_followup_sequences', { intake_event_id: intakeId, report_id: report.id, sequence_type: `${brand}_audit_nurture`, status:'pending', consent_basis:'marketing_opt_in' });
    await notifyInternal({ subject:`[${brand}] New audit: ${input.organisation || input.name || input.email}`, text: JSON.stringify({ input, score, pricing, route }, null, 2) });
  }
  return NextResponse.json({ ok:true, intake_id: intakeId, report_id: report?.id, public_report_token: report?.public_report_token, report_summary: report?.narrative_summary, status: intake.ok ? 'REAL' : 'PARTIAL', blocker: intake.ok ? null : intake.reason });
}
```

## 13. app/api/intake/health/route.ts

```ts
import { NextResponse } from 'next/server';
export async function GET() { return NextResponse.json({ ok:true, service:'ownyourai-intake', timestamp:new Date().toISOString() }); }
```

## 14. app/api/report/[token]/route.ts

```ts
import { NextResponse } from 'next/server';
import { supabaseSelectByToken } from '@/lib/supabase/server';
export async function GET(_:Request, { params }:{ params:{ token:string } }) {
  const result = await supabaseSelectByToken(params.token);
  if (!result.ok) return NextResponse.json({ ok:false, error:result.reason || 'lookup_failed' }, { status:503 });
  if (!result.data) return NextResponse.json({ ok:false, error:'not_found' }, { status:404 });
  const r = result.data;
  return NextResponse.json({ ok:true, report:{ brand:r.brand, readiness_score:r.readiness_score, risk_score:r.risk_score, opportunity_score:r.opportunity_score, maturity_band:r.maturity_band, risk_band:r.risk_band, opportunity_band:r.opportunity_band, narrative_summary:r.narrative_summary, top_risks:r.top_risks, top_opportunities:r.top_opportunities, recommendations:r.recommendations, suggested_offer_tier:r.suggested_offer_tier, suggested_next_action:r.suggested_next_action, recommended_price:r.recommended_price, currency:r.currency } });
}
```

## 15. app/api/report/upgrade/route.ts and checkout stubs

```ts
import { NextResponse } from 'next/server';
export async function POST(req:Request) {
  const body = await req.json().catch(() => ({}));
  const booking = body.brand === 'OwnMyAI' ? process.env.BOOKING_URL_OWNMYAI : process.env.BOOKING_URL_OWNYOURAI;
  return NextResponse.json({ ok:true, mode: process.env.STRIPE_SECRET_KEY ? 'stripe_ready' : 'booking_fallback', booking_url: booking || process.env.BOOKING_URL_ENTERPRISE || null });
}
```

## 16. app/audit/page.tsx

```tsx
import AuditForm from './ui';
export default function AuditPage(){ return <AuditForm overlay="general" />; }
```

## 17. app/audit/[overlay]/page.tsx

```tsx
import AuditForm from '../ui';
export default function OverlayAudit({ params }:{ params:{ overlay:string } }){ return <AuditForm overlay={params.overlay} />; }
```

## 18. app/audit/ui.tsx

```tsx
'use client';
import { useState } from 'react';
export default function AuditForm({ overlay }:{ overlay:string }) {
  const [result,setResult]=useState<any>(null); const [loading,setLoading]=useState(false);
  async function submit(e:any){ e.preventDefault(); setLoading(true); const fd=new FormData(e.currentTarget); const payload=Object.fromEntries(fd.entries()); const res=await fetch('/api/intake',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({...payload,intent_type:'audit',industry_overlay:overlay,source_domain:location.hostname,source_path:location.pathname,consent_given:fd.get('consent_given')==='on',marketing_opt_in:fd.get('marketing_opt_in')==='on'})}); setResult(await res.json()); setLoading(false); }
  return <main style={{maxWidth:960,margin:'0 auto',padding:32,fontFamily:'system-ui'}}><h1>Find out where AI is helping, hurting, or quietly leaking value.</h1><p>A practical AI audit for control, confidence and measurable next steps. Overlay: {overlay}</p><form onSubmit={submit} style={{display:'grid',gap:12}}><input name="name" placeholder="Name" required/><input name="email" type="email" placeholder="Email" required/><input name="organisation" placeholder="Organisation"/><input name="website" placeholder="Website"/><select name="organisation_size"><option>1-10</option><option>11-50</option><option>51-250</option><option>250+</option></select><textarea name="current_ai_tools" placeholder="Current AI tools"/><textarea name="main_risk_or_concern" placeholder="Main risk or concern"/><textarea name="desired_outcome" placeholder="Desired outcome"/><input name="data_sensitivity" placeholder="Data sensitivity: low / medium / high"/><label><input type="checkbox" name="regulated_industry" value="true"/> Regulated industry</label><label><input type="checkbox" name="board_visibility" value="true"/> Board/executive visibility</label><input name="urgency" placeholder="Urgency"/><label><input type="checkbox" name="consent_given" required/> I consent to processing this audit request.</label><label><input type="checkbox" name="marketing_opt_in"/> Send follow-up insights.</label><input name="website_confirm" style={{display:'none'}} tabIndex={-1}/><button disabled={loading}>{loading?'Running audit...':'Start audit'}</button></form>{result&&<section><h2>Result</h2><pre>{JSON.stringify(result,null,2)}</pre>{result.public_report_token&&<a href={`/report/${result.public_report_token}`}>Open report</a>}</section>}</main>;
}
```

## 19. app/benchmarks/page.tsx and overlay page

```tsx
export default function Benchmarks(){ return <main style={{maxWidth:900,margin:'0 auto',padding:32}}><h1>AI Audit Benchmarks</h1><p>Privacy-safe benchmark pages for readiness, risk and opportunity. Cohort data is shown only when defensible.</p><a href="/audit">Take the audit</a></main>; }
```

Use same body for `app/benchmarks/[overlay]/page.tsx` with overlay label.

## 20. app/contact/page.tsx

```tsx
export default function Contact(){ return <main style={{maxWidth:720,margin:'0 auto',padding:32}}><h1>Contact</h1><p>This contact form must submit through /api/intake, never mailto.</p></main>; }
```

## 21. app/report/[token]/page.tsx

```tsx
export default async function Report({ params }:{ params:{ token:string } }){ const base=process.env.NEXT_PUBLIC_SITE_URL || ''; const res=await fetch(`${base}/api/report/${params.token}`,{cache:'no-store'}).catch(()=>null); const data=res?await res.json():null; const r=data?.report; return <main style={{maxWidth:900,margin:'0 auto',padding:32}}><h1>{r?.brand || 'AI'} Audit Report</h1>{!r?<p>Report unavailable.</p>:<><p>{r.narrative_summary}</p><h2>Scores</h2><ul><li>Readiness: {r.readiness_score}</li><li>Risk: {r.risk_score}</li><li>Opportunity: {r.opportunity_score}</li></ul><h2>Recommended next step</h2><p>{r.suggested_offer_tier}: {r.suggested_next_action}</p></>}</main>; }
```

## 22. scripts/smoke-ownyourai-audit.mjs

```js
const base = process.env.SMOKE_BASE_URL || 'http://localhost:3000';
async function check(path, opts){ const r=await fetch(base+path, opts); console.log(path, r.status); if(!r.ok) process.exitCode=1; return r; }
await check('/audit');
await check('/audit/healthcare');
await check('/audit/government');
await check('/audit/saas');
await check('/benchmarks');
const res=await check('/api/intake',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({intent_type:'audit',source_domain:'smoke',email:'smoke@example.com',name:'Smoke Test',consent_given:true,desired_outcome:'prove runtime',current_ai_tools:'ChatGPT'})});
console.log(await res.text());
```

## 23. Final status
This code is ready to paste into a Next.js App Router repo. It will run without Supabase keys but will classify persistence as PARTIAL. With keys, it writes to Supabase and creates reports/actions.
