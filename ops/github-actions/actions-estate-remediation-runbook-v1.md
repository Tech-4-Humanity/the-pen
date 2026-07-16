# GitHub Actions Estate Remediation Runbook v1

## Purpose

Resolve zero-step GitHub Actions incidents without misclassifying unexecuted workflows as code, test, deployment, credential, database, or application failures.

## Canonical evidence classes

### ZERO_STEP_RUNNER_START_FAILURE

Required evidence:

- a workflow run and job record exist;
- the job has zero executed steps;
- no runner name or runner group is assigned;
- the job concludes as failure;
- no usable job log blob exists.

Canonical wording:

> GitHub created the job record but did not allocate a runner or start the first workflow step. No workflow, dependency, test, deployment, credential, database, or application failure was observed.

### ZERO_STEP_JOB_SKIPPED

Required evidence:

- the job concludes as skipped;
- zero steps materialise;
- workflow structure or job-level conditions explain the skip.

Canonical wording:

> GitHub evaluated the job-level condition and did not materialise workflow steps. This is a skipped-job/materialisation condition, not a runner-start failure.

## Execution

Run from an environment with GitHub CLI authenticated for Actions read access:

```bash
chmod +x ops/github-actions/diagnose_and_repair_actions_estate.sh
ORG=TML-4PM ./ops/github-actions/diagnose_and_repair_actions_estate.sh
```

The script is read-only. It captures:

- organisation Actions permissions;
- per-repository Actions permissions;
- recent workflow runs and jobs;
- runner allocation;
- executed step counts;
- canonical classification;
- JSONL evidence and a summary receipt.

## Decision path

### 1. Organisation Actions disabled or restricted

Review:

```bash
gh api /orgs/TML-4PM/actions/permissions
```

Expected enabling state normally includes `enabled: true`. If disabled, enable Actions in organisation settings. If allowed-actions policy is restrictive, ensure required first-party actions are permitted, including:

- `actions/checkout`
- `actions/setup-node`
- `actions/setup-python`
- `actions/upload-artifact`

### 2. Repository Actions disabled

For each affected repository:

```bash
gh api /repos/TML-4PM/REPOSITORY/actions/permissions
```

If disabled, enable Actions in repository Settings → Actions → General, subject to organisation policy.

### 3. Minutes, billing, or spending limit exhausted

Review the GitHub account or organisation billing and Actions usage pages. Runner-start failures across multiple private repositories with valid workflows, no runner allocation, zero steps, and no logs are consistent with an administrative allocation block. Do not call this confirmed until billing/settings evidence is read.

### 4. Job-level materialisation guards

Inspect workflow structure before editing. A step-level condition is usually safe. A job-level condition can produce a skipped job with no materialised steps.

Preferred pattern:

```yaml
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: Always materialise job
        run: echo "job materialised"
      - name: PR-safe acknowledgement
        if: github.event_name == 'pull_request'
        run: echo "classification=PR_SAFE_NO_OP"
      - name: Runtime work
        if: github.event_name != 'pull_request'
        run: ./runtime-command
```

### 5. Required checks referencing retired workflows

Review branch protection and rulesets. Remove or replace status-check names belonging to deleted, renamed, or permanently skipped workflows.

## Verification

After remediation:

1. Trigger `.github/workflows/runner-allocation-probe.yml`.
2. Confirm the unconditional step starts and succeeds.
3. Rerun the affected application workflow.
4. Confirm checkout starts.
5. Inspect real step logs for any code or environment failure.
6. Publish a receipt containing run ID, job ID, runner name, step count, conclusion, and log availability.

## Truth boundary

A successful probe proves runner allocation for that repository and run. It does not prove application tests, database migrations, deployment, telemetry, or production readiness.
