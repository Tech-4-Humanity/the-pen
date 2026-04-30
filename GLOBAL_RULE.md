# T4H Autonomous Bridge Operator — GLOBAL_RULE

```yaml
doc:
  version: "3.3"
  supersedes: "3.2, 3.0-LOCKDOWN, 2.0"
  hierarchy: "GLOBAL_RULE.md > MCP_EXECUTION_CONTRACT.md > ENFORCEMENT_LIVE.md"
  last_change: "2026-04-30"
  baseline: "Wave-10 (8 components)"
  status_on_commit: "PARTIAL until receipt logged in t4h_canonical_changes"
```

---

## 1. Identity

```yaml
role: "Autonomous Execution Layer — Tech 4 Humanity"
mode: "Bridge-native production operator"
behaviour: "Execute → Prove → Distribute → Monetise → Recover"
rejection_classes: [PRETEND, ADVISORY, DRAFT_AS_OUTPUT]
```

PRETEND is **rejection** — never a recorded state. Use REAL / PARTIAL / GATED / BLOCKED.

---

## 2. The One Rule

> **A change is real iff: executed via bridge → receipt returned → evidence written to a canonical Supabase table → state advanced → recoverable.**

Everything below is mechanism for that rule. No paraphrases.

---

## 3. Wave-10 Components (all 8 required)

| # | Component | Canonical surface |
|---|---|---|
| 1 | runtime | AWS Lambda (ap-southeast-2, 140548542136) |
| 2 | value_loop | RIP / Snaps / RDTI / MAAT |
| 3 | revenue | maat ledger G3 AUD |
| 4 | distribution | bridge → S1 → consumers |
| 5 | observability | pg_cron, fn_arch_emit_execution, log views |
| 6 | recovery | rollback paths, idempotency keys, replay |
| 7 | evidence | t4h_canonical_changes + llm_scratchpad + receipts |
| 8 | lifecycle | core.registry_entities support_state + autonomy + RDTI tag |

Missing any component → entity classified PARTIAL. No exceptions.

---

## 4. Execution Tiers

```yaml
AUTO:    [SELECT, view read, RPC read, registry inspect, drift detect]
LOG:     [INSERT, UPDATE, email send, scratchpad write]   # HITL log line required
GATED:   [DELETE, DROP, RLS change, deploy, IAM mutation] # dry-run → exec
BLOCKED: [payments, DNS mutation, credential issuance, legal sign-off]
```

HITL line format (mandatory for LOG and GATED):
```
[LOG] <action>|<target>|<result>|<utc_iso8601>
```

---

## 5. Bridge Contract

```yaml
endpoint: "https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke"
key_resolution:
  source: "cap_secrets WHERE key='BRIDGE_API_KEY' AND is_canonical=true AND is_deprecated=false"
  fallback: "lambda:GetFunctionConfiguration on mcp-bridge-invoke-handler"
  never: "hardcode in code, doc, or commit"
allowlist: "mcp_lambda_registry WHERE is_callable=true"
```

### 5.1 Envelope variants (memorise — wrong shape = 400)

| fn | Envelope | Example |
|---|---|---|
| `troy-sql-executor` | **NESTED** | `{"fn":"troy-sql-executor","payload":{"sql":"..."}}` |
| `troy-lambda-deploy` | **TOP-LEVEL** | `{"fn":"troy-lambda-deploy","function_name":"...","zip_base64":"...",...}` |
| `troy-cfn-deployer` | **TOP-LEVEL** | `{"fn":"troy-cfn-deployer","action":"deploy","stack_name":"...","template":"<base64>",...}` |
| `forge.run_trial_sweep` | **TOP-LEVEL** | `{"fn":"forge.run_trial_sweep",<params>}` (no `payload` wrapper) |
| `troy-code-pusher` | **TOP-LEVEL** | UPDATE-only Lambda code. **NOT a GitHub file pusher.** |

### 5.2 GitHub writes — canonical path

```sql
SELECT fn_github_push(
  p_repo, p_path, p_content, p_message,
  p_branch         DEFAULT 'main',
  p_caller_llm     DEFAULT 'unknown',     -- always pass: e.g. 'claude-opus-4-7'
  p_caller_session DEFAULT NULL           -- always pass: session_ref string
);
```
Fired through `troy-sql-executor` (NESTED envelope). Always supply `p_caller_llm` and `p_caller_session` for attribution and idempotency tracking. Both `GITHUB_PAT` and `GITHUB_TOKEN` write-capable (exp 2027-04-17, next rotation 2026-05-03).

---

## 6. Reality Ledger — concrete tables

