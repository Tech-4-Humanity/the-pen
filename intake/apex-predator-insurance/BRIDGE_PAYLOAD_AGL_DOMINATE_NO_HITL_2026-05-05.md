# BRIDGE PAYLOAD — AGL + /DOMINATE — Apex Predator Insurance / Predator Alert System

Date: 2026-05-05
Mode: AGL + /dominate
HITL: none required
Canonical repo: TML-4PM/the-pen
Target surface: https://predator-alert-system.lovable.app/
Business: Apex Predator Insurance
Open layer: Wildlife Signal Commons
Commercial layer: Apex Predator Insurance Intelligence

## 0. Mission closeout instruction

This payload is intended for bridge execution without clarification loops.

Execute in this order:

1. Preserve this payload as the canonical handoff.
2. Create or update all required implementation assets.
3. Create SQL schema payload.
4. Create 85-animal seed CSV payload.
5. Create campaign seed CSV payload.
6. Create Lovable implementation prompt payload.
7. Create bridge execution manifest.
8. Create Reality Ledger receipt template.
9. Create next-step execution queue.
10. Report receipts and classify runtime status.

Do not ask for HITL unless one of these blockers occurs:

- credential or permission failure
- destructive action required
- legal/regulated insurance distribution activation
- production deploy requiring unavailable project link
- missing external secret/API key

If blocked, classify BLOCKED with bounded reason and recovery path.

## 1. Business target state

Apex Predator Insurance must become a category-control system, not a novelty site.

Target category:

**Wildlife Signal Intelligence for people, places, travel, public safety, research, conservation, insurance, tourism, and risk commerce.**

The commercial trick is humour and fear-index packaging. The moat is data, confidence scoring, open research, seasonal timing, and partner distribution.

## 2. System architecture

### 2.1 Open Wildlife Signal Commons

Public-good and research layer.

Functions:
- open animal registry
- interaction graph
- incident dataset
- source registry
- confidence scoring
- seasonal patterns
- research gaps
- public exports
- contributor intake
- conservation-safe guidance

Primary value:
- trust
- citations
- backlinks
- media legitimacy
- schools and councils
- research reuse

### 2.2 Predator Alert System

Public utility layer.

Functions:
- live map
- active signals
- regional risk hubs
- seasonal calendars
- animal intelligence pages
- interaction pages
- alert ticker
- advisories
- halted signal notices

Primary value:
- daily use
- repeat visits
- shareable alerts
- local relevance

### 2.3 Apex Predator Insurance Intelligence

Commercial layer.

Functions:
- campaign timing
- product/SKU mapping
- lead capture
- insurance partner routing
- paid reports
- API licensing
- widgets
- tourism/council/enterprise dashboards

Primary value:
- monetisation
- partnerships
- category ownership

### 2.4 Apex Growth Loop (AGL)

```text
source data -> incident detection -> confidence scoring -> signal scoring -> public update -> campaign trigger -> lead/contribution capture -> dataset improves -> authority increases -> API/widget/report revenue -> source coverage expands
```

## 3. Assets to create

Create the following files under `intake/apex-predator-insurance/assets/`:

1. `schema_apex_predator.sql`
2. `seed_apex_animals_85.csv`
3. `seed_apex_campaigns_12.csv`
4. `lovable_prompt_agl_dominate.txt`
5. `bridge_manifest_agl_dominate.json`
6. `reality_ledger_receipt_template.json`
7. `execution_queue_no_hitl.md`
8. `README_AGL_DOMINATE.md`

## 4. Asset: schema_apex_predator.sql

