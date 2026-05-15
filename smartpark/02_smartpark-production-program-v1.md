# SmartPark Production Program v1

## Purpose

Build SmartPark as a real deployable product, not a slogan.

SmartPark is the operating system for vehicle dwell space: every parking bay, loading zone, EV charger, autonomous vehicle staging point, fleet waiting area, kerb space, event bay and private space becomes an asset that can be mapped, scored, governed, priced, reserved, monitored, sold and monetised.

## Product architecture

### 1. Public Website

Primary promise: Every Parking Space Is an Asset.

Core pages:

- `/` — strategic homepage
- `/asset-map` — sell the precinct audit and asset mapping product
- `/autonomous-readiness` — driverless parking, fleet staging, EV charging and future mobility
- `/service-transition` — enforcement-to-service workforce model
- `/revenue-models` — monetisation paths for councils, property owners and precincts
- `/benefits` — community, traffic, staff and asset benefits
- `/contact` — lead capture

### 2. SmartPark Asset Map

This is the first commercial product.

Inputs:

- precinct name
- owner / council / operator
- street or boundary
- space count estimate
- public/private mix
- current rules
- enforcement model
- pricing model
- local business context
- EV capacity
- loading zones
- accessibility bays
- event or peak demand windows

Outputs:

- spot inventory
- rules register
- asset score
- revenue score
- community value score
- autonomy readiness score
- risk score
- service transition plan
- monetisation plan
- implementation roadmap

### 3. Data Model

Tables:

- smartpark_precincts
- smartpark_spaces
- smartpark_rules
- smartpark_asset_scores
- smartpark_revenue_models
- smartpark_service_transitions
- smartpark_autonomous_readiness
- smartpark_leads
- smartpark_evidence_receipts

### 4. Scoring Model

Each space receives five scores from 0 to 100:

- commercial value
- community value
- turnover value
- autonomy readiness
- operational risk

Composite score:

`asset_score = commercial_value * 0.25 + community_value * 0.25 + turnover_value * 0.20 + autonomy_readiness * 0.20 - operational_risk * 0.10`

### 5. Revenue Model

Revenue paths:

- audit fee
- SaaS subscription
- booking fee
- dynamic pricing uplift
- EV charging partnership
- fleet staging agreement
- loading zone optimisation
- event parking optimisation
- retail validation program
- data licensing
- autonomous readiness certification
- managed service contract

### 6. Service Catalogue Offer

Product: SmartPark Asset Map

Tier 1: Precinct Snapshot
- fixed precinct audit
- inventory estimate
- asset score report
- 30-day action plan

Tier 2: Managed Asset Layer
- live register
- monthly reporting
- revenue model tracking
- staff transition plan
- governance dashboard

Tier 3: Autonomous Readiness Program
- AV staging plan
- EV/load/queue model
- fleet interface plan
- partner pipeline
- future infrastructure roadmap

## Homepage copy

# Every Parking Space Is an Asset

Parking is not just enforcement. It is infrastructure, inventory, retail access, fleet capacity, EV readiness, logistics space and future autonomous vehicle waiting space.

SmartPark maps, manages and monetises parking spaces as live community assets.

We help councils, precincts and property owners understand what spaces they have, what they are worth, how they should be governed, and how they can generate better outcomes for businesses, residents, staff and future mobility networks.

## Where Will Driverless Vehicles Wait?

Driverless vehicles still need somewhere to stop, charge, clean, service, load, unload, queue, stage and reposition.

The future of parking is not a ticket on a windscreen.

It is a live asset network.

SmartPark is building the operating layer for that network.

## From Enforcement to Orchestration

Car spaces are communal assets. When a small number of people misuse them, local business turnover suffers, residents lose access, and staff are pulled into conflict-heavy enforcement activity.

SmartPark helps shift the model.

Instead of treating staff as enforcers, we help councils and precincts transition them into service, support, optimisation and community productivity roles.

## Four Benefit Pillars

### Employee and Community Welfare

Move parking staff from enforcement-first interactions into service, wayfinding, business support and community assistance.

### Traffic Management for Productivity

Improve turnover, reduce congestion, increase access and support local economic activity.

### Lifestyle and Wellbeing

Make local precincts easier, fairer and more pleasant for residents, visitors, vulnerable users and workers.

### Modern Asset Management

Turn parking spaces into measured, governed, revenue-generating assets with clear ownership and future value.

## Implementation backlog

### Front-end

- Replace existing hero headline.
- Remove giant grey highlight blocks.
- Add clean strategic hero section.
- Add benefit cards.
- Add asset map product section.
- Add driverless vehicle readiness section.
- Add service catalogue tiers.
- Add contact CTA.

### Data

- Create Supabase schema for SmartPark.
- Seed one demo precinct.
- Seed example space classes.
- Seed asset score examples.
- Add lead capture.
- Add receipt table.

### APIs

- POST `/api/leads`
- POST `/api/asset-score`
- GET `/api/demo-precinct`
- POST `/api/receipts`

### Automation

- Every new lead writes receipt.
- Every asset-score calculation writes receipt.
- Every deploy writes receipt.
- Every failed lead submission logs error state.

### Deployment

- GitHub push to SmartPark repo.
- Vercel build.
- Capture deployment URL.
- Capture screenshot.
- Log status REAL only after site proves live.

## Bridge handoff payload

```json
{
  "task_id": "smartpark-production-program-v1",
  "intent": "Build SmartPark as a production-ready site and service catalogue product for global parking asset mapping and autonomous vehicle dwell-space orchestration.",
  "target": {
    "site": "smartpark-three-pi.vercel.app",
    "repo_hint": "SmartPark Vercel-linked repository not discoverable by GitHub search; inspect Vercel project metadata or connected GitHub projects to locate source repo."
  },
  "required_outputs": [
    "production homepage rewrite",
    "asset map product page",
    "autonomous readiness page",
    "service transition page",
    "revenue models page",
    "Supabase schema",
    "demo precinct seed data",
    "asset scoring API",
    "lead capture API",
    "receipt logging",
    "Vercel deployment receipt"
  ],
  "truth_rule": "Do not mark REAL until GitHub commit, Vercel deployment, live URL, and screenshot or HTTP proof are attached.",
  "status": "PARTIAL_UNTIL_DEPLOYED"
}
```

## Reality Ledger

status: PARTIAL
result: Production program specified and committed to GitHub handoff repo.
evidence: GitHub commit pending on create_file response.
gaps: SmartPark source repo not discovered through GitHub repository search; Vercel deployment not executed from this connector.
next_action: locate SmartPark source repo or Vercel project binding, apply code, deploy, capture receipt.
elevation: Converts SmartPark from page copy into deployable product architecture and service catalogue offer.
pressure_flags: Current public site undersells the autonomous infrastructure thesis and needs replacement.
score: 0.82
