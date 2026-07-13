# CalmBound Canonical Platform Specification v1.0

**Commission date:** 2026-07-13  
**Owner:** Tech4Humanity  
**Product:** CalmBound  
**Acquisition wedge:** Kids Visit Mode  
**Category:** Household Coordination Infrastructure  
**Document status:** CANONICAL STRATEGY / IMPLEMENTATION FOUNDATION  
**Runtime status:** PARTIAL — architecture compiled; production execution not yet evidenced

---

## 0. Executive Decision

CalmBound is not a parental-control application, a captive-portal microsite, a family social network, or a generic smart-home product.

CalmBound is the trusted household coordination layer that translates family intent into visible, temporary, reversible and accountable action across people, devices, spaces and services.

Its consumer promise is:

> Fewer reminders. Clearer expectations. Calmer homes.

Its platform rule is:

> Know enough to coordinate. Refuse to know more than necessary.

Its north-star metric is:

> Meaningful household transitions coordinated per active household per week.

The product should begin with Kids Visit Mode and a small number of household modes, prove repeated household use, and then expand into embedded device, partner and multi-home infrastructure.

---

# Volume 0 — Household Knowledge Model

The Household Knowledge Model is the semantic foundation for every application, API, automation, AI agent and partner integration.

## 0.1 Knowledge domains

- People
- Roles
- Relationships
- Households
- Homes
- Rooms
- Vehicles
- Networks
- Devices
- Services
- Pets
- Routines
- Values
- Agreements
- Boundaries
- Preferences
- Responsibilities
- Chores
- Meals
- Allergies
- Visitors
- Carers
- Emergency contacts
- Trusted adults
- Schools
- Clubs
- Travel
- Holidays
- Events
- Milestones
- Goals
- Permissions
- Consents
- Evidence

## 0.2 Knowledge rule

Every household object must have:

- owner
- source
- status
- version
- created time
- effective time
- expiry where relevant
- dependencies
- evidence
- lifecycle
- deletion route

No object is considered canonical if its owner, evidence or lifecycle is unknown.

---

# Volume 1 — Vision and Product Constitution

## 1.1 Mission

Help families coordinate daily life with less repetition, less conflict and less surveillance.

## 1.2 Category

**Household Coordination Infrastructure**

The category performs four functions:

1. Express household agreements.
2. Activate household states.
3. Coordinate people, devices and services.
4. Preserve trust, agency and accountability.

## 1.3 Product boundaries

CalmBound owns:

- household state
- modes
- agreements
- permissions
- coordination
- signals
- event evidence

CalmBound integrates rather than rebuilds:

- payments
- identity
- messaging
- calendars
- smart-home systems
- device management
- workflow orchestration
- policy engines
- event buses
- observability

## 1.4 Product constitution

Every capability must:

1. Reduce household friction.
2. Be understandable to affected people.
3. Preserve human judgment.
4. Increase child agency over time.
5. Minimise data collection.
6. Avoid surveillance by default.
7. Make authority visible.
8. Prefer temporary permissions.
9. Remain reversible.
10. Produce evidence of important system actions.

A capability failing these tests must be rejected, redesigned or isolated.

## 1.5 Permanent prohibitions

CalmBound must not provide:

- child obedience scores
- parenting scores
- hidden behavioural profiles
- covert monitoring
- automated punishment
- unsupported medical or psychological diagnosis
- co-parent comparison scores
- household social rankings
- advertising to children
- sale of child or household behaviour data
- insurance pricing from household behaviour
- hidden affiliate placement in child experiences
- emotional manipulation for retention

---

# Volume 2 — Canonical Household Ontology

## 2.1 Core entities

| Entity | Purpose |
|---|---|
| Household | Primary coordination environment |
| Person | Adult, child, teenager, guest or carer |
| Role | Contextual authority assigned to a person |
| Relationship | Connection between people, households or organisations |
| Space | Home, room, vehicle, school or temporary environment |
| Device | Connected endpoint |
| Network | Household or partner connectivity boundary |
| Service | External system participating in coordination |
| Mode | Current or scheduled household state |
| Agreement | Shared expectation expressed in human terms |
| Rule | Machine-evaluable condition and outcome |
| Permission | Allowed action, subject, scope and duration |
| Exception | Temporary deviation from an agreement or rule |
| Schedule | Timing and recurrence definition |
| Signal | Message, device or environmental action |
| Event | Recorded occurrence |
| Consent | Purpose-bound authority and approval |
| Evidence | Proof that an action or decision occurred |
| Integration | Connection to an external system |
| Partner | Approved external organisation |
| Subscription | Commercial access state |
| Safety Policy | Constraint protecting household members |
| Retention Policy | Data lifecycle rule |