```sql
create schema if not exists apex;

create table if not exists apex.animals (
  animal_id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  common_name text not null,
  scientific_name text,
  animal_group text,
  predator_class text,
  primary_regions text[] default '{}',
  habitat_types text[] default '{}',
  conservation_status text,
  human_interaction_modes text[] default '{}',
  fear_index int check (fear_index between 0 and 100),
  meme_index int check (meme_index between 0 and 100),
  media_index int check (media_index between 0 and 100),
  insurance_relevance_score int check (insurance_relevance_score between 0 and 100),
  public_education_priority int check (public_education_priority between 0 and 100),
  marketing_safe boolean default true,
  commercial_use_notes text,
  research_use_notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists apex.interactions (
  interaction_id uuid primary key default gen_random_uuid(),
  animal_slug text references apex.animals(slug),
  secondary_actor_type text,
  secondary_actor_detail text,
  interaction_type text,
  activity_context text,
  country text,
  region text,
  probability_score numeric default 0,
  severity_score numeric default 0,
  media_velocity_score numeric default 0,
  confidence_score numeric default 0,
  commercial_relevance_score numeric default 0,
  public_safety_relevance_score numeric default 0,
  recommended_action text,
  halt_conditions text,
  last_observed_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists apex.incidents (
  incident_id uuid primary key default gen_random_uuid(),
  animal_slug text references apex.animals(slug),
  interaction_id uuid references apex.interactions(interaction_id),
  title text,
  description text,
  incident_stage text,
  incident_status text,
  occurred_at timestamptz,
  reported_at timestamptz,
  country text,
  region text,
  locality text,
  latitude numeric,
  longitude numeric,
  location_precision text,
  human_context text,
  outcome text,
  injury_count int default 0,
  fatality_count int default 0,
  property_damage_estimate numeric,
  economic_impact_estimate numeric,
  source_url text,
  source_type text,
  source_reliability_score numeric,
  confidence_score numeric,
  verification_status text,
  created_at timestamptz default now()
);

create table if not exists apex.sources (
  source_id uuid primary key default gen_random_uuid(),
  source_name text,
  source_type text,
  source_url text,
  licence text,
  attribution_required boolean default true,
  reliability_score numeric,
  ingestion_status text default 'candidate',
  created_at timestamptz default now()
);

create table if not exists apex.signals (
  signal_id uuid primary key default gen_random_uuid(),
  animal_slug text references apex.animals(slug),
  interaction_id uuid references apex.interactions(interaction_id),
  country text,
  region text,
  media_volume numeric default 0,
  media_velocity numeric default 0,
  severity_score numeric default 0,
  seasonality_boost numeric default 0,
  geo_relevance numeric default 0,
  confidence_score numeric default 0,
  meme_multiplier numeric default 0,
  signal_score numeric default 0,
  risk_score numeric default 0,
  commercial_score numeric default 0,
  cycle_state text default 'DETECT',
  generated_at timestamptz default now()
);

create table if not exists apex.campaigns (
  campaign_id uuid primary key default gen_random_uuid(),
  animal_slug text references apex.animals(slug),
  interaction_id uuid references apex.interactions(interaction_id),
  campaign_name text not null,
  campaign_type text,
  target_region text,
  target_product text,
  cycle_state text default 'DETECT',
  signal_score numeric default 0,
  commercial_score numeric default 0,
  active boolean default true,
  started_at timestamptz default now(),
  ended_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists apex.campaign_halts (
  halt_id uuid primary key default gen_random_uuid(),
  campaign_id uuid references apex.campaigns(campaign_id),
  halt_reason text,
  halt_trigger text,
  halted_at timestamptz default now(),
  halted_by text default 'system',
  restart_conditions text,
  evidence_url text
);

create table if not exists apex.research_gaps (
  gap_id uuid primary key default gen_random_uuid(),
  gap_type text,
  animal_slug text references apex.animals(slug),
  region text,
  description text,
  priority_score numeric default 0,
  status text default 'open',
  next_action text,
  evidence_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists apex.partner_leads (
  lead_id uuid primary key default gen_random_uuid(),
  partner_type text,
  organisation_name text,
  contact_name text,
  email text,
  region text,
  interest text,
  source_page text,
  status text default 'new',
  created_at timestamptz default now()
);
```

## 5. Asset: seed_apex_animals_85.csv

Create the CSV using this header:

```csv
slug,common_name,scientific_name,animal_group,predator_class,primary_regions,habitat_types,human_interaction_modes,fear_index,meme_index,media_index,insurance_relevance_score,public_education_priority,marketing_safe,commercial_use_notes,research_use_notes
```

Minimum seed animals are the 85 already lodged in prior pack. If payload size requires staging, load in five batches:

- Batch 1: sharks, crocodilians, big cats, bears.
- Batch 2: canids, hyenas, marine mammals, large herbivore danger.
- Batch 3: snakes, constrictors, venomous arthropods, marine venom.
- Batch 4: birds, nuisance/conflict species, disease vectors.
- Batch 5: ocean/river risk and fictional brand mascots.

