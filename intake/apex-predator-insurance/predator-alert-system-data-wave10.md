# Predator Alert System / Apex Predator Insurance — Data Completion Pack

Status: PARTIAL
Reason: Lovable app URL was supplied, but the backing source repository was not discoverable by GitHub search. This pack is therefore a complete Lovable-ready data and product specification, not a direct source-code patch.

Target site: https://predator-alert-system.lovable.app/
Commercial front-end: Apex Predator Insurance
Public-good layer: open-source wildlife interaction research and public safety intelligence

## 1. Existing site capability baseline

From the attached outstanding-actions note, the current Lovable system already has:

- Chart and visualisation functions: incident distribution, yearly trends, species counts, risk by species, region severity, time series, seasonal patterns, severity cards.
- Map functions: interactive Leaflet map, clustering, colour-coded markers, species-aware popups.
- Filter and search: text search, animal filters, warning/incident/accident/death stages, date range, status filters.
- Data processing: incident counts, severity averages, risk assessment, trend analysis, hotspot detection.
- UI utilities: animal colours, stage colours, badges, border styles, date formatting, 15-species database.
- Data management: GNews API fallback, React Query cache, 30-minute polling, manual refresh, rate-limit handling.

The outstanding gaps are:

- Predictive modelling.
- Weather and season correlation.
- Population density and tourism correlation.
- Economic impact calculation.
- Threat escalation calculation.
- PDF/Excel exports.
- Email/push/live ticker/emergency broadcasts.
- Social/news integration expansion.
- Composite risk score.
- Insurance premium calculator.
- Travel advisory generator.
- Incident probability model.
- Better free data sources.

## 2. Strategic product architecture

This must become two products sharing one data spine.

### A. Open Wildlife Signal Commons

Purpose: public-good, reusable, open-source human-wildlife interaction dataset.

Users:
- wildlife researchers
- schools and educators
- conservation groups
- journalists
- councils and public safety bodies
- travel operators
- NGOs
- citizen scientists

Outputs:
- open dataset
- public dashboards
- species explainers with confidence scores
- incident maps
- seasonal and regional advisories
- downloadable research packs
- public API later

### B. Apex Predator Insurance Intelligence Layer

Purpose: commercial marketing, conversion, pricing signal, campaign timing, product packaging.

Users:
- customers
- insurers/reinsurers
- travel brands
- tourism operators
- event organisers
- councils
- adventure/outdoor platforms

Outputs:
- risk-led landing pages
- animal/product campaign mapping
- campaign timing engine
- halt engine
- micro-cover product concepts
- lead capture
- API licensing
- partner widgets

## 3. Animal data model — 85 animal registry

Every animal must be a signal node.

Required fields:

```sql
animal_id uuid primary key
slug text unique not null
common_name text not null
scientific_name text
animal_group text -- mammal, reptile, fish, bird, insect, arachnid, marine, mythical/brand-only
predator_class text -- apex, mesopredator, defensive, venomous, nuisance, environmental-risk, fictional
primary_regions text[]
habitat_types text[]
conservation_status text
human_interaction_modes text[] -- bite, sting, collision, predation, disease, property damage, panic, economic disruption
fear_index int check 0-100
meme_index int check 0-100
media_index int check 0-100
insurance_relevance_score int check 0-100
public_education_priority int check 0-100
marketing_safe boolean default true
commercial_use_notes text
research_use_notes text
created_at timestamptz default now()
updated_at timestamptz default now()
```

## 4. Interaction graph

Do not treat animals as isolated facts. The saleable and research-worthy unit is interaction.

```sql
interaction_id uuid primary key
animal_id uuid references animals(animal_id)
secondary_actor_type text -- human, pet, livestock, vehicle, crop, infrastructure, another_animal, tourist_group
secondary_actor_detail text
interaction_type text -- attack, bite, sting, collision, encounter, sighting, disease, nuisance, property_damage, conservation_conflict
activity_context text -- swimming, surfing, hiking, camping, driving, farming, boating, backyard, school, tourism
region_id uuid
seasonality_id uuid
probability_score numeric
severity_score numeric
media_velocity_score numeric
confidence_score numeric
commercial_relevance_score numeric
public_safety_relevance_score numeric
recommended_action text
halt_conditions text
last_observed_at timestamptz
```

## 5. Incident table

```sql
incident_id uuid primary key
source_id uuid
animal_id uuid
interaction_id uuid
title text
description text
incident_stage text -- warning, sighting, incident, accident, injury, fatality, resolved, hoax, duplicate
incident_status text -- active, monitoring, resolved, halted
occurred_at timestamptz
reported_at timestamptz
country text
region text
locality text
latitude numeric
longitude numeric
location_precision text -- exact, suburb, regional, country_only, unknown
human_context text
outcome text
injury_count int
fatality_count int
property_damage_estimate numeric
economic_impact_estimate numeric
source_url text
source_type text -- news, gov, research, social, citizen, ngo
source_reliability_score numeric
confidence_score numeric
verification_status text -- unverified, corroborated, verified, rejected
created_at timestamptz default now()
```

