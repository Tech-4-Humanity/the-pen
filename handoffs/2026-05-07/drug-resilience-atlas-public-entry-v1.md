# Drug Resilience Atlas — Public Entry V1 Handoff

Date: 2026-05-07
Owner: Troy Latter / Tech 4 Humanity
Target: The Pen → Dev inspection → Bridge execution → Prod candidate
Status: PARTIAL — build specification, launch copy, schema, endpoint contract, calculator discovery request prepared. Runtime deployment not proven in this handoff.

## Intent
Open the Drug Resilience Atlas to the public by starting with participation, debate, and survey-based signal capture rather than a closed dashboard-first release.

## Public Positioning
Public front door should use a safer broad frame:

- Human Resilience Atlas
- powered by the Drug Resilience Atlas research spine
- purpose: help people understand how humans respond differently to stress, substances, sleep, social pressure, medication, digital dependency, burnout, loneliness, gaming, AI companions, and recovery environments

## Core Public CTA
Primary: Take the Resilience Survey
Secondary: Join the Debate
Tertiary: Explore Public Signals

## Required Existing Dependency
The endpoint and calculator already exist. Dev must locate the DRA calculator before recreating anything.

Search terms:
- DRA calculator
- Drug Resilience Atlas calculator
- resilience calculator
- atlas calculator
- drug resilience
- behavioural resilience calculator
- calculator endpoint

Likely locations:
- GitHub repositories under TML-4PM or Tech4Humanity org/user installations
- Google Drive project docs
- Supabase edge functions / API notes
- Vercel/Lovable site code
- Bridge endpoint registry

## Build Surfaces

### 1. Public Landing Page
Sections:
- Hero: Humans respond differently. Help map why.
- Trust strip: Anonymous-first, evidence-aware, research-backed, support-oriented.
- CTAs: Take survey, Join debate, View signals.
- Three explanation cards: Resilience, Risk, Recovery.
- Debate preview.
- Survey preview.
- Public signal map preview.
- Safety/support footer.

### 2. Debate Engine
Structured topics. Not a free-for-all forum.

Initial topics:
1. Is burnout changing how people use alcohol, stimulants, medication, and screens?
2. Should AI companions be included in addiction and dependency research?
3. Are ADHD medications misunderstood in public debate?
4. Is loneliness now one of the strongest behavioural risk signals?
5. Should recovery systems measure resilience, not just relapse?
6. Are gaming, social media, vaping, and alcohol part of the same dopamine debate?
7. How should governments balance harm reduction, personal freedom, and public safety?
8. What protective factors matter most: sleep, community, purpose, routine, therapy, income, exercise?

Voting model:
- agree / disagree / unsure
- reason category
- confidence score
- optional anonymous story
- optional evidence link
- demographic/lens tags only with consent

### 3. Survey Engine
Short public survey with immediate output.

Modules:
- sleep and recovery
- stress and pressure
- social support
- digital intensity
- substance exposure categories
- medication context
- emotional regulation
- work/study environment
- financial pressure
- purpose/routine
- support access
- optional neurodivergence/lived-experience lens

Output:
- resilience profile
- protective factors
- pressure signals
- comparison cohort
- support resources
- shareable card

### 4. Data Capture
Minimum table spine:

```sql
create table if not exists public.dra_public_participants (
  id uuid primary key default gen_random_uuid(),
  consent_state text not null default 'anonymous' check (consent_state in ('anonymous','session','longitudinal')),
  country text,
  region text,
  age_band text,
  role_context text,
  neuro_lens text,
  created_at timestamptz default now()
);

create table if not exists public.dra_public_survey_responses (
  id uuid primary key default gen_random_uuid(),
  participant_id uuid references public.dra_public_participants(id),
  survey_version text not null default 'v1',
  response_json jsonb not null,
  resilience_score numeric,
  pressure_score numeric,
  protective_factor_score numeric,
  profile_label text,
  calculator_endpoint text,
  calculator_version text,
  classification text not null default 'PARTIAL' check (classification in ('REAL','PARTIAL','PRETEND','BLOCKED')),
  evidence_json jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists public.dra_public_debate_topics (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  description text,
  status text not null default 'active',
  created_at timestamptz default now()
);

create table if not exists public.dra_public_debate_responses (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references public.dra_public_debate_topics(id),
  participant_id uuid references public.dra_public_participants(id),
  stance text check (stance in ('agree','disagree','unsure','mixed')),
  reason_category text,
  confidence int check (confidence between 1 and 5),
  comment text,
  evidence_url text,
  classification text not null default 'PARTIAL' check (classification in ('REAL','PARTIAL','PRETEND','BLOCKED')),
  created_at timestamptz default now()
);
```

### 5. Calculator Endpoint Contract
Do not rebuild if existing endpoint is found. Wrap existing endpoint.

Expected request:

```json
{
  "survey_version": "v1",
  "participant_context": {
    "country": "AU",
    "age_band": "35-44",
    "role_context": "worker",
    "consent_state": "anonymous"
  },
  "responses": {
    "sleep_quality": 3,
    "stress_pressure": 4,
    "social_support": 2,
    "digital_intensity": 5,
    "substance_exposure": {},
    "recovery_behaviours": {},
    "support_access": {}
  }
}
```

Expected response:

```json
{
  "status": "ok",
  "calculator": "dra_resilience_calculator",
  "version": "existing-or-v1",
  "resilience_score": 0,
  "pressure_score": 0,
  "protective_factor_score": 0,
  "profile_label": "string",
  "explanation": [],
  "support_recommendations": [],
  "evidence": {
    "endpoint": "string",
    "runtime_id": "string",
    "timestamp": "string"
  }
}
```

### 6. Public Safety Rules
No instructions for acquiring, manufacturing, combining, or optimising illegal or harmful substance use.
No glorification.
No medical advice claims.
Always provide support/resource framing on high-risk content.
Use resilience, recovery, support, behaviour, context, and evidence language.

### 7. Stage Gates

Gate 1 — Calculator discovery
- Locate existing DRA calculator endpoint/code.
- Record endpoint URL or repo path.
- Classify as REAL only with typed evidence: URL, API response, code path, commit, or runtime receipt.

Gate 2 — Public landing + CTA
- Deploy public page with survey/debate CTAs.
- Evidence: URL + screenshot + commit.

Gate 3 — Survey write path
- Save anonymous response.
- Call calculator.
- Store calculator result.
- Evidence: DB row + API response.

Gate 4 — Debate write path
- Save structured debate response.
- Evidence: DB row + UI action receipt.

Gate 5 — Public signals
- Aggregate non-identifying results.
- Evidence: query output + public chart.

## Reality Ledger

task_id: dra-public-entry-v1
intent: open DRA to public through debate + survey + signal capture
execution: handoff created; runtime execution still required
output: public product spec, schema, endpoint contract, safety rules, stage gates
status: PARTIAL
evidence: GitHub commit receipt from this handoff required from create_file result
score: 0.62

gaps:
- existing DRA calculator not yet located in this handoff
- endpoint not yet verified
- public page not yet deployed
- survey/debate tables not yet applied
- API not smoke-tested
- no public URL evidence yet

next_action:
Dev/Pen must search repositories and Drive for existing DRA calculator, then wire public survey and debate surfaces to the existing calculator endpoint.

pressure_flags:
- do not rebuild calculator until search confirms missing
- keep public framing broad and safe
- avoid dashboard-first release
- prove every REAL claim with runtime evidence
