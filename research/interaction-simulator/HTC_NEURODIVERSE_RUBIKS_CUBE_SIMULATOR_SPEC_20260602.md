# Human × Technology × Context Simulator
## Neurodiverse Rubik's Cube / Organisational Norm Engine

**Status:** v1.3 candidate  
**Date:** 2026-06-02  
**Owner:** TML-4PM / Tech 4 Humanity  
**Purpose:** Codify the user-facing calculator, simulator, Rubik's Cube interaction model, study-ingestion engine, multi-view 10×10×10 reasoning system, and shape hierarchy for predicting how humans, technologies, machines, contexts, research topics, and organisational systems interact.

---

## 1. Core Question

The simulator exists to answer three questions:

1. What happens when this human meets this technology under these conditions?
2. What happens when this human changes the technology?
3. What happens when the technology changes the human?

This invariant sits under AI Sweet Spots, WorkFamilyAI, ConsentX, HoloOrg, MyNeuralSignal, GC-BAT, RATPAK, NEUROPAK, Social Media Ban / Digital Child Protection, Drug Resilience Atlas, Reality Ledger, and related Tech 4 Humanity studies.

---

## 2. Shape Hierarchy Decision

The cube and dodecahedron are not competing models.

They are different objects at different levels of granularity.

### Theme = Shelf / Domain

A theme is not a cube.

A theme is a domain or shelf that contains many subtopic cubes.

Examples:
- The Performing Human
- The Developing Human
- The Biological Human
- The Governed Human
- The Sovereign Human
- The Economic Human
- The Future Human

Purpose:
- organise research estate
- show portfolio balance
- group related subtopics
- support funding / programme narrative

### Subtopic = Cube

A subtopic should be represented as a cube.

Reason:
- it is stable enough to be reusable
- it has repeatable dimensions
- users can rotate it
- it can support multiple studies
- it is simple enough to explain and interact with

Default cube faces:
1. Human
2. Technology / Machine
3. Context
4. Change / Question
5. Signal
6. Outcome

Example:

Subtopic:
`Consent Fatigue Modelling`

Cube:
- Human: citizen / patient / employee / parent
- Technology: consent interface / portal / AI agent
- Context: government / healthcare / workplace
- Change: repeated consent prompts
- Signal: abandonment / confusion / trust decay
- Outcome: compliance, fatigue, refusal, safer design

### Study = Dodecahedron When Needed

A study can be represented as a dodecahedron when the work needs richer state tracking.

Not every study needs the dodecahedron in the user interface.

The dodecahedron is best for research, audit, evidence, IP, and commercialisation state.

Default dodecahedron faces:
1. Problem
2. Hypothesis
3. Experiment
4. Population
5. Technology / Machine
6. Context
7. Evidence
8. Signal
9. Risk / Ethics
10. IP / Novelty
11. Productisation / Asset
12. Commercialisation / Impact

Example:

Study:
`Consent Prompt Frequency and Trust Decay in Government Portals`

Dodecahedron:
- Problem: repeated consent prompts cause abandonment
- Hypothesis: fatigue reduces valid consent quality
- Experiment: vary prompt frequency and clarity
- Population: citizens, elderly, migrants, neurodivergent users
- Technology: government portal / consent ledger
- Context: public service access
- Evidence: completion rates, abandonment, survey trust score
- Signal: time-to-consent, refusal rate, support calls
- Risk: exclusion, coercion, invalid consent
- IP: consent fatigue classifier
- Product: ConsentX design audit
- Commercialisation: government advisory / compliance pack

---

## 3. Why This Simplifies Complexity

The model looks more complex but is actually simpler operationally.

Without shape hierarchy:
- every study creates a new model
- every subtopic becomes ambiguous
- every asset needs custom explanation
- users do not know where to enter

With shape hierarchy:
- themes organise
- subtopic cubes let people explore
- study dodecahedrons track evidence/IP/commercial state
- the database stays normalised
- the interface can remain intuitive

The rule:

```
Theme = shelf
Subtopic = cube
Study = dodecahedron when state complexity matters
Asset = card / node / evidence object
```

---

## 4. Avoiding Shape Explosion

Do not create a bespoke cube for every study.

That creates noise.

Instead:

- every subtopic gets one reusable cube template
- studies inside the subtopic inherit that cube
- studies may add a dodecahedron state layer if needed
- assets attach as cards/nodes/evidence rows

This lets ten studies inside one subtopic share the same cube but have different dodecahedron states.

Example:

Subtopic cube:
`AI Sweet Spot Curves`

Studies inside it:
1. ADHD AI Intensity Curve
2. Autism Communication Curve
3. Dyslexia Modality Curve
4. Neurotypical Overreliance Curve
5. Elderly Cognitive Prosthetic Curve

