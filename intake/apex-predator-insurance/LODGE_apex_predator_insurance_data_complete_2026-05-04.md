# LODGED: Apex Predator Insurance / Predator Alert System Data Completion Pack

Date: 2026-05-04
Target site: https://predator-alert-system.lovable.app/
Canonical lodging repo: TML-4PM/the-pen

## Executive outcome

Apex Predator Insurance now has a complete data, campaign, research, and monetisation architecture for updating the Lovable Predator Alert System site. The site should evolve from a chart/map demo into a dual-layer platform:

1. Open Wildlife Signal Commons — public-good, reusable, open-source wildlife interaction intelligence.
2. Apex Predator Insurance Intelligence — commercial campaign, timing, product, and partner monetisation engine.

This pack completes the missing data needs for 85 animals, their interactions, incident capture, signal scoring, campaign cycles, halt rules, dashboards, exports, alerts, and monetisation.

## Current attached baseline from Lovable review

Existing capabilities identified:

- Incident charts: pie charts, yearly trend bars, species incident counts, species risk, predator alerts.
- Region charts: incident count by region and severity by region.
- Time series: yearly, seasonal, and severity trends.
- Interactive Leaflet map with clustering and species-aware popups.
- Filters: text search, animal filters, stage filters, date range, active/monitoring/resolved status.
- Data processing: statistics, severity averages, risk by species/region, trend detection, hotspots.
- UI utilities: animal colours, stage colours, status badges, date helpers, stage config.
- Data management: GNews API fallback, React Query cache, 30-minute polling, manual refresh, rate-limit fallback.

Missing capabilities that this lodging closes at design/data level:

- Predictive modelling.
- Weather/season correlation calculators.
- Population density and tourism exposure overlays.
- Economic impact calculators.
- Threat level escalation.
- PDF/CSV/Excel/JSON export.
- Email/push/live ticker/emergency-style advisories.
- Social and expanded news ingestion.
- Composite risk score.
- Insurance premium/relevance calculator.
- Travel advisory generator.
- Statistical probability model.
- Open data/public research packaging.

## Product spine

### Public layer: Open Wildlife Signal Commons

Purpose:
A globally reusable, open-source human-wildlife interaction dataset and public intelligence layer.

Primary users:
- Wildlife researchers.
- Conservation organisations.
- Councils and public-safety teams.
- Schools and educators.
- Travel operators.
- Journalists.
- Citizen scientists.

Primary outputs:
- Open incident dataset.
- Animal and interaction registry.
- Seasonal risk calendar.
- Confidence-scored explainers.
- Public maps and dashboards.
- Downloadable CSV/JSON packs.
- Research gaps dashboard.

### Commercial layer: Apex Predator Insurance Intelligence

Purpose:
A campaign, timing, product, and partner monetisation engine using wildlife signal data.

Primary users:
- Consumers.
- Insurers and reinsurers.
- Tourism and travel brands.
- Adventure and event operators.
- Councils and place managers.
- Media and content partners.

Primary outputs:
- Animal/product campaign maps.
- Campaign cycle state: DETECT, RISE, PEAK, DECAY, HALT.
- Insurance lead capture.
- Partner widgets.
- API licensing.
- Travel/tourism advisory products.
- Paid reports and dashboards.

## Required database objects

### animals

```sql
create table if not exists public.apex_animals (
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
```

### interactions

```sql
create table if not exists public.apex_interactions (
  interaction_id uuid primary key default gen_random_uuid(),
  animal_id uuid references public.apex_animals(animal_id),
  secondary_actor_type text,
  secondary_actor_detail text,
  interaction_type text,
  activity_context text,
  country text,
  region text,
  probability_score numeric,
  severity_score numeric,
  media_velocity_score numeric,
  confidence_score numeric,
  commercial_relevance_score numeric,
  public_safety_relevance_score numeric,
  recommended_action text,
  halt_conditions text,
  last_observed_at timestamptz,
  created_at timestamptz default now()
);
```

### incidents

```sql
create table if not exists public.apex_incidents (
  incident_id uuid primary key default gen_random_uuid(),
  source_id uuid,
  animal_id uuid references public.apex_animals(animal_id),
  interaction_id uuid references public.apex_interactions(interaction_id),
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
```