## 2.2 Universal capability expression

Every capability must be representable as:

> Person + role + space + mode + agreement + permission + signal + evidence

## 2.3 Authority is contextual

A person may hold different authority in different spaces and times. Account ownership does not imply unrestricted authority over every person, device, household or data class.

---

# Volume 3 — Household Runtime

## 3.1 Runtime services

- Household state engine
- Rule engine
- Permission engine
- Scheduler
- Event bus
- Notification service
- Evidence service
- Consent service
- Integration service
- Subscription entitlement service
- Recovery service
- Audit service

## 3.2 Runtime truth rules

An action is not REAL unless it has:

- execution
- receipt
- ledger entry
- telemetry
- validation
- recovery path

No receipt means the action is not proven complete.

## 3.3 State model

Canonical states:

- DRAFT
- READY
- ACTIVE
- PAUSED
- EXPIRED
- REVOKED
- FAILED
- QUARANTINED
- ARCHIVED

## 3.4 Failure and recovery

| Failure | Required recovery |
|---|---|
| Mode activation fails | Retry, visible error and fallback notification |
| Device unavailable | Degraded mode; do not assume enforcement |
| Partner API fails | Queue, retry and quarantine after threshold |
| Permission expiry fails | Revoke, alert and create incident receipt |
| Incorrect access occurs | Suspend access, investigate and preserve evidence |
| Stripe webhook is delayed | Preserve safe entitlement temporarily and reconcile |
| Deletion fails | Quarantine, retry and verify deletion |
| Smart-home action fails | Report failure; never imply environmental change |
| AI output breaches policy | Suppress output, record model event and escalate |
| Authority is contested | Freeze disputed action and require authorised review |

No silent failure is permitted.

---

# Volume 4 — Household Graph

## 4.1 Node classes

- household
- person
- role
- relationship
- space
- network
- device
- service
- mode
- agreement
- permission
- consent
- event
- evidence
- partner
- capability
- policy

## 4.2 Edge classes

- MEMBER_OF
- GUARDIAN_OF
- CARES_FOR
- AUTHORISED_FOR
- LOCATED_IN
- CONNECTED_TO
- GOVERNED_BY
- DEPENDS_ON
- ACTIVATES
- EMITS
- EVIDENCED_BY
- CONSENTED_TO
- EXPIRES_AT
- DELEGATED_TO
- PROVIDED_BY

## 4.3 Graph requirement

Every node and edge requires owner, evidence, dependency and lifecycle metadata.

---

# Volume 5 — Capability Registry

Every product function is registered as a capability rather than embedded directly in a page or application.

## 5.1 Required capability fields

- capability ID
- name
- purpose
- user problem
- owner
- lifecycle status
- actors
- inputs
- outputs
- dependencies
- permissions
- agreements
- rules
- events emitted
- signals produced
- interfaces
- APIs
- AI involvement
- telemetry
- safety controls
- business value
- consumer value
- revenue relationship
- acceptance criteria
- rollback path

## 5.2 Initial registered capabilities

1. Household Creation
2. Household Invitation
3. Kids Visit Mode
4. Quiet Hours
5. Homework Mode
6. Dinner Mode
7. Bedtime Mode
8. Sleepover Mode
9. Guest Wi-Fi Portal
10. Temporary Override
11. Child-readable Rule View
12. Two-adult Fairness
13. Carer Access
14. Teen Autonomy Progression
15. Household Display
16. Calendar Synchronisation
17. Smart-home Signal Dispatch
18. Multi-home Agreement
19. Handoff Checklist
20. Emergency Override
21. Consent Receipt
22. Permission Expiry
23. Data Export
24. Data Deletion
25. Subscription Entitlement

---

# Volume 6 — Rule Engine

## 6.1 Rule structure

A rule contains:

- rule ID
- version
- scope
- actor
- subject
- conditions
- action
- priority
- effective time
- expiry
- override policy
- evidence requirement
- recovery action

