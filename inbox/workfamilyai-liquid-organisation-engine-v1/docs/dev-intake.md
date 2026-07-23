# Developer Intake — Liquid Organisation Engine v1

## Build objective
Create an interactive application that lets a user assess a whole organisation, one pillar, team or role; run scenarios; compare predicted outcomes; see why the prediction was made; and record actual responses for calibration.

## Required surfaces
1. Organisation baseline wizard
2. 10-variable radar and evidence view
3. 10x10x10 role explorer
4. Role detail page
5. Artefact and dependency graph
6. AI Sweet Spots heatmap
7. AI Blackspots heatmap
8. Scenario builder and comparison
9. Evolutionary-state mixture view
10. Prediction explanation panel
11. Intervention planner
12. Saved runs, outcomes and receipts

## User journey
1. Select or create organisation.
2. Import role runtime records or use canonical 1,000-role defaults.
3. Answer baseline questions; allow evidence-backed prefill.
4. Review variable scores, confidence and unknowns.
5. Explore role, pillar and organisation heatmaps.
6. Select a predefined scenario or create a custom one.
7. Set severity, duration, affected roles and constraints.
8. Execute transparent rule engine.
9. Review first-order and cascading consequences.
10. Select intervention options.
11. Save a prediction receipt.
12. Record actual response and outcome later.
13. Compare predicted versus observed and recalibrate.

## Initial data model
- organisation
- pillar
- role_record
- artefact
- dependency
- variable_definition
- assessment
- assessment_response
- evidence_reference
- scenario_definition
- scenario_run
- prediction
- intervention
- observed_outcome
- receipt

## Prediction object
Each prediction must include:
- scope and affected role IDs
- baseline variable values
- pressure changes
- dependency propagation path
- expected direction and magnitude band
- time horizon
- sweet spots
- blackspots
- human effects
- required artefacts and decisions
- intervention options
- confidence
- evidence provenance
- assumptions
- falsification measure

## Transparent scoring v1
- Score each variable from 0–100.
- Keep source, freshness and confidence separate from score.
- Calculate sweet-spot eligibility from AI Fit, Artefact Integrity, Authority Clarity, Human Capacity and Trust/Flourishing.
- Calculate blackspot flags with explicit rules; do not average critical risks away.
- Propagate scenario impacts through named role and system dependencies.
- Display rule traces in plain language.
- Treat outputs as directional until calibrated against observed outcomes.

## Interaction requirements
- Ask one relevant question at a time.
- Skip questions already answered by fresh evidence.
- Explain why a question matters.
- Permit unknown as a valid response.
- Surface missing evidence rather than forcing false precision.
- Let users challenge a score or prediction.
- Show how changing one variable changes the result.
- Preserve scenario versions and comparisons.

## Non-negotiable constraints
- No human-elimination optimisation.
- Human authority for high-consequence decisions.
- Explicit appeal, override and recovery pathways.
- Cognitive diversity and varying work patterns supported.
- No unsupported productivity multipliers.
- No opaque prediction without an explanation trace.
- Every saved run emits a receipt.

## Suggested implementation sequence
### Build 1 — Data spine
Load the 1,000 role records, artefact registry, dependencies and ten variables.

### Build 2 — Baseline assessment
Adaptive questions, scoring, evidence confidence and saved assessment receipts.

### Build 3 — Role explorer
Role detail, heatmaps, artefacts, KPIs, onboarding, offboarding and future state.

### Build 4 — Scenario engine
Predefined and custom scenarios with transparent dependency propagation.

### Build 5 — Sweet Spots and Blackspots
AI fit recommendations, hard blackspot rules and intervention options.

### Build 6 — Predictive learning loop
Capture observed outcomes, compare predictions, calibrate weights and preserve model versions.

### Build 7 — Canon integration
Connect state mix, Evolutionary Engine, OIKOS and Runtime evidence.

## Completion evidence
- deployed URL
- test organisation seeded
- all 1,000 roles searchable
- at least 10 scenarios executable
- question paths verified
- prediction traces visible
- receipts replayable
- observed outcome capture working
- telemetry dashboard live
