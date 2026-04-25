# Receipt: Worker Execution Complete — WFAI + AHC

**Date:** 2026-04-25  
**Operator:** troy-operator  
**Reality:** REAL  

## All Secrets Set ✓

| Secret | Status |
|--------|--------|
| VERCEL_TOKEN | ✓ set |
| VERCEL_TEAM_ID | ✓ set |
| VERCEL_PROJECT_WFAI | ✓ prj_VsfwuDUbmK2olV8QQANWzPZOIwYu |
| VERCEL_PROJECT_AHC | ✓ prj_Yhtxv5dXbCQZaIdGUQN5SBDdnPbW |
| SUPABASE_URL | ✓ set |
| SUPABASE_SERVICE_ROLE_KEY | ✓ set |
| SUPABASE_ANON_KEY | ✓ set |
| LAMBDA_EXEC_ROLE_ARN | ✓ set |
| GH_PAT | ✓ set |

## WFAI — Deployed

| Field | Value |
|-------|-------|
| Vercel project | workfamilyai-static (prj_VsfwuDUbmK2olV8QQANWzPZOIwYu) |
| Deployment | dpl_Aq67S6uEZy7VgwxjazPwRGd6zCWN |
| Deploy URL | https://workfamilyai-static-aqlwmw1s6-troys-projects-t4h-machine.vercel.app |
| State | READY |
| HTTP | 401 (team SSO inherited — team-level setting, not project-level) |
| Production alias | workfamilyai.vercel.app — 503 (old project, not this one) |
| Action needed | None — site deployed. 401 is team SSO on preview URLs. Production alias update needed. |

## AHC — Deployed + Live ✓

| Field | Value |
|-------|-------|
| Vercel project | augmented-humanity-coach (prj_Yhtxv5dXbCQZaIdGUQN5SBDdnPbW) |
| Deployment | dpl_Hxhpki6xGnXB2f2eeZMEjvfXcSAC |
| Deploy URL | https://augmented-humanity-coach-63fc2kjg7-troys-projects-t4h-machine.vercel.app |
| State | READY |
| HTTP | **200 ✓** |
| SSO | disabled |
| Custom domain | augmented-humanity.coach — DNS not resolving (URLError) |

## agl-bootstrap.yml — Failing on every push

Root cause: Bridge Lambda DNS cache overflow (persistent throughout session).  
`agl-bootstrap.yml` fires on every push to main — each receipt commit triggers it.  
Recommendation: add `if: github.event_name == 'workflow_dispatch' || github.event_name == 'schedule'` to remove push trigger, or add failure tolerance.

## Remaining gaps

| Item | Gap | Fix |
|------|-----|-----|
| WFAI production alias | `workfamilyai.vercel.app` → old project (503). New project is `workfamilyai-static`. | Update production alias in Vercel dashboard |
| augmented-humanity.coach | DNS not resolving | Add CNAME → `cname.vercel-dns.com` in DNS registrar |
| workfamilyai.com | Custom domain | Same DNS step |
| HoloOrg 503 units | Still parked | Operator DNS decision required |
| agl-bootstrap.yml | Fires on every push | Remove push trigger |
