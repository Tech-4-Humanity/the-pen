# Receipt: Worker Requests — WorkFamilyAI + AHC + HoloOrg

**Date:** 2026-04-24  
**Operator:** troy-operator  
**Reality:** REAL  

## Worker 1: WorkFamilyAI Re-Deploy

| Field | Value |
|-------|-------|
| Contract | `WRK-WFAI-DEPLOY-001` |
| Intent | `INT-WFAI-DEPLOY-001` |
| Worker | `.github/workflows/worker-wfai-deploy.yml` |
| Queue entry | `agent_task_queue` / `wip-worker-request` |
| Status | WIP — blocked on secrets |
| Docs | `workers/wfai-deploy/` |

### Blocked on (operator action required)
1. Add `VERCEL_TOKEN` to `TML-4PM/the-pen` repo secrets
2. Create Vercel project for `workfamilyai` → get project ID → add as `VERCEL_PROJECT_WFAI` secret
3. Trigger: `Actions → Worker — WorkFamilyAI Re-Deploy → Run workflow`

---

## Worker 2: AHC First Deploy

| Field | Value |
|-------|-------|
| Contract | `WRK-AHC-DEPLOY-001` |
| Intent | `INT-AHC-DEPLOY-001` |
| Worker | `.github/workflows/worker-ahc-deploy.yml` |
| Queue entry | `7d5dff9d` / `agent_task_queue` / `wip-worker-request` |
| Status | WIP — blocked on secrets |
| Docs | `workers/ahc-deploy/` |

### Blocked on (operator action required)
1. Add `VERCEL_TOKEN` to `TML-4PM/the-pen` repo secrets
2. Create Vercel project for AHC → add as `VERCEL_PROJECT_AHC` secret
3. Add `SUPABASE_ANON_KEY` secret (needed for Vite build env vars)
4. Trigger: `Actions → Worker — AHC First Deploy → Run workflow → dry_run: true` (build test first)

---

## Job 3: HoloOrg 503 — PARKED

| Field | Value |
|-------|-------|
| Queue entry | `c061480f` / `agent_task_queue` / `wip-parked` |
| Status | PARKED — awaiting operator DNS decision |
| Affected units | holoorg, outcome-ready, ai4tradies, medledger |

### Required before unparking
- Operator to confirm DNS config (A/CNAME) for each unit
- Check Vercel project health per unit
- Decision: fix in-place or re-deploy from scratch

---

## Commits
| File | Commit |
|------|--------|
| workers/wfai-deploy/CONTRACT.md | ed603b403e3b |
| workers/wfai-deploy/INTENT.json | 8f97c39cf949 |
| workers/wfai-deploy/README.md | f8e0f73dbe81 |
| .github/workflows/worker-wfai-deploy.yml | 790c8e101607 |
| workers/ahc-deploy/CONTRACT.md | a020b89c977f |
| workers/ahc-deploy/INTENT.json | e45df50528d6 |
| workers/ahc-deploy/README.md | 7f2e411d339a |
| .github/workflows/worker-ahc-deploy.yml | 25704e3d487d |
