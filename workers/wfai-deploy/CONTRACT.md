# Worker Contract: WorkFamilyAI Re-Deploy

**contract_id:** WRK-WFAI-DEPLOY-001  
**version:** 1.0  
**created:** 2026-04-24  
**owner:** troy-operator  
**reality_required:** REAL  

## Objective
Re-deploy WorkFamilyAI site to Vercel. Current status: 404 on `workfamilyai.vercel.app`. Repo `TML-4PM/workfamilyai` has valid `index.html` (12,776 chars). No `vercel.json` present — static deploy only.

## Acceptance Criteria
- [ ] Vercel project `workfamilyai` exists and is linked to `TML-4PM/workfamilyai`
- [ ] Deployment returns HTTP 200 on `workfamilyai.vercel.app`
- [ ] `primary_domain` in `t4h_business_runtime_registry` updated to `workfamilyai.com`
- [ ] `health_score` updated to 80+
- [ ] Receipt written to `the-pen/receipts/`

## Stop Conditions
- STOP if deployment returns non-200 after 3 attempts
- STOP if Vercel API returns auth error (token missing)
- ESCALATE to operator if DNS custom domain config required

## Inputs
| Key | Value |
|-----|-------|
| repo | TML-4PM/workfamilyai |
| branch | main |
| entry_file | index.html |
| deploy_type | static |
| vercel_team | team_IKIr2Kcs38KGo8Zs60yNtm7Y |
| biz_key | workfamilyai |
| target_url | https://workfamilyai.vercel.app |

## Execution Steps
1. Check Vercel project exists via API — create if missing
2. Trigger deployment from GitHub repo
3. Poll deployment status until ready (max 5 min)
4. HTTP GET `workfamilyai.vercel.app` — assert 200
5. Update `t4h_business_runtime_registry` — health_score=80, deploy_status=live
6. Write receipt to `the-pen/receipts/RCP_wfai_deploy_{date}.md`

## Autonomy Tier
AUTONOMOUS — no human approval required for re-deploy of existing static site.

## Evidence Required
- Vercel deployment URL
- HTTP 200 confirmation
- Registry update confirmed
