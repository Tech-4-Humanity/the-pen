# 10x10x10 Agent Operating Model v1

## Status
PARTIAL until posted to Bridge/GitHub and receipt is returned.

## Purpose
This document converts the 10x10x10 agent model from a static workforce map into an operating model for organisational metabolism: agents, context, flows, translation, AI Sweet Spots, evidence, and simulation.

## Correct arithmetic
- Core matrix: 10 leader groups x 10 domain groups x 10 role groups = 1,000 agents.
- Context wrapper: 3 layers x 10 dimensions = 30 context dimensions per agent.
- Minimum v1 operating record: approximately 66 fields per agent.
- Total structured v1 cells: 1,000 agents x 66 fields = approximately 66,000 cells.
- Context-only cells: 1,000 agents x 30 context fields = 30,000 cells.

The important correction: 30,000 is not the full CSV. It is only the context wrapper. The operating CSV/table set is closer to 66,000 cells before runtime telemetry, graph edges, evidence rows, and documents are added.

---

# 1. Core Agent Matrix

The original move was from 9x9x9 to 10x10x10.

| Model | Calculation | Count |
|---|---:|---:|
| Previous model | 9 x 9 x 9 | 729 agents |
| Current model | 10 x 10 x 10 | 1,000 agents |
| Increase | 1,000 - 729 | 271 additional agents |
| Increase percentage | 271 / 729 | 37.17% uplift |

The shift is not only numerical. The 10th layer gave the model room for governance, external context, translation, and adaptive behaviour.

---

# 2. The Three 10x10 Context Layers

## Layer 1: World Context
These describe where the agent operates and what external forces shape the work.

| # | Dimension | Meaning |
|---:|---|---|
| 1 | Industry | Sector or industry domain such as health, education, government, agriculture, finance, energy, retail, transport, manufacturing, technology. |
| 2 | Location / Place | Physical or virtual place such as home, hospital, office, school, factory, vehicle, public space, field, digital space, remote site. |
| 3 | Geography | Local, regional, state, national, APAC, EMEA, Americas, rural, urban, global. |
| 4 | Organisation Type | Startup, family business, enterprise, government agency, NGO, school, hospital, regulator, platform, community organisation. |
| 5 | Market / Audience | Consumer, citizen, patient, student, enterprise, SMB, partner, regulator, investor, community. |
| 6 | Regulatory Environment | Low regulation, education, healthcare, financial services, defence, public sector, privacy-heavy, safety-critical, cross-border, experimental. |
| 7 | Economic Environment | Growth, contraction, constrained budget, premium market, emerging market, crisis, grant-funded, debt-funded, subscription, public funding. |
| 8 | Culture / Language | Australian, regional, multilingual, professional culture, family culture, technical culture, safety culture, accessibility needs, community norms, institutional norms. |
| 9 | Geopolitical / Influence | Sovereignty, national security, trade blocs, sanctions, global influence, cross-border supply, platform dependence, regional tension, standards influence, critical infrastructure. |
| 10 | Operating Environment | Normal, remote, hybrid, frontline, emergency, high-risk, low-connectivity, regulated, experimental, frontier. |

## Layer 2: Work Context
These describe what is happening and how the work is structured.

