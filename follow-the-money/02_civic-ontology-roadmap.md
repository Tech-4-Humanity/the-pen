# Follow The Money™ Civic Ontology Roadmap v1.0

## Purpose

This roadmap converts the finite political issue map into the routing layer for Jersey of the Day™, Team of the Day™, Poll of the Day™, Influence Atlas, and open-source country packs.

The core insight: politics is not infinite. Most headlines can be routed into a stable set of jurisdictional buckets, universal voter-facing themes, team archetypes, value tensions, actors, evidence classes, and consequence groups.

---

## Five Deep Cycles

### Cycle 1 — Finite Civic Map

The system needs a canonical ontology before it needs graphics. A headline cannot become a jersey unless it can be routed into a jurisdiction, bucket, theme, value tension, likely actor map, and likely consequence map.

Canonical routing levels:

1. Country
2. Jurisdiction
3. Issue bucket
4. Universal theme
5. Human value tension
6. Team archetype
7. Actor class
8. Evidence class
9. Consequence class
10. Render type

### Cycle 2 — Influence Is Not Just Funding

The front of the jumper cannot mean only political donations. Many issues have little visible donation evidence but strong influence through lobbying, media, procurement, campaign infrastructure, research funding, industry body submissions, union mobilisation, philanthropy, grants, or platform ownership.

The system therefore distinguishes:

- Money influence
- Institutional influence
- Advocacy influence
- Media influence
- Procurement influence
- Regulatory influence
- Community influence
- Expertise influence
- Historical influence
- Foreign or geopolitical influence

The back of the jumper is the innovation: it maps consequence carriers, not merely opponents.

### Cycle 3 — Extra Ideas Layer

Reusable product surfaces:

- Jersey of the Day™
- Team of the Day™
- Poll of the Day™
- Player Cards
- Influence Ladder
- Sponsor Bingo
- Country Packs
- Classroom Packs
- Media Embed Cards
- Debate Briefs
- Atlas Heatmaps
- Issue Family Trees
- Future Generation Jerseys
- Uncertainty Jerseys
- Counterfactual Jerseys
- Who Pays? scorecards

### Cycle 4 — Pull Together

The canonical operating loop becomes:

```text
Headline
→ Country
→ Jurisdiction
→ Issue bucket
→ Universal theme
→ Human values
→ Teams
→ Actors
→ Evidence
→ Consequences
→ Jerseys
→ Poll
→ Archive
→ Atlas
→ Learning loop
```

The output is not a political answer. It is a public-facing civic transparency object.

### Cycle 5 — Build

The build pack consists of:

1. Ontology roadmap
2. Australia country pack
3. Issue template library
4. Team archetype library
5. Render rules
6. Data/evidence rules
7. Bridge execution envelope
8. Reality Ledger binding

---

## Jurisdiction Layer

```yaml
jurisdictions:
  - local
  - state
  - federal
  - global
```

---

## Local Government Buckets

```yaml
local_buckets:
  - roads_and_footpaths
  - rates_and_council_finances
  - rubbish_and_recycling
  - planning_and_development
  - parks_and_recreation
  - parking_and_traffic
  - local_environment
  - community_safety
  - local_business_and_main_streets
  - housing_and_homelessness
  - pets_and_local_regulation
  - community_services
  - emergency_readiness
  - council_integrity
```

## State Government Buckets

```yaml
state_buckets:
  - health_and_hospitals
  - education_and_schools
  - transport
  - police_and_public_safety
  - housing_and_planning
  - energy_and_utilities
  - skills_and_tafe
  - child_protection_and_families
  - justice_and_courts
  - mental_health
  - regional_development
  - environment_and_water
  - emergency_services
  - public_sector_management
  - major_projects
```

## Federal Government Buckets

```yaml
federal_buckets:
  - economy_and_cost_of_living
  - tax_and_budget
  - housing
  - medicare_and_health_funding
  - migration_and_population
  - defence_and_national_security
  - foreign_affairs_and_trade
  - climate_and_energy_transition
  - welfare_and_social_security
  - ndis_and_disability
  - industrial_relations
  - childcare_and_families
  - higher_education_and_research
  - indigenous_affairs
  - digital_ai_and_data
  - agriculture_and_regions
  - infrastructure
  - integrity_and_governance
```

