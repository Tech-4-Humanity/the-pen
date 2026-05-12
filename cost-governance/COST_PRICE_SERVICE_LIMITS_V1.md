# Cost, Price and Service Limits Governance V1

Status: PARTIAL until bound to live Supabase, Drive, S3, laptop inventory, agent logs, and Reality Ledger receipts.

## Purpose

Create one repeatable cost and pricing spine for every resource touched by Tech 4 Humanity, WorkFamilyAI, Augmented Humanity Coach, Holo-ORG, Apex Predator Insurance, MediaOps, and future portfolio businesses.

The system must answer:

- What does this resource cost to create, run, change, store, delete, and recover?
- Which project, domain, cost centre, business, and journey stage owns it?
- What is the wholesale cost, retail price, margin, and service limit?
- Which agent, human, workflow, campaign, or customer action caused the cost?
- Is the cost claimable, capitalisable, billable, reusable IP, or dead drag?

## Constitutional rule

Nothing is free.

Every resource and every action must create or update a cost event.

A table, file, asset, agent, workflow, page, campaign, checkout, model run, storage object, repo change, Drive import, S3 upload, or deletion is not operationally real until it is attached to:

- business_id
- project_id
- domain_slug
- cost_centre_id
- resource_id
- journey_stage_id
- owner
- claim_category
- price_model_id, where sellable
- service_limit_id, where serviceable
- evidence_ref

## Operating sources

- Supabase: live operational tables, ledgers, indexes, state, dashboards.
- Google Drive: source and staging material only; not a working source of truth.
- S3: binary vault for images, videos, audio, PDFs, exports, backups, and large artifacts.
- Laptop: local capture/cache only; anything useful is ingested, hashed, deduped, and routed.
- GitHub: canonical repo for schemas, manifests, docs, prompts, policies, scripts, manifests, and reusable operating assets.

## Core registries

### 1. cost_centre_registry

Owns cost accountability.

Required columns:

- cost_centre_id
- name
- pillar
- business_id
- project_id
- domain_slug
- owner_type
- owner_id
- budget_status
- default_claim_category
- active
- created_at
- updated_at

Example cost centres:

- CC_API_001: Apex Predator Insurance
- CC_WFAI_001: WorkFamilyAI
- CC_AHC_001: Augmented Humanity Coach
- CC_HOLO_001: Holo-ORG
- CC_MEDIA_001: MediaOps
- CC_PLATFORM_001: Shared Platform Runtime

### 2. resource_registry

Every costable object.

Required columns:

- resource_id
- resource_type
- resource_name
- source_system
- source_ref
- s3_bucket
- s3_key
- repo_full_name
- repo_path
- supabase_schema
- supabase_table
- business_id
- project_id
- domain_slug
- cost_centre_id
- journey_stage_id
- owner_type
- owner_id
- data_class
- retention_class
- lifecycle_status
- sha256
- created_at
- updated_at
- retired_at

Resource types:

- supabase_table
- supabase_view
- supabase_function
- s3_object
- google_drive_file
- local_file
- github_repo
- github_file
- vercel_project
- domain
- agent
- workflow
- campaign
- landing_page
- stripe_product
- stripe_price
- youtube_asset
- social_asset
- outreach_sequence
- model_run
- prompt_template
- evidence_pack

### 3. cost_event_ledger

The canonical cost truth table.

Required columns:

- cost_event_id
- occurred_at
- event_type
- action
- resource_id
- parent_resource_id
- actor_type
- actor_id
- agent_id
- workflow_id
- campaign_id
- business_id
- project_id
- domain_slug
- cost_centre_id
- journey_stage_id
- quantity
- unit
- unit_cost
- direct_cost
- model_input_tokens
- model_output_tokens
- model_cost
- storage_gb_month
- storage_cost
- compute_seconds
- compute_cost
- labour_minutes
- labour_rate
- labour_cost
- tool_cost
- campaign_cost
- payment_fee
- total_cost
- wholesale_price
- retail_price
- gross_margin
- claimable_status
- claim_category
- capitalisation_flag
- reusable_ip_flag
- revenue_linked
- revenue_event_id
- evidence_ref
- reality_status
- created_at

Event types:

- create
- read
- update
- delete
- generate
- publish
- deploy
- ingest
- classify
- archive
- restore
- campaign_send
- lead_capture
- checkout
- refund
- support
- review
- model_run
- file_move
- file_dedupe
- schema_change
- table_create
- table_alter
- table_drop

### 4. journey_stage_registry

Costs by site or product journey.

Required stages:

1. idea
2. domain
3. brand
4. repo
5. database
6. content
7. assets
8. landing_page
9. forms
10. checkout
11. campaign
12. leads
13. delivery
14. support
15. reporting
16. optimisation
17. retirement

Each stage has:

- default_cost_types
- default_claim_category
- default_service_limits
- default_margin_floor
- default_reality_gate

### 5. agent_price_book

Every agent has cost, wholesale, retail, and service limits.

