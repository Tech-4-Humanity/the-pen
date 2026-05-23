# SESSION HANDOFF — 2026-05-23
> Canonical session close document. Writeback receipt = this commit.

---

## REALITY LEDGER — SESSION STATE

| Item | Status | Evidence |
|---|---|---|
| Bridge URL corrected | REAL | commit: 076e7370ca2c |
| Bridge envelope format fixed | REAL | cap_secrets + BOOTSTRAP.md |
| house_rules table seeded (27 rules, 7 groups) | REAL | supabase:public.house_rules |
| knowledge/standard_knowledge_register.csv updated | REAL | commit: 076e7370ca2c |
| rules/house/house_rules_v1.3.csv pushed | REAL | commit: a76916f5350f |
| bootstrap/BOOTSTRAP.md updated | REAL | commit: 987cffa2e54f |
| RAR 5-star pass (810 slots, 9 views, FTS, tags, maturity) | REAL | supabase:research_asset_register |
| A10 parking lot notes populated | REAL | REST PATCH all 9 subgroups |
| 4 A10 fragments migrated to spine | REAL | A03-S04, A03-S03, A09-S04, A01-S01-AT-ABS |
| 17 new knowledge entries from 14 uploaded files | REAL | supabase:cap_secrets |
| Weekly maturity sweep registered | REAL | maat_scheduled_jobs: cron 0 22 * * 0 |

---

## WHAT WAS READ THIS SESSION

| File | Key Insight | Action Taken |
|---|---|---|
| HOUSE_RULES_ENGINE.pdf (101pp) | HRE v1.3: 27 rules, 7 groups, sweeper, glossary, bootstrap structure | Seeded to house_rules table; pushed to GitHub |
| unified_standard_knowledge_system.xlsx | Bridge endpoint stale (m5oqj21chd dead), wrong Supabase ID | Corrected 3 rows, added 8 new rows, saved v2 |
| RPT_AISweetSpots_ResearchWorkbook_GovernancePassbookUpdates_20260521.xlsx | 32-tab research workbook. 6 activities: ASS_CORE/DRA/BRAIN_CAPITAL/SOCIAL_RQ/THRIVING_KIDS/LONGITUDINAL. PARTIAL status. | Added to knowledge register |
| T4H_Portfolio_Roadmap_Current_Next_Status.xlsx | 105 brands. Wave 0 PROD→PROMOTE (overdue). 41 DEV, 24 HOLD. | Added to knowledge register |
| LLM_IP_audit.txt | 142-row master research asset CSV in Drive. CARE metrics CONFLICTING — do not publish. | Added BLOCKED flag to knowledge register |
| Research_Ledger.txt | 15 CORE questions (CORE-01 to CORE-15). 70-80% shared across studies. No full RCT yet. | Added to knowledge register |
| DRAIN_DOCTRINE.md | v1 drain protocol: 6 modes, 4 states, 6 validators. Evidence debt target <15%. | Already in GitHub; logged |
| bbes-gov-drainer-smoke.md | Drainer functional 2026-04-28 | Logged |
| IP_Canonical_Knowledge_Operating_System.md | CKOS: 8-layer runtime IP. Enforcement modes: OFF/WARN/STRICT_CRITICAL/STRICT_ALL | Added as IP to knowledge register |
| scoring_engine_-_white_label_github_README.md | Weighted repo scoring: readiness 30, maintainability 25, security 20, velocity 15, traction 10 | Added to knowledge register |
| Augmented_Marketing_Campaign_and_Sales_Execution_Runtime.pdf | HITL manual. E0-E9 severity. Kill switches. RTO<15min. Classifications: REAL/PARTIAL/PRETEND etc. | Added to knowledge register |
| RPT_HumanSignalImpactFlywheel_T4H_Ecosystem_20260520.pdf | 6-layer flywheel model. Score 0.78 PARTIAL. T4H positioning: builds evidence, not influence. | Added to knowledge register |
| 727_WorkfamilyAI_-_staff_roles.pdf | WorkFamilyAI staff roles linked to Holo-Org 9×9×9 | Logged |
| T4H_ResearchIP_OperatingModel_v1_docx.pdf | 7×7 research lattice (49 cells). Signal engine. 40 SKUs. Safety profiles. | Added 7×7 lattice to knowledge register |

