# COAX Session — 2026-05-06 Continuation
**Time**: 2026-05-06 AEST (continuation of 2026-05-05 dispatch)
**Mode**: Federated COAX, real execution, no clarification loops
**Inputs from Troy**: "1 lodged / 2 show 32 / 3 watch bill — lambda shocked"

---

## 1. RDTI LODGED — sealed in system

| Action | Status | Evidence |
|---|---|---|
| `maat_decision_log` INSERT topic=RDTI_LODGEMENT_COMPLETE | REAL | rows_affected=1 |
| `maat_immutable_event` INSERT entity_pk=PYV4R3VPW, status=accepted | REAL | rows_affected=1 (hash-chained from prev `5adcdb96…`) |
| `maat_doc_matrix` 7 RDTI rows status→COMPLETE | REAL | rows_affected=7 |
| `rdti_maat_bridge` FY2024/25 rows tagged with lodgement reference | REAL | rows_affected=2 |
| `ops.work_register` WR-071 created — Troy upload evidence URLs | REAL | rows_affected=1 |

**Outstanding control gap, not refund risk**: signed v1.1 PDFs not yet in S3, no AusIndustry receipt or Gordon email ingested. WR-071 tracks until you upload them. The lodgement event itself is locked — system now confirms what you said.

## 2. SHOW 32 — live portfolio from `t4h_portfolio_master`

### CORE (4) — all PARTIAL/PARTIAL/PARTIAL, GATED
- `tech-for-humanity` (holding co)
- `workfamilyai`
- `augmented-humanity-coach`
- `holoorg`

### NEW (2)
- `tradie-ai` — PARTIAL/PARTIAL/PARTIAL
- `belle-deco-primary` — PRETEND

### MISSION (7)
- PARTIAL: `outcome-ready`, `medledger`, `VALDOC` (only one with live URL: valdocco-merch.vercel.app)
- MIXED: `factors` — commercial PARTIAL but runtime PRETEND (repair candidate)
- PRETEND: `mission-critical`, `smartpark`, `aquame`

### SIGNAL (8)
- PARTIAL: `consentx`
- PRETEND: `gc-bat-core`, `far-cage`, `myneuralsignal`, `neuropak`, `ratpak`, `lifegraph`, `ai-olympics`

### RETAIL (6) — all PRETEND
- `enter-australia`, `apac-just-walk-out`, `vuon-troi`, `justpoint`, `xces`, `house-of-biscuits`

### FUN (5) — all PRETEND
- `apex-predator-insurance`, `extreme-spotto`, `ai-oopsies`, `rhythm-method`, `girlmath`

### Counts
- 4 CORE + 2 NEW + 7 MISSION + 8 SIGNAL + 6 RETAIL + 5 FUN = **32** confirmed
- PARTIAL/PARTIAL/PARTIAL businesses: 8 (4 CORE + tradie-ai + outcome-ready + medledger + VALDOC + consentx) — **9 actually**
- All-PRETEND ready for SPEC-003 strip: **22**
- Mixed-state (factors): **1** — needs repair-or-strip decision
- Memory said 20 INVENTORY; system reality is 22-23. Pick 2 to defer or accept the larger strip.

## 3. LAMBDA SHOCK — billing watch deployed

### `ops.lambda_billing_watch` table CREATED + first snapshot inserted
```
snapshot_id:               031f8296-66d8-4ab2-be79-0ac1ed5bc6bd
snapshot_at:               2026-05-05T22:25:32Z
total_lambdas:             801
callable:                   77
never_invoked:             468  (58.4%)
stale_30d (last invoke):   324  (40.4%)
active_30d:                  9  ( 1.1%)
total_invocations_lifetime: 35
free_tier_used_pct:        85.4   (854K / 1M)
free_tier_threshold_alert: WARN_85PCT
```

### What this means
- **801 Lambdas in `mcp_lambda_registry`** — way bigger than the 330+ memory had, and dwarfs the 174 ghost coverage_gap
- **Only 9 of 801 (1.1%) ran in last 30 days**
- **Lifetime invocations across the whole fleet: 35**
- 854K free-tier requests consumed somewhere — that's not coming from these 9 active functions; the consumption is happening *outside* what the registry tracks (real bridge/MCP traffic)

### Watch posture (no destructive ops)
- Watch table inserts a fresh snapshot any time COAX runs (rerun query = new row, never overwrite)
- Free-tier threshold alerts: WARN_85PCT now → CRIT_95PCT next → BLOCK_99PCT
- Categories worth the most attention: `100SIGNAL` (103 lambdas, 0 invocations), `TROY` (77, 0), `OTHER` (53, 0), `BRIDGE` (45, 0 invocations registered)
- Recommended cadence: snapshot daily via cron, alert when active_30d / total drops below 1% or free_tier_used_pct crosses 90

### Phase 1 ghost survey (still queued, awaiting your go)
174 unused Lambdas in coverage_gap — survey is non-destructive (~5 min bridge time), produces classification CSV. No deletes. Just visibility. Per "watch bill — lambda shocked": survey first, decisions second.

---

## Net change this turn
- 5 INSERT/UPDATE statements against MAAT canonical tables (RDTI sealed)
- 1 new table `ops.lambda_billing_watch` + 1 snapshot row
- 1 new work_register item WR-071
- 1 hash-chain extension on `maat_immutable_event`

All REAL. No PRETEND. No completion theatre.
