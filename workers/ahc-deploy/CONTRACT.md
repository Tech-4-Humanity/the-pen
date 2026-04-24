# Worker Contract: AHC First Deploy

**contract_id:** WRK-AHC-DEPLOY-001  
**version:** 1.0  
**created:** 2026-04-24  
**owner:** troy-operator  
**reality_required:** REAL  

## Objective
First production deployment of Augmented Humanity Coach (`TML-4PM/augmented-humanity-coach`) to Vercel.  
Repo is a Vite + React + shadcn/ui app. `vercel.json` exists. Build command: `npm run build`. Output: `dist/`.  
Current status: no deployment exists, `augmented-humanity.coach` is unreachable.

## Acceptance Criteria
- [ ] `npm run build` succeeds (Vite build)
- [ ] Vercel deployment returns HTTP 200 on `*.vercel.app` URL
- [ ] Registry updated: `primary_domain=augmented-humanity.coach`, `health_score=80`
- [ ] Receipt written to `the-pen/receipts/`
- [ ] `SYNAPSE` job payload updated with deployment URL

## Stop Conditions
- STOP if `npm run build` fails — report error, do not deploy broken build
- STOP if build > 10 min — timeout and escalate
- STOP if Vercel auth fails — escalate to operator for token
- ESCALATE if `.env` values required for build (check `.env` in repo first)

## Inputs
| Key | Value |
|-----|-------|
| repo | TML-4PM/augmented-humanity-coach |
| branch | main |
| build_cmd | npm run build |
| output_dir | dist |
| vercel_team | team_IKIr2Kcs38KGo8Zs60yNtm7Y |
| biz_key | augmented-humanity-coach |
| target_domain | augmented-humanity.coach |

## Execution Steps
1. Checkout `TML-4PM/augmented-humanity-coach` @ main
2. Inspect `.env` — extract required env vars (do NOT log values)
3. `npm ci` — install deps
4. `npm run build` — assert exit 0, `dist/` directory created
5. `vercel deploy --prod` — capture deployment URL
6. HTTP GET deployment URL — assert 200
7. Update `t4h_business_runtime_registry`: `health_score=80`, `deploy_status=live`, `primary_domain=augmented-humanity.coach`
8. Update SYNAPSE job payload with deployment URL
9. Write receipt to `the-pen/receipts/RCP_ahc_deploy_{date}.md`

## Autonomy Tier
AUTONOMOUS — first deploy of existing repo. Escalate only on build failure or auth error.

## Evidence Required
- `npm run build` exit code = 0
- Vercel deployment URL
- HTTP 200 on deployed URL
- Registry update confirmed
- Receipt committed to the-pen