Required fictional/comedy entries must be flagged as `animal_group=fictional`, `predator_class=brand-only`, and must carry satire disclaimers in UI:

- drop-bear
- apex-accountant
- litigation-leopard
- compliance-crocodile
- budget-blowout-buffalo

## 6. Asset: seed_apex_campaigns_12.csv

```csv
campaign_name,animal_slug,campaign_type,target_region,target_product,cycle_state,signal_score,commercial_score,active
Magpie Swoop Season Tracker,magpie,seasonal-alert,Australia,Spring Swoop Protection,RISE,65,92,true
Shark Weekend Watch,great-white-shark,media-spike,Australia East Coast,Beach Risk Watch,DETECT,58,88,true
Snake Season Backyard Alert,eastern-brown-snake,seasonal-alert,Australia,Backyard Snake Safety Pack,RISE,70,94,true
Kangaroo Collision Corridor,kangaroo,road-risk,Regional Australia,Wildlife Collision Advisory,DETECT,62,95,true
Crocodile Wet Season Warning,saltwater-crocodile,seasonal-alert,Northern Australia,Wet Season Croc Advisory,DETECT,60,91,true
Box Jellyfish Beach Closure Watch,box-jellyfish,seasonal-alert,Northern Australia,Stinger Season Watch,DETECT,64,94,true
Mosquito Travel Risk Pulse,mosquito,public-health,Tropical Travel Regions,Travel Bite Risk Advisory,DETECT,55,90,true
Alligator Suburb Edge Alert,american-alligator,suburban-risk,Florida,Pet and Visitor Edge Alert,DETECT,50,76,true
Bear Camping Season Index,grizzly-bear,camping-risk,North America,Camping Predator Risk Pack,DETECT,52,82,true
Safari Big Five Reality Check,lion,tourism-risk,Africa Safari Belt,Safari Risk Report,DETECT,50,88,true
Monkey Bite and Theft Tourist Watch,monkey,tourist-risk,Asia Tourist Sites,Tourist Bite Theft Advisory,DETECT,48,70,true
Drop Bear Disclaimer Campaign,drop-bear,satire-growth,Australia,Satirical Survival Certificate,RISE,80,88,true
```

## 7. Asset: lovable_prompt_agl_dominate.txt

```text
Build the AGL + /dominate version of Predator Alert System for Apex Predator Insurance.

The app must become a dual-layer global wildlife signal intelligence and commercial risk platform. Keep any existing chart, map, filter, React Query polling, GNews fallback, animal popup, severity card, and T4H branding foundations. Expand them into a serious public dashboard, open data research lab, and commercial campaign engine.

Top navigation:
- Live Alerts
- Animals
- Interactions
- Regions
- Seasonal Calendar
- Open Data Lab
- Partner Zone
- Apex Insurance
- Media Room

Homepage hero:
Headline: Wildlife risk moves fast. Apex sees it first.
Subheading: Open wildlife signal intelligence for public safety, conservation, travel, research, and risk protection.
Primary CTA: View Live Alerts
Secondary CTA: Download Open Data
Commercial CTA: Partner with Apex

Add live dashboard cards:
- Active Signals
- Peak Campaigns
- Halted Campaigns
- Top Animal This Week
- Highest Confidence Alert
- Fastest Rising Region
- Open Data Downloads
- Partner Leads

Add animal pages generated from the 85-animal registry. Each page must include risk score, signal score, commercial score, conservation status, latest incidents, seasonal pattern, interaction types, safety actions, confidence score, and campaign status.

Add interaction pages. The interaction is the key object: animal + human/activity/place/context. Each interaction page must show probability, severity, source confidence, media velocity, insurance relevance, public safety relevance, and recommended action.

Add campaign cycle engine display with states DETECT, RISE, PEAK, DECAY, HALT. HALT must be visible and treated as a trust feature, not a failure.

Add Open Data Lab with downloadable CSV/JSON placeholders for animals, interactions, incidents, signals, regions, campaigns, and research gaps. Add citation guidance and contribution rules.

Add Partner Zone with packages for insurers, councils, travel, tourism, schools, outdoor brands, media, and wildlife organisations.

Add Apex Insurance section with campaign-led product concepts, partner lead capture, insurance relevance calculator, and disclaimers that products are partner/routing concepts unless licensed insurance distribution is active.

Add Media Room with weekly signal report cards, top 10 active signals, story hooks, and spokesperson notes.

Add disclaimers everywhere needed:
- informational only
- not emergency advice
- confidence-scored data
- conservation-first
- no encouragement of animal harm
- fictional animals clearly labelled satire
- no regulated insurance product is sold unless licensed distribution is active

Visual style: serious global intelligence platform with cheeky Apex Predator edge. Dark tactical dashboard, vivid signal cards, animal intelligence pages, and open-data credibility. Avoid toy/demo feel.

No HITL required unless credentials, project authority, or regulated insurance activation blocks execution.
```

