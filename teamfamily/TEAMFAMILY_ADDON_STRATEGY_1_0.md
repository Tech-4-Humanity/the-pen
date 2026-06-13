# TeamFamily Add-On Strategy 1.0

Date: 2026-06-07
Status: PARTIAL execution, strategy artefact complete
Target site: https://team-family-app.vercel.app/
Canonical repo handoff: TML-4PM/the-pen

## Executive summary

TeamFamily already exists. The right move is not to rebuild it or replace the homepage. The next 1.0 move is to rationalise and slot the supplied add-ons into the existing site as modular product extensions, pricing bundles, navigation paths, and ecosystem links.

The strongest strategic frame is:

> TeamFamily is the family coordination layer. Kids Buddy is the child-facing companion. Reading Buddy is the learning add-on. Parent Buddy is the family command layer. Teacher/Tutor/Support Buddy are the professional revenue paths.

The moat is not any single Buddy. The moat is the Child Growth Graph: one longitudinal picture of each child across home, school, tutoring, support, wellbeing, routines, and community participation.

## Execution findings

### Confirmed

- Vercel team access is available for `troy's projects`, slug `troys-projects-t4h-machine`, team id `team_IKIr2Kcs38KGo8Zs60yNtm7Y`.
- GitHub canonical handoff to `TML-4PM/the-pen` is available.
- The public target URL was provided: `https://team-family-app.vercel.app/`.

### Blocked / incomplete

- Live page fetch from the browser layer failed with a cache-miss style fetch failure.
- Container DNS could not resolve the public Vercel domain.
- GitHub installed repository search did not find a matching `team-family-app`, `team-family`, or `teamfamily` repository.
- Vercel project listing was not completed in this pass, so no code mutation or production deployment is claimed.

## Product architecture

### Layer 1: TeamFamily front door

TeamFamily should remain the umbrella. It should not be narrowed into Kids Buddy, Reading Buddy, SchoolFamilyAI, NDIS, wellbeing, or education-only.

Plain-language promise:

> TeamFamily helps families coordinate learning, routines, wellbeing, support and school life in one place.

### Layer 2: Buddy products

Buddy products are user-facing experiences, not the whole strategy.

- Kids Buddy: child-facing companion
- Parent Buddy: parent command layer
- Reading Buddy: learning confidence and reading evidence
- Homework Buddy: task breakdown and guided missions
- Teacher Buddy: classroom and parent communication support
- Tutor Buddy: tutoring continuity and lesson/progress support
- Support Buddy: practitioner/provider goals, notes, evidence, and support continuity
- Wellbeing Buddy: mood, transitions, overload, school refusal and confidence support
- Family Ops Buddy: routines, chores, appointments, permissions, transport and shared responsibilities
- Community Buddy: libraries, councils, sports, clubs, mentoring and local support participation

### Layer 3: Shared engines

These are the reusable engines behind the add-ons.

1. Child Growth Graph
2. Family Knowledge Layer
3. Evidence Layer
4. Consent and permission layer
5. Review pack generator
6. Cohort/classroom continuity layer

### Layer 4: Ecosystem infrastructure

These should power the site but not dominate the front-facing message.

- Outcome Ready
- ConsentX
- LifeGraph+
- MyNeuralSignal
- SchoolFamilyAI
- CommunityFamilyAI
- WorkFamilyAI

## Add-on fit map

| Add-on | Fit | Buyer/user | Site placement | Look and feel | Pricing role |
|---|---|---|---|---|---|
| Family Ops Buddy | Core TeamFamily function | Parent/family | Existing core/product section | Calm operations, low-noise | Base subscription |
| Kids Buddy | Child-facing companion | Parent buys, child uses | Primary product card | Warm, safe, playful but not babyish | Included in Family Plus or child-profile upgrade |
| Reading Buddy | Learning module | Parent, tutor, school | Learning support card | Confidence, progress, outcomes | Strong standalone and school/tutor upsell |
| Homework Buddy | Learning plus family operations | Parent/child/tutor | Secondary learning card | Mission/control, not nagging | Family Plus feature |
| Parent Buddy | Parent command centre | Parent | For Parents section | Executive dashboard, calm summary | Main family-paid value driver |
| Teacher Buddy | Education professional tool | School/teacher | For Schools section | Professional, workload reduction | B2B revenue |
| Tutor Buddy | Education-general professional layer | Tutor/tutoring business | For Tutors section | Lesson continuity and progress | Early B2B revenue |
| Support Buddy | Support/practitioner layer | Practitioner/provider/family | Support Teams section | Evidence-driven, compliant | High-value B2B |
| Wellbeing Buddy | Family/school/support layer | Parent/school/support team | Wellbeing section | Soft, private, supportive | Premium family/school feature |
| Community Buddy | Community/council layer | Council/library/youth program | Ecosystem/community section | Participation and local support | B2B/community/government |

## Pricing architecture

### Family pricing

| Plan | Price | Contents |
|---|---:|---|
| Free | $0 | Basic family setup, one child, limited routines |
| Family Core | $9-$19/month | Family Ops, routines, calendar, shared responsibilities |
| Family Plus | $29-$49/month | Kids Buddy, Homework Buddy, Parent Buddy |
| Learning Plus | $39-$69/month | Reading Buddy, Homework Buddy, progress summaries |
| Support Plus | $79-$149/month | Support plans, evidence pack, practitioner sharing |

### Professional pricing

| Segment | Price |
|---|---:|
| Solo tutor | $29-$79/month |
| Practitioner | $49-$199/month |
| Tutoring business | $199-$999/month |
| Provider organisation | $499-$5,000/month |

