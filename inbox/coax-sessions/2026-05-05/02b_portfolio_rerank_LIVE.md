# Portfolio Re-Rank v2 — Live Data
**Generated**: 2026-05-05 by COAX | **Source**: t4h_portfolio_master + v_maat_business_pnl + system status
**Squad**: P02-C9 (तृष्णा दवे) + P07-E5 (दिव्या दुआ) + P04-I1 (तन्वी मणि)

---

## Reality check
- Memory said 28 businesses. **System has 32.**
- Memory said 30 named. **System has 32 in t4h_portfolio_master.**
- Memory said 6 active / 22 on-hold. **System reality: 0 commercial-REAL, 10 PARTIAL, 22 PRETEND.**
- Memory said 3 CORE. **System has 4 CORE (the 4th is `tech-for-humanity` — the holding company).**

The "active vs on-hold" framing in memory has drifted from the actual ledger. This re-rank uses live data.

## Live portfolio (32 businesses)

### CORE (4) — locked, do not score
| biz_key | commercial | runtime | canonical_site |
|---|---|---|---|
| tech-for-humanity | PARTIAL | PARTIAL | (holding co) |
| augmented-humanity-coach | PARTIAL | PARTIAL | augmentedhumanity.coach |
| holoorg | PARTIAL | PARTIAL | holo-org.com |
| workfamilyai | PARTIAL | PARTIAL | workfamilyai.org |

### SIGNAL (8)
| biz_key | commercial | runtime | recommendation |
|---|---|---|---|
| consentx | PARTIAL | PARTIAL | **MAINTAIN** (canonical domain consentx.org) |
| ai-olympics | PRETEND | PRETEND | **STRIP** |
| far-cage | PRETEND | PRETEND | **STRIP** |
| gc-bat-core | PRETEND | PRETEND | **STRIP** |
| lifegraph | PRETEND | PRETEND | **STRIP** |
| myneuralsignal | PRETEND | PRETEND | **STRIP** |
| neuropak | PRETEND | PRETEND | **STRIP** |
| ratpak | PRETEND | PRETEND | **STRIP** |

### MISSION (7)
| biz_key | commercial | runtime | recommendation |
|---|---|---|---|
| outcome-ready | PARTIAL | PARTIAL | **MAINTAIN** |
| medledger | PARTIAL | PARTIAL | **MAINTAIN** |
| VALDOC | PARTIAL | PARTIAL | **GROW** (only one with live URL: valdocco-merch.vercel.app) |
| factors | PARTIAL | PRETEND | **REPAIR or STRIP** — runtime mismatch flag |
| aquame | PRETEND | PRETEND | **STRIP** |
| mission-critical | PRETEND | PRETEND | **STRIP** |
| smartpark | PRETEND | PRETEND | **STRIP** |

### NEW (2)
| biz_key | commercial | runtime | recommendation |
|---|---|---|---|
| tradie-ai | PARTIAL | PARTIAL | **GROW** (E2E test pending per memory; ai4tradies.org) |
| belle-deco-primary | PRETEND | PRETEND | **STRIP** (newest entry — give 30 days before strip) |

### RETAIL (6)
| biz_key | commercial | runtime | recommendation |
|---|---|---|---|
| apac-just-walk-out | PRETEND | PRETEND | **STRIP** |
| enter-australia | PRETEND | PRETEND | **STRIP** |
| house-of-biscuits | PRETEND | PRETEND | **STRIP** |
| justpoint | PRETEND | PRETEND | **STRIP** |
| vuon-troi | PRETEND | PRETEND | **STRIP** |
| xces | PRETEND | PRETEND | **STRIP** |

### FUN (5)
| biz_key | commercial | runtime | recommendation |
|---|---|---|---|
| ai-oopsies | PRETEND | PRETEND | **STRIP** |
| apex-predator-insurance | PRETEND | PRETEND | **STRIP** |
| extreme-spotto | PRETEND | PRETEND | **STRIP** |
| girlmath | PRETEND | PRETEND | **STRIP** |
| rhythm-method | PRETEND | PRETEND | **STRIP** |

## Strip-Consume target list (20 businesses)

Memory said "20 INVENTORY to strip-archive." Live count of PRETEND/PRETEND businesses = **22**. This needs Troy reconciliation:

1. ai-olympics
2. far-cage
3. gc-bat-core
4. lifegraph
5. myneuralsignal
6. neuropak
7. ratpak
8. aquame
9. mission-critical
10. smartpark
11. belle-deco-primary
12. apac-just-walk-out
13. enter-australia
14. house-of-biscuits
15. justpoint
16. vuon-troi
17. xces
18. ai-oopsies
19. apex-predator-insurance
20. extreme-spotto
21. girlmath
22. rhythm-method

**Action**: Troy picks the 2 to defer. Default if no pick: defer the 2 with most recent activity (timestamp on `t4h_portfolio_master.updated_at`).

## Revenue truth (from v_maat_business_pnl)
| business_slug | txn count | total_income | net_position |
|---|---|---|---|
| tech4humanity | 1 | $5,000 | $5,000 |

**That's it. The entire allocated PnL across the portfolio is a single $5K transaction against tech-for-humanity.** The 6,070+ MAAT raw transactions exist but are not allocated to specific businesses through this view.

This is why every business reads PRETEND on commercial status — the spine has no revenue evidence. The Strip-Consume call is well-supported by the data.

## Recommended sequencing
1. **Week 1**: Confirm the 22→20 Strip-Consume list, run SPEC-003 4-layer extraction in parallel batches of 5
2. **Week 2**: Continue Strip; in parallel, verify and lock the 4 CORE + 4 PARTIAL/PARTIAL maintains (consentx, outcome-ready, medledger, VALDOC, tradie-ai)
3. **Week 3**: GROW push on VALDOC + tradie-ai; identify revenue path within 30 days
4. **Week 4**: PARTIAL businesses with no progress in 30 days drop to STRIP
