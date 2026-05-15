# Service Catalog Runtime + Memory Upgrade Model

Status: READY_FOR_REVIEW
Date: 2026-05-15
Owner: T4H Autonomous Execution Layer

## Why this exists

The environment is moving from ad hoc product work into service-catalog-driven products, offers, packs, fulfilment paths, and agent interactions.

That changes the operating model.

A service catalog item is not just copy, a web page, or a product description. It is an executable contract across:

- customer problem
- offer and price
- eligibility
- intake
- fulfilment
- agent actions
- dependencies
- evidence
- support
- audit
- telemetry
- renewal / expansion
- retirement

Any agent thinking, touching, building, or auditing must understand that it is interacting with catalog-governed operational objects, not loose ideas.

## Core upgrade

Move from:

```text
conversation memory → ad hoc action → document/update
```

To:

```text
intent → catalog object → environment touch map → execution plan → evidence → telemetry → service lifecycle
```

## Mandatory object model

Every product/service interaction must bind to this object model:

```yaml
service_catalog_item:
  catalog_id: string
  name: string
  brand: string
  business_group: string
  offer_type: product|service|pack|subscription|audit|assessment|implementation|managed_service|training|platform_capability
  lifecycle_stage: idea|draft|offer_ready|market_ready|active|paused|retired
  customer_segment: string[]
  problem_statement: string
  promised_outcome: string
  inclusions: string[]
  exclusions: string[]
  prerequisites: string[]
  intake_requirements: string[]
  fulfilment_steps: string[]
  delivery_owner: string
  agent_roles: string[]
  systems_touched: string[]
  data_touched: string[]
  authority_required: AUTO|LOG|GATED|BLOCKED
  risk_class: LOW|NORMAL|HIGH|CRITICAL
  evidence_required: string[]
  telemetry_required: string[]
  price_model: fixed|tiered|usage|retainer|quote|free|internal
  cost_drivers: string[]
  margin_notes: string|null
  support_model: self_service|guided|managed|enterprise
  sla: string|null
  audit_status: CURRENT|STALE|PARTIAL|CONTRADICTED|BLOCKED
  last_refreshed_at: timestamp
  instruction_sha: string
  evidence_ref: string|null
```

## Thinking / touching / building rule

Before any agent touches a product/service/catalog item, it must answer:

```yaml
pre_touch_check:
  what_object_am_i_touching: service_catalog_item|runtime|site|repo|database|customer_asset|audit_artifact|unknown
  is_it_catalog_bound: true|false
  current_lifecycle_stage: string|null
  authority_required: AUTO|LOG|GATED|BLOCKED
  evidence_required: string[]
  stale_memory_check: CURRENT|STALE|CONTRADICTED|BLOCKED
  mutation_allowed: true|false
```

If `what_object_am_i_touching = unknown`, no write is allowed until classified.

If `is_it_catalog_bound = true`, changes must update catalog metadata, not only the visible artifact.

## Service catalog scaling implications

As the environment scales, the system must support these layers:

### 1. Catalog registry

A canonical registry of all products, packs, services, subscriptions, audits, and managed service offers.

Must support:

- 30-business portfolio mapping
- brand/group ownership
- offer maturity
- customer segment
- dependencies
- price/margin notes
- fulfilment state
- runtime evidence

### 2. Fulfilment engine

Every catalog item requires a delivery path.

Minimum fulfilment model:

```yaml
fulfilment:
  intake
  qualification
  consent/authority
  data collection
  delivery workflow
  QA/evidence check
  customer handover
  support/renewal
```

### 3. Agent role binding

Agents should not act generically. They act as roles in the fulfilment chain.

Examples:

```yaml
agent_roles:
  - catalog_curator
  - offer_architect
  - intake_assessor
  - fulfilment_operator
  - evidence_collector
  - QA_reviewer
  - support_agent
  - renewal_agent
```

### 4. Touch map

Every service catalog action must declare touched systems.

Examples:

```yaml
systems_touched:
  - GitHub
  - Supabase
  - Vercel
  - AWS
  - Stripe
  - Google Drive
  - Command Centre
  - customer_site
  - audit_register
```

### 5. Evidence model

No service catalog item is REAL unless it has:

- catalog record
- offer description
- fulfilment steps
- authority model
- evidence requirements
- support model
- runtime/operational receipt if active

### 6. Memory upgrade

Memory must store the catalog object, not just the conversation.

Every future memory related to a product must attach:

```yaml
memory_binding:
  catalog_id
  brand
  service_name
  lifecycle_stage
  instruction_sha
  source_session
  created_at
  expires_at
  evidence_ref
```

Operational memory without a catalog binding is advisory only.

### 7. Audit upgrade

Audits must evaluate the service lifecycle, not just content completeness.

Audit dimensions:

```yaml
audit_dimensions:
  catalog_integrity
  offer_clarity
  fulfilment_readiness
  revenue_model
  authority_model
  evidence_model
  telemetry_model
  support_model
  compliance_risk
  stale_memory_risk
  customer_value
```

## Interaction pattern for future agents

Every service catalog conversation should follow this pattern:

```text
1. refresh instructions
2. identify catalog object
3. classify lifecycle stage
4. inspect current assets
5. map service dependencies
6. determine authority tier
7. build/update catalog metadata
8. build/update customer-facing artifact
9. build/update fulfilment plan
10. attach evidence and telemetry
11. record receipt
12. advance lifecycle stage or log blocker
```

## Service catalog lifecycle ladder

```yaml
lifecycle:
  IDEA:
    meaning: rough concept only
    mutation_allowed: true
    customer_sale_allowed: false
  DRAFT:
    meaning: offer described but fulfilment incomplete
    customer_sale_allowed: false
  OFFER_READY:
    meaning: offer, audience, inclusions, exclusions, intake, and price model defined
    customer_sale_allowed: limited
  MARKET_READY:
    meaning: public-facing page, catalogue record, fulfilment path, and evidence checklist complete
    customer_sale_allowed: true
  ACTIVE:
    meaning: live offer with intake, delivery, support, telemetry, and receipts
    customer_sale_allowed: true
  PAUSED:
    meaning: temporarily not sold/delivered
    customer_sale_allowed: false
  RETIRED:
    meaning: no longer offered; archived with evidence
    customer_sale_allowed: false
```

## Environment requirements as we scale

The environment needs these capabilities before scaling service catalogs heavily:

1. Canonical catalog table
2. Catalog ID naming convention
3. Service dependency graph
4. Fulfilment checklist engine
5. Evidence and receipt attachment model
6. Agent role registry
7. Authority/mutation gate per service
8. Price/cost/margin fields
9. Customer segment and offer mapping
10. Command Centre catalog dashboard
11. Stale-memory and stale-offer sweeper
12. Audit quarantine state for old products
13. Site/page/repo/service cross-reference map
14. Renewal/support lifecycle tracking
15. Retirement/rollback path

## Minimum viable catalog schema

```sql
CREATE TABLE IF NOT EXISTS service_catalog_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  catalog_id text UNIQUE NOT NULL,
  name text NOT NULL,
  brand text NOT NULL,
  business_group text,
  offer_type text NOT NULL,
  lifecycle_stage text NOT NULL DEFAULT 'DRAFT',
  customer_segment text[] DEFAULT '{}',
  problem_statement text,
  promised_outcome text,
  inclusions text[] DEFAULT '{}',
  exclusions text[] DEFAULT '{}',
  prerequisites text[] DEFAULT '{}',
  intake_requirements text[] DEFAULT '{}',
  fulfilment_steps text[] DEFAULT '{}',
  delivery_owner text,
  agent_roles text[] DEFAULT '{}',
  systems_touched text[] DEFAULT '{}',
  data_touched text[] DEFAULT '{}',
  authority_required text NOT NULL DEFAULT 'LOG',
  risk_class text NOT NULL DEFAULT 'NORMAL',
  evidence_required text[] DEFAULT '{}',
  telemetry_required text[] DEFAULT '{}',
  price_model text,
  cost_drivers text[] DEFAULT '{}',
  margin_notes text,
  support_model text,
  sla text,
  audit_status text NOT NULL DEFAULT 'PARTIAL',
  last_refreshed_at timestamptz,
  instruction_sha text,
  evidence_ref text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

## Non-negotiable rules

- A website page is not a service catalog item unless catalog metadata exists.
- A product name is not an offer unless inclusions, exclusions, intake, fulfilment, support, and evidence are defined.
- A service is not ACTIVE unless telemetry and support paths exist.
- Memory about a product is advisory unless bound to catalog ID and instruction SHA.
- Old catalog outputs must be quarantined until refreshed.
- Agents must not mutate unknown objects.
- Service catalog changes must update both customer-facing assets and operational metadata.

## Test path

Use three existing products first:

1. Outcome Ready / Reading Buddy
2. Augmented Humanity Coach service packs
3. WorkFamilyAI role/workforce products

For each:

```text
create catalog record
map current page/repo/site
define offer inclusions/exclusions
define fulfilment steps
define evidence requirements
classify lifecycle stage
identify stale assumptions
record next action
```

## Classification

```yaml
status: PARTIAL
result: service-catalog-aware runtime and memory upgrade specified
execution: committed to canonical repo
remaining_gap: schema not deployed, registry not populated, dashboard not wired
next_action: deploy catalog table and run first three product mappings
```
