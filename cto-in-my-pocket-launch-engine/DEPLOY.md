# CTO in My Pocket Launch Engine — Deployment Guide

Status: PARTIAL until deployed, smoke-tested, and bound to runtime receipts.

## Purpose

This deployment pack provisions the minimum launch engine for CTO in My Pocket / Business in My Pocket.

The customer-facing promise is convenience, not technology. The infrastructure supports:

- public assessment intake
- lead capture
- scoring and recommendation generation
- report creation
- Stripe subscription handoff
- email follow-up
- telemetry and Reality Ledger evidence

## Target Architecture

```text
Customer
  -> Landing Page / Assessment UI
  -> API Gateway
  -> Intake Lambda
  -> Supabase / Postgres
  -> Scoring Lambda
  -> Report Lambda
  -> Email Lambda
  -> Stripe Checkout
  -> Reality Ledger
  -> Command Centre telemetry
```

## Environments

Required environments:

- `dev`
- `staging`
- `prod`

Recommended AWS region:

- `ap-southeast-2`

## Required Secrets

Secrets must not be committed to GitHub. Store them in AWS SSM Parameter Store as SecureString unless otherwise noted.

See `infra/ssm-parameters.md` for the full inventory.

## Deployment Order

1. Create or confirm SSM parameters.
2. Deploy Terraform/CDK/CloudFormation baseline.
3. Deploy Lambda code bundle.
4. Configure API Gateway routes.
5. Configure Stripe webhook endpoint.
6. Run smoke tests.
7. Write Reality Ledger deployment receipt.
8. Confirm Command Centre telemetry view receives events.

## Terraform Deployment

```bash
cd cto-in-my-pocket-launch-engine/infra/terraform
terraform init
terraform plan -var="environment=dev" -out=tfplan
terraform apply tfplan
```

## CloudFormation Deployment

```bash
aws cloudformation deploy \
  --template-file cto-in-my-pocket-launch-engine/infra/cloudformation/ctoip-launch-engine.yaml \
  --stack-name ctoip-launch-engine-dev \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides Environment=dev
```

## CDK Deployment

```bash
cd cto-in-my-pocket-launch-engine/infra/cdk
npm install
npx cdk synth
npx cdk deploy CtoipLaunchEngineStack-dev
```

## Scripted Deployment

```bash
chmod +x cto-in-my-pocket-launch-engine/scripts/*.sh
cto-in-my-pocket-launch-engine/scripts/deploy-dev.sh
```

## Smoke Test

```bash
cto-in-my-pocket-launch-engine/scripts/smoke-test.sh dev
```

Expected checks:

- health endpoint returns 200
- intake endpoint accepts sample assessment
- scoring function returns structured score
- report function returns report payload
- telemetry event is written
- Reality Ledger event is written

## Rollback

```bash
cto-in-my-pocket-launch-engine/scripts/rollback.sh dev
```

Rollback should disable API routes before deleting stateful resources. Do not delete production databases or SSM parameters during rollback.

## Reality Ledger Classification

| Area | Status | Evidence Required |
|---|---|---|
| Infrastructure files | REAL | GitHub commit |
| Deployment | PARTIAL until executed | CloudFormation/Terraform/CDK receipt |
| API runtime | PARTIAL until tested | smoke-test output |
| SSM binding | PARTIAL until confirmed | parameter list + successful secret fetch |
| Customer launch | PARTIAL until live customer evidence | lead/payment/report receipt |

## Launch Gate

Do not call this REAL until all are true:

- API deployed
- public landing page wired
- intake writes to database
- scoring works
- report generated
- Stripe checkout works
- email follow-up works
- telemetry visible
- Reality Ledger writes evidence
- at least one test customer journey completed end-to-end
