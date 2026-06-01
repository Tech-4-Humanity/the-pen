# Human × Technology × Context Simulator
## Neurodiverse Rubik's Cube / Organisational Norm Engine

**Status:** v1.1 candidate  
**Date:** 2026-06-02  
**Owner:** TML-4PM / Tech 4 Humanity  
**Purpose:** Codify the user-facing calculator, simulator, Rubik's Cube interaction model, and study-ingestion engine for predicting how humans, technologies, machines, contexts, and organisational systems interact.

---

## 1. Core Question

The simulator exists to answer three questions:

1. What happens when this human meets this technology under these conditions?
2. What happens when this human changes the technology?
3. What happens when the technology changes the human?

This is the same invariant that sits under AI Sweet Spots, WorkFamilyAI, ConsentX, HoloOrg, MyNeuralSignal, GC-BAT, RATPAK, NEUROPAK, Social Media Ban / Digital Child Protection, Drug Resilience Atlas, Reality Ledger, and related Tech 4 Humanity studies.

The user does not enter through a research taxonomy. The user enters through themselves, their role, their technology, their organisation, and the change being considered.

The research team enters through studies, subtopics, hypotheses, signals, and evidence.

The same engine must support both.

---

## 2. Product Forms

The system can appear as four related products.

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

A simulator runs multiple people, roles, teams, technologies, machines, and conditions.

Input:
- organisation norm profile
- role groups
- change scenario
- technology profile
- machine/system profile
- cohort variants
- baseline assumptions
- study or subtopic being tested

Output:
- role impact map
- machine/system impact map
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
- study impact testing

### 2.3 Neurodiverse Rubik's Cube

A digital interaction object the user can rotate and tune.

Faces:
1. Human
2. Technology / Machine
3. Context
4. Change / Study Question
5. Signal
6. Outcome

Each face contains sliders, cards, or selectable variables.

The cube is not the database. It is the interface.

The database remains tables and a graph.

### 2.4 Study Ingestion Engine

A new study, topic, subtopic, or hypothesis can be entered and quickly tested against the existing role, machine, human, and organisational dimensions.

Input:
- study theme
- subtopic
- hypothesis
- target human populations
- target technologies / machines / systems
- context classes
- variables affected
- expected positive impacts
- expected negative impacts
- evidence status

Output:
- which roles are affected
- which machines/systems are affected
- which variables matter
- which organisational norms need calibration
- which businesses can use the study
- what evidence is missing
- what product or asset forms may emerge

This is what makes the simulator reusable across all studies, not just AI Sweet Spots.

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
- ability profile
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
- sensor system
- autonomous machine

Attributes:
- technology class
- machine/system class
- autonomy level
- explainability
- risk level
- interface modality
- maturity
- frequency of use
- dependency potential
- signal capture intensity

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

The PIN lets the system compare an individual, role, team, or machine-facing interaction against the organisational norm and show variance.

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

6. `machine_system_profile`
   - machine_id
   - machine_name
   - system_type
   - autonomy_level
   - signal_inputs
   - human_touchpoints
   - failure_modes
   - feedback_channels
   - learning_capability
   - governance_requirements

7. `interaction_scenario`
   - scenario_id
   - org_id
   - change_name
   - change_type
   - target_technology
   - target_machine_system
   - affected_role_groups
   - time_window
   - pressure_level

8. `interaction_prediction`
   - prediction_id
   - scenario_id
   - profile_id
   - role_group_id
   - tech_id
   - machine_id
   - predicted_uplift
   - predicted_risk
   - overload_probability
   - dependency_probability
   - trust_delta
   - adoption_probability
   - machine_adaptation_delta
   - recommended_intervention
   - confidence

9. `outcome_observation`
   - observation_id
   - prediction_id
   - actual_result
   - signal_measured
   - delta_from_prediction
   - evidence_link
   - update_required

---

## 5. Study Ingestion Model

Every new study or subtopic must be ingestible without redesigning the system.

A new topic should be converted into a standard study object.

### 5.1 Study Object Fields

Table: `research_study_object`

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

### 5.2 Study Impact Matrix

Every study must be mapped against:

- 9 or 10 executive / organisational role groups
- human profiles
- technology profiles
- machine/system profiles
- context classes
- signals
- outcomes
- business alignments
- evidence gaps

This is the key difference from a static research register.

