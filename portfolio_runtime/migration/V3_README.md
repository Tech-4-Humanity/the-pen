# Vercel-to-AWS Migration v3

Issue: #304

This package converts the estate migration from per-site recovery scripts into a
manifest-driven, resumable workflow. The current tranche is the guarded planning
foundation. It does **not** perform AWS mutations and therefore cannot classify a
site as REAL.

## Run the Outcome Ready plan

```bash
python3 portfolio_runtime/migration/vercel-estate-to-aws-v3.py \
  portfolio_runtime/migration/manifests/outcome-ready.v3.json \
  --run-root runtime/migration-runs/outcome-ready \
  --plan-only
```

## Run tests

```bash
python3 -m unittest \
  portfolio_runtime/migration/tests/test_vercel_estate_to_aws_v3.py
```

## Gate model

The ordered stages are source refresh, inventory, route classification, build,
S3 publish/readback, CloudFront, ACM, pre-cutover validation, DNS snapshot,
Route53 cutover, live HTTPS validation, rollback window and final receipt.

Every non-static route needs an owner, reason, dependency, lifecycle state and
evidence. Required routes cannot disappear from the inventory. Planning and
successful checkpoints remain PARTIAL until execution also supplies provider
readback, receipts, ledger entries, telemetry, live validation and tested
recovery.

## Next implementation tranche

Add idempotent adapters and tests for:

1. versioned S3 publication and hash readback;
2. CloudFront and ACM create/reuse;
3. CloudFront-hostname acceptance before DNS mutation;
4. Route53 snapshot, cutover and rollback;
5. public HTTPS route and asset validation;
6. dynamic-runtime targets;
7. immutable per-site and estate reconciliation receipts.
