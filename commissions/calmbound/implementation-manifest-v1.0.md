# CalmBound Implementation Manifest v1.0

**Date:** 2026-07-13  
**Owner:** Tech4Humanity  
**Status:** READY FOR EXECUTION

## Delivery doctrine

Every object requires an owner, evidence, dependency and lifecycle. Every critical action requires execution, receipt, ledger entry, telemetry, validation and recovery.

## Work packages

| ID | Work package | Primary output | Dependencies | Evidence gate | State |
|---|---|---|---|---|---|
| CB-001 | Capability registry | Versioned registry for initial 25 capabilities | Canonical specification | Schema validation and registry receipt | READY |
| CB-002 | Household ontology | JSON Schema and SQL model for core entities and edges | CB-001 | Round-trip schema tests | READY |
| CB-003 | Event envelope | Canonical event and correlation model | CB-002 | Emit, persist and read-back test | READY |
| CB-004 | Mode schema | Versioned household-mode definition | CB-002, CB-003 | Validation against Phase 1 modes | READY |
| CB-005 | Permission and consent | Contextual authority, expiry and revocation model | CB-002 | Deny, grant, expire and revoke tests | READY |
| CB-006 | Governance policies | Child rights, privacy, AI and partner constraints | CB-004, CB-005 | Policy enforcement tests | READY |
| CB-007 | API contract | OpenAPI contract for Phase 1 | CB-001–CB-006 | Contract lint and mock tests | READY |
| CB-008 | Runtime skeleton | State, rules, permission, event and evidence services | CB-003–CB-007 | Local execution receipt | QUEUED |
| CB-009 | Phase 1 wedge | Household creation, invitation, Kids Visit Mode, quiet hours, override | CB-008 | End-to-end acceptance receipt | QUEUED |
| CB-010 | Identity integration | Guardian, adult, child and carer roles | CB-005, CB-008 | Role isolation and recovery tests | QUEUED |
| CB-011 | Billing adapter | Stripe test-mode subscription entitlements | CB-007, CB-008 | Signed webhook and reconciliation receipt | QUEUED |
| CB-012 | Persistence adapter | Validated database, migrations, RLS and backups | CB-002, CB-008 | Migration, restore and RLS receipts | QUEUED |
| CB-013 | Guest portal | Accessible captive-portal projection | CB-009 | Device matrix and fallback receipts | QUEUED |
| CB-014 | Parent experience | Current mode, next transition, request and exception views | CB-009, CB-010 | Accessibility and usability tests | QUEUED |
| CB-015 | Observability | OpenTelemetry, ledger, metrics and alerting | CB-003, CB-008 | Trace and failure-readback receipt | QUEUED |
| CB-016 | Threat model | Household, child, partner, router and billing threats | CB-006–CB-013 | Review and mitigations ledger | READY |
| CB-017 | Deployment foundation | Environments, secrets, CI/CD, rollback and recovery | CB-008, CB-012, CB-015 | Deployment and rollback receipts | QUEUED |
| CB-018 | Household pilot | Controlled real-household validation | CB-009–CB-017 | Consent, usage and incident evidence | BLOCKED_BY_RUNTIME |

## Phase 1 acceptance gates

The wedge may be labelled REAL only when all are observed:

- Household can be created and read back.
- Authorised adult can invite another member.
- Kids Visit Mode can activate and expire.
- Guest agreement is displayed and acknowledged.
- Network enforcement result is observed rather than assumed.
- Quiet Hours can activate, override and recover.
- A child-readable explanation is available.
- Permissions deny unauthorised actions.
- Consent and permission expiry are enforced.
- Every consequential action emits a correlated event.
- Receipts are persisted and queryable.
- Failed actions enter retry, rollback or quarantine.
- Data export and deletion are testable.
- Stripe test-mode lifecycle reconciles from signed webhooks.
- Database backup and restore are proven.
- Security, privacy, accessibility and child-impact reviews are complete.

## Build-versus-reuse decision

### Build

- Household ontology and graph
- Household state and mode model
- Progressive-autonomy model
- Child-readable transparency
- Contextual permission model
- Evidence and receipt model
- Multi-home neutrality controls

### Reuse

- Identity provider
- Stripe
- Database platform
- Workflow orchestration
- Policy engine where suitable
- Event transport
- OpenTelemetry
- Messaging and calendar connectors
- Smart-home and router SDKs

## Prohibited shortcuts

- Browser-to-service-role database access
- Subscription truth from redirect pages
- Unverified router enforcement claims
- Permanent generic household consent
- Hidden child or household scoring
- Production claims based on local storage demos
- Hard-coded pricing, plans or policy inside pages
- Silent failure

## Ledger fields

Every work-package completion receipt must include:

- work package ID
- run ID
- commit or artefact hash
- environment
- executor
- start and end time
- inputs
- outputs
- tests
- telemetry reference
- failures
- recovery action
- state classification
- next dependency
