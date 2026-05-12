# 83_ram_dev_inspection_gate.md

## Purpose
Dev must inspect a RAM package before it can be promoted to prod. No exceptions.

## What dev must verify

### 1. Schema validity
- All `ram_*` tables exist with declared columns, types, defaults, constraints
- All CHECK constraints on `evidence_state` and `status` columns enforce `REAL|PARTIAL|BLOCKED` only
- All foreign keys resolve and have appropriate ON DELETE behaviour
- All unique indexes present (`ram_assets_canonical_name_uq`, `ram_asset_hashes (hash_type, hash_value)`)

### 2. RLS policy safety
- RLS enabled on all 12 `ram_*` tables
- `service_role` policies present and permissive
- `authenticated` read-only on portfolio + watch surfaces
- `anon` has no policies (default deny)
- `v_ram_portfolio_real` returns only `evidence_state='REAL'`

### 3. Naming compliance
- All package files match `^([0-9]{2})_([a-z0-9_-]+)(?:_v[0-9-]+)?\.[a-z0-9]+$`
- No `final`, `fixed`, `real-final`, `latest`, `untitled` tokens
- Semantic ranges respected (00-99 buckets)
- Environment tags applied where present

### 4. Evidence classification accuracy
- Every `ram_asset_validation` row references a real asset and a real check
- Every REAL row has at least one typed evidence row
- No row claims REAL without typed evidence
- No PRETEND state anywhere

### 5. Reportability of internal dataset
- At least one ingest from `TML-4PM/the-pen` present
- At least one ingest from `TML-4PM/mcp-command-centre` present
- At least 25 assets normalised
- At least 5 portfolio cards generated for one brand
- At least one validation summary report exists

### 6. Widget render path
- All 9 widgets in `40_ram_command-centre_widgets.tsx` render against live Supabase
- `v_ram_portfolio_real` returns at least one row
- No widget breaks the page if data is empty (loading + empty states present)

### 7. Bridge handoff payload format
- Bridge calls use correct envelope (NESTED for `troy-sql-executor`, TOP-LEVEL otherwise)
- Receipts written to `audit.log` with matching stems
- Multi-statement SQL never sent via `troy-sql-executor`

### 8. Reality Ledger binding
- At least one `public.reality_ledger` row created at dev-inspection submission with status=PARTIAL
- No PRETEND values
- Each ledger row references a typed evidence object

### 9. Rollback safety
- Schema rollback path documented and reversible
- Lambda rollback retains previous version
- Bridge allowlist reversible via prior commit

### 10. Cost gate
- Per-asset compute under budget
- No zombie agents
- Orphan timeout enforced

## Inspection workflow
1. Dev posts to `POST /ram/dev/inspect` with package_stem
2. Worker inserts `ram_dev_inspections` row with status=`PARTIAL`
3. Dev runs the 10 checks above
4. Dev posts findings (JSONB) and flips status to `REAL` or `BLOCKED`
5. Receipt `RCPT_ram_dev-inspection_<stem>.json` is written to `audit.log`
6. Reality Ledger row updated

## Pass criteria
A dev inspection passes ONLY when:
- All 10 checks return REAL
- At least one finding entry per check
- Receipt URI recorded
- Telegram broadcast to chat_id 6972032328 confirms inspection complete

## Fail handling
- If any check is BLOCKED, dev inspection is BLOCKED
- If any check is PARTIAL, dev inspection is PARTIAL
- BLOCKED inspections cannot promote to prod
- PARTIAL inspections must be re-run after remediation

## No HITL fallback
This gate is automated and autonomous. HITL only triggers on legal/destructive/financial threshold; not on routine inspection outcomes.

## Standing constraint
RAM dev inspection on `PKG_ram_dogfood-first_20260512` must reference real internal data. A dev inspection without internal data ingestion is automatically BLOCKED, regardless of other check results.
