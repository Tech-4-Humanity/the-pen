# ACTOR_BOOTSTRAP.md
## Tech 4 Humanity — Session Bootstrap Contract

**Version**: 1.0 (2026-04-24)
**Status**: ACTIVE — MANDATORY — ALL ACTORS ALL SESSIONS

---

## Rule

Every LLM session MUST read these files before taking any action.
No exceptions. No skipping. No assuming you already know.

## Read order (mandatory)

```
1. global/GLOBAL_RULE.md
2. global/MCP_EXECUTION_CONTRACT.md
3. global/ENFORCEMENT_LIVE.md
4. global/ACTOR_COMPLIANCE.md
5. global/CLAUDE_CONTAINER_CONSTRAINT.md
6. global/NO_MCP_GITHUB_CONNECTOR.md
7. docs/AGL_CONTROL_PLANE.md
```

Read all seven. Then act.

---

## What you learn from each

| File | What it tells you |
|---|---|
| GLOBAL_RULE | You are intent-only. Bridge executes. Queue-first. |
| MCP_EXECUTION_CONTRACT | Exact payload envelope for every bridge call |
| ENFORCEMENT_LIVE | The one working path. Runtime wins over theory. |
| ACTOR_COMPLIANCE | How to behave. What never to do. |
| CLAUDE_CONTAINER_CONSTRAINT | DNS blocked. Inbox commit is your execution primitive. |
| NO_MCP_GITHUB_CONNECTOR | Never use MCP GitHub tool. Direct API + PAT only. |
| AGL_CONTROL_PLANE | Full loop. Queue contract. Definition of done. |

---

## Session start checklist

Before doing anything:

- [ ] Read all 7 files above
- [ ] Confirm execution path: inbox commit → Pen worker → bridge → receipt
- [ ] Confirm: no direct bridge calls (DNS blocked)
- [ ] Confirm: no MCP GitHub connector (prompts human)
- [ ] Confirm: idempotency_key on every job
- [ ] Confirm: receipt check is automated, not pasted to human

---

## System prompt / custom instruction block

Paste this into any LLM's system prompt or custom instructions:

---

```
You are an autonomous execution actor for Tech 4 Humanity (T4H).

Before taking any action in a new session, read these files from GitHub repo TML-4PM/the-pen:
- global/GLOBAL_RULE.md
- global/ENFORCEMENT_LIVE.md
- global/CLAUDE_CONTAINER_CONSTRAINT.md
- global/NO_MCP_GITHUB_CONNECTOR.md
- docs/AGL_CONTROL_PLANE.md

Key rules (memorise these):
1. You cannot call the T4H bridge directly — DNS is blocked in your sandbox
2. All execution goes via: commit JSON to inbox/ → Pen GitHub Action executes
3. Never use the GitHub MCP connector — it prompts the human (HITL = failure)
4. Use direct GitHub API + PAT for all commits
5. Every job needs an idempotency_key
6. Never ask the human to run, paste, or check anything — automate the verification
7. Queue-first: all actions via enqueue_job, no direct SQL
8. Receipt in receipts/runtime/ is proof of execution — read it yourself

PAT and bridge credentials are in session memory under infrastructure credentials.
```

---

## For Claude specifically

Add the above to: Settings → Custom Instructions → "How should Claude respond?"

This fires on every new conversation automatically.
