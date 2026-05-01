# Universal 12-Stage Funnel Control Pack

Status: PARTIAL until Supabase execution, bridge run, and dashboard proof are returned.
Owner: Tech 4 Humanity / Outcome Ready / Command Centre
Created: 2026-05-01 Australia/Sydney
Canonical purpose: one reusable product funnel system for all current and future T4H products.

## 1. Operating Rule

Every product must be mapped through the same 12-stage funnel. Product differences are handled through configuration, not new funnel logic.

The shared funnel stages are:

1. Problem Trigger
2. Audience
3. Entry Surface
4. Capture
5. Consent
6. Qualification
7. Offer
8. Conversion
9. Provisioning
10. First Value
11. Evidence
12. Continuation

## 2. Stage Contract

Each stage must produce a structured event with:

- product_key
- funnel_instance_id
- lead_id or account_id
- stage_number
- stage_key
- input_payload
- decision_payload
- output_payload
- status: pending | active | passed | failed | blocked
- evidence_id
- reality_state: REAL | PARTIAL | PRETEND | BLOCKED
- next_stage_key
- created_at
- updated_at

## 3. Expanded Stage Definitions

### 1. Problem Trigger
Question: What pain or opportunity starts this?

Purpose: create urgency and context.

Examples:
- child struggling to read
- business cannot explain AI value
- provider needs NDIS readiness
- founder wants productised AI workflow
- school needs twice-exceptional support

Outputs:
- trigger_type
- trigger_intensity_score
- source_signal
- urgency_band

Agent:
- Trigger Agent

### 2. Audience
Question: Who enters?

Purpose: identify buyer, user, beneficiary, and stakeholder.

Dimensions:
- parent
- student
- school
- provider
- participant
- SME owner
- enterprise executive
- government stakeholder
- partner/reseller

Outputs:
- persona_id
- audience_cluster
- buyer_user_beneficiary_map

Agent:
- Audience Agent

### 3. Entry Surface
Question: Where do they enter?

Surfaces:
- website
- widget
- form
- email
- QR code
- partner referral
- school/provider intake
- Command Centre
- API
- Synal/Place surface

Outputs:
- entry_surface
- campaign_id
- source_url
- attribution_chain

Agent:
- Entry Agent

### 4. Capture
Question: What data is collected?

Data classes:
- identity
- contact
- organisation
- role
- problem statement
- urgency
- consent posture
- product interest
- signal data when available

Outputs:
- capture_record_id
- completeness_score
- missing_fields

Agent:
- Capture Agent

### 5. Consent
Question: What permission is needed?

Consent levels:
- NONE: anonymous or minimal session only
- SESSION: temporary processing
- FULL: persistent product/service/research journey
- PARTNER: authorised shared workflow
- RESEARCH: explicit research participation

Outputs:
- consent_level
- consent_scope
- consent_actor_map
- expiry
- revocation_path

Agent:
- ConsentX Agent

### 6. Qualification
Question: How do we classify them?

Classification:
- HOT
- WARM
- COLD
- NURTURE
- REJECT
- REFER
- RESEARCH_ONLY

Inputs:
- fit
- urgency
- budget
- authority
- consent
- risk
- segment

Outputs:
- qualification_status
- lead_score
- recommended_route

Agent:
- Qualification Agent

### 7. Offer
Question: What do we recommend?

Offer types:
- free assessment
- paid assessment
- report
- subscription
- pilot
- workshop
- managed service
- implementation package
- research opt-in
- partner pack

Outputs:
- offer_id
- offer_variant
- offer_price_band
- upsell_path

Agent:
- Offer Agent

### 8. Conversion
Question: What payment, booking, or approval happens?

Conversion events:
- Stripe checkout
- subscription
- booking
- invoice
- signed approval
- school/provider onboarding
- research enrolment
- partner acceptance

Outputs:
- conversion_event_id
- conversion_type
- revenue_value
- booking_id
- payment_status

Agent:
- Conversion Agent

### 9. Provisioning
Question: What gets created or assigned?

Provisioning actions:
- account created
- agent assigned
- report generated
- dashboard created
- onboarding email sent
- workflow started
- cohort created
- partner access granted

Outputs:
- provisioning_id
- assigned_assets
- assigned_agents
- service_start_status

Agent:
- Provisioning Agent

### 10. First Value
Question: What proves it works quickly?

Examples:
- Reading Buddy: first reading insight/report
- Outcome Ready: first action plan
- AI Sweet Spots: first profile result
- AHC: first workflow automation recommendation
- HoloOrg: first role-to-agent map
- ConsentX: first actor/scope map
- MyNeuralSignal: first signal-to-intervention event