### signals

```sql
create table if not exists public.apex_signals (
  signal_id uuid primary key default gen_random_uuid(),
  animal_id uuid references public.apex_animals(animal_id),
  interaction_id uuid references public.apex_interactions(interaction_id),
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
```

### campaigns

```sql
create table if not exists public.apex_campaigns (
  campaign_id uuid primary key default gen_random_uuid(),
  animal_id uuid references public.apex_animals(animal_id),
  interaction_id uuid references public.apex_interactions(interaction_id),
  campaign_name text not null,
  campaign_type text,
  target_region text,
  target_product text,
  cycle_state text default 'DETECT',
  signal_score numeric,
  commercial_score numeric,
  active boolean default true,
  started_at timestamptz default now(),
  ended_at timestamptz,
  created_at timestamptz default now()
);
```

### campaign halts

```sql
create table if not exists public.apex_campaign_halts (
  halt_id uuid primary key default gen_random_uuid(),
  campaign_id uuid references public.apex_campaigns(campaign_id),
  halt_reason text,
  halt_trigger text,
  halted_at timestamptz default now(),
  halted_by text default 'system',
  restart_conditions text,
  evidence_url text
);
```

### sources

```sql
create table if not exists public.apex_sources (
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
```

## Scoring formulas

### signal score

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

### risk score

```text
risk_score =
  (incident_probability * 0.25)
+ (severity_score * 0.25)
+ (exposure_score * 0.20)
+ (environmental_conditions * 0.15)
+ (response_gap_score * 0.15)
```

### commercial score

```text
commercial_score =
  (signal_score * 0.25)
+ (meme_index * 0.15)
+ (fear_index * 0.15)
+ (insurance_relevance_score * 0.25)
+ (campaign_timing_score * 0.20)
```

## Campaign cycle rules

States:

- DETECT: low-level monitoring.
- RISE: signal accelerating, education and awareness content.
- PEAK: high-confidence signal, conversion campaign.
- DECAY: retargeting and recap.
- HALT: stop campaign.

Transitions:

```text
DETECT -> RISE if signal_score >= 40 and confidence_score >= 55
RISE -> PEAK if signal_score >= 70 and media_velocity >= 60
PEAK -> DECAY if signal_score falls by 30% over rolling 72h
ANY -> HALT if confidence_score < 35, sentiment risk > 70, regulatory risk true, tragedy sensitivity true, or fatigue score > 80
DECAY -> HALT after 7 days or signal_score < 25
```

Halt reasons:

- factual uncertainty
- duplicate or hoax risk
- active human tragedy
- legal/regulatory concern
- conservation sensitivity
- cultural sensitivity
- campaign fatigue
- low conversion
- signal decay
- partner request

## Seed 85-animal registry

CSV header:

```csv
slug,common_name,scientific_name,animal_group,predator_class,primary_regions,habitat_types,human_interaction_modes,fear_index,meme_index,media_index,insurance_relevance_score,public_education_priority,marketing_safe,commercial_use_notes,research_use_notes
```

Seed rows:

