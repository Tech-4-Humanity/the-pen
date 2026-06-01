# Human × Technology × Context Simulator
## Neurodiverse Rubik's Cube / Organisational Norm Engine

**Status:** v1.0 candidate  
**Date:** 2026-06-02  
**Owner:** TML-4PM / Tech 4 Humanity  
**Purpose:** Codify the user-facing calculator, simulator, and Rubik's Cube interaction model for predicting how humans, technologies, and contexts interact across an organisation.

---

## 1. Core Question

The simulator exists to answer three questions:

1. What happens when this human meets this technology under these conditions?
2. What happens when this human changes the technology?
3. What happens when the technology changes the human?

This is the same invariant that sits under AI Sweet Spots, WorkFamilyAI, ConsentX, HoloOrg, MyNeuralSignal, GC-BAT, RATPAK, NEUROPAK, and related Tech 4 Humanity studies.

The user does not enter through a research taxonomy. The user enters through themselves, their role, their technology, their organisation, and the change being considered.

---

## 2. Product Forms

The system can appear as three related products.

### 2.1 Calculator

A calculator gives a quick scored result.

Input:
- person profile
- role
- organisation profile
- technology/change
- optional neurodiversity/cognitive profile

Output:
- fit score
- risk score
- likely uplift
- overload risk
- dependency risk
- training need
- recommended intervention

Use case:
- landing page
- lead magnet
- board briefing
- individual self-assessment

### 2.2 Simulator

A simulator runs multiple people, roles, teams, and conditions.

Input:
- organisation norm profile
- role groups
- change scenario
- technology profile
- cohort variants
- baseline assumptions

Output:
- role impact map
- organisational variance
- adoption curve
- resistance map
- sweet spot / black spot distribution
- recommended sequencing
- evidence gaps

Use case:
- enterprise advisory
- transformation planning
- WorkFamilyAI modelling
- HoloOrg mapping
- R&D evidence generation

### 2.3 Neurodiverse Rubik's Cube

A digital interaction object the user can rotate and tune.

Faces:
1. Human
2. Technology
3. Context
4. Change
5. Signal
6. Outcome

Each face contains sliders, cards, or selectable variables.

The cube is not the database. It is the interface.

The database remains tables and a graph.

---

## 3. The PIN Concept

The user gives the system a PIN.

PIN does not mean only a numeric code. It means a compact interaction identity:

**P.I.N. = Profile + Interaction + Norm**

### P — Profile
Who is the person or role?

Examples:
- mid-level accountant
- CFO
- teacher
- parent
- child
- frontline worker
- neurodivergent founder
- public servant

Attributes:
- role
- level
- demographic profile
- psychographic profile
- cognitive profile
- neurodiversity profile
- digital maturity
- trust level
- agency level
- constraints

### I — Interaction
What is the person interacting with?

Examples:
- AI copilot
- payroll system
- agentic workflow
- BCI
- social platform
- government portal
- robot
- policy change
- reporting obligation

Attributes:
- technology class
- autonomy level
- explainability
- risk level
- interface modality
- maturity
- frequency of use
- dependency potential

### N — Norm
What is normal in this organisation or context?

Examples:
- baseline productivity
- baseline error rate
- trust culture
- psychological safety
- cognitive load
- technology maturity
- governance maturity
- support quality
- change fatigue
- regulatory pressure

The PIN lets the system compare an individual or role against the organisational norm and show variance.

---

## 4. Organisational Norm Engine

The organisation needs a norm before the simulator can predict variance.

A norm is not one average number. It is a baseline profile across multiple dimensions.

### 4.1 Norm Tables

Required baseline tables:

1. `org_profile`
   - org_id
   - industry
   - size
   - region
   - regulation_level
   - digital_maturity
   - ai_maturity
   - culture_profile
   - change_load

2. `org_role_group`
   - role_group_id
   - org_id
   - role_family
   - level
   - function
   - headcount
   - business_criticality
   - exposure_to_change

3. `org_norm_baseline`
   - baseline_id
   - org_id
   - metric_name
   - metric_value
   - measurement_method
   - confidence
   - source

4. `human_profile_archetype`
   - profile_id
   - profile_name
   - demographic_tags
   - psychographic_tags
   - cognitive_tags
   - neurodiversity_tags
   - ability_tags
   - support_needs

