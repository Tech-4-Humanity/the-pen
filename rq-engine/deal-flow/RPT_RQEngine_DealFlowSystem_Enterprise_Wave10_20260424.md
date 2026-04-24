# RQ Engine Enterprise Deal Flow System — Wave 10 Pack

**Date:** 2026-04-24  
**Owner:** Tech 4 Humanity / RQ Engine  
**Repository:** `TML-4PM/the-pen`  
**Status:** PARTIAL until runtime execution, CRM writeback, Stripe activation, and first real prospect movement are evidenced.  
**Autonomy tier:** AUTONOMOUS for non-destructive orchestration; GATED for payment activation, email sending to real prospects, legal/privacy policy publishing, and destructive updates.  

## 1. Purpose

Build RQ Engine into a repeatable enterprise revenue machine: lead list → qualification → outreach → meeting → diagnostic → pilot → proposal → invoice/payment → delivery → evidence → expansion.

This pack is designed for the Pen / Bridge Runner to implement as a real operating system, not a static document.

## 2. Commercial motion

### Default product ladder

| Offer | Price | Duration | Buyer | Purpose |
|---|---:|---:|---|---|
| Executive Diagnostic | AUD 35,000 | 2–4 weeks | CHRO, COO, Head of AI Transformation | Fast assessment of workforce variability, AI ROI, overload, and work design mismatch |
| Team Pilot | AUD 95,000 | 6–8 weeks | CHRO, COO, L&D, Ops | Prove measurable uplift in one team/cohort |
| Enterprise Platform | AUD 180,000+ / year | Annual | Executive sponsor + CIO/HR/Ops | Scale dashboards, governance, reporting, integration, quarterly optimisation |
| Advisory + Platform Hybrid | Custom | Ongoing | Enterprise | Highest-margin model: setup + annual licence + quarterly optimisation |

### Positioning

Lead with:
- performance consistency
- AI ROI
- manager burden reduction
- work design improvement
- fatigue, overload, and risk signals

Do **not** lead cold enterprise conversations with brain-type language, clinical framing, or anything that sounds like diagnosis or employee surveillance.

## 3. Pipeline stages

1. **Target identified** — company/contact added.
2. **Prioritised** — A/B/C score assigned.
3. **First touch sent** — LinkedIn/email/template logged.
4. **Engaged** — response received.
5. **Discovery booked** — calendar event exists.
6. **Discovery complete** — call notes captured.
7. **Diagnostic proposed** — proposal generated.
8. **Diagnostic won/lost** — decision captured.
9. **Pilot proposed** — pilot proposal generated.
10. **Pilot won/lost** — decision captured.
11. **Delivery active** — project created.
12. **Expansion candidate** — enterprise upsell triggered.
13. **Closed / nurture / archived** — lifecycle outcome.

## 4. Supabase schema

```sql
create table if not exists public.rq_enterprise_accounts (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  website text,
  sector text,
  employee_band text,
  country text default 'AU',
  priority text check (priority in ('A','B','C')) default 'B',
  fit_score int check (fit_score between 0 and 100) default 50,
  owner text default 'troy',
  status text default 'target_identified',
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.rq_enterprise_contacts (
  id uuid primary key default gen_random_uuid(),
  account_id uuid references public.rq_enterprise_accounts(id),
  full_name text not null,
  role_title text,
  email text,
  linkedin_url text,
  buyer_type text,
  consent_status text default 'unknown',
  status text default 'new',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.rq_enterprise_deals (
  id uuid primary key default gen_random_uuid(),
  account_id uuid references public.rq_enterprise_accounts(id),
  contact_id uuid references public.rq_enterprise_contacts(id),
  deal_name text not null,
  offer_type text check (offer_type in ('diagnostic','pilot','enterprise_platform','advisory_hybrid')),
  stage text not null default 'target_identified',
  amount_aud numeric default 0,
  probability int check (probability between 0 and 100) default 10,
  next_action text,
  next_action_due date,
  close_date date,
  source text default 'rq_enterprise_outbound',
  evidence_status text check (evidence_status in ('REAL','PARTIAL','PRETEND')) default 'PARTIAL',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.rq_enterprise_touchpoints (
  id uuid primary key default gen_random_uuid(),
  deal_id uuid references public.rq_enterprise_deals(id),
  contact_id uuid references public.rq_enterprise_contacts(id),
  channel text check (channel in ('linkedin','email','call','meeting','proposal','invoice','note','system')),
  direction text check (direction in ('outbound','inbound','internal')),
  subject text,
  body text,
  outcome text,
  external_id text,
  created_at timestamptz default now()
);

create table if not exists public.rq_enterprise_assets (
  id uuid primary key default gen_random_uuid(),
  deal_id uuid references public.rq_enterprise_deals(id),
  asset_type text check (asset_type in ('deck','one_pager','proposal','diagnostic','pilot_plan','invoice','receipt','meeting_notes')),
  title text not null,
  url text,
  status text default 'draft',
  created_at timestamptz default now()
);

create table if not exists public.rq_enterprise_receipts (
  id uuid primary key default gen_random_uuid(),
  receipt_type text not null,
  system text default 'rq_engine_enterprise_deal_flow',
  claim text not null,
  status text check (status in ('REAL','PARTIAL','PRETEND')) default 'PARTIAL',
  evidence jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create or replace view public.v_rq_enterprise_pipeline as
select
  d.id as deal_id,
  a.company_name,
  c.full_name,
  c.role_title,
  d.deal_name,
  d.offer_type,
  d.stage,
  d.amount_aud,
  d.probability,
  round((d.amount_aud * d.probability / 100.0), 2) as weighted_pipeline_aud,
  d.next_action,
  d.next_action_due,
  d.evidence_status,
  d.created_at,
  d.updated_at
from public.rq_enterprise_deals d
left join public.rq_enterprise_accounts a on a.id = d.account_id
left join public.rq_enterprise_contacts c on c.id = d.contact_id;
```

