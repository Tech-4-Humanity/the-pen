# LinkedIn Intelligence Audit Engine

## Status
PARTIAL/BRIDGE-READY. This package is a complete execution handoff for the LinkedIn export audit system. It is not marked REAL until S3 data is present, Supabase schema is applied, the Lambda/agent run executes, and Reality Ledger proof is written.

## Mission
Turn Troy's downloaded LinkedIn archive into a reusable organisational intelligence engine for:
- article/topic/date/link summaries
- book candidates
- course candidates
- content reuse packs
- business crossover mapping
- predictions tracker
- lost action recovery
- new business ideas
- connection activation strategy

## Input
LinkedIn export files staged in S3.

Recommended S3 layout:
```text
s3://t4h-linkedin-intelligence/raw/YYYY-MM-DD/linkedin-export.zip
s3://t4h-linkedin-intelligence/raw/YYYY-MM-DD/unzipped/
s3://t4h-linkedin-intelligence/processed/YYYY-MM-DD/
s3://t4h-linkedin-intelligence/reports/YYYY-MM-DD/
s3://t4h-linkedin-intelligence/evidence/YYYY-MM-DD/
```

## Run Flow
1. Ingest raw LinkedIn export from S3.
2. Parse Articles, Posts, Comments, Reactions, Connections, Messages where present.
3. Normalise into Supabase tables.
4. Run clustering and classification agents.
5. Generate dashboard-ready outputs.
6. Write report JSON/CSV/Markdown back to S3.
7. Write Reality Ledger proof.
8. Create action backlog for follow-up execution.

## Primary Outputs
- `article_index`: title, date, URL, topic, summary, reusable assets
- `theme_dashboard`: themes ranked by volume, engagement, maturity, business fit
- `book_pipeline`: book candidates with chapter maps and gap analysis
- `course_pipeline`: course candidates and lead magnet ladders
- `business_map`: existing and new business opportunity mapping
- `prediction_tracker`: predictions, status, accuracy, reuse value
- `lost_action_backlog`: abandoned ideas/actions requiring execution
- `connection_strategy`: audience/persona activation map

## Reality Gates
- S3 object exists and checksum captured
- Parser completes without sampling
- Row counts reconciled against source files
- Article links preserved or reconstructable
- Every output has source references
- No item classified as business/book/course without evidence
- Reality Ledger row written with REAL/PARTIAL/PRETEND classification

## Bridge Instruction
Invoke with `bridge_payload.json`. Apply `supabase_schema.sql` first, then deploy or run `lambda_runner.py` as the parser/orchestrator shell.
