# CAV Browser Harvest Engine

Status: BRIDGE HANDOFF PACKAGE

Purpose: capture browser sprawl, convert each tab into structured business evidence, map to execution, and feed Command Centre / Bridge deployment.

## Included

- `cav_engine_v2.py` — local Mac capture engine for Chrome/Safari tabs.
- `browser_harvest_schema.sql` — Supabase tables and roll-up views.
- `bridge_payload.json` — bridge execution payload for deploy/handoff.
- `runbook.md` — operating instructions and proof gates.

## Reality status

Current classification: PARTIAL

Reason: GitHub handoff is real; runtime deployment requires Bridge execution on the authorised environment and first-run receipt.

REAL gate requires:

1. Code exists in repo.
2. Bridge accepts payload.
3. Runtime executes capture or receives imported tab export.
4. Supabase insert succeeds.
5. Roll-up views return counts.
6. Receipt is written back to `/receipts` or issue comment.

## Important execution note

A cloud Lambda cannot directly inspect a user's local browser tabs. The local capture component must run on the Mac endpoint or browser extension. The Bridge can deploy the processor, storage, schema, and queue, but live browser tab capture needs device-side execution.
