# POG Worker Contract

Generated: 2026-05-06
Status: ACTIVE

## Worker Registry

| Worker | Lambda | Lane | Status |
|--------|--------|------|--------|
| finance_worker_primary | autonomy-worker-financeops | finance_ops | ACTIVE |
| website_worker_primary | autonomy-worker-websiteops | website_ops | ACTIVE |
| data_worker_primary | autonomy-worker-dataops | data_ops | ACTIVE |
| task_worker_primary | autonomy-worker-taskops | task_ops | ACTIVE |

## Work Queue — Enqueued (P1=highest)

| Priority | work_type | Description |
|----------|-----------|-------------|
| P1 | sweep.domain_lock_normalise | Normalise 60-row provisional domain lock workbook |
| P2 | sweep.evidence_bind | Bind evidence_registry to canonical_entities |
| P3 | sweep.commercial | Build commercial layer |
| P4 | sweep.ingestion | Wire browser/LLM ingestion pipeline |
| P5 | sweep.autonomous | Deploy daily sweep worker |
| P6 | sweep.telemetry_qa | Wire telemetry/QA |
| P7 | sweep.research_lineage | Research/IP lineage |
| P8 | sweep.recommendations | Autonomous recommendations |

## Ingestion Jobs — Queued

- route53 / ap-southeast-2: scan_dns_records
- vercel / team_IKIr2Kcs38KGo8Zs60yNtm7Y: scan_deployments
- github / TML-4PM: scan_repos
- supabase / lzfgigiyqpuuxslsygjt: scan_tables_schemas
- stripe / live: scan_products_prices
- llm_export / claude.ai: ingest_conversations
- browser_export / manual: ingest_browser_sessions

## Canonical Entity Snapshot (2026-05-06)

| Type | Count |
|------|-------|
| agent | 49 |
| domain | 35 |
| worker | 4 |
| deployment | 1 |
| system | 1 |
| **TOTAL** | **90** |

## Sweep Outputs Generated (Initial Run)

| Type | Count |
|------|-------|
| agent.needs_evidence | 49 |
| domain.needs_verification | 35 |
| **TOTAL** | **84** |

## Change Feed Events: 92

## Scheduled Sweep

Cron: pog-daily-sweep @ 0 20 * * * UTC (6am AEST)
Function: pog_daily_sweep()

## Governance

- prod_guard: ACTIVE — no lifecycle=prod without evidence_level=REAL
- change_feed: ACTIVE — every canonical_entity change emits event
- updated_at: ACTIVE — auto-managed
- archive_not_delete: POLICY — archived_at soft-delete

## Next Dev Actions

1. Workers: pick up sweep.domain_lock_normalise (P1) — DNS probe 35 domains, set evidence_level=REAL
2. Workers: pick up sweep.evidence_bind (P2) — match evidence_registry.source_table to canonical_entities
3. Workers: pick up sweep.commercial (P3) — Stripe API → offers/pricing canonical entities
4. Deploy ingestion_jobs workers to consume queued jobs
5. Close Issue #64 with this receipt