## 5. RLS baseline

```sql
alter table public.rq_enterprise_accounts enable row level security;
alter table public.rq_enterprise_contacts enable row level security;
alter table public.rq_enterprise_deals enable row level security;
alter table public.rq_enterprise_touchpoints enable row level security;
alter table public.rq_enterprise_assets enable row level security;
alter table public.rq_enterprise_receipts enable row level security;

create policy if not exists rq_enterprise_service_all_accounts on public.rq_enterprise_accounts for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists rq_enterprise_service_all_contacts on public.rq_enterprise_contacts for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists rq_enterprise_service_all_deals on public.rq_enterprise_deals for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists rq_enterprise_service_all_touchpoints on public.rq_enterprise_touchpoints for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists rq_enterprise_service_all_assets on public.rq_enterprise_assets for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists rq_enterprise_service_all_receipts on public.rq_enterprise_receipts for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
```

## 6. Command Centre widget query

```sql
insert into public.t4h_ui_snippet (slug, version, is_active, content)
values (
  'rq-enterprise-pipeline-widget',
  '1.0',
  true,
  '<iframe src="/widgets/rq-enterprise-pipeline" style="width:100%;height:900px;border:0;border-radius:16px;"></iframe>'
)
on conflict (slug, version) do update set is_active = excluded.is_active, content = excluded.content;
```

## 7. Automation events

### Event names

- `rq.enterprise.account.created`
- `rq.enterprise.contact.created`
- `rq.enterprise.first_touch.sent`
- `rq.enterprise.response.received`
- `rq.enterprise.discovery.booked`
- `rq.enterprise.discovery.completed`
- `rq.enterprise.proposal.generated`
- `rq.enterprise.invoice.generated`
- `rq.enterprise.payment.received`
- `rq.enterprise.delivery.started`
- `rq.enterprise.expansion.triggered`

### Bridge envelope

```json
{
  "action": "invoke_function",
  "function_name": "rq-enterprise-deal-flow-orchestrator",
  "invocation_type": "RequestResponse",
  "payload": {
    "event_type": "rq.enterprise.proposal.generated",
    "deal_id": "uuid",
    "dry_run": false
  },
  "metadata": {
    "source": "the-pen",
    "biz_key": "rq_engine",
    "request_id": "rq-deal-flow-20260424",
    "timestamp_utc": "2026-04-24T00:00:00Z"
  }
}
```

## 8. HubSpot mapping

If HubSpot is used, map as:

- Company → `rq_enterprise_accounts`
- Contact → `rq_enterprise_contacts`
- Deal → `rq_enterprise_deals`
- Note / email / meeting → `rq_enterprise_touchpoints`
- Attachment / proposal / invoice link → `rq_enterprise_assets`

Default deal stages:

- `target_identified`
- `first_touch_sent`
- `engaged`
- `discovery_booked`
- `diagnostic_proposed`
- `diagnostic_won`
- `pilot_proposed`
- `pilot_won`
- `delivery_active`
- `expansion_candidate`
- `closed_won`
- `closed_lost`
- `nurture`

## 9. Outreach templates

### LinkedIn first touch

