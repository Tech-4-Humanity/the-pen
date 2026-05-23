# Ecosystem Explorer Master Pack v1.0

Status: PARTIAL until Bridge execution receipts and live Supabase inventory bind back into the Reality Ledger.

Purpose: Ecosystem Explorer is a business-intelligence harvest and ordering system for a post-acquisition style conglomerate estate. It is not an IT cleanup exercise. It does not classify old systems as dead because they have low usage. It recovers business IP, campaign intelligence, product DNA, provenance, and future opportunity from Supabase, GitHub, Vercel, GDrive, and S3.

Primary instruction: No delete. No kill. No archive as default. Harvest first. Understand first. Enhance first. Technology wrappers may later go in the bin, but the intelligence must be extracted before any platform disposal decision.

## Operating thesis

You have acquired a conglomerate of businesses. The old implementation estate contains roughly 200 GitHub repos, roughly 200 Vercel sites, one or two Supabase estates, GDrive material, and S3 assets. The estate is messy because it is a history of product creation, pre-sale campaigns, research, offers, prototypes, brand evolution, customer journeys, forms, prompts, content, and business experiments.

An IT-only assessment would call much of this unused. Ecosystem Explorer rejects that framing. Low activity does not mean low business value. Many assets are pre-sale, warmed-up, dormant IP, duplicated opportunity signals, or historical product DNA.

## Core outcomes

1. Produce a complete estate inventory.
2. Recover business intelligence from every source.
3. Reverse-map provenance from table/repo/site/document/bucket back to brand, product, campaign, research source, and business family.
4. Identify product DNA and reusable opportunity patterns.
5. Prepare Command Centre views that allow Troy to see the conglomerate as a portfolio, not as isolated apps.
6. Create enhancement queues for campaigns, sales, research, and rebuild pathways.
7. Preserve harvested intelligence even if disposable website/application shells are later replaced.

## Master taxonomy

Every discovered item gets an asset record.

### 1. Asset Identity

- asset_id
- asset_type: supabase_project, schema, table, column, row_sample, function, policy, storage_bucket, edge_function, repo, file, vercel_site, domain, gdrive_doc, s3_object, prompt, form, offer, campaign, product, brand, business
- source_system: Supabase, GitHub, Vercel, GDrive, S3, Lovable, manual
- source_location
- discovered_at
- first_seen_at
- last_seen_at
- owner_status: known, inferred, unknown
- confidence
- evidence_uri
- evidence_hash

### 2. Business Origin

- business_family: HoloOrg, WorkFamilyAI, Augmented Humanity Coach, Outcome Ready, Tech4Humanity, GC-BAT, NEUROPAK, RATPAK, AI Sweet Spots, Doolittles, Synal, Predator/Apex, Enter Australia, Reading Buddy, Research, Unknown
- sub_brand
- initiative
- product
- campaign
- market
- geography
- target_customer
- buyer
- operator
- beneficiary
- business_stage: idea, research, prototype, pre_sale, warmed_up, launched, dormant_ip, scale_candidate

### 3. Provenance Graph

- originating_repo
- originating_site
- originating_domain
- originating_form
- originating_prompt
- originating_document
- originating_research
- originating_storage_path
- imported_from
- related_assets
- inferred_from
- provenance_confidence

### 4. Customer and Market Intelligence

- persona
- problem
- pain_point
- job_to_be_done
- trigger_event
- offer_language
- value_proposition
- pricing_signal
- compliance_signal
- consent_signal
- evidence_signal
- channel_signal

### 5. Product DNA

- core_offer
- workflow
- feature
- capability
- reusable_component
- data_object
- orchestration_pattern
- evidence_pattern
- signal_pattern
- consent_pattern
- revenue_path
- delivery_model

### 6. Funnel Position

Use the canonical 12-stage funnel:

1. Problem Trigger
2. Audience
3. Entry Surface
4. Capture
5. Consent
6. Qualification
7. Offer
8. Conversion
9. Provisioning
10. First Value
11. Evidence
12. Continuation

Fields:

- funnel_stage
- funnel_object
- next_stage
- conversion_path
- missing_stage
- campaign_readiness

### 7. Intelligence Value

Scores 0-100:

- strategic_score
- reuse_score
- monetisation_score
- evidence_score
- novelty_score
- ecosystem_score
- campaign_score
- research_score
- risk_score
- urgency_score

### 8. Relationship Layer

Relationships must support graph traversal:

- asset -> repo
- repo -> site
- site -> domain
- site -> table
- table -> form
- form -> campaign
- campaign -> product
- product -> brand
- brand -> business_family
- document -> product
- S3 object -> campaign/product/evidence
- prompt -> workflow/product

### 9. Action Layer

Allowed actions:

- harvest
- classify
- enrich
- connect
- deduplicate_intelligence
- promote
- campaign_enable
- rebuild_clean
- expose_in_command_centre
- validate_provenance
- research_followup
- risk_review

Disallowed default actions:

- delete
- kill
- archive
- purge
- drop_table
- remove_repo
- remove_site

Any destructive action requires separate explicit approval and evidence that harvested intelligence has been preserved.

## Reporting model for Command Centre

### Executive Portfolio View

Shows businesses, products, campaign readiness, data concentration, revenue pathways, and strongest opportunities.

### Conglomerate Map

Business -> Brand -> Product -> Campaign -> Site -> Repo -> Supabase Table -> Evidence/Data.

### Supabase Intelligence View

Project, schema, table, column, row count, relationships, policies, functions, storage, inferred business, inferred provenance, value scores, recommended enhancements.

### Product DNA Report

Extracts recurring patterns across the estate, including consent engines, signal engines, AI coaching, role frameworks, evidence systems, BCI, workforce mapping, policy readiness, and business operating models.

### Opportunity Radar

Ranks reusable and monetisable opportunities. It asks: What appears repeatedly? Which offer language is strongest? Which forms imply demand? Which assets can power campaigns now?

### Provenance Time Machine

Shows evolution over time, for example HoloOrg -> WorkFamilyAI -> Outcome Ready -> current product variants.

### Ecosystem Heatmap

Rows: business families. Columns: customer, product, campaign, research, funnel, Supabase data, GitHub repos, Vercel sites, GDrive docs, S3 objects, evidence, revenue path.

### Enhancement Queue

Non-destructive queue for enrichment, connection, campaign enablement, product rebuilds, and Command Centre exposure.

### Risk and Sensitivity Register

Captures personal data, credentials, secrets, compliance-sensitive material, consent boundaries, health/NDIS/BCI sensitivity, customer records, and evidence-chain requirements.

## Supabase harvest method

Use Supabase PAT through Bridge/cap store where authorised.

Harvest in this sequence:

1. Management API project inventory.
2. Per-project schema discovery.
3. pg_catalog and information_schema extract.
4. Table and column metadata.
5. Row counts and size estimates.
6. RLS/policy/function/trigger inventory.
7. Storage bucket/object inventory.
8. Edge function inventory.
9. Safe sample extraction for business-intelligence classification, respecting sensitivity gates.
10. Relationship inference from foreign keys, naming, code references, Vercel envs, GitHub code, and GDrive references.
11. Asset record writeback into Ecosystem Explorer tables.
12. Command Centre widget publication.

Usage stats are evidence, not deletion criteria.

## Bridge execution envelope

Task: ecosystem_explorer_v1_harvest_and_command_centre_pack

Inputs:

- Supabase PAT from cap store or Bridge secret authority
- GitHub connector / token
- Vercel token if available
- GDrive connector if available
- S3 inventory access if available

Outputs:

- ecosystem_asset_register
- ecosystem_relationship_graph
- ecosystem_business_classification
- ecosystem_supabase_inventory
- ecosystem_opportunity_radar
- ecosystem_command_centre_views
- ecosystem_reality_ledger_receipt

Execution rules:

- No destructive actions.
- No archiving by default.
- No table drop, repo deletion, site removal, or bucket cleanup.
- Classify unknowns as UNKNOWN_ORIGIN, not dead.
- Preserve evidence hash and source URI for every harvested asset.
- Bind all outputs to Reality Ledger.
- Publish Command Centre views under Ecosystem Explorer.

## Suggested table-of-tables schema

- ecosystem_assets
- ecosystem_asset_relationships
- ecosystem_business_families
- ecosystem_products
- ecosystem_campaigns
- ecosystem_provenance
- ecosystem_supabase_objects
- ecosystem_repo_objects
- ecosystem_site_objects
- ecosystem_document_objects
- ecosystem_storage_objects
- ecosystem_intelligence_extracts
- ecosystem_product_dna
- ecosystem_funnel_map
- ecosystem_opportunity_scores
- ecosystem_risk_register
- ecosystem_action_queue
- ecosystem_receipts

## Reality Ledger

status: PARTIAL
result: Ecosystem Explorer canonical taxonomy, reporting model, Supabase harvest method, and Bridge execution envelope created.
evidence:
  - type: github_file
    value: TML-4PM/the-pen/ecosystem-explorer/00_ecosystem-explorer-master-pack.md
  - type: user_instruction
    value: No archiving/no killing; harvest business intelligence before old technology is discarded.
gaps:
  - Live Supabase harvest not yet executed.
  - Bridge runtime receipt not yet returned.
  - Command Centre widgets not yet deployed.
  - Cross-source provenance scan not yet completed.
next_action:
  - Dispatch Bridge envelope using available Supabase PAT and connectors.
  - Create Command Centre Ecosystem Explorer views.
  - Bind returned receipts into ecosystem_receipts.
elevation: Business intelligence recovery operating system for a conglomerate estate.
pressure_flags:
  - False-dead asset risk.
  - Hidden IP loss risk.
  - Provenance ambiguity.
  - Technology-shell distraction.
  - Pre-sale campaign value buried in low-usage tables.
score: 0.90