## 6. Signal scoring engine

Core formula:

```text
signal_score =
  (media_volume * 0.20)
+ (media_velocity * 0.20)
+ (severity_score * 0.20)
+ (seasonality_boost * 0.15)
+ (geo_relevance * 0.10)
+ (confidence_score * 0.10)
+ (meme_multiplier * 0.05)
```

Risk score:

```text
risk_score =
  (incident_probability * 0.25)
+ (severity_score * 0.25)
+ (exposure_score * 0.20)
+ (environmental_conditions * 0.15)
+ (response_gap_score * 0.15)
```

Commercial score:

```text
commercial_score =
  (signal_score * 0.25)
+ (meme_index * 0.15)
+ (fear_index * 0.15)
+ (insurance_relevance_score * 0.25)
+ (campaign_timing_score * 0.20)
```

## 7. Campaign cycle engine

States:

- DETECT: signal exists but confidence or volume is low.
- RISE: signal is accelerating; publish education and soft content.
- PEAK: signal is high-confidence and time-sensitive; run conversion campaigns.
- DECAY: signal is falling; run retargeting, recap, and educational follow-up.
- HALT: campaign must stop.

Campaign transition rules:

```text
DETECT -> RISE if signal_score >= 40 and confidence_score >= 55
RISE -> PEAK if signal_score >= 70 and media_velocity >= 60
PEAK -> DECAY if signal_score falls by 30% over rolling 72h
ANY -> HALT if confidence_score < 35, sentiment risk > 70, regulatory risk true, tragedy sensitivity true, or fatigue score > 80
DECAY -> HALT after 7 days or signal_score < 25
```

## 8. Halt engine

Halt is a first-class feature.

Halt reasons:

- factual uncertainty
- duplicate/hoax risk
- active human tragedy
- legal/regulatory concern
- conservation sensitivity
- cultural sensitivity
- campaign fatigue
- low conversion
- signal decay
- partner request

Required table:

```sql
campaign_halts (
  halt_id uuid primary key,
  campaign_id uuid,
  halt_reason text,
  halt_trigger text,
  halted_at timestamptz default now(),
  halted_by text,
  restart_conditions text,
  evidence_url text
)
```

## 9. Free useful data sources to prioritise

Use only lawful, attributable sources.

Initial source classes:

- GDELT global news/event data.
- GNews or equivalent news API already present.
- Government wildlife incident reports.
- IUCN Red List status references.
- GBIF species occurrence data.
- eBird for bird signals.
- iNaturalist observations where licensing permits.
- NOAA / BOM / national weather agencies.
- OpenStreetMap for beaches, parks, roads, hospitals, trails.
- WorldPop / census-style population density.
- Wikidata for species metadata.
- Wikipedia summaries only as low-confidence explainer seed, not incident truth.

## 10. Dashboard modules needed on Lovable site

### Public dashboard

- Global incident map.
- Top animals by active signal.
- Top interactions by region.
- Seasonal risk calendar.
- Open research download panel.
- Confidence score explainer.
- Submit/verify incident form.
- Conservation-sensitive disclaimer.

### Commercial dashboard

- Campaign cycle state by animal.
- Product SKU mapping by interaction.
- Revenue/conversion by animal.
- Halted campaigns.
- Active regions.
- Signal-to-sale funnel.
- Partner leads.
- API demand.

### Research dashboard

- Source coverage.
- Verification status.
- Data quality score.
- Open-source export logs.
- Research gaps by region/species.
- Expert review queue.

## 11. Lovable implementation prompt

Paste this into Lovable as the site update prompt:

```text
Update predator-alert-system.lovable.app into a dual-layer Wildlife Signal Commons + Apex Predator Insurance intelligence site.

Preserve existing charts, maps, filters, React Query polling, GNews fallback, animal popups, severity cards, and existing T4H branding work.

Add three top-level modes:
1. Public Wildlife Signal Commons
2. Apex Predator Insurance Intelligence
3. Research / Open Data Lab

Add/extend data models for animals, interactions, incidents, signal scores, risk scores, campaign cycles, campaign halts, sources, regions, weather context, seasonality, exports, and contribution reports.

Every animal must be treated as a signal node. Expand from the current 15 species database toward an 85-animal registry. Each animal needs common name, scientific name, group, predator class, regions, habitats, human interaction modes, fear index, meme index, media index, insurance relevance score, public education priority, conservation status, marketing_safe, commercial notes, and research notes.

Create an interaction graph where the core unit is animal + human/pet/livestock/vehicle/infrastructure/activity context. Add scores for probability, severity, media velocity, confidence, commercial relevance, and public-safety relevance.

Add composite calculators:
- signal score
- risk score
- commercial campaign score
- incident probability score
- economic impact estimate
- insurance relevance score
- source confidence score

Add campaign cycle states: DETECT, RISE, PEAK, DECAY, HALT. Show cycle state visually on cards and dashboards. Add HALT as a first-class system with reason, trigger, timestamp, evidence URL, and restart conditions.

Add dashboards:
- Public: global map, top animals, top interactions, seasonal calendar, open data download, confidence explainer, report incident form.
- Commercial: campaign cycle by animal, SKU mapping, conversion placeholders, halted campaigns, signal-to-sale funnel.
- Research: source coverage, verification status, data quality score, open export log, research gaps, expert review queue.

Add exports:
- CSV export for animals, interactions, incidents, signals, campaigns, and research gaps.
- JSON export for API-ready data.
- PDF-style report view generated as printable HTML.

Add alert components:
- live ticker
- regional alert cards
- advisory generator
- social/news signal panel
- emergency broadcast placeholder with clear disclaimer that it is not an official emergency service.

Add monetisation components:
- free public dataset tier
- traveller pro tier
- industry intelligence tier
- enterprise/API licensing tier
- partner widget licensing
- research sponsorship
- insurance lead capture

Add clear disclaimers:
- open data is informational and confidence-scored
- not official emergency advice
- wildlife conservation and human safety both matter
- no encouragement of animal harm

Use dense, content-rich copy. Avoid a thin demo feel. Make the site feel like a serious global wildlife intelligence platform with a cheeky Apex Predator commercial edge.
```

## 12. Seed animal groups for the 85 registry

Build the 85 from these clusters:

- Sharks: great white, tiger, bull, hammerhead, oceanic whitetip.
- Crocodilians: saltwater crocodile, Nile crocodile, American alligator, caiman.
- Big cats: lion, tiger, leopard, jaguar, cougar, snow leopard.
- Bears: polar, grizzly, black, sloth bear.
- Canids/hyenas: wolf, dingo, coyote, spotted hyena, African wild dog.
- Marine mammals: orca, leopard seal, sea lion.
- Large herbivore danger: hippo, elephant, rhino, buffalo, bison, moose, camel, kangaroo, cassowary.
- Venomous snakes: inland taipan, coastal taipan, eastern brown, black mamba, king cobra, rattlesnake, viper.
- Constrictors: anaconda, reticulated python.
- Venomous arthropods: funnel-web spider, redback, black widow, scorpion, cone snail, box jellyfish, blue-ringed octopus.
- Birds/air risk: magpie, eagle, owl, goose, emu, cassowary.
- Human conflict species: wild boar, feral dog, monkey, raccoon, fox, rat.
- Disease vectors: mosquito, tick, bat.
- Ocean/river risk: piranha, stonefish, lionfish, stingray, barracuda.
- Brand/comedy/extreme: drop bear, apex accountant, litigation leopard, compliance crocodile, budget blowout buffalo.

## 13. Monetisation model

Free:
- public map
- latest 30-day incidents
- limited species profiles
- open data samples
- education explainers

Traveller Pro:
- custom regions
- trip watchlists
- full species profiles
- printable risk reports
- SMS/email alerts

Industry Intelligence:
- API access
- historical data exports
- predictive scores
- dashboard builder
- white-label widgets

Enterprise:
- custom risk feeds
- partner integration
- tourism/council/insurer dashboards
- SLA support
- custom research reports

Research sponsorship:
- sponsor a species
- sponsor a region
- sponsor a conservation data pack
- university/NGO collaboration packs

## 14. Evidence and execution ledger

task_id: apex_predator_predator_alert_data_wave10
intent: Complete all needs for Predator Alert System Lovable data update and Apex Predator Insurance open wildlife intelligence model.
execution: Created this GitHub PEN handoff because source repository was not discoverable from available connector search.
output: Lovable-ready product/data architecture, schemas, scoring formulas, cycle/halt logic, dashboards, data sources, monetisation model, and implementation prompt.
status: PARTIAL
evidence: GitHub file creation receipt from connector.
gaps:
- Backing Lovable code repository not found.
- No direct patch applied to the live Lovable source.
- Live web verification unavailable in this execution path.
next_action:
- Paste Lovable implementation prompt into the Lovable project, or provide/connect the backing GitHub repo and apply this as code/schema changes.
- Load 85-animal CSV seed into the Lovable/Supabase backend.
- Add export, alert, scoring, and halt UI components.
elevation:
- Converted a marketing animal list into a reusable open wildlife intelligence data spine plus commercial Apex Predator monetisation layer.
pressure_flags:
- no_source_repo_found
- direct_lovable_patch_blocked
score: 0.82
```
