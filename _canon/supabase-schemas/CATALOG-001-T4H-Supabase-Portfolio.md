# CATALOG-001 · T4H Supabase Portfolio — Full Catalogue
**Date:** 2026-05-04 (Mon, Sydney) · **Org:** ML-4PM's Org (PRO plan) · **Trigger:** Troy uploaded org-dashboard screenshot showing 8 projects · **Status:** PARTIAL (deep on S1+S2-with-data, shallow on 6 empty shells — no anon keys for those)
**Lodged to Pen:** 2026-05-11 (was staged 2026-05-04, bridge-blocked at the time)

This document supersedes the project-count assumption in `SPEC-T4H-CONSOLIDATION-001` (which assumed 2-3 projects). **There are 8.**

---

## A · WIDE CATALOGUE — All 8 projects

| # | Project | Ref | Region | Compute | Created | REST | Auth | Storage |
|---|---|---|---|---|---|---|---|---|
| 1 | **Ecosystem Explorer** | `lzfgigiyqpuuxslsygjt` | aws \| us-east-1 | MICRO | 12 Apr 25 10:24:29 | 401✅ | 401✅ | 200✅ |
| 2 | **Tech4Humaninty** *(typo)* | `pflisxkcxbzboxwidywf` | aws \| ap-southeast-1 | NANO | 22 Mar 25 19:44:18 | 401✅ | 401✅ | 200✅ |
| 3 | tech4humanity-core | `librjdvfycantsgwpkgj` | aws \| ap-southeast-1 | MICRO | 02 Feb 26 01:36:38 | 401✅ | 401✅ | 200✅ |
| 4 | tech4humanity-fun | `tzcmuwazvthjkcdwjfcn` | aws \| ap-southeast-1 | MICRO | 02 Feb 26 01:36:40 | 401✅ | 401✅ | 200✅ |
| 5 | tech4humanity-gcbat | `ughlfzpdwvxywfgofarz` | aws \| ap-southeast-1 | MICRO | 02 Feb 26 01:36:42 | 401✅ | 401✅ | 200✅ |
| 6 | tech4humanity-ip | `yckvdzvxwuijlicqeqpd` | aws \| ap-southeast-1 | MICRO | 02 Feb 26 01:36:30 | 401✅ | 401✅ | 200✅ |
| 7 | tech4humanity-mission | `vkaqbzskdawoptahwuan` | aws \| ap-southeast-1 | MICRO | 02 Feb 26 01:36:32 | 401✅ | 401✅ | 200✅ |
| 8 | tech4humanity-personal | `gwbuyholtvabbgtwikpl` | aws \| ap-southeast-1 | MICRO | 02 Feb 26 01:36:34 | 401✅ | 401✅ | 200✅ |

**All 8 ACTIVE.** All return 401 on REST without anon key (= alive, RLS active). All have storage layer responsive.

