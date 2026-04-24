# Receipt: Worker Activation + Batch 1+2 Promotion

**Date:** 2026-04-24T07:17:40Z  
**Operator:** troy-operator  
**Reality:** REAL  

## What Was Done

### 1. Sweep runs closed
- 160 stale `sweep.runs` forced to `FAILED` (constraint: `RUNNING|OK|FAILED` only)
- All runs from Apr 8–Apr 24 with `finished_at IS NULL` now closed

### 2. Queue cleared
- 16 `blocked` legacy items → `archived`  
- 36 stale `ready`/`triaged` items (site autofixes, legacy handoffs) → `archived`  
- Deploy script bug fixed: `registry/domain-control-system/scripts/deploy-lambdas.mjs` commit `b56154a0`

### 3. Worker pipeline executed
All 8 Batch 1+2 jobs driven through full Symbio→Synapse state machine:

| Job | Receipt chain | Final status |
|-----|--------------|--------------|
| Tech for Humanity | WIP-0001 → PEN-0001 → SYMBIO-0001 → GATEKEEPER-0001 → SYNAPSE-0001 | SYNAPSE |
| ConsentX | WIP-0002 → PEN-0002 → SYMBIO-0002 → GATEKEEPER-0002 → SYNAPSE-0002 | SYNAPSE |
| WorkFamilyAI | WIP-0003 → PEN-0003 → SYMBIO-0003 → GATEKEEPER-0003 → SYNAPSE-0003 | SYNAPSE |
| HoloOrg | WIP-0004 → PEN-0004 → SYMBIO-0004 → GATEKEEPER-0004 → SYNAPSE-0004 | SYNAPSE |
| Augmented Humanity Coach | WIP-0005 → PEN-0005 → SYMBIO-0005 → GATEKEEPER-0005 → SYNAPSE-0005 | SYNAPSE |
| Outcome Ready | WIP-0006 → PEN-0006 → SYMBIO-0006 → GATEKEEPER-0006 → SYNAPSE-0006 | SYNAPSE |
| Tradie AI | WIP-0007 → PEN-0007 → SYMBIO-0007 → GATEKEEPER-0007 → SYNAPSE-0007 | SYNAPSE |
| MedLedger | WIP-0008 → PEN-0008 → SYMBIO-0008 → GATEKEEPER-0008 → SYNAPSE-0008 | SYNAPSE |

## Final Queue State
- `archived`: 268  
- `SYNAPSE`: 8 (all Batch 1+2)

## Evidence
- `audit.receipts`: 40 rows written (5 layers × 8 jobs) — 2026-04-24
- `ops.worker_log`: all transitions logged
- `sweep.runs`: 160 rows closed
- GitHub commit: `b56154a0` (deploy-lambdas.mjs path fix)

## Next Actions Required
- Batch 1 units need actual Vercel/GitHub deployments verified (SYNAPSE status is registry-level, not runtime-level)
- Sweep worker root cause: needs a completion callback — runs open indefinitely if worker crashes mid-sweep
- pg_cron: `sweep_stale_jobs` runs every 5 min but does not close `sweep.runs` rows
