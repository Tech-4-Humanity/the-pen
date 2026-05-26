# House Rules Engine — Bridge Activation Handoff

**Status:** ACTIVATION REQUESTED
**Source issue:** [TML-4PM/the-pen#61](https://github.com/TML-4PM/the-pen/issues/61)
**Companion files:**
- `rules/house/house_rules.csv` (commit `19a8847`)
- `bootstrap/product_loop_stub.md` (commit `0dab8f6`)

## Activation request

Bridge should:

1. Sync `rules/house/house_rules.csv` to Supabase (target table: `public.house_rules` or canonical equivalent per schema spine).
2. Surface the resulting rules in **Command Centre**.
3. Return per-rule activation receipts to `receipts/runtime/house-rules-activation-*.receipt.json`.

## Acceptance receipt criteria

- CSV row count matches Supabase row count post-sync (no silent drops — see [bridge-worker-intake#2](https://github.com/TML-4PM/bridge-worker-intake/issues/2) for executor INSERT-masking bug)
- Command Centre widget readable and displays current rule set
- Per-rule receipts written to runtime path
- Reality Ledger row written: `system=house_rules_engine`, `status=REAL` with evidence chain

## Operating intent reference

See `bootstrap/README.md` for product loop and nine-view doctrine.
