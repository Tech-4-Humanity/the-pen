# Outcome Ready Platform — Build Specification

## Build Name
Outcome Ready Learning + Wellbeing Platform

## Goal
Turn the current Reading Buddy / Reading Mate material into a unified platform with Reading, Maths, Wellbeing, Adult capability, assessment, reporting, and evidence loops.

## Repositories To Inspect

- https://github.com/TML-4PM/readingmate
- https://github.com/TML-4PM/reading-buddy

Compare before merging. Choose the strongest running baseline. Do not blindly combine broken files.

## Target App Structure

Recommended monorepo layout:

```txt
outcome-ready/
  apps/
    web/                    # main Outcome Ready site
    reading/                # Reading Mate mode if separated
    maths/                  # Maths Mate mode if separated
    wellbeing/              # Thrive Mate / wellbeing mode if separated
    adult/                  # Adult content mode if separated
  packages/
    ui/                     # shared cards/buttons/layout/forms
    content/                # domain copy, packs, voice settings
    assessments/            # diagnostic question sets + scoring
    supabase/               # generated client/helpers
    email/                  # email templates + sender adapters
  supabase/
    migrations/
    seed/
  bridge/
    payloads/
    receipts/
  docs/
    prfaq.md
    product-bulletin.md
    architecture.md
    kids-vs-adults.md
```

If existing codebase is a single Next/Vite app, keep it simple: use `/src/pages` or `/app` routes and do not overbuild the monorepo until one loop is real.

## Required Routes

| Route | Purpose |
|---|---|
| `/` | Outcome Ready master landing page |
| `/reading` | Reading Mate / Reading Buddy product page |
| `/maths` | Maths Mate product page |
| `/wellbeing` | Thrive Mate / wellbeing product page |
| `/adult` | Adult capability mode |
| `/assessments` | Diagnostic entry point, link or embed AI Sweet Spots |
| `/packs` | Product and service packs |
| `/schools` | School and education buyer page |
| `/parents` | Parent/family buyer page |
| `/providers` | Providers, NDIS, allied health, tutors, partners |
| `/bulletin` | Product bulletin |
| `/prfaq` | PRFAQ |
| `/contact` | Contact/intake form |

## Page Content Rules

### Reading
- Focus: literacy, comprehension, confidence, guided reading, reading progress.
- Use warm, companion style.
- CTA: Start reading assessment.

### Maths
- Mirror Reading page structure, but content must not look copied.
- Focus: numeracy, confidence, real-world problem solving, decision maths, time/money/logic.
- CTA: Start maths check.

### Wellbeing
- Mirror structure again.
- Focus: calm, focus, emotional regulation, digital pressure, social-media context, behaviour support.
- Link to CalmBound and SM Ban Watch.
- CTA: Start wellbeing check.

### Adult
- Same engine, different voice.
- Focus: workplace comprehension, decision-making, capability uplift, wellbeing, life admin, forms, productivity.
- No childish copy. No badges unless reframed as progress/proof.

## Shared Components

Build/reuse:

- ProductHero
- ProductCard
- PackCard
- AssessmentCTA
- EvidenceLoop
- ExternalSignalLinks
- ContactForm
- ReportPreview
- PersonaSwitcher

## External Links To Add

- AI Sweet Spots Assessments: https://aisweetspots.com/assessments
- SM Ban Watch: https://sm-ban-watch.lovable.app/
- CalmBound: https://calmbound-system.vercel.app/

## Minimum Working Loop

The first proven loop should be Reading because it has the most existing material.

1. User chooses Reading.
2. User completes a short intake/assessment.
3. App stores record in Supabase.
4. App returns a recommendation.
5. App offers pack/next action.
6. App logs telemetry/proof.
7. Optional: email event is queued/sent if email is configured.

Then clone the same pattern to Maths and Wellbeing.

## Build Quality Gates

- `npm install` succeeds.
- `npm run build` succeeds.
- Contact/assessment form validates client-side and server-side.
- Supabase env vars are documented.
- If Supabase unavailable, app must degrade gracefully with a visible `integration_pending` status, not crash.
- No claim that email works until verified.
- Receipt must include deployed URL, commit SHA, build result, test result, and known blockers.

## Product Pack Drafts

### Parent Starter Pack
- Reading check
- Maths check
- Wellbeing check
- Parent report
- 30-day improvement plan

### School Starter Pack
- Cohort screening
- Reading + Maths baseline
- Wellbeing pulse
- Teacher dashboard/report
- Intervention recommendations

### Provider Pack
- Child/family intake
- Learning + behaviour notes
- Intervention plan
- Report export
- Consent-aware records

### Adult Capability Pack
- Reading/work comprehension
- Decision maths
- Productivity/wellbeing check
- Personal plan
- Workplace-ready report

## Open Risks

- Name ownership: Reading Buddy is weak as long-term master brand.
- No ThrivingOS domain: do not lead with ThrivingOS yet.
- Email not set up: readingbuddy@outcome-ready.com must not be presented as live unless verified.
- Existing repos may contain divergent implementations; pick the strongest baseline.

## Builder Instruction

Ship the smallest real platform loop first, not a decorative mega-site. Once one loop is real, mirror to Maths and Wellbeing.
