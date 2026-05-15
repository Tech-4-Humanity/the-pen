# Bridge Runtime Receipts MCP

Status: PARTIAL

Purpose: add an MCP-facing receipt layer for Bridge runtime acknowledgement so operator commits can be promoted into Bridge-visible, runtime-visible, and human-visible closure states.

## Problem
Current flow can create GitHub artifacts and commit receipts, but cannot yet produce:

- bridge_receipt_id
- db_result
- ontology_upsert_log
- command_centre_surface evidence
- connector_test_results

This MCP package defines the missing interface.

## Required MCP tools

### bridge.submit_handoff
Input:
```json
{
  "task_id": "string",
  "source_repo": "string",
  "source_path": "string",
  "source_commit": "string",
  "intent": "string",
  "closure_target": "closed_for_bridge|closed_for_runtime|closed_for_human",
  "next_owner": "string",
  "failure_owner": "string",
  "evidence": []
}
```

Output:
```json
{
  "bridge_receipt_id": "brg_rcpt_...",
  "status": "ACCEPTED|REJECTED|PARTIAL",
  "received_at": "iso8601",
  "validation": [],
  "next_action": []
}
```

### bridge.get_receipt
Input:
```json
{
  "bridge_receipt_id": "string"
}
```

Output:
```json
{
  "bridge_receipt_id": "string",
  "task_id": "string",
  "status": "string",
  "closure_level": "string",
  "evidence": [],
  "gaps": [],
  "updated_at": "iso8601"
}
```

### bridge.run_connector_tests
Input:
```json
{
  "task_id": "string",
  "connectors": ["github", "notion", "google_drive", "bridge", "receipt_store"],
  "source_commit": "string"
}
```

Output:
```json
{
  "connector_test_receipt_id": "ctr_...",
  "results": [
    {
      "connector": "github",
      "status": "PASS|FAIL|PARTIAL",
      "latency_ms": 0,
      "auth_status": "OK|FAILED|UNKNOWN",
      "schema_status": "OK|FAILED|UNKNOWN",
      "evidence": []
    }
  ]
}
```

### bridge.promote_closure
Input:
```json
{
  "task_id": "string",
  "from": "closed_for_operator",
  "to": "closed_for_bridge",
  "receipt_id": "string",
  "evidence": []
}
```

Output:
```json
{
  "status": "PROMOTED|REJECTED|PARTIAL",
  "closure_level": "string",
  "gaps": []
}
```

## Storage targets

Minimum tables:

```sql
create schema if not exists ops;

create table if not exists ops.bridge_receipts (
  id text primary key,
  task_id text not null,
  source_repo text,
  source_path text,
  source_commit text,
  status text not null,
  closure_level text,
  next_owner text,
  failure_owner text,
  evidence jsonb not null default '[]'::jsonb,
  gaps jsonb not null default '[]'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists ops.connector_test_receipts (
  id text primary key,
  task_id text not null,
  source_commit text,
  results jsonb not null,
  status text not null,
  created_at timestamptz default now()
);

create table if not exists ops.closure_events (
  id text primary key,
  task_id text not null,
  from_level text,
  to_level text,
  receipt_id text,
  status text not null,
  evidence jsonb not null default '[]'::jsonb,
  created_at timestamptz default now()
);
```

## Closure policy

- GitHub commit receipt can close for operator.
- Bridge receipt can close for Bridge.
- DB/runtime mutation can close for runtime.
- Command Centre/Drive/Notion/dashboard surface can close for human.

No simple `closed` claim is valid.

## Connector test matrix

Required tests:

1. GitHub: create/read file, create issue, fetch commit.
2. Google Drive: create doc, fetch metadata.
3. Notion: create page under configured parent, fetch page.
4. Bridge: submit handoff, get receipt.
5. Receipt store: write receipt, read receipt, promote closure.

## Implementation note

This README is the contract for adding the MCP tool layer. It is not a runtime implementation yet.

Current status remains PARTIAL until a working MCP server exposes these tools and returns live receipts.
