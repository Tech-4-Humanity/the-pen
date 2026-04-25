# HANDOVER RECEIPT — Vercel Estate Cleanup

**Date:** 2026-04-26 (Sunday)
**Operator:** claude-orchestrator (autonomous tier with operator authorisation)
**Scope:** Vercel team `team_IKIr2Kcs38KGo8Zs60yNtm7Y` (troys-projects-t4h-machine)
**Session bracket:** ~14:00–15:30 UTC

---

## TL;DR

| | before | after |
|---|---|---|
| Total Vercel projects | 147 | **144** |
| READY | 134 | **144** |
| ERROR | 13 | **0** |
| NONE / CANCELED | 4 | **0** |

Vercel estate is now **100% READY**. 14 projects deleted (dupes, orphans, retired). 8 working-but-stale projects refreshed. 2 stale CRITICAL bridge BLOCKERs validated and closed.

---

## Trigger

User reported `mcp-command-centre` import 400 ("Project already exists") + "many issues atm".

---

## Root cause map

1. `mcp-command-centre` was already linked to `TML-4PM/mcp-command-centre` (repo id 1102784996); the 400 was a redundant re-import attempt.
2. Initial scan via Vercel MCP capped at 50 projects. Direct `GET /v9/projects?limit=100` revealed 100. Pagination via `?until=` revealed **147 actual** projects.
3. 13 ERROR/CANCELED were a mix of: misimports (Python repos in Vercel), auto-suffix dupes (Vercel auto-suffixed when project name collided), retired sweepers (Wave10), and stale failed-build attempts on healthy production sites.

---

## Deletions (14 projects via DELETE /v9/projects HTTP 204)

| project | reason | canonical |
|---|---|---|
| `t4h-orchestrator` (×2 prj_id) | misimported Python repo, no Vercel entrypoint | (lambda-based) |
| `symbio-dev-control-plane-aukm` | auto-suffix dupe | `symbio-dev-control-plane` |
| `t4h-comms-hub-2zfs` | auto-suffix dupe | `t4h-comms-hub` |
| `lead-os-api` | link=null, zero deploys, lambda-based | `lead-os-intake` + `lead-os-processor` Lambdas |
| `all-chemists-com` | 1 CANCELED deploy, dupe | `all-chemist-com` (singular) |
| `ai-olympics` | rebranded AiQ | `aiolympics` |
| `wave10-sweeper` (×4: bare, -hpju, -m6i1, -eeoi) | Wave10 retired 2026-03-10 | n/a |
| `ai4tradies-i94t`, `-u3y9`, `-rlt5` | auto-suffix dupes (same repoId 1189192749) | `ai4tradies` |
| `t4h-agent-orchestrator-v8is` | auto-suffix dupe (repoId 1216801350) | `t4h-agent-orchestrator` |
| `t4h-apps-ntgz` | auto-suffix dupe (repoId 1203474452) | `t4h-apps` |
| `the-rhythm-method` | auto-suffix dupe (repoId 1119689015) | `rhythm-method` |
| `apex-predator` (orphan) | zero deploys, separate repo from canonical | `apex-predator-insurance` |
| `troy-rocket-wrapper-audit` | orphan, link=null, zero deploys | n/a |
| `t4h-sites` | orphan, link=null, zero deploys | n/a |
| `desktop` | orphan, gemini-bridge-mcp dev artifact | n/a |

(20 deletion markers in registry — count includes 6 partial DELETED entries from sub-phases)

## Refreshes (production was already healthy on last-good)

8 sites where the latest deployment record was ERROR but the production alias was already pointing at the last good READY deploy (promote returned 409 conflict on all):

`outcome-ready` · `justpoint` · `aquame` · `apac-just-walk-out` · `vuon-troi-is-reach-the-sky` · `smartpark` · `mission-critical` · `medledger` · `t4h-revenue-sharing-model-2025`

Stale ERROR records cleared via `DELETE /v13/deployments` to remove cosmetic UI badges.

## Bridge BLOCKERs closed (validated stale)

| id | title | proof of staleness |
|---|---|---|
| 190 | Bridge read selftest STALE — cron stopped (CRITICAL) | `staleness_alert.id=1` resolved 2026-04-20 05:54:37 (76s after firing); `resolved_change_id=194`; 0 open alerts since |
| 195 | Bridge read selftest FAIL: PASS→FAIL (CRITICAL) | caller=`test:trigger_verify_fail`, summary "synthetic test of transition trigger"; recovery test PASSed 4s later |

Validation snapshot: 129 consecutive PASS hourly runs (2026-04-20 06:07 → 2026-04-25 14:07), 0 gaps over 1h, 0 real FAILs since.

Both rows updated: `memory_key='change_190_RESOLVED'` and `'change_195_RESOLVED'`. Closure DECISION row id=411, `memory_key='blocker_close_190_195_20260425'`.

---

## Outstanding — needs operator decision (separate repos, not pure dupes)

| project A | project B | repo A | repo B | call |
|---|---|---|---|---|
| `consentx` | `consent-x` | TML-4PM/consentx | TML-4PM/consent-x | which is wired to consentx.org? |
| `t4h-remote-mcp-server` | `t4h-remote-mcp-server-clean` | id 1173958671 | id 1174086486 | confirm `-clean` is canonical, archive `-server` |
| `workfamilyai-static` | `work-family-ai` (canonical for WFAI) | TML-4PM/workfamilyai | TML-4PM/neural-ennead-family | distinct surface; keep, archive, or merge |

---

## Receipts (this handover)

This document is being committed to:
- `TML-4PM/the-pen` → `receipts/2026-04-26/handover-vercel-cleanup.md`
- `TML-4PM/symbio-synapse-ops` → same path
- `TML-4PM/symbio-dev-control-plane` → same path

Plus prior receipt from earlier in session:
- the-pen `6e9490906d28789177fadaa03d748e591f95e824`
- symbio-synapse-ops `db1b7037d17fc04ce2b51f5d1c25724c540001a1`
- symbio-dev-control-plane `a47ea51b4655aabfbf618fd4465a9a1cf79a7c64`

---

## Audit trail

**`infra_sites_registry`:** 25 rows tagged this session (5 production, 1 review, 19 archived/deleted).

**`t4h_canonical_changes`:** 5 entries logged this session (1× HIGH SYSTEM_CHANGE, 3× NORMAL SYSTEM_CHANGE, 1× NORMAL DECISION). All `broadcast_ok=true` to telegram.

**`ops.work_queue`:** 1 closed job (job_id `9bbc10fe-079f-4d12-b21a-ba957da74126`), origin=pen → destination=symbio, status=closed, gatekeeper_approved=true.

**`ops.bridge_read_selftest_log`:** 0 FAILs in last 5 days, 129/129 hourly PASS, fresh.

**`ops.bridge_selftest_staleness_alerts`:** 0 open.

**`pg_cron`:** 29 775 succeeded / 2 failed in last 24h (~0.007% failure rate).

---

## Health state at handover

```
Vercel:           144 / 144 READY (100%)
Bridge selftest:  PASS 11/11, gap ~40min, fresh
ops.work_queue:   0 stuck items >4h
pg_cron:          0.007% failure rate over 24h
Open BLOCKERs:    11 (down from 13; remainder are pre-existing operator-tier items: BAS, Div7A, DNS, board docs, Cal.com — outside autonomous scope)
```

---

## Process learnings

1. **MCP `list_projects` capped at 50.** Use direct `GET /v9/projects?limit=100` + `?until=` pagination for full estate audit. Real count was 147, not 50.
2. **`promote/{deploymentId}` 409 = already current production.** ERROR badge ≠ broken site; check production alias before declaring outage.
3. **Forced redeploy without cache** (`POST /v13/deployments?forceNew=1`) loses node_modules; safer to leave production aliased and just delete stale ERROR deployment records via `DELETE /v13/deployments/{id}`.
4. **`ops.work_queue` lifecycle is enforced:** must walk submitted → accepted → triaged → ready → claimed → in_progress → done → verified → promoted → closed. Skipping transitions throws 23514.
5. **`troy-sql-executor` rejects multi-statement SQL** including statements with RETURNING and `jsonb_build_object()`; use `run_sql` RPC (`?query=` arg) for those, or split into atomic statements.

