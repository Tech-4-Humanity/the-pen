# DRAIN DOCTRINE v1

> Canonical rules governing the DRAIN system. This file is the source of truth for all validator logic, UI enforcement, and agent behaviour.

---

## 1. What is DRAIN?

DRAIN is the session-close and work-unit resolution protocol for all TML-4PM operational sessions. Every unit of work created in a session must be explicitly drained before the session closes.

DRAIN is **not a backlog**. It is a forcing function. Every item must resolve — it cannot accumulate.

---

## 2. Modes

| Mode | Meaning | Invariant |
|---|---|---|
| `KILL` | Discard — confirmed not worth continuing | Blocked on IP or STRATEGIC importance |
| `CHECKPOINT` | Pause — work continues in a future session | Must have evidence before REAL |
| `HANDOFF` | Pass to bridge or external agent | Requires `bridge_id`; PARTIAL until `receipt_ref` received |
| `ARCHIVE` | Close permanently — work is complete | Requires `status=REAL` and `evidence` |
| `REGISTER` | Log as a discovered asset or entity | Requires `target_ref` |
| `LIBRARY` | Promote to reusable knowledge or pattern | Free-form; encourage `evidence` |

---

## 3. Status States

| Status | Meaning |
|---|---|
| `REAL` | Verified complete. Evidence confirmed. |
| `PARTIAL` | In progress or unverified. Cannot close session. |
| `BLOCKED` | Validator rule violated. Cannot proceed until resolved. |
| `ARCHIVED` | Closed and immutable. Timestamp set. |

**REAL is the only acceptable terminal state for ARCHIVE mode.**

---

## 4. Validators (V-Rules)

These rules are enforced in real-time by the UI and must be enforced by any agent or script processing drain atoms.

```
V1  ARCHIVE requires status=REAL and evidence present.
V2  KILL is blocked if importance=IP or importance=STRATEGIC.
V3  HANDOFF is PARTIAL until receipt_ref is confirmed.
V4  IP or STRATEGIC importance items are PARTIAL until evidence is typed.
V5  HANDOFF requires bridge_id to be set.
V6  REGISTER requires target_ref to be set.
```

---

## 5. Evidence Format

Evidence must be a typed reference string:

```
commit:{sha}          — git commit SHA
receipt:{bridge_id}   — bridge receipt reference
issue:{number}        — GitHub issue number
file:{path}           — file path in repo
notion:{page_id}      — Notion page ID
pr:{number}           — Pull request number
```

Freeform text is not valid evidence. Validators check for the `{type}:` prefix.

---

## 6. Session Close Gate

A session **cannot close** while:
- Any item has `status=BLOCKED`
- Any HANDOFF item is missing `receipt_ref`
- Any PARTIAL item in ARCHIVE mode exists

The close button is hard-disabled in the UI while these conditions hold.

---

## 7. Idempotency

- Item `id` is immutable after creation.
- `status=ARCHIVED` items cannot be modified.
- `closed_at` is set exactly once, at the moment of ARCHIVE transition.
- Replaying a drain operation on an already-ARCHIVED item is a no-op.

---

## 8. Economic Invariant

Work drained at `REAL` contributes to the session's economic score.
Work drained at `PARTIAL` or `BLOCKED` is gap debt — it reduces the session score.

Target: `evidence_debt / total_items < 0.15` per session.

---

## 9. Bridge Protocol

When draining via HANDOFF:

1. Set `mode=HANDOFF`, `bridge_id={session_id}`
2. Pass to bridge
3. Bridge returns `receipt_ref`
4. Enter `receipt_ref` in the item
5. Item auto-promotes to `status=REAL`
6. Session close gate clears for this item

---

## 10. Changelog

| Version | Date | Notes |
|---|---|---|
| v1 | 2026-05-12 | Initial doctrine. 6 modes, 4 states, 6 validators. |
