# CLAUDE_CONTAINER_CONSTRAINT.md
## Tech 4 Humanity — Claude Container DNS Constraint

**Version**: 1.0 (2026-04-24)
**Status**: ACTIVE — PERMANENT CONSTRAINT

---

## Constraint

Claude's execution sandbox blocks outbound DNS.
**Claude cannot call the bridge directly.**

This is an Anthropic infrastructure decision. It cannot be changed from within the container.

---

## Canonical workaround (proven REAL)

All bridge calls from Claude go via GitHub commit to the Pen inbox.

```
Claude
  → commits JSON to TML-4PM/the-pen/inbox/<key>.json
  → Pen GitHub Action triggers
  → worker reads inbox file
  → executes bridge call
  → writes receipt to receipts/runtime/
  → audit.log row written
```

**Commit SHA dcef07c** — first proven execution of this pattern (2026-04-24).

---

## What Claude can do directly

| Action | Method |
|---|---|
| Read GitHub files | GitHub API (works) |
| Write GitHub files | GitHub API (works) |
| Commit to inbox | GitHub API (works) |
| Call bridge directly | BLOCKED |
| Call Supabase REST | BLOCKED |

---

## Do not ask Claude to

- Unblock DNS (not possible)
- Call the bridge directly (will fail)
- Run curl against Supabase (will fail)

Route all execution through the Pen inbox commit pattern.

---

## Actor compliance

All actors (Claude instances, Mac, cron) must know this constraint.
If a Claude session attempts a direct bridge call and gets DNS error → immediately fall back to inbox commit. No retry loop. No asking the human.
