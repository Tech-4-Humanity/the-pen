# Infra Autopilot Grid — Wave 20 Runtime Governance Handoff

Created: 2026-04-30
Owner system: Tech 4 Humanity / MCP Command Centre / PEN
Target repo role: canonical execution handoff for bridge workers
Reality status: PARTIAL until deployed, scanned, smoke-tested, and ledger-bound in runtime.

## Mission
Turn Lambda runtime migration into a self-healing infrastructure governance grid. This is not a one-off Node runtime migration. It is a continuous control system that discovers assets, maps dependencies, enforces runtime policy, validates live behaviour, rolls back unsafe changes, writes evidence, and produces monetisable optimisation reports.

## Wave 20 scope

1. Runtime governance for AWS Lambda
2. Dependency graph mapping across Lambda, IAM roles, layers, API Gateway, EventBridge, SQS, SNS, S3 and environment variables
3. IAM drift detection and correction queue
4. Cost and utilisation intelligence
5. CVE and package vulnerability registry
6. Policy decision engine with canary and rollback enforcement
7. Reality Ledger evidence binding
8. Command Centre metric contract
9. Bridge-ready invocation envelopes
10. Commercial product wrapper: Infra Autopilot Grid

## Included assets

- `sql/001_wave20_schema.sql` — Supabase schema, indexes, rules, views, seed policies
- `src/wave20-runtime-governor.mjs` — Lambda handler pack: scanner, graph builder, decision engine, migrator, validator, rollback, ledger writer
- `infra/sam-template.yaml` — deployable AWS SAM skeleton for the governor functions
- `infra/step-function.asl.json` — orchestration definition: discover → graph → decide → execute → validate → ledger → report
- `bridge/execute-wave20.json` — MCP bridge invocation envelope
- `docs/RUNBOOK.md` — deployment, operation, recovery and proof gates
- `docs/BOARD-NOTE.md` — board/investor-ready summary and monetisation frame
- `MANIFEST.json` — package manifest and receipt checklist

## Execution order

1. Apply Supabase schema.
2. Deploy SAM stack with environment variables.
3. Run scanner in dry-run mode.
4. Populate asset graph.
5. Run decision engine in audit mode.
6. Enable canary migration for low-risk functions.
7. Validate behaviour.
8. Promote or rollback.
9. Bind all executions to Reality Ledger.
10. Publish Command Centre widget metrics.

## Proof gates

The system is not REAL until all gates pass:

- G1: Every Lambda discovered through pagination across configured accounts and regions.
- G2: Every discovered Lambda written once to canonical inventory using idempotent upsert.
- G3: Each migration has old runtime, new runtime, old version, new version, alias state and rollback target.
- G4: Smoke and live comparison test pass before promotion.
- G5: Rollback path is tested against at least one non-critical function.
- G6: Reality Ledger has execution evidence for scan, decision, migration, validation and rollback test.
- G7: Command Centre view shows risk, drift, migration, failure and ROI metrics.

## No gaps left deliberately open

Known hard blockers only:

- Runtime deployment needs AWS/Supabase secrets in the execution environment.
- Live bridge execution receipt can only be produced by the bridge runtime after invoking the supplied payload.
- Destructive auto-fix remains policy-gated by enforcement mode and safety thresholds.

## Bridge handoff

Use `bridge/execute-wave20.json` to enqueue execution through MCP Bridge. The preferred worker should write back a runtime receipt into this folder or the Command Centre receipt ledger.