## 6.2 Example

```text
IF visitor.role = CHILD_VISITOR
AND visitor.declared_age_band = UNDER_16
AND household.mode = VISIT
AND network.type = GUEST
THEN display guest agreement
AND apply configured guest network policy
AND emit agreement_displayed
AND require explicit continue action
```

## 6.3 Conflict resolution order

1. Safety policy
2. Lawful authority constraint
3. Explicit consent restriction
4. Emergency override
5. Household agreement
6. Mode rule
7. User preference
8. Recommendation

A lower-order rule cannot silently override a higher-order constraint.

---

# Volume 7 — Permission and Consent System

## 7.1 Permission record

Every permission requires:

- owner
- subject
- grantee
- action
- object
- scope
- purpose
- start
- expiry
- evidence
- revocation route
- policy version

## 7.2 Consent record

Every consent requires:

- subject
- granting authority
- purpose
- scope
- start
- expiry
- revocation
- evidence
- jurisdiction
- age suitability
- renewal rule

No generic permanent household consent is acceptable.

## 7.3 Decision rights

| Decision | Primary authority |
|---|---|
| Household billing | Account owner |
| Child safety setting | Guardian |
| Shared household mode | Authorised household adults |
| Teen privacy boundary | Negotiated and age-dependent |
| Carer access | Guardian or delegated adult |
| School-context mode | School only within school context |
| Cross-home agreement | Authorised representatives of both households |
| Emergency override | Authorised adult with full audit |
| AI recommendation | Advisory only |
| Data export or deletion | Data owner or lawful guardian |

When authority is disputed, contested access is frozen rather than inferred.

---

# Volume 8 — Household Modes

## 8.1 Initial modes

- Morning
- School Departure
- Arrival Home
- Homework
- Dinner
- Bedtime
- Quiet House
- Family Time
- Kids Visit
- Sleepover
- Babysitter
- Carer
- Weekend
- Holiday
- Travel
- Exam Week
- Illness
- Party
- Maintenance
- Emergency
- Co-parent Handoff
- Home Safe

## 8.2 Mode schema

Each mode defines:

- purpose
- eligible actors
- trigger
- duration
- agreements
- rules
- permissions
- signals
- exceptions
- child explanation
- AI behaviour
- telemetry
- evidence
- recovery

## 8.3 Initial wedge

Phase 1 is limited to:

- Kids Visit Mode
- Quiet Hours
- one configurable household mode
- temporary override
- child-readable rule view
- household invitations

---

# Volume 9 — Product Portfolio

## 9.1 CalmBound Home

Daily household coordination including morning, homework, dinner, quiet hours, bedtime and family time.

## 9.2 CalmBound Visit

Guest experience and acquisition engine including Kids Visit Mode, sleepovers, guest Wi-Fi, visitor instructions, emergency contacts, pickup details and automatic permission expiry.

## 9.3 CalmBound Together

Shared agreements, requests, exceptions, family meetings, responsibilities and progressive autonomy.

## 9.4 CalmBound Care

Temporary and delegated access for babysitters, nannies, grandparents, tutors, coaches and other trusted carers.

## 9.5 CalmBound Across Homes

Neutral multi-home coordination with explicit shared agreements, household autonomy, portable preferences and no parent comparison.

## 9.6 CalmBound Grow

Life-stage progression from newborn and toddler through primary school, teenage autonomy, leaving home and voluntary adult family connection.

---

# Volume 10 — Consumer Experience

## 10.1 Consumer jobs

Adults want less repetition, less administration and fewer arguments.

Children want understandable rules, visible fairness, the ability to ask and increasing autonomy.

Teenagers want negotiated boundaries, privacy visibility and dignity.

Carers want only the information and authority required for a defined period.

## 10.2 Primary interface

The home experience answers:

1. What mode is active?
2. What happens next?
3. Does anyone need something?
4. Is anything unusual?

It must not resemble an enterprise control panel or surveillance dashboard.

## 10.3 Ambient interfaces

- Mobile
- Web
- Guest portal
- Tablet home hub
- Smart television
- Lock-screen widget
- Smartwatch
- Router
- Smart speaker
- Calendar
- Car interface
- QR and NFC
- SMS and email fallback
- Printed household card
- Partner API

The best experience often requires nobody to open the application.

---

# Volume 11 — AI Architecture

## 11.1 AI roles

