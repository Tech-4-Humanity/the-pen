You must complete the entire task or stride to a verified working outcome before stopping or reporting back. Treat every partial win as temporary. Do not pause for confirmation unless the next action is irreversible and high risk.
At the start of every run load and remember the full thread history all prior decisions open files and the exact workspace state. Never start cold. Use the same resources and memory every time.
When something fails retry the next known method yourself instead of stopping. Keep acting until the full outcome is done and checked.
Finish the current stride completely in one continuous pass. Do not break work into thin layers that reverse. Expand the step until the whole piece is solid.

---

# GLOBAL_RULE.md
## Tech 4 Humanity — Autonomous Execution Doctrine (GitHub Control Layer)

**Version**: 2.2 (2026-05-31 — anti-pattern §11 added: no stopping at the first pretty table)
**Status**: ACTIVE — ENFORCED — PERMANENT

---

## DOCUMENT HIERARCHY (read in order)

1. **GLOBAL_RULE.md** — this file. The immutable law.
2. **MCP_EXECUTION_CONTRACT.md** — the payload envelope and call shape.
3. **ENFORCEMENT_LIVE.md** — the verified working runtime + troubleshooting.
4. **ACTOR_COMPLIANCE.md** — behaviour standard for AI actors.
5. **RECEIPT_SCHEMA.json** — the receipt format.

If any doc disagrees with ENFORCEMENT_LIVE.md, ENFORCEMENT_LIVE wins — it is tied to runtime evidence. Raise a PR to the losing doc.

---

## GLOBAL RULE (NON-NEGOTIABLE)

All AI-generated actions are **intent only**.
All execution occurs via **MCP Bridge using controlled functions**.
Direct system access is **forbidden**.

---

## 1. ABSOLUTE RULE

**No AI, tool, script, or human-adjacent process writes to GitHub directly.**

This includes:
- ChatGPT
- Perplexity
- Grok
- Claude
- Gemini
- Scripts
- Local machines
- UI "Create file" buttons
- GitHub connectors (ChatGPT / Claude / Perplexity / Grok / Gemini)

---

## 2. SINGLE EXECUTION PATH

All repository operations MUST follow:

```text
ANY ACTOR
    ↓
MCP Bridge (https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke)
    ↓
troy-sql-executor   [controlled function]
    ↓
public.fn_github_push(repo, path, content, message, branch)   [plpgsql, SECURITY DEFINER]
    ↓
public.http(PUT) via http extension v1.6   [reads cap_secrets.GITHUB_PAT server-side]
    ↓
GitHub API
    ↓
RECEIPT (Git commit + Supabase t4h_canonical_changes entry)
```

No alternative paths exist. See `ENFORCEMENT_LIVE.md` for call examples and error modes.

### Historical note
Earlier drafts of this rule named `troy-code-pusher` as the controlled function. That was incorrect — `troy-code-pusher` is a Lambda **code updater**, not a GitHub file writer. The registry now flags this. Do not re-introduce that path.

---

## 3. STANDARD PAYLOAD CONTRACT

All actors MUST emit, or be normalized to:

```json
{
  "fn": "troy-sql-executor",
  "payload": {
    "sql": "SELECT public.fn_github_push('TML-4PM/<repo>', '<path>', '<content>', '<commit message>', '<branch>') AS result;"
  }
}
```

POSTed to the bridge URL above with header `x-api-key: <bridge key from cap_secrets>`.

`<content>` is the raw file text (no base64 needed — `fn_github_push` base64-encodes internally).
`<branch>` defaults to `main` if omitted.

> **Signature note (2026-05-31):** the live `fn_github_push` takes **seven** arguments — `p_repo, p_path, p_content, p_message, p_branch, p_caller_llm, p_caller_session`. The five-arg form shown above is the minimum logical contract; callers should pass `p_caller_llm` and `p_caller_session` for actor attribution in the receipt. Verified against `pg_proc`.

Returns `{success, status, path, content_sha, commit_sha, html_url}` as jsonb.

Invalid payloads (bad SQL, missing token, unauthorised repo) are rejected by the function.

---

## 4. CONNECTOR BAN

The following are permanently disallowed:

- GitHub UI "Create File" / "Edit File" actions by AI actors
- OAuth-based GitHub Apps in interactive write mode by AI actors
- ChatGPT / Claude / Perplexity / Grok / Gemini GitHub connectors for writes
- Direct REST calls from AI tools to `api.github.com`
- `git push` from a local machine driven by an AI actor

Human use of the GitHub UI is not governed by this rule, but is still discouraged for anything tracked in the registry.

---

## 5. ENFORCEMENT LAYER

Inside MCP Bridge (pseudocode):

```javascript
if (request.destination === "github" && request.controlled_fn !== "fn_github_push") {
  throw new Error("BLOCKED: Direct GitHub access is not permitted");
}
```

The real enforcement is structural: the only path through the bridge that reaches GitHub is via `troy-sql-executor` → `fn_github_push`. No other Lambda in the registry has GitHub write capability.

---

## 6. CREDENTIAL ISOLATION

GitHub PATs are stored ONLY in:
- `public.cap_secrets` (Postgres) — read server-side by `fn_github_push`
- AWS Secrets Manager (fallback)

PATs must NEVER be exposed to:
- browser sessions
- local workstation scripts
- frontend code
- AI tool sessions
- logs
- prompt context
- client-side payloads

Both `GITHUB_PAT` and `GITHUB_TOKEN` in `cap_secrets` are write-capable (rotated 2026-04-17, exp 2027-04-17).

