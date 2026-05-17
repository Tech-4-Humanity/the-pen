# Content Signal House Rules

Status: PARTIAL until wired into runtime ingestion, drafting, image generation, approval, and posting workflows.

## Purpose

Create a persistent content signal operating layer that watches live LLM conversations, historical LLM chat exports, LinkedIn article exports, comments, reactions, views, social metrics, and business context to identify when an idea should become a LinkedIn article, essay, series, campaign, product, partnership, ebook, course, or other asset.

The goal is that mid-conversation the system can detect: "this would make a good article" and produce a draft package ready for approval.

## Core Rule

Every meaningful conversation fragment, article, comment, reaction, view, topic, business, brand, and platform format is an object in a table of tables.

Content creation is not a one-off writing event. It is a signal pipeline:

signal -> classify -> compare -> decide -> draft -> package -> approve -> publish -> amplify -> measure -> learn -> reuse

## Required Inputs

1. Live LLM conversation signal
2. Historical LLM chat library
3. LinkedIn exported articles
4. LinkedIn comments, reactions, shares, rich media, and profile exports
5. Existing business and brand registry
6. Social platform registry
7. Brand voice and point-of-view registry
8. Image/style registry
9. Publishing approval state
10. Performance telemetry

## Article Creation Trigger

During any thread, if the user says or implies:

- create a LinkedIn article
- create this as a LinkedIn article short
- turn this into a normal article
- make this an essay
- write the post
- this is a good article
- publish/release the hounds

then the system should be able to create the article package directly.

The article package includes:

- article draft
- length classification: short, normal, long, extra long, essay, or platform-specific
- title options
- summary
- stream assignment
- point of view / business voice
- related prior articles
- series candidate status
- suggested images
- social cutdowns
- approval checklist
- publishing target
- reuse path

## Human Approval Rule

Until proven otherwise, publishing remains human-in-the-loop for:

- final article approval
- final image approval
- business/brand POV confirmation
- sensitive policy/legal/regulatory content
- destructive or paid distribution steps

Drafting, packaging, classification, cutdowns, and recommendation do not require human approval.

## One-Off / Two-Off / Three-Off Escalation

### One-off

If a topic appears once:

- record it
- classify it
- do not overbuild it
- allow article draft if requested

### Two-off

If a topic appears twice:

- record related article linkage
- suggest cross-reference
- add "related article" footer option
- update topic count

### Three-off

If a topic appears three times:

- alert the user
- mark as series candidate
- generate series options
- propose release order
- identify business/product links

### Five-plus

If a topic appears five or more times:

- mark as pillar candidate
- evaluate ebook/course/newsletter/microsite potential
- produce expansion map

### Ten-plus

If a topic appears ten or more times:

- mark as strategic platform candidate
- evaluate partnership, business, product, research, or community path

## Voice and Point-of-View Rule

Every content asset must declare:

- speaker / representative
- business / brand
- audience
- tone
- allowed claims
- banned phrases
- default footer
- distribution channels

Examples:

- Troy / InnovateMe: executive, future-facing, provocative but grounded
- Tech 4 Humanity: ethical, human-centred, policy-aware
- AHC: practical augmentation, organisational transformation, capability uplift
- GC-BAT: governance, neurotechnology, standards, societal risk
- Emerging Tech: exploratory, opportunity-driven, frontier signals

## Platform Expansion Rule

LinkedIn is the first execution surface.

Once LinkedIn works, extend the same object model to:

- Instagram
- TikTok
- YouTube
- newsletter
- website
- Medium or long-form article surfaces
- podcast/video scripts

Each platform must have its own format table, voice adaptation, media requirements, post cadence, approval state, and telemetry metrics.

## Open Source First Rule

Where open-source components exist, prefer reuse before custom build. Candidate categories:

- content calendar frameworks
- taxonomy and tagging systems
- vector search / semantic clustering
- topic modelling
- social scheduling connectors
- analytics ingestion
- media asset management
- approval workflows

Open-source use must still bind to the Reality Ledger with source, licence, fit, and integration status.

## Required Tables

1. content_asset
2. conversation_signal
3. llm_chat_source
4. article_export_source
5. topic_registry
6. topic_occurrence
7. topic_relationship
8. series_registry
9. content_package
10. brand_voice_registry
11. point_of_view_registry
12. platform_registry
13. platform_format_rule
14. media_asset
15. image_style_registry
16. approval_gate
17. publishing_queue
18. engagement_fact
19. topic_performance_rollup
20. gap_analysis
21. monetisation_map
22. partnership_signal
23. product_signal
24. campaign_registry
25. reality_ledger_receipt

## Default Runtime Behaviour

1. Ingest signal from conversation or library.
2. Extract topics, entities, products, audiences, brand links, and article candidates.
3. Compare against existing article archive and topic registry.
4. Count occurrences.
5. Apply one-off/two-off/three-off/five-plus/ten-plus escalation rules.
6. If article requested, generate draft package at requested length.
7. If no length requested, infer likely length from topic weight and user intent.
8. Match to brand voice and POV.
9. Generate image brief and optional social cutdowns.
10. Place in approval queue.
11. After approval, publish or hand off to publishing executor.
12. Measure performance.
13. Feed engagement back into topic registry, release strategy, and future drafting.

## Reality Classification

Current status: PARTIAL

Reason: The house rule exists, but runtime ingestion, table schema, dashboard, trigger engine, and publishing executor are not yet proven in production.

REAL requires:

- schema deployed
- historical LinkedIn export ingested
- LLM chat library ingested
- conversation signal detector running
- at least one article package generated from mid-thread signal
- approval queue created
- publishing handoff proven
- telemetry and receipts written

## Next Required Build

Create the Content Signal Operating System schema, ingestion pipeline, topic counter, series escalation engine, brand voice registry, and LinkedIn article package generator.