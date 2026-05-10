# Machine Onboarding Session Requirements

Version: v3.1 (Validated — Preflight + Traps + Atomic Elements integrated)
Status: ACTIVE
Canonical Owner: The Pen
Canonical Path: machine-onboarding/SESSION_REQUIREMENTS.md
Supersedes:
  - v1 (commit `7c1c8155e87aa052c6478ac39273d3aaee9f6cac`)
  - v3 (commit `62c72b2d0964b87474620d18ddbf37511cd902de`)
Last Updated: 2026-05-11
Change log:
  - v3.1: Added §19 (Preflight), §20 (Discovered Traps), §21 (Atomic Elements). Fixed SKS project drift. Embedded cluster registry FK rule.

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

### 3.0 Preflight (NEW in v3.1)

Run `PREFLIGHT.md` before any other action. Four mandatory steps: pin bridge, surface open blocks, verify canonical runtime objects, confirm HRE loaded. Output is mandatory ledger metadata (see §19).

### 3.1 Search
- Locate all relevant source material, files, repos, threads, tasks, receipts, prior decisions, dependencies, telemetry, and runtime state available to the machine.
- Record what was searched, what was not accessible, and why.

### 3.2 Audit
- Compare discovered material against the stated intent, canonical rules, known execution doctrine, current asset state, runtime state, and registry state.
- Identify duplicates, contradictions, stale assumptions, dead tasks, missing receipts, weak evidence, unclosed handoffs, orphaned deployments, unbound assets, hidden dependencies, unverifiable outputs, false REAL claims.

### 3.3 Analysis
- Convert the audit into decisions, actions, gaps, risks, owner paths, evidence requirements, recovery requirements, rollback paths, dependency chains, monetisation impact.
- Classify every material claim as REAL, PARTIAL, BLOCKED, or INVALID.

### 3.4 Execution or Handoff
- Execute directly where authorised.
- Otherwise package a bridge-ready payload (see `BRIDGE_HANDOFF_STANDARD.yaml`).
- A bridge handoff is not complete unless payload was transmitted, receipt returned, receipt recorded, and receipt bound to the ledger. **Writing a prompt is not a handoff.**

### 3.5 Receipt
- Apply `canonical/atomic-elements/bridge_receipt_pattern.yaml` (ATOM-EXEC-001).
- Receipts must be replayable, durable, traceable, and linked to task IDs and execution state.

### 3.6 Close
- Close only when completion is evidenced.
- If completion cannot be evidenced, declare PARTIAL or BLOCKED with the exact dependency.

---

## 4. Canonical Reality Library (Mandatory Reference Layer)

Machines may not onboard against threads alone. Every onboarding session must bind against the canonical operational reference library at `machine-onboarding/canonical/`.

| # | Registry | File / Path | Seeded |
|---|----------|-------------|--------|
| 0 | Machine Reality Index | `MACHINE_REALITY_INDEX.yaml` | yes |
| 1 | Systems Registry | `canonical/systems/` | no |
| 2 | Business Registry | `canonical/businesses/` | no (live source: `public.t4h_business_registry`) |
| 3 | Product Registry | `canonical/products/` | no |
| 4 | Asset Registry | `canonical/assets/` | no |
| 5 | Atomic Elements Registry | `canonical/atomic-elements/` | **yes (5 primitives, v3.1)** |
| 6 | Runtime Environment Registry | `canonical/runtime-environments/` | **yes (v3.1)** |
| 7 | Canonical Repo Registry | `canonical/repos/` | **yes (seed, v3.1)** |
| 8 | Domain & Surface Registry | `canonical/domains/` | no |
| 9 | Doctrine Registry | `canonical/doctrine/` | **yes (CLUSTERS + TRAPS, v3.1)** |
| 10 | Evidence & Receipt Registry | `canonical/receipts/` | no (covered by `EVIDENCE_STANDARD.yaml` for now) |
| 11 | Telemetry Registry | `canonical/telemetry/` | no (covered by ATOM-EXEC-005) |
| 12 | Relationship Graph | `canonical/relationships/` | no (seed in `MACHINE_REALITY_INDEX.yaml`) |

**Hard rule:** Failure to load `MACHINE_REALITY_INDEX.yaml` or validate against the canonical library downgrades trust classification automatically.

Machines must NEVER infer system ownership from naming, business identity from product hints, canonical repo from recency, or environment trust from URL alone.

---

## 5. House Rules Engine Integration (L1 Binding)

Every session is governed by the HRE. Non-overridable rules inside an onboarded session:

- **Writeback rule.** Information not written back to a system of record is treated as lost.
- **No passive waiting.** Search before declaring missing.
- **Continuous refinement.** Output that does not advance prior state is flagged as drag.
- **Coherence sweep.** Conflicting rules must be surfaced, not silently merged.
- **Escalation chain.** Authority resolves via `canonical/atomic-elements/escalation_chain.yaml` (ATOM-EXEC-003).
- **Search telemetry.** Apply `canonical/atomic-elements/telemetry_block.yaml` (ATOM-EXEC-005).

HRE violations are logged as defects even when output appears successful.

---

## 6. Standard Knowledge System Binding (L3 Resolution)

Before hardcoding any stable value, resolve via:

1. `ops.v_standard_knowledge_active` (runtime view, S1, **NOT S2** — see TRAPS-D-2)
2. `cap_secrets` where `is_canonical=true AND is_deprecated=false`
3. `public.t4h_business_registry` (live portfolio)
4. `MACHINE_REALITY_INDEX.yaml` and `canonical/` files

Hardcoded magic values where SKS resolution exists trigger an automatic regression flag.

---

## 7. Tight Completion Contract

(unchanged from v3 — see prior commit `62c72b2d`)