```csv
great-white-shark,Great White Shark,Carcharodon carcharias,fish,apex,"Australia|South Africa|USA|Mediterranean","coastal|marine","bite|sighting|tourism disruption",95,70,95,92,90,true,"Ocean risk cover, beach alert campaigns","High public-safety and conservation sensitivity"
tiger-shark,Tiger Shark,Galeocerdo cuvier,fish,apex,"Australia|Hawaii|Caribbean","marine|reef","bite|sighting",90,62,86,85,85,true,"Travel and surf-region advisories","Useful for seasonal coastal risk"
bull-shark,Bull Shark,Carcharhinus leucas,fish,apex,"Australia|USA|Africa|Asia","river|estuary|coastal","bite|sighting",92,58,84,88,88,true,"River and estuary risk cover","Important for non-ocean encounter education"
hammerhead-shark,Hammerhead Shark,Sphyrnidae,fish,apex,"Global tropical waters","marine|reef","sighting|tourism disruption",76,68,78,60,75,true,"Dive tourism signal campaigns","Conservation-sensitive species family"
oceanic-whitetip-shark,Oceanic Whitetip Shark,Carcharhinus longimanus,fish,apex,"Tropical oceans","open ocean","bite|sighting",88,50,70,62,80,true,"Open-ocean travel/adventure content","High conservation sensitivity"
saltwater-crocodile,Saltwater Crocodile,Crocodylus porosus,reptile,apex,"Australia|PNG|SE Asia","river|estuary|wetland|coastal","attack|fatality|pet loss",98,72,95,95,95,true,"Northern Australia wet-season risk cover","Serious public-safety priority"
nile-crocodile,Nile Crocodile,Crocodylus niloticus,reptile,apex,"Africa","river|lake|wetland","attack|fatality|livestock loss",97,62,90,88,95,true,"Safari and river tourism advisory","High fatality risk context"
american-alligator,American Alligator,Alligator mississippiensis,reptile,apex,"USA","swamp|lake|suburban waterway","bite|pet loss|sighting",82,66,82,76,82,true,"Florida visitor and pet-risk cover","Strong suburban interface data use"
caiman,Caiman,Caimaninae,reptile,mesopredator,"Central America|South America","river|wetland","bite|sighting",70,45,55,48,65,true,"Regional travel advisory","Lower media but useful ecosystem signal"
lion,Lion,Panthera leo,mammal,apex,"Africa|India","savanna|reserve","attack|livestock loss|fatality",96,78,96,88,92,true,"Safari and reserve risk products","Strong conservation framing required"
tiger,Tiger,Panthera tigris,mammal,apex,"India|SE Asia|Russia","forest|mangrove|reserve","attack|livestock loss|fatality",97,82,96,86,95,true,"Tiger region risk and conservation campaigns","High conservation sensitivity"
leopard,Leopard,Panthera pardus,mammal,apex,"Africa|Asia","forest|savanna|peri-urban","attack|pet loss|livestock loss",88,60,82,70,84,true,"Village-edge and safari advisory","Useful human-wildlife conflict species"
jaguar,Jaguar,Panthera onca,mammal,apex,"Central America|South America","rainforest|river","attack|livestock loss",84,58,72,58,80,true,"Amazon travel and ranch conflict lens","Conservation-sensitive"
cougar,Cougar,Puma concolor,mammal,apex,"North America|South America","mountain|forest|suburban edge","attack|sighting|pet loss",84,55,80,72,82,true,"Trail and suburb-edge alert campaigns","Good for hiking safety"
snow-leopard,Snow Leopard,Panthera uncia,mammal,apex,"Central Asia","mountain","livestock conflict|sighting",78,65,70,42,78,true,"Conservation sponsorship more than insurance","Rare incident, high conservation value"
polar-bear,Polar Bear,Ursus maritimus,mammal,apex,"Arctic","ice|coastal|settlement edge","attack|sighting|property damage",96,64,88,78,92,true,"Arctic travel and climate-risk content","Climate-linked risk narrative"
grizzly-bear,Grizzly Bear,Ursus arctos horribilis,mammal,apex,"North America","forest|mountain|river","attack|camping incident|property damage",94,62,88,82,92,true,"Camping and national park risk cover","Strong seasonal model candidate"
black-bear,Black Bear,Ursus americanus,mammal,apex,"North America","forest|suburban edge","attack|property damage|food conflict",78,70,82,76,84,true,"Campground and suburb-edge campaigns","Frequent encounter education"
sloth-bear,Sloth Bear,Melursus ursinus,mammal,apex,"India|Sri Lanka","forest|village edge","attack|fatality",90,42,68,58,88,true,"Regional conflict advisory","High injury potential, lower global awareness"
wolf,Wolf,Canis lupus,mammal,apex,"North America|Europe|Asia","forest|mountain|rural","livestock loss|sighting|rare attack",78,72,82,62,80,true,"Livestock and wilderness advisory","Politically sensitive conservation topic"
dingo,Dingo,Canis dingo,mammal,apex,"Australia","desert|island|bush|campground","bite|pet loss|tourism conflict",82,74,84,78,86,true,"K'gari camping and pet-risk advisory","Australian public-safety relevance"
coyote,Coyote,Canis latrans,mammal,mesopredator,"North America","urban|suburban|rural","pet loss|bite|sighting",64,66,72,66,76,true,"Suburban pet-risk campaigns","High urban interface signal"
spotted-hyena,Spotted Hyena,Crocuta crocuta,mammal,apex,"Africa","savanna|village edge","attack|livestock loss|scavenging",82,76,72,54,78,true,"Safari and livestock-risk content","Strong myth/media gap"
african-wild-dog,African Wild Dog,Lycaon pictus,mammal,apex,"Africa","savanna|reserve","sighting|livestock conflict",66,60,58,34,75,true,"Conservation sponsorship content","Low direct human risk"
orca,Orca,Orcinus orca,mammal,apex,"Global oceans","marine","boat interaction|sighting|tourism disruption",86,86,95,72,88,true,"Boat and marine tourism signal campaigns","High media, nuanced risk"
leopard-seal,Leopard Seal,Hydrurga leptonyx,mammal,apex,"Antarctica|Subantarctic","marine|ice","attack|sighting",84,55,68,42,76,true,"Expedition travel advisory","Niche but high intrigue"
sea-lion,Sea Lion,Otariinae,mammal,mesopredator,"Americas|Australia|NZ","coastal|marine","bite|boat interaction|sighting",62,76,72,56,68,true,"Beach and marina advisory","Good tourist education species"
hippo,Hippopotamus,Hippopotamus amphibius,mammal,large-herbivore-danger,"Africa","river|lake","attack|boat incident|fatality",96,70,90,82,95,true,"Safari river risk cover","High fatality misconception correction"
elephant,Elephant,Elephantidae,mammal,large-herbivore-danger,"Africa|Asia","savanna|forest|reserve|village edge","charge|crop damage|fatality",94,80,94,80,94,true,"Safari and crop-conflict advisory","High conservation and community sensitivity"
rhino,Rhinoceros,Rhinocerotidae,mammal,large-herbivore-danger,"Africa|Asia","savanna|grassland|reserve","charge|vehicle damage",88,62,78,62,84,true,"Safari vehicle advisory","Conservation-first framing"
african-buffalo,African Buffalo,Syncerus caffer,mammal,large-herbivore-danger,"Africa","savanna|wetland","charge|fatality",92,58,76,70,90,true,"Safari walking-risk advisory","Underestimated danger species"
bison,Bison,Bison bison,mammal,large-herbivore-danger,"North America","grassland|park","goring|tourist incident|vehicle damage",82,74,82,68,82,true,"National park tourist advisory","High stupid-tourist content potential"
moose,Moose,Alces alces,mammal,large-herbivore-danger,"North America|Europe","forest|roadway|wetland","vehicle collision|charge",78,72,76,80,86,true,"Road collision and winter advisory","Strong insurance relevance"
camel,Camel,Camelus,mammal,large-herbivore-danger,"Middle East|Australia|Africa|Asia","desert|roadway|farm","collision|bite|property damage",58,78,62,64,62,true,"Outback collision and tourism content","Good Australia/Middle East angle"
kangaroo,Kangaroo,Macropodidae,mammal,large-herbivore-danger,"Australia","bush|roadway|suburban edge","vehicle collision|attack|property damage",70,92,90,95,82,true,"Outback collision cover, viral campaigns","Top Australian commercial species"
cassowary,Cassowary,Casuarius,bird,large-herbivore-danger,"Australia|PNG","rainforest|roadway","kick|vehicle collision|sighting",80,86,82,70,86,true,"Rainforest tourist advisory","Conservation-sensitive Australian icon"
inland-taipan,Inland Taipan,Oxyuranus microlepidotus,reptile,venomous,"Australia","arid|grassland","bite|sighting",96,68,82,72,92,true,"Snake-season education campaigns","High fear, lower encounter frequency"
coastal-taipan,Coastal Taipan,Oxyuranus scutellatus,reptile,venomous,"Australia|PNG","coastal|forest|cane fields","bite|sighting",94,58,78,74,92,true,"Northern/Eastern Australia snake alerts","High public-safety priority"
eastern-brown-snake,Eastern Brown Snake,Pseudonaja textilis,reptile,venomous,"Australia","urban edge|farm|grassland","bite|pet risk|sighting",96,72,90,92,96,true,"Backyard and school snake-season cover","Top AU snake-risk signal"
black-mamba,Black Mamba,Dendroaspis polylepis,reptile,venomous,"Africa","savanna|rocky|woodland","bite|fatality",98,64,84,70,96,true,"Safari and rural snake advisory","High fear/global awareness"
king-cobra,King Cobra,Ophiophagus hannah,reptile,venomous,"South Asia|SE Asia","forest|farm|village edge","bite|sighting",94,76,88,70,92,true,"Regional snake-risk content","Conservation nuance required"
rattlesnake,Rattlesnake,Crotalinae,reptile,venomous,"Americas","desert|grassland|suburban edge","bite|pet risk|sighting",86,70,78,74,88,true,"Trail and pet-risk advisory","Strong North American signal"
viper,Viper,Viperidae,reptile,venomous,"Europe|Asia|Africa","forest|grassland|farm","bite|sighting",82,50,64,58,82,true,"Regional hiking advisory","Broad family requires local precision"
anaconda,Anaconda,Eunectes,reptile,constrictor,"South America","river|wetland|rainforest","attack|livestock loss|sighting",86,82,80,50,78,true,"Amazon myth-vs-risk content","Useful media/fact correction"
reticulated-python,Reticulated Python,Malayopython reticulatus,reptile,constrictor,"SE Asia","forest|village edge","attack|pet loss|sighting",84,74,76,58,78,true,"Village-edge and pet-risk advisory","Rare but high media"
funnel-web-spider,Funnel-web Spider,Atracidae,arachnid,venomous,"Australia","urban|garden|forest","bite|sighting",92,76,82,78,92,true,"Sydney venomous spider season content","High local public education value"
redback-spider,Redback Spider,Latrodectus hasselti,arachnid,venomous,"Australia","urban|shed|garden","bite|sighting",76,82,70,66,84,true,"Backyard and shed safety campaigns","Frequent education species"
black-widow-spider,Black Widow Spider,Latrodectus mactans,arachnid,venomous,"North America","urban|shed|garden","bite|sighting",78,70,70,62,82,true,"Home/garden safety advisory","Recognisable but manageable risk"
scorpion,Scorpion,Scorpiones,arachnid,venomous,"Global arid/tropical","desert|home|rocky","sting|sighting",70,64,62,58,78,true,"Desert travel and household advisory","Family-level data needs localisation"
cone-snail,Cone Snail,Conidae,mollusc,venomous,"Indo-Pacific","reef|marine","sting|fatality",88,54,64,52,84,true,"Reef and shell-collector advisory","Underknown high education value"
box-jellyfish,Box Jellyfish,Chironex fleckeri,cnidarian,venomous,"Australia|Indo-Pacific","coastal|marine","sting|fatality|beach closure",98,70,92,94,98,true,"Beach closure and travel cover","Top seasonal marine hazard"
blue-ringed-octopus,Blue-ringed Octopus,Hapalochlaena,mollusc,venomous,"Australia|Indo-Pacific","tidepool|reef","bite|sighting",92,82,82,68,90,true,"Tidepool and tourist education","High fear and education value"
magpie,Australian Magpie,Gymnorhina tibicen,bird,defensive,"Australia","urban|park|school|bike path","swoop|injury|cycling incident",58,98,96,92,88,true,"Spring swoop tracker and cyclist cover","Perfect campaign timing species"
eagle,Eagle,Accipitridae,bird,apex,"Global","mountain|forest|coastal","pet risk|sighting|rare attack",58,74,68,36,60,true,"Pet-risk and myth-busting content","Low direct human risk"
owl,Owl,Strigiformes,bird,mesopredator,"Global","forest|urban|farm","swoop|pet risk|sighting",42,72,54,26,52,true,"Night wildlife education","Low commercial but good education"
goose,Goose,Anserini,bird,defensive,"Global","park|lake|urban","bite|chase|nuisance",36,92,72,40,45,true,"Comic urban risk content","High meme, low severity"
emu,Emu,Dromaius novaehollandiae,bird,large-herbivore-danger,"Australia","grassland|roadway|farm","kick|collision|sighting",54,88,68,56,60,true,"Outback and road-trip content","Australian brand value"
wild-boar,Wild Boar,Sus scrofa,mammal,defensive,"Europe|Asia|Americas|Australia","forest|farm|urban edge","attack|crop damage|vehicle collision",76,74,78,82,86,true,"Farm, road, and suburb-edge advisory","High economic and collision relevance"
feral-dog,Feral Dog,Canis familiaris,mammal,mesopredator,"Global","urban edge|rural|wildland","bite|livestock loss|pet risk",72,48,62,72,86,true,"Community and livestock risk advisory","Sensitive welfare framing required"
monkey,Monkey,Primates,mammal,defensive,"Asia|Africa|South America","urban|temple|forest|tourist site","bite|theft|disease exposure",66,86,80,70,82,true,"Tourist theft/bite advisory","Needs disease and welfare nuance"
raccoon,Raccoon,Procyon lotor,mammal,nuisance,"North America|Europe","urban|suburban|forest","bite|property damage|disease exposure",42,88,72,58,70,true,"Urban nuisance and pet-risk content","Good disease education"
fox,Fox,Vulpes,mammal,mesopredator,"Global","urban|rural|forest","bite|pet risk|disease exposure",40,78,60,48,64,true,"Urban wildlife education","Low severity but common"
rat,Rat,Rattus,mammal,disease-vector,"Global","urban|sewer|farm","disease exposure|property damage|food contamination",54,78,74,76,88,true,"Property and food safety advisory","Strong public health tie"
mosquito,Mosquito,Culicidae,insect,disease-vector,"Global","wetland|urban|tropical","bite|disease transmission",72,50,82,90,98,true,"Disease-season alert and travel advisory","Highest real public-health relevance"
tick,Tick,Ixodida,arachnid,disease-vector,"Global","forest|grassland|pet areas","bite|disease transmission",62,42,58,74,92,true,"Hiking and pet-risk advisory","Strong preventive education value"
bat,Bat,Chiroptera,mammal,disease-vector,"Global","cave|urban|forest","bite|scratch|disease exposure",72,70,82,68,90,true,"Rabies/lyssavirus education","High conservation sensitivity"
piranha,Piranha,Serrasalmidae,fish,mesopredator,"South America","river","bite|sighting",58,86,68,42,58,true,"Myth-busting river advisory","High myth/media gap"
stonefish,Stonefish,Synanceia,fish,venomous,"Indo-Pacific|Australia","reef|shallow marine","sting|beach incident",88,54,70,76,92,true,"Beach and reef footwear advisory","High education value"
lionfish,Lionfish,Pterois,fish,venomous,"Indo-Pacific|Caribbean","reef","sting|invasive species",58,66,62,42,72,true,"Dive and invasive-species content","Good conservation angle"
stingray,Stingray,Myliobatoidei,fish,defensive,"Global coastal","marine|estuary","sting|beach incident",64,70,74,66,82,true,"Beach shuffle and wading advisory","Recognisable risk"
barracuda,Barracuda,Sphyraena,fish,mesopredator,"Tropical oceans","reef|marine","bite|sighting",62,58,56,38,58,true,"Dive/snorkel advisory","Moderate signal"
drop-bear,Drop Bear,Thylarctos plummetus,fictional,brand-only,"Australia","bush|tourist imagination","ambush|tourist myth",100,100,95,88,40,true,"Comic campaign and disclaimer-led content","Must be clearly fictional/comedy"
apex-accountant,Apex Accountant,,fictional,brand-only,"Global","office|tax season","audit bite|budget panic",42,96,72,62,20,true,"Tax-season comedy insurance hook","Clearly satirical"
litigation-leopard,Litigation Leopard,,fictional,brand-only,"Global","boardroom|legal office","lawsuit pounce",62,92,70,68,20,true,"Legal-risk comedy hook","Satirical only"
compliance-crocodile,Compliance Crocodile,,fictional,brand-only,"Global","regulated industries","regulatory snap",70,90,72,74,20,true,"Governance/compliance campaign mascot","Satirical only"
budget-blowout-buffalo,Budget Blowout Buffalo,,fictional,brand-only,"Global","projects|government|enterprise","cost stampede",68,94,76,82,20,true,"Project risk and budget campaign mascot","Satirical only"
```