Required columns:

- agent_id
- agent_family
- agent_name
- role_code
- role_level
- work_package_id
- default_model
- input_cost_per_1k
- output_cost_per_1k
- tool_cost_per_run
- expected_runs_per_month
- direct_cost_per_run
- labour_equivalent_minutes
- labour_equivalent_rate
- labour_equivalent_cost
- wholesale_price_per_run
- retail_price_per_run
- monthly_wholesale_price
- monthly_retail_price
- margin_floor
- service_limit_id
- overage_price
- active

Supported scales:

- WorkFamilyAI 729 role-agent grid
- 1,000 agent grid
- 10,000 file/task/agent extension
- Holo-ORG capability graph
- Augmented Humanity Coach coaching and intervention graph

### 6. service_limit_registry

Defines what is included and where overage starts.

Required columns:

- service_limit_id
- plan_code
- service_name
- included_agent_runs
- included_model_tokens
- included_storage_gb
- included_uploads
- included_pages
- included_campaigns
- included_contacts
- included_reports
- included_support_minutes
- max_response_time_hours
- overage_model
- overage_unit
- overage_price
- hard_cap
- soft_cap
- active

Example plans:

- STARTER
- PROFESSIONAL
- BUSINESS
- ENTERPRISE
- GOVERNMENT
- INTERNAL_BUILD
- R_AND_D

### 7. price_model_registry

Defines how each work package is sold.

Required columns:

- price_model_id
- model_type
- billing_frequency
- cost_basis
- wholesale_markup_pct
- retail_markup_pct
- minimum_margin_pct
- setup_fee
- recurring_fee
- usage_fee_unit
- usage_fee_amount
- active

Model types:

- one_off
- subscription
- usage_based
- retainer
- outcome_based
- grant_funded
- internal_capitalised
- free_public_good

## Default pricing formula

total_cost = direct_cost + model_cost + storage_cost + compute_cost + labour_cost + tool_cost + campaign_cost + payment_fee

wholesale_price = max(total_cost * 1.35, total_cost + minimum_wholesale_margin)

retail_price = max(wholesale_price * 1.75, total_cost * 2.5, minimum_retail_price)

service_overage_price = retail_unit_price * overage_multiplier

All values are defaults and can be tuned by business, market, customer tier, and stage.

## Startup and claimable cost base

Classify every cost into one of:

- R_AND_D
- software_development
- infrastructure
- marketing
- content_production
- compliance
- sales_enablement
- customer_delivery
- training
- support
- operations
- administration
- non_claimable
- unknown_pending_review

Claimable status values:

- claimable_candidate
- partially_claimable_candidate
- non_claimable
- unknown_pending_adviser

No tax or legal classification is final until reviewed by a qualified adviser.

## Enforcement gates

A Supabase table cannot move from scratch to operational unless it has:

- resource_registry row
- cost_centre_id
- business_id or shared_platform binding
- domain_slug
- journey_stage_id
- owner
- data_class
- retention_class
- cost_tracking_enabled
- evidence_ref

A file cannot move from Drive or laptop into use unless it has:

- sha256
- resource_registry row
- S3 vault pointer for binary files
- project/business/cost centre binding
- lifecycle status

An agent cannot run production work unless it has:

- agent_price_book row
- service_limit binding
- model cost basis
- wholesale price
- retail price
- overage rule
- cost_event_ledger logging

## Initial businesses to bind

- Apex Predator Insurance
- WorkFamilyAI
- Augmented Humanity Coach
- Holo-ORG
- MediaOps
- Tech 4 Humanity shared platform

## Required execution pack

1. Inspect Supabase tables and classify existing resources.
2. Inspect Google Drive folders and hash candidate assets.
3. Inspect S3 buckets/prefixes and reconcile binaries.
4. Inspect laptop nominated roots and hash local assets.
5. Generate resource_registry seed data.
6. Generate cost_centre_registry seed data.
7. Generate journey_stage_registry seed data.
8. Generate agent_price_book defaults for 729, 1000, and 10000 scales.
9. Generate service_limit_registry defaults.
10. Generate cost_event_ledger schema and triggers.
11. Generate dashboards for cost by business, stage, agent, asset, campaign, claimability, and margin.
12. Bind all future Bridge jobs to cost_event_ledger.

## Reality classification

Current status: PARTIAL.

Evidence attached:

- GitHub canonical governance asset path: cost-governance/COST_PRICE_SERVICE_LIMITS_V1.md

Gaps:

- Live Supabase not inspected in this action.
- Google Drive not inspected in this action.
- S3 not inspected in this action.
- Laptop not inspected in this action.
- Existing agent/task files not yet attached or parsed.
- No runtime cost events written yet.

Next action:

- Attach or route the 729/1000/10000 files.
- Run inventory over Supabase, Drive, S3, and laptop.
- Generate SQL DDL and seed data.
- Push bridge execution payload.
- Upgrade to REAL only after receipts, table creation, and inventory evidence exist.