- Household AI
- Routine AI
- Visitor Concierge
- Family Scheduler
- Homework Assistant
- Bedtime Assistant
- Teen Coach
- Parent Coach
- Family Meeting Facilitator
- Care Coordinator
- Smart-home Coordinator
- Safety Policy Assistant

## 11.2 Permitted AI behaviour

- suggest routine changes
- detect repeated overrides
- identify conflicting schedules
- explain rules in age-appropriate language
- translate agreements
- prepare family meetings
- reduce unnecessary notifications
- suggest autonomy progression
- summarise household patterns without permanent scoring

## 11.3 Prohibited AI behaviour

- diagnose
- punish
- secretly score
- infer sensitive traits without necessity
- manipulate emotions
- compare children, parents or households
- generate legal conclusions
- make irreversible safety decisions

## 11.4 AI evidence requirements

Every consequential AI output requires:

- source context
- model and version
- policy version
- explanation
- confidence
- human override
- retention rule
- feedback route

---

# Volume 12 — Trust, Privacy and Governance

## 12.1 Trust principles

- data minimisation
- child-first design
- no advertising to children
- no data sale
- no surveillance by default
- clear retention
- local processing where practical
- export and deletion
- time-limited permissions
- separate child and adult views
- age-appropriate transparency
- visible override history
- explainable automation
- independent security testing
- public trust centre
- incident disclosure
- partner access registry

## 12.2 Governance functions

- product safety review
- privacy impact assessment
- child impact assessment
- AI model review
- partner access review
- incident review
- template moderation
- retention enforcement
- security testing
- appeal handling

## 12.3 Required governance metrics

- permission expiry success
- deletion completion
- partner access violations
- child complaints
- authority disputes
- AI recommendations rejected
- unsupported inference prevented
- security incidents
- retention breaches
- appeal resolution time
- rule comprehension by affected children

Governance without telemetry remains aspirational.

---

# Volume 13 — Business Model

## 13.1 Revenue engines

1. Direct household subscriptions
2. Embedded distribution through devices, telcos and services
3. Platform and marketplace revenue
4. Institutional and public-interest licensing

## 13.2 Consumer plans

### Free

- one household
- Kids Visit Mode
- guest portal
- one manually activated mode
- basic quiet period
- one child profile
- two adults
- limited history

### Family

- multiple children
- scheduled modes
- calendar integration
- household display
- carer access
- shared agreements
- standard integrations

### Family Plus

- multiple homes
- advanced permissions
- teen autonomy controls
- custom modes
- smart-home automation
- extended history
- priority support

### Care Network

- multiple carers
- professional carer roles
- organisation links
- emergency packs
- delegated administration

### Partner Platform

- per activated household
- per managed device
- API usage
- licence
- revenue share
- implementation
- certification
- support

## 13.3 Economic prohibitions

Revenue must never depend on:

- child advertising
- sale of family behaviour
- hidden affiliate recommendations
- school monetisation of home data
- surveillance upsells
- emotional manipulation

---

# Volume 14 — Distribution and Ecosystem

## 14.1 Growth loops

### Guest loop

Host activates Kids Visit Mode → visitor experiences clear rules → visiting parent discovers CalmBound → new household created.

### Invitation loop

One adult invites partner, child, grandparent or carer.

### Device loop

CalmBound is activated during router, mesh device or family hub setup.

### Cohort loop

Schools and clubs use narrow contextual modes without accessing private home activity.

### Template loop

Trusted household routines are shared and adapted.

### Life-stage loop

The product evolves as children gain independence.

## 14.2 Partner classes

### Infrastructure

- telcos
- ISPs
- router manufacturers
- mesh Wi-Fi
- smart-home platforms
- device manufacturers
- home builders

### Family services

- childcare
- schools
- tutors
- carers
- sports clubs
- libraries
- community organisations
- family mediators

### Household systems

- calendars
- smart locks
- televisions
- cars
- music
- travel
- meal planning
- education tools

## 14.3 Partner access rule

Partners may participate in household context without owning the household relationship.

Every partner grant must be purpose-bound, narrow, revocable, logged and prohibited from resale or child advertising.

---

# Volume 15 — Marketplace

The marketplace is deferred until the core runtime, trust model and publishing controls are proven.

## 15.1 Future categories

