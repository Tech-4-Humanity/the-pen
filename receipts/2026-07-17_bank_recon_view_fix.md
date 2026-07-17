# Bank Recon View Fix + FY24-25 Statement Gap Chase

**Date:** 2026-07-17
**Author:** Claude (T4H autonomous session)

## 1. Bug found and fixed
`v_maat_bank_recon_summary` had a broken join: `LEFT JOIN (...) ta ON (false)`. This literal-false join predicate meant `txn_loaded` always evaluated to 0 for every account, producing a false "0 transactions loaded, fleet-wide overdue" alarm. Root cause: `account_id` was missing from the `account_latest` CTE grouping, so the join could not be expressed correctly and was stubbed as `false`.

Fix applied via `apply_migration` (fix_bank_recon_summary_broken_join): added `account_id` to the CTE, joined `account_latest` to `txn_actual` on `account_id`.

Verified pre-fix against `maat_transactions` directly: 7,269 real transactions loaded across active accounts (ANZ Personal Everyday 2032, ANZ T4H Business 1066, ANZ Biz Saver 27, Amex business-use 1368, CBA Everyday Offset 1325+220, CBA Home Loan 127+104+4). Post-fix the view now reports these correctly with txn_gap=0 for accounts with matching data.

## 2. Real gaps found (post-fix)

### ANZ T4H Biz Online Saver (...6563)
- Statements 3 (Oct24-Apr25) and 4 (Apr25-Oct25): status PENDING_UPLOAD - never sourced. Covers the second half of FY24-25.
- Statements 1-2 (Oct23-Oct24, 27 txns loaded): status FILE_MISSING - transaction data is loaded but the source PDF is no longer in the storage bucket. Provenance gap only.
- Nov25-Mar26 txn report: also PENDING_UPLOAD (outside FY24-25 but relevant to ongoing coverage).

### Bendigo Loan (...2678) and Savings (...7655)
- Both are placeholder `__GAP__` rows only (`provider: gap_placeholder`). No real statement has ever been registered for either account. PENDING_UPLOAD since 2026-03-02. Entity-wide gap, spans FY24-25.

## 3. Actions taken
- Logged 3 rows to `maat_exception_queue`: MISSING_STMT_ANZ_SAVER (error), FILE_MISSING_ANZ_SAVER_H1 (warn), BENDIGO_UNSOURCED (error).
- Logged 2 rows to `t4h_canonical_changes`: SYSTEM_CHANGE (view fix), BLOCKER (statement gaps).

## 4. Next action required (human)
Troy to source: ANZ Biz Online Saver statements for account 6563 covering Oct 2024 - Oct 2025 (via ANZ internet banking or Hales Redden), and Bendigo statements for Loan 2678 / Savings 7655 for FY24-25 (via Bendigo online banking). Until sourced, FY24-25 bank reconciliation for these two ANZ periods and both Bendigo accounts remains BLOCKED.
