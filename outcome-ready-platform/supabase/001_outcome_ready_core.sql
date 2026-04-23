-- Outcome Ready Platform Core Schema
-- Status: execution-ready DDL, apply only after environment confirmation

create extension if not exists pgcrypto;

create table if not exists public.orp_leads (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  source text not null default 'outcome-ready-web',
  product text not null check (product in ('reading','maths','wellbeing','adult','school','parent','provider','general')),
  audience text not null default 'unknown',
  name text,
  email text,
  phone text,
  organisation text,
  role text,
  child_age_band text,
  consent_status text not null default 'pending' check (consent_status in ('pending','granted','declined','not_required')),
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'new' check (status in ('new','triaged','contacted','converted','closed','blocked'))
);

create table if not exists public.orp_assessments (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  lead_id uuid references public.orp_leads(id) on delete set null,
  product text not null check (product in ('reading','maths','wellbeing','adult')),
  assessment_type text not null default 'intake',
  score numeric,
  band text,
  answers jsonb not null default '{}'::jsonb,
  result jsonb not null default '{}'::jsonb,
  recommendation jsonb not null default '{}'::jsonb,
  evidence_status text not null default 'partial' check (evidence_status in ('real','partial','pretend','blocked'))
);

create table if not exists public.orp_interventions (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  assessment_id uuid references public.orp_assessments(id) on delete cascade,
  product text not null,
  intervention_type text not null,
  title text not null,
  description text,
  action_payload jsonb not null default '{}'::jsonb,
  status text not null default 'recommended' check (status in ('recommended','accepted','started','completed','declined','blocked')),
  outcome jsonb not null default '{}'::jsonb
);

create table if not exists public.orp_packs (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  slug text unique not null,
  product text not null,
  audience text not null,
  name text not null,
  description text not null,
  inclusions jsonb not null default '[]'::jsonb,
  price_mode text not null default 'tbd' check (price_mode in ('free','fixed','range','quote','tbd')),
  price_note text,
  active boolean not null default true
);

create table if not exists public.orp_events (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  event_type text not null,
  product text,
  entity_type text,
  entity_id uuid,
  status text not null default 'logged',
  payload jsonb not null default '{}'::jsonb
);

create table if not exists public.orp_email_events (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  to_email text not null,
  from_email text not null default 'hello@outcome-ready.com',
  subject text not null,
  template_key text not null,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'queued' check (status in ('queued','sent','failed','blocked')),
  provider text default 'pending',
  provider_message_id text,
  error text
);

create table if not exists public.orp_reality_ledger (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  claim text not null,
  classification text not null check (classification in ('real','partial','pretend','blocked')),
  evidence_url text,
  evidence_payload jsonb not null default '{}'::jsonb,
  notes text
);

alter table public.orp_leads enable row level security;
alter table public.orp_assessments enable row level security;
alter table public.orp_interventions enable row level security;
alter table public.orp_packs enable row level security;
alter table public.orp_events enable row level security;
alter table public.orp_email_events enable row level security;
alter table public.orp_reality_ledger enable row level security;

create policy if not exists "service role full access leads" on public.orp_leads for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists "service role full access assessments" on public.orp_assessments for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists "service role full access interventions" on public.orp_interventions for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists "public read active packs" on public.orp_packs for select using (active = true);
create policy if not exists "service role full access packs" on public.orp_packs for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists "service role full access events" on public.orp_events for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists "service role full access email events" on public.orp_email_events for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');
create policy if not exists "service role full access ledger" on public.orp_reality_ledger for all using (auth.role() = 'service_role') with check (auth.role() = 'service_role');

insert into public.orp_packs (slug, product, audience, name, description, inclusions, price_mode, price_note)
values
('parent-starter', 'all', 'parent', 'Parent Starter Pack', 'A home-based starter pack covering reading, maths, and wellbeing checks with a practical 30-day improvement plan.', '["Reading check", "Maths check", "Wellbeing pulse", "Parent report", "30-day plan"]', 'range', 'Introductory pricing to be set after first pilot'),
('school-starter', 'all', 'school', 'School Starter Pack', 'Cohort screening and reporting across reading, maths, and wellbeing for schools and education providers.', '["Cohort baseline", "Reading + Maths screening", "Wellbeing pulse", "Teacher summary", "Intervention recommendations"]', 'quote', 'School pricing depends on cohort size'),
('provider-starter', 'all', 'provider', 'Provider Starter Pack', 'A provider-facing intake and intervention pack for tutors, allied health, therapy, and support organisations.', '["Family intake", "Learning notes", "Behaviour notes", "Intervention plan", "Report export"]', 'quote', 'Provider pricing depends on workflow'),
('adult-capability', 'adult', 'adult', 'Adult Capability Pack', 'Adult learning and capability support across comprehension, decision maths, productivity, and wellbeing.', '["Work comprehension", "Decision maths", "Wellbeing check", "Personal plan", "Progress report"]', 'range', 'Individual and enterprise pricing to be tested')
on conflict (slug) do nothing;

insert into public.orp_reality_ledger (claim, classification, notes)
values
('Outcome Ready Supabase schema authored and placed in the pen repo', 'real', 'DDL file exists in TML-4PM/the-pen outcome-ready-platform/supabase/001_outcome_ready_core.sql'),
('Outcome Ready platform is deployed and proven', 'pretend', 'No deployment receipt has been produced yet'),
('readingbuddy@outcome-ready.com email is operational', 'pretend', 'User stated email is not set up; must verify before use')
on conflict do nothing;