| # | Dimension | Meaning |
|---:|---|---|
| 11 | Lifecycle Stage | Discover, assess, design, build, deploy, operate, monitor, optimise, recover, retire. |
| 12 | Time Horizon | Real-time, minute, hourly, daily, weekly, monthly, quarterly, annual, historical, predictive. |
| 13 | Role & Operating Context | Onboarding, role knowledge, operating assumptions, local practices, current responsibilities, boundaries, authority, current constraints, expected behaviours, maturity. |
| 14 | Ways of Working | Agile, waterfall, classroom, clinical, military, field work, case work, sales motion, operational rhythm, community practice. |
| 15 | SOP / Playbook Coverage | Procedures, checklists, playbooks, templates, scripts, escalation rules, exceptions, quality gates, recovery steps, working examples. |
| 16 | Decision Type | Strategic, tactical, operational, clinical, financial, ethical, safety, legal, emergency, experimental. |
| 17 | Dependencies | People, systems, tools, vendors, data, policies, approvals, funding, devices, external events. |
| 18 | Forecast Risks / Issues | Bottlenecks, failure patterns, quality risks, adoption risks, burnout risk, compliance risk, cost risk, delivery risk, communication risk, role drift. |
| 19 | Evidence / Validation | Runtime receipts, telemetry, audit trail, user feedback, research evidence, financial proof, QA records, policy proof, document evidence, observed outcomes. |
| 20 | Success Measures | KPIs, SLIs, outcomes, human benefit, financial result, speed, quality, safety, adoption, resilience, learning. |

## Layer 3: Human Runtime
These describe how people behave, communicate, learn, and work with AI.

| # | Dimension | Meaning |
|---:|---|---|
| 21 | Personality | Communication pattern, decision temperament, openness, conscientiousness, directness, patience, curiosity, confidence, conflict style, social energy. |
| 22 | Traits | Analytical, empathetic, structured, creative, cautious, bold, relational, systems-minded, practical, reflective. |
| 23 | Characteristics | Experience, expertise, seniority, literacy, digital comfort, accessibility needs, domain fluency, cultural background, working history, capability level. |
| 24 | Motivations | Purpose, money, recognition, security, autonomy, mastery, belonging, service, achievement, curiosity. |
| 25 | Cognitive / Stress State | Calm, overloaded, fatigued, distracted, urgent, anxious, confident, blocked, energised, recovering. |
| 26 | Preferences | Visual, verbal, text, voice, short-form, long-form, guided, self-directed, evidence-first, story-first. |
| 27 | Inputs | Voice, text, image, video, biometric, neural, behaviour, device, environmental, transaction. |
| 28 | Outputs | Decision, action, message, document, escalation, plan, approval, rejection, evidence, learning. |
| 29 | Relationship Context | Boss, peer, customer, citizen, patient, student, parent, regulator, partner, community. |
| 30 | Human-AI Fit / AI Sweet Spot | Human-only, AI-assisted, co-pilot, AI-led with human review, automated, under-assisted, over-assisted, unsafe automation, adaptive assistance, sweet spot. |

---

# 3. Minimum v1 Field Count

A useful v1 CSV/table row needs more than the 30 context dimensions.

| Group | Fields | Total cells across 1,000 agents |
|---|---:|---:|
| A. Identity | 8 | 8,000 |
| B. Matrix position | 4 | 4,000 |
| C. Context layers | 30 | 30,000 |
| D. Support and inclusion | 8 | 8,000 |
| E. Governance and monitoring | 8 | 8,000 |
| F. Runtime and feeding | 8 | 8,000 |
| Total | 66 | 66,000 |

## A. Identity fields
- agent_id
- agent_name
- agent_number
- leader_group
- domain_group
- role_group
- agent_title
- agent_description

## B. Matrix position fields
- leader_index
- domain_index
- role_index
- matrix_coordinate

## C. Context layer fields
The 30 fields listed above.

## D. Support and inclusion fields
- support_needs
- inclusion_needs
- accessibility_needs
- preferred_learning_mode
- preferred_instruction_style
- preferred_feedback_style
- handoff_needs
- translation_needs

## E. Governance and monitoring fields
- owner
- review_cadence
- status
- risk_level
- confidence_level
- evidence_level
- last_reviewed
- next_action

## F. Runtime and feeding fields
- source_documents
- required_sops
- required_tools
- required_data
- input_channels
- output_channels
- dependencies
- feedback_loop

---

# 4. What We Know About One Agent

For one agent, we now know:

1. Who they are.
2. Where they sit in the 10x10x10 matrix.
3. What world they operate in.
4. What work context shapes their behaviour.
5. What human context applies.
6. What they need to perform.
7. How they should be supported and included.
8. How they should communicate.
9. How they should be managed and monitored.
10. What documents, SOPs, tools, data, channels, dependencies, and feedback loops feed them.

This means the agent is no longer a name in a grid. It becomes an operating identity.

---

# 5. What We Know About the 1,000 Agents as a Group

Across the 1,000 agents, we can calculate:

1. Coverage by industry.
2. Coverage by geography.
3. Coverage by lifecycle stage.
4. Coverage by risk type.
5. Coverage by SOP availability.
6. Coverage by evidence level.
7. Coverage by AI Sweet Spot.
8. Coverage by translation need.
9. Coverage by dependency.
10. Coverage by communication style.

This allows the model to show which areas are overbuilt, underbuilt, unsupported, high-risk, low-evidence, over-automated, or translation-heavy.

---

# 6. Press-Go Calculations

Each runtime execution should calculate the following.

## 6.1 Coverage
How complete is the data across agents and dimensions?

Formula:
coverage = populated_required_fields / total_required_fields

Example:
57,000 populated fields / 66,000 required fields = 86.36% coverage

## 6.2 Missingness
Which fields are missing and where?

Formula:
missingness = missing_fields / total_required_fields

## 6.3 Confidence
How reliable is the information?

Confidence scale:
- 0 = unknown
- 1 = assumed
- 2 = inferred
- 3 = evidenced
- 4 = telemetry-backed
- 5 = validated over time

Agent confidence:
average confidence across applicable fields.

## 6.4 Translation Load
How difficult is it for this agent to communicate across humans, machines, roles, industries, cultures, and evidence styles?

Suggested drivers:
- industry vocabulary mismatch
- role vocabulary mismatch
- culture/language mismatch
- evidence preference mismatch
- decision style mismatch
- stress/cognitive state
- channel mismatch
- human-machine fit

## 6.5 AI Sweet Spot Fit
Is the agent under-assisted, correctly assisted, over-assisted, or in an unsafe automation zone?

Key fields:
- ideal_ai_involvement_pct
- current_ai_involvement_pct
- cognitive_load
- output_quality
- trust
- error_rate

## 6.6 Boundary Drift
Which roles are changing shape?

Example:
A teacher may now contain:
- 20% curriculum agent
- 15% wellbeing agent
- 10% compliance agent
- 25% parent communication agent
- 30% classroom delivery agent

This identifies role change before the job title changes.

## 6.7 Document Dependency
Does the agent have the required documents, SOPs, onboarding material, examples, policies, and evidence to operate?

## 6.8 Signal Health
Are inputs, outputs, feedback, escalations, and recovery loops flowing?

## 6.9 Risk Heat
Risk increases when autonomy is high, evidence is low, human stress is high, or regulatory burden is high.

Risk Heat = autonomy_level x risk_level x regulatory_sensitivity x human_impact x (1 - evidence_confidence)

## 6.10 Organism Health
Measures whether the whole system is flowing, learning, recovering, and improving.

Suggested components:
- signal flow
- feedback completion
- recovery success
- evidence coverage
- translation quality
- AI Sweet Spot fit
- dependency health
- outcome movement

## 6.11 Delta Over Time
Every run should compare against the previous run:
- What improved?
- What degraded?
- What moved?
- What is newly risky?
- What became automatable?
- What now requires translation?

---

# 7. Why This Matters

The move from 729 to 1,000 agents looked like a numeric uplift. It was actually a shift from modelling workers to modelling work in context.

A 729-agent model can represent a workforce.

A 1,000-agent model with 30 dimensions and 66 fields per agent can represent a living organisation.

It can show:
- what each agent does
- what each agent needs
- what each agent consumes
- what each agent produces
- what each agent depends on
- where translation is required
- where AI helps
- where AI harms
- where roles are changing
- where evidence is missing
- where the system is healthy or sick