---

## OPEN GAPS — MUST ACTION NEXT SESSION

### HIGH PRIORITY
1. **CARE metrics conflict** — `CLM-005` blocked. `N=1243/OR=29.4` sourced from methodology vs site. Do not publish until reconciled.
2. **Full RCT protocol** — outline only. No protocol doc exists. Needed for 2026 multi-site validation.
3. **Full question bank doc** — 15 core questions exist in workbook. Need standalone bank doc built from all study data.
4. **Wave 0 brands overdue** — 14 PROD brands need PROMOTE actions (tech4humanity.com.au, augmentedhumanity.coach, workfamilyai.org, holo-org.com, AI4Tradies, Outcome Ready, etc.)
5. **DRA paper partial** — ART-DRA-001 has duplicate Drive versions. Needs de-duplication and canonical selection.
6. **Research workbook owners/dates missing** — all 6 activity tabs show "Open" status for recruitment, retention, and risk fields.

### MEDIUM PRIORITY
7. **Stripe product wiring** — 12 GREEN RAR rows missing stripe_product_id (v_rar_stripe_gaps).
8. **ARTEFACT_MANIFEST gaps** — ART-SS-A-002 and ART-SS-A-003 status: REFERENCED_NOT_EXTRACTED. Need Drive extraction.
9. **Bridge concurrency recurring** — add `aws lambda put-function-concurrency` to a scheduled Lambda health check.
10. **7×7 vs 10-area RAR reconciliation** — research IP model uses 7×7 (49 cells), RAR uses 10-area (810 slots). Need mapping table.

---

## SYSTEM STATE AS OF 2026-05-23

### Infrastructure
- Bridge: `https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke`
- Envelope: `{fn, sql}` NOT `{functionName, payload}`
- Supabase: `lzfgigiyqpuuxslsygjt`
- GitHub org: TML-4PM

### Research Asset Register (RAR)
- 810 slots | 12 GREEN | 798 AMBER | A01–A10
- 9 views live (v_rar_search, v_rar_ready_to_publish, v_rar_ipf_alerts, etc.)
- FTS via search_vector (GIN indexed) — confirmed working
- Weekly maturity sweep: maat_scheduled_jobs cron `0 22 * * 0`

### Research Program
- 6 active studies (ASS_CORE, DRA, BRAIN_CAPITAL, SOCIAL_RQ, THRIVING_KIDS, LONGITUDINAL)
- 15 CORE questions (CORE-01 to CORE-15) shared 70-80% across studies
- Scoring: Optimal>=82%, Monitor>=61%, Risk>=41%, Harm<41% | MaxScore=147
- Reality Ledger: PARTIAL (workbook structure built, no real data imported yet)

### Portfolio
- 105 brands tracked | 14 PROD (Wave 0 due) | 41 DEV | 24 HOLD
- Wave 0 target: 28 Apr–1 May 2026 (OVERDUE — action needed)

### House Rules
- 27 rules, 7 groups, v1.3 in `public.house_rules`
- GitHub: `rules/house/house_rules_v1.3.csv`
- Bootstrap: `bootstrap/BOOTSTRAP.md`

---

## NEXT SESSION ENTRY POINT

Load in this order:
1. `bootstrap/BOOTSTRAP.md` — bridge, rules, system map
2. `rules/house/house_rules_v1.3.csv` — behavioural controls
3. This file — session state and gaps

First action:
```
SELECT * FROM house_rules WHERE priority='critical' AND status='active' ORDER BY group_name;
SELECT * FROM v_rar_ipf_alerts;  -- IP filing urgency (8 rows, 4 immediate)
SELECT * FROM v_rar_stripe_gaps WHERE stripe_gap_status='MISSING_STRIPE';  -- 12 rows
```

**CARE metrics — DO NOT PUBLISH until CLM-005 resolved.**
**Wave 0 brands — OVERDUE — start promotion sequence.**
**DRA paper — de-duplicate before sharing externally.**
