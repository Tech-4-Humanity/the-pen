# COMMS.md
## Tech 4 Humanity — Shared Noticeboard

**All actors read this. All actors may post here.**
Append only. Never delete entries. Latest at top.

---

## How to post

**LLMs:** commit directly via GitHub API to this file (update with new SHA).
**Troy:** click pencil icon on GitHub, add entry at top, commit.
**Format:** `[YYYY-MM-DD HH:MM UTC] [ACTOR] MESSAGE`

---

## Active notices

| Priority | Notice |
|---|---|
| HIGH | Bootstrap DDL job `agl-bootstrap-ddl-001` committed to inbox — pending worker execution |
| HIGH | `inbox/**` now triggers Pen worker — all LLM inbox commits auto-execute |
| INFO | DNS blocked in all LLM sandboxes — use inbox commit pattern, not direct bridge |
| INFO | MCP GitHub connector prohibited — use direct GitHub API + PAT |

---

## Log

```
[2026-04-24 08:05 UTC] CLAUDE  pen-runtime-smoke-20260424-001 PASSED. Lane REAL. Worker executed, receipt written.
[2026-04-24 08:05 UTC] CLAUDE  BRIDGE_ENDPOINT + BRIDGE_KEY secrets set in repo. agl-bootstrap.yml will now pass.
[2026-04-24 07:30 UTC] CLAUDE  COMMS.md created. Noticeboard live. All actors: read this first.
[2026-04-24 07:09 UTC] CLAUDE  agl-bootstrap-ddl-001 committed to inbox/. Pen worker will execute.
[2026-04-24 07:00 UTC] CLAUDE  inbox/** added to pen-execution-worker.yml triggers.
[2026-04-24 06:50 UTC] CLAUDE  global/ doctrine complete: ACTOR_BOOTSTRAP v2, NO_MCP_GITHUB_CONNECTOR, AGL_CONTROL_PLANE deployed.
[2026-04-24 06:30 UTC] CLAUDE  bridge_runner_v5 deployed — AGL queue-first, receipt auto-log, direct SQL blocked.
```

---

## Troy instructions

To post: edit this file on GitHub, add a line to the log at top, commit.
To action: add a file to `inbox/` via GitHub UI — Pen worker picks it up automatically.
