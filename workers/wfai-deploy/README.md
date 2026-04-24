# Worker: WorkFamilyAI Re-Deploy

**Status:** READY  
**Contract:** `workers/wfai-deploy/CONTRACT.md`  
**Intent:** `workers/wfai-deploy/INTENT.json`  
**Workflow:** `.github/workflows/worker-wfai-deploy.yml`  

## What This Does
Re-deploys `TML-4PM/workfamilyai` (static HTML site) to Vercel.  
Current health: 404. Target: HTTP 200.

## Required Secrets (GitHub Actions)
| Secret | Value Source |
|--------|-------------|
| `VERCEL_TOKEN` | Vercel account token |
| `VERCEL_TEAM_ID` | `team_IKIr2Kcs38KGo8Zs60yNtm7Y` |
| `VERCEL_PROJECT_WFAI` | Vercel project ID for workfamilyai (create if missing) |
| `GH_PAT` | GitHub PAT with repo read access |

## Run
```bash
# Via GitHub Actions UI: Actions → Worker — WorkFamilyAI Re-Deploy → Run workflow
# Or push any file to workers/wfai-deploy/ to trigger
```

## Blocked On
- `VERCEL_TOKEN` secret must be set in `TML-4PM/the-pen` repo secrets
- If Vercel project doesn't exist, create via: `vercel link --repo TML-4PM/workfamilyai`