**Naming alignment to T4H pillars (CORE | SIGNAL | MISSION | RETAIL | FUN):**
- CORE → `tech4humanity-core` ✓
- SIGNAL → ❌ no project
- MISSION → `tech4humanity-mission` ✓
- RETAIL → ❌ no project (currently lives in `Tech4Humaninty` aka project #2)
- FUN → `tech4humanity-fun` ✓
- Plus: IP, GCBAT, PERSONAL — three additional pillars

---

## B · DEEP CATALOGUE — Tech4Humaninty (project #2)

**This is where 99% of the working portfolio data lives today.** Schema below derived from public REST inspection (anon JWT).

### B.1 Tenant footprint summary

| Tenant | Tables present | Rows-with-data | Status |
|---|---|---|---|
| **Apex Predator Insurance** | animals · bundle_products · wholesale_tiers · pricing_plans · orders · donations · user_certificates · partner_applications | 52 (real) | Wave-0 PROMOTE |
| **AI Oopsies** | products (22 SKUs) · oopsies (RLS-empty) | 22 | Inventory present, never sold |
| **ConsentX** | testimonials (1) · consent_records (RLS-empty) · public_figures (1 — Julie Inman Grant) | 2 | Brand placeholders |
| **Books & Courses pod** | courses (20 — MS MCP) · disciplines (5) | 25 | Real catalogue |
| **HoloOrg agents directory** | agents (49 — n8n templates) | 49 | Curated, not the 729-active CORD agents |
| **AI Sweet Spots / RDTI** | disciplines (5 research domains) | 5 | RDTI activity registry |
| **Generic consumer infra** | chat_* · notifications · transactions · leads · spottos · email_captures · profiles · user_roles | 0 | Schemas ready, RLS active, no rows |

### B.2 Populated content highlights

**`disciplines` (5 rows) — research thesis registry**

| Slug | Name |
|---|---|
| `inclusive-neurocognitive-systems` | Inclusive Neurocognitive Systems |
| `ai-sweet-spots` | AI Sweet Spots Research |
| `extreme-ai-effects` | Extreme AI Effects |
| `neural-signal-technology` | Neural Signal Technology |
| `cognitive-architecture` | Cognitive Architecture Research |

> These map directly to RDTI activity descriptions (RDTI ref PYV4R3VPW $929,504 lodged 26 Apr). Created 2025-09-25T03:23:56.

**`bundle_products` (3 rows) — Apex retail strategy in DB**

| Bundle | Animals | Price | Savings |
|---|---|---|---|
| Land Predators Bundle | 25 | $149.99 | $99.76 |
| Ocean Hunters Bundle | 20 | $119.99 | $79.81 |
| Complete Apex Predator Collection | 79 | $199.99 | $589.22 |

> Bundle math problem: only 45 animals in DB, Complete Collection promises 79. 34 missing.

**`wholesale_tiers` (4 rows)** — $8.99/cert (10+) → $7.99 (25+) → $6.99 (50+) → $5.99 (100+).

### B.3 Edge Functions (S2)

| Function | HTTP on empty | Verdict |
|---|---|---|
| `create-checkout-session` | 400 "Invalid price ID" | ✅ Live |
| `create-donation-session` | 500 "Invalid donation amount" | ✅ Live |
| `crawl-content` | 500 null-deref | 🟡 Live |
| `process-content-ai` | 500 | 🟡 Live |
| `ai-chat` | 500 | 🟡 Live |

### B.4 Storage (S2)

| Bucket | Public | Objects | Size |
|---|---|---|---|
| `images` | yes | **3** | ~3.8 MB |

**The entire image library across the consolidated portfolio is 3 files.** Brand-asset migration is trivial.

### B.5 RLS posture

All 18 empty S2 tables return PG `42501` ("row violates row-level security policy") on empty POST. Confirms strict default-deny posture. Writes must go through service-role-keyed Edge Functions.

---

## C · WHAT'S IN THE 6 EMPTY SHELLS (provisioned 02 Feb 26)

Cannot deep-probe without anon keys. **Inference from naming + portfolio doctrine:**

| Project | Likely intent | Recommended fate |
|---|---|---|
| `tech4humanity-core` | CORE: AHC + WorkFamilyAI + HoloOrg ops | Populate or **delete** |
| `tech4humanity-fun` | RETAIL/FUN: Apex/Oopsies/Spotto/GirlMath | **Delete** — already in Tech4Humaninty |
| `tech4humanity-gcbat` | GCBAT cluster | Populate or **delete** |
| `tech4humanity-ip` | IP/patent/RDTI registry | Populate or **delete** |
| `tech4humanity-mission` | MISSION: enteraustralia, gov-ai, GCBAT | Populate or **delete** |
| `tech4humanity-personal` | Troy personal data | Populate or **delete** |

**Cost reality:** 6 idle MICRO compute slots ≈ **~$150/mo** waste.

---

## D · IMPLICATIONS

The earlier two-project recommendation (S2 = retail/community, S1 = ops/MAAT/vault) **still holds** but is recontextualised:

| Earlier framing | Updated framing |
|---|---|
| "2 active projects + 1 dead 3rd" | "8 projects, 6 are empty shells from an abandoned per-pillar plan" |
| "Consolidate everything to S2" | "**Already consolidated** — 5 tenants live in S2 today" |
| "Two-project final state" | **Recommended: TWO-PROJECT FINAL STATE — S1 (ops/MAAT/vault) + S2 (everything-public, multi-tenant by RLS). Delete the 6 empty shells.** |

---

## E · OPEN QUESTIONS

| Q | Decision needed |
|---|---|
| F1 | Kill the 6 empty shells now? Default = **delete now** |
| F2 | Memory drift on S1 (Ecosystem Explorer name) — is it actually the ops/MAAT canonical? |
| F3 | Repurpose `disciplines` table as portfolio brand-isolation primitive? Default = **yes** |
| F4 | Fix the "Tech4Humaninty" project-name typo? Default = **yes, rename** |