5. `technology_profile`
   - tech_id
   - tech_name
   - tech_class
   - autonomy_level
   - complexity
   - explainability
   - risk_level
   - interface_mode

6. `interaction_scenario`
   - scenario_id
   - org_id
   - change_name
   - change_type
   - target_technology
   - affected_role_groups
   - time_window
   - pressure_level

7. `interaction_prediction`
   - prediction_id
   - scenario_id
   - profile_id
   - role_group_id
   - tech_id
   - predicted_uplift
   - predicted_risk
   - overload_probability
   - dependency_probability
   - trust_delta
   - adoption_probability
   - recommended_intervention
   - confidence

8. `outcome_observation`
   - observation_id
   - prediction_id
   - actual_result
   - signal_measured
   - delta_from_prediction
   - evidence_link
   - update_required

---

## 5. Setting the Norm

The organisation norm is set in layers.

### Layer 1 — Default Population Norm

Start with a generic norm.

Examples:
- normal operating stress
- baseline digital maturity
- average trust in technology
- expected adoption curve
- average cognitive load

This is weak but useful when no data exists.

Status: PARTIAL.

### Layer 2 — Industry Norm

Apply sector-specific assumptions.

Examples:
- finance has high compliance load
- healthcare has high duty of care
- education has high child-safety sensitivity
- government has high policy and audit pressure
- construction has mobile/field constraints

Status: stronger.

### Layer 3 — Organisation Norm

Collect organisation-specific data.

Sources:
- surveys
- HR data
- productivity metrics
- incident logs
- tool usage
- helpdesk tickets
- training completion
- engagement data
- change fatigue assessments

Status: strong if evidenced.

### Layer 4 — Team Norm

Each team differs.

Examples:
- finance may be controlled and risk-averse
- sales may be fast and informal
- IT may be overloaded but adaptive
- HR may be emotionally exposed
- operations may be interruption-heavy

Status: stronger.

### Layer 5 — Individual / Role Norm

Personalised baseline.

Examples:
- neurodiversity
- attention style
- trust style
- learning preference
- sensory profile
- experience level
- confidence
- tool history

Status: strongest with consent and evidence.

---

## 6. Prediction Logic

The prediction engine should not pretend to be exact.

It should produce a probability-weighted variance profile.

### Basic prediction equation

For a given scenario:

```
Impact = f(Human Profile, Technology Profile, Context Norm, Change Pressure, Support Quality)
```

### Output bands

- Green: likely sweet spot
- Yellow: monitor / intervention useful
- Red: black spot / overload risk
- Grey: unknown / insufficient evidence

### Prediction outputs

For each role group:

- expected benefit
- expected friction
- expected adoption rate
- likely blockers
- likely champions
- support requirement
- training pathway
- governance risk
- evidence confidence

---

## 7. Question-to-Answer Across the Organisation

The simulator should support question propagation.

Example business question:

> Should we roll out an AI copilot to finance?

The system translates it into organisational queries:

1. Which role groups are affected?
2. Which technology is being introduced?
3. What is the current organisational norm?
4. Which profiles benefit?
5. Which profiles struggle?
6. Where are sweet spots likely?
7. Where are black spots likely?
8. What intervention changes the result?
9. What evidence is missing?
10. What should be measured after rollout?

### Example role outputs

CFO:
- impact: governance, reporting speed, audit traceability
- risk: overconfidence, compliance exposure
- intervention: evidence ledger and review gates

Accountant:
- impact: reconciliation speed, reporting assistance
- risk: dependency, hallucination, skill atrophy
- intervention: assisted mode, audit checklist, escalation rules

HR / THRO:
- impact: training load, change fatigue, inclusion risk
- risk: unequal adoption across neurotypes
- intervention: segmented learning and support profiles

CTO:
- impact: integration, security, tool governance
- risk: shadow AI and data leakage
- intervention: approved stack, telemetry, access controls

CEO:
- impact: productivity narrative, capability uplift
- risk: culture split between adopters and resistors
- intervention: staged adoption and visible outcome reporting

---

## 8. How the Rubik's Cube Works Digitally

### Face 1 — Human

Selectable:
- role
- level
- cognitive profile
- neurodiversity
- confidence
- trust
- digital maturity
- support need

### Face 2 — Technology

Selectable:
- technology class
- autonomy level
- interface mode
- explainability
- risk
- integration level

### Face 3 — Context

Selectable:
- organisation
- industry
- team
- geography
- regulation
- culture
- pressure

