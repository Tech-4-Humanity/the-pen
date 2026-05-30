# REPEATED ISSUE: GHA "chronic workflow failure" misdiagnosis loop

**Status:** Failure is CONTEXT-dependent, not code (proven). Suspected cause: open PR forcing main into pull_request context. PR-open state NOT independently confirmed (no PR-list tool available this session).
**First mis-filed as:** OPS-RUNNER-001 ("scheduled jobs fail with no runner") — WRONG framing
**Date:** 2026-05-30

## What is PROVEN

The failure is determined by branch/execution context, not by workflow code. Identical `pen-worker.yml`:
- Run #108 on branch `fix/pen-worker-no-job-graceful-exit` → SUCCESS, 13s, full steps
- Run #109 same code on `main` (commit 6c4b0b9) → FAILURE, 2s, no steps

Same code, different context = failure is contextual. No code change on main fixes it.

## What is INFERRED (consistent, not independently confirmed)

The likely mechanism: `main` is the head/base of an **open PR**, so runs on main are evaluated in pull_request context where GitHub withholds secrets/privileged execution → 0–3s death, no runner, no steps.

Supporting (circumstantial):
- Every failing run's UI breadcrumb reads `on:pull_request` even for push/schedule triggers.
- AGL Bootstrap #135–138 GREEN → #139–140 RED, flip ~aligns with when PR #108 work landed.
- `-1s`/`0s` durations = skip/withhold signature.

NOT confirmed: that PR #108 is currently open (no tool to list PRs was found/used). The two-branch test proves context-dependence; it does NOT by itself prove the PR is the context source. Treat the PR cause as strong-but-unconfirmed until the PR list is checked in the UI.

## Wrong diagnoses already burned (do not repeat)

1. "missing secret / rotate BRIDGE_API_KEY / GITHUB_PAT" — WRONG (failing workflow uses built-in GITHUB_TOKEN; sibling repo same token is green)
2. "runner acquisition / billing / spending cap" — WRONG (sibling repo green)
3. "repo Actions disabled / restricted policy" — WRONG (would fail all runs, not flip)
4. "push race / non-fast-forward on main" — WRONG (real smell; job dies BEFORE commit step). Push-retry was committed anyway (03c9c32, 196aea4) and did NOT fix it — confirming this was not the cause.
5. "job-resolve hard-fail" — REAL bug in some workflows, NOT this failure

**The trap that drove the loop:** GitHub API `run_jobs` returns empty `steps[]` and `runner_name=""` even for runs that genuinely executed steps. The slim projection LIES and makes every failure look like a startup/runner death. Live logs purge <20s. Only reliable per-step truth = GitHub UI step view.

## Diagnostic protocol (next time, skip the 5 wrong causes)

1. UI breadcrumb: does a push/schedule run say `on:pull_request`? → suspect open PR on main.
2. CONFIRM the PR is actually open (check PR list in UI — not assumed).
3. Two-branch test: identical trivial workflow on feature branch vs main, compare green/red → proves context-vs-code.
4. Do NOT trust API `steps[]`/`runner_name`. Use UI step view or catch a live log <20s.
5. If PR confirmed open: fix = merge/close it.

## Fix

Merge or close the open PR (suspected #108). Graceful-exit fix already mirrored to main (6c4b0b9) so no divergence on merge.

## Tooling note (states ONLY what was tested)

No dedicated MCP merge tool. Bridge merge paths ATTEMPTED:
- `troy-github-actions` — refuses PR ops (hard contract, Actions-run verbs only). CONFIRMED no.
- `troy-bridge-worker` (gh_api passthrough) — HTTP 500.
- `troy-code-pusher` (probe) — HTTP 500; dormant since March.
- `troy-lambda-deploy` (one-shot merge fn) — needs `zip_base64`; zip NOT built this session.

NOT tested: `troy-controller`, `mcp-bridge-invoke-handler`, the `troy-lambda-deploy` zip path.

Honest state: autonomous bridge merge is **incompletely investigated** — 4 paths failed, 2+ untested, impossibility NOT proven and viability NOT proven. Do not assert either "blocked" or "the bridge can obviously do this" without a tried-and-verified path. UI merge (10s) is proportionate.

---
*Filed by autonomous executor 2026-05-30. This doc was itself first written with an unverified claim (that bridge merge was viable-but-heavy) and corrected — the same assert-ahead-of-evidence error it documents. Next session: confirm the PR is open before acting; verify paths before calling them blocked or available.*
