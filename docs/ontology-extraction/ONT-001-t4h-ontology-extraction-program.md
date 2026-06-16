# ONT-001: T4H Ontology Extraction Program

## Status

PARTIAL.

This file is the execution scaffold for compressing the accumulated Pen, MCP Command Centre, Runtime-Real, Bridge, research, product, and conversation backlog into canonical objects, capabilities, laws, graph relationships, and runtime mappings.

## Why this exists

The portfolio already contains the same ideas repeated under different names across issues, pull requests, chats, repos, research artefacts, bridge handoffs, and product experiments.

The next useful move is not to create another product. It is to discover what has already been discovered, compress duplicates, and expose the operating model underneath.

## Evidence already found

### The Pen issue evidence

Issue #199: Tech4Humanity Portfolio Architecture v2
- Describes Tech4Humanity as a research-derived operating system, not a collection of products.
- Names customer outcomes, evidence and signals, research IP, reusable runtime components, Signal Spine, Synal, ConsentX, event/signal routing, and evidence loops.

Issue #196: T4H Corpus Intelligence Program
- Already calls for canonical ontology across chats, browser sessions, docs, repos, and runtime artefacts.
- Identifies weak signals, unfinished decisions, missed business value, telemetry, drift detection, receipt generation, and next-session continuation.

Issue #171: Implement canonical signal taxonomy
- Calls for signal families across runtime, governance, economic, ontology, and human intervention signals.

Issue #170: Signal Layer Spine Enhancement Plan
- Defines the need to make signal layer the operating surface of Spine and Agent Orchestrator.
- Target loop: Detect -> Signal -> Recover -> Validate -> Receipt -> Close.

Issue #113: Bridge Receipt: Language and Ontology Contract v1
- Shows previous attempt to convert language ontology research into executable infrastructure.

Issue #82: Organisational Atom Table v3 handoff
- Defines a universal periodic-table-style operating map for organisations and systems.

Issue #130: SpeechEvent 1.0
- Defines speech as an executable runtime object rather than a transcript.

## Core hypothesis

The ecosystem is not hundreds of separate things.

It is likely:

```text
1 ontology
1 graph
1 runtime
many front doors
```

The apparent complexity should compress into:

```text
200+ issues
100+ repos
1000+ agents
1000s of conversations
↓
30-50 canonical capabilities
10-20 operating laws
1 graph
1 runtime
```

## Extraction streams

### WS1: Canonical Objects

Find the nouns that recur across issues, repos, products, and threads.

Initial candidate objects:

- Signal
- Person
- Agent
- Task
- Workflow
- Intervention
- Capability
- Evidence
- Receipt
- Outcome
- Identity
- Consent
- Relationship
- Environment
- Resource
- Asset
- Opportunity
- Risk
- Recovery
- Ledger
- Runtime
- Graph
- Ontology Node
- Product Surface

### WS2: Canonical Capabilities

Find the verbs and reusable system functions.

Initial candidates:

- Capture
- Classify
- Route
- Prioritise
- Decide
- Adapt
- Execute
- Verify
- Recover
- Learn
- Govern
- Monetise
- Consent
- Observe
- Escalate
- Compress
- Reuse
- Productise

### WS3: Canonical Laws

Extract repeatable operating rules.

Initial candidates:

1. Signal before action.
2. Identity before permission.
3. Consent before use.
4. Capability before delegation.
5. Adaptation before escalation.
6. Evidence before truth.
7. Recovery before completion.
8. Outcome before activity.
9. Relationship before transaction.
10. Graph before silo.
11. One object, many views.
12. Receipt before REAL.
13. Runtime beats memory.
14. Reuse before rebuild.
15. Closed is not REAL.

### WS4: Capability Compression Map

Map each issue, PR, repo, thread, and artefact to canonical capability IDs.

Example:

```text
PEN-170, PEN-171, runtime-real#62, corpus intelligence, signal taxonomy
→ CAP-001 Signal Capture and Taxonomy
→ LAW-001 Signal before action
→ LAW-012 Receipt before REAL
```

### WS5: Runtime Mapping

For each canonical capability, record:

- owner repo
- runtime object
- schema/table
- API endpoint
- issue tracker
- receipt mechanism
- telemetry source
- recovery path
- product surfaces
- REAL/PARTIAL/BLOCKED status

## Required output artefacts

1. `canonical-objects.yml`
2. `canonical-capabilities.yml`
3. `canonical-laws.yml`
4. `capability-compression-map.yml`
5. `runtime-mapping.yml`
6. `ontology-extraction-ledger.ndjson`
7. `extraction-receipts/`

## Extraction schema

```yaml
source_item:
  id:
  source_type: issue|pr|repo|thread|doc|runtime|schema
  source_repo:
  source_url:
  source_state: open|closed|merged|abandoned|unknown
  title:
  summary:
  detected_objects: []
  detected_capabilities: []
  detected_laws: []
  duplicates_or_related: []
  canonical_mapping:
    object_ids: []
    capability_ids: []
    law_ids: []
  runtime_status: REAL|PARTIAL|BLOCKED|ASPIRATIONAL
  evidence:
    commits: []
    issues: []
    receipts: []
    telemetry: []
  next_action:
```

## REAL gate

This program is not REAL until:

1. At least The Pen, MCP Command Centre, and Runtime-Real open issues are harvested.
2. Closed issues are sampled for false-closed / not-REAL states.
3. At least 30 canonical capabilities are defined.
4. At least 10 laws are defined.
5. Every canonical capability has an owner, evidence, dependency, lifecycle, and runtime state.
6. A receipt ledger exists.
7. The compression map is queryable.

## Immediate next actions

1. Create master issue in The Pen.
2. Create or update linked issue in Runtime-Real.
3. Harvest The Pen issues #199, #196, #171, #170, #113, #82, #130.
4. Harvest MCP Command Centre open issues and PRs.
5. Build first compression map.
6. Identify false-closed items.
7. Produce first canonical objects/capabilities/laws pack.

## Current classification

Status: PARTIAL

Reason:
- Strong evidence of prior related work exists in The Pen.
- Scaffold is now persisted.
- Extraction has not yet run across all issue sources.
- No compression ledger or runtime mapping exists yet.
