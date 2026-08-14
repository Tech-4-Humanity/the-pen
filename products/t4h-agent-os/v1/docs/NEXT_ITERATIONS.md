# Next iterations

## V1.1 — Engagement and economics

- signed HTTP job-ingress API
- event, schedule and webhook triggers
- per-job token, tool, infrastructure and retry cost ledger
- provider profiles and fallback routing
- tenant, budget and authority policies
- dead-letter queue, cancellation and replay

## V1.2 — Workforce operations

- Command Centre queue and worker telemetry
- playbook execution rather than documentation-only definitions
- arena execution with isolated candidates, scoring and dissent retention
- persistent context references with freshness and provenance
- EC2 worker deployment and health supervision

## V1.3 — Productisation

- customer-facing API and SDK
- packaged workforce overlays such as AI4Tradies
- metering, quotas and commercial plans
- organisation-specific catalogues and private agents
- audit export and compliance evidence packs

## Needs before production

1. Select the canonical production ledger and secret store.
2. Define model-provider credentials and permitted fallback order.
3. Deploy a persistent worker outside the Mac.
4. Add signed ingress, tenancy and rate limits.
5. Prove cancellation, timeout, retry, replay and recovery.
6. Connect telemetry and cost data to Command Centre.
7. Run one genuine external business workflow end to end.
