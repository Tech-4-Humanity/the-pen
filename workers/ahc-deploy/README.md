# Worker: AHC First Deploy

**Status:** READY  
**Contract:** `workers/ahc-deploy/CONTRACT.md`  
**Intent:** `workers/ahc-deploy/INTENT.json`  
**Workflow:** `.github/workflows/worker-ahc-deploy.yml`  

## What This Does
First production deployment of Augmented Humanity Coach (Vite + React + shadcn/ui) from `TML-4PM/augmented-humanity-coach` to Vercel.

## Stack
- Vite + React + TypeScript + shadcn/ui + Tailwind
- Build: `npm run build` → `dist/`
- Deploy: Vercel static (vercel.json present)

## Required Secrets (set in TML-4PM/the-pen repo settings)
| Secret | Value Source |
|--------|-------------|
| `VERCEL_TOKEN` | Vercel account → Settings → Tokens |
| `VERCEL_TEAM_ID` | `team_IKIr2Kcs38KGo8Zs60yNtm7Y` |
| `VERCEL_PROJECT_AHC` | Create via `vercel link` in ahc-src, then get project ID |
| `GH_PAT` | PAT with read access to TML-4PM/augmented-humanity-coach |
| `SUPABASE_URL` | `https://lzfgigiyqpuuxslsygjt.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anon key |

## Run — Dry Run First
```
Actions → Worker — AHC First Deploy → Run workflow → dry_run: true
```

## Run — Live
```
Actions → Worker — AHC First Deploy → Run workflow → dry_run: false
```

## Blocked On
- `VERCEL_TOKEN` must be set in repo secrets
- `VERCEL_PROJECT_AHC` — link project first or create via Vercel dashboard
