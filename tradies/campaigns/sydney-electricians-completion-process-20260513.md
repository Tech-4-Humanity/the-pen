# Sydney Electricians Campaign Completion Process

Date: 2026-05-13
Status: Runtime Candidate

## Core Decision

This is not an email campaign. It is a repeatable acquisition and operational transformation system for tradies, starting with Sydney electricians.

Outbound is only ingestion. The real product is the operating layer that captures demand, qualifies it, converts it, delivers fast wins, captures proof, and expands into recurring AI operations.

## Campaign Spine

1. Acquisition: find electricians
2. Qualification: score who matters
3. Conversion: get response/bookings
4. Delivery: deliver fast wins
5. Expansion: upsell operations AI
6. Retention: become the operational layer
7. Evidence: prove outcomes
8. Automation: reduce manual work

## Phase 1 — Narrow Hard

Start with Sydney electricians only.

Reason:

- high urgency
- high lead value
- emergency work
- fragmented local competition
- weak digital maturity in many operators
- clear ROI around missed calls, quote speed, reviews, and Google visibility

Do not begin with all tradies. Expand after proof.

## Phase 2 — Canonical Offer

Build three clear packages.

| Tier | Outcome | Price Model |
|---|---|---|
| Visibility | Website + Google Business Profile + lead alerts | Fixed setup + low monthly |
| Growth | CRM + automation + AI assistant + follow-up | Monthly |
| Ops AI | SOPs + invoicing + outreach + workflows + dashboard | Higher monthly |

Each package must include:

- onboarding steps
- delivery timeline
- outputs
- evidence
- support model
- upgrade path

## Phase 3 — Audit Engine First

The audit is the central asset. It is the lead magnet, qualification engine, sales tool, scoring system, and reporting system.

Audit scoring categories:

| Area | Example |
|---|---|
| Google visibility | Missing or weak Maps presence |
| Website quality | Speed, mobile, contact clarity |
| Response speed | Missed call / slow reply risk |
| Quote friction | Contact and scoping complexity |
| Reviews | Rating, count, freshness, response quality |
| SEO | Missing service/suburb pages |
| Automation | No lead capture / no reminders |
| Admin maturity | Manual invoicing / weak follow-up |
| AI readiness | Opportunity score |

Output:

- instant score
- PDF/report
- top three fixes
- estimated missed revenue / admin leakage
- recommended tier
- CTA: book setup / request callback

## Phase 4 — Lead Infrastructure

Canonical lead sources:

| Source | Priority |
|---|---|
| Google Maps | High |
| Yellow Pages | High |
| hipages | Medium |
| Facebook pages | Medium |
| Service directories | Medium |

Lead registry fields:

- business_name
- trade
- suburb
- website
- email
- phone
- google_rating
- review_count
- source
- enrichment_status
- ai_score
- contact_status
- outreach_stage
- last_contacted
- owner
- notes

## Phase 5 — Qualification Scoring

Prioritise leads before outreach.

| Signal | Score Direction |
|---|---|
| No website | High opportunity |
| Bad website | High opportunity |
| Few reviews | Trust gap |
| High reviews but weak SEO | High conversion opportunity |
| Multiple vans/staff | Higher ability to pay |
| Expensive service category | Higher ROI |
| Fast-growing suburb | Higher demand |
| Poor response path | Strong AI Front Desk fit |

## Phase 6 — Outreach Runtime

Do not send one email and stop. Run sequenced outbound.

Channel stack:

| Channel | Use |
|---|---|
| Email | Primary |
| SMS | Follow-up where compliant and available |
| Phone | Warm conversions |
| Facebook | Awareness and enrichment |
| Google profile | Inbound trust check |
| Retargeting | Later |

Sequence:

| Day | Message |
|---|---|
| 0 | Short local email |
| 2 | Missed jobs / slow response reminder |
| 5 | Competitor visibility angle |
| 8 | Free audit reminder |
| 14 | Before/after example or case study |
| 30 | Reactivation |

## Phase 7 — Operational Delivery Engine

Delivery categories:

| Domain | Examples |
|---|---|
| Leads | Google, ads, capture |
| Sales | Follow-ups, quote reminders |
| Admin | Invoicing, bookings |
| Ops | Scheduling, reminders |
| AI Assistants | Phone, chat, email |
| Reporting | Weekly business scorecards |
| SOPs | Staff onboarding |
| Compliance | Templates, checklists |

## Phase 8 — Evidence Layer

Every client must generate evidence.

Evidence captured:

- rankings improved
- leads captured
- missed calls reduced
- response speed improved
- revenue increase
- admin hours saved
- quote turnaround improved
- reviews increased
- repeat bookings created

Store in canonical evidence registry and Reality Ledger.

## Phase 9 — Expansion Engine

After electricians proof:

- plumbers
- roofers
- landscapers
- builders
- HVAC
- pest control
- mechanics

Then expand vertically into:

- accountants
- lawyers
- clinics
- consultants
- local SMBs

## Worker Architecture

| Worker | Function |
|---|---|
| Lead Worker | Scraping and enrichment |
| Audit Worker | Website + SEO scoring |
| Outreach Worker | Email/SMS sequencing |
| Qualification Worker | Prioritisation |
| Sales Worker | Booking/follow-up |
| Delivery Worker | Setup/onboarding |
| Evidence Worker | Proof capture |
| Reporting Worker | Weekly metrics |
| Orchestrator Worker | Queue, retries, escalation, receipts |

## 14-Day Execution Plan

| Day Range | Objective |
|---|---|
| 1-2 | Lock electricians + offers |
| 2-4 | Build audit engine |
| 3-5 | Build lead registry |
| 4-6 | Build enrichment/scoring |
| 5-7 | Build outreach runtime |
| 6-8 | Build landing/audit flow |
| 8-10 | Launch first 50-100 |
| 10-12 | Capture proof |
| 12-14 | Refine and scale |

## Runtime Acceptance Gates

REAL requires:

- lead registry exists and is seeded
- audit engine returns scores
- outreach sequence configured
- landing/audit page live
- at least 50 Sydney electrician leads loaded
- first campaign batch sent or queued with receipts
- evidence registry active
- dashboard visible
- Reality Ledger receipt written

Until then, status remains PARTIAL / Runtime Candidate.

## Bridge Execution Payload Summary

Task: deploy Sydney Electricians AI4Tradies campaign runtime.

Required outputs:

- Supabase lead registry tables
- audit scoring tables/functions
- campaign sequence records
- landing page route
- lead capture endpoint
- evidence registry
- Command Centre campaign widget
- receipt JSON

No manual human loop unless blocked by credentials, legal, or spend authority.
