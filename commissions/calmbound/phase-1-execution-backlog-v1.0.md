# CalmBound Phase 1 Execution Backlog v1.0

**Date:** 2026-07-13  
**Objective:** Deliver a receipted, observable Phase 1 wedge without inheriting prototype architecture.

## Epic A — Canonical contracts

### CB-A01 Capability registry schema

**Output:** JSON Schema and seed records for the initial 25 capabilities.  
**Done when:** registry validates, versions, deprecates and resolves dependencies.  
**Receipt:** schema hash, seed count, validation output.

### CB-A02 Household ontology schemas

**Output:** schemas for Household, Person, Role, Relationship, Space, Network, Device, Mode, Agreement, Rule, Permission, Consent, Event and Evidence.  
**Done when:** valid and invalid fixtures pass expected tests.  
**Receipt:** entity count, fixture results, schema hashes.

### CB-A03 Canonical event envelope

**Required fields:** event ID, event type, version, source, actor, subject, object, action, outcome, occurred time, recorded time, correlation ID, causation ID, policy version, evidence reference and privacy class.  
**Done when:** emit, persist and read-back are proven.  
**Receipt:** correlated sample trace.

### CB-A04 Mode definition schema

**Output:** versioned schema plus Kids Visit Mode, Quiet Hours and one configurable household mode.  
**Done when:** triggers, rules, explanations, overrides, expiry, signals, evidence and recovery validate.  
**Receipt:** three validated mode records.

### CB-A05 Permission and consent schemas

**Output:** grant, deny, delegate, expire, revoke and contest models.  
**Done when:** default deny is enforced and expiry cannot silently fail.  
**Receipt:** authority matrix test results.

## Epic B — Governance and safety

### CB-B01 Product policy pack

Policies:

- child transparency
- progressive autonomy
- privacy and minimisation
- AI constraints
- partner access
- data retention
- incident handling
- disputed authority

**Done when:** policies are versioned and executable controls are mapped.

### CB-B02 Threat model

Threat domains:

- unauthorised guardian or adult
- child bypass and unsafe enforcement
- abusive household control
- visitor identification
- captive-portal spoofing
- router compromise
- webhook replay
- database service-key exposure
- partner overreach
- multi-home misuse
- AI inference and manipulation

**Done when:** every high threat has mitigation, owner, test and residual risk.

### CB-B03 Data classification and retention

**Done when:** every entity and event has a privacy class, retention rule, deletion route and access owner.

## Epic C — Runtime foundation

### CB-C01 Runtime service skeleton

Services:

- household state
- rules
- permissions
- scheduling
- events
- evidence
- consent
- recovery

**Done when:** a mode activation traverses all services and emits one correlated trace.

### CB-C02 Persistence adapter

**Requirements:** migrations, environment separation, least privilege, RLS or equivalent, backup, restore, deletion and audit.  
**Done when:** clean deploy and restore both succeed.

### CB-C03 Identity adapter

Roles:

- account owner
- guardian
- authorised adult
- child
- teenager
- carer
- guest
- partner service

**Done when:** cross-role isolation tests pass.

### CB-C04 Observability and ledger

**Requirements:** OpenTelemetry, structured logs, metrics, traces, immutable evidence references, alerting and run IDs.  
**Done when:** a success and deliberate failure can be reconstructed end to end.

## Epic D — Phase 1 product wedge

### CB-D01 Household creation

Create and read back a household with timezone, lifecycle and owner evidence.

### CB-D02 Household invitation

Invite and accept a second authorised adult without granting unrestricted authority.

### CB-D03 Kids Visit Mode

Activate, display guest terms, acknowledge, apply configured network policy, observe outcome and expire.

### CB-D04 Quiet Hours

Schedule, activate, explain, override, expire and recover.

### CB-D05 Child-readable rule view

Show active rule, reason, duration, allowed actions, request path and data visibility.

### CB-D06 Temporary override

Require authority, reason, duration, evidence and automatic expiry.

### CB-D07 Guest portal projection

Accessible portal with no unsupported claim that acknowledgement itself enforces filtering.

## Epic E — Commercial and deployment adapters

### CB-E01 Stripe test-mode adapter

**Requirements:** hosted Checkout, signed raw-body webhook, idempotency, complete lifecycle handling, entitlement reconciliation and failure queue.  
**Done when:** create, activate, payment failure, recovery, cancellation, downgrade and replay tests pass.

### CB-E02 Deployment pipeline

**Requirements:** dev, test and production separation; secret management; CI checks; deployment; smoke test; rollback; receipt.  
**Done when:** deploy and rollback are both observed.

### CB-E03 Pilot readiness gate

Requires:

- threat model approved
- privacy and child-impact reviews
- accessibility pass
- incident route
- support route
- export and deletion tests
- consent materials
- telemetry dashboard

## Priority order

1. CB-A01–CB-A05
2. CB-B01–CB-B03
3. CB-C01–CB-C04
4. CB-D01–CB-D07
5. CB-E01–CB-E03

## Definition of REAL

A backlog item is REAL only when:

- implementation exists
- tests execute
- receipt is persisted
- ledger entry exists
- telemetry is observed
- read-back validates the claimed state
- failure has a tested recovery path
- dependencies are updated

Code committed without runtime observation is PARTIAL.
