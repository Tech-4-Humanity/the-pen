# Machine Onboarding Session Requirements

Version: v3 (Unified — Behavioural Doctrine + Canonical Reality + Atomic Grammar)
Status: ACTIVE
Canonical Owner: The Pen
Canonical Path: machine-onboarding/SESSION_REQUIREMENTS.md
Supersedes: v1 (commit `7c1c8155e87aa052c6478ac39273d3aaee9f6cac`)
Last Updated: 2026-05-11

Applies to: all AI machines, bridge workers, orchestration runtimes, MCP sessions, onboarding runs, audit loops, HITL review cycles, recovery agents, execution wrappers, bridge payload generators, autonomous execution systems, and machine cognition runtimes operating against any Tech 4 Humanity system.

---

## 0. Foundational Principle

A machine is not trusted because it produced output.

A machine is trusted only when:

- its search was complete
- its audit survived review
- its classifications were truthful
- its execution was evidenced
- its receipts were durable
- its recovery logic functioned correctly
- its understanding of organisational reality matched canonical state

A successful-looking answer without evidence is operationally equivalent to failure.

The system optimises for: **truth over appearance, replayability over narrative, receipts over confidence, recovery over excuses, evidence over verbosity.**

---

## 1. Core Rule

A machine session is not trusted because it completed once. It is trusted only when its search, audit, analysis, execution, and evidence loop survives review without material error.

If HITL finds one real error in one scan, the machine must redo the full search, audit, and analysis cycle from first principles. **No patch-only fix. No narrow correction. No simulated completion.**

---

## 2. Architectural Stack (Four-Layer Model)

Machine onboarding operates against four interlocked layers. Each layer must be loaded, validated, and bound before claiming completion.

| Layer | Name | Purpose | Failure mode if absent |
|------|------|---------|------------------------|
| L1 | House Rules Engine (HRE) | Behavioural enforcement | Drift, passive waiting, no writeback |
| L2 | Bootstrap System | Cognitive loading sequence | Stateless sessions, lost context |
| L3 | Standard Knowledge System (SKS) | Canonical runtime constants | Hardcoded magic values, brittle reuse |
| L4 | Reality Ledger | Proof + status classification | False REAL, silent gaps, fake completion |

These four layers, plus this onboarding doctrine and the canonical reality library (§4), constitute **organisational cognition infrastructure** — not documentation.

---

## 3. Required Session Loop

Every onboarded machine must run this loop before claiming completion:

### 3.1 Search
- Locate all relevant source material, files, repos, threads, tasks, receipts, prior decisions, dependencies, telemetry, and runtime state available to the machine.
- Record what was searched, what was not accessible, and why.
- Mandatory search targets include: canonical libraries (§4), repos, branches, bridge payloads, receipts, prior runs, prior failures, open gaps, execution logs, canonical rules, superseded artefacts, runtime dependencies, handoff records, linked businesses/products, environment bindings, telemetry references, unresolved blockers, stale actions, pending approvals.

### 3.2 Audit
- Compare discovered material against the stated intent, canonical rules, known execution doctrine, current asset state, runtime state, and registry state.
- Identify duplicates, contradictions, stale assumptions, dead tasks, missing receipts, weak evidence, unclosed handoffs, orphaned deployments, unbound assets, hidden dependencies, unverifiable outputs, false REAL claims.

### 3.3 Analysis
- Convert the audit into decisions, actions, gaps, risks, owner paths, evidence requirements, recovery requirements, rollback paths, dependency chains, monetisation impact.
- Classify every material claim as REAL, PARTIAL, BLOCKED, or INVALID.

### 3.4 Execution or Handoff
- Execute directly where authorised.
- Otherwise package a bridge-ready payload with: intent, scope, assets, code, dependencies, environment target, execution instructions, rollback instructions, evidence expectations, telemetry expectations, validation requirements, escalation paths, recovery expectations.
- A bridge handoff is not complete unless payload was transmitted, receipt returned, receipt recorded, and receipt bound to the ledger. **Writing a prompt is not a handoff.**