- new baby
- homework
- exam period
- sensory-friendly
- ADHD-supportive
- travel
- sleepover
- co-parenting
- sports season
- holiday
- emergency
- school morning

## 15.2 Publisher requirements

- verified identity
- expertise disclosure
- evidence basis
- age range
- jurisdiction
- version
- review date
- expiry
- conflict disclosure
- reporting route

## 15.3 Marketplace exclusions

- unsupported medical claims
- unsupported legal claims
- punishment systems
- discriminatory content
- hidden advertising
- covert tracking

---

# Volume 16 — Technical Architecture

## 16.1 Layers

### Experience layer

Mobile, web, guest portal, household display, voice, watch, television, car, email and SMS fallback.

### Runtime layer

Household state, rules, permissions, scheduler, events, notifications, evidence and integrations.

### Data layer

Operational database, graph, event store, audit ledger, consent store, analytics store, billing store and secrets manager.

### Governance plane

Policy enforcement, access review, retention, AI governance, partner governance and incident management.

### Observability

OpenTelemetry, runtime receipts, error tracking, security monitoring, permission failures, automation success and deletion verification.

## 16.2 Build versus reuse

### Build

- household ontology
- household state engine
- child transparency model
- progressive autonomy model
- multi-home neutrality model
- evidence and receipt model
- capability registry

### Reuse

- Stripe or equivalent payments
- mature identity provider
- workflow orchestrator
- policy engine
- event bus
- OpenTelemetry
- messaging systems
- calendar connectors
- smart-home SDKs

Stripe and Supabase are adapters, not the architecture centre.

---

# Volume 17 — Billing and Data Integration Policy

## 17.1 Stripe requirements

- hosted Checkout only
- no card storage in CalmBound
- signed webhook is subscription truth
- idempotent webhook processing
- grace period and reconciliation
- billing data separated from child behaviour
- no reliance on browser redirect as payment proof

## 17.2 Cancellation

- paid capability continues to billing-period end
- configuration remains available during grace period
- account downgrades to Free
- export and deletion remain available
- reactivation restores configuration where retention permits

## 17.3 Database acceptance requirements

Before any database is declared live:

- canonical environment confirmed
- schema versioned
- migrations tested
- row-level security validated
- backup verified
- restore tested
- secrets stored correctly
- environments separated
- audit logs enabled
- deletion tested
- receipt generated

No placeholder project URL is canonical.

---

# Volume 18 — Telemetry and Evidence

## 18.1 Event envelope

Every material event includes:

- event ID
- source
- timestamp
- actor
- subject
- object
- action
- outcome
- policy version
- evidence reference
- correlation ID
- recovery status

## 18.2 Product metrics

- activated households
- weekly active households
- modes per household
- automated versus manual modes
- guest invitations
- guest-to-household conversion
- household member acceptance
- child rule comprehension
- override frequency
- linked environments
- carer invitations
- multi-home retention
- retention by child age
- partner activation
- permission expiry success
- deletion success
- reported reduction in repeated conflict

Downloads and app opens are secondary metrics.

---

# Volume 19 — Roadmap and Proof Gates

## Phase 0 — Foundation

Deliver:

- canonical registry
- ontology
- product constitution
- trust model
- threat model
- event taxonomy
- metrics

Proof:

- architecture reviewed
- capability IDs stable
- high-risk areas identified
- acceptance tests defined

## Phase 1 — Wedge

Deliver:

- household creation
- Kids Visit Mode
- guest portal
- one household mode
- two-adult fairness
- child-readable rule view
- temporary override
- Free and Family entitlement
- receipts and telemetry

Proof:

- real households activated
- setup under five minutes
- repeat weekly use
- guest conversion observed
- children understand active rules
- no severe trust incidents

## Phase 2 — Daily use

Deliver:

- scheduled modes
- homework
- dinner
- bedtime
- calendar
- carer access
- household display
- teen permission progression

Proof:

- several modes used weekly
- reminders reduced
- teen participation retained
- automation reliability demonstrated

## Phase 3 — Embedded household

Deliver:

- router integration
- smart-home integration
- partner API
- television and device support
- governed template system

Proof:

- partner integration reliability
- lower acquisition cost
- stable APIs
- permission isolation

## Phase 4 — Multi-environment

Deliver:

- multi-home
- school and club context
- extended family
- carer organisations
- portable preferences

Proof:

