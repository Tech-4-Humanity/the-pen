# Connector Control Plane — Full Production Program

## Reality Ledger

```yaml
status: PARTIAL
result: Full production program specified as deployable repo package. GitHub receipt created for program layer. This is not yet REAL production because runtime deployment receipts are still absent.
evidence:
  - type: github_commit
    value: pending_connector_response
  - type: repo_path
    value: connector-control-plane/02_full-production-program.md
gaps:
  - files must be materialised into repo as CDK/source artifacts
  - npm install/build/synth not yet run by this chat runtime
  - AWS deploy not yet executed
  - Service Catalog product not yet registered in AWS
  - first runtime receipt not yet emitted
next_action:
  - create repo file set
  - run CI/synth
  - promote through Bridge/dev worker
  - capture runtime receipts
pressure_flags:
  - user rejected staged builder-layer output
  - target standard is Apple/Amazon-grade production readiness tonight
score: 0.84
```

---

## What This Program Must Deliver

This is the complete program package for productionising Connector Control Plane as a service-catalog product.

It must include:

1. CDK deployable infrastructure
2. Lambda workers
3. Supabase/Postgres migration SQL
4. Runtime schemas
5. GitHub Actions validation
6. AWS Service Catalog product metadata
7. Bridge promotion envelope
8. Runbook
9. Telemetry contract
10. Reality Ledger receipt templates
11. Definition of Done
12. Deployment commands
13. Recovery commands

---

## Required Repo Tree

```text
connector-control-plane/
  README.md
  00_connector-control-plane-v1.md
  01_amazon-grade-service-catalog-standard.md
  02_full-production-program.md
  cdk/
    package.json
    tsconfig.json
    cdk.json
    bin/
      app.ts
    lib/
      connector-control-plane-stack.ts
      service-catalog-stack.ts
    lambda/
      health-worker.ts
      intent-router.ts
      receipt-writer.ts
      shared.ts
  db/
    001_connector_control_plane.sql
    002_seed_connector_registry.sql
  service-catalog/
    product-metadata.yaml
    portfolio.yaml
  bridge/
    promote-connector-control-plane-v1.json
  runbooks/
    01_operations-runbook.md
    02_recovery-runbook.md
  reality-ledger/
    receipt-template.json
    promotion-ledger.yaml
  .github/
    workflows/
      connector-control-plane-ci.yml
```

---

## Production Deployment Contract

```yaml
deploy_contract:
  command_local:
    - cd connector-control-plane/cdk
    - npm install
    - npm run build
    - npx cdk synth
    - npx cdk deploy --all

  command_bridge:
    action: invoke_function
    function_name: troy-code-pusher
    payload:
      task_id: connector-control-plane-v1-productionise
      repo: TML-4PM/the-pen
      path: connector-control-plane
      required_receipts:
        - github_commit
        - cdk_synth
        - stack_deploy
        - health_worker_invoke
        - service_catalog_metadata
        - reality_ledger_write
```

---

## Runtime Definition of Done

```yaml
production_done:
  github_package: required
  cdk_synth_pass: required
  cdk_deploy_pass: required
  lambda_health_worker_created: required
  lambda_intent_router_created: required
  lambda_receipt_writer_created: required
  dynamodb_or_supabase_contract_created: required
  service_catalog_product_registered: required
  cloudwatch_alarms_active: required
  first_connector_health_receipt: required
  bridge_receipt: required
  reality_ledger_status: REAL
```

---

## No More Builder-Layer Rule

From this point, acceptable outputs must be one of:

1. committed source file
2. committed deployment package
3. runtime receipt
4. CI result
5. deployment receipt
6. Service Catalog registration receipt
7. verified rollback/recovery receipt

Anything else is commentary only and must not be presented as completion.
