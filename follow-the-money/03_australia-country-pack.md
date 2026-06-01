# Follow The Money™ Australia Country Pack v1.0

## Objective

Enable any Australian headline to be routed into Jersey of the Day™, Team of the Day™, Poll of the Day™, Player Cards, Evidence Packs, and Influence Atlas entries.

## Country Metadata

```yaml
country:
  id: australia
  name: Australia
  iso_alpha_2: AU
  jurisdictions:
    - local
    - state
    - federal
  states_and_territories:
    - NSW
    - VIC
    - QLD
    - WA
    - SA
    - TAS
    - ACT
    - NT
```

## Source Registry

### Electoral and donations

- Australian Electoral Commission
- State electoral commissions where applicable
- Political party annual returns
- Associated entity disclosures
- Donor disclosures

Evidence class: official_register, political_donation
Confidence default: high for existence of record, medium for inferred influence.

### Lobbying

- Federal lobbyist register
- NSW lobbyist register
- VIC lobbyist register
- QLD lobbyist register
- WA lobbyist register
- SA lobbyist register
- TAS lobbyist register
- ACT lobbyist register
- NT lobbyist register where available

Evidence class: lobbying_register
Confidence default: high for registration, medium for issue linkage unless explicitly stated.

### Parliament and policy

- Hansard
- bills and explanatory memoranda
- committee inquiries
- public submissions
- parliamentary library briefs
- ministerial media releases
- budget papers
- regulator publications

Evidence class: parliamentary_record, policy_document, public_submission
Confidence default: high.

### Public money

- AusTender
- GrantConnect
- state procurement portals
- infrastructure pipelines
- annual reports
- budget measures

Evidence class: procurement_record, grant_record, public_filing
Confidence default: high for transaction existence, medium for policy influence linkage.

### Corporate and market

- ASIC
- ASX announcements
- annual reports
- company sustainability reports
- industry body submissions
- court filings where relevant

Evidence class: company_filing, public_statement, inquiry_report
Confidence default: high for disclosed statements, medium for inferred benefit.

### Civil society and labour

- ACNC charity register
- NGO annual reports
- union disclosures
- public campaign pages
- submissions to inquiries
- philanthropy reports where public

Evidence class: ngo_disclosure, union_disclosure, campaign_material, public_submission
Confidence default: medium unless official filing.

### Research and expertise

- CSIRO
- Productivity Commission
- Treasury
- ABS
- AIHW
- AEMO
- universities
- peer-reviewed research
- professional bodies

Evidence class: academic_research, inquiry_report, policy_document
Confidence default: high for official data and peer-reviewed work.

### Media and narrative

- ABC
- SBS
- Nine
- News Corp
- Seven
- Guardian Australia
- The Conversation
- Crikey
- Australian Financial Review
- independent local media

Evidence class: media_report
Confidence default: medium. Use media for narrative signal, not as sole proof of influence.

## Actor Classes

```yaml
actor_classes:
  politician:
    examples: [prime_minister, premier, minister, shadow_minister, councillor]
  party:
    examples: [labor, liberal, nationals, greens, one_nation, independents]
  agency:
    examples: [department, regulator, statutory_authority]
  company:
    examples: [listed_company, private_company, multinational, contractor]
  industry_body:
    examples: [property_council, minerals_council, business_council]
  union:
    examples: [actu, cfmeu, asu, uwu]
  ngo:
    examples: [choice, climate_council, getup, wwf]
  think_tank:
    examples: [grattan, cis, ipa, australia_institute]
  academic:
    examples: [university_researcher, policy_expert, institute]
  media:
    examples: [publisher, broadcaster, platform, commentator]
  community:
    examples: [renters, patients, students, farmers, families, local_residents]
```

## First 25 Issue Families

```yaml
issue_families:
  housing:
    children: [negative_gearing, renters_rights, social_housing, build_to_rent, first_home_buyers, planning_reform]
  energy:
    children: [nuclear, coal, gas, solar, wind, transmission, grid_reliability]
  climate:
    children: [emissions, adaptation, carbon_markets, industry_transition, disasters]
  migration:
    children: [students, refugees, asylum, skilled_migration, population, borders]
  defence:
    children: [aukus, cyber, defence_spending, sovereign_capability, alliances]
  ai_and_digital:
    children: [ai_regulation, privacy, online_safety, social_media, copyright, cyber]
  gambling:
    children: [pokies, wagering, advertising, sports_integrity, harm_minimisation]
  tobacco_and_vaping:
    children: [cigarettes, vaping, taxation, retail_control, health_campaigns]
  health:
    children: [medicare, hospitals, pbs, aged_care, primary_care, workforce]
  mental_health:
    children: [youth, acute_care, community_services, crisis_response]
  education:
    children: [schools, curriculum, teachers, funding, classrooms]
  higher_education:
    children: [universities, hecs, research, international_students]
  ndis_and_disability:
    children: [access, provider_rules, sustainability, quality, workforce]
  tax_and_budget:
    children: [income_tax, gst, deficits, debt, spending, superannuation]
  cost_of_living:
    children: [inflation, wages, prices, supermarkets, energy_bills]
  industrial_relations:
    children: [wages, unions, gig_work, awards, workplace_law]
  childcare_and_families:
    children: [subsidies, early_learning, parental_leave, child_safety]
  indigenous_affairs:
    children: [closing_the_gap, services, land, recognition, local_decision_making]
  agriculture_and_regions:
    children: [biosecurity, drought, exports, water, farm_costs]
  infrastructure:
    children: [roads, rail, ports, cities, major_projects]
  transport:
    children: [trains, buses, roads, tolls, congestion]
  justice_and_safety:
    children: [crime, policing, courts, prisons, domestic_violence, youth_justice]
  environment_and_water:
    children: [water_security, land_clearing, biodiversity, parks, waste]
  integrity_and_governance:
    children: [donations, corruption, transparency, public_service, procurement]
  local_services:
    children: [rates, rubbish, parks, pets, parking, footpaths, community_safety]
```

## Mandatory Team Generation

Every Australian issue must generate at least these teams:

1. Government Team
2. Industry Team
3. Citizen Team
4. Expert Team
5. Taxpayer Team
6. Future Generation Team

Optional teams:

- Advocacy Team
- Media Team
- Platform Team
- International Team
- Regulator Team
- Local Community Team

## Jersey Rules

Front of jersey: influence side.

Back of jersey: consequence side.

No claim of causal control may be made unless legally established. Donations, lobbying and public support are evidence of relationship, not proof of capture.

## Poll Rules

Polls should ask values and trade-offs, not partisan identity.

Preferred poll forms:

- What should matter most?
- Which cost is acceptable?
- Who should carry the burden?
- Which value should win if values conflict?
- Which evidence would change your mind?

## Reality Ledger

status: PARTIAL
result: Australia country pack created and committed.
evidence:
  - GitHub commit receipt from create_file action.
gaps:
  - sources not connected to live ingestion
  - actors not populated into database
  - issue families not yet converted into executable templates
  - no renderer proof
  - no 72h survivability proof
next_action:
  - create 04_issue-template-library.md
  - create 05_atlas-schema.sql
  - create 06_bridge-execution-pack.md
score: 0.74