## Free but useful data source pack

Prioritise lawful and attributable sources:

- GDELT global news/event data.
- GNews API already used by current system.
- Australian Bureau of Meteorology and other national weather agencies.
- NOAA weather/ocean data.
- GBIF species occurrence data.
- iNaturalist observations where licensing permits.
- eBird for bird occurrence and timing.
- IUCN Red List metadata.
- Wikidata species metadata.
- OpenStreetMap for beaches, roads, trails, parks, hospitals.
- Government wildlife incident pages and public safety alerts.
- Census/WorldPop-style population density.
- Tourism visitation public datasets.

## Lovable update prompt

```text
Update predator-alert-system.lovable.app into a dual-layer Wildlife Signal Commons + Apex Predator Insurance intelligence platform.

Preserve existing charts, maps, filters, React Query polling, GNews fallback, animal popups, severity cards, and T4H branding.

Add three top-level modes:
1. Public Wildlife Signal Commons
2. Apex Predator Insurance Intelligence
3. Research / Open Data Lab

Add/extend data models for animals, interactions, incidents, signals, campaigns, campaign halts, sources, weather context, regions, seasonality, exports, and contribution reports.

Every animal must be treated as a signal node. Expand from the current species database toward the supplied 85-animal registry. Each animal needs common name, scientific name, group, predator class, regions, habitats, human interaction modes, fear index, meme index, media index, insurance relevance score, public education priority, conservation status, marketing_safe, commercial notes, and research notes.

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

Make the site feel like a serious global wildlife intelligence platform with a cheeky Apex Predator commercial edge. Avoid a thin demo feel. Use dense, content-rich copy, strong dashboard cards, and clear data confidence indicators.
```