### Face 4 — Change

Selectable:
- rollout
- policy change
- restructure
- new tool
- compliance obligation
- crisis

### Face 5 — Signal

Selectable:
- trust
- stress
- productivity
- error rate
- adoption
- dependency
- engagement
- learning

### Face 6 — Outcome

Output:
- sweet spot
- black spot
- neutral
- uplift
- risk
- recommended next action

The user rotates the cube by changing one face. The simulator shows how the outcome changes.

---

## 9. Variance Demonstration

The simulator must show that one small change can alter outcomes.

Example:

Baseline:
- mid-level accountant
- AI copilot
- finance team
- quarter-end reporting
- medium trust

Prediction:
- productivity up
- moderate risk
- training needed

Change one cell:
- trust: medium → low

New prediction:
- adoption down
- resistance up
- training load up
- productivity benefit delayed

Change another cell:
- neurodiversity: neurotypical → ADHD

New prediction:
- productivity may increase sharply if tool reduces friction
- overload risk increases if interface is noisy
- intervention shifts to chunking, prompts, and explicit progress markers

This is the point of the cube: users learn by rotating variables.

---

## 10. Norm Calibration Method

The organisation norm should be set by a three-pass intake.

### Pass 1 — Quick Survey

10 to 20 questions:
- technology confidence
- trust in AI
- current workload
- change fatigue
- support quality
- autonomy preference
- learning preference
- perceived risk
- team pressure
- expected benefit

### Pass 2 — System Data

Pull existing organisational data where available:
- HR systems
- helpdesk
- LMS
- productivity tools
- incident reports
- collaboration tools
- project systems

### Pass 3 — Scenario Test

Run 3 to 5 business scenarios:
- new payroll system
- AI copilot rollout
- policy change
- campaign launch
- compliance uplift

Measure predicted variance across role groups.

---

## 11. Minimum Viable Build

### MVP User Journey

1. User selects role.
2. User selects technology/change.
3. User selects context.
4. User answers 8 to 12 profile/norm questions.
5. Simulator returns:
   - personal impact
   - role impact
   - team impact
   - organisational impact
   - confidence level
   - next best intervention

### MVP Outputs

- personal report
- manager report
- executive summary
- organisational heat map
- recommended intervention pack

### MVP Tables

- `human_profile_archetype`
- `technology_profile`
- `context_profile`
- `org_norm_baseline`
- `interaction_scenario`
- `interaction_prediction`
- `outcome_observation`

---

## 12. Evidence Discipline

Every prediction must carry evidence status.

- REAL: measured from organisation or study data
- PARTIAL: inferred from similar studies or structured assumptions
- HYPOTHESIS: plausible but not yet evidenced
- BLOCKED: insufficient data or missing consent

Do not present all predictions as equal.

---

## 13. Business Alignment

This simulator supports multiple businesses.

- AI Sweet Spots: calibration and cognitive fit
- WorkFamilyAI: role and workplace impact
- HoloOrg: role-to-agent mapping and organisational modelling
- ConsentX: consent and authority chains
- MyNeuralSignal: signal and baseline measurement
- GC-BAT: governance and foresight simulation
- Outcome Ready / Reading Buddy: learner and support outcomes
- RATPAK / NEUROPAK: human intent to machine action

This is not a single-brand feature. It is a shared research and product primitive.

---

## 14. Build Priority

1. Codify the schema.
2. Build the calculator first.
3. Add role-group organisational simulator.
4. Add digital cube UI.
5. Add evidence and outcome logging.
6. Add adaptive norm calibration.
7. Add cross-study research graph.

---

## 15. Definition of Done

The simulator is not done until:

- user can create a PIN profile
- organisation can establish a norm
- scenario can be run across role groups
- prediction generates scored impact and confidence
- result links to evidence or hypothesis status
- observation can be captured after rollout
- norm can update from actual results
- reports can be generated for user, manager, and executive

---

## 16. Reality Ledger

**Task:** Codify the calculator / simulator / neurodiverse Rubik's Cube model.

**Status:** PARTIAL until executable system exists.

**Evidence:** This specification committed to GitHub.

**Gaps:**
- No live UI yet.
- No Supabase tables deployed from this spec yet.
- No calculator route yet.
- No prediction algorithm implemented yet.
- No organisational norm baseline loaded yet.

**Next action:** Create Supabase schema and MVP calculator prototype.