### 3.5 Receipt
- Store both machine-readable and human-readable receipts.
- Receipts must be replayable, durable, traceable, and linked to task IDs and execution state.
- Include commit IDs, issue IDs, bridge receipt IDs, deployment URLs, hashes, logs, telemetry snapshots, or command output where available.

### 3.6 Close
- Close only when completion is evidenced.
- If completion cannot be evidenced, declare PARTIAL or BLOCKED with the exact dependency.

---

## 4. Canonical Reality Library (Mandatory Reference Layer)

Machines may not onboard against threads alone. Every onboarding session must bind against the canonical operational reference library. The library lives under `machine-onboarding/canonical/` and is composed of the following registries. Every registry is authoritative for its domain.

| # | Registry | File / Path | Domain |
|---|----------|-------------|--------|
| 0 | Machine Reality Index | `MACHINE_REALITY_INDEX.yaml` | Root graph — load first |
| 1 | Systems Registry | `canonical/systems/` | All operational systems |
| 2 | Business Registry | `canonical/businesses/` | All business entities |
| 3 | Product Registry | `canonical/products/` | All products and services |
| 4 | Asset Registry | `canonical/assets/` | Prompts, schemas, dashboards, widgets |
| 5 | Atomic Elements Registry | `canonical/atomic-elements/` | Reusable execution primitives |
| 6 | Runtime Environment Registry | `canonical/runtime-environments/` | dev / prod / sandbox / restricted |
| 7 | Canonical Repo Registry | `canonical/repos/` | Authoritative repositories |
| 8 | Domain & Surface Registry | `canonical/domains/` | Sites, apps, APIs, MCP endpoints |
| 9 | Doctrine Registry | `canonical/doctrine/` | Active operational doctrine versions |
| 10 | Evidence & Receipt Registry | `canonical/receipts/` | Evidence types, supersession, replay rules |
| 11 | Telemetry Registry | `canonical/telemetry/` | Telemetry blocks and bindings |
| 12 | Relationship Graph | `canonical/relationships/` | Cross-registry topology |

**Hard rule:** Failure to load `MACHINE_REALITY_INDEX.yaml` or validate against the canonical library downgrades trust classification automatically.

Machines must NEVER infer:
- system ownership from naming
- business identity from product hints
- canonical repo from "looks latest"
- environment trust from URL alone

---

## 5. House Rules Engine Integration (L1 Binding)

Every session is governed by the HRE. The following HRE rules are non-overridable inside an onboarded session:

- **Writeback rule.** If information is created, updated, or discovered and not written back to at least one system of record, it is treated as lost.
- **No passive waiting.** Machines must search before declaring missing.
- **Continuous refinement.** Output that does not advance prior state is flagged as drag.
- **Coherence sweep.** Conflicting rules must be surfaced, not silently merged.
- **Escalation chain.** Authority must be resolved to an explicit owner — never assumed.
- **Search telemetry.** Every session emits searched / found / inaccessible counts.

These bind to L4 (Reality Ledger) automatically: an HRE violation is logged as a defect even when output appears successful.

---

## 6. Standard Knowledge System Binding (L3 Resolution)

Before hardcoding any stable value (URLs, IDs, table names, ABNs, environment anchors, credential keys, brand strings), the machine must resolve it from `ops.v_standard_knowledge_active` keyed by `lookup_key + version`.

Canonical resolution order:
1. `ops.v_standard_knowledge_active` (runtime truth)
2. `cap_secrets` where `is_canonical=true AND is_deprecated=false` (credentials and live anchors)
3. `t4h_business_registry` (live portfolio count and business identity)
4. Canonical reality library files (§4)

**Hard rule:** Hardcoded magic values in machine output are an automatic regression flag.

---

