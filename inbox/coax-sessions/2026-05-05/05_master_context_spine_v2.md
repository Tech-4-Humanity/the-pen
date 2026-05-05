# Master Context Spine v2
**Last Updated**: 2026-05-05 by COAX
**Overall Business Health**: YELLOW (RDTI ✅ secured $929K, but BAS overdue + 4 active workstreams contending for attention + bridge down)

---

## 1. Current Priorities & OKRs (Ranked)

| # | Priority | Target | Success Metric |
|---|---|---|---|
| 1 | Restore canonical bridge | This week | All MCP tool calls return non-error; SQL writes verified gated |
| 2 | Lodge BAS Q1+Q2 FY25-26 | ASAP | ATO acknowledgement received |
| 3 | Strip-Consume 20 INVENTORY businesses | 6 weeks | All 20 archived with 4-layer extraction verified |
| 4 | Sign Div7A agreement | 30 Jun 2026 | Signed PDF in GDrive + Supabase + ATO |
| 5 | Rotate TML-4PM PATs | Recheck status | New PATs working, old revoked |
| 6 | Lodge personal tax FY22-25 | Q3 2026 | Gordon McKirdy submission receipts |
| 7 | Deploy `ops.llm_session_register` | Bridge return + 1 day | Schema live, canary row inserted, weekly view populated |
| 8 | Refresh IP Opportunity Register | Continuous | 7+ IP candidates filed/registered |

## 2. Product & Offer Landscape
- **CORE (locked, SPEC-003)**: augmented-humanity-coach, workfamilyai, holoorg
- **In Market**: tradie/valdoc (recent additions, traction TBD), ai4tradies.org (E2E test pending)
- **In Build**: TAE manuscript (32 chapters, 8 parts; Batch 1.5 pending), Books & Courses pod (Todd Price P06-C10)
- **Backlog**: HoloOrg structure capture (§1, §6, §7 outstanding), 1000-Agent OS book + course
- **INVENTORY (20)**: To strip-archive — list pulled from `ops.standard_knowledge_register` on bridge return

## 3. Financial & Resource Constraints
- **RDTI refund**: $929,504 inbound (lodged 26 Apr 2026, ref PYV4R3VPW) ✅
- **Div7A exposure**: $371,699 total ($72,299 due 30 Jun 2026)
- **BAS Q1+Q2 FY25-26**: OVERDUE
- **Personal tax FY22-25**: unlodged
- **AWS free tier**: 854K/1M Lambda requests consumed (drift signal — 330+ active functions)
- **Approval Thresholds**:
  - AUTONOMOUS: only `t4h.bridge.orchestrator`
  - GATED-CODE (purple): GitHub merges
  - GATED-INFRA (green): infra/schema changes
  - BLOCKED-MONEY: payment/IAM/credential ops

## 4. Customer & Market Context
- Primary ICPs: founders running AI portfolios at scale, family-AI users (WorkFamilyAI), augmented-coaching market (AHC)
- Win/Loss Patterns: TBD — pending Portfolio Re-rank exercise (this dispatch)

## 5. Active Projects & Campaigns

| Project | Owner | Status | Next Decision |
|---|---|---|---|
| Bridge restoration | Symbio (DEV exec) | Diagnostic plan staged | Run Step 1 verification |
| Strip-Consume 20 INVENTORY | P10-B4 Ryan Taylor + squad | Plan staged | Pull slug list on bridge return |
| Portfolio Re-rank 25 non-CORE | P02-C9 + squad | Framework locked | Confirm 25-slug list with groups |
| IP Opportunity Register | P06-C10 Todd Price + squad | 7 candidates mined | Filing decisions per candidate |
| Cross-LLM session register | COAX | DDL staged | Execute on bridge return |
| TAE manuscript Batch 1.5 | Founder-direct | Awaiting expansion pass | Word-count target review |
| HoloOrg structure capture | Founder voice | §2-§5 received; §1, §6, §7 outstanding | Founder voice note |
| Books & Courses pod | P06-C10 Todd Price (lead) | 13 named agents allocated | Seed pair brief |
| ai4tradies.org E2E | 12-agent pod | 1 REAL / 1 PARTIAL / 6 PRETEND pre-run | Awaiting `/run` direction |

## 6. Troy's Preferences & Style (re-anchored)
- **Communication**: Tables > prose. Concise, direct AU, no filler. No clarification loops.
- **Mode**: COAX runs federated; Pen brokers dev; Symbio DEV exec; Synapse PROD exec
- **Posture**: Execute first, explain after. Done = Troy's outcome reached, not API 200.
- **Non-negotiables**:
  - Evidence over rapport
  - REAL/PARTIAL/PRETEND honest labelling
  - No completion theatre
  - HITL on destructive ops
  - Archive-not-delete on data
  - Surface live deadlines every session
  - "Hold every downstream session's intent contract; measure drift on wake"

## 7. Known Gaps & Risks
- **Bridge down** (`m5oqj21chd` / Streamable HTTP wrapper): blocks all writes from this Claude session
- **GAP-001 BASIQ CFN+consent**: not connected
- **GAP-002 S2 payload**: UNKNOWN
- **GAP-003 Snaps CWS → synal-task-intake**: not wired
- **GAP-013**: Two unidentified $5K "Jeff Troy" Mar 2026 transactions
- **GAP-014**: wfai.com + ahc.net NOT owned by T4H
- **PRETEND completion engine**: 9 GATED lockdown actions await Troy confirmation (mcp-command-centre, the-pen, t4h-remote-mcp-server-clean self-signing receipts)
- **API key bk_tOH8...**: 403 burned, must rotate
- **TML-4PM PATs**: status uncertain post-3 May expiry — recheck

## 8. Historical Compound Learnings (Top 5)
1. **Self-signed receipts without runtime traffic = PRETEND.** GitHub Actions bot signing its own success is the smoking gun.
2. **Trailing semicolon on every SQL via bridge.** Otherwise silent `rows:[]`.
3. **`cap_secrets` schema actually has 11 cols, not the 6 the docs said** — verify schema before INSERT.
4. **Bridge-first execution; fall back to Supabase REST; never proceed as if verification occurred when bridge is down.** Acknowledge gap explicitly.
5. **3 CORE locked, 20 INVENTORY to strip — but always extract 4 layers (data, logic, intent, identity) before archive.** External-facing identities are write-once, never deleted.

## 9. Cross-LLM Session Register (NEW)
- Schema: `ops.llm_session_register` (DDL staged this dispatch)
- Default thresholds: 30% drift = re-anchor, 40% drift = scoop-and-thanks
- Three-path wake protocol: Engage / Re-anchor / Scoop
- Weekly aggregate via `v_session_channel_value` shows which channels are net-positive; `v_session_scoop_candidates` flags terminations
