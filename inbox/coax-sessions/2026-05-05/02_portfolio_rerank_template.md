# Portfolio Re-Rank — 28 Businesses Triage Framework
**Owner**: COAX | **Squad**: P02-C9 (तृष्णा दवे) + P02-D6 (Daniel Landry) signal analysts | P07-E5 (दिव्या दुआ) + P07-E1 (Melanie Jordan) revenue scorers | P04-I1 (तन्वी मणि) + P04-H10 (陽子 中島) cost scorers
**Generated**: 2026-05-05

---

## Scoring Axes (each 0-10, weighted)

| Axis | Weight | Definition | Source |
|---|---|---|---|
| Revenue Potential (12mo) | 30% | Realistic revenue if pushed — not best-case fantasy | Market sizing + comparable signals |
| Current Traction | 20% | Live customers, paying users, signed LOIs | Supabase `cap_leads`, MAAT bank feeds, deployment traffic |
| Cost-to-Maintain | 20% | Monthly burn: infra, domain, dev time, compliance | Lambda usage, Vercel, GitHub Actions, accounting |
| Strategic Fit | 15% | Alignment with HoloOrg/AHC/WorkFamilyAI core thesis | Founder review |
| IP/Asset Value | 10% | Reusable IP if business were stripped | IP Opportunity Register |
| Compliance Drag | 5% | Regulatory exposure if continued | GAP register |

## Decision Matrix (output of scoring)

| Total Score | Classification | Action |
|---|---|---|
| 8.0+ | **CORE** | Investment, scale, dedicated squad |
| 6.0–7.9 | **GROW** | Light squad, monthly review |
| 4.0–5.9 | **MAINTAIN** | Skeleton crew, quarterly review |
| 2.0–3.9 | **STRIP** | Enter Strip-Consume protocol |
| < 2.0 | **EMERGENCY ARCHIVE** | Skip strip, just secure identities + archive |

## Anti-Spiral Rules (preventing "everything looks important")
- **Ranking is forced-distribution**: max 5 businesses can score 8.0+. Period.
- **No score above 7.0 without typed evidence** (revenue receipt, signed contract, working deployment with real users)
- **Cost-to-Maintain above 7 with revenue below 3 = automatic STRIP** regardless of other axes
- **Strategic Fit alone cannot save a business** — must clear at least 4.0 on Revenue Potential OR 6.0 on IP Value

## Confirmed Constraint
- **3 CORE locked** by SPEC-003: augmented-humanity-coach, workfamilyai, holoorg
- These do not get scored — they're spine. The other 25 do.

## Bridge-Down Posture
- Cannot pull live revenue from MAAT
- Cannot pull deployment traffic from Vercel
- Cannot run Lambda invocation counts
- **Can do now**: build the rubric, prep the scoring sheet template, draft criteria for each axis

## Scoring Sheet Template
| Slug | Group | Rev Pot | Traction | Cost | Strategic | IP | Compliance | Weighted | Class | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| augmented-humanity-coach | CORE | — | — | — | — | — | — | LOCKED-CORE | — | SPEC-003 |
| workfamilyai | CORE | — | — | — | — | — | — | LOCKED-CORE | — | SPEC-003 |
| holoorg | CORE | — | — | — | — | — | — | LOCKED-CORE | — | SPEC-003 |
| ai4tradies.org | RETAIL? | | | | | | | | | E2E test pending |
| consentx.org | SIGNAL? | | | | | | | | | Canonical domain |
| ... | | | | | | | | | | 22 more |

**Action required**: Troy to confirm the full 28-slug list with group assignments. Memory references CORE/SIGNAL/MISSION/RETAIL/FUN groups but no enumerated mapping is in current context.

## Output Schedule
- **Day 0** (today): Framework locked, sheet seeded with the 3 CORE
- **Day 1**: Slug list confirmed, scoring sheet populated with placeholders
- **Day 3**: Each axis scored using whatever data is available (typed evidence flagged)
- **Day 5**: Review session — Troy confirms or overrides classifications
- **Day 7**: STRIP candidates handed to Strip-Consume execution plan
