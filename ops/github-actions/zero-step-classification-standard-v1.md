# GitHub Actions Zero-Step Classification Standard v1

**Owner:** T4H Operations  
**Scope:** All repositories accessible under `TML-4PM`  
**Status:** ACTIVE  
**Truth rule:** A workflow job with no executed steps is not a code-test failure.

## Required terminology

### `ZERO_STEP_RUNNER_START_FAILURE`

Use only when all observed evidence is present:

- GitHub created a workflow run and job record.
- Job `steps` is empty or absent.
- No runner name or runner group was allocated.
- No job log blob exists, commonly returned as `404 BlobNotFound`.
- The job concludes rapidly as `failure`, `cancelled`, or another terminal state.
- The workflow definition contains executable steps.

Correct wording:

> GitHub created the job record but did not allocate a runner or start the first workflow step. No workflow, dependency, test, deployment, credential, or application failure was observed.

Never write:

- `tests failed with zero steps`
- `workflow steps failed to create`
- `the code failed before steps`
- `CI failed the tests`
- `all jobs failed`

unless a step actually started and produced evidence.

Likely cause classes include repository or organisation Actions policy, billing/minutes/spending restrictions, hosted-runner allocation, workflow approval, or platform incident. These remain hypotheses until settings or audit evidence confirms one.

### `ZERO_STEP_JOB_SKIPPED`

Use when GitHub evaluated a job-level condition such as:

```yaml
jobs:
  verify:
    if: github.event_name != 'pull_request'
```

or:

```yaml
jobs:
  noop:
    if: false
```

and therefore no step was eligible to run.

Correct wording:

> The workflow was triggered, but the job-level condition prevented the job from materialising executable steps.

Recommended repair:

- Remove the job-level skip when the check is expected to exist.
- Add an unconditional first step such as `Always materialise job`.
- Move context-sensitive guards to individual steps.
- Add a safe acknowledgement step for PR or restricted contexts.

### `STEP_EXECUTION_FAILURE`

Use only when at least one workflow step started and a step conclusion or log identifies the failure.

Correct wording:

> The `<step name>` step executed and failed because `<observed error>`.

### `EXTERNAL_CHECK_FAILURE`

Use for Vercel, AWS, Buildkite, or another non-GitHub-Actions provider. Do not classify it as a GitHub Actions runner or workflow failure.

## Decision table

| Evidence | Classification |
|---|---|
| Job exists; steps empty; runner absent; log blob absent | `ZERO_STEP_RUNNER_START_FAILURE` |
| Job skipped by job-level `if` | `ZERO_STEP_JOB_SKIPPED` |
| At least one step started and logged an error | `STEP_EXECUTION_FAILURE` |
| Check URL belongs to another provider | `EXTERNAL_CHECK_FAILURE` |
| Evidence unavailable or contradictory | `UNRESOLVED_CHECK_STATE` |

## Receipt requirements

Every Actions incident receipt must include, where available:

- repository
- workflow name and file
- run ID
- job ID and name
- event type
- head SHA and branch
- run status and conclusion
- job status and conclusion
- step count
- runner name and runner group
- run duration
- log retrieval result
- external check contexts kept separate
- classification
- evidence gaps
- recovery or reroute action

## Organisation-wide audit result — 2026-07-14

- Repository inventory returned a broad TML-4PM estate with many active private repositories.
- Code search found GitHub Actions definitions across multiple repositories.
- Confirmed runner-start evidence currently exists for `TML-4PM/the-pen`, including historical issue `OPS-RUNNER-001` and CalmBound runs `29266981601`, `29267054505`, and `29267235197`.
- The CalmBound split run created `validate-source` and `validate-postgres`, but neither began the first step.
- Search also found workflow files containing `if: github.event_name != 'pull_request'`; this string may be safe at step level and must be structurally inspected before changing it.
- Prior `symbio-dev-control-plane` job-level materialisation risks were repaired and receipted separately.
- No claim is made that every repository has the runner-start defect. Each repository requires run/job evidence before classification.

## Canonical linked evidence

- `issues/OPS-RUNNER-001-actions-runner-not-allocated.md`
- GitHub issue `#232` — organisation-wide runner-start investigation
- `receipts/2026-07-14-calmbound-zero-step-ci-correction.md`
- `symbio-dev-control-plane/receipts/20260613-workflow-materialisation-repair.md`

## Operational rule

**Zero executed steps means execution did not reach application code.** Diagnose job materialisation and runner allocation first. Do not edit application code to fix an unstarted job.