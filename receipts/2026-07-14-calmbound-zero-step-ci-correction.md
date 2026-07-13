# Receipt — CalmBound Zero-Step CI Correction

**Date:** 2026-07-14  
**Repository:** `TML-4PM/the-pen`  
**Status:** PARTIAL

## Correction

PR #231 did not fail after running zero test steps. GitHub created the workflow jobs but did not start the first workflow step.

The workflow contains explicit steps for checkout, Node setup, dependency installation, syntax validation, contract tests, OpenAPI linting, PostgreSQL startup, migrations, API smoke tests, event receipt verification, artefact upload and rollback validation.

Three runs were observed:

- `29266981601`
- `29267054505`
- `29267235197`

In the split run, GitHub created both `validate-source` and `validate-postgres`, but exposed no executed steps for either job. Job-log retrieval returned `BlobNotFound`.

## Classification

- **Not a runtime code-test failure:** no source checkout or test command executed.
- **Not a PostgreSQL failure:** the PostgreSQL validation job never reached its first step.
- **Zero-step workflow-start failure:** GitHub created job records but did not start workflow execution.
- **Root cause unresolved:** available evidence does not identify whether the block is billing, account policy, repository Actions policy, runner allocation or another GitHub platform condition.

## Actions completed

- The CI workflow was split into independent source and PostgreSQL jobs.
- The runtime was validated separately in an isolated local Node environment.
- Syntax validation passed.
- Three contract tests passed with zero failures.
- A transactional owner-membership defect was identified and corrected.
- PR #231 was closed because its code changes were applied additively to current `main` and the branch became superseded.

## Remaining proof

A runner must successfully start `actions/checkout` before GitHub-hosted CI can be considered operational. PostgreSQL migration, API smoke, OpenAPI lint, telemetry and rollback remain unproven.

## Truth statement

This receipt proves the distinction between a zero-step workflow-start failure and an executed test failure. It does not claim the GitHub Actions platform block has been removed.