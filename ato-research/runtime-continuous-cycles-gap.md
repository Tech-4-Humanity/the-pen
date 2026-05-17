# ATO Research Runtime Gap — Continuous Cycles and Real-Time System

Status: PARTIAL

## Core truth

The artefacts exist. The websites exist. The experiment register exists. The product/pricing evidence is emerging. The missing layer is still the same:

**There is no proven continuous cycle and no real-time evidence system.**

That means current evidence can support reconstruction, but not yet live operating proof.

## What has not changed

1. Evidence is still mostly artefact-based, not runtime-based.
2. Research records are searchable, but not continuously refreshed.
3. Experiment register entries are indexed, but not automatically promoted through lifecycle states.
4. Pricing/RFT/RFQ assets exist, but are not yet linked to a live transaction/evidence ledger.
5. Websites and screenshots show existence, but not continuous operational cycles.
6. No verified cron/event/worker loop is currently proven for ATO evidence capture.
7. No real-time telemetry feed is proven across GitHub, Vercel, Supabase, Stripe, Drive, and Command Centre.

## Required runtime cycle

The system needs this loop:

source event -> capture -> classify -> evidence object -> ledger entry -> challenge mapping -> defence narrative -> dashboard visibility -> periodic reconciliation -> receipt

## Minimum continuous cycles

### 1. Daily evidence sweep
Sources: GitHub, Vercel, Supabase, Stripe, Drive, site URLs, uploaded artefacts.
Output: new/changed evidence objects.

### 2. Experiment lifecycle sweep
States: IDEA -> HYPOTHESIS -> EXPERIMENT -> OBSERVATION -> RESULT -> ASSET -> CLAIM_LINKED -> DEFENCE_READY.
Output: movement log and stale-item alerts.

### 3. Pricing and product sweep
Sources: Stripe, product pages, calculators, pricing catalogues, RFT/RFQ tools.
Output: price history, SKU map, role model comparison, source timestamps.

### 4. RFT/RFQ action sweep
Sources: tender tools, RFT analyser, June action register, proposal docs, calendar/task records.
Output: commercial activity chronology tied to research and pricing models.

### 5. Ledger reconciliation sweep
Sources: evidence ledger, claim ledger, reality ledger, project register.
Output: missing evidence, unsupported claims, duplicate objects, stale evidence.

## Real-time system requirement

Near real-time does not mean fancy. It means every material event leaves a trace quickly enough that the system can reconstruct what happened without memory.

Required event types:

- repo commit
- deployment created
- site/page changed
- product/price changed
- RFT/RFQ record created
- experiment updated
- evidence file added
- claim linkage changed
- challenge raised
- defence updated

## Proof gates before REAL

1. Scheduler or event trigger exists.
2. Worker runs without manual prompting.
3. Output writes to a structured ledger.
4. Run receipt is stored.
5. Dashboard or report can show latest state.
6. Re-run is idempotent.
7. Missing/failed source produces a gap entry, not silence.

## Current classification

Status: PARTIAL

Evidence exists for artefacts and register structure, but not for continuous runtime operation.

## Next build action

Create the continuous evidence cycle package:

- SQL schema for evidence_events, evidence_objects, experiment_lifecycle, pricing_snapshots, rft_rfq_actions, ledger_reconciliation_runs
- GitHub/Vercel/Stripe/Supabase/Drive source adapters
- daily scheduler plus manual run endpoint
- receipt writer
- Command Centre widget
- ATO chronology export

## Rule

Do not call the ATO evidence system REAL until at least one unattended cycle has run, written receipts, and produced a reconciliation report.
