-- Campaigns as Executable Infrastructure
-- task_id: campaign-board-hitl-expanded-20260511
-- status: PARTIAL until executed through Bridge/Supabase and evidenced

create table if not exists public.campaign_businesses (
  id uuid primary key default gen_random_uuid(),
  business_name text not null unique,
  group_name text not null,
  vercel_project_name text,
  campaign_wave int not null default 1,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.campaign_runs (
  id uuid primary key default gen_random_uuid(),
  campaign_name text not null,
  business_name text not null references public.campaign_businesses(business_name),
  wave int not null,
  start_date date not null,
  end_date date,
  channel text not null,
  objective text not null,
  offer text,
  audience text,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED','READY_FOR_HITL','NEEDS_DECISION','DONE')) default 'PARTIAL',
  hitl_required boolean not null default false,
  evidence_required text[] not null default array[]::text[],
  receipt_link text,
  owner_role text default 'campaign_operator',
  next_action text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.campaign_tasks (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.campaign_runs(id) on delete cascade,
  task_name text not null,
  task_type text not null check (task_type in ('asset','page','email','social','cta','crm','telemetry','evidence','hitl','smoke_test')),
  due_date date,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED','READY_FOR_HITL','NEEDS_DECISION','DONE')) default 'PARTIAL',
  automation_hint text,
  evidence_link text,
  receipt_link text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.campaign_hitl_decisions (
  id uuid primary key default gen_random_uuid(),
  business_name text not null,
  decision_type text not null check (decision_type in ('approve_first_sprint','merge_brand','kill_campaign','go_live','spend','legal','destructive')),
  decision_question text not null,
  default_action text not null,
  status text not null check (status in ('READY_FOR_HITL','APPROVED','REJECTED','DEFERRED','BLOCKED')) default 'READY_FOR_HITL',
  decision_by text,
  decision_at timestamptz,
  evidence_link text,
  created_at timestamptz not null default now()
);

create table if not exists public.campaign_evidence_log (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (entity_type in ('business','run','task','hitl','deployment','receipt')),
  entity_id uuid,
  evidence_type text not null,
  evidence_uri text not null,
  evidence_summary text,
  reality_status text not null check (reality_status in ('REAL','PARTIAL','BLOCKED')) default 'PARTIAL',
  created_at timestamptz not null default now()
);

create table if not exists public.campaign_runtime_tests (
  id uuid primary key default gen_random_uuid(),
  test_name text not null unique,
  test_scope text not null,
  expected_result text not null,
  status text not null check (status in ('REAL','PARTIAL','BLOCKED','READY_FOR_HITL','DONE')) default 'PARTIAL',
  evidence_link text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.campaign_businesses (business_name, group_name, vercel_project_name, campaign_wave)
values
('AI 4 Tradies','ENTRY','ai4tradies',1),
('GirlMath','FUN / SIGNAL SURFACE',null,1),
('Outcome Ready','MISSION','outcome-ready',1),
('Augmented Humanity Coach','CORE','augmented-humanity-coach',1),
('WorkFamilyAI','CORE','workfamilyai-static',1),
('Tech for Humanity','CORE','tech-for-humanity',2),
('HoloOrg','CORE','holo-org',2),
('ConsentX','SIGNAL','consent-x',2),
('Drug Resilience Atlas','SIGNAL','drug-resilience-atlas',2),
('AI Olympics','SIGNAL','aiolympics',2)
on conflict (business_name) do update set
  group_name = excluded.group_name,
  vercel_project_name = excluded.vercel_project_name,
  campaign_wave = excluded.campaign_wave,
  updated_at = now();

insert into public.campaign_runtime_tests (test_name, test_scope, expected_result, status)
values
('portfolio_wave_1_count','data','Five first-sprint businesses exist and are active','PARTIAL'),
('portfolio_wave_2_count','data','Five next-wave businesses exist and are active','PARTIAL'),
('hitl_policy_present','governance','HITL decisions exist only for approve/merge/kill/go-live/spend/legal/destructive gates','PARTIAL'),
('campaign_status_values','data','Campaign rows only use REAL/PARTIAL/BLOCKED/READY_FOR_HITL/NEEDS_DECISION/DONE','PARTIAL'),
('vercel_surface_mapping','runtime','Known Vercel projects mapped where available','PARTIAL'),
('receipt_fields_present','evidence','Every run/task can store receipt_link and evidence_link','PARTIAL'),
('first_sprint_queue','execution','First five businesses have executable campaign runs and tasks','PARTIAL'),
('next_five_queue','execution','Next five businesses staged for wave 2 execution','PARTIAL')
on conflict (test_name) do update set
  test_scope = excluded.test_scope,
  expected_result = excluded.expected_result,
  updated_at = now();