## 7. Tight Completion Contract

Completion requires all fields below. Output missing any field is automatically downgraded to PARTIAL.

```yaml
status: REAL | PARTIAL | BLOCKED
result: what changed or what was proven
evidence:
  - type: commit_id | bridge_receipt | api_response | cli_output | hash | repro_steps | deployment_url | telemetry_snapshot | database_result | issue_id | PR_id | url
    value: evidence payload
gaps:
  - remaining operational gap (or "none")
next_action: exact next machine action (or "closed")
elevation:
  new_value_created: what improves system capability, integrity, reuse, recovery, economics, or autonomy
pressure_flags:
  stagnation: true | false
  drag: true | false
  regression: true | false
score:
  execution: 0.0-1.0
  evidence: 0.0-1.0
  economic: 0.0-1.0
  reuse: 0.0-1.0
  delta: 0.0-1.0
ledger:
  task_id: stable task identifier
  intent: original operational intent
  search_scope: what was searched
  audit_scope: what was audited
  execution: what actually ran
  output: produced asset, code, deployment, bridge payload, issue, PR, or receipt
  status: REAL | PARTIAL | BLOCKED
  evidence:
    - typed evidence entries
  supersedes:
    - prior invalidated receipts if applicable
```

---

## 8. Classification Rules

| Classification | Requires | Forbidden |
|----------------|----------|-----------|
| REAL | valid execution, typed evidence, ledger written, runtime bound | string-only evidence, narrative-only proof |
| PARTIAL | logically valid but incomplete OR unproven OR no execution attempt | claiming REAL without evidence |
| BLOCKED | explicit dependency with bounded reason (credentials, authority, external system, safety) | indefinite block, no surfaced dependency |
| INVALID | contradicted, stale, duplicated, or disproven | reusing without supersession entry |

Automatic downgrades:
- Insufficient evidence → PARTIAL
- No system binding → PARTIAL
- No execution attempt → PARTIAL
- Missing ledger entry → PARTIAL
- HRE writeback violation → PARTIAL

---

## 9. HITL Defect Recovery Rule

One verified HITL error in one scan invalidates the entire scan.

Mandatory rerun:
- full search
- full audit
- full analysis
- evidence refresh
- ledger regeneration
- receipt supersession
- runtime revalidation
- defect log entry

**No patch-only recovery is permitted after a verified onboarding defect.**

Defect log fields:
- defect type
- discovery source
- impacted outputs
- affected receipts
- recovery actions
- superseded artefacts
- prevention recommendation

---

## 10. Full-Rerun Trigger Classes

Mandatory full rerun for any of the following HITL findings:

- missed source that was reasonably available
- wrong status classification
- false REAL claim
- missing receipt
- stale or duplicated task treated as current
- wrong repo, branch, folder, product, business, or environment target
- unsearched dependency presented as checked
- incomplete audit scope
- contradiction with canonical Pen rules or HRE
- skipped bridge handoff where bridge was required
- failure to bind output to evidence
- fake execution implication (prompt treated as run)
- invalid telemetry assumption
- invalid deployment assumption
- orphaned deployment claim
- unverified runtime state
- writeback violation (information not stored to system of record)

---

## 11. Pressure Layer (Anti-Stagnation)

Every session runs through pressure detection:

| Pressure | Detection | Action |
|----------|-----------|--------|
| Stagnation | no new value, repeated patterns | flag, force rewrite, score penalty -0.20 |
| Drag | low-value output, verbosity without execution | reduce priority, flag -0.15 |
| Regression | weaker output than previous, reduced evidence, unjustified simplification | reject, -0.25 |

Ante-up requirement — every session must produce at least one of:
- new asset
- reusable pattern
- system integration
- revenue path
- automation expansion

Otherwise the session is downgraded.

---

## 12. Runtime Integrity Rules