Hi [Name] — I’m building an enterprise workforce optimisation model that looks at performance consistency, workload state, and AI usage together rather than as separate issues.

It is designed to help teams improve output consistency, reduce overload, and get better ROI from AI tools already in place.

I thought it may be relevant to your work in [HR/Ops/Transformation]. Happy to send the short pilot overview.

### Warm email

Subject: Improving performance consistency and AI ROI

Hi [Name],

I’m working on RQ Engine, a workforce optimisation platform that helps organisations understand where performance, workload, and AI usage are mismatched.

The enterprise pilot is built around a practical question: where are people, tasks, states, and AI support out of alignment, and what measurable interventions improve output?

Typical pilot:
- 50–150 participants
- 6–8 weeks
- baseline, intervention, measurement
- manager dashboard and executive outcome report
- AUD 95k

The goal is not more dashboards. It is better work design, stronger AI ROI, less manager guesswork, and measurable improvement.

Happy to send the short pilot overview.

Troy

### Follow-up

Subject: RQ Engine pilot structure

Hi [Name],

Most teams we speak to are seeing uneven results from AI rollout. Some people accelerate, some slow down, and managers are left guessing why.

That is usually not a tooling issue. It is a mismatch between people, state, workload, and task design.

The RQ pilot surfaces those mismatches and turns them into practical interventions.

Worth a short conversation?

Troy

## 10. Proposal generator fields

Required fields:

- company_name
- sponsor_name
- sponsor_role
- sector
- team_scope
- participant_count
- current_problem
- target_outcomes
- pilot_duration
- investment
- decision_date
- governance_notes

Generated outputs:

- diagnostic one-pager
- pilot proposal
- board-ready summary
- implementation plan
- invoice/payment request payload
- Reality Ledger receipt

## 11. Deal scoring

Fit score = 100-point model:

- AI rollout pressure: 20
- measurable workforce output: 20
- executive sponsor access: 20
- urgency / pain: 15
- cohort size: 10
- governance readiness: 10
- expansion potential: 5

A = 75+  
B = 50–74  
C = under 50

## 12. First 30-day operating target

- 100 target accounts added
- 300 contacts identified
- 100 first touches sent
- 30 replies
- 10 discovery meetings
- 3 diagnostic proposals
- 1 pilot proposal
- 1 signed diagnostic or pilot

## 13. Stripe status

Stripe product creation was attempted from assistant execution but blocked by platform safety controls. Therefore Stripe activation is **GATED**.

Required manual/compliant Stripe objects:

- Product: RQ Engine Executive Diagnostic — AUD 35,000 one-time
- Product: RQ Engine Enterprise Pilot — AUD 95,000 one-time
- Product: RQ Engine Enterprise Platform — AUD 180,000+ annual subscription or invoice

Do not mark payment layer REAL until Stripe product IDs, price IDs, payment links/invoice IDs, and payment receipts are captured in `rq_enterprise_receipts`.

## 14. Runtime acceptance tests

1. Create account/contact/deal.
2. Log first outbound touch.
3. Move deal to `engaged`.
4. Generate proposal asset row.
5. Create calendar booking or touchpoint.
6. Write receipt.
7. Confirm `v_rq_enterprise_pipeline` returns weighted value.
8. Confirm Command Centre widget renders.
9. Confirm invoice/payment step is either REAL or GATED with evidence.

## 15. Reality Ledger classification

Current: **PARTIAL**

Reason:
- GitHub pack exists.
- Schema, workflow, automation envelope, and outreach system are defined.
- Stripe product creation was blocked.
- Runtime deployment, CRM writeback, and real prospect movement are not yet evidenced.

Path to REAL:
- Supabase migration applied.
- Command Centre widget renders live data.
- At least one real account/contact/deal created.
- At least one touchpoint logged from Gmail/LinkedIn/manual entry.
- Proposal generated and asset URL stored.
- Stripe/manual invoice object linked.
- Receipt written and searchable.

## 16. Pen tasks

- Apply Supabase migration.
- Build `/widgets/rq-enterprise-pipeline` page.
- Build proposal generator endpoint.
- Build `rq-enterprise-deal-flow-orchestrator` Lambda/worker.
- Add GitHub Actions smoke test.
- Add Command Centre snippet.
- Create runtime receipt JSON after successful smoke test.
- Keep all receipts in `receipts/` and `rq-engine/deal-flow/receipts/`.

## 17. Completion rule

This system is not complete until the Pen produces a runtime receipt proving:

- data write
- pipeline view read
- proposal generation
- widget render
- receipt persistence
- Stripe/payment layer marked REAL or GATED with reason
