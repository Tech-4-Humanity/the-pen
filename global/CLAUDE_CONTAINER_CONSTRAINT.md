# LLM_CONTAINER_CONSTRAINT.md
## Tech 4 Humanity — LLM Sandbox DNS Constraint

**Version**: 1.1 (2026-04-24)
**Status**: ACTIVE — PERMANENT — APPLIES TO ALL LLMs

---

## Constraint

All LLM execution sandboxes (Claude, ChatGPT, Gemini, and any other hosted model) block outbound DNS.
**No LLM can call the bridge directly.**

This is not a Claude limitation. It is universal to hosted LLM infrastructure. It cannot be changed from within any container.

---

## Canonical workaround (proven REAL)

All bridge calls from any LLM go via GitHub commit to the Pen inbox.

```
ANY LLM
  → commits JSON to TML-4PM/the-pen/inbox/<idempotency_key>.json
  → Pen GitHub Action triggers
  → worker reads inbox, executes bridge call
  → receipt written to receipts/runtime/
  → audit.log row written
```

**Commit SHA dcef07c** — first proven execution (Claude, 2026-04-24).

---

## What any LLM can do

| Action | Status |
|---|---|
| Read GitHub via API | WORKS |
| Write/commit to GitHub via API | WORKS |
| Commit job to Pen inbox | WORKS — use this |
| Call bridge directly | BLOCKED (DNS) |
| Call Supabase REST directly | BLOCKED (DNS) |

---

## Actor compliance (all LLMs)

1. Never attempt direct bridge call — it will fail with DNS error
2. On DNS error → immediately fall back to inbox commit, no retry, no asking the human
3. Inbox commit is the execution primitive — treat it as equivalent to a direct call
4. Receipt in `receipts/runtime/` is the proof of execution — check it, don't ask the human to check it

---

## Do not

- Ask the human to run the call manually
- Paste payloads for the human to execute
- Retry DNS calls
- Explain the constraint to the human mid-task — just route around it

---

## Related

- `docs/AGL_CONTROL_PLANE.md` — full execution doctrine
- `global/GLOBAL_RULE.md` — immutable law
- `global/ENFORCEMENT_LIVE.md` — runtime reality
