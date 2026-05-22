# SpeechEvent Runtime v0.1

## Status

PARTIAL.

This file creates the canonical SpeechEvent / SpeechRuntime seed for Doolittles, Synal, WorkFamilyAI, The Hundred Room, Speedo/Drift telemetry, ConsentX, MyNeuralSignal, NEUROPAK, and Reality Ledger binding.

No prior canonical SpeechEvent schema was found in reachable GitHub search across TML-4PM or the-pen. This file promotes the concept into the Pen as the working source of truth.

## Core Position

Doolittles is not a chat transcript system.

Doolittles is a cognitive runtime for translating what was said into:

- what different listeners heard
- what different species/systems interpreted
- what actions were triggered
- what misunderstanding risk exists
- what emotional, social, economic, operational, and legal consequences emerge
- what proof is bound to Reality Ledger

Humans think they speak sentences.

Machines execute:

- action
- object
- modifiers
- context
- emotion
- intent
- consequences

Therefore verbs, nouns, adjectives, and adverbs are not grammar here. They are signal primitives.

## SpeechEvent v1.0

```yaml
SpeechEvent:
  metadata:
    id: uuid
    timestamp: ISO8601
    parent_event_id: uuid|null
    conversation_id: uuid
    session_id: uuid
    source:
      actor_id: string
      actor_type:
        - human
        - ai
        - system
        - robot
        - environment
        - family
        - animal
        - sensor
        - future_self
      location: string|null
      channel:
        - voice
        - text
        - slack
        - email
        - meeting
        - tv
        - sensor
        - api

  raw:
    utterance: string
    transcript: string|null
    language: string
    confidence: float

  primitives:
    verbs:
      - id: ontology_id
        value: string
        tense: string
        class: string
        certainty: float
        energy: float
        reversibility: float
        risk: float
        activation_weight: float

    nouns:
      - id: ontology_id
        value: string
        type: string
        ownership: string|null
        volatility: float
        relationships: []

    modifiers:
      adjectives: []
      adverbs: []
      certainty_terms: []
      weakening_terms: []
      emotional_amplifiers: []

    entities:
      people: []
      systems: []
      places: []
      products: []
      teams: []
      animals: []
      robots: []

  semantic:
    intent:
      explicit: []
      inferred: []
      hidden: []
      suppressed: []
      competing: []

    sentiment:
      emotional_state: []
      polarity: string
      urgency_score: float
      confidence_score: float

  listener_simulation:
    audience:
      - CFO
      - HR
      - employee
      - customer
      - regulator
      - AI_agent
      - robot
      - family
      - child
      - neurodivergent
      - future_self

    interpretations:
      listener_id:
        heard: []
        assumed: []
        feared: []
        likely_action: []
        misunderstanding_probability: float
        trust_shift: float
        emotional_shift: float

  species_translation:
    human: string
    executive: string
    child: string
    machine: string
    legal: string
    logistics: string
    animal: string
    family: string
    neurodivergent: string
    regulator: string
    future_self: string

  signal:
    drift_score: float
    ambiguity_score: float
    misunderstanding_probability: float
    emotional_variance: float
    trust_risk: float
    interpretation_spread: float

  action_graph:
    actions: []
    systems: []
    agents: []
    APIs: []
    workflows: []

  impact:
    time:
      immediate: []
      delayed: []
      future: []
    economics:
      cost: string|null
      benefit: string|null
    social:
      trust: string|null
      morale: string|null
    operational:
      risk: string|null
      dependency: string|null

  reality:
    evidence:
      receipts: []
      links: []
      system_updates: []
      telemetry: []
    state:
      - REAL
      - PARTIAL
      - PRETEND
```

## SpeechRuntime v2.0 modules

```yaml
SpeechRuntime:
  modules:
    - SpeechEventParser
    - OntologyRegistry
    - VerbGraph
    - NounGraph
    - ModifierGraph
    - ListenerGenomeEngine
    - SpeciesTranslationEngine
    - SignalInheritanceEngine
    - TemporalMemoryEngine
    - DriftScoringEngine
    - ActionGraphRouter
    - HundredRoomVisualizer
    - RealityLedgerBinder
```

## Runtime Flow

```text
SpeechEvent
  -> Ontology Registry
  -> VerbGraph / NounGraph / ModifierGraph
  -> Listener Genome
  -> Species Translation
  -> Signal Inheritance
  -> Temporal Memory
  -> Drift Engine
  -> Hundred Room Visualizer
  -> Action Graph
  -> Reality Ledger
```

## Ontology Registry Seed

```yaml
VERB_DELAY_001:
  aliases: [delay, postpone, defer, push, hold]
  class: operational_change
  risk_weight: 0.72
  reversibility: high

VERB_RESTRUCTURE_001:
  aliases: [restructure, reorganise, reshape, realign]
  class: organisational_change
  risk_weight: 0.88
  reversibility: medium

NOUN_EMPLOYEE_001:
  aliases: [staff, worker, people, crew, team_member]
  parent: PERSON

NOUN_EXPANSION_001:
  aliases: [growth, rollout, scale-up, expansion]
  parent: STRATEGIC_ACTIVITY

MODIFIER_CRITICAL_001:
  aliases: [urgent, severe, major, high-risk]
  amplification_weight: 0.86

MODIFIER_MAY_001:
  aliases: [may, might, possible, potential]
  weakening_weight: 0.62
```

## Listener Genome Seed

```yaml
ListenerGenome:
  listener_id: employee_001
  type: human
  role: employee
  worldview:
    trust_in_leadership: low
    previous_layoff_experience: true
    financial_security: fragile
  cognitive_style: anxious_detail_oriented
  incentives:
    protect_income: high
    avoid_uncertainty: high
  memory:
    related_events: [previous_restructure_2024]
  risk_profile:
    emotional_spread: 0.82
    action_power: 0.18
```

## Listener Weighting

```text
ListenerImpact = Influence x ExecutionPower x Trust x Reach x MemoryPersistence
```

## Signal Inheritance

```yaml
SignalInheritance:
  parent_event: cost_reduction_warning
  children:
    - travel_freeze
    - hiring_pause
    - restructure_message
  shared_intent: reduce_cost
  confidence: 0.84
```

## Drift Score

```text
DriftScore =
(Ambiguity x 0.25)
+ (InterpretationSpread x 0.30)
+ (EmotionalVariance x 0.20)
+ (CrossListenerConflict x 0.15)
+ (HistoricalDivergence x 0.10)
```

```yaml
drift_band:
  green: 0.00-0.30
  yellow: 0.31-0.60
  red: 0.61-1.00
```

## Temporal Memory

```text
MemoryStrength = Emotion x Novelty x Repetition x Importance / Decay
```

## Hundred Room Example

```text
Speech:
"We may delay expansion"

Primitives:
VERB: delay
NOUN: expansion
MODIFIER: may

CFO hears:
cash preservation

HR hears:
layoff preparation

Employee hears:
job insecurity

Marketing hears:
campaign risk

Robot hears:
capacity adjustment

Child hears:
dad/mum stress incoming

AI hears:
ambiguity high, confidence low

Speedo:
Drift: 72%
Trust risk: 63%
Confusion probability: 81%
```

## Grammar Genome / Organisational DNA

```yaml
Amazon:
  verbs: [launch, scale, invent, optimise, reduce]
  modifiers: [customer-obsessed, frugal, high-bar]

Government:
  verbs: [review, consult, approve, defer, investigate]
  modifiers: [compliant, safe, temporary]

Tech4Humanity:
  verbs: [augment, orchestrate, translate, protect, simulate]
  modifiers: [human, ethical, adaptive]
```

## Product Bindings

```yaml
Doolittles: universal interpretation layer
Synal: live surface
WorkFamilyAI: listener and role simulation
The Hundred: 100-reality visualiser
Speedo: drift and trust telemetry
ConsentX: permission boundary
MyNeuralSignal: signal enrichment
NEUROPAK: intervention routing
RealityLedger: proof and receipts
```

## Graph Model

```yaml
nodes:
  - SpeechEvent
  - Verb
  - Noun
  - Modifier
  - Listener
  - Species
  - Emotion
  - Intent
  - Action
  - System
  - Impact
  - RealityReceipt

edges:
  - SPOKE
  - CONTAINS_VERB
  - CONTAINS_NOUN
  - MODIFIED_BY
  - HEARD_AS
  - TRANSLATED_FOR
  - TRIGGERED
  - AFFECTED
  - MISUNDERSTOOD
  - INHERITS_FROM
  - EVIDENCED_BY
```

## Reality Ledger

```yaml
status: PARTIAL
result: Canonical SpeechEvent runtime seed created in the Pen.
evidence:
  - GitHub search returned no existing canonical SpeechEvent source in reachable TML-4PM scope.
  - GitHub repository TML-4PM/the-pen reachable with push/admin permissions.
  - This file commits the schema, runtime modules, scoring, ontology seed, graph model, and product bindings.
gaps:
  - Bridge receipt not created from this chat environment.
  - Runtime engine not yet implemented.
  - Ontology registry not yet executable.
  - Graph store not yet provisioned.
  - Drift scoring not calibrated against dataset.
  - Hundred Room UI not yet built.
next_action:
  - create JSON schema
  - create SQL tables
  - create sample events
  - create graph edge export
  - bind bridge receipt when bridge executor is available
score: 0.88
```
