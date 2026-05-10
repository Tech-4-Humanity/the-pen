# CATALOG-001 v2 SUPPLEMENT — S2 Full Table Inventory
**Date:** 2026-05-04 (Mon, Sydney) · **Trigger:** Troy uploaded DDL schema confirmed = S2/Tech4Humaninty source · **Predecessor:** CATALOG-001 v1 · **Status:** PARTIAL (S2 deepened, 7 other projects still pending)
**Lodged to Pen:** 2026-05-11

---

## 0 · Why this supplement

Troy's uploaded DDL listed 10 tables. **All 10 exist in S2.** Cross-checking against v1 revealed I had missed 7 of them. A wider brute-force probe (114 candidate names) raised the live S2 count from **27 → 40 tables**.

Net new discovery: **`insurance_policies` table with 8 populated rows — a fully-defined alternative product model for Apex Predator that I'd missed in v1.**

---

## 1 · The 13 tables CATALOG-001 v1 missed

### 1.1 With data (1)

| Table | Rows | Importance |
|---|---|---|
| **`insurance_policies`** | **8** | 🔴 Major. Apex's alternative product model. See §3. |

### 1.2 Empty but RLS-active (12)

| Table | Tenant signal | Notes |
|---|---|---|
| `adventure_stories` | Apex | User-generated predator-encounter stories with `certificate_id` FK |
| `predator_encounters` | Apex | Lat/long incident reports with `insurance_claim_filed` flag |
| `fun_activities` | Generic FUN pillar | Points-based gamification |
| `music_memories` | **Augmented Memories** | `meal_entry_id` FK + artist/song — food-music memory linker |
| `meals` | **Augmented Memories** | New find — meal entries (parent of `music_memories`) |
| `spotto_likes` | Extreme Spotto | Engagement table |
| `oopsie_comments` | AI Oopsies | Engagement on `oopsies` |
| `app_settings` | Generic | Feature flags / config |
| `bookings` | Generic | Reservations? |
| `comments` | Generic | Cross-tenant comments |
| `content_items` | Generic content | Possibly the article/blog backbone v1 audit said was missing |
| `reports` | Generic | Reporting/analytics |

> **`meals` + `music_memories`** indicate **Augmented Memories is also already in S2** as a 6th tenant.

---

## 2 · Updated S2 tenant footprint

| Tenant | Tables (count) | Rows (real data) | Status revision |
|---|---|---|---|
| **Apex Predator Insurance** | 11 (was 8) | **60** (was 52) | Adds `adventure_stories`, `predator_encounters`, `insurance_policies` |
| **AI Oopsies** | 3 (was 2) | 22 | Adds `oopsie_comments` |
| **ConsentX** | 3 | 2 | Unchanged |
| **Books & Courses pod** | 2 | 25 | Unchanged |
| **HoloOrg agents directory** | 1 | 49 | Unchanged |
| **Augmented Memories** *(NEW tenant)* | 2 | 0 | `meals` + `music_memories` |
| **Extreme Spotto** | 2 (was 1) | 0 | Adds `spotto_likes` |
| **Generic infra** | 16 (was 8) | 0 | +8 new tables |

**Six tenants confirmed. Possible 7th** if `content_items` is the blog backbone for any brand.

---

## 3 · `insurance_policies` — the missed product surface

Apex Predator Insurance has **two product models live in S2 simultaneously**, which the SPA wires up depending on the route taken:

### 3.1 Model A — Novelty certificate bundles (already documented in REV1)
- Individual cert ~$9.99
- 3 bundles ($119.99 / $149.99 / $199.99)
- 4 wholesale tiers ($5.99–$8.99/cert at 10/25/50/100+)

### 3.2 Model B — **Insurance policies (this is new)**

| Policy | Price | Coverage | Animals covered | Regions |
|---|---|---|---|---|
| Basic Wilderness Protection | $49.99 | $75K | Domestic Dog · Moose · Brown Bear · American Alligator | North America · Europe |
| Vector Protection Plan | $89.99 | $150K | Mosquito · Tsetse Fly · Assassin Bug · Vampire Bat | Tropical Africa · C/S America · SE Asia |
| Marine Venom Shield | $149.99 | $300K | Box Jellyfish · Blue-Ringed Octopus · Stonefish · Cone Snail | AU · Indo-Pacific · GBR · SE Asia |
| Australian Outback Survival | $179.99 | $350K | Inland Taipan · Sydney Funnel-Web · Blue-Ringed Octopus · Saltwater Croc | AU + NT/QLD/NSW |
| Reptile & Venom Specialist | $199.99 | $400K | Black Mamba · Inland Taipan · King Cobra · Indian Cobra · Komodo Dragon | Africa · Asia · AU · Indonesia |
| Tropical Adventure Shield | $249.99 | $500K | Jaguar · Vampire Bat · Brazilian Wandering Spider · Tiger Shark | Central/South America · Caribbean |
| Big Game Ultimate | $299.99 | $750K | African Bush Elephant · Lion · Cape Buffalo · Nile Croc · Hippo | Sub-Saharan Africa |
| **Apex Predator Global** | **$399.99** | **$1M** | Tiger · Polar Bear · Saltwater Croc · Great White Shark · Grizzly | **Global** |

All 8 are `is_active=true`, 365-day duration, with structured `exclusions` arrays.

### 3.3 Compliance posture sharpened

The novelty-cert framing in REV1's disclaimer covered the "$9.99 fun cert" angle. **The insurance_policies model materially raises stakes:**
- Marketing language: "Comprehensive coverage", "$1,000,000 coverage"
- Coverage amounts that read like real insurance products
- Regional and animal-specific exclusions resembling actual policy language

Calling something "insurance" with $1M coverage in Australia without an AFS licence is a hard regulatory matter. **Either:**
- (a) Make crystal clear it's parody/novelty + consider renaming away from "insurance" semantics
- (b) Partner with a licensed underwriter (probably out of scope for Wave-0)
- (c) Drop Model B, ship Model A only

**Recommend (c) for Wave-0 launch.** Park `insurance_policies` rows as `is_active=false` until compliance posture decided.

---

## 4 · Schema preservation pattern

```
_canon/supabase-schemas/    (canonical destination — this folder)
 ├── 00_SCHEMAS_INDEX.md
 ├── CATALOG-001-T4H-Supabase-Portfolio.md
 ├── CATALOG-001-v2-Supplement.md
 ├── tech4humaninty_partial_2026-05-04.sql (pending — gated by download approval)
 ├── ecosystem-explorer_<date>.sql (placeholder)
 ├── tech4humanity-core_<date>.sql (placeholder)
 ├── tech4humanity-fun_<date>.sql (placeholder)
 ├── tech4humanity-gcbat_<date>.sql (placeholder)
 ├── tech4humanity-ip_<date>.sql (placeholder)
 ├── tech4humanity-mission_<date>.sql (placeholder)
 └── tech4humanity-personal_<date>.sql (placeholder)
```

Every preserved schema gets a 12-line provenance header, stamped SHA-256, dated filename (archive-not-delete), original DDL preserved verbatim.

**Invariant:** the SQL file is canonical truth for the project at dump-time. The CATALOG supplements derive from it; if they disagree, the SQL wins.

---

## 5 · Per-project data presence summary

| # | Project | Schema captured? | Has data? | Tables (with-data / total) |
|---|---|---|---|---|
| 1 | Ecosystem Explorer | ❌ awaiting | 🟡 Memory says yes — UNVERIFIED | ? / ? |
| 2 | **Tech4Humaninty** | ✅ partial (10 tables) | ✅ **178 rows across 10 populated tables** | 10 / 40 |
| 3 | tech4humanity-core | ❌ awaiting | 🟡 Troy: empty | ? / ? |
| 4 | tech4humanity-fun | ❌ awaiting | 🟡 Troy: empty | ? / ? |
| 5 | tech4humanity-gcbat | ❌ awaiting | 🟡 Troy: empty | ? / ? |
| 6 | tech4humanity-ip | ❌ awaiting | 🟡 Troy: empty | ? / ? |
| 7 | tech4humanity-mission | ❌ awaiting | 🟡 Troy: empty | ? / ? |
| 8 | tech4humanity-personal | ❌ awaiting | 🟡 Troy: empty | ? / ? |

**Tech4Humaninty row count: 178 across 10 populated tables**
- 49 agents
- 45 animals
- 22 products
- 20 courses
- 8 insurance_policies *(new)*
- 5 disciplines
- 4 wholesale_tiers
- 3 bundle_products
- 1 public_figure
- 1 testimonial
- (30 other tables exist but empty)

---

## 6 · Ready-to-receive — what's needed for the other 7

For each remaining project, paste/upload the schema dump. I will:

1. **Verify** by cross-probing live REST against the listed tables
2. **Confirm data presence** per table via `Prefer: count=exact` on `select=count`
3. **Preserve** the DDL in `_canon/supabase-schemas/<project>_<date>.sql` with provenance header
4. **Update** this catalogue with row counts and tenant identification
5. **Surface** any cross-tenant data, missing tables, or compliance-relevant findings

**Highest-value first:**
1. Ecosystem Explorer — most likely to have real data (memory canonical for MAAT/vault)
2. tech4humanity-personal — if it holds Troy personal data
3. tech4humanity-core / -mission / -ip / -fun / -gcbat — likely all true-empty per Troy's note
