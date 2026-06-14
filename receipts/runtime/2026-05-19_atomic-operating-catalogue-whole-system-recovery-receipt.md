# Receipt — Atomic Operating Catalogue / Whole-System Recovery

Date: 2026-05-19
Thread status: PARTIAL -> recovery chain established
Repo: TML-4PM/the-pen
Primary issue: #122

## Executive summary

This thread started as an atomic document catalogue / asset preference task and escalated into a whole-system operating recovery requirement.

The user clarified that this is not a builder session and that the business owner must not be forced into IT triage. The operating system must absorb, govern, prevent, repair and report issues end-to-end.

The critical correction is that the Pen is too late as the first enforcement point. The Pen is a queue/receipt layer. Enforcement must happen upstream before work is created, midstream at the canonical registry, and downstream at runtime and evidence writeback.

## Pass 1 — what was captured

### Original intent

The user identified too many documents, lists, asset lists, matrices and canonical/atomic fragments. The need was to build an atomic catalogue of human-used artefacts, so when the owner asks for a one-pager, deck, white paper, McKinsey map, 2x2 or research blueprint, the system knows what exists and which version to use.

The first catalogue direction:

- create atomic artefact types
- keep only three versions of each artefact
- link brands and businesses to their preferred artefact variants
- add/process new, modified and retired assets through a governed table
- link this to the existing asset matrix/poster/research system

### Sources discovered and linked

The thread searched Drive, Notion and GitHub-connected material and found multiple overlapping source classes:

- Tech4Humanity Canonical Registry
- T4H Canonical Doctrine & Registry
- AGL Control Matrix Handoff
- The Pen — Intake & Capture
- Agent House Rules / Bootstrap Contract
- 10K Agent Canonical Registry
- COAX status / master-brain reconciliation
- CATALOG-001 T4H Supabase Portfolio
- T4H infrastructure map/state files
- Master Asset Matrix — AI Sweet Spots
- t4h_study_registry_master_v3
- MAAT catalogues
- T4H Agent Catalogues
- Thriving Kids + NDIS Catalogue
- RFT Parsing Engine / Talent Intelligence materials
- Product Business Consumption Matrix
- Business Product Price Matrix

### Critical model change

The Atomic Document Catalogue is not the parent system.

Correct hierarchy:

```text
T4H Atomic Operating Catalogue
  -> Canonical Doctrine
  -> Portfolio Registry
  -> Service Catalogue
  -> Commercial Widget Registry
  -> Demand Centre Registry
  -> Document Atom Registry
  -> Research Asset Registry
  -> Runtime / Infrastructure Registry
  -> Agent / Worker Registry
  -> Control Tower / Master Brain Registry
  -> Evidence Registry
  -> Process Registry
```

The document layer is one child layer of the whole operating catalogue.

### Register created and expanded

A live Google Sheet was created:

T4H Atomic Document Preference Register — Brands Businesses Processes
https://docs.google.com/spreadsheets/d/11GtsYKxZRud7wwl9eO_kZNIwg686VZu1d20KUyS1JUc

Original sheets:

- Brand Preferences
- Business Preferences
- Process AMD
- Links

Expanded sheets:

- Canonical Sources
- Service Catalogue
- Demand Centres
- Control Towers
- Runtime Systems
- Agent Systems
- Crosswalk
- Loop Chain

Seed businesses:

- AI Sweet Spots
- Canberra Consulting
- AGL Control Plane

### GitHub contract committed

File:
contracts/t4h-atomic-operating-catalogue-v1.md

Commit:
e43502b906d80b6e2093d0a2a488624ceb0309b7

Purpose:
Defines the parent operating catalogue, child registries, loop chain, HITL rule, evidence states, seeded sources and deployment gate.

### Deployment/recovery gate created

Issue:
#122 — DEPLOYMENT GATE — T4H Atomic Operating Catalogue v1
https://github.com/TML-4PM/the-pen/issues/122

Originally this issue was a deployment gate. It has now been escalated into the parent whole-system recovery gate.

## Pass 2 — missed or corrected information

### Missed correction 1 — Pen is too late

The user correctly pointed out that enforcement at the Pen is too late.

Correction added to issue #122:

- Pen is only a queue/receipt layer.
- Pen proves something entered the system; it does not prevent bad work from being created.
- Effective enforcement must happen before creation.

Required upstream and downstream enforcement layers:

1. Prompt / generator preflight
2. Registry entrypoint
3. Sheet-level guardrails
4. GitHub workflow / repo guardrails
5. Bridge / runtime guardrails
6. Gatekeeper as final promotion gate, not first enforcement

Required metadata before Pen execution:

- active_issue
- canonical_register_checked=true
- duplicate_check=passed
- expected_cost_aud
- stop_condition
- deployment_gate
- evidence_state
- idempotency_key
- rollback_path

If missing, worker must reject before execution.

### Missed correction 2 — not an IT issue

The user clarified this is not a builder session. They own and run the business; they should not be picking up IT problems.

Correction added to issue #122:

This is a whole-system operating failure pattern:

- upstream actors can create work without preflight
- midstream registries can duplicate truth
- downstream queues can receive invalid work
- runtime can execute before evidence/cost gates are proven
- executive owner is forced into technical triage

The new objective is a single operating recovery chain that fixes upstream, midstream and downstream controls together.

### Executive abstraction boundary

Business owner should see only:

- business state
- risk state
- spend state
- revenue state
- decision gates

Business owner should not handle:

- trigger failures
- duplicate registries
- queue wiring
- worker failures
- schema drift
- connector drift
- evidence plumbing

All technical drift must collapse into one executive report format:

- what is broken
- business impact
- whether spend/revenue is affected
- what the system fixed or blocked
- decision needed only if deployment/public/destructive/legal/financial

### Missed correction 3 — cost/control problem

A loop-cost-control policy was created after the user raised bill/iteration concerns.

File:
contracts/loop-cost-control-policy-v1.md

Commit:
a9aa8bc41759f0197a7825658890c76818108865

Core controls:

- one active issue per programme
- no duplicate catalogues/matrices/registers
- no open-ended loops
- no repeated searches without new source class or named gap
- no paid runtime/API/worker/deployment without gate
- no unproven claims to advance a task
- no new artefact unless linked to the active issue

Default loop limits:

- max_cycles: 3
- max_new_files: 2
- max_external_calls: 12
- expected_cost_aud: 0
- stop condition: duplicate found, no new evidence, missing proof, deployment boundary

### Missed correction 4 — research duplication risk

The user raised that a lot of research work is active and must not be done two, three or four times because the system missed a source.

Research-specific controls now required:

1. Every research item must first check:
   - Master Asset Matrix
   - t4h_study_registry_master_v3
   - R&D Evidence Matrix
   - Atomic Operating Catalogue Crosswalk
   - Canonical Sources sheet

2. Every research artefact must carry:
   - study_id or research_slug
   - source dataset reference
   - method/protocol reference
   - evidence_state
   - output artefact type
   - replacement/retirement relationship if superseding

3. No research paper/poster/white paper/deck should be generated unless:
   - it links to the canonical study registry or a new registered study row
   - it passes duplicate detection
   - it has an evidence classification
   - it is attached to the active control issue or successor

4. Existing research material must be consolidated, not regenerated.

5. Samples are examples only until promoted into canonical assets.

## Correct operating doctrine

### Wrong model

```text
human -> AI -> generate -> discover drift -> ask human to fix IT
```

### Correct model

```text
human intent
  -> executive abstraction layer
    -> preflight enforcement
      -> canonical register lookup
        -> duplicate detection
          -> cost gate
            -> registry bind
              -> controlled generation
                -> queue/runtime
                  -> evidence writeback
                    -> executive report
```

### Core rule

Problems collapse downward, not upward.

The system absorbs operational complexity. The business owner receives only business-level state and decisions.

## Current artefacts and receipts

### Live register

T4H Atomic Document Preference Register — Brands Businesses Processes
https://docs.google.com/spreadsheets/d/11GtsYKxZRud7wwl9eO_kZNIwg686VZu1d20KUyS1JUc

### Operating catalogue contract

contracts/t4h-atomic-operating-catalogue-v1.md
Commit: e43502b906d80b6e2093d0a2a488624ceb0309b7

### Cost control policy

contracts/loop-cost-control-policy-v1.md
Commit: a9aa8bc41759f0197a7825658890c76818108865

### Parent issue

Issue #122
https://github.com/TML-4PM/the-pen/issues/122

Comments added:

- Pen is too late / upstream enforcement required
- Whole-system recovery / executive must not triage IT

## Updated classification

| Layer | State |
|---|---|
| Atomic Operating Catalogue concept | REAL as contract |
| Live register scaffold | REAL |
| Crosswalk seed | PARTIAL |
| GitHub issue gate | REAL |
| Cost-control policy | REAL |
| Upstream enforcement design | REAL |
| Automated upstream enforcement | PARTIAL |
| Runtime rejection enforcement | PARTIAL |
| Executive abstraction layer | SPEC/PARTIAL |
| Research dedupe enforcement | PARTIAL |
| Deployment | BLOCKED until gate completion |

## Required next implementation work

This is the next chain and should be implemented, not re-discussed:

### 1. Preflight contract

Create a required preflight object for every worker/generator/search:

```yaml
preflight:
  active_issue: 122
  canonical_register_checked: true
  duplicate_check: passed
  expected_cost_aud: 0
  stop_condition: defined
  evidence_state: SPEC|PARTIAL|REAL
  deployment_gate: required_if_public_or_runtime
```

### 2. Register permission model

Move from spreadsheet-only governance toward Supabase-backed canonical tables with:

- unique IDs
- slug/type unique constraints
- lifecycle_state
- evidence_state
- replaced_by
- canonical boolean
- source links
- active_issue
- cost policy fields

### 3. Pen rejection contract

Pen workers must reject invalid jobs missing:

- active_issue
- idempotency_key
- duplicate_check
- cost cap
- rollback path
- evidence state

### 4. Runtime rejection contract

Bridge/workers must reject:

- paid actions without gate
- deployment without approval
- unregistered output paths
- missing evidence writeback

### 5. Research anti-duplication contract

Before any research output:

- check Master Asset Matrix
- check Study Registry
- check Evidence Matrix
- check Crosswalk
- check Canonical Sources
- attach evidence classification
- update/replace instead of duplicate

### 6. Executive report contract

All drift reports must be collapsed into:

- broken item
- business impact
- spend impact
- revenue impact
- what system did
- decision required, if any

## Receipt conclusion

This thread produced a partial but important operating correction.

The system now has:

- a parent Atomic Operating Catalogue model
- a live expanded register
- a GitHub operating contract
- a GitHub cost-control contract
- a parent recovery/deployment issue
- issue comments documenting two critical corrections

The remaining work is not more ideation. It is enforcement implementation upstream, at the registry, at the Pen, at runtime, and at executive reporting.

No research work should be generated again without checking the canonical research spine first.

No business owner should be forced into IT triage.

Pen-only enforcement is rejected as too late.

Whole-system recovery is now the active programme.
