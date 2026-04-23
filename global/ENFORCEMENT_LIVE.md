# ENFORCEMENT LIVE — the working MCP→GitHub path

**Version**: 2026-04-24
**Role in the hierarchy**: runtime reality + troubleshooting guide for the path specified by `GLOBAL_RULE.md` §2 and `MCP_EXECUTION_CONTRACT.md`.

If doctrine and runtime disagree, this file wins (runtime always wins over theory). Raise a PR to the losing doc.

## The one working path

```
POST https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke
Header: x-api-key: <bridge key from cap_secrets>
Body:
{
  "fn": "troy-sql-executor",
  "payload": {
    "sql": "SELECT public.fn_github_push('<owner>/<repo>','<path>','<raw text content>','<commit msg>','<branch>') AS result;"
  }
}
```

`fn_github_push` handles everything server-side:
- reads `GITHUB_PAT` from `cap_secrets`
- base64-encodes content
- GETs existing `sha` if the file is an update
- PUTs via `public.http()` (http extension v1.6 — synchronous, reliable)
- returns `{success, status, content_sha, commit_sha, html_url}` as jsonb

## Proof receipts (REAL_AUTONOMOUS achieved)

| Commit | Purpose |
|---|---|
| `9425776984b06393b1e6c058a36a7b6bc8f13b60` | First REAL_AUTONOMOUS write (`receipts/global-rule-lock.json`) |
| `c673da8c98dc924c05acea6fb68cba95c7622ec7` | Replay via patched function (`receipts/global-rule-lock-replay-01.json`) |
| `6f0fe96a5601bdc728ded4ecdc1093e647c1ccd4` | Migration SQL durability (`migrations/2026-04-24_fix_fn_github_push.sql`) |
| `7ddb6052db6aca51eaabf7095ddad1128186bac3` | First version of this doc |

Canonical changes: `t4h_canonical_changes.id=384` (flip) and `id=388` (replay+durable). Both `broadcast_ok=true`.

## What does NOT work (and why — so the wheel is not reinvented)

| Thing | Why it fails |
|---|---|
| Chat-native GitHub connector | Triggers the HITL popup. Forbidden by GLOBAL_RULE. |
| `troy-code-pusher` Lambda | Misleading name — it updates **Lambda code**, not GitHub files. Sending `files: {path: content}` ships your content as Python source to a Lambda, default target `troy-bridge-runner` (retired). Registry description now flags this. |
| Old `fn_github_push` using `net.http_request` | `pg_net 0.14` dropped `net.http_put` and the 4-arg `net.http_request` signature. Returned `sql_error` via bridge. Patched 2026-04-24 to use the `http` extension. Migration in this repo. |
| `execution_tasks` queue with `task_type: github_push` | `troy-worker`'s queue is DORMANT (Wave21 retired 2026-04-24). Nothing picks up tasks. |

## Contract for actors

1. **No direct GitHub access.** Only the path above.
2. **No credential handling on the client side.** PATs stay in `cap_secrets`, read server-side by `fn_github_push` only.
3. **Receipts are evidence.** For job-flow work, follow the two-way structure in `receipts/README.md`. For doctrinal / system-state changes, a flat receipt at `/receipts/<id>.json` + a `t4h_canonical_changes` entry is sufficient.
4. **Canonical changes are audit.** Every system-state change gets an INSERT into `t4h_canonical_changes` with `evidence_ref` pointing at the receipt or commit URL.

## Test the path (read-only probe, no side effects)

```sql
-- Confirm function exists with correct signature and uses http ext
SELECT pg_get_function_arguments(p.oid), obj_description(p.oid,'pg_proc')
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname='public' AND p.proname='fn_github_push';
-- Expect: 5-arg signature, comment dated 2026-04-24
```

```sql
-- Confirm http extension version
SELECT extname, extversion FROM pg_extension WHERE extname='http';
-- Expect: http | 1.6
```

```sql
-- Confirm both tokens present, write-capable, not expired
SELECT key, length(value), is_deprecated, notes FROM cap_secrets WHERE key IN ('GITHUB_PAT','GITHUB_TOKEN');
-- Expect: two rows, both active, both 93 chars, notes indicate write-capable exp 2027-04-17
```

## Common error signatures

| Symptom | Likely cause | Fix |
|---|---|---|
| `sql_error` with no detail | Either a SQL syntax error in the payload, or a runtime error inside a called function that the executor can't surface | Wrap the call in a `DO` block and log `SQLERRM/SQLSTATE` to a temp table, then SELECT it back |
| `{"success": false, "status": 404, "body": "Not Found"}` | Repo path typo, wrong branch, or PAT doesn't have access to that repo | Check repo slug; verify PAT scope |
| `{"success": false, "status": 401}` | PAT invalid/revoked | Rotate PAT in `cap_secrets`; update `notes` |
| `{"success": false, "status": 422}` | Branch conflict or sha mismatch on update | Retry (the function fetches current sha each call, so a second try usually wins) |
| Bridge returns `DNS cache overflow` on first call | Sandbox egress proxy state, not the bridge | Retry once after a short pause. If persistent, `cat /etc/resolv.conf` + pin the bridge IP in `/etc/hosts` |

## If the function breaks again

- First suspect: `http` extension version changed or `cap_secrets.GITHUB_PAT` rotated/expired.
- `SELECT extname, extversion FROM pg_extension WHERE extname='http';` — expect `1.6`.
- `SELECT key, length(value), is_deprecated, notes FROM cap_secrets WHERE key IN ('GITHUB_PAT','GITHUB_TOKEN');` — expect two active rows, both write-capable.
- Re-apply `migrations/2026-04-24_fix_fn_github_push.sql` from this repo.
- Log a canonical change with `change_type='BLOCKER'` if the path is down.

## Relationship to other global docs

- **GLOBAL_RULE.md** — the law (no direct access, MCP only). Abstract and stable.
- **MCP_EXECUTION_CONTRACT.md** — the payload envelope (cross-reference for shape).
- **ACTOR_COMPLIANCE.md** — behaviour standard for AI actors.
- **RECEIPT_SCHEMA.json** — shape of a receipt.
- **ENFORCEMENT_LIVE.md** (this file) — the verified runtime path + troubleshooting. If the other docs disagree with this file, this file is right by definition (it's tied to commits).
