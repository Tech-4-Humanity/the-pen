# CalmBound Validation and Acceptance Specification v1.0

**Status:** Canonical implementation artefact  
**Scope:** Phase 1 schemas and contracts  
**Runtime status:** Not executed by this publication

## 1. Validation gates

### Capability registry

- Every capability has a stable ID.
- Every capability names actors, inputs, outputs, permissions, events, telemetry, dependencies and acceptance criteria.
- Every external action has recovery behaviour.
- No capability may claim completion from a requested event alone.

### Household ontology

- Every entity carries owner, source, status, version, lifecycle and deletion metadata.
- Authority-bearing objects carry scope and effective period.
- Edge endpoints use registered entity types.
- Contested authority freezes access.

### Event envelope

- `event_id` is globally unique and idempotent.
- `occurred_at` and `recorded_at` are RFC3339 timestamps.
- `correlation_id` is present for every event.
- Consequential events include evidence references.
- External actions emit separate request and result events.
- `unknown` and `partial` are not accepted as success.

### Permission and consent model

- Default decision is deny.
- Grantor authority is checked before delegation.
- Guest, carer, partner and emergency permissions carry expiry.
- Consent includes purpose, scope, policy version, jurisdiction and revocation.
- Expiry and revocation emit receipts.

### Rule engine and mode registry

- Priority order is deterministic.
- Lower-priority rules cannot override higher-priority safety or legal constraints.
- Overrides are visible, scoped and time-bound.
- Child-readable explanations show purpose, start, end and request path.
- Every mode defines degraded or recovery behaviour.

### OpenAPI contract

- The document parses as OpenAPI 3.1.
- Every mutating endpoint requires authenticated authority.
- Error responses distinguish denial, conflict, validation and runtime failure.
- Event ingestion is idempotent.
- No production URL is claimed until a deployed endpoint is receipted.

### Database schema

- SQL parses on a supported PostgreSQL version.
- Foreign keys and check constraints succeed.
- RLS is enabled for sensitive tables.
- No permissive browser policy exists by default.
- Event IDs are unique.
- Provider subscription identifiers are unique.
- Migration execution, rollback and restore are separately receipted before REAL classification.

## 2. Phase 1 acceptance scenarios

1. Create a household and assign one owner.
2. Invite a second adult with bounded authority and expiry where applicable.
3. Activate Kids Visit Mode and render a child-readable guest agreement.
4. Request a network policy and record its actual result separately.
5. Schedule Quiet Hours in `Australia/Sydney` and prove correct timezone handling.
6. Request, approve and automatically expire a temporary override.
7. Grant and revoke purpose-bound consent.
8. Automatically expire a carer permission and verify readback.
9. Process the same event twice without duplicating side effects.
10. Simulate a failed router or device action and confirm no false success is displayed.
11. Freeze access when authority becomes contested.
12. Export and delete a subject's data with completion receipts.

## 3. Evidence required for REAL runtime status

- Migration execution logs
- Database schema readback
- RLS policy tests
- API contract validation output
- Unit and integration test results
- Event ledger records
- OpenTelemetry traces
- Failure and retry evidence
- Permission expiry evidence
- Deletion verification
- Deployment commit and immutable artefact digest
- Production smoke tests
- Security, privacy, accessibility and child-impact review outputs

## 4. Current classification

The files in this package are REAL as published implementation definitions. They remain PARTIAL as runtime implementation until execution, telemetry, validation and recovery evidence exist.
