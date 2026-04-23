# ENFORCEMENT LIVE — the working MCP-to-GitHub path

**Status**: `REAL_AUTONOMOUS` since 2026-04-24.
**Parent commits**: `9425776984b06393b1e6c058a36a7b6bc8f13b60` (lock), `c673da8c98dc924c05acea6fb68cba95c7622ec7` (replay).

## The one working path

Any T4H actor (AI or human) that needs to commit a file to a GitHub repo under the `TML-4PM` org goes through this pipe — no GitHub connector, no HITL prompt, no PAT leaving Postgres:

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
- GETs existing sha if the file is an update
- PUTs via `public.http()` (http extension v1.6 — synchronous, reliable)
- returns `{success, status, content_sha, commit_sha, html_url}` as jsonb

## What does NOT work (and why — so the wheel is not reinvented)

| Thing | Why it fails |
|---|---|
| Chat-native GitHub connector | Triggers the HITL popup. Forbidden by GLOBAL_RULE. |
| `troy-code-pusher` Lambda | Misleading name — it updates **Lambda code**, not GitHub files. Sending `files: {path: content}` to it ships your content as Python source to a Lambda, default target `troy-bridge-runner` (retired). Registry description should be amended. |
| Old `fn_github_push` using `net.http_request` | `pg_net 0.14` dropped `net.http_put` and the 4-arg `net.http_request` signature. Returned `sql_error` via bridge. Patched on 2026-04-24 to use the `http` extension. |
| `execution_tasks` queue with `task_type: github_push` | `troy-worker`'s queue is DORMANT (Wave21 retired 2026-04-24). Nothing picks up tasks. |

## Contract for actors

1. **No direct GitHub access.** Only the path above.
2. **No credential handling on the client side.** The PAT stays in `cap_secrets`, read server-side by `fn_github_push` only.
3. **Receipts are evidence.** Every meaningful commit should drop a receipt JSON into `receipts/` following the schema in `global/RECEIPT_SCHEMA.json`.
4. **Canonical changes are audit.** Every system-state change gets an INSERT into `t4h_canonical_changes` with `evidence_ref` pointing at the receipt or commit URL.

## Test the path (read-only probe, no side effects)

```sql
-- Confirm function exists with correct signature and uses http ext
SELECT pg_get_function_arguments(p.oid), obj_description(p.oid,'pg_proc')
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname='public' AND p.proname='fn_github_push';
```

## If it breaks again

- First suspect: `http` extension version changed or `cap_secrets.GITHUB_PAT` rotated/expired.
- `SELECT extname, extversion FROM pg_extension WHERE extname='http';` — expect `1.6`.
- `SELECT key, length(value), is_deprecated, notes FROM cap_secrets WHERE key IN ('GITHUB_PAT','GITHUB_TOKEN');` — expect two active rows, both write-capable.
- Re-apply `migrations/2026-04-24_fix_fn_github_push.sql` from this repo.
