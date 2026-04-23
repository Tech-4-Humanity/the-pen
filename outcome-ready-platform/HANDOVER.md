# Outcome Ready Platform — Bridge Handover

Status: PARTIAL / UNPROVEN
Date: 2026-04-24
Destination repo: TML-4PM/the-pen
Source threads: Reading Buddy / Maths Mate / Wellbeing / Outcome Ready consolidation

## Reality Ledger Classification

| Area | Status | Notes |
|---|---|---|
| Product architecture | REAL | Defined in chat and ready for execution. |
| Existing front end | PARTIAL | Reading Buddy Vercel app exists: https://reading-buddy-by-outcome-ready.vercel.app/ |
| GitHub source repos | PARTIAL | Compare and consolidate readingmate and reading-buddy repos. |
| Maths Mate | PRETEND | Required by mirroring Reading pages and customising content, not yet built/proven here. |
| Wellbeing / Thrive Mate | PARTIAL | CalmBound and SM Ban Watch exist as adjacent systems but are not yet integrated. |
| AI Sweet Spots assessments | PARTIAL | Assessment site exists: https://aisweetspots.com/assessments but must be wired into Outcome Ready flows. |
| Email infra | PRETEND | readingbuddy@outcome-ready.com is not set up. Preferred product mailboxes listed below. |
| Mono-repo | PRETEND | Must be created/merged by the pen/bridge runner. |
| Supabase backend | PRETEND | Schema supplied, not applied in this chat. |
| Deployment automation | PRETEND | Bridge payload supplied, not run in this chat. |

## One-line Intent

Build Outcome Ready into a multi-domain learning, wellbeing, and capability platform with Reading Mate, Maths Mate, Thrive Mate, Adult Mode, AI Sweet Spots assessments, SM Ban Watch, and CalmBound integrated into a single measurable loop.

## Current User Direction

The user wants the website worked out now, specifically:

- Mirror Reading pages for Maths and Wellbeing.
- Customise content so Maths Mate has its own identity, copy, email, and web presence.
- Bring Reading, Maths, Wellbeing, Adult services, subjects, and packs together.
- Keep the adult site under the same naming family as the kids site. It was previously Reading Mate. It will now be differentiated by content and services rather than a separate unrelated brand.
- Create a clear list of what differs between kids and adults and why.
- Compare and contrast:
  - https://github.com/TML-4PM/readingmate
  - https://github.com/TML-4PM/reading-buddy
- Email warning: readingbuddy@outcome-ready.com is not set up.
- Naming warning: we do not own Reading Buddy cleanly; avoid over-indexing on that as the long-term brand.
- No ThrivingOS domain exists right now; Outcome Ready is the play.
- Make https://aisweetspots.com/assessments live/real as the diagnostic entry point.
- Add links to:
  - SM Ban Watch: https://sm-ban-watch.lovable.app/
  - CalmBound: https://calmbound-system.vercel.app/
- Product bulletin required.
- PRFAQ required.

## Product Model

Outcome Ready Platform contains:

1. Reading Mate / Reading Buddy Mode
   - Literacy, comprehension, reading confidence, phonics, fluency, guided reading.
2. Maths Mate
   - Numeracy, maths confidence, real-world problem solving, decision maths, money/time/logic.
3. Thrive Mate / Wellbeing Mode
   - Calm, focus, emotional regulation, behaviour signals, screen-time context, intervention pathways.
4. Adult Mode
   - Same platform pattern, different content and voice: capability uplift, workplace reading, numeracy, decision-making, executive/function-specific learning, wellbeing and burnout prevention.
5. Assessments
   - AI Sweet Spots becomes the diagnostic doorway feeding recommendations, packs, reports, and subscriptions.

## Strategic Shift

This is no longer just a reading app. It is an Outcome Ready learning + wellbeing + human capability system.

Core loop:

Assess -> Adapt -> Intervene -> Improve -> Prove -> Report -> Monetise -> Replicate

## Required Frontend Pages

Minimum page set for the first build:

- `/` Outcome Ready landing page
- `/reading` Reading Mate / Reading Buddy page
- `/maths` Maths Mate page
- `/wellbeing` Thrive Mate / Wellbeing page
- `/adult` Adult capability page
- `/assessments` Assessment entry page or strong link to AI Sweet Spots
- `/packs` Product/service packs
- `/schools` School/education offer
- `/parents` Parent/family offer
- `/providers` NDIS/allied/therapy/provider-facing offer if used
- `/about` Outcome Ready positioning
- `/contact` with working forms and product-specific email routing
- `/bulletin` Product bulletin page
- `/prfaq` PRFAQ page