Each study inherits the same cube faces but has its own dodecahedron state.

---

## 5. Shape Selection Rules

Use a cube when the goal is:
- user interaction
- scenario exploration
- role impact
- simulator input
- quick comparison
- teaching the concept

Use a dodecahedron when the goal is:
- research governance
- audit evidence
- IP protection
- commercialisation readiness
- study maturity
- ATO/R&D support
- grant defensibility

Use cards/nodes when the goal is:
- attaching assets
- listing documents
- showing evidence
- linking datasets
- linking prices/products
- linking repositories

---

## 6. Multi-View 10×10×10 System

The 10×10×10 is not a single fixed cube.

It is a view generator.

Views include:
1. Human × Technology × Context
2. Role × Study × Variable
3. Executive Lens × Machine Impact × Outcome
4. Human Profile × Role Level × Organisation Norm
5. Study Theme × Subtopic × Evidence Signal
6. Business Activity × Affected Role × Intervention
7. Person × Machine × Feedback Loop
8. Customer/Citizen × System × Service Outcome
9. Agent × Task × Governance Constraint
10. Time × State × Drift

The same subtopic cube can be viewed through any of these 10×10×10 cuts.

The same study dodecahedron can be inspected through any of these cuts.

---

## 7. Study Ingestion Model

Every new study or subtopic must be ingestible without redesigning the system.

A new topic should be converted into a standard study object.

Fields:
- study_id
- theme
- subtopic
- hypothesis
- study_stage: novel | extension | applied_hypothesis | active | completed | rejected | dormant
- evidence_status: REAL | PARTIAL | HYPOTHESIS | BLOCKED
- target_human_profiles
- target_role_groups
- target_technology_profiles
- target_machine_systems
- target_contexts
- affected_variables
- expected_positive_impacts
- expected_negative_impacts
- expected_machine_impacts
- expected_organisation_impacts
- measurement_signals
- evidence_links
- asset_links
- ip_links
- business_alignment
- monetisation_path
- ethics_or_consent_flags
- norm_required
- confidence
- shape_type: cube | dodecahedron | card | node
- parent_cube_id

---

## 8. Default Cube Faces

Subtopic cubes use six faces by default.

### Face 1 — Human
- role
- level
- cognitive profile
- neurodiversity
- confidence
- trust
- digital maturity
- support need

### Face 2 — Technology / Machine
- technology class
- autonomy level
- interface mode
- explainability
- risk
- integration level
- signal capture
- feedback loop

### Face 3 — Context
- organisation
- industry
- team
- geography
- regulation
- culture
- pressure

### Face 4 — Change / Study Question
- rollout
- policy change
- restructure
- new tool
- compliance obligation
- crisis
- new study topic
- new hypothesis

### Face 5 — Signal
- trust
- stress
- productivity
- error rate
- adoption
- dependency
- engagement
- learning
- machine adaptation
- signal integrity

### Face 6 — Outcome
- sweet spot
- black spot
- neutral
- uplift
- risk
- recommended next action
- evidence gap
- machine/system change

---

## 9. Default Dodecahedron Faces

Study dodecahedrons use twelve faces when richer state is required.

1. Problem
2. Hypothesis
3. Experiment
4. Population
5. Technology / Machine
6. Context
7. Evidence
8. Signal
9. Risk / Ethics
10. IP / Novelty
11. Productisation / Asset
12. Commercialisation / Impact

Each face should carry:
- score
- status
- evidence link
- owner
- next action

---

## 10. Product Interpretation

For a user:
- show the cube first
- keep the dodecahedron mostly hidden
- expose the dodecahedron as an advanced research/audit/commercial view

For researchers:
- show both cube and dodecahedron

For executives:
- show cube result plus scorecard

For ATO/R&D:
- show dodecahedron evidence state

For product teams:
- show asset cards attached to cube and dodecahedron faces

---

## 11. Definition of Done

The simulator is not done until:

- every theme can contain subtopic cubes
- every subtopic can instantiate a cube
- every study can inherit from a subtopic cube
- every study can optionally generate a dodecahedron state view
- every face links to evidence, assets, variables, roles, machines, and outcomes
- multiple 10×10×10 views can cut across the same objects
- users can explore simply while researchers can inspect deeply

---

## 12. Reality Ledger

**Task:** Decide whether every topic/subtopic/study becomes a cube or dodecahedron.

**Decision:** Theme = shelf/domain. Subtopic = reusable cube. Study = dodecahedron when richer evidence/IP/commercial/governance state is required. Assets = cards/nodes/evidence objects.

**Status:** PARTIAL until implemented in UI/schema.

**Evidence:** This specification committed to GitHub.

**Next action:** Add schema fields for shape_type, parent_cube_id, face definitions, and dodecahedron state records.
