# Canonical Enterprise Event Model (CEEM) v1.0

Status: ACTIVE / IMPLEMENTATION-READY
Owner: Portfolio Control / Runtime Kernel
Canonical repository: `TML-4PM/the-pen`
Created: 2026-07-14

## Purpose

CEEM is the master event model for every customer, prospect, partner, supplier, employee, regulator, system and AI-agent interaction. It replaces disconnected email sequences, CRM automations and workflow definitions with one canonical business-event graph.

An event is modelled once and may drive CRM updates, workflows, tasks, communications, documents, billing, compliance, support, AI actions, evidence, receipts, ledgers, telemetry and analytics.

## Canonical execution chain

`intent -> validate -> authorise -> event -> rules -> actions -> outputs -> observe -> verify -> receipt -> ledger -> classify -> learn`

## Core object model

CEEM is a table-of-tables, not one flat registry.

1. `ceem_event` - canonical event definitions.
2. `ceem_event_rule` - eligibility, branching and decision logic.
3. `ceem_event_action` - system, human and AI actions.
4. `ceem_event_output` - communications, documents and notifications.
5. `ceem_event_edge` - predecessor, successor, exception, retry and recovery paths.
6. `ceem_workflow` - orchestration definitions.
7. `ceem_template` - channel templates and variants.
8. `ceem_evidence_policy` - proof, receipt, ledger and retention requirements.
9. `ceem_metric` - success, SLA, value and risk measures.
10. `ceem_integration_binding` - CRM, ERP, finance, identity, support, marketing and infrastructure mappings.
11. `ceem_agent_binding` - AI-agent authority, tools, guardrails and confidence thresholds.
12. `ceem_runtime_event` - immutable event occurrences.

## Universal required metadata

Every canonical event must have:

- `event_id`
- `event_key`
- `canonical_name`
- `description`
- `event_family`
- `domain`
- `lifecycle_stage`
- `status`
- `version`
- `business_owner`
- `operational_owner`
- `trigger_type`
- `source_system`
- `primary_actor_type`
- `primary_audience_type`
- `required_action_summary`
- `default_next_event_key`
- `exception_event_key`
- `evidence_required`
- `receipt_required`
- `success_metric_key`
- `sla_seconds`
- `security_classification`
- `effective_at`
- `review_at`

An event missing any required field is `DRAFT` or `PARTIAL`; it cannot be promoted to `ACTIVE/REAL`.

## Conditional metadata rules

- Billing events require invoice/payment/subscription fields and finance-system binding.
- Compliance events require policy, regulatory basis, evidence type, retention and audit fields.
- Communication outputs require template, audience, channel, consent, accessibility and delivery policy.
- AI actions require agent, authority, tool scope, knowledge sources, confidence threshold, guardrails and escalation.
- Technical events require schema, idempotency, correlation, trace, retry, timeout and recovery policy.
- Destructive events require explicit authority and recovery/rollback controls.

## Lifecycle families

The initial customer-facing projection contains stages 0-18:

0. Lead Capture
1. Awareness
2. Qualification
3. Solution Design
4. Proposal
5. Commercial
6. Customer Setup
7. Onboarding
8. Implementation
9. Operations
10. Billing
11. Customer Success
12. Marketing Automation
13. Compliance
14. Support
15. Expansion
16. Renewal
17. Offboarding
18. Advocacy

These are views over the event graph, not hard-coded linear steps.

## Truth and promotion model

Supported states: `ASPIRATIONAL`, `DRAFT`, `PARTIAL`, `REAL`, `DEGRADED`, `BLOCKED`, `QUARANTINED`, `DEPRECATED`, `ARCHIVED`.

No runtime occurrence is REAL unless it has:

- canonical event identity and version;
- actor and authority identity;
- source timestamp and correlation/idempotency keys;
- observed action/output telemetry;
- verification result;
- receipt reference;
- ledger reference or documented exemption;
- recovery status for failures.

## Event-key convention

Use lower-case dot notation:

`<domain>.<object>.<past-tense-event>`

Examples:

- `sales.lead.captured`
- `sales.discovery.completed`
- `commercial.proposal.sent`
- `commercial.proposal.accepted`
- `billing.invoice.issued`
- `billing.payment.failed`
- `customer.onboarding.completed`
- `support.ticket.escalated`
- `compliance.consent.renewed`
- `customer.subscription.cancelled`

## Repository assets

- `schema/ceem.schema.json` - canonical JSON Schema.
- `sql/001_ceem_core.sql` - reference PostgreSQL schema.
- `types/ceem.ts` - TypeScript runtime contracts.
- `seed/customer-lifecycle-events.csv` - initial event catalogue seed.
- `IMPLEMENTATION.md` - integration, validation and rollout requirements.
- `receipts/2026-07-14-ceem-v1-publication.json` - publication receipt.

## Existing-source reconciliation

This specification consolidates rather than replaces prior work:

- Drive: `Canonical_Operating_Registry_v6_structural_reconciled_complete.xlsx`.
- Drive: `T4H_Enterprise_Metadata_Repository_v9_UPDATED.xlsx`.
- Drive: `OIKOS_Canonical_Knowledge_System_MASTER_v1.xlsx`.
- Pen: `PORTFOLIO_CANONICAL_REGISTRY_BINDING.md`.
- Pen: `GLOBAL_RULE.md` and `global/GLOBAL_RULE_KERNEL_V7.yaml`.

Drive remains the human control view. GitHub owns executable definitions and versioning. Runtime systems own occurrence truth. Receipts and ledger records own proof.
