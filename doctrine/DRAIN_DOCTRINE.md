# DRAIN DOCTRINE v1.0

> Status enforcement rules for all drain.atom entries across The Pen ecosystem.

---

## Core Contract

Every item in drain has a `status` of one of:
- `REAL` — executed, evidence confirmed, receipt on file
- `PARTIAL` — started or handed off, awaiting confirmation
- `BLOCKED` — cannot proceed (missing credential, dependency, access)
- `ARCHIVE` — closed with full evidence chain

**PRETEND is not a valid status.** Any item without typed evidence defaults to PARTIAL, never REAL.

---

## Status Transition Rules

| From | To | Required |
|---|---|---|
| any | REAL | typed evidence (api_response, commit_id, url, hash, cli_output) |
| any | ARCHIVE | status must already be REAL + receipt_ref present |
| any | BLOCKED | reason + dependency named |
| PARTIAL | REAL | evidence added + validated |
| BLOCKED | PARTIAL | blocker resolved |

---

## Validator Rules (V1–V6)

| Rule | Trigger | Effect |
|---|---|---|
| V1 | ARCHIVE without REAL status | BLOCKED |
| V2 | KILL on IP or STRATEGIC item | BLOCKED |
| V3 | HANDOFF without receipt_ref | PARTIAL |
| V4 | IP/STRATEGIC without typed evidence | PARTIAL |
| V5 | HANDOFF without bridge_id | BLOCKED |
| V6 | REGISTER without target_ref | BLOCKED |

---

## Mode Buckets

| Mode | Purpose | Close condition |
|---|---|---|
| KILL | Permanent removal — no recovery | Not IP/STRATEGIC |
| CHECKPOINT | Snapshot in time — version and save | evidence written |
| HANDOFF | Pass to another agent/bridge | receipt_ref confirmed |
| ARCHIVE | Close with full evidence chain | REAL + receipt |
| REGISTER | Bind to external target | target_ref present |
| LIBRARY | Store as reference — no action required | always allowed |

---

## Evidence Types

At least one of the following must be present for REAL status:

- `api_response` — raw HTTP/JSON response from a real API call
- `database_result` — query result, row count, or record ID
- `cli_output` — terminal output including exit code
- `commit_id` — full 40-char SHA from a real commit
- `url` — live URL returning a valid response
- `hash` — content hash from a verifiable operation
- `reproducible_steps` — steps another agent can follow to reproduce the result

String-only evidence is rejected.

---

## Session Close Gate

Session close is hard-blocked while any of the following are true:

1. Any item has status BLOCKED
2. Any HANDOFF item has no receipt_ref
3. Any REGISTER item has no target_ref
4. Any ARCHIVE item was not previously REAL

---

## Receipt Protocol

All HANDOFF completions must write a receipt:

```json
{
  "receipt_ref": "<bridge_id>-<timestamp>",
  "bridge_id": "<bridge_id>",
  "item_id": "<drain_item_id>",
  "status_at_close": "REAL",
  "evidence": { "type": "commit_id", "value": "<sha>" },
  "closed_at": "<iso8601>"
}
```

Receipts are stored in `RECEIPTS/` and referenced by `receipt_ref` on the drain item.

---

## Idempotency

All drain operations are idempotent:
- Re-running the same ARCHIVE on an already-archived item is a no-op
- Re-running REGISTER on an already-registered item updates target_ref only
- Re-running CHECKPOINT creates a new snapshot without invalidating prior ones

---

## Invariants

1. `status=REAL` requires `evidence != null && evidence.type in allowed_types`
2. `mode=ARCHIVE` requires `status=REAL && receipt_ref != null`
3. `mode=HANDOFF` requires `bridge_id != null`
4. `mode=KILL && importance in [IP, STRATEGIC]` → hard BLOCK
5. `mode=REGISTER` requires `target_ref != null`
6. PRETEND state is invalid — any item without evidence is PARTIAL

---

_Doctrine version: 1.0 | Written: 2026-05-11 | Repo: TML-4PM/the-pen_
