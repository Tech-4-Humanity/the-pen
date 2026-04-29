# Session Findings — 2026-04-29

**Author:** claude
**Session:** troy-2026-04-29-attribution-fix
**Status:** REAL — all findings verified live this session

## 1. Bridge envelope contract (per-Lambda)

| Lambda | Envelope | Notes |
|---|---|---|
| `troy-sql-executor` | **nested** `{fn, payload:{sql}}` | only callable using payload |
| `troy-lambda-deploy` (CREATE) | top-level | `{fn, function_name, zip_base64, runtime, handler, memory_size, timeout, role}` |
| `troy-code-pusher` (UPDATE-only) | top-level | `create_if_missing` is **ignored**; falls through to `UpdateFunctionCode` and 404s |
| `troy-cfn-deployer` | top-level | `template` = base64-encoded string. Error msgs mentioning `template_body`/`template_body_b64` are misleading |
| `forge.run_trial_sweep` | top-level | no `payload`, no `seed_and_sweep` param. Input under `s3://<forge-bucket>/trials/input/` |

**Probe before guessing:** `{fn:"X", action:"VERSION_PROBE_v2"}` top-level → response `"unknown action"` = top-level was the right shape.

## 2. troy-sql-executor masks SQLERRM — root cause of "8-retry flake"

| Layer | Behaviour |
|---|---|
| `public.run_sql` (Postgres RPC) | ✅ Captures `SQLERRM` + `SQLSTATE`, returns `{"error":"...","sqlstate":"22P02"}` |
| `troy-sql-executor` Lambda Python wrapper | ❌ Strips diagnostic, returns generic `{"success":false,"error":"sql_error","command":null}` HTTP 400 |
| Caller (LLM session) | ❌ Sees only `"sql_error"`, retries up to 8× expecting flake, hits same deterministic failure |

**Smoking-gun cross-check (today):**

```
Bridge (troy-sql-executor):  HTTP 400  {"success":false,"error":"sql_error","command":null}
PostgREST direct (run_sql):  HTTP 200  {"error":"invalid input value for enum gov_audience: \"gemini\"","sqlstate":"22P02"}
```

Same SQL, same RPC. Lambda has the real error in hand and drops it.

**Why selftest 11/11 lies:** runs `SELECT 1`, `SHOW`, `EXPLAIN` — none trip enum/check/trigger error paths. Real-world INSERTs into typed columns trip them. Selftest needs a known-bad payload to catch response-shape regressions.

**Fix shape (Lambda Python handler):**

```python
# current — drops SQLERRM
if 'error' in result.data:
    return 400, {"success": False, "error": "sql_error"}

# should be
if isinstance(result.data, dict) and 'error' in result.data:
    return 400, {
        "success": False,
        "error": result.data['error'],            # real SQLERRM
        "sqlstate": result.data.get('sqlstate'),  # 22P02 etc
        "error_type": "sql_error"                 # backwards compat
    }
```

GATED — awaiting Troy go to push patch. Source repo not registered for this Lambda; need location.

## 3. t4h_canonical_changes column traps

| Column | Type | Accepts | Don't put |
|---|---|---|---|
| `audiences` | `gov_audience[]` (enum) | `ENG_AUDIT, KB_SOP, TRAINING_CORPUS, RDTI_AUDIT, BOARD, NEWSLETTER, ADR, REGULATOR` | LLM names — fail with `22P02` |
| `broadcast_to` | `text[]` | LLM names (`claude`, `gemini`, `grok`, `coax-p`) | enum values |
| `change_type` | text + check constraint | `MILESTONE, SCHEMA_CHANGE, BUSINESS_CHANGE, IP_CHANGE, PRODUCT_CHANGE, FINANCIAL_CHANGE, SYSTEM_CHANGE, BLOCKER, DECISION` | `SCHEMA` (use `SCHEMA_CHANGE`) |
| `severity` | text + check | `LOW, NORMAL, HIGH, CRITICAL` | lowercase |

## 4. mcp_lambda_registry cascade

`trg_lambda_registry_sync` cascades INSERTs to `core.registry_entities`, which fires the S13 RDTI gate (`t_require_rdti_tag`). The cascade does **not** pass `metadata.is_rd` / `metadata.project_code` through, so the registry INSERT fails opaquely.

**Pattern:** pre-create the `core.registry_entities` row with `metadata.is_rd=true` + `metadata.project_code='OUTRD'` (or relevant code) **before** the registry insert. The cascade then `WHERE NOT EXISTS` skips and the parent insert lands clean.

## 5. github_push_log wired (this session)

New audit table `public.github_push_log` (16 cols, RLS, 4 indexes). `fn_github_push` gains 2 optional params: `p_caller_llm` (default `'unknown'`), `p_caller_session` (default `null`). Best-effort INSERT after PUT — logging failure never breaks the push.

View `public.v_github_push_log_daily` groups by Australia/Sydney day × `caller_llm` × ok/fail/repos.

**Caller contract for other LLMs:**

```sql
SELECT public.fn_github_push(
  p_repo := 'TML-4PM/<repo>',
  p_path := '<path>',
  p_content := '<content>',
  p_message := '<commit msg>',
  p_caller_llm := 'gemini',                     -- claude / gemini / grok / coax-p / coax-x / coax-a / copilot
  p_caller_session := 'gemini-2026-04-29-rdti'  -- session anchor
);
```

Live verification commit: [`beef9f50`](https://github.com/TML-4PM/the-pen/commit/beef9f50ff33fa5e6e532d79b1704a7653d11258), audit row id=1, GitHub receipt cross-checked OK.

## 6. forge.run_trial_sweep contract

- Envelope: top-level (params alongside `fn`, no `payload` wrapper)
- Do NOT pass `seed_and_sweep` parameter
- Input data → `s3://<forge-bucket>/trials/input/`
- Bucket currently empty apart from prior run's fixture + receipt
- Drop real input under `trials/input/` then re-fire to process actual data
- Receipts land in same bucket

## 7. Cleanup pending (GATED)

Test rows from today's diagnostic bisect remain in `public.t4h_canonical_changes`:

```
bisect_a, bisect_b, bisect_c, bisect_e, bisect_f, bisect_g (failed)
enum_invalid_gemini (failed), enum_valid_board, enum_valid_with_md
postgrest_probe (failed), dup_test, dup_test_v2 (failed)
```

Awaiting decision: archive (set `sealed=true` + tombstone tag) vs delete.

## 8. Carried-forward open blockers (Troy action)

- BAS FY25-26 Q1+Q2 **OVERDUE** — lodge immediately
- Div7A MYR $72,299 due 30 Jun 2026 — sign agreement
- EC2 IAM role `t4h-ec2-bridge-runner` — manual console creation + instance profile attach
- `AmazonSESFullAccess` attachment to `lovable-mcp-client`
- `sam deploy` + S3 bucket create for LLM-JSON
- `GITHUB_PAT` rotation due 2026-05-03
- Patch `troy-sql-executor` to pass through SQLERRM (source repo unknown)
