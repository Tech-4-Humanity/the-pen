# OPS-RUNNER-001 — GitHub Actions: jobs created but no runner allocated (the-pen)

```yaml
issue:
  id: OPS-RUNNER-001
  status: OPEN
  severity: P2
  class: infrastructure / runner-allocation
  repo: TML-4PM/the-pen
  filed: 2026-05-30
  filed_by: Claude (executor), directive from Troy (director)
  evidence_state: REAL
```

## Symptom

Multiple workflows in `TML-4PM/the-pen` report **Failure** in 2-5s with **zero steps**, no runner, and **no log blob**. GitHub mobile shows "This check has no steps"; the app also mislabels the trigger as `on:pull_request`.

Affected (observed): Pen Queue Processor (Sweep), Bridge Runner Heartbeat, PEN Ingest Worker, Master Context Spine, Knowledge Spine Runtime Proof, Standard Runtime Proof, Bridge Diagnostics, self-healing-monitor.

## Hard evidence (read, not inferred)

| Fact | Value | Source |
|---|---|---|
| Example run | Pen Queue Sweep #461, run_id 26682068030 | runs_list |
| Trigger | `event: schedule` (NOT pull_request) | runs_list |
| Job | id 78644097976, `Inbox sweep + drift check (no HITL)` | run_jobs |
| Steps executed | `[]` (none) | run_jobs |
| Runner assigned | `""` (none) | run_jobs |
| Duration | 3s | run_jobs |
| Log fetch | HTTP 404 `BlobNotFound` — no log was ever written | github_actions_job_logs |
| Workflow YAML | valid (`on.schedule` cron `*/30 * * * *`, well-formed steps) | github_file_read |

## Diagnosis

A job that is **created, assigned no runner, runs zero steps, writes no log blob, and completes in ~3s as `failure`** — on **valid YAML**, on a **scheduled** trigger — did not fail inside workflow logic. It failed at **run start / runner allocation**, before any runner attached.

Falsified hypotheses (each disproven by later evidence this session):
- ~~Stale AWS / bridge credential~~ — those fail mid-step with a logged error; these have no steps/no log.
- ~~PR-context secret withholding~~ — #461 is a `schedule` run, not PR.
- ~~Cosmetic skipped-check rendering red~~ — affected workflows have no job-level `if:` skip guard; scheduled runs are affected.
- ~~Claude's cron edits corrupted YAML~~ — pen-queue-cron.yml (unedited by Claude) is affected and valid.
- ~~Branch-protection required checks~~ — does not explain scheduled runs failing at allocation.

Remaining dominant cause for *runner-never-allocated on valid YAML, private repo*: **GitHub Actions is administratively disabled for the repo, OR the account's Actions minutes / spending limit is exhausted.** Both live behind a settings/billing surface not reachable by current tooling.

## Decisive next read (settings-gated — director only)

```bash
gh api /repos/TML-4PM/the-pen/actions/permissions
# -> {"enabled": false} would confirm Actions disabled
```
plus GitHub Settings -> Billing -> Actions usage (minutes vs included; spending limit reached?).

One of these two ends OPS-RUNNER-001.

## Remediation (by branch)

- If Actions disabled -> re-enable (repo Settings -> Actions -> General -> Allow actions).
- If minutes/spend exhausted -> raise spending limit or wait for monthly reset; THEN apply the already-committed cron-frequency cuts (heartbeat & pen-ingest `*/15 -> hourly`, commits 0aef0f2 / e080215) to keep burn down, and extend cuts to pen-queue-cron (`*/30`).

## What was actually fixed vs not (honest ledger)

- FIXED: SEC-WFA-001 push-scope (mcp-command-centre, commit 92ccf13) — REAL, verified green.
- MITIGATED: heartbeat + pen-ingest cron frequency cut (0aef0f2, e080215) — reduces burn, does NOT green the runner-allocation failure.
- NOT FIXED: OPS-RUNNER-001 (this issue) — blocked on a settings/billing read+change only the director can perform.

_Receipt: this file's commit is the artifact. Ledger row to be written to ops.reality_ledger on confirmation of cluster_id._
