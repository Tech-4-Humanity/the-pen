# CalmBound Reference Runtime

This package is the first executable implementation tranche derived from the published CalmBound contracts.

## Included

- Fastify HTTP service
- PostgreSQL transaction adapter
- Household creation with event receipt
- Mode activation with contextual authority check
- Idempotent event-ledger ingestion with payload-drift detection
- Checksum-protected migration runner
- Node contract tests
- Telemetry specification
- Phase 1 threat model

## Required environment

```text
DATABASE_URL=postgresql://...
PORT=3000
HOST=0.0.0.0
DB_POOL_MAX=10
```

## Local validation

```bash
npm install
npm run check
npm test
npm run migrate
npm start
```

The migration command emits a JSON result with `APPLIED`, `SKIPPED`, or `FAILED`. Migration checksum drift fails closed.

## Current supported routes

- `GET /health`
- `POST /v1/households`
- `POST /v1/households/{householdId}/modes`
- `POST /v1/events`

The service uses `x-person-id` only as a reference identity boundary. Production must replace it with verified JWT identity and claims before deployment.

## Truth status

The code and contracts are published. They have not been installed, dependency-resolved, executed against PostgreSQL, deployed, penetration-tested, or observed through telemetry in this publication session.

Therefore:

- Source publication: REAL
- Runtime execution: PARTIAL
- Production readiness: BLOCKED pending validation and release gates

## Next execution gate

1. Install dependencies in an isolated runner.
2. Run syntax and contract tests.
3. Start disposable PostgreSQL.
4. Apply migration twice to prove idempotency.
5. Run API smoke tests.
6. Capture structured logs and traces.
7. Test rollback and event drift detection.
8. Store receipts and classify results.
