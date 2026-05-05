# COAX Delegated Work Board - 2026-05-05

## Wednesday board (29 Apr deadline - Troy-named, COAX-owned)

| ID | Workstream | Last seen | State | Blocker | Tier |
|---|---|---|---|---|---|
| W1 | Browser cleanup - 200-300 tabs T4H+personal | 26 Apr | BLOCKED | OneTab/session-recovery export | LOG |
| W2 | Order Drive - drive_cleanup_plan_v1.md first-pass 10 actions | 26 Apr | PARTIAL - plan written, exec stalled | Bridge for Drive writes | LOG |
| W3 | Audit LLM convos - 7x memories.json + 6.32GB exports -> 1000-agent CSV + 50-biz registry | 28 Apr | PARTIAL - lambda designed | Bridge for Supabase writes | LOG |

## Backlog - multi-week carry

| ID | Workstream | State | DoD |
|---|---|---|---|
| A | HoloOrg sec1, sec6, sec7 | 3 sections outstanding | All 7 in Master Context Spine |
| B | Books and Courses pod (Todd Price P06-C10 lead) | Doctrine + seed pair shipped | First book + course audited against canon |
| C | Cross-LLM session register | Designed UNDEPLOYED | Schema deployed, register populated |
| D | AWS Lambda canary | 854K/1M free-tier; drift signal logged | 9 GATED lockdown confirmed |
| E | CORD 9x9x9 | 4 business names missing | Names assigned, registry closed |
| F | TAE Batch 1.5 expansion | Ch 1-4 PARTIAL word-count | Batch 1.5 -> Batch 2 drafted |
| G | ai4tradies E2E /run | 1R/1P/6PR pre-run | Backend trigger + worker wired |
| 9-LOCK | 9 GATED lockdown actions | Awaiting Troy confirm | Locks executed, audit log entry |
| E1-E15 | RDTI/articles/Notion/cold email/LP/competitor/LinkedIn/decision log/Tab Triage/Stripe/HoloOrg exec/Vercel kill | None progressed | Per-item DoD |

## Slash systems status

| Slash | State | Evidence | Next |
|---|---|---|---|
| /bridge | **HEALTHY v3.5.0** (memory was 7 days stale) | dpl_3e143H, commit 1edb349a, READY 4 May; 9 main deploys all READY since 26 Apr | Bash mcp_call.sh probe with current key |
| /pen | PARTIAL - schema chain drafted, validated, undeployed | pcs_v1-v6 + envelopes + receive_pen_receipt.py (280L, 6 smoke tests pass) | Bridge probe -> deploy via /rpc/run_sql |
| /symbio | DEAD by transitive - Symbio reaches Supabase via Bridge | symbio-dev-control-plane touched in last 7 days | Wait on Bridge -> Pen |
| /internal-comms | DRIFT - projects active, no closed-loop | t4h-comms-hub + chatter-by-ahc deployed; no Stripe->cord.signals roundtrip | Name CRO; wire one live offer |

## PRETEND engine - framing OVERTAKEN

| Surface | Old framing | Live state |
|---|---|---|
| t4h-remote-mcp-server-clean | PRETEND | HEALTHY v3.5.0, 9 deploys READY, github_bulk_dispatch confirmed REAL |
| mcp-command-centre | PRETEND | Re-probe required |
| the-pen | PRETEND | Re-probe required |

9 GATED lockdown actions still pending Troy confirm - they are independent of bridge state and remain valid security ops.

## Live Troy-action deadlines (carried second)

| Item | Date | State |
|---|---|---|
| GitHub PATs (TML-4PM) | 2026-05-03 | OVERDUE 2 days - rotate immediately |
| Div 7A $72,299 | 2026-06-30 | Agreement unsigned (GAP-005) |
| BAS Q1+Q2 FY25-26 | OVERDUE | GAP-004 |
| Personal tax FY22-25 | Unlodged | Gordon McKirdy |