The study is not just stored. It is made simulatable.

---

## 6. The 9 or 10 Role Impact Layer

The simulator should support the organisation's major role lenses.

Default 10 role lenses:

1. CEO / Strategy
2. CFO / Finance
3. CTO / Technology
4. CHRO / THRO / People
5. COO / Operations
6. CMO / Marketing
7. CRO / Sales / Revenue
8. CLO / Legal / Governance
9. CISO / Risk / Security
10. Customer / Citizen / Service Recipient Lens

If the organisation prefers 9, the customer/citizen lens can be handled as an external stakeholder layer rather than an executive role.

For every study, the system should ask:

- Does this role care?
- Is the impact direct, indirect, or negligible?
- Is the role a beneficiary, blocker, risk owner, funder, operator, regulator, or affected party?
- What question would this role ask?
- What answer does the study provide?
- What decision changes because of it?

---

## 7. Machine/System Impact Layer

The simulator must also model the machine side.

Technology is not passive.

People change the technology, and technology changes people.

For every study, assess machine/system impact:

- Does the machine receive new data?
- Does the machine learn or adapt?
- Does the interface need to change?
- Does autonomy increase or decrease?
- Does explainability need to improve?
- Does risk classification change?
- Does the machine create new signals?
- Does the machine require consent or governance controls?
- Does the machine amplify or reduce human capability?
- Does the machine create new dependency?

This applies to AI systems, robots, BCI systems, dashboards, platforms, workflows, policy engines, and public-sector systems.

---

## 8. Organisational Variable Layer

Every study must map to organisational variables.

Core variable categories:

### Human variables
- cognition
- neurodiversity
- confidence
- trust
- learning preference
- stress
- sensory load
- motivation
- agency
- capability

### Role variables
- authority
- accountability
- decision rights
- workload
- exposure
- influence
- support requirement
- adoption pressure

### Technology variables
- autonomy
- explainability
- complexity
- interface mode
- data sensitivity
- integration depth
- failure visibility
- dependency potential

### Machine variables
- signal intake
- feedback loop
- model adaptation
- autonomy drift
- control handoff
- error correction
- human override
- observability

### Context variables
- industry
- geography
- regulation
- culture
- time pressure
- change fatigue
- safety sensitivity
- economic pressure

### Outcome variables
- productivity
- quality
- risk
- inclusion
- resilience
- burnout
- dependency
- trust
- learning
- customer/citizen impact

---

## 9. Setting the Norm

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

## 10. Prediction Logic

The prediction engine should not pretend to be exact.

It should produce a probability-weighted variance profile.

### Basic prediction equation

For a given scenario:

