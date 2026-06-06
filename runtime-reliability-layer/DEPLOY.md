# Runtime Reliability Layer — DEPLOY.md

Status: v1.0 deployable scaffold
Created: 2026-06-05
Repository: TML-4PM/the-pen

## Purpose

Runtime Reliability Layer turns workflow, queue, bridge, credential, and runtime-proof signals into one deployable reliability control plane.

The deployment creates infrastructure for:

- runtime incident tracking
- runtime receipt tracking
- queue orphan detection
- credential drift detection
- workflow health checks
- bridge proof checks
- recovery task creation
- SSM-backed configuration

## Architecture

```text
GitHub Actions / Bridge / Queue / Runtime Proof
        ↓
Runtime Reliability Lambdas
        ↓
DynamoDB Tables
        ↓
CloudWatch Metrics + Alarms
        ↓
Reality Ledger / Service Catalogue / Operator Escalation
```

## Deployment Options

This pack includes three equivalent infrastructure paths:

1. Terraform
2. CloudFormation
3. AWS CDK TypeScript

Use one, not all three, for the same environment.

Recommended order:

```bash
cd runtime-reliability-layer/terraform
terraform init
terraform plan
terraform apply
```

## Prerequisites

- AWS account access
- AWS CLI configured
- Terraform >= 1.6 if using Terraform
- Node.js >= 20 if using CDK/scripts
- GitHub repository secrets available for runtime checks
- SSM Parameter Store path writable under /t4h/runtime-reliability

## Required SSM Parameters

See `ssm/parameter-registry.md`.

Minimum required values:

```text
/t4h/runtime-reliability/bridge/url
/t4h/runtime-reliability/bridge/api-key
/t4h/runtime-reliability/github/workflow-pat
/t4h/runtime-reliability/supabase/url
/t4h/runtime-reliability/supabase/service-role
/t4h/runtime-reliability/recovery/enabled
/t4h/runtime-reliability/customer-notify/enabled
```

Sensitive values must be SecureString.

## Terraform Deploy

```bash
cd runtime-reliability-layer/terraform
terraform init
terraform plan -out runtime-reliability.tfplan
terraform apply runtime-reliability.tfplan
```

## CloudFormation Deploy

```bash
aws cloudformation deploy \
  --template-file runtime-reliability-layer/cloudformation/runtime-reliability.yaml \
  --stack-name runtime-reliability-layer \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides EnvironmentName=prod
```

## CDK Deploy

```bash
cd runtime-reliability-layer/cdk
npm install
npx cdk synth
npx cdk deploy RuntimeReliabilityStack
```

## Scripts

```bash
runtime-reliability-layer/scripts/deploy.sh terraform prod
runtime-reliability-layer/scripts/verify.sh prod
runtime-reliability-layer/scripts/recover.sh prod dry-run
```

## Smoke Tests

Minimum smoke test outcomes:

1. DynamoDB tables exist.
2. SSM parameters are readable by Lambda role.
3. Runtime proof Lambda returns structured receipt.
4. Queue health Lambda can classify empty, healthy, and orphaned states.
5. Credential health Lambda can classify present/missing/stale without leaking secret values.
6. Recovery script defaults to dry-run.

## Safety Boundaries

The scaffold does not expose secret values. It only checks parameter existence, age metadata where available, and invocation health.

Automatic recovery must remain disabled until:

```text
/t4h/runtime-reliability/recovery/enabled = true
```

## Reality Classification

Current state after posting this pack:

```yaml
status: PARTIAL
result: deployable scaffold committed
REAL_requires:
  - terraform apply receipt
  - cloudformation deploy receipt or CDK deploy receipt
  - lambda invoke receipt
  - queue health receipt
  - ledger row write receipt
```

## Next Action

Run one deployment path and attach receipts to GitHub Issue #160.
