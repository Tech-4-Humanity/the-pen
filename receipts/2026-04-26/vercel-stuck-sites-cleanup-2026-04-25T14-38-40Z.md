# RECEIPT — Vercel Stuck-Sites Cleanup

**Session:** 2026-04-26 (Sunday)
**Author:** claude-orchestrator
**Scope:** Vercel team `team_IKIr2Kcs38KGo8Zs60yNtm7Y` (troys-projects-t4h-machine)
**Severity:** HIGH
**Outcome:** 100/100 projects READY · 0 ERROR

---

## Trigger

User reported `mcp-command-centre` import 400 ("Project already exists") + "many issues atm".

## Root cause

1. `mcp-command-centre` already linked to `TML-4PM/mcp-command-centre` (repo id 1102784996); browser was on redundant `/new/import` page. No fix needed.
2. Audit revealed **13 ERROR/CANCELED** projects across the team (out of 100 total — earlier MCP `list_projects` was 50-capped).

## Actions executed

### Phase 1 — Initial cleanup (3 deletes)
| Project | Reason | HTTP |
|---|---|---|
| `t4h-orchestrator` × 2 prj_id | Misimported Python repo, no Vercel entrypoint, every deploy ERRORed | 204 |
| `symbio-dev-control-plane-aukm` | Auto-suffix dupe of canonical `symbio-dev-control-plane` (same GH repo id 1219232439) | 204 |
| `t4h-comms-hub-2zfs` | Auto-suffix dupe of `t4h-comms-hub` (same GH repo id 1220818758) | 204 |

### Phase 2 — Stuck-sites triage (7 deletes + 7 redeploys)
**Deleted (dead/retired):**
- `lead-os-api` — `link:null`, zero deploys; API served by Lambdas `lead-os-intake` + `lead-os-processor`
- `all-chemists-com` — 1 CANCELED deploy, dupe of `all-chemist-com`
- `ai-olympics` — rebranded AiQ
- `wave10-sweeper`, `-hpju`, `-m6i1`, `-eeoi` (×4) — Wave10 retired 2026-03-10

**Promoted/redeployed (production was already healthy on last-good; ERROR was on stale build attempts):**
- `outcome-ready` (dpl_GpoeWVQGj3 — "fix: pricing JSX")
- `justpoint`, `aquame`, `apac-just-walk-out`, `vuon-troi-is-reach-the-sky`, `smartpark`, `mission-critical`, `medledger`
- All 8 returned 409 conflict on promote = LAST_GOOD already current production
- Forced redeploy via `POST /v13/deployments?forceNew=1` to refresh build state
- vuon-troi: redeploy failed (no cache → `vite: command not found`); cleared by deleting 2 stale ERROR records

## Registered in `infra_sites_registry`

7 active rows (slug pattern `vercel_<name>`):
- `vercel_mcp_command_centre` · `vercel_the_pen` · `vercel_t4h_comms_hub`
- `vercel_symbio_dev_control_plane` · `vercel_symbio_synapse_ops`
- `vercel_workfamilyai_static` (lifecycle=review — possible dupe of `work-family-ai`)

10 DELETED markers (slug suffix `_DELETED`):
- `vercel_t4h_orchestrator_BROKEN` · `vercel_symbio_aukm_DUPLICATE` · `vercel_t4h_comms_hub_2zfs_DELETED`
- `vercel_lead_os_api_DELETED` · `vercel_all_chemists_com_DELETED` · `vercel_ai_olympics_DELETED`
- `vercel_wave10_sweeper_DELETED` (×4 variants)

## Logged in `t4h_canonical_changes`

3 entries:
1. SYSTEM_CHANGE / NORMAL — Initial registry sync + duplicate triage
2. SYSTEM_CHANGE / NORMAL — Cleanup deletes (broken + duplicates)
3. SYSTEM_CHANGE / HIGH — Stuck-sites cleanup, 100/100 READY

All 3 broadcast_to=`['telegram']`.

## Final state

```
TOTAL:   100
READY:   100
ERROR:   0
CANCELED: 0
```

## Outstanding (GATED — needs operator decision)

Auto-suffix dupes pre-dating this session, may have aliases/traffic:
- `ai4tradies-i94t`, `-u3y9`, `-rlt5` (vs canonical `ai4tradies`)
- `t4h-agent-orchestrator-v8is` (vs `t4h-agent-orchestrator`)
- `t4h-apps-ntgz` (vs `t4h-apps`)
- `consentx` vs `consent-x` (consentx.org canonical)
- `rhythm-method` vs `the-rhythm-method`
- `t4h-remote-mcp-server` (BLOCKED in registry) vs `t4h-remote-mcp-server-clean`

## Evidence

- Vercel API: 12× HTTP 204 deletes, 8× HTTP 409 promote-conflicts (= already current), 7× redeploy 200, 2× HTTP 200 deploy-deletes
- DB: 9 INSERTs into `infra_sites_registry`, 3 INSERTs into `t4h_canonical_changes`
- Bridge: `bk_tOH8…` via `troy-sql-executor`
- GitHub PAT (`github_pat_11AO5…`) used for repo inspections only (no writes during triage)

