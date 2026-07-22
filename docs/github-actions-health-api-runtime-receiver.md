# GitHub Actions Health API Runtime Receiver

Status: BLOCKED UNTIL PROVEN

## Purpose

This document defines the receiving side required to turn a GitHub commit into a live deployment.

A workflow file is not execution proof.

## Required Execution Chain

```text
GitHub event
  -> workflow selected
  -> workflow compiled
  -> GitHub-hosted runner allocated
  -> first step started
  -> GitHub OIDC token issued
  -> AWS IAM role assumed
  -> SAM validates
  -> SAM builds
  -> CloudFormation deploys
  -> Lambda exists
  -> API Gateway route exists
  -> health endpoint returns 200
  -> receipt committed
```

## Current Receiver State

- Workflow exists: REAL
- `runs-on: ubuntu-latest`: DECLARED
- GitHub-hosted runner allocation: UNPROVEN
- OIDC permission `id-token: write`: DECLARED
- AWS role secret reference: DECLARED
- AWS IAM OIDC trust relationship: UNPROVEN
- AWS role existence: UNPROVEN
- SAM deployment execution: UNPROVEN
- CloudFormation stack: UNPROVEN
- Lambda function: UNPROVEN
- API Gateway endpoint: UNPROVEN
- Live `/health` response: UNPROVEN

## Required AWS Receiver

The receiving AWS account must contain:

1. GitHub OIDC provider for `token.actions.githubusercontent.com`.
2. IAM role referenced by `AWS_GHA_HEALTH_API_ROLE_ARN`.
3. Trust policy restricted to repository `TML-4PM/the-pen` and branch `main`.
4. Permissions for CloudFormation, Lambda, API Gateway, IAM pass-role, S3 deployment artefacts, and CloudWatch Logs.
5. A writable SAM deployment bucket or permission to create one through `--resolve-s3`.

## Required Proof

The deployment is not REAL until all of these exist:

```yaml
workflow_run_id:
job_id:
runner_name:
first_step_started_at:
oidc_role_arn:
cloudformation_stack_id:
lambda_function_arn:
api_gateway_url:
health_status: 200
receipt_path:
```

## Failure Classification

- No workflow run: EVENT_OR_TRIGGER_FAILURE
- Run exists, no jobs: WORKFLOW_COMPILATION_OR_POLICY_FAILURE
- Job exists, no steps: RUNNER_OR_STARTUP_FAILURE
- Credentials step fails: OIDC_OR_IAM_TRUST_FAILURE
- SAM build fails: BUILD_FAILURE
- CloudFormation fails: AWS_DEPLOYMENT_FAILURE
- Stack exists but `/health` fails: RUNTIME_OR_ROUTE_FAILURE

## Operating Rule

Do not mark the API deployed because code and workflow files were committed.

Deployment becomes REAL only after runtime readback proves the complete receiving chain.
