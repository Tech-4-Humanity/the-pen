# Uplift: Open-Source Whiteboard Renderer Targets

## Status
PARTIAL

## Result
The reusable whiteboard/doodle renderer anatomical asset has been uplifted with two priority target applications:

1. AI4 Tradies
2. Thriving Kids

These are now recorded as first-class reuse targets for the shared renderer capability.

---

## Target 1: AI4 Tradies

### Purpose
Turn practical trade-business AI use cases into short, plain-language whiteboard explainers for tradies, subcontractors, small operators, apprentices, industry associations, insurers, suppliers, and local business networks.

### Core Audience
- Sole traders
- Small trade businesses
- Builders and subcontractors
- Electricians, plumbers, HVAC, carpenters, landscapers, cleaners, maintenance crews
- Admin staff and partners who run bookings, invoices, quotes, rosters, compliance, and customer follow-up

### Jobs To Be Done
- Explain AI without corporate jargon.
- Show how AI reduces admin drag.
- Convert business owners from curiosity to first workflow adoption.
- Package repeatable AI use cases as short videos.
- Support lead generation for AI4 Tradies products, workshops, templates, and advisory offers.

### Reusable Whiteboard Video Types
- “How AI helps a tradie quote faster”
- “From missed call to booked job”
- “Turning photos into job notes”
- “Invoice follow-up without awkward phone calls”
- “AI safety checklist for small operators”
- “The 5 admin jobs AI can take off your plate this week”
- “Before and after: one-person trade business with AI support”

### Standard Scene Pattern
```text
Pain point
  -> simple story
  -> manual workflow
  -> AI-assisted workflow
  -> business outcome
  -> next action
```

### Asset Output Targets
- 30-second social clips
- 60-second explainers
- 3-minute workshop intros
- carousel-to-video conversions
- trade association presentation inserts
- landing page hero videos
- onboarding/training clips

### Evidence / Metrics To Capture
- lead source
- completion rate
- click-through rate
- booked consults
- template downloads
- workshop signups
- quote-to-cash cycle reduction claims where evidenced
- admin hours saved claims where evidenced

---

## Target 2: Thriving Kids

### Purpose
Turn child, family, provider, school, and support-system concepts into gentle, trusted, clear whiteboard explainers that help families and providers understand pathways, supports, evidence, consent, and outcomes.

### Core Audience
- Parents and carers
- Children and young people, where age-appropriate
- Educators
- Allied health practitioners
- support coordinators
- providers
- community organisations
- policy and program stakeholders

### Jobs To Be Done
- Explain support journeys without overwhelming families.
- Make evidence, consent, progress, and outcomes visible.
- Convert complex program logic into calm and usable story assets.
- Support NDIS/provider/school/community communication.
- Create repeatable family-facing and provider-facing education modules.

### Reusable Whiteboard Video Types
- “What happens before the first support session?”
- “How progress evidence is collected without making life harder”
- “What a good child support plan looks like”
- “Consent, safety, and family choice explained simply”
- “How schools, providers, and families can stay aligned”
- “From concern to support pathway”
- “How small signals show whether a child is thriving”

### Standard Scene Pattern
```text
Family concern
  -> child context
  -> support pathway
  -> consent and trust
  -> intervention
  -> evidence of progress
  -> next safe step
```

### Asset Output Targets
- parent explainer videos
- provider onboarding clips
- school meeting support visuals
- policy explainer inserts
- social campaign clips
- workshop modules
- family journey walkthroughs
- funding/evidence pathway explainers

### Evidence / Metrics To Capture
- family comprehension signal
- provider adoption
- referral quality
- consent completion
- progress evidence completeness
- support plan clarity
- reduced rework or missed documentation
- outcome reporting strength

---

## Shared Renderer Contract Additions

Add the following fields when these two target classes call the renderer:

```json
{
  "target_program": "ai4_tradies | thriving_kids",
  "audience_segment": "string",
  "journey_stage": "awareness | education | onboarding | conversion | evidence | retention",
  "risk_tone": "commercial | family_safe | provider_safe | policy_safe",
  "call_to_action": "string",
  "evidence_required": true,
  "brand_overlay": "string",
  "reuse_permission": "cross_project"
}
```

## Spine Binding
This target uplift attaches AI4 Tradies and Thriving Kids to the previously registered anatomical item:

`spine/assets/anatomical-items/open-source-whiteboard-renderer.md`

The renderer is now explicitly available for both commercial small-business education and child/family/provider support pathway explanation.

## Gaps
- No rendered AI4 Tradies sample yet.
- No rendered Thriving Kids sample yet.
- No storyboard JSON examples committed yet.
- No Remotion implementation committed yet.
- No Bridge runtime receipt yet.

## Next Action
1. Commit two storyboard JSON samples.
2. Add Remotion template starter.
3. Generate first AI4 Tradies 60-second explainer.
4. Generate first Thriving Kids 60-second explainer.
5. Register outputs in the asset ledger and Command Centre.

## Elevation
This gives the renderer two sharply different proof targets: one commercial and practical, one family/provider trust-oriented. That is useful because the same anatomical item must prove it can flex across tone, risk, audience, and brand without becoming a one-off campaign asset.

## Pressure Flags
- reuse_pressure: high
- evidence_gap: runtime proof missing
- compliance_tone: Thriving Kids requires careful language, trust, consent, and evidence handling
- commercial_tone: AI4 Tradies requires direct value, time saved, leads, admin relief, and simple explanations

## Score
0.76

## Ledger
- task_id: uplift-whiteboard-renderer-ai4-tradies-thriving-kids
- intent: add AI4 Tradies and Thriving Kids as two priority reuse targets for the anatomical whiteboard renderer asset
- execution: GitHub spine target record created
- output: target uplift specification
- status: PARTIAL
- evidence: GitHub commit receipt from create_file response
- score: 0.76
