# Content Signal OS — Claude Deploy Brief

Status: READY_FOR_CLAUDE_DEPLOY
Source rule commit: 2b82c6bbf52153a148bd1310cec10ac20b9cfe40
Source rule file: CONTENT_SIGNAL_HOUSE_RULES.md
Target repo: TML-4PM/the-pen as canonical rule source
Runtime target: Command Centre / Supabase / Bridge-compatible executor layer

## Mission

Deploy the Content Signal Operating System from house rule into a working runtime layer.

The system must turn meaningful conversation fragments, LLM chat exports, LinkedIn exports, article drafts, comments, reactions, social metrics, brand context, and business context into structured content assets.

The runtime must detect when a topic should become a LinkedIn article, essay, series, campaign, product, partnership, ebook, course, or other reusable asset.

## Non-Negotiable Outcome

This is not complete when a document exists.

Completion requires:

1. database schema deployed
2. seed data loaded
3. ingestion path created
4. topic counter working
5. escalation rules working
6. package generator working
7. approval queue working
8. telemetry written
9. Reality Ledger receipt written
10. Claude deploy report returned with proof

## Reality State

Current state: PARTIAL

Reason: governance exists in CONTENT_SIGNAL_HOUSE_RULES.md, but runtime ingestion, schema, dashboard, trigger engine, approval flow, publishing handoff, telemetry, and receipts are not yet proven.

Target state after Claude deploy: REAL only if runtime receipt and verification evidence are attached.

## Runtime Objects

Claude must create or validate the following tables. Use Supabase/Postgres if available. If a table exists, migrate idempotently.

Required tables:

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

## Minimum Schema Requirements

Every table must include:

- id uuid primary key default gen_random_uuid()
- created_at timestamptz default now()
- updated_at timestamptz default now()
- source_ref text
- reality_state text check in REAL/PARTIAL/BLOCKED/PRETEND where applicable
- evidence jsonb default '{}'::jsonb where applicable

Key content fields:

conversation_signal:
- raw_text text not null
- signal_type text
- source_platform text
- source_thread_ref text
- detected_entities jsonb
- detected_topics jsonb
- user_intent text
- article_candidate boolean default false
- confidence numeric

content_asset:
- title text
- asset_type text
- status text
- stream text
- brand_voice_id uuid nullable
- point_of_view_id uuid nullable
- primary_topic_id uuid nullable
- summary text
- body text
- reuse_path jsonb

content_package:
- content_asset_id uuid
- length_class text
- title_options jsonb
- summary text
- article_draft text
- image_brief text
- social_cutdowns jsonb
- approval_checklist jsonb
- publishing_target text
- telemetry jsonb

topic_registry:
- topic_name text unique
- topic_slug text unique
- occurrence_count integer default 0
- escalation_level text
- strategic_status text
- linked_businesses jsonb
- linked_products jsonb

topic_occurrence:
- topic_id uuid
- source_type text
- source_ref text
- excerpt text
- occurrence_weight numeric default 1

approval_gate:
- content_package_id uuid
- approval_state text default 'pending'
- required_approver text
- approval_reason text
- approved_at timestamptz
- blocked_reason text

publishing_queue:
- content_package_id uuid
- platform text
- queue_state text default 'pending_approval'
- scheduled_for timestamptz
- published_url text
- handoff_receipt jsonb

reality_ledger_receipt:
- task_id text
- status text
- result text
- evidence jsonb
- gaps jsonb
- next_action jsonb
- score numeric

## Seed Data

Create seed rows for brand_voice_registry:

1. Troy / InnovateMe
- tone: executive, future-facing, provocative but grounded
- default stream: InnovateMe

2. Tech 4 Humanity
- tone: ethical, human-centred, policy-aware
- default stream: Tech4Humanity

3. Augmented Humanity Coach
- tone: practical augmentation, organisational transformation, capability uplift
- default stream: AHC

4. GC-BAT
- tone: governance, neurotechnology, standards, societal risk
- default stream: GC-BAT

5. Emerging Tech
- tone: exploratory, opportunity-driven, frontier signals
- default stream: Emerging Tech

Create seed rows for platform_registry:

- LinkedIn
- Instagram
- TikTok
- YouTube
- Newsletter
- Website
- Podcast
- Ebook
- Course

Create seed rows for platform_format_rule:

LinkedIn Article:
- short: 700-1200 words
- normal: 1200-2000 words
- long: 2000-3500 words
- extra_long: 3500-6000 words
- essay: 6000+ words

## Trigger Rules

Claude must implement or stub with executable SQL/function logic:

When raw signal includes user intent equivalent to:

- create a LinkedIn article
- create this as a LinkedIn article short
- turn this into a normal article
- make this an essay
- write the post
- this is a good article
- publish
- release the hounds

then:

1. create conversation_signal
2. extract topic candidate
3. upsert topic_registry
4. create topic_occurrence
5. update occurrence_count
6. compute escalation_level
7. create content_asset
8. create content_package
9. create approval_gate
10. create publishing_queue with pending_approval
11. write reality_ledger_receipt

## Escalation Rules

one_off:
- occurrence_count = 1
- action: record and classify

two_off:
- occurrence_count = 2
- action: suggest related article and cross-reference

three_off:
- occurrence_count >= 3
- action: mark series candidate and generate series options

five_plus:
- occurrence_count >= 5
- action: mark pillar candidate and evaluate ebook/course/newsletter/microsite

ten_plus:
- occurrence_count >= 10
- action: mark strategic platform candidate and evaluate partnership/business/product/research/community path

## Human Approval Boundary

Publishing remains human-in-the-loop until proven otherwise.

Human approval required for:

- final article approval
- final image approval
- business or brand POV confirmation
- sensitive policy/legal/regulatory content
- destructive or paid distribution steps

No human approval required for:

- ingestion
- classification
- topic counting
- drafting
- packaging
- social cutdowns
- image briefs
- recommendations
- approval queue creation
- receipt generation

## Claude Deployment Steps

1. Inspect repository and available runtime files.
2. Confirm whether Supabase migrations folder exists.
3. If no migrations folder exists, create one.
4. Add migration: content_signal_os_schema.sql.
5. Add seed file: content_signal_seed.sql or include seeds in migration if repository pattern requires.
6. Add runtime helper/function if project supports it.
7. Add README deployment section.
8. Add smoke test SQL.
9. Commit changes.
10. Return receipt.

## Smoke Test

Claude must include a test that inserts this raw signal:

"This is a good article. Turn this into a normal LinkedIn article for Tech 4 Humanity about why AI companion devices need consent, signal boundaries, and human-centred governance."

Expected result:

- conversation_signal row created
- topic_registry row created or updated
- topic_occurrence row created
- content_asset row created
- content_package row created with normal length_class
- approval_gate row created with pending state
- publishing_queue row created with pending_approval
- reality_ledger_receipt row created
- status remains PARTIAL unless runtime execution evidence exists

## Acceptance Criteria

Claude must return:

- commit SHA
- files changed
- migration path
- smoke test path
- exact commands to run
- runtime proof or reason blocked
- Reality Ledger receipt

## Reality Ledger Receipt Template

Claude must return this object:

```json
{
  "task_id": "content-signal-os-runtime-deploy",
  "intent": "Deploy Content Signal OS runtime from house rules",
  "status": "REAL|PARTIAL|BLOCKED",
  "result": "What was actually deployed",
  "evidence": [
    {"type": "commit_id", "value": "..."},
    {"type": "file", "value": "..."},
    {"type": "migration", "value": "..."},
    {"type": "smoke_test", "value": "..."}
  ],
  "gaps": ["Any unresolved runtime gaps"],
  "next_action": ["Next executable steps"],
  "score": {
    "execution": 0,
    "evidence": 0,
    "economic": 0,
    "reuse": 0,
    "delta": 0,
    "overall": 0
  }
}
```

## Definition of Done

REAL only if:

- schema exists in repo
- migration is executable
- seed data exists
- smoke test exists
- generated package path is proven by SQL or runtime test
- approval queue exists
- receipt exists

Otherwise return PARTIAL with exact gap.

Do not mark REAL for documentation alone.
