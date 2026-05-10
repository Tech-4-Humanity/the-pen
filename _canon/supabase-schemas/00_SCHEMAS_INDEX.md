# Supabase Schemas Index — T4H Portfolio
**Path:** `_canon/supabase-schemas/` (canonical destination)
**Lodged:** 2026-05-11 (was staged in Drive 2026-05-04, never canonicalised — bridge-blocked at the time, now unblocked)
**Source bundle:** Drive folder `1QAhJeO5caPv2rSwI2_7r9XXFCJOfZUwc`

## How to add a new project schema

1. Open Supabase Dashboard → Project → Database → **Schema visualizer / dump**
2. Copy the DDL (CREATE TABLE statements)
3. Paste into chat — COAX adds provenance header, verifies, preserves

## Naming convention

`<project-slug>_<YYYY-MM-DD>.sql`

If multiple dumps in the same day: `<project-slug>_<YYYY-MM-DD>_<seq>.sql`

## Provenance header (every file)

```
-- ============================================================================
-- T4H SUPABASE SCHEMA — PROJECT: <Name>
-- Project ref: <ref>
-- Region: aws | <region>
-- Compute: <NANO|MICRO|...>
-- Created: <date the project was provisioned>
-- Schema dumped: <date of this dump>
-- Provenance: <where the DDL came from>
-- Verified: <which tables verified live, by what method>
-- Status: CANONICAL · keep · do not edit
-- ============================================================================
```

## Project status (running)

| # | Project | Ref | Schema captured | Verified | Has data |
|---|---|---|---|---|---|
| 1 | Ecosystem Explorer | `lzfgigiyqpuuxslsygjt` | ❌ pending | — | 🟡 memory says yes (MAAT/vault/ops) |
| 2 | Tech4Humaninty *(typo, retail surface)* | `pflisxkcxbzboxwidywf` | ✅ partial 2026-05-04 (10 tables) | ✅ 10/10 | ✅ 178 rows |
| 3 | tech4humanity-core | `librjdvfycantsgwpkgj` | ❌ pending | — | 🟡 Troy: empty |
| 4 | tech4humanity-fun | `tzcmuwazvthjkcdwjfcn` | ❌ pending | — | 🟡 Troy: empty |
| 5 | tech4humanity-gcbat | `ughlfzpdwvxywfgofarz` | ❌ pending | — | 🟡 Troy: empty |
| 6 | tech4humanity-ip | `yckvdzvxwuijlicqeqpd` | ❌ pending | — | 🟡 Troy: empty |
| 7 | tech4humanity-mission | `vkaqbzskdawoptahwuan` | ❌ pending | — | 🟡 Troy: empty |
| 8 | tech4humanity-personal | `gwbuyholtvabbgtwikpl` | ❌ pending | — | 🟡 Troy: empty |

## Open items

- 4 bundle files (`s2_full_table_inventory.json`, `manifest.json`, `evidence_insurance_policies.json`, `tech4humaninty_partial_2026-05-04.sql`) remain in Drive — download approval gated. To lodge: approve `download_file_content` then bulk-dispatch into this folder.
- `insurance_policies` compliance question (AFSL exposure) — see CATALOG-001-v2-Supplement §3.3. Defer until Troy decides Model A vs Model B for Apex Wave-0.
- 7 of 8 project schemas not yet captured.

## Cross-refs

- Reality ledger: `system='t4h.canon.audit'` `component='drive_bundle_2026-05-08_supabase_schemas'`
- Canonical change: see `t4h_canonical_changes` row created 2026-05-11 'CATALOG-001 lodged to Pen'
