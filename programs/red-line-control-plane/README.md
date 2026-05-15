# Red-Line Control Plane

Status: PARTIAL (probe layer REAL — see `STATUS.md`)
Last updated: 2026-05-15T21:26:26Z

This package converts the audit/runtime problem from scattered discussion into a concrete control-plane program inside `TML-4PM/the-pen`.

It moves work through:

```text
scan -> classify -> repair -> receipt -> proof -> closure
```

It exists because passive dashboards and flat receipts are not enough. A receipt that only proves a file/comment exists is not the same as runtime execution, blocker handling, or closure.

## Included artefacts

| File | Purpose | Reality |
|---|---|---|
| `receipt_lifecycle_v2.schema.json` | Lifecycle receipt schema (dispatch/acceptance/implementation/runtime/closure/blocker/repair/probe) | REAL (defined) |
| `runtime_probe.sql` | SQL probes for `fn_github_push`, `http`, `cap_secrets`, receipt table | REAL |
| `runtime_receipts/2026-05-15_probe_run_001.json` | First REAL runtime receipt, schema-v2-conforming | REAL |
| `runtime_receipts/2026-05-15_probe_run_001.md` | Human-readable mirror | REAL |
| `blocker_matrix.md` | Current blocker matrix (#102/#106/#107/#108 + drift + dispatcher) | REAL |
| `audit_repair_dispatcher_v1.md` | Operating spec for the autonomous repair loop | SPEC |
| `STATUS.md` | Reality state of every layer + close-out path | REAL |

## Probe receipt summary (REAL)

Executed 2026-05-15T21:26:26Z via Supabase Official Connector:

- `fn_github_push` — exists, `(p_repo, p_path, p_content, p_message, p_branch, p_caller_llm, p_caller_session) -> jsonb`, body 3488 bytes
- `http` extension — installed
- `t4h_canonical_changes` — 26 cols, 3,240 rows total, 2,744 in last 7d
- `cap_secrets.GITHUB_PAT` / `GITHUB_TOKEN` — present, not deprecated
- `cap_secrets` total — 417 rows

→ Runtime path `fn_github_push → http → GitHub → t4h_canonical_changes` is **structurally REAL**.

## Remaining work to flip program to REAL

Four items, in order:

1. **Schema migration** — `migrations/2026-05-16_receipt_lifecycle_v2.sql` adds lifecycle columns to `t4h_canonical_changes`. Closes B-01, B-04.
2. **Quarantine RPC** — `public.fn_receipt_quarantine(text)`. Closes B-02 / issue #107.
3. **Dispatcher RPC + cron** — `public.fn_red_line_dispatcher_tick()` + `*/5 * * * *` pg_cron. Closes B-05 / issue #102.
4. **Confirmatory probe re-run** — second probe receipt proving v2 columns accept lifecycle payloads.

## Execution path note

Bridge keys are 401 across all combinations (per current credential state). SQL execution for this program routes through the Supabase Official Connector. Bridge remains reserved for AWS/Vercel/GitHub operations.

## Reference

- `global/GLOBAL_RULE.md` — `the-pen` canonical
- `global/MCP_EXECUTION_CONTRACT.md` — bridge envelope (under review for SQL/non-SQL split)
- `global/ENFORCEMENT_LIVE.md` — historical working runtime path
- `migrations/2026-04-24_fix_fn_github_push.sql` — `fn_github_push` implementation
- `global/RECEIPT_SCHEMA.json` — current flat schema (to be superseded by v2)
- `receipts/README.md` — two-way lifecycle that this package operationalises