---

# 8. Organisational Metabolism

The organisation should now be seen as a moving organism.

Every agent:
- consumes inputs
- interprets context
- makes or supports decisions
- produces outputs
- receives feedback
- adapts over time

The model is no longer an org chart. It is a metabolism map.

The flows include:
- knowledge
- decisions
- money
- risk
- communication
- relationships
- signals
- documents
- automation
- outcomes

When these flows are healthy, the organisation learns and adapts. When flows are blocked, duplicated, delayed, or mistranslated, the organisation becomes sick.

---

# 9. Translation Layer

The next major build is the translation layer.

This is not simply preferred verbs or nouns. It is not a dictionary. It is not prompt engineering.

It is a communication genome that helps:
- humans talk to machines
- machines talk to humans
- humans talk to other humans across different roles
- machines talk to other machines across different domains

The translation layer should understand:
- vocabulary profile
- evidence preference
- decision preference
- learning preference
- escalation preference
- trust profile
- communication style
- context sensitivity
- cultural and industry meaning
- stress/cognitive state

Example:
The word “risk” does not mean the same thing to everyone.

- To finance, risk may mean exposure.
- To healthcare, risk may mean patient safety.
- To government, risk may mean accountability.
- To agriculture, risk may mean weather, yield, biosecurity, and debt.
- To a machine, risk may be an undefined variable unless context is supplied.

The translation layer supplies that context.

---

# 10. AI Sweet Spots

AI Sweet Spots becomes dynamic inside this model.

The question is not “should we use AI?”

The question is:
How much AI, for which person, in which role, under which context, at which moment, with which evidence and risk profile?

Possible states:
- human-only
- AI-assisted
- co-pilot
- AI-led with human review
- automated
- under-assisted
- over-assisted
- unsafe automation
- adaptive assistance
- sweet spot

The same person may have different AI Sweet Spots across different work contexts.

---

# 11. Prediction and Simulation

With automation, the model can predict:
- burnout before burnout
- communication mismatch before conflict
- missing SOPs before delivery failure
- role drift before org redesign
- over-automation before harm
- under-automation before waste
- dependency failure before outage
- governance gaps before audit failure
- translation failure before operational failure
- new roles before job titles exist

The simulation layer then asks:
- What happens if policy changes?
- What happens if 20% of work becomes AI-assisted?
- What happens if a key team disappears?
- What happens if regulation increases?
- What happens if the market contracts?
- What happens if a new technology arrives?

This is the path from workforce model to organisational foresight engine.

---

# 12. Recommended Table Architecture

Do not keep everything in one CSV forever. Use one CSV as a portable v1 baseline, then normalise into tables.

Recommended v1 tables:

1. agent_registry
2. agent_context_world
3. agent_context_work
4. agent_context_human_runtime
5. agent_support_inclusion
6. agent_governance_monitoring
7. agent_runtime_feeding
8. agent_documents
9. agent_signal_flow
10. agent_relationship_graph
11. agent_ai_sweet_spot
12. agent_translation_profile
13. agent_evidence_ledger
14. agent_run_metrics
15. organism_health_snapshot

---

# 13. Reality Ledger Status

status: PARTIAL

result: Canonical v1 model compiled.

evidence:
- arithmetic corrected
- 10x10x10 structure defined
- 30 contextual dimensions defined
- 66-field v1 operating model defined
- press-go calculations defined
- next table architecture defined

gaps:
- no live Bridge receipt yet
- no GitHub commit hash yet
- no runtime execution against actual 1,000-agent CSV yet
- no Supabase tables deployed from this document yet
- no telemetry-bound proof yet

next_action:
- post this document and schema pack to Bridge/GitHub
- generate CSV template
- generate SQL schema
- generate press-go run calculator
- bind first run to Reality Ledger

score: 0.91
