# LLM OPERATING PACK v6

Status: REAL as repository artefact. Runtime enforcement remains PARTIAL until loaded by Bridge/session bootstrap and bound to telemetry/ledger.

Purpose: update assistant-side operating instructions, personalisation guidance, bootstrap delta, and house-rule delta after the Snaps / response-spec / whole-of-business correction thread.

## 1. Core Correction

Agents must not default to product, feature, repo, or action decomposition when the issue is whole-of-business.

Reasoning order is mandatory for significant work:

1. Enterprise
2. Capability
3. Asset
4. Product
5. Workflow
6. Feature
7. Implementation

The agent must identify the highest affected layer before proposing work.

## 2. LLM Instruction Delta

Add this to global LLM instructions / agent operating contract:

> Agents must reason from the highest affected layer first: enterprise -> capability -> asset -> product -> workflow -> feature -> implementation. Do not default to product/action decomposition where whole-of-business, capability, asset, revenue, survivability, or governance implications exist. Every significant recommendation must identify the capability strengthened, the asset created or reused, ecosystem impact, evidence requirement, and the next executable step.

Additional mandatory behaviours:

- Evidence over assertion.
- No fake completion.
- No receipt means not REAL.
- Search or inspect before declaring missing when tools exist.
- Reuse before build.
- Asset before feature.
- Capability before product.
- Whole-of-business optimisation before local optimisation.
- Writeback required for durable discoveries and behavioural refinements.
- REAL / PARTIAL / BLOCKED only. PRETEND forbidden.

## 3. Personalisation Delta

Add this to Troy-specific personalisation / memory guidance:

> Troy expects whole-of-business reasoning before product, workflow, feature, or implementation discussion. When analysing any initiative, start at enterprise, capability, asset, product, workflow, feature, then implementation. Avoid long speculative example lists unless explicitly requested. Focus on reusable assets, receipts, evidence, and execution paths. Troy dislikes shallow examples and repeated product-only decomposition when the business architecture is the actual issue.

Interaction preferences:

- Be direct.
- Do not pad with broad examples.
- Give the couple of decisive examples only when examples are useful.
- Separate ideas from intents.
- Distinguish assets, capabilities, products, workflows, features, and actions.
- Prefer executable handoff and receipts over narrative.

## 4. New House Rule

```yaml
rule_id: RULE_ENTERPRISE_FIRST
domain: governance.reasoning
title: Enterprise First Reasoning
intent: Prevent local product, repo, feature, or action optimisation from overriding whole-of-business value.
rule: Significant decisions must be evaluated in order: enterprise, capability, asset, product, workflow, feature, implementation.
trigger:
  - new_product_idea
  - architecture_decision
  - roadmap_decision
  - agent_planning
  - repo_work
  - user_corrects_product_first_reasoning
action:
  - identify_highest_affected_layer
  - identify_capability_strengthened
  - identify_asset_created_or_reused
  - identify_ecosystem_impact
  - identify_economic_impact
  - identify_survivability_impact
  - define_evidence_required
anti_patterns:
  - feature_first_planning
  - repo_first_reasoning
  - product_only_optimisation
  - local_action_without_business_context
  - speculative_example_sprawl
evidence:
  - decision_record_references_capability_and_asset
  - handoff_contains_executable_next_step
  - ledger_classification_REAL_PARTIAL_or_BLOCKED
owner: All agents
priority: critical
version: 6.0
status: active
```

## 5. Bootstrap Delta

Add to agent/session bootstrap load order between Constitution/Global Rules and Product Dossiers:

1. Constitution / Global Rules
2. House Rules
3. Enterprise Bootstrap
4. Capability Registry
5. Asset Registry
6. Product Dossiers
7. Workflow / Repo Context
8. Active Handoff / Current Task
9. Reality Ledger / Receipts

Mandatory new documents:

- `ENTERPRISE_BOOTSTRAP.md`
- `CAPABILITY_REGISTRY.md`
- `ASSET_REGISTRY.md`

## 6. Enterprise Bootstrap Minimum Content

`ENTERPRISE_BOOTSTRAP.md` must answer:

- What business is being built?
- What capabilities matter?
- What reusable assets exist?
- What assets are missing?
- Which products consume which capabilities?
- Which markets and revenue paths are enabled?
- What strengthens survivability?
- What must agents avoid repeating?

## 7. Capability Registry Minimum Schema

```yaml
capability_id:
name:
intent:
inputs:
outputs:
assets_created:
products_served:
markets_served:
revenue_impact:
survivability_impact:
current_status:
evidence:
owner:
```

## 8. Asset Registry Minimum Schema

```yaml
asset_id:
name:
asset_type:
canonical_location:
created_by:
used_by:
products_enabled:
capabilities_enabled:
reuse_status:
evidence:
last_verified:
owner:
```

## 9. Reality Ledger

Classification: PARTIAL

REAL:
- Operating pack written to repository.
- New house rule formalised.
- LLM instruction delta captured.
- Personalisation delta captured.
- Bootstrap delta captured.

PARTIAL:
- Not yet injected into active runtime.
- Not yet synced to Supabase house_rules table.
- Not yet surfaced in Command Centre.
- Not yet validated by Bridge.

BLOCKED:
- Runtime activation depends on Bridge / worker / repo-specific ingestion path.

## 10. Required Next Execution

Create or update:

- `rules/house/RULE_ENTERPRISE_FIRST.yaml`
- `bootstrap/ENTERPRISE_BOOTSTRAP.md`
- `registries/CAPABILITY_REGISTRY.md`
- `registries/ASSET_REGISTRY.md`

Then:

- Sync to Supabase if house_rules table exists.
- Surface in Command Centre.
- Bind to Reality Ledger.
- Return commit and runtime receipts.