- specialist safety review
- household neutrality maintained
- low authority-dispute rate

## Phase 5 — Standard

Deliver:

- telco distribution
- device certification
- independent trust governance
- internationalisation
- developer ecosystem

Proof:

- external audits
- broad partner adoption
- standards participation
- jurisdictional coverage

---

# Volume 20 — Testing and Certification

## 20.1 Test domains

- functional
- integration
- security
- privacy
- child safety
- accessibility
- performance
- resilience
- recovery
- deletion
- permission expiry
- multi-home isolation
- partner isolation
- AI policy compliance
- regression

## 20.2 Certification classes

- CalmBound Household Compatible
- CalmBound Router Compatible
- CalmBound Device Compatible
- CalmBound Partner Certified
- CalmBound Template Reviewed
- CalmBound AI Policy Compliant

Certification requires evidence, expiry and revalidation.

---

# Source Artefact Disposition

The exploratory artefacts remain evidence of discovery but are not production foundations.

## Keep and canonicalise

- Kids Visit Mode acquisition concept
- household-norm positioning
- “The house explains it” messaging
- guest portal interaction pattern
- device and guest dual-view concept
- trust and privacy language
- progressive autonomy
- multi-home neutrality
- product portfolio concepts
- partner and ecosystem map
- billing policy concepts

## Refactor

- captive portal implementation
- Stripe integration reference
- Supabase schema reference
- Lambda handler pattern
- pricing structure
- checkout flow
- UI component concepts

## Archive as discovery artefacts

- standalone HTML microsites
- duplicated CSS
- hard-coded pricing pages
- demo local persistence
- cosmetic toggles
- placeholder links
- unverified Supabase project references
- unconnected Stripe implementation

## Discard from production path

- duplicated page-specific markup
- static pricing as source of truth
- page-owned business rules
- browser-owned subscription state
- claims that imply enforcement without runtime evidence
- claims of live integration without receipts

---

# Immediate Implementation Package

The next executable package must contain:

1. `registry/capabilities.yaml`
2. `ontology/entities.yaml`
3. `ontology/relationships.yaml`
4. `runtime/events.schema.json`
5. `runtime/modes.schema.json`
6. `runtime/permissions.schema.json`
7. `governance/product-constitution.yaml`
8. `governance/prohibited-behaviours.yaml`
9. `governance/retention-policies.yaml`
10. `api/openapi.yaml`
11. `telemetry/event-envelope.schema.json`
12. `phase-1/functional-spec.md`
13. `phase-1/acceptance-tests.md`
14. `phase-1/threat-model.md`
15. `phase-1/deployment-acceptance.md`

---

# Gap Register

## Closed at strategy level

- category definition
- product kernel
- product portfolio
- consumer value
- daily-use model
- pricing architecture
- distribution
- partner model
- governance principles
- authority model
- consent model
- data classes
- AI boundaries
- marketplace governance
- technology layers
- failure and recovery
- roadmap
- validation gates
- source artefact disposition

## Still open and requiring execution evidence

- deployed production runtime
- validated identity and permissions
- live database environment
- tested RLS or equivalent authorisation
- live Stripe configuration
- signed webhook receipts
- runtime event ledger
- OpenTelemetry traces
- backup and restore proof
- deletion proof
- real household activation
- guest conversion
- child comprehension testing
- security assessment
- partner commitments
- multi-home safety validation
- revenue and retention

These remain PARTIAL until execution, telemetry and receipts exist.

---

# Canonical Brand Hierarchy

```text
Tech4Humanity
└── CalmBound
    ├── CalmBound Home
    ├── CalmBound Visit
    │   └── Kids Visit Mode
    ├── CalmBound Together
    ├── CalmBound Care
    ├── CalmBound Across Homes
    └── CalmBound Grow
```

---

# Final Position

CalmBound should not aim to dominate family attention.

It should become the quiet protocol through which households express expectations, coordinate transitions, delegate temporary authority and progressively give children greater agency.

The strongest version of CalmBound:

- knows enough to coordinate
- refuses unnecessary knowledge
- gives children more agency as they grow
- gives adults clarity without covert control
- gives partners access without household ownership
- makes consequential actions visible, temporary and reversible
- treats execution evidence as the difference between aspiration and reality

CalmBound does not replace family life.

It removes avoidable friction so family life can happen.
