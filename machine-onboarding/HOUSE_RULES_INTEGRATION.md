# House Rules Engine Integration

Status: ACTIVE
Canonical Owner: The Pen
Binds: HRE (L1) into onboarding doctrine
Companion: `SESSION_REQUIREMENTS.md` §5

## Purpose

The House Rules Engine (HRE) governs *behaviour*. Onboarding requirements govern *cognition and proof*. This file binds the two so that every onboarded machine session inherits HRE enforcement automatically.

## Four-Layer Stack Reminder

| Layer | Function |
|-------|----------|
| L1 — House Rules Engine | behaviour enforcement |
| L2 — Bootstrap System | session cognition loading |
| L3 — Standard Knowledge System | canonical runtime constants |
| L4 — Reality Ledger | proof + classification |

This document is the explicit L1 → onboarding contract.

## Non-Overridable HRE Rules Inside An Onboarded Session

1. **Writeback rule.** If information is created, updated, or discovered and not written back to at least one system of record, it is treated as lost. Verbal acknowledgement is not a write.
2. **Search before missing.** A machine may not declare information missing until it has searched all reasonably available sources and recorded what was searched.
3. **No passive waiting.** If a dependency is uncertain, the machine surfaces the dependency as BLOCKED with a bounded reason. It does not idle.
4. **Continuous refinement.** Output that does not advance prior state is flagged as drag and incurs score penalty.
5. **Coherence sweep.** Conflicting rules, conflicting data, or conflicting receipts must be surfaced — never silently merged. Conflicts route to the RULE_SWEEPER pattern.
6. **Escalation chain.** Authority must resolve to an explicit owner. "The system" is not an owner.
7. **Search telemetry.** Every session emits counts: searched, found, inaccessible, contradicted.

## Bootstrap Folder Contract (L2)

Machines load context in this order. Skipping a layer is a defect.

```
/bootstrap/
  RULES/        ← HRE rules + onboarding doctrine
  SYSTEM/       ← canonical systems registry
  OPERATIONS/   ← active operational state
  PRODUCTS/     ← product registry
  KNOWLEDGE/    ← SKS bindings
  HUMAN/        ← operator preferences and standing orders
```

## SKS Resolution Order (L3)

Before any stable value is hardcoded the machine resolves via:

1. `ops.v_standard_knowledge_active` (runtime view)
2. `cap_secrets` where `is_canonical=true AND is_deprecated=false`
3. `t4h_business_registry` for portfolio identity
4. Canonical reality library files

Hardcoded magic values where SKS resolution exists trigger an automatic regression flag.

## Reality Ledger Binding (L4)

Every session writes one or more rows to `public.reality_ledger` with:

- `task_id` (stable)
- `system`
- `component`
- `status` ∈ {REAL, PARTIAL, BLOCKED}
- `evidence` (jsonb — packs intent, execution, output, score)
- `last_verified`
- `cluster_id` where applicable

Missing ledger row → automatic downgrade.

Per current TRAPS-C session rules:
- `audit.log` REST returns 404 — write `public.reality_ledger` directly.
- Three `reality_ledger` tables exist (public / ops / core) — they are NOT the same table. Public uses CHECK = REAL | PARTIAL | PRETEND; ops uses CHECK = REAL | PARTIAL | BLOCKED | failed. Pack intent/execution/output/score into the `evidence` jsonb.

## Session-Start Pre-Flight

At the start of every onboarded session the machine MUST:

1. Pin bridge DNS (zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com).
2. Read `public.reality_ledger WHERE status=BLOCKED AND last_verified > now() - interval '14 days'` and surface open blocks before proceeding.
3. Load `MACHINE_REALITY_INDEX.yaml`.
4. Confirm HRE active.

## Cross-Layer Failure Modes

| Symptom | Root layer | Resolution |
|---------|------------|------------|
| Drift, passive waiting | L1 | HRE writeback + search-before-missing |
| Lost context, stateless behaviour | L2 | Bootstrap folder load |
| Hardcoded magic values | L3 | SKS resolution |
| False REAL, silent gaps | L4 | Reality Ledger entry + typed evidence |

## Operating Principle

The HRE prevents the machine from *behaving badly*. Onboarding doctrine prevents the machine from *claiming falsely*. Together they prevent the most common machine failure mode: convincing output without operational truth.
