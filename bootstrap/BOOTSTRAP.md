# BOOTSTRAP — SESSION ONBOARDING (T4H)
Updated: 2026-05-22 | Version: 2.0

## On session start — load in this order:
1. House Rules (mandatory behaviour)
2. System Map (where things live)
3. Bridge connection (how to execute)
4. Active priorities (what to work on)

---

## BRIDGE (CANONICAL — DO NOT GUESS)
```
URL:    https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke
Header: x-api-key: <read from cap_secrets key=BRIDGE_API_KEY>
Envelope: {"fn":"troy-sql-executor","sql":"SELECT ..."}
```
**NOT** functionName/payload. **NOT** the old m5oqj21chd endpoint.

### If bridge returns UNAUTHORIZED or empty response:
Lambda concurrency throttled to 0. Run:
```bash
aws lambda put-function-concurrency --function-name troy-sql-executor --reserved-concurrent-executions 10 --region ap-southeast-2
aws lambda put-function-concurrency --function-name mcp-bridge-invoke-handler --reserved-concurrent-executions 10 --region ap-southeast-2
```

### Bridge fallback (when bridge is down):
Direct Supabase REST: `https://lzfgigiyqpuuxslsygjt.supabase.co/rest/v1/{table}`
Header: `apikey: <SUPABASE_SERVICE_ROLE_KEY from cap_secrets>`

---

## SUPABASE (CANONICAL)
- Project ID: `lzfgigiyqpuuxslsygjt`  ← NOT pflisxkcxbzboxwidywf
- Service role key: read from `cap_secrets` table, key=`SUPABASE_SERVICE_KEY`
- GitHub org: TML-4PM
- Vercel team: team_IKIr2Kcs38KGo8Zs60yNtm7Y

---

## HOUSE RULES (NON-NEGOTIABLE)

### Critical rules every session must follow:
| Rule | Behaviour |
|---|---|
| SEARCH_PROTOCOL | Search multi-source before declaring anything missing |
| NO_PASSIVE_WAIT | Never wait for humans. Escalate to Bridge. |
| RULE_BRIDGE_ESCALATION_ONLY | When blocked: Bridge only. Not a human. |
| WRITEBACK_REQUIRED | If not written to a system of record = lost |
| RULE_SYSTEM_BOUNDARY_ENFORCEMENT | Stay in role. Pen builds. Bridge executes. |
| RULE_RETRY_CAP | All loops need retry limits. No infinite loops. |
| RULE_LEGAL_COMPLIANCE | Law overrides optimisation. No exceptions. |
| RULE_HUMAN_OVERRIDE | Human explicit override = stop and apply. |

Full rule set: `SELECT * FROM house_rules WHERE status='active' ORDER BY priority, group_name`

---

## SYSTEM MAP — WHERE THINGS LIVE
| System | Role | NOT for |
|---|---|---|
| Bridge | Execution — runs jobs, returns receipts | Design, decisions |
| Supabase | Structured state — tables, views, RLS | Execution |
| GitHub (TML-4PM/the-pen) | Canonical docs, rules, code | Runtime data |
| Command Centre | Visibility, monitoring | Execution |
| The Pen | Builds artefacts, structures content | Pricing, search, execution |
| Knowledge Library | Storage + retrieval | Decisions, execution |

---

## KNOWLEDGE REGISTER
- Supabase: `ops.standard_knowledge_register` (target) / `public.house_rules` (live)
- Workbook: `unified_standard_knowledge_system_v2.xlsx`
- GitHub: `knowledge/standard_knowledge_register.csv`
- Read priority: Supabase first → workbook second → this file third

---

## ACTIVE PORTFOLIO (2026-05-22)
- **RAR**: 810 slots, 12 GREEN, A01–A10, 9 views live, weekly maturity sweep active
- **House Rules Engine**: 27 rules, 7 groups, live in `public.house_rules`
- **IP Portfolio**: 241 assets, 12 linked to GREEN RAR rows, 4 immediate filing urgency
- **Maturity log**: weekly snapshot via `maat_scheduled_jobs` (Mon 08:00 AEST)

---

## DO NOT
- Hardcode the bridge endpoint — always read from cap_secrets
- Use m5oqj21chd (dead endpoint)
- Use pflisxkcxbzboxwidywf (wrong Supabase project)
- Use functionName/payload envelope (returns FORBIDDEN)
- Wait for a human when blocked
- Leave outputs in chat without writing back
