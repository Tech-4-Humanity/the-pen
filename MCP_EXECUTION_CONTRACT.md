# MCP Execution Contract

```yaml
doc:
  version: "1.0"
  parent: "GLOBAL_RULE.md"           # GLOBAL_RULE wins on conflict for principles
  loses_to: "ENFORCEMENT_LIVE.md"     # ENFORCEMENT_LIVE wins on conflict for runtime
  scope: "Wire-level contract for every bridge-callable Lambda"
  source_of_truth: "public.mcp_lambda_registry WHERE is_callable=true"
  last_change: "2026-04-30"
```

This document does **not** enumerate every callable Lambda. The registry does that, live. This document defines the **envelope classes** every operator and every LLM must use to call them, plus the canonical operator-facing handful that are exercised daily.

---

## 1. Bridge endpoint

```yaml
endpoint:   "https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke"
method:     "POST"
content:    "application/json"
auth:       "x-api-key header"
key_source: "cap_secrets WHERE key='BRIDGE_API_KEY' AND is_canonical=true AND is_deprecated=false"
fallback:   "lambda:GetFunctionConfiguration on mcp-bridge-invoke-handler (env)"
hardcoded:  "FORBIDDEN — flag-fix 2026-04-29 proved canonical/deprecated flags can invert silently"
```

Allow-list is dynamic: the bridge consults `mcp_lambda_registry.is_callable=true` per invocation. A function not in the registry, or with `is_callable=false`, returns a non-200 regardless of envelope correctness.

---

## 2. The two envelope classes

Every callable falls into exactly one of these. The variant is **not** in `mcp_lambda_registry.invocation_pattern` (that column describes the trigger type, not the wire shape). Variant is determined by the function's handler code; the truth table below is the authoritative mapping.

### 2.1 Class A — NESTED

```json
{
  "fn":      "<function_name>",
  "payload": { /* function-specific args */ }
}
```

Used when the handler has internal sub-routing on `payload.*` keys. Currently used by: **`troy-sql-executor`** (only). Operators must wrap SQL in `payload.sql`. Adding any sibling key to `payload` triggers `400 sql_error` from the executor.

### 2.2 Class B — TOP-LEVEL

```json
{
  "fn":             "<function_name>",
  "<arg-1>":        "<value>",
  "<arg-2>":        "<value>",
  "...":            "..."
}
```

All function-specific args sit at the top level alongside `fn`. No `payload` wrapper. Used by every other operator-facing function: `troy-lambda-deploy`, `troy-cfn-deployer`, `troy-code-pusher`, `forge.run_trial_sweep`, and most EventBridge/queue-fed Lambdas.

### 2.3 Truth table — operator canonicals

| function_name | class | required keys | response key for OK |
|---|---|---|---|
| `troy-sql-executor` | A | `payload.sql` (single statement, trailing `;`, no BEGIN/COMMIT) | `success: true` |
| `troy-lambda-deploy` | B | `function_name`, `zip_base64`, `runtime`, `handler`, `memory_size`, `timeout`, `role` | `status: ACTIVE` |
| `troy-cfn-deployer` | B | `action: 'deploy'`, `stack_name`, `template` (base64-encoded YAML/JSON), `capabilities[]` | `stack_status: CREATE_COMPLETE \| UPDATE_COMPLETE` |
| `troy-code-pusher` | B | `target` (Lambda fn-name), `files: {<filename>: <code>}` — UPDATE-only | `updated: true` |
| `forge.run_trial_sweep` | B | sweep params (no `seed_and_sweep`); inputs read from `s3://<forge-bucket>/trials/input/` | receipt JSON in same bucket |
| Any `*-broadcast`, `*-poster`, etc. | B | function-specific | function-specific |

`troy-bridge-runner` is **retired** (`is_callable=false`, 410-Gone stub). Do not call.

### 2.4 Registry inconsistency to fix (not yet patched)

`mcp_lambda_registry.callable_reason` for `troy-sql-executor` claims the contract is `{fn, sql}`. **It is not.** Empirically `{fn, sql}` returns `400 fn required` or runs without seeing the SQL. Correct contract is `{fn, payload:{sql}}` (Class A). The registry row should be updated; this doc is the canonical source until it is.

---

## 3. Response shape

### 3.1 Success — synchronous (DIRECT / SYNC pattern)

```json
{
  "success": true,
  "rows":    [ /* result rows for SELECT */ ],
  "count":   1,
  "command": "SELECT" | "INSERT" | "UPDATE" | ...
}
```

### 3.2 Success — async (ASYNC / QUEUE / EVENTBRIDGE pattern)

```json
{
  "ok": true,
  "request_id": "<uuid>",
  "queued_at":  "<iso8601>"
}
```
Outcome lands later in the function's own evidence table (varies by function).

### 3.3 Failure shapes

| HTTP | body | meaning | action |
|---|---|---|---|
| 401 | `{"ok":false,"error_code":"UNAUTHORIZED","request_id":"..."}` | bad / missing `x-api-key` | re-resolve key from `cap_secrets`, do not retry blindly |
| 400 | `{"error":"fn required"}` | envelope key wrong (used `lambda_name` etc) | fix to `fn` |
| 400 | `{"error_code":"sql_error","command":null}` | masked PG error from `troy-sql-executor` | re-fire the same SQL through PostgREST `run_sql` RPC for the real message |
| 403 | from API Gateway | rate limit / WAF | back off, then retry once |
| 502/504 | from Lambda | function timeout or crash | check `last_invocation_status` in registry; do not retry destructive writes without checking idempotency |

---

## 4. Canonical examples (copy-paste ready)

### 4.1 SQL — read

```bash
curl -sS -X POST "$BRIDGE" \
  -H "Content-Type: application/json" -H "x-api-key: $BRIDGE_KEY" \
  -d '{"fn":"troy-sql-executor","payload":{"sql":"SELECT now() AS utc;"}}'
```

### 4.2 SQL — write (and verify)

INSERT/UPDATE work, **but** `troy-sql-executor` masks `RETURNING` (returns `count:1, rows:[]`). Always verify the write through PostgREST direct read:

```bash
# 1. fire INSERT via bridge
curl -sS -X POST "$BRIDGE" \
  -H "Content-Type: application/json" -H "x-api-key: $BRIDGE_KEY" \
  -d '{"fn":"troy-sql-executor","payload":{"sql":"INSERT INTO foo(...) VALUES(...) RETURNING id;"}}'
# 2. verify via REST (the RETURNING you needed)
curl -sS "$S1_URL/rest/v1/foo?<filter>&select=id,created_at" \
  -H "apikey: $S1_KEY" -H "Authorization: Bearer $S1_KEY"
```

### 4.3 GitHub file write

```sql
-- via troy-sql-executor (Class A)
SELECT fn_github_push(
  'TML-4PM/the-pen',          -- p_repo
  'path/to/file.md',          -- p_path
  $body$ ...content... $body$,-- p_content (dollar-quoted to avoid escape gymnastics)
  'commit message',           -- p_message
  'main',                     -- p_branch (default)
  'claude-opus-4-7',          -- p_caller_llm  ← always pass
  'session-ref-string'        -- p_caller_session  ← always pass
);
```
Returns: `{path, status, success, html_url, commit_sha, content_sha}`.

### 4.4 Lambda code update (NOT GitHub)

```bash
# troy-code-pusher updates Lambda *function code*, not repo files.
curl -sS -X POST "$BRIDGE" \
  -H "Content-Type: application/json" -H "x-api-key: $BRIDGE_KEY" \
  -d '{
    "fn":     "troy-code-pusher",
    "target": "my-existing-lambda-fn",
    "files":  {"index.mjs": "<code-string>"}
  }'
```

`create_if_missing` is **ignored**. To create a new Lambda, use `troy-lambda-deploy` instead.

### 4.5 Lambda deploy (CREATE)

```bash
curl -sS -X POST "$BRIDGE" \
  -H "Content-Type: application/json" -H "x-api-key: $BRIDGE_KEY" \
  -d '{
    "fn":            "troy-lambda-deploy",
    "function_name": "new-fn-name",
    "zip_base64":    "<base64-of-zip>",
    "runtime":       "python3.12",
    "handler":       "app.handler",
    "memory_size":   256,
    "timeout":       30,
    "role":          "arn:aws:iam::140548542136:role/<role-name>"
  }'
```

### 4.6 CFN deploy (IAM-capable, atomic)

```bash
curl -sS -X POST "$BRIDGE" \
  -H "Content-Type: application/json" -H "x-api-key: $BRIDGE_KEY" \
  -d '{
    "fn":           "troy-cfn-deployer",
    "action":       "deploy",
    "stack_name":   "my-stack",
    "template":     "<base64-encoded-cfn-template>",
    "capabilities": ["CAPABILITY_NAMED_IAM"]
  }'
```

`lovable-mcp-client` cannot mutate IAM directly; the canonical IAM mutation path is CFN through this fn (verified atomic OIDC + Role + InlinePolicy on 2026-04-29).

---

## 5. Idempotency contract

Every write that can be safely re-run must be re-runnable. Three patterns are sanctioned:

| pattern | example | notes |
|---|---|---|
| `WHERE NOT EXISTS (...)` | INSERT into `t4h_canonical_changes` guarded by `memory_key` | preferred for ledger writes |
| `ON CONFLICT (...) DO ...` | upserts into registries | requires a unique constraint to actually exist |
| Content-addressed | `fn_github_push` (commit only changes if SHA changes) | implicit — no client work needed |

Naked `INSERT` without a guard is **not** idempotent and will create duplicates on retry. Use `memory_key` (text) on `t4h_canonical_changes` as the natural session-level idempotency key.

---

## 6. Single-statement contract

`troy-sql-executor` does **not** support:

- Multiple statements in one payload (split DDL into separate bridge calls).
- `BEGIN` / `COMMIT` / explicit transaction blocks.
- Statements without a trailing `;` (silently returns `rows:[]`).

CTEs (`WITH ... AS (...) INSERT ... RETURNING ...`) are one statement and are fully supported, which is the right tool for any "do A then B then C atomically" requirement.

---

## 7. Discovering callable functions

```sql
SELECT function_name, invocation_pattern, callable_reason, last_invocation_status
FROM   public.mcp_lambda_registry
WHERE  is_callable = true
ORDER  BY function_name;
```

373 rows as of 2026-04-30. Most are seeded but unused (`invocation_count = 0`). Top operator-touched: `rb-campaign-poster`, `troy-forge-trial-sweep`, `troy-gdrive-migrator`, plus the canonicals in §2.3.

---

## 8. Forbidden patterns

- Hardcoded bridge keys in code, docs, or commits.
- `function_name` / `lambda_name` / `action` as the top-level routing key. The only routing key is `fn`.
- Multi-statement SQL through `troy-sql-executor`.
- Trusting `count` from `troy-sql-executor` to mean "rows are now visible to my next read" — the executor commits, but the next read should still go through PostgREST direct or a fresh bridge call.
- Calling retired functions. Check `is_callable` before invoking.

---

## 9. When this doc loses

If `ENFORCEMENT_LIVE.md` (runtime) contradicts this doc, ENFORCEMENT_LIVE wins. If `GLOBAL_RULE.md` (law) contradicts a principle here, GLOBAL_RULE wins. This doc is the wire format — it does not override either.

End.
