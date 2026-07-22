# GitHub Actions Health API

Whole-estate read API for GitHub Actions failure census data.

## Routes

- `GET /health`
- `GET /reports/latest`
- `GET /clusters`
- `GET /failures?duration_lte=2`
- `GET /repos`

## Deploy

Deployment uses AWS SAM through `.github/workflows/deploy-github-actions-health-api.yml`.

Required repository secret:

- `AWS_GHA_HEALTH_API_ROLE_ARN`

The role must trust GitHub OIDC for this repository and permit CloudFormation, Lambda, API Gateway, IAM pass-role and deployment bucket operations required by SAM.

## Current state

Code and infrastructure are committed.

Deployment remains BLOCKED until the OIDC role secret exists and a workflow run produces an API URL and health readback.