```yaml
status: REAL | PARTIAL | BLOCKED
result: ...
evidence: [{type: ..., value: ...}]
gaps: [...]
next_action: ...
elevation: { new_value_created: ... }
pressure_flags: { stagnation, drag, regression }
score: { execution, evidence, economic, reuse, delta }
ledger:
  task_id, intent, search_scope, audit_scope, execution, output, status, evidence, supersedes
```

---

## 8. Classification Rules

(unchanged from v3 — REAL / PARTIAL / BLOCKED / INVALID with automatic downgrade triggers)

## 9. HITL Defect Recovery Rule

One verified HITL error invalidates the entire scan. Apply `canonical/atomic-elements/recovery_loop.yaml` (ATOM-EXEC-004) for the cycle-level rerun. No patch-only recovery permitted.

## 10. Full-Rerun Trigger Classes

(unchanged from v3 — 17 trigger classes)

## 11. Pressure Layer (Anti-Stagnation)

(unchanged from v3 — stagnation -0.20, drag -0.15, regression -0.25; ante-up requirement)

## 12. Runtime Integrity Rules

(unchanged from v3 — runtime > planned, deployed ≠ operational, execution without evidence → PARTIAL, missing ledger → downgrade, supersession needs explicit link)

## 13. Autonomous Recovery Requirements

Apply ATOM-EXEC-004 recovery_loop. Capabilities: retry, replay, re-search, re-audit, dependency recheck, stale state invalidation, receipt regeneration, bridge retry, telemetry refresh, rollback validation.

## 14. Non-Negotiables

(unchanged from v3 — 12 hard rules)

## 15. Machine Onboarding Acceptance Test

Tests T01–T15 defined in `ONBOARDING_ACCEPTANCE_TESTS.yaml`. Critical: T05, T08, T09, T11, T13. Failing T11 = machine fails onboarding entirely.

## 16. Canonical Folder Structure

```
machine-onboarding/
  SESSION_REQUIREMENTS.md          ← this file (v3.1)
  MACHINE_REALITY_INDEX.yaml       ← v1.1 root cognition graph
  PREFLIGHT.md                     ← session-start 4-step checklist
  EVIDENCE_STANDARD.yaml
  BRIDGE_HANDOFF_STANDARD.yaml
  ONBOARDING_ACCEPTANCE_TESTS.yaml
  HOUSE_RULES_INTEGRATION.md
  ONBOARDING_VALIDATION_REPORT_v3.md  ← durable validation record
  canonical/
    doctrine/
      CLUSTERS.yaml                ← FK source for reality_ledger.cluster_id
      TRAPS.md                     ← session traps register
    atomic-elements/
      00_INDEX.md
      bridge_receipt_pattern.yaml  ← ATOM-EXEC-001
      evidence_envelope.yaml       ← ATOM-EXEC-002
      escalation_chain.yaml        ← ATOM-EXEC-003
      recovery_loop.yaml           ← ATOM-EXEC-004
      telemetry_block.yaml         ← ATOM-EXEC-005
    runtime-environments/
      ENVIRONMENTS.yaml
    repos/
      CANONICAL_REPOS.yaml
    systems/ businesses/ products/ assets/ domains/ receipts/ telemetry/ relationships/  ← scaffold
```

## 17. Closure of Identified Gaps

(unchanged from v3 — 5 architectural gaps closed; v3.1 additionally closes operational gaps: preflight scattered, cluster FK undocumented, atomic elements empty, SKS location drift)

## 18. Operating Principle

(unchanged from v3 — not documentation; organisational cognition infrastructure)

---

## 19. Preflight Contract (NEW in v3.1)

Every session loads `PREFLIGHT.md` and emits a `preflight` block in the ledger evidence jsonb:

```yaml
preflight:
  bridge_pinned: true | false
  open_blocks_count: <int>
  open_blocks_acknowledged: [<ledger_id>, ...]
  l3_sks_view_present: true | false
  l4_ledger_present: true | false
  l1_hre_loaded: true | false
  cluster_registry_present: true | false
  ran_at: <ISO timestamp>
```

A missing preflight block downgrades the session to PARTIAL automatically.

---

## 20. Discovered Traps Reference (NEW in v3.1)

Active session traps are documented in `canonical/doctrine/TRAPS.md`. Current entries:

| ID | Severity | Summary |
|----|----------|---------|
| TRAPS-D-1 | HIGH | `reality_ledger.cluster_id` is FK to `core.cluster_registry` |
| TRAPS-D-2 | HIGH | SKS is on S1, not S2 |
| TRAPS-D-3 | MEDIUM | `supabase_rest_proxy POST` can silently no-op |
| TRAPS-D-4 | HIGH | `troy-sql-executor` masks RETURNING and pg errors |
| TRAPS-D-5 | LOW | Leading SQL comment breaks read tool output |

Every session that discovers a new trap MUST append it to `canonical/doctrine/TRAPS.md` as part of writeback.

---

## 21. Atomic Elements Registry Reference (NEW in v3.1)

Reusable execution primitives live in `canonical/atomic-elements/`. Seeded:

| ID | Name | Used by |
|----|------|---------|
| ATOM-EXEC-001 | bridge_receipt_pattern | §3.5 Receipt |
| ATOM-EXEC-002 | evidence_envelope | §7 Completion Contract, EVIDENCE_STANDARD.yaml |
| ATOM-EXEC-003 | escalation_chain | §5 HRE, §13 Recovery |
| ATOM-EXEC-004 | recovery_loop | §9 HITL, §13 Recovery |
| ATOM-EXEC-005 | telemetry_block | §5 HRE search telemetry, §19 Preflight |

Each primitive has a stable ID. Modifying a primitive requires a `supersedes` link in the ledger.
