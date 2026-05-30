# REPEATED ISSUE: GHA "chronic workflow failure" misdiagnosis loop

**Status:** ROOT CAUSE CONFIRMED — fix is a one-click PR merge
**First mis-filed as:** OPS-RUNNER-001 ("scheduled jobs fail with no runner") — WRONG framing
**Date:** 2026-05-30

## The actual root cause (proven)

An **open PR with `main` involved** (#108, `fix/pen-worker-no-job-graceful-exit-20260526`) forces **every** workflow run on `main` — push, schedule, any trigger — to be evaluated in **pull_request context**. GitHub withholds repo secrets and privileged execution in PR context by policy, so the runner is never granted and the job dies in 0–3s with no steps.

### Decisive proof (controlled test)
Identical `pen-worker.yml` content:
- Run #108 on branch `fix/pen-worker-no-job-graceful-exit` → **SUCCESS, 13s, full steps**
- Run #109 same code on `main` (commit 6c4b0b9) → **FAILURE, 2s, no steps**

Same code, different branch context = the failure is contextual, not code. No code change on main can fix it while the PR is open.

### Corroborating evidence
- AGL Bootstrap runs #135–138 GREEN (before PR opened) → #139–140 RED (after). Flip aligns with PR open date, not any code change.
- Every failing run's UI breadcrumb reads `on:pull_request` even for push/schedule triggers — the tell that main is inside an open PR.
- `-1s`/`0s` durations = skip/withhold signature, not error.

## Why this keeps getting misdiagnosed (the loop)

The symptom presents as infrastructure failure, leading to repeated wrong root-causes:
1. "missing secret / rotate BRIDGE_API_KEY / GITHUB_PAT" — WRONG (failing workflow uses built-in GITHUB_TOKEN; sibling repo with same token is green)
2. "runner acquisition / billing / spending cap" — WRONG (sibling repo green; was green until PR opened)
3. "repo Actions disabled / restricted policy" — WRONG (would fail all runs, not flip a day ago)
4. "push race / non-fast-forward on main" — WRONG (real smell, but job dies BEFORE the commit step)
5. "job-resolve hard-fail" — REAL bug in some workflows, but NOT this failure

**The trap:** the GitHub API (`run_jobs`) returns empty `steps[]` and `runner_name=""` even for runs that genuinely executed steps. This slim projection LIES and makes every failure look like a startup/runner death. Live logs purge in <20s. The only reliable per-step truth is the **GitHub UI step view**.

## Diagnostic protocol (use this next time, skip steps 1–5 above)

1. Check the UI breadcrumb: does a push/schedule run say `on:pull_request`? → **open PR on main is the cause.**
2. Confirm with the two-branch test: commit identical trivial workflow to a feature branch vs main, compare green/red.
3. Do NOT trust API `steps[]`/`runner_name` — use UI step view or catch a live log <20s.
4. Fix = **merge or close the open PR.** That's it.

## Fix

**Merge (or close) PR #108.** The instant main is no longer in an open PR, normal context returns, runners bind, all workflows run. Merging also lands the graceful-no-job-exit fix.

Graceful-exit fix content already mirrored to main (commit 6c4b0b9) so there is no divergence on merge. Push-retry hardening added to agl-bootstrap (03c9c32) and bridge-runner-heartbeat (196aea4) — correct improvements, will take effect once context is restored.

## Tooling note

The PR merge itself has no dedicated MCP tool; `troy-github-actions` Lambda is Actions-run-verbs only (no PR ops). Options to merge autonomously: deploy a one-shot merge Lambda via `troy-lambda-deploy` (deploy-class, requires GITHUB_TOKEN env wiring — heavy/gated), OR merge via GitHub UI (10s). UI merge is the proportionate path; do not manufacture privileged infra to avoid one tap.

---
*Filed by autonomous executor 2026-05-30 after a 4-misdiagnosis investigation loop. Logged here so the next session greps this before re-deriving wrong causes 1–5.*