```
Impact = f(Human Profile, Role Group, Technology Profile, Machine Profile, Context Norm, Change Pressure, Support Quality, Study Evidence)
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
- machine/system risk
- evidence confidence

---

## 11. Question-to-Answer Across the Organisation

The simulator should support question propagation.

Example business question:

> Should we roll out an AI copilot to finance?

The system translates it into organisational queries:

1. Which role groups are affected?
2. Which technology is being introduced?
3. Which machines/systems are affected?
4. What is the current organisational norm?
5. Which profiles benefit?
6. Which profiles struggle?
7. Where are sweet spots likely?
8. Where are black spots likely?
9. What intervention changes the result?
10. What evidence is missing?
11. What should be measured after rollout?

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

Machine/System:
- impact: higher usage, new data patterns, possible autonomy drift
- risk: bad feedback loops, overfitting to dominant user groups, hidden failure modes
- intervention: telemetry, guardrails, human override, bias and failure monitoring

---

## 12. How the Rubik's Cube Works Digitally

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

### Face 2 — Technology / Machine

Selectable:
- technology class
- autonomy level
- interface mode
- explainability
- risk
- integration level
- signal capture
- feedback loop

### Face 3 — Context

Selectable:
- organisation
- industry
- team
- geography
- regulation
- culture
- pressure

### Face 4 — Change / Study Question

Selectable:
- rollout
- policy change
- restructure
- new tool
- compliance obligation
- crisis
- new study topic
- new hypothesis

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
- machine adaptation
- signal integrity

### Face 6 — Outcome

Output:
- sweet spot
- black spot
- neutral
- uplift
- risk
- recommended next action
- evidence gap
- machine/system change

The user rotates the cube by changing one face. The simulator shows how the outcome changes.

---

## 13. Variance Demonstration

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

Change another cell:
- machine autonomy: assisted → autonomous

New prediction:
- role anxiety increases
- governance risk increases
- productivity may improve for high-trust users
- oversight requirement rises
- machine feedback monitoring becomes mandatory

This is the point of the cube: users learn by rotating variables.

---

## 14. Norm Calibration Method

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
- telemetry systems
- machine/system logs

### Pass 3 — Scenario Test

Run 3 to 5 business scenarios:
- new payroll system
- AI copilot rollout
- policy change
- campaign launch
- compliance uplift
- social media ban impact
- consent model change
- agentic workflow introduction

Measure predicted variance across role groups and machine/system layers.

---

## 15. Minimum Viable Build

### MVP User Journey

1. User selects role.
2. User selects technology/change/study question.
3. User selects context.
4. User answers 8 to 12 profile/norm questions.
5. Simulator returns:
   - personal impact
   - role impact
   - team impact
   - machine/system impact
   - organisational impact
   - confidence level
   - next best intervention

### MVP Study Journey

1. Researcher enters new topic or subtopic.
2. System converts it into a study object.
3. Study is mapped to role groups, machine systems, variables, and contexts.
4. Simulator generates first-pass impact matrix.
5. Evidence gaps and required signals are listed.
6. Study is tagged to businesses/products/assets.

### MVP Outputs

- personal report
- manager report
- executive summary
- organisational heat map
- machine/system impact report
- study impact matrix
- recommended intervention pack

### MVP Tables

- `research_study_object`
- `human_profile_archetype`
- `technology_profile`
- `machine_system_profile`
- `context_profile`
- `org_norm_baseline`
- `org_role_group`
- `interaction_scenario`
- `interaction_prediction`
- `outcome_observation`

---

## 16. Evidence Discipline

Every prediction must carry evidence status.

- REAL: measured from organisation or study data
- PARTIAL: inferred from similar studies or structured assumptions
- HYPOTHESIS: plausible but not yet evidenced
- BLOCKED: insufficient data or missing consent

Do not present all predictions as equal.

A new study can be useful at HYPOTHESIS level, but it must not be marketed as REAL until evidence exists.

---

## 17. Business Alignment

This simulator supports multiple businesses and research programs.

- AI Sweet Spots: calibration and cognitive fit
- WorkFamilyAI: role and workplace impact
- HoloOrg: role-to-agent mapping and organisational modelling
- ConsentX: consent and authority chains
- MyNeuralSignal: signal and baseline measurement
- GC-BAT: governance and foresight simulation
- Outcome Ready / Reading Buddy: learner and support outcomes
- RATPAK / NEUROPAK: human intent to machine action
- Social Media Ban / Digital Child Protection: child, platform, parent, school, regulator impacts
- Drug Resilience Atlas: biology, culture, law, behaviour, resilience
- Reality Ledger: claim, evidence, truth status, organisational proof

This is not a single-brand feature. It is a shared research and product primitive.

---

## 18. Build Priority

1. Codify the schema.
2. Build the calculator first.
3. Add study ingestion.
4. Add role-group organisational simulator.
5. Add machine/system impact layer.
6. Add digital cube UI.
7. Add evidence and outcome logging.
8. Add adaptive norm calibration.
9. Add cross-study research graph.

---

## 19. Definition of Done

The simulator is not done until:

- user can create a PIN profile
- organisation can establish a norm
- new study can be ingested
- study can be mapped to roles, machines, variables, contexts, and businesses
- scenario can be run across role groups
- machine/system impacts can be shown
- prediction generates scored impact and confidence
- result links to evidence or hypothesis status
- observation can be captured after rollout
- norm can update from actual results
- reports can be generated for user, manager, executive, and research team

---

## 20. Reality Ledger

**Task:** Codify the calculator / simulator / neurodiverse Rubik's Cube / cross-study ingestion model.

**Status:** PARTIAL until executable system exists.

**Evidence:** This specification committed to GitHub.

**Gaps:**
- No live UI yet.
- No Supabase tables deployed from this spec yet.
- No calculator route yet.
- No prediction algorithm implemented yet.
- No organisational norm baseline loaded yet.
- No study ingestion UI yet.
- No machine/system profile library yet.

**Next action:** Create Supabase schema and MVP calculator prototype with study ingestion support.
