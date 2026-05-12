# 50_ram_bridge_handoff.md

## Purpose
Define how RAM packages are handed off through the T4H bridge to the Pen, dev, and prod, with deterministic receipt naming and Reality-Ledger binding.

## Bridge endpoint
POST https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke

Headers:
- x-api-key: <BRIDGE_ROUTER_KEY>
- Authorization: Bearer <BRIDGE_API_KEY>

Envelope rules:
- troy-sql-executor -> NESTED { fn:troy-sql-executor, payload:{sql:...} }
- All other RAM Lambdas -> TOP-LEVEL { fn:<lambda>, <field>:<value> }

## Package naming
PKG_ram_<purpose>_<YYYYMMDD-HHMM>.zip
Example: PKG_ram_dogfood-first_20260512.zip
Receipt mirror: RCPT_ram_<purpose>_<YYYYMMDD-HHMM>.json

## Hand-off flow

### 1. Pen push (GitHub)
- Tool: T4H Remote MCP Clean github_bulk_dispatch
- Owner/repo: TML-4PM/the-pen
- Branch: main
- One commit per file, message format: ram: <slug>
- Receipt: commit SHA collected per file, persisted to ram_packages.manifest.commits[]

### 2. Dev inspection
- Insert into public.ram_dev_inspections (status=PARTIAL initially)
- Bridge notifies dev via Telegram (chat_id 6972032328) with package stem + commits
- Dev posts findings (jsonb) and flips status to REAL or BLOCKED
- Receipt: RCPT_ram_dev-inspection_<stem>.json written to audit.log

### 3. Prod promotion
- Pre-check: select * from public.ram_dev_inspections where package_stem=$1 and status='REAL'
- If empty -> insert ram_prod_promotions with status=BLOCKED, gate_result.reason=no_dev_inspection_real
- If present -> insert with status=REAL, write public.reality_ledger row, receipt to audit.log
- Receipt: RCPT_ram_prod-promotion_<stem>.json

## Failure modes and recovery
- Bridge 4xx -> classify as BLOCKED, write ram_watch_events severity=critical
- Bridge 5xx -> retry with exponential backoff (max 3), then BLOCKED
- SQL error masked by troy-sql-executor -> verify via PostgREST read; if not present, status=BLOCKED
- Multi-statement SQL -> rejected; use run_sql RPC for DDL

## Idempotency
- Pen push: SHA-based; identical content does not create new commit
- Dev inspection: composite key (package_stem, inspector) enforced application-side
- Prod promotion: one REAL row per package_stem; subsequent attempts return existing receipt

## Telemetry
- Every handoff stage writes:
  - audit.log row
  - ram_packages.manifest.events[] append
  - ram_watch_events if degraded
- public.reality_ledger updated only at prod stage with typed evidence

## Standing constraint
RAM stays PARTIAL across all surfaces until at least one full dogfood loop closes with a RCPT_ram_prod-promotion_* receipt referencing internal Tech 4 Humanity data.
