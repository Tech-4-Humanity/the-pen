# T4H Managed Migadu MCP

Status: PARTIAL — control scaffold created; no live Migadu execution has occurred.

Upstream: `Michaelzag/migadu-mcp`
Pinned upstream commit: `7b61cb83331003335337dbb40a96e821a33765c0`
Work item: `TML-4PM/the-pen#222`

## Purpose

Wrap the upstream Migadu MCP behind T4H controls so AI agents cannot call production mutations directly.

## Required lifecycle

`intent → inventory refresh → plan → policy → snapshot → execute → verify → receipt → ledger → telemetry → classify → retry/rollback/quarantine`

## Current contents

- `policy/tool_authority.json` — tool authority and control requirements.
- `schemas/receipt.schema.json` — receipt contract.
- `ledger/execution_ledger.jsonl` — append-only ledger seed.
- `telemetry/otel-collector.yaml` — telemetry configuration scaffold.
- `.github/workflows/migadu-managed-mcp-validation.yml` — repository validation workflow.

## Truth state

The scaffold is evidence that implementation has started. It is not evidence of a successful scan, test, sandbox operation, ledger write, or telemetry export. REAL requires observed execution plus independent verification, receipt, ledger, telemetry, and recovery evidence.