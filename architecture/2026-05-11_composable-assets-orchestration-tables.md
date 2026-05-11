# Composable Assets + Orchestration Tables Architecture

Date: 2026-05-11
Status: PARTIAL -> persisted architecture receipt
Owner: Troy Latter / Tech 4 Humanity ecosystem

## Executive Decision

The ecosystem is not a set of separate brands, sites, apps, or products.

The correct architecture is:

- public surfaces at the top
- reusable assets underneath
- orchestration tables as the control layer
- shared runtime underneath everything

Everything can be shared, renamed, re-skinned, and called something different depending on brand, vertical, audience, or market.

## Core Principle

One capability can appear as many products.

A reading intervention, environmental alert, executive AI coach, consent workflow, governance audit, or agent task may use the same underlying primitives:

- identity
- consent
- signal capture
- telemetry
- workflow
- agent routing
- proof
- evidence
- notification
- dashboard
- runtime execution
- revenue attribution

The brand is a view.
The asset is the reusable capability.
The table is the control surface.
The runtime is the execution fabric.

## Corrected Stack

```text
Civilisation primitives
  - Signal
  - ConsentX
  - Governance / GC-BAT
  - Tech 4 Humanity / common good

Organisational cognition group
  - WorkFamilyAI
  - Augmented Humanity Coach
  - Holo-Org

Applied outcome verticals
  - Outcome Ready
  - AquaMe
  - Reading Buddy
  - Thriving Kids
  - Thriving Biz
  - AI4Tradies
  - other future verticals

Entry-level signal surfaces
  - AI Oopsies
  - Spotto
  - GirlMath
  - quizzes
  - public diagnostics
  - cultural / viral capture surfaces

Composable asset layer
  - assets
  - tables
  - mappings
  - prompts
  - schemas
  - agents
  - offers
  - workflows
  - evidence models
  - telemetry definitions

Runtime layer
  - Pen
  - Bridge
  - Reality Ledger
  - Command Centre
  - Agent Orchestrator
  - Agent Channel
  - Supabase
  - GitHub
  - Vercel
  - AWS
```

## Movement Model

```text
Human intent
  -> signal capture
  -> intent classification
  -> reusable asset selection
  -> table-driven configuration
  -> brand / vertical rendering
  -> orchestration
  -> execution
  -> evidence capture
  -> registry update
  -> dashboard visibility
  -> economic attribution
  -> persistent memory
```

## Why This Matters

The system was previously being interpreted as multiple separate products.
That creates sprawl, duplication, repeated execution, and unresolved orchestration entropy.

The corrected model treats the portfolio as one composable operating system:

- many surfaces
- shared assets
- common tables
- reusable runtime
- different naming per context

## Required Tables

Minimum canonical tables required:

1. `asset_registry`
   - reusable capability inventory
   - asset type, owner, version, maturity, reuse status

2. `surface_registry`
   - brand/site/app/front-door definitions
   - public name, audience, domain, parent group

3. `asset_surface_map`
   - which assets power which surfaces
   - naming overrides per surface

4. `intent_registry`
   - captured human/agent intent
   - source, priority, business, execution state

5. `workflow_registry`
   - repeatable workflows and process atoms
   - trigger, owner, inputs, outputs

6. `proof_registry`
   - evidence, receipts, runtime proof, expiry

7. `economic_registry`
   - offer, pricing, funnel, revenue path, customer value

8. `governance_registry`
   - consent, authority, risk, HITL, policy controls

9. `runtime_registry`
   - execution systems, environments, deployment state

10. `semantic_alias_registry`
   - lets the same asset be called different things in different brands

## Strategic Correction

WorkFamilyAI, Augmented Humanity Coach, and Holo-Org should sit together as a vertical organisational cognition group, not merely side-by-side brands.

Outcome Ready should remain at the applied outcome layer with multiple avenues beneath it.

Signal and ConsentX likely rise toward the top as civilisation primitives.

AquaMe must be uplifted from product/vertical into an environmental intelligence and planetary systems layer.

GC-BAT must be uplifted/clumped into a governance/common-good layer with adjacent trust, safety, consent, and standards assets.

Entry-level signal surfaces are missing from the prior diagram and must be explicitly retained because they provide low-friction public signal acquisition.

## Operating Rule

Do not build new standalone products by default.

Build reusable assets, register them in tables, then expose them through branded surfaces.

## Reality Ledger

status: PARTIAL
result: Architecture decision persisted to GitHub. Runtime database tables and bridge execution are not yet applied from this connector response.
evidence:
  - github_create_file_commit: returned by connector
  - repository: TML-4PM/the-pen
  - path: architecture/2026-05-11_composable-assets-orchestration-tables.md
gaps:
  - Supabase DDL not executed
  - Bridge runtime receipt not produced by live bridge
  - Command Centre widget not updated
  - asset registry not yet populated
next_action:
  - create Supabase DDL for the ten canonical tables
  - bind to Bridge/Pen receipt model
  - add Command Centre view for surface -> asset -> runtime -> proof
elevation:
  - Moves ecosystem from product sprawl to composable asset operating model.
pressure_flags:
  - stagnation: false
  - drag: false
  - regression: false
score:
  execution: 0.55
  evidence: 0.75
  economic: 0.85
  reuse: 1.0
  delta: 0.9
ledger:
  task_id: composable-assets-orchestration-tables-architecture
  intent: persist corrected ecosystem architecture and nesting model
  execution: GitHub file creation via connector
  output: canonical architecture markdown
  status: PARTIAL
  evidence: GitHub commit receipt from create_file