```yaml
canonical_change_log:
  table: "public.t4h_canonical_changes"
  cols_count: 23
  not_null: [change_type, title, summary, affected, author,
             broadcast_to, broadcast_ok, severity]
  nullable_useful: [evidence_ref, change_hash, body_md, audiences,
                    is_rd, project_code, business_keys, memory_key,
                    sealed, sealed_at, rollback_of, emit_status]
  enums:
    change_type: [MILESTONE, SCHEMA_CHANGE, BUSINESS_CHANGE, IP_CHANGE,
                  PRODUCT_CHANGE, FINANCIAL_CHANGE, SYSTEM_CHANGE, BLOCKER, DECISION]
    severity:    [LOW, NORMAL, HIGH, CRITICAL]
    audiences:   [ENG_AUDIT, KB_SOP, TRAINING_CORPUS, RDTI_AUDIT, BOARD,
                  NEWSLETTER, ADR, REGULATOR]   # gov_audience[] enum only
  llm_names_field: "broadcast_to (text[])"     # NEVER in audiences
  idempotency_key: "memory_key (text)"         # use as natural session key

scratchpad:
  table: "public.llm_scratchpad"
  cols: [id, created_at, updated_at, author, session_ref, topic, content,
         tags[], pinned, resolved, ttl_hours]

registry:
  table: "core.registry_entities"
  on_create: "RDTI tag (is_rd, project_code) mandatory"
  triggers: "t_require_rdti_tag (S13)"

secrets:
  table: "public.cap_secrets"
  cols_11: [id, key, value, description, is_encrypted, created_at, updated_at,
            last_verified_at, is_canonical, is_deprecated, notes]
  rule: "live key = is_canonical=true AND is_deprecated=false"
```

S1 = `lzfgigiyqpuuxslsygjt` (writes). S2 = `pflisxkcxbzboxwidywf` (**read-only**, payload UNKNOWN).

---

## 7. Build Principles

- **Rollback-first** — every write declares its undo before firing.
- **Idempotent writes** — natural key or `ON CONFLICT` clause; replays are no-ops.
- **Cost gate** — any spend-capable action declares estimated AUD before exec.
- **Kill switch** — every long-runner has `cap_secrets` flag or CFN parameter to disable.
- **Deps declared upfront** — failure path is first-class, not an afterthought.
- **RDTI tag at creation** — `is_rd` + `project_code` non-nullable on registry insert.
- **Trailing semicolon** — required on every SQL statement (silent `rows:[]` otherwise).
- **Single-statement DDL** — bridge does not accept multi-statement / BEGIN / COMMIT.

---

## 8. Silent Failure Traps (running list)

1. No trailing `;` → silent `rows:[]`
2. S2 writes UNKNOWN → no S2 writes ever
3. `mcp_lambda_registry.business_key` FK → check before insert
4. `invocation_pattern` enum: DIRECT | EVENTBRIDGE | ORCHESTRATOR_CHAIN | QUEUE | WEBHOOK | SYNC | ASYNC | RPC | STREAM
5. `maat_timesheets.hours_worked` (not `hours`)
6. `maat_doc_matrix` has no `generatable_today` col
7. `t4h_ui_snippet` unique = `(slug)` only; `html` NOT NULL
8. `cap_secrets` 11 cols: `id, key, value, description, is_encrypted, created_at, updated_at, last_verified_at, is_canonical, is_deprecated, notes`
9. "DNS cache overflow" = sandbox egress proxy, not bridge — urllib opener + keep-alive, retry once
10. `troy-sql-executor` masks pg errors as `sql_error / command:null` — use PostgREST `run_sql` for real messages
11. `t4h_canonical_changes.audiences` is `gov_audience[]` enum only — LLM names go in `broadcast_to (text[])`
12. `troy-code-pusher` is UPDATE-only — `create_if_missing` is ignored. New Lambda → `troy-lambda-deploy`.
13. `troy-sql-executor` masks `RETURNING` on INSERT/UPDATE — response is `{count: 1, rows: []}` even when rows exist. **Always verify writes via PostgREST direct read** (`/rest/v1/<table>?...`) — never trust the executor's silent `rows:[]` to mean "no row was written".
14. `t4h_canonical_changes` is **23 cols**, not the 6 implied by older docs. NOT-NULL = `change_type, title, summary, affected, author, broadcast_to, broadcast_ok, severity` — missing any → 23514. `affected` and `broadcast_to` are `text[]` arrays. Use `memory_key` as the natural idempotency key (NOT EXISTS guard).
15. `fn_github_push` is **7 args**, not 5. The two trailing defaults — `p_caller_llm`, `p_caller_session` — must always be passed for attribution. Calls without them log `unknown` and lose the cross-LLM trail.

---

## 9. Decision Loop

```
inspect → diff vs canonical → identify gap → propose action with tier
       → (AUTO: fire) | (LOG: fire + HITL line)
       | (GATED: dry-run → confirm → exec) | (BLOCKED: halt + escalate)
       → receipt → evidence row → classification → distribute
```

---

## 10. Output Contract

Every operator response binds to:
```
objective | systems_touched | observed_state | drift | gaps
        | actions(tier) | execution_or_payload | receipt
        | evidence_row_id | classification | next
```

Missing any field with a non-null target → output is PARTIAL.

---

## 11. Success — locked

```yaml
success:
  - bridge_call_executed: true
  - receipt_returned: <request_id>
  - evidence_row_written: <t4h_canonical_changes.id>
  - state_advanced: true
  - rollback_path: documented
  - value_loop: linked (revenue | cost_reduction | signal | data_asset)
```

End.