## Product Emails

Do not rely on readingbuddy@outcome-ready.com until configured.

Preferred scalable mailboxes:

- hello@outcome-ready.com
- reading@outcome-ready.com
- maths@outcome-ready.com
- thrive@outcome-ready.com
- schools@outcome-ready.com
- parents@outcome-ready.com
- partners@outcome-ready.com

If email infra is not ready, render mailto links only after verification. Otherwise use forms that write to Supabase lead tables and optionally send via SES/Migadu after verification.

## Kids vs Adults Differentiation

| Dimension | Kids | Adults | Why |
|---|---|---|---|
| Voice | Buddy, encouraging, playful | Coach, direct, capable | Trust model and motivation differ. |
| Content | Stories, school tasks, games, guided exercises | Workplace documents, life admin, decisions, reports, planning | Relevance drives adoption. |
| UX | Visual, short, parent-safe, progress badges | Minimal, efficient, dashboard/report driven | Adult users want outcome and proof, not gamification. |
| Stakeholders | Child, parent, teacher, provider | Individual, employer, manager, coach | Buying and reporting chains differ. |
| Metrics | Reading level, confidence, task completion, behaviour signals | Time saved, comprehension, productivity, decision quality, wellbeing | Different ROI stories. |
| Consent | Guardian/child-safe controls | Self-consent, workplace/privacy controls | Governance and law differ. |
| Interventions | Micro-lessons, encouragement, parent tips | Coaching scripts, job aids, executive summaries, behavioural nudges | The same engine, different intervention packaging. |
| Packs | School, parent, tutor, therapy/provider | Individual, team, enterprise, leader, return-to-work | Different distribution and pricing. |

## Integrations

### AI Sweet Spots

Use as the assessment and intake engine:

- Current link: https://aisweetspots.com/assessments
- Required: either embed, redirect, or replicate assessment modules inside Outcome Ready.
- Every assessment must create a result record, recommendation, and next action.

### SM Ban Watch

Use as a policy/context signal:

- Current link: https://sm-ban-watch.lovable.app/
- Product role: child safety, social media ban context, parent/school trust layer, external signal library.
- Add link from Wellbeing and Parent pages.

### CalmBound

Use as the wellbeing/intervention layer:

- Current link: https://calmbound-system.vercel.app/
- Product role: calm/focus/regulated-state pathways, wellbeing packs, behaviour intervention options.
- Add link from Wellbeing, Schools, Parent, and Adult pages.

## Required Build Order

1. Inspect both repos:
   - TML-4PM/readingmate
   - TML-4PM/reading-buddy
2. Identify strongest app baseline and do not blindly merge junk.
3. Create monorepo or clean app repo structure.
4. Preserve current Reading pages and mirror to Maths and Wellbeing.
5. Replace content, icons, CTAs, offers, and assessment prompts by domain.
6. Add shared component system: product cards, pack cards, CTAs, intake form, assessment card, proof/report card.
7. Add Supabase schema for leads, assessments, interventions, products, packs, events, and proof logs.
8. Add form handlers with environment-gated email sending.
9. Add links to AI Sweet Spots, SM Ban Watch, and CalmBound.
10. Add PRFAQ and Product Bulletin pages.
11. Add Bridge Runner payload and smoke tests.
12. Deploy to Vercel only after build passes locally.
13. Write receipt with commit SHA, deployed URLs, smoke test results, and any blockers.

## Do Not Do

- Do not claim email works until DNS/provider verification is proven.
- Do not claim Supabase is wired until forms write rows and rows can be read.
- Do not rename everything to ThrivingOS until the domain/brand strategy is locked.
- Do not make Reading Buddy the long-term top-level brand because name ownership is weak.
- Do not build a giant static brochure without one working assessment -> recommendation -> lead/report loop.

## Definition of Real Done

A user can:

1. Land on Outcome Ready.
2. Choose Reading, Maths, Wellbeing, or Adult.
3. Complete an assessment/intake.
4. Receive a recommendation.
5. Generate a lead/report/action record.
6. Trigger a confirmation email or stored outbound event.
7. See their action reflected in Supabase.
8. The build has smoke tests and a written receipt.

Until that loop is proven, status remains PARTIAL, not FINAL.