### Institutional pricing

| Segment | Price |
|---|---:|
| School pilot | $2,500-$15,000 |
| School annual | $10,000-$100,000+ |
| Community pilot | $10,000-$50,000 |
| Government/community cohort | $25,000-$250,000+ |

## Recommended site update scope

This is an update to an existing site, not a rebuild.

### Navigation

Suggested nav labels:

- For Families
- For Kids
- For Learning
- For Schools
- For Support Teams
- Pricing
- Pilots

### Add-on section

Suggested section headline:

> Choose the support your family needs now. Add more as life changes.

Suggested cards:

- Family Ops
- Kids Buddy
- Reading Buddy
- Homework Buddy
- Parent Buddy
- Wellbeing Buddy
- Teacher Buddy
- Support Buddy

Each card should show:

- who it helps
- what problem it solves
- included plan or upgrade path
- pilot path where relevant

### Audience paths

Add or strengthen audience cards:

- Families
- Schools
- Tutors
- Practitioners
- Providers
- Community programs

### Bundle section

Suggested bundles:

| Bundle | Included |
|---|---|
| Family Core | Family Ops, routines, calendar, shared responsibilities |
| Learning Core | Reading Buddy, Homework Buddy, Tutor continuity |
| Wellbeing Core | Wellbeing Buddy, mood patterns, transitions, confidence |
| School Core | Teacher Buddy, classroom visibility, parent communication |
| Support Core | Support Buddy, goals, evidence, plan tracking |
| Community Core | Community Buddy, local programs, participation |

### Trust strip

Recommended copy:

> Built with privacy-aware family coordination, consent-based sharing, and child-safe AI patterns.

Supporting bullets:

- Consent-aware sharing
- Parent-governed permissions
- Child-safe AI responses
- Evidence logs
- Human oversight where needed
- Exportable family/school summaries

### Ecosystem footer

Add an active ecosystem strip rather than static links.

| Product | Role |
|---|---|
| TeamFamily | Family coordination |
| Kids Buddy | Child-facing companion |
| Reading Buddy | Reading confidence and evidence |
| SchoolFamilyAI | School/home continuity |
| Outcome Ready | Support plans and outcomes |
| WorkFamilyAI | Workforce/role operating patterns |
| ConsentX | Consent and permissions |
| LifeGraph+ | Longitudinal context |
| MyNeuralSignal | Adaptive signal layer |

## Copy blocks ready for site update

### Platform line

TeamFamily helps families coordinate learning, routines, wellbeing, support and school life in one place.

### Kids Buddy

A child-safe companion that helps kids understand what is next, build confidence, and stay connected to the people supporting them.

### Reading Buddy

Reading support that turns practice into confidence, progress evidence, and better conversations between home and school.

### Homework Buddy

Turns homework from nightly chaos into small, supported missions families can actually complete.

### Parent Buddy

A calm parent command centre that shows what needs attention without drowning families in notifications.

### Teacher Buddy

Reduce teacher admin while improving continuity between classroom, home and support teams.

### Tutor Buddy

Give tutors a living picture of each student, not just notes from the last session.

### Support Buddy

Turn support goals, family observations and practitioner notes into usable evidence and better continuity.

### Wellbeing Buddy

Helps families notice patterns early and support children through transitions, overload and tough days.

### Community Buddy

Connect families with trusted community programs and make participation visible, supported and measurable.

## Priority order

### Add first

1. Family Ops Buddy
2. Kids Buddy
3. Reading Buddy
4. Homework Buddy
5. Parent Buddy
6. Child Growth Graph
7. Wellbeing Buddy

### Add second

8. Tutor Buddy
9. Teacher Buddy
10. Support Buddy

### Add later

11. Community Buddy
12. MyNeuralSignal adaptive layer
13. Marketplace
14. Government/cohort analytics

## Board-level conclusion

TeamFamily should not become a pile of disconnected Buddy products. It should present as a practical family coordination system, with Buddy modules as optional experiences and the Child Growth Graph as the underlying value engine.

The highest-value commercial sequence is:

1. Families for validation
2. Tutors and practitioners for early paid B2B
3. Schools for scale
4. Providers and government for evidence/outcome infrastructure

## Reality ledger

- status: PARTIAL
- result: Strategy artefact complete and pushed to canonical GitHub handoff path.
- evidence:
  - Vercel team access confirmed: `troy's projects`, slug `troys-projects-t4h-machine`, id `team_IKIr2Kcs38KGo8Zs60yNtm7Y`.
  - Public URL provided: `https://team-family-app.vercel.app/`.
  - GitHub handoff target: `TML-4PM/the-pen/teamfamily/TEAMFAMILY_ADDON_STRATEGY_1_0.md`.
- gaps:
  - live DOM/site inspection blocked
  - repository unresolved
  - Vercel project unresolved
  - no code mutation
  - no deployment
  - no runtime tests
- next_action:
  1. Resolve Vercel project id for `team-family-app` inside team `team_IKIr2Kcs38KGo8Zs60yNtm7Y`.
  2. Resolve source repo from Vercel Git metadata or project settings.
  3. Inspect existing sections/components.
  4. Apply modular add-on registry and site copy updates without rebuilding the homepage.
  5. Run build/lint if repo access becomes available.
  6. Deploy and record production receipt.
- elevation: Site update is a product-extension and commercial-packaging exercise, not greenfield build.
- pressure_flags:
  - prior process drifted into rebuild framing
  - repo unavailable
  - live URL inaccessible from current runtime
  - high risk of feature sprawl if Child Growth Graph is not made the organising layer
- score: 0.72 PARTIAL
