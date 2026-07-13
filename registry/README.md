# Portfolio Deployment Registry

This directory converts prior Google Drive workbooks into one executable deployment-control model.

## Source workbooks

1. `T4H_Vercel_S3_Migration_EXECUTE_NOW_v3_REVIEWED.xlsx`
2. `Vercel_To_S3_Migration_Master.xlsx`
3. `T4H_Master_Infrastructure_Map_REBUILT_v2(1).xlsx`

Workbook values are historical evidence. They do not become executable facts until AWS, GitHub, DNS and live-content readback mark the relevant fields `VERIFIED`.

## Field states

- `OBSERVED` — seen directly but not fully verified.
- `STALE` — imported from an older source and must be refreshed.
- `CONFLICTING` — authoritative sources disagree.
- `MISSING` — no usable value exists.
- `VERIFIED` — runtime readback and receipt prove the value.

## Status gate

A target may be `REAL` only when repository, committed artefact, S3 bucket, CloudFront distribution, HTTPS URL, content identity and rollback source are present and the critical fields are `VERIFIED`.

## Validate all seeded targets

```bash
python3 scripts/validate_portfolio_deployment_registry.py \
  --registry registry/portfolio-deployment-targets.json \
  --receipt receipts/portfolio-registry/latest-validation.json
```

## Validate one target

```bash
python3 scripts/validate_portfolio_deployment_registry.py \
  --registry registry/portfolio-deployment-targets.json \
  --target the-pen-production
```

The validator performs no AWS changes.

## Current seed scope

The first tranche includes the two runtime-proven targets plus the highest-priority public sites found in the earlier Drive migration registers. Remaining infrastructure-map rows must be imported in later tranches and remain non-executable until verified.