## Monetisation ladder

Free:
- public map
- last 30-day incidents
- limited species profiles
- education explainers
- open sample downloads

Traveller Pro:
- custom watch regions
- trip risk reports
- full species profiles
- printable reports
- email/SMS alerts

Industry Intelligence:
- API access
- historical export
- predictive scores
- dashboard builder
- white-label widgets

Enterprise:
- custom feeds
- insurer/tourism/council dashboards
- SLA and account management
- custom research packs
- integration support

Research sponsorship:
- sponsor a species
- sponsor a region
- sponsor a conservation data pack
- sponsor open-data maintenance

## Execution ledger

status: PARTIAL
result: Apex Predator Insurance / Predator Alert System data completion pack lodged to the PEN with schema, seed data, signal model, campaign cycle, halt logic, Lovable update prompt, data source list, and monetisation ladder.
evidence:
- typed_evidence: GitHub commit receipt from create_file
- target_repo: TML-4PM/the-pen
- target_path: intake/apex-predator-insurance/LODGE_apex_predator_insurance_data_complete_2026-05-04.md
gaps:
- The backing Lovable source repo was not found via available GitHub repository search in the previous turn.
- The live Lovable site was not directly patched from this chat.
- Web browsing is disabled in this environment, so live inspection of the deployed Lovable page was not possible.
next_action:
- Apply this lodged Lovable prompt to the Lovable project.
- Load the 85-animal CSV seed into the project data layer.
- Wire exports, signal scoring, cycle state, and halting UI.
- Connect source ingestion incrementally, starting with GNews/GDELT/weather and Australian shark/snake/magpie campaigns.
elevation:
- Converted an 85-animal marketing concept into a reusable open wildlife intelligence research layer plus commercial Apex Predator Insurance campaign and monetisation engine.
pressure_flags:
- source_repo_not_discovered
- direct_lovable_patch_not_executed
- no_live_web_validation
score: 0.86