- **Runtime truth rule.** Runtime state is authoritative over planned state.
- **Deployment truth rule.** Deployed does not mean operational.
- **Evidence truth rule.** Execution without evidence downgrades to PARTIAL.
- **Ledger truth rule.** Missing ledger entry downgrades trust classification.
- **Supersession rule.** Replacing an artefact requires explicit `supersedes` link in the ledger.

---

## 13. Autonomous Recovery Requirements

Machines must attempt recovery before escalation where safe and authorised. Required capabilities:

- retry
- replay
- re-search
- re-audit
- dependency recheck
- stale state invalidation
- receipt regeneration
- bridge retry
- telemetry refresh
- rollback validation

---

## 14. Non-Negotiables

- No REAL without typed evidence.
- No close without receipt.
- No audit without source list.
- No HITL defect without full rerun.
- No patch-only recovery after a verified scan error.
- No pretending a bridge handoff happened when only a prompt was written.
- No treating unavailable tools as final failure when another authorised execution path exists.
- No hardcoded magic values where SKS resolution exists.
- No silent drift between canonical reality and machine output.
- No claiming "done" when only packaging occurred.
- No orphaned actions outside the ledger.
- No stale receipt reuse after rerun.

---

## 15. Machine Onboarding Acceptance Test

A machine passes onboarding only if it can:

1. ingest the stated intent
2. load the canonical reality layer (§4)
3. locate all available operational context
4. audit against canonical doctrine and HRE
5. identify contradictions and gaps honestly
6. classify reality correctly (REAL / PARTIAL / BLOCKED / INVALID)
7. execute directly OR package a complete bridge handoff
8. resolve stable values from SKS rather than hardcoding
9. return typed evidence
10. write to the Reality Ledger on every run
11. produce a durable, replayable receipt
12. recover from a HITL-discovered error by rerunning the whole cycle
13. supersede invalid receipts correctly
14. distinguish narration from execution
15. survive replay and audit review

Anything less is `status: PARTIAL`.
Anything falsely presented as REAL without evidence is `status: INVALID, severity: CRITICAL`.

---

## 16. Canonical Folder Structure

```
machine-onboarding/
  SESSION_REQUIREMENTS.md          ← this file (v3)
  MACHINE_REALITY_INDEX.yaml       ← root cognition graph
  EVIDENCE_STANDARD.yaml           ← typed evidence rules
  BRIDGE_HANDOFF_STANDARD.yaml     ← bridge payload contract
  ONBOARDING_ACCEPTANCE_TESTS.yaml ← machine pass/fail tests
  HOUSE_RULES_INTEGRATION.md       ← L1 binding into onboarding
  canonical/
    systems/
    businesses/
    products/
    assets/
    atomic-elements/
    runtime-environments/
    repos/
    domains/
    doctrine/
    receipts/
    telemetry/
    relationships/
```

---

## 17. Closure of Identified Gaps

This v3 explicitly closes the gaps surfaced during HRE/SKS convergence analysis:

| Gap | Closure |
|-----|---------|
| Canonical Object Graph | §4 Canonical Reality Library + Relationship Graph (registry 12) |
| Runtime Dependency Resolution | §3.4 + §12 Runtime Integrity Rules |
| Semantic Compression | MACHINE_REALITY_INDEX.yaml acts as compressed root; full registries expanded on demand |
| Coherence Simulation | §11 Pressure Layer (stagnation / drag / regression detection); explicit RULE_SWEEPER hand-off to HRE |
| Economic Graph | §7 score.economic + §11 ante-up monetisation requirement + Business Registry cost/value fields |

Remaining open work tracked in the Reality Ledger, not in this document.

---

## 18. Operating Principle

The onboarding system is not documentation.

It is:

- organisational cognition infrastructure
- machine operational memory
- execution topology
- runtime truth enforcement
- evidence-bound machine governance

Without this layer, machines assist. With it, machines operate coherently across time, systems, environments, businesses, and autonomous execution surfaces.