Outputs:
- first_value_event_id
- time_to_value_minutes
- user_visible_value
- value_score

Agent:
- First Value Agent

### 11. Evidence
Question: What gets logged or reported?

Evidence types:
- API response
- database result
- generated report
- user confirmation
- event log
- payment record
- booking record
- before/after metric
- research observation

Reality states:
- REAL: executed and evidenced
- PARTIAL: designed or partially executed
- PRETEND: proposed with no execution
- BLOCKED: dependency prevents execution

Outputs:
- evidence_id
- evidence_type
- reality_state
- proof_url_or_hash

Agent:
- Evidence Agent / Reality Ledger Agent

### 12. Continuation
Question: What keeps them moving or paying?

Loops:
- weekly progress report
- subscription renewal
- next assessment
- next intervention
- cohort comparison
- partner expansion
- upsell/cross-sell
- research follow-up
- support and success loop

Outputs:
- continuation_plan_id
- retention_state
- next_best_action
- expansion_opportunity

Agent:
- Continuation Agent

## 4. Supabase Production Schema

```sql
create schema if not exists funnel;

create table if not exists funnel.products (
  id uuid primary key default gen_random_uuid(),
  product_key text unique not null,
  product_name text not null,
  group_key text,
  owner_org text default 'Tech 4 Humanity',
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists funnel.stage_catalog (
  stage_number int primary key check (stage_number between 1 and 12),
  stage_key text unique not null,
  stage_name text not null,
  stage_question text not null,
  required_output_schema jsonb not null default '{}'::jsonb,
  default_agent_key text not null,
  active boolean default true
);

create table if not exists funnel.instances (
  id uuid primary key default gen_random_uuid(),
  product_key text not null references funnel.products(product_key),
  lead_id uuid,
  account_id uuid,
  current_stage_number int references funnel.stage_catalog(stage_number),
  status text not null default 'active' check (status in ('active','converted','lost','blocked','completed')),
  reality_state text not null default 'PARTIAL' check (reality_state in ('REAL','PARTIAL','PRETEND','BLOCKED')),
  started_at timestamptz default now(),
  completed_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists funnel.events (
  id uuid primary key default gen_random_uuid(),
  funnel_instance_id uuid not null references funnel.instances(id) on delete cascade,
  product_key text not null references funnel.products(product_key),
  stage_number int not null references funnel.stage_catalog(stage_number),
  stage_key text not null,
  status text not null check (status in ('pending','active','passed','failed','blocked')),
  input_payload jsonb not null default '{}'::jsonb,
  decision_payload jsonb not null default '{}'::jsonb,
  output_payload jsonb not null default '{}'::jsonb,
  evidence_id uuid,
  reality_state text not null default 'PARTIAL' check (reality_state in ('REAL','PARTIAL','PRETEND','BLOCKED')),
  next_stage_key text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists funnel.product_stage_maps (
  id uuid primary key default gen_random_uuid(),
  product_key text not null references funnel.products(product_key),
  stage_number int not null references funnel.stage_catalog(stage_number),
  product_specific_trigger text,
  product_specific_output jsonb not null default '{}'::jsonb,
  required_integrations text[] not null default '{}',
  monetisation_role text,
  active boolean default true,
  unique(product_key, stage_number)
);

create table if not exists funnel.agent_contracts (
  id uuid primary key default gen_random_uuid(),
  agent_key text unique not null,
  agent_name text not null,
  stage_numbers int[] not null,
  input_contract jsonb not null default '{}'::jsonb,
  output_contract jsonb not null default '{}'::jsonb,
  allowed_actions text[] not null default '{}',
  requires_hitl boolean default false,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists funnel.reality_evidence (
  id uuid primary key default gen_random_uuid(),
  product_key text not null,
  funnel_instance_id uuid,
  event_id uuid,
  evidence_type text not null,
  evidence_ref text,
  evidence_hash text,
  evidence_payload jsonb not null default '{}'::jsonb,
  reality_state text not null check (reality_state in ('REAL','PARTIAL','PRETEND','BLOCKED')),
  created_at timestamptz default now()
);

create or replace view funnel.v_product_funnel_readiness as
select
  p.product_key,
  p.product_name,
  count(psm.stage_number) filter (where psm.active) as mapped_stages,
  round((count(psm.stage_number) filter (where psm.active)::numeric / 12) * 100, 2) as readiness_percent,
  case
    when count(psm.stage_number) filter (where psm.active) = 12 then 'READY'
    when count(psm.stage_number) filter (where psm.active) >= 8 then 'AT_RISK'
    when count(psm.stage_number) filter (where psm.active) >= 1 then 'PARTIAL'
    else 'BLOCKED'
  end as readiness_state
from funnel.products p
left join funnel.product_stage_maps psm on p.product_key = psm.product_key
where p.active = true
group by p.product_key, p.product_name;
```

