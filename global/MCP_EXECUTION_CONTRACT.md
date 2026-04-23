# MCP_EXECUTION_CONTRACT.md
## Tech 4 Humanity — Single Execution Contract

**Version**: 2.0 (2026-04-24 — envelope corrected to match runtime)
**Status**: ACTIVE — REQUIRED FOR ALL ACTORS

All actors are intent generators only. Execution occurs through MCP Bridge controlled functions.

## Canonical Execution Path

```text
ANY ACTOR
  → MCP BRIDGE (API Gateway)
  → troy-sql-executor (Lambda)
  → public.fn_github_push(repo, path, content, message, branch) (plpgsql)
  → public.http(PUT) via http ext v1.6
  → GitHub API
  → RECEIPT (git commit + Supabase canonical change)
```

## Required Envelope (HTTP POST to the bridge)

**URL**: `https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke`
**Headers**: `x-api-key: <bridge key>`, `Content-Type: application/json`
**Body**:

```json
{
  "fn": "troy-sql-executor",
  "payload": {
    "sql": "SELECT public.fn_github_push('TML-4PM/the-pen', 'path/in/repo.ext', 'complete file content', 'auto: execution', 'main') AS result;"
  }
}
```

Notes:
- `<content>` is raw UTF-8 text. `fn_github_push` base64-encodes internally. Do NOT pre-encode on the client side.
- Use dollar-quoting (`$TAG$…$TAG$`) around content that contains single quotes or mixed escapes. Pick a tag that cannot appear in the content.
- `<branch>` defaults to `main`; pass explicitly if writing to another branch.
- Extra fields alongside `sql` trigger `sql_error`. Keep the `payload` object minimal.
- If the file already exists at `path`, `fn_github_push` performs an update (fetches the existing `sha` first). The same call handles create and update.

## Returned jsonb shape

```json
{
  "success": true,
  "status": 201,
  "path": "path/in/repo.ext",
  "content_sha": "<blob sha>",
  "commit_sha": "<commit sha>",
  "html_url": "https://github.com/TML-4PM/the-pen/blob/main/path/in/repo.ext"
}
```

On failure:

```json
{
  "success": false,
  "status": <http status>,
  "body": "<first 1000 chars of GitHub response>"
}
```

## Rejection Rules

Reject any request that:
- bypasses `troy-sql-executor` (no direct API Gateway invoke of other Lambdas for GitHub writes)
- carries a PAT in the payload (credentials stay in `cap_secrets`)
- lacks a receipt plan (either under `/receipts/` or as a `t4h_canonical_changes` entry)
- writes without a declared actor in the accompanying canonical change entry
- writes to a repo outside the `TML-4PM/*` org (explicit allow-list would be a separate approval)

## Runtime Proof

Every successful write MUST produce:
- Git `commit_sha` (in the jsonb response)
- Git receipt under `/receipts/` OR an equivalent `t4h_canonical_changes.evidence_ref` entry
- Reality classification: `REAL`, `PARTIAL`, or `FAILED` (never `PRETEND`)

## What this contract replaces

The v1 contract specified `troy-code-pusher` with an `files: [{path, content}]` array envelope. That was incorrect — `troy-code-pusher` is a Lambda code updater, not a GitHub file writer. See `ENFORCEMENT_LIVE.md` for the discovery trail and proof commits.

## Status

ACTIVE — REQUIRED FOR ALL ACTORS