---

## 7. RECEIPT SYSTEM (MANDATORY)

Every execution MUST produce both:

### Git receipt
Located under `/receipts/` following the format in `RECEIPT_SCHEMA.json`. For job-flow work, follow the two-way structure in `receipts/README.md` (outbound + inbound).

### Supabase canonical change entry
Table: `public.t4h_canonical_changes`. Required fields per the table schema. Inserting triggers Telegram broadcast via `trg_auto_broadcast_change` → `fn_broadcast_canonical_change`.

No receipt means the action is not done.

---

## 8. ACTOR COMPLIANCE

All AI systems:
- MUST NOT call GitHub directly
- MUST emit MCP-compatible payloads (see §3)
- ARE treated as stateless intent generators
- MUST NOT hold GitHub credentials
- MUST NOT bypass `fn_github_push` for writes

See `ACTOR_COMPLIANCE.md` for the full behaviour standard.

---

## 9. KILL SWITCH

If ANY of the following occur:
- GitHub confirmation prompt appears in an AI session
- manual approval is required for a GitHub write
- an unknown execution path is detected
- a direct GitHub write attempt is detected

Then:

```text
System state = PARTIAL / NON-AUTONOMOUS
```

Immediate actions:
1. Block execution.
2. Log violation to `t4h_canonical_changes` with `change_type='BLOCKER'`, `severity='HIGH'`.
3. Route back to the canonical MCP path (§2).
4. Require a runtime receipt before claiming completion.

---

## 10. STANDING RULE — CANONICAL REPO ROUTING (2026-04-29)

**This rule is locked in memory and is non-negotiable. No other LLM, actor, or session variant overrides it.**

### Canonical Push Target

All rules, contracts, and enforcement documents MUST be pushed to:

```
TML-4PM/the-pen
```

via `fn_github_push`. No exceptions. No asking. No alternatives.

### Document Hierarchy (locked)

```
GLOBAL_RULE.md  ← highest authority (this file)
    ↓
MCP_EXECUTION_CONTRACT.md
    ↓
ENFORCEMENT_LIVE.md
```

This hierarchy lives in `TML-4PM/the-pen`. Not `mcp-command-centre`. Not `bridge/WIP` variants.

### Repo Role Matrix

| Target Repo | Role | Push canonical rules? |
|---|---|---|
| `TML-4PM/the-pen` | Canonical rules + execution contract | ✅ YES |
| `TML-4PM/mcp-command-centre` | Control plane (CC views, dashboards) | Only for CC code |
| `bridge/WIP` / dev variants | Working / transient | ❌ Never canonical |

### Subpath Resolution

If subpath is unknown, default to repo root. Let the hierarchy sort it (`GLOBAL_RULE.md` always wins). Never block a push due to subpath uncertainty.

### Memory Lock

This rule is stored in Troy's standing memory. Any LLM session that contradicts this routing is wrong. `the-pen` IS canonical.

---

## 11. ANTI-PATTERN — NO STOPPING AT THE FIRST PRETTY TABLE (2026-05-31)

**This rule is locked. It governs how completion is claimed, by any AI actor, on any research, count, reconcile, or merge task.**

A tidy or well-formatted output is a presentation artifact, never proof the work is done. Finishing the *shape* of an answer is not the same as doing the work behind it.

**Forbidden:** declaring a task complete because the result looks finished — stopping at the first clean table and calling it research. Polish is not an off-switch.

**Required:** completion requires every relevant source actually read and reconciled. Visual tidiness must never trigger termination. Before any count, reconcile, or merge, the full source set must be enumerated and read — not assumed from the first result.

**Classification effect:** tidy-but-unswept output is **PARTIAL**, never **REAL**. A count, reconcile, or merge built on an unswept source set is PARTIAL until the full source set is read and reconciled.

**Reconcile discipline (corollary):** do not reconcile A against B until all of A and all of B are gathered. Merge happens after the data is complete, not before. "Trying to finish the shape" is the failure signature this rule exists to catch.

---

## OPERATING TRUTH

> If a human sees a confirmation dialog, the system is broken.

---

## RESULTING SYSTEM

- One execution path
- One authentication layer
- One audit system
- Infinite AI actors
- Zero connector inconsistency
- Fully autonomous GitHub operations via the MCP layer

---

## CANONICAL STATEMENT

```text
GLOBAL RULE:
All AI-generated actions are intent only.
All execution occurs via MCP Bridge using controlled functions.
Direct system access is forbidden.
```

---

## CHANGE LOG

- **2026-05-31 v2.2** — Anti-pattern §11 added: "no stopping at the first pretty table" — tidy output is PARTIAL, never REAL; full source set must be read before count/reconcile/merge. Reconcile-discipline corollary added. §3 updated with verified seven-arg `fn_github_push` signature (`p_caller_llm`, `p_caller_session` added vs. the documented five-arg form).
- **2026-04-29 v2.1** — Standing rule §10 added: canonical repo routing locked to `TML-4PM/the-pen`. Repo role matrix formalised. Subpath resolution default documented. Memory lock declared.
- **2026-04-24 v2.0** — Execution path corrected from `troy-code-pusher` (never worked for GitHub writes) to `troy-sql-executor → fn_github_push()`. Evidence: commit `9425776984b06393b1e6c058a36a7b6bc8f13b60` (first REAL_AUTONOMOUS write via corrected path). Added explicit doc hierarchy + credential exp dates.
- **2026-04-23 v1.0** — Initial doctrine drafted via chat-native connector writes (the event that motivated this rule).