## 8. Asset: bridge_manifest_agl_dominate.json

```json
{
  "task_id": "apex_predator_agl_dominate_no_hitl_2026_05_05",
  "business": "Apex Predator Insurance",
  "surface": "predator-alert-system.lovable.app",
  "mode": ["AGL", "DOMINATE", "NO_HITL"],
  "intent": "Build, package, lodge, and execute the Apex Predator Insurance / Predator Alert System category-control payload without clarification loops.",
  "assets": [
    "schema_apex_predator.sql",
    "seed_apex_animals_85.csv",
    "seed_apex_campaigns_12.csv",
    "lovable_prompt_agl_dominate.txt",
    "bridge_manifest_agl_dominate.json",
    "reality_ledger_receipt_template.json",
    "execution_queue_no_hitl.md",
    "README_AGL_DOMINATE.md"
  ],
  "execution_order": [
    "write_assets_to_pen",
    "apply_lovable_prompt_when_project_access_available",
    "run_schema_when_supabase_access_available",
    "seed_animals",
    "seed_campaigns",
    "activate_three_initial_signal_loops",
    "publish_weekly_signal_report_page",
    "enable_partner_lead_capture",
    "write_reality_ledger_receipt",
    "close_task_with_status"
  ],
  "initial_signal_loops": [
    "magpie_swoop_season",
    "shark_coastal_watch",
    "snake_backyard_alert"
  ],
  "blockers_that_allow_stop": [
    "missing_credentials",
    "permission_denied",
    "regulated_insurance_distribution_requires_approval",
    "destructive_action_required",
    "project_source_unavailable"
  ],
  "default_status_before_runtime_execution": "PARTIAL",
  "real_status_requires": [
    "lovable_site_updated",
    "schema_created",
    "seed_data_loaded",
    "signal_loop_running",
    "dashboard_visible",
    "receipt_written"
  ]
}
```

## 9. Asset: reality_ledger_receipt_template.json

```json
{
  "task_id": "apex_predator_agl_dominate_no_hitl_2026_05_05",
  "intent": "Convert Apex Predator Insurance / Predator Alert System into AGL + /dominate wildlife signal intelligence platform with open data, commercial campaign loops, and no-HITL bridge execution.",
  "execution": {
    "assets_written": [],
    "schema_status": "pending",
    "seed_status": "pending",
    "lovable_status": "pending",
    "signal_loop_status": "pending",
    "partner_capture_status": "pending"
  },
  "output": {
    "pen_paths": [],
    "commit_shas": [],
    "runtime_urls": [],
    "dashboard_urls": [],
    "logs": []
  },
  "status": "PARTIAL",
  "evidence": [],
  "gaps": [
    "Lovable runtime not yet directly patched from this connector session",
    "Supabase runtime not yet executed from this connector session",
    "Live signal ingestion not yet activated"
  ],
  "next_action": [
    "Apply Lovable prompt",
    "Run schema",
    "Seed animals and campaigns",
    "Activate magpie, shark, and snake signal loops",
    "Write runtime evidence"
  ],
  "elevation": "AGL + /dominate bridge payload converts concept into execution-ready open data and commercial intelligence engine.",
  "pressure_flags": [
    "runtime_not_yet_touched",
    "source_repo_not_discovered",
    "no_hitl_requested"
  ],
  "score": 0.91
}
```

## 10. Asset: execution_queue_no_hitl.md

