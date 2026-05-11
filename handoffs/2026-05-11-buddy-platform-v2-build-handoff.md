# Buddy Platform V2 — Bridge Build Handoff

## Source
Uploaded PRD: Buddy Platform V2 — Product Requirements Document, May 2026.

## Intent
Build Reading Buddy + Maths Buddy into a unified Australian K–6 multi-subject Buddy Platform with one learner profile, adaptive learning engines, teacher and parent portals, curriculum-aligned reporting, accessibility, school subscriptions, and white-label licensing.

## Build Scope

### Product Core
- Reading Buddy V2 adaptive reading engine.
- Maths Buddy V2 adaptive problem engine.
- Unified learner profile across all Buddy subjects.
- Teacher portal for class management, heatmaps, assignments, reporting, lesson plans, rubrics, and worksheet/resource generation.
- Parent portal for weekly summaries, session history, consent, notifications, and home practice guidance.
- Future Buddy extensibility for Writing, Spelling, Science, Wellbeing, and NAPLAN.

### Technical Baseline
- AWS ap-southeast-2 hosting for Australian data residency.
- Multi-tenant SaaS model with school-level segregation.
- Offline-capable PWA with service workers and IndexedDB.
- Google Classroom integration for roster sync and grade passback.
- CSV roster import.
- DynamoDB telemetry stream to real-time dashboards.
- K–12 LLM moderation layer.
- Student data excluded from LLM training.
- WCAG 2.1 AA, dyslexia-friendly font, high contrast, dark mode, NDIS/accommodation flags, and EAL/D support.

### Commercial Baseline
- School subscription tier with per-seat pricing.
- White-label licensing mode for tutoring centres and resellers.
- Free individual student tier with limited daily sessions.
- NDIS-aware purchasing/support pathway.

## Work Packages

### WP1 — Canonical Data Model
Create schemas/entities for organisations/schools, classes, students, guardians, teachers, learner_profile, subject_skill_state, session_events, reading_attempts, maths_attempts, mastery_badges, accommodation_flags, consent_records, curriculum_descriptors, assignments, reports, subscriptions, and white_label_tenants.

### WP2 — Adaptive Engines
Implement reading level adjustment using WCPM, accuracy, miscue category, comprehension score, and stamina; phonics decoding assistance; sight word mastery with spaced repetition; maths diagnostic placement; adaptive problem generation; hint ladder; partial credit; error pattern detection; targeted drill prescription.

### WP3 — Portals
Build student dashboard, teacher dashboard, and parent dashboard with the required PRD capability set.

### WP4 — Safety, Privacy, Governance
Implement Australian Privacy Act aligned export/deletion workflows, under-13 parental consent, K–12 LLM moderation, audit logging, and no-student-data-training enforcement.

### WP5 — Monetisation and GTM Readiness
Implement school subscription checkout/provisioning, white-label tenant setup, free tier gating, NDIS-aware family purchase pathway, and onboarding funnel.

### WP6 — Telemetry and Evidence
Track DAU, session completion, pre/post diagnostic gain, weekly active teachers, school subscriptions, parent report open rate, mastery progression, abandoned sessions, and accessibility mode use.

## Acceptance Tests
- Student can complete Reading Buddy and Maths Buddy sessions under one learner profile.
- Teacher can create class, add students, assign work, and export PDF report.
- Parent can view progress, receive weekly summary, and manage consent/session limits.
- Adaptive engines adjust difficulty from live student performance.
- PWA works offline for cached session content.
- Accommodation flags alter session presentation.
- LLM tutor refuses unsafe/inappropriate content and remains Socratic.
- Telemetry events are captured and visible in dashboard.
- School subscription and white-label tenant flows are stubbed or live depending on credentials.

## Bridge Payload

```json
{
  "task_id": "buddy-platform-v2-build-20260511",
  "intent": "Build Buddy Platform V2 from PRD into executable product backlog, architecture, data model, portal implementation plan, telemetry, governance, and commercial launch path.",
  "source_artifact": "Buddy Platform V2 PRD uploaded May 2026",
  "target_repo": "TML-4PM/the-pen",
  "target_path": "handoffs/2026-05-11-buddy-platform-v2-build-handoff.md",
  "systems": ["Reading Buddy", "Maths Buddy", "Buddy Platform", "Outcome Ready", "Tech4Humanity"],
  "execution_mode": "NO_HITL_UNLESS_CREDENTIALS_LEGAL_SAFETY_OR_DESTRUCTIVE_ACTION",
  "required_outputs": ["canonical schema", "implementation backlog", "adaptive engine contracts", "portal contracts", "privacy and safety controls", "telemetry events", "commercial launch path", "runtime smoke tests", "receipt"],
  "classification": "PARTIAL_UNTIL_RUNTIME_EXECUTION_AND_SMOKE_TESTS",
  "next_executor": "bridge_or_symbio_dev"
}
```

## Reality Ledger

| Field | Value |
|---|---|
| task_id | buddy-platform-v2-build-20260511 |
| intent | Convert Buddy Platform V2 PRD into bridge-ready execution package |
| execution | GitHub handoff file created in the-pen |
| output | Build handoff, work packages, bridge payload, acceptance tests |
| status | PARTIAL |
| evidence | GitHub commit receipt required from connector response |
| gaps | Runtime bridge execution, deployment, smoke tests, telemetry dashboard, credential-bound integrations |
| next_action | Bridge/Symbio executor consumes this handoff and runs build pipeline |
| elevation | Moves Buddy from PRD into executable portfolio build package with product, technical, governance, telemetry, and commercial layers |
| pressure_flags | stagnation=false; drag=false; regression=false |
| score | execution=0.65; evidence=0.55; economic=0.9; reuse=0.95; delta=0.85 |

## Close Condition
This task is closed at handoff level only when GitHub commit receipt is returned. It becomes REAL operationally only after Bridge/Symbio runtime execution, smoke tests, and telemetry evidence are returned.
