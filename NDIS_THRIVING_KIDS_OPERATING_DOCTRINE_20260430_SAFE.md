# NDIS + Thriving Kids Operating Doctrine

Date: 2026-04-30
Owner: Tech 4 Humanity
Repo: TML-4PM/the-pen
Status: PEN handoff ready
Reality status: PARTIAL until runtime proof exists

## Purpose

Codify the strategic operating response to current NDIS, Thriving Kids, Foundational Supports, early childhood, provider compliance, school support, and evidence requirements.

This document is non-clinical and non-legal. It does not diagnose, determine eligibility, or replace professional judgement. It defines product, operating, campaign, and evidence architecture.

## Strategic bottom line

The funded support environment is shifting from broad access and flexible delivery toward structured pathways, stronger provider controls, shorter intervention windows, and clearer evidence requirements.

The market need is a cross-system operating layer that helps families, schools, providers, and support organisations understand needs, act quickly, track progress, and produce usable evidence.

The operating loop is:

Detect early -> intervene fast -> prove quickly -> defend support -> escalate with evidence -> monetise -> replicate.

For provider-side products the loop is:

Build -> enforce -> prove -> recover -> monetise -> replicate.

## Core architecture

AI Sweet Spots is the root product.

It is the entry, profile, signal, routing, and evidence engine. It should not be treated as a simple quiz.

Reading Buddy is a specialist education add-on. It should focus on reading, learning, comprehension, attention, regulation, and school-aligned improvement over time.

The agents are not separate products per market. They are one reusable agent framework packaged differently for parents, schools, providers, workforce, accountants, AI fraternities, and other sectors.

The durable spine is:

AI Sweet Spots -> Identity -> ConsentX -> LifeGraph -> Signals -> Applications -> Evidence -> Updated Profile.

## Priority audiences

1. Parents and participants needing practical next steps.
2. Schools needing structured student support and twice-exceptional pathways.
3. Providers needing stronger evidence, documentation, and compliance-ready workflows.
4. Broader sectors that can reuse the same agent and profile system with different packaging.

## Twice-exceptional school pathway

Twice-exceptional learners must be explicit in the school strategy.

The product should identify uneven profiles where high strengths and high friction coexist. The message is:

Not underperforming. Misaligned.

Outputs should include parent explanation, teacher strategy pack, classroom adjustment guidance, strength-friction map, and Reading Buddy routing where literacy or comprehension friction appears.

## Product modules

1. AI Sweet Spots assessment and profile.
2. Functional and cognitive profile summary.
3. Parent navigation output.
4. School support output.
5. Provider evidence output.
6. Short-cycle intervention planner.
7. Reading Buddy education add-on.
8. Evidence pack generator.
9. Campaign and touchpoint tracker.
10. Reality Ledger evidence binding.

## Build sequence: May to September 2026

May: foundation and spine.
- AI Sweet Spots child and participant mode.
- Functional profile model.
- Consent and identity baseline.
- Signal event schema.
- Parent, school, provider report v1.

June: intervention and evidence.
- Reading Buddy v1.
- Two to three week intervention cycle templates.
- Baseline to delta tracking.
- Parent navigation flow.

July: campaign and pilots.
- Parent landing page.
- School landing page.
- Provider landing page.
- Segmented outreach dataset.
- Pilot onboarding for schools and parent cohorts.

August: harden and monetise.
- Pricing packages.
- Paid evidence reports.
- Provider readiness offer.
- School pilot pack.

September: conversion and readiness.
- Customer onboarding.
- Sales scripts.
- Public launch assets.
- October readiness campaign.

October: capture transition demand.
- Launch parent protection offer.
- Launch school execution offer.
- Launch provider evidence offer.
- Feed all interactions back into LifeGraph, Signals, and AI Sweet Spots.

## Data model summary

Core tables to implement:

- ass_person
- ass_consent_grant
- ass_assessment_session
- ass_sweet_spot_profile
- ass_signal_event
- ass_intervention_cycle
- ass_evidence_pack
- ass_pathway_assignment
- ass_campaign_touchpoint

## Agent family

Core agents:

- Intake Agent
- Interpretation Agent
- Routing Agent
- Planning Agent
- Progress Agent
- Evidence Agent
- Escalation Agent
- Campaign Agent

Packaging layers:

- Parent pack
- School pack
- Provider pack
- Workforce pack
- Sector pack

Applications:

- AI Sweet Spots as root engine
- Reading Buddy as education add-on
- Outcome Ready as evidence and provider outcomes layer
- Augmented Humanity Coach as workforce and human augmentation layer

## Campaign doctrine

Master message:

The system is changing. You do not have to wait for it.

Parent message:

Start now with structured guidance, measurable support, and evidence you can use.

School message:

Schools need practical student profiles, short intervention cycles, progress evidence, and escalation-ready reports.

Provider message:

Providers need clearer outcomes, stronger documentation, and compliance-ready evidence workflows.

Twice-exceptional message:

Not underperforming. Misaligned.

## Acceptance gates

The work is not REAL until these gates pass:

1. Execution proof: schema deploys, assessment works, profile generates, pathway assigns, evidence pack generates.
2. Coverage proof: parent, school, provider, 2e, and Reading Buddy flows exist.
3. Reality Ledger proof: every major output has intent, execution, output, classification, and evidence.
4. Campaign proof: segments, messages, touchpoints, and response states are trackable.
5. Monetisation proof: parent, school, and provider offers have pricing and payment path.
6. Replication proof: at least one non-NDIS/non-school sector pack exists.

## Immediate task queue for PEN

1. Create Supabase migration for core tables.
2. Create seed records for parent, school, provider, 2e, and workforce packs.
3. Create AI Sweet Spots assessment v1.
4. Create scoring placeholders for profile, pathway, 2e, and confidence.
5. Create evidence pack generator.
6. Create short-cycle intervention generator.
7. Create Reading Buddy integration stub.
8. Create parent, school, and provider landing page copy.
9. Create campaign message sets.
10. Create Reality Ledger binding pattern.
11. Create Symbio DEV handoff.
12. Return GitHub receipt and proof status.

## Final operating rule

Do not create separate product systems for every sector.

Create one root intelligence, identity, consent, signal, intervention, and evidence loop.

Package it differently.

Reading Buddy is a specialist education application.

AI Sweet Spots is the root product.