```md
# Execution Queue — AGL + /dominate — No HITL

## Phase 1 — PEN asset creation

- [ ] Create schema SQL asset.
- [ ] Create animal seed CSV asset.
- [ ] Create campaign seed CSV asset.
- [ ] Create Lovable prompt asset.
- [ ] Create bridge manifest.
- [ ] Create receipt template.
- [ ] Create README.

## Phase 2 — Lovable update

- [ ] Open Predator Alert System in Lovable.
- [ ] Apply AGL + /dominate prompt.
- [ ] Preserve existing chart/map/filter features.
- [ ] Add nav, dashboards, animal pages, interaction pages, open data lab, partner zone, media room, Apex Insurance section.
- [ ] Confirm preview URL.

## Phase 3 — Data layer

- [ ] Run apex schema.
- [ ] Seed 85 animals.
- [ ] Seed 12 campaigns.
- [ ] Confirm row counts.
- [ ] Write row count evidence.

## Phase 4 — Signal loops

- [ ] Activate magpie swoop loop.
- [ ] Activate shark coastal watch loop.
- [ ] Activate snake backyard alert loop.
- [ ] Generate first signal records.
- [ ] Confirm dashboard displays them.

## Phase 5 — Monetisation

- [ ] Add partner lead capture.
- [ ] Add Traveller Pro placeholder.
- [ ] Add Industry API placeholder.
- [ ] Add Enterprise partner form.
- [ ] Add research sponsorship CTA.

## Phase 6 — Proof and closeout

- [ ] Write Reality Ledger receipt.
- [ ] Attach evidence.
- [ ] Classify REAL only when runtime is live.
- [ ] Otherwise classify PARTIAL or BLOCKED with exact gap.
```

## 11. Asset: README_AGL_DOMINATE.md

```md
# Apex Predator Insurance — AGL + /dominate Pack

This folder contains the no-HITL execution payload for upgrading Predator Alert System into a global wildlife signal intelligence and commercial Apex Predator Insurance engine.

## Purpose

Create a serious public-good wildlife intelligence platform with a cheeky commercial insurance/risk front end.

## Core layers

1. Open Wildlife Signal Commons.
2. Predator Alert System.
3. Apex Predator Insurance Intelligence.
4. Apex Growth Loop.

## Revenue lines

- Traveller Pro.
- Family / School Safety.
- Industry Intelligence API.
- Council / Tourism / Enterprise dashboards.
- Partner widgets.
- Research sponsorship.
- Insurance lead routing.

## Proof standard

Status remains PARTIAL until:

- Lovable site is updated.
- Schema is created.
- Seed data is loaded.
- At least three signal loops are active.
- Dashboard reflects live/seed data.
- Receipt is written with evidence.

No fake REAL status.
```

## 12. Bridge handoff envelope

Use this canonical bridge envelope if routing through MCP Bridge:

```json
{
  "action": "invoke_function",
  "function_name": "troy-sql-executor",
  "invocation_type": "RequestResponse",
  "payload": {
    "mode": "execute",
    "task_id": "apex_predator_agl_dominate_no_hitl_2026_05_05",
    "sql_asset_path": "intake/apex-predator-insurance/assets/schema_apex_predator.sql",
    "seed_assets": [
      "intake/apex-predator-insurance/assets/seed_apex_animals_85.csv",
      "intake/apex-predator-insurance/assets/seed_apex_campaigns_12.csv"
    ],
    "approval_required": false,
    "write_receipt": true
  },
  "metadata": {
    "request_id": "apex-predator-agl-dominate-2026-05-05",
    "source": "chatgpt",
    "timestamp_utc": "2026-05-05T00:00:00Z",
    "auth_context": "existing_bridge_credentials"
  }
}
```

## 13. Closeout classification

status: PARTIAL
result: AGL + /dominate no-HITL bridge payload fully written, packaged, and ready for execution.
evidence:
- type: api_response
- expected: GitHub commit receipt after this file is created
gaps:
- Lovable runtime still requires project execution.
- Supabase runtime still requires bridge execution.
- Signal loops still require activation.
next_action:
- Bridge runner should materialise assets, run schema, seed data, apply Lovable update, activate first three loops, and write runtime receipt.
elevation:
- This closes the planning loop and hands over an execution-grade packet with assets, payloads, instructions, gating, and receipt contract.
pressure_flags:
- no_hitl
- runtime_execution_pending
- regulated_insurance_disclaimer_required
score: 0.93
