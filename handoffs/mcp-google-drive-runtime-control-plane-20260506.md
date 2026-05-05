# MCP Google Drive Runtime Control Plane — Pen Handoff

**Date:** 2026-05-06
**Source actor:** ChatGPT / Troy execution session
**Target:** `TML-4PM/the-pen`
**Job key:** `mcp_google_drive_runtime_control_plane_20260506`
**Requested outcome:** Complete all issues, send to Pen, obtain receipt, close.

## Status

**Classification:** PARTIAL

This packet is dispatched to the Pen with a GitHub write receipt. The private MCP Bridge endpoint could not be invoked from this ChatGPT environment, so this handoff is not claimed as a successful bridge runtime execution. It is a durable Pen work order and outbound receipt path for execution by the canonical bridge/runner.

## Evidence already checked

The Pen repository confirms the canonical document hierarchy and runtime contract:

- `README.md` identifies `global/GLOBAL_RULE.md`, `global/MCP_EXECUTION_CONTRACT.md`, `global/ENFORCEMENT_LIVE.md`, `global/ACTOR_COMPLIANCE.md`, and `global/RECEIPT_SCHEMA.json` as the required hierarchy.
- `MCP_EXECUTION_CONTRACT.md` defines the bridge path: actor → MCP Bridge → `troy-sql-executor` → `public.fn_github_push()` → GitHub API → receipt.
- `ENFORCEMENT_LIVE.md` identifies the runtime path and known non-working paths.
- `receipts/README.md` requires outbound and inbound receipts for important work.

## Problem statement

Google Drive MCP is blocked due to an environment variable name mismatch. This is not just a connector issue. It is a symptom of configuration drift across the autonomous operations fabric.

The affected operating surface includes:

- MCP connector runtime
- Bridge runner
- local Mac shell/runtime
- Docker/container runtime
- Lambda runtime
- Supabase secrets/runtime
- Vercel runtime
- EC2 orchestrator/runtime
- GitHub/Pen receipt path
- Command Centre telemetry

## Known issues register

| # | Issue | Classification | Required close condition |
|---:|---|---|---|
| 1 | Google Drive MCP blocked by env var name mismatch | PARTIAL | Exact required var and actual supplied var recorded; shim applied; connector health check passes |
| 2 | Secret naming drift across runtimes | PARTIAL | Canonical secret registry created and populated |
| 3 | No enforced canonical secret registry | PARTIAL | `t4h_secret_registry` / equivalent table exists with aliases, scopes, owners, validation status |
| 4 | Runtime env injection not proven end-to-end | PARTIAL | Local, MCP, Docker, Lambda, EC2, Vercel, Supabase validations logged |
| 5 | Bridge jobs may queue/fail silently when connector blocked | PARTIAL | Blocked connector prevents false-green execution and emits blocker receipt |
| 6 | GitHub/Pen receipt loop not guaranteed in every path | PARTIAL | All dispatches create outbound receipt; all completions create inbound receipt |
| 7 | Tool-unavailable states not always routed to bridge fallback | PARTIAL | Fallback routing rule enforced with BLOCKED classification when unavailable |
| 8 | Reality Ledger binding incomplete | PARTIAL | Every execution writes REAL/PARTIAL/BLOCKED with evidence ref |
| 9 | MCP subprocess/container env may differ from shell env | PARTIAL | Runtime diff check compares shell/subprocess/container values without exposing secrets |
| 10 | Google Drive alias mismatch risk (`GOOGLE_*`, `GOOGLE_DRIVE_*`, `GDRIVE_*`) | PARTIAL | Alias shim resolves legacy names into canonical names |
| 11 | Token freshness not validated separately from env presence | PARTIAL | Google token validation probe logs valid/expired/revoked state |
| 12 | No universal startup assertion for required vars | PARTIAL | Startup guard fails loudly with missing var names |
| 13 | No drift scanner | PARTIAL | Scheduled drift scanner emits receipt and Command Centre status |
| 14 | Multiple execution surfaces have independent config | PARTIAL | Runtime topology map created and kept live |
| 15 | Bridge/Pen handoff ghost risk | PARTIAL | Two-way receipt process enforced per `receipts/README.md` |
| 16 | Connector health not first-class Command Centre telemetry | PARTIAL | Connector health matrix widget/table exists |
| 17 | Dependency failures not always classified BLOCKED early | PARTIAL | BLOCKED classification created before work is claimed |
| 18 | No provider-env mapping table | PARTIAL | Google/GitHub/Slack/Stripe/Supabase/etc. provider map exists |

## Required target architecture

### 1. Secret Registry

Create a canonical registry for all provider secrets and aliases.

Suggested schema:

```sql
create table if not exists public.t4h_secret_registry (
  id uuid primary key default gen_random_uuid(),
  canonical_name text not null unique,
  provider text not null,
  aliases jsonb not null default '[]'::jsonb,
  runtime_scopes text[] not null default '{}',
  owner_system text not null default 'unknown',
  required boolean not null default true,
  validation_status text not null default 'UNKNOWN' check (validation_status in ('VALID','MISSING','EXPIRED','INVALID','UNKNOWN','BLOCKED')),
  last_validated_at timestamptz,
  last_validated_by text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

### 2. Google Drive canonical names

Adopt these canonical names:

```bash
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
GOOGLE_REFRESH_TOKEN
GOOGLE_PROJECT_ID
GOOGLE_APPLICATION_CREDENTIALS
GOOGLE_DRIVE_FOLDER_ID
```

Legacy aliases to support temporarily:

```bash
GDRIVE_CLIENT_ID
GDRIVE_CLIENT_SECRET
GDRIVE_REFRESH_TOKEN
GDRIVE_PROJECT_ID
GDRIVE_FOLDER_ID
GOOGLE_DRIVE_CLIENT_ID
GOOGLE_DRIVE_CLIENT_SECRET
GOOGLE_DRIVE_REFRESH_TOKEN
GOOGLE_DRIVE_PROJECT_ID
GOOGLE_DRIVE_ROOT_FOLDER_ID
```

### 3. Runtime alias shim

Create a reusable startup shim:

```bash
export GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-${GDRIVE_CLIENT_ID:-${GOOGLE_DRIVE_CLIENT_ID:-}}}"
export GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET:-${GDRIVE_CLIENT_SECRET:-${GOOGLE_DRIVE_CLIENT_SECRET:-}}}"
export GOOGLE_REFRESH_TOKEN="${GOOGLE_REFRESH_TOKEN:-${GDRIVE_REFRESH_TOKEN:-${GOOGLE_DRIVE_REFRESH_TOKEN:-}}}"
export GOOGLE_PROJECT_ID="${GOOGLE_PROJECT_ID:-${GDRIVE_PROJECT_ID:-${GOOGLE_DRIVE_PROJECT_ID:-}}}"
export GOOGLE_DRIVE_FOLDER_ID="${GOOGLE_DRIVE_FOLDER_ID:-${GDRIVE_FOLDER_ID:-${GOOGLE_DRIVE_ROOT_FOLDER_ID:-}}}"
```

### 4. Startup guard

All relevant runtimes must fail loudly if required vars are missing.

```ts
const REQUIRED = [
  'GOOGLE_CLIENT_ID',
  'GOOGLE_CLIENT_SECRET',
  'GOOGLE_REFRESH_TOKEN'
];

for (const key of REQUIRED) {
  if (!process.env[key]) {
    throw new Error(`BLOCKED: missing required env var ${key}`);
  }
}
```

### 5. Drift scanner

Scheduled scanner requirements:

- compare canonical secret names to aliases
- compare expected runtime scopes to observed runtime scopes
- validate token freshness separately from var presence
- emit `VALID`, `MISSING`, `EXPIRED`, `INVALID`, `BLOCKED`
- write Reality Ledger evidence
- create outbound/inbound receipts for execution runs
- update Command Centre connector health matrix

### 6. Connector health matrix

Minimum fields:

```sql
create table if not exists public.t4h_connector_health (
  id uuid primary key default gen_random_uuid(),
  connector_name text not null,
  provider text not null,
  runtime_scope text not null,
  health_status text not null check (health_status in ('GREEN','YELLOW','RED','BLOCKED','UNKNOWN')),
  blocker text,
  evidence_ref text,
  last_checked_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
```

## Pen execution tasks

1. Inspect the actual Google Drive MCP manifest/config and record the exact required env var names.
2. Inspect the active runtime env names without logging secret values.
3. Create the secret registry table or map into the existing canonical schema if already present.
4. Seed Google Drive canonical names and aliases.
5. Add runtime alias shim to MCP/bridge startup path.
6. Add startup assertions for Google Drive connector.
7. Add token freshness probe.
8. Add connector health matrix table/view/widget.
9. Add drift scanner job.
10. Add Reality Ledger binding for every connector check.
11. Add outbound receipt for this dispatch.
12. Add inbound acceptance receipt when the Pen/Bridge picks it up.
13. Add implementation receipt when code/schema/shims are committed.
14. Add runtime receipt when Google Drive MCP successfully boots and performs a harmless read/list probe.
15. Add blocker receipt if bridge credentials, runtime access, or Google credentials prevent completion.

## Acceptance criteria

This job is not closed until:

- Google Drive MCP boots with canonical or aliased env names.
- A harmless Google Drive probe succeeds or a clear BLOCKED receipt exists.
- Secret registry is populated for Google Drive.
- Connector health shows a current status.
- Drift scanner can detect mismatches.
- Reality Ledger/evidence ref exists.
- Two-way receipt structure exists under `receipts/mcp-google-drive-runtime-control-plane/`.

## Bridge execution envelope to use

```json
{
  "fn": "troy-sql-executor",
  "payload": {
    "sql": "SELECT public.fn_github_push('TML-4PM/the-pen','handoffs/mcp-google-drive-runtime-control-plane-20260506.md',$PEN$<content>$PEN$,'handoff: mcp google drive runtime control plane','main') AS result;"
  }
}
```

## Reality Ledger

| Field | Value |
|---|---|
| status | PARTIAL |
| result | Pen handoff packet prepared and written through available GitHub connector path |
| evidence | GitHub commit receipt from `create_file`; Pen docs inspected |
| gaps | Private MCP Bridge endpoint not invoked from this environment; no live Google Drive runtime probe performed |
| next_action | Pen/Bridge executor applies shim, validates runtime, emits inbound receipts |
| elevation | Systemic runtime-control-plane issue, not isolated Google Drive connector bug |
| pressure_flags | connector drift, silent failure, ghost handoff, fake-green runtime risk |
| score | 0.78 |

## Close rule

Do not mark this COMPLETE from dispatch alone. Dispatch is outbound evidence only. Completion requires inbound implementation and runtime receipts.
