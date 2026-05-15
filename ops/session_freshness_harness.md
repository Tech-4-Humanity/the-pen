# Session Freshness + Audit Quarantine Harness

Status: READY_FOR_TEST
Date: 2026-05-15

## Purpose

This harness lets operators test the stale-memory containment model before wiring it into every agent/runtime.

It validates:

- daily instruction refresh gate
- stale memory lockout
- contradiction handling
- audit quarantine classification
- private GitHub search fallback behaviour
- mutation lock when instruction freshness is unknown

## Canonical Inputs

Known-path sources, not code search:

```yaml
canonical_sources:
  - TML-4PM/the-pen/GLOBAL_RULE.md
  - TML-4PM/the-pen/MCP_EXECUTION_CONTRACT.md
  - TML-4PM/the-pen/ENFORCEMENT_LIVE.md
```

Code search is optional and non-authoritative. Empty search results are not proof that a file or instruction does not exist.

## Required Session Record

```yaml
session_record:
  session_id: string
  agent_id: string
  created_at: timestamp
  last_refresh_at: timestamp|null
  instruction_sha: string|null
  memory_age_seconds: integer|null
  freshness_state: CURRENT|STALE|CONTRADICTED|BLOCKED
  mutation_allowed: boolean
  contradiction_count: integer
  blocked_reason: string|null
  evidence_ref: string|null
```

## Decision Function

```pseudo
function classify_session(now, session, canonical_fetch_result, attempted_mutation):
  if canonical_fetch_result.status == BLOCKED:
    return BLOCKED with mutation_allowed=false unless fallback receipt exists

  instruction_age = now - canonical_fetch_result.fetched_at
  memory_age = now - session.last_refresh_at

  if memory_age > 24h and attempted_mutation:
    return STALE with mutation_allowed=false

  if session.memory_claim conflicts with canonical_fetch_result.live_claim:
    return CONTRADICTED with mutation_allowed=false for contradicted topic

  if instruction_age <= 24h:
    return CURRENT with mutation_allowed=true

  return STALE with mutation_allowed=false
```

## Test Cases

### T1 — Fresh session may mutate

Input:

```yaml
last_refresh_at: now - 2h
instruction_sha: latest
attempted_mutation: true
canonical_fetch: OK
contradiction: false
```

Expected:

```yaml
freshness_state: CURRENT
mutation_allowed: true
```

### T2 — 20-day-old operational memory is locked

Input:

```yaml
last_refresh_at: now - 20d
instruction_sha: old
attempted_mutation: true
canonical_fetch: OK
contradiction: false
```

Expected:

```yaml
freshness_state: STALE
mutation_allowed: false
required_action: refresh instructions before mutation
```

### T3 — Stale DOWN contradicted by live UP

Input:

```yaml
memory_claim: T4H Remote MCP Clean = CRITICAL_DOWN
memory_claim_checked_at: 2026-04-25
live_claim: T4H Remote MCP Clean = UP
attempted_mutation: false
canonical_fetch: OK
```

Expected:

```yaml
freshness_state: CONTRADICTED
mutation_allowed: false for stale topic
required_action:
  - update stale register row
  - attach probe evidence
  - create stale-truth incident
```

### T4 — Private GitHub search unavailable

Input:

```yaml
code_search_indexed: false
search_results: []
known_path_fetch: OK
```

Expected:

```yaml
freshness_state: CURRENT
mutation_allowed: true if known-path SHA is current
note: empty search result ignored as non-authoritative
```

### T5 — Canonical fetch blocked

Input:

```yaml
canonical_fetch: BLOCKED
fallback_attempted: true
fallback_receipt: null
attempted_mutation: true
```

Expected:

```yaml
freshness_state: BLOCKED
mutation_allowed: false
required_action: create refresh-debt item
```

### T6 — Old audit output quarantine

Input:

```yaml
audit_output_age: 30d
source_timestamp: missing
runtime_receipt: missing
instruction_sha: missing
```

Expected:

```yaml
audit_classification: PARTIAL
freshness_state: STALE
reuse_allowed: false for live operational decisions
```

## Manual Test Procedure

1. Fetch `GLOBAL_RULE.md` by known path.
2. Record returned commit SHA.
3. Create or select a session record.
4. Set `last_refresh_at` to each scenario above.
5. Run the decision function.
6. Confirm mutation lock behaviour.
7. Confirm contradiction produces quarantine/incident action.
8. Confirm old audit outputs are marked PARTIAL unless source timestamps and receipts exist.

## Pass Criteria

```yaml
pass:
  - stale sessions cannot mutate
  - canonical known-path fetch outranks code search
  - contradictions disable stale memory for the affected topic
  - 20-day-old operational memory is rejected
  - audit outputs without instruction SHA / source timestamp / runtime receipt are PARTIAL
  - blocked canonical refresh creates refresh debt instead of pretending success
```

## Current Limits

This harness is ready for validation but is not yet the production daemon.

Still required for full enforcement:

- central session registry
- scheduled daily sweeper
- Bridge/Supabase receipt writer
- Command Centre freshness overlays
- contradiction scanner against runtime probes
- conversation export/archive scanner

## Classification

```yaml
status: PARTIAL
result: READY_FOR_TEST harness committed
reason: governance and test harness exist; production daemon not yet wired
```