---

## Universal Voter-Facing Themes

Every headline should map to one or more of these 20 master themes.

```yaml
universal_themes:
  - cost
  - homes
  - health
  - education
  - jobs
  - safety
  - transport
  - tax
  - migration
  - energy
  - environment
  - roads
  - services
  - fairness
  - identity
  - business
  - regions
  - technology
  - integrity
  - future
```

---

## Human Value Layer

This powers better polls and avoids crude yes/no rage bait.

```yaml
human_values:
  - freedom
  - safety
  - prosperity
  - fairness
  - security
  - community
  - environment
  - innovation
  - tradition
  - future
  - dignity
  - accountability
  - care
  - opportunity
  - sovereignty
```

---

## Team Archetypes

```yaml
team_archetypes:
  government_team:
    description: Current decision makers and public institutions.
  industry_team:
    description: Commercial beneficiaries, market participants, trade bodies and investors.
  advocacy_team:
    description: NGOs, campaign organisations, unions, community campaigns and public mobilisation actors.
  citizen_team:
    description: People directly affected as users, voters, households, workers, patients, students or residents.
  expert_team:
    description: Researchers, scientists, professional bodies, inquiries, regulators and technical authorities.
  taxpayer_team:
    description: Fiscal burden holders, budget contributors and long-term public liability carriers.
  future_generation_team:
    description: Children, future taxpayers, long-term environment, infrastructure inheritance and intergenerational consequences.
  international_team:
    description: Foreign governments, treaties, trade partners, multilateral organisations and geopolitical actors.
  media_team:
    description: Media owners, broadcasters, platforms, creators, publishers and amplification channels.
  platform_team:
    description: Digital platforms, algorithms, infrastructure operators and data intermediaries.
```

---

## Evidence Classes

```yaml
evidence_classes:
  - official_register
  - political_donation
  - lobbying_register
  - procurement_record
  - grant_record
  - parliamentary_record
  - policy_document
  - public_submission
  - company_filing
  - union_disclosure
  - ngo_disclosure
  - think_tank_disclosure
  - academic_research
  - media_report
  - court_record
  - inquiry_report
  - campaign_material
  - public_statement
  - social_media_record
```

---

## Consequence Classes

```yaml
consequence_classes:
  - direct_cost
  - indirect_cost
  - direct_benefit
  - indirect_benefit
  - service_load
  - legal_risk
  - security_risk
  - health_impact
  - environmental_impact
  - community_impact
  - rights_impact
  - market_impact
  - infrastructure_impact
  - workforce_impact
  - intergenerational_impact
  - regional_impact
```

---

## Render Types

```yaml
render_types:
  - sponsor_jersey
  - advocate_jersey
  - impact_jersey
  - cost_jersey
  - future_generation_jersey
  - uncertainty_jersey
  - team_card
  - player_card
  - atlas_heatmap
  - influence_ladder
  - issue_tree
  - media_embed
  - classroom_sheet
```

---

## Safety Language

Never overstate causality.

Allowed terms:

- publicly associated with
- received donations from
- disclosed lobbying activity
- likely beneficiary
- affected group
- policy-aligned actor
- publicly advocated for
- public record indicates
- evidence suggests
- insufficient evidence to determine

Prohibited unless legally proven:

- bought
- bribed
- controlled by
- corruptly influenced by
- secretly funded by
- paid off
- owned by

---

## Reality Ledger

status: PARTIAL
result: Ontology roadmap built and committed.
evidence:
  - GitHub commit receipt required from create_file action.
gaps:
  - headline classifier not deployed
  - data connectors not deployed
  - renderer not deployed
  - public archive not deployed
  - country packs not validated against live sources
next_action:
  - create Australia country pack
  - create 25 issue templates
  - create bridge execution envelope
  - create first demo issue JSON
score: 0.70