## 5. Stage Seed Data

```sql
insert into funnel.stage_catalog(stage_number, stage_key, stage_name, stage_question, default_agent_key)
values
(1,'problem_trigger','Problem Trigger','What pain or opportunity starts this?','trigger_agent'),
(2,'audience','Audience','Who enters?','audience_agent'),
(3,'entry_surface','Entry Surface','Where do they enter?','entry_agent'),
(4,'capture','Capture','What data is collected?','capture_agent'),
(5,'consent','Consent','What permission is needed?','consentx_agent'),
(6,'qualification','Qualification','How do we classify them?','qualification_agent'),
(7,'offer','Offer','What do we recommend?','offer_agent'),
(8,'conversion','Conversion','What payment, booking, or approval happens?','conversion_agent'),
(9,'provisioning','Provisioning','What gets created or assigned?','provisioning_agent'),
(10,'first_value','First Value','What proves it works quickly?','first_value_agent'),
(11,'evidence','Evidence','What gets logged or reported?','reality_ledger_agent'),
(12,'continuation','Continuation','What keeps them moving or paying?','continuation_agent')
on conflict(stage_number) do update set
stage_key = excluded.stage_key,
stage_name = excluded.stage_name,
stage_question = excluded.stage_question,
default_agent_key = excluded.default_agent_key;
```

## 6. Initial Product Mapping: Reading Buddy

| Stage | Reading Buddy Mapping |
|---|---|
| 1 | Parent, school, or student sees reading struggle, confidence drop, or twice-exceptional mismatch |
| 2 | Parent, teacher, school leader, tutor, student, provider |
| 3 | Reading Buddy website, school intake, provider referral, widget, QR, campaign |
| 4 | age/year level, reading issue, current support, consent actor, contact, learning context |
| 5 | parent/school/student consent; session or full longitudinal learning consent |
| 6 | classify by need, urgency, reading level, support pathway, NDIS/school/private route |
| 7 | free screener, paid report, subscription, school pilot, provider package |
| 8 | Stripe, booking, school/provider approval, research opt-in |
| 9 | create learner profile, assign Reading Buddy agent, generate first plan/report |
| 10 | first reading insight, confidence intervention, recommended next activity |
| 11 | outcome metric, report hash, Reality Ledger evidence, progress record |
| 12 | weekly progress loop, subscription, school report, next intervention, cross-sell to Outcome Ready |

## 7. Product Rollout Pattern

The system should onboard products in this order:

1. Reading Buddy
2. Outcome Ready
3. AI Sweet Spots
4. Augmented Humanity Coach
5. HoloOrg
6. ConsentX
7. MyNeuralSignal
8. LifeGraph+
9. WorkFamilyAI
10. Remaining product portfolio in groups of three

## 8. Command Centre Widget Spec

Widget: Universal Funnel Readiness

Required cards:
- total products
- products READY
- products AT_RISK
- products BLOCKED
- average readiness percent
- stage with highest drop-off
- stage with highest revenue contribution
- stage with weakest evidence

Required table columns:
- product_key
- product_name
- mapped_stages
- readiness_percent
- readiness_state
- current_revenue_stage
- top_blocker
- next_action
- reality_state

## 9. Bridge Runner Job Shape

Expected executor action:
- apply SQL to Supabase
- seed stage catalog
- seed first product mapping
- create Command Centre widget record
- log Reality Ledger evidence
- return execution receipt

Required proof:
- migration execution result
- row counts
- view query result
- widget creation result
- Reality Ledger evidence row

## 10. Reality Ledger Entry

task_id: universal_funnel_system_v1
intent: create reusable 12-stage product funnel system
execution: GitHub handoff created; Supabase execution pending bridge
output: canonical control doc + bridge job
status: PARTIAL
evidence: GitHub commit receipt required from connector response
score: 0.72 before runtime, target 0.95 after bridge execution

## 11. Hard Gaps Remaining

- Supabase SQL not yet executed in live project from this chat.
- Command Centre widget not yet deployed from this chat.
- Bridge Runner execution receipt pending.
- Reality Ledger live row pending.
- Stripe/booking/payment hooks not created here.

## 12. Next Required Action

Run the bridge job at `bridge_jobs/universal_funnel_system_v1.json`, then return receipts and upgrade state from PARTIAL to REAL only after database, widget, and ledger proof exist.
