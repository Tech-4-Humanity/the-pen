# CCP — Status

**Date:** 2026-05-16 (Sydney)  
**Repo:** TML-4PM/the-pen  
**Path:** connector-control-plane/

## Promotion pipeline

| Stage | Item                                  | State    | Evidence                                |
| ----- | ------------------------------------- | -------- | --------------------------------------- |
| 1     | GitHub canonical package              | REAL     | This commit batch                       |
| 2     | Supabase schema apply                 | PENDING  | `make schema` against $SUPABASE_DB_URL  |
| 3     | Deploy Lambda workers                 | PENDING  | `make deploy` (or GHA workflow)         |
| 4     | First health probe receipt            | PENDING  | row in `public.ccp_receipts`            |
| 5     | First intent receipt                  | PENDING  | row in `public.ccp_receipts`            |
| 6     | AWS Service Catalog publish           | PENDING  | Service Catalog product ID              |

## What was just shipped
- Full CDK app (`cdk/`) — `ConnectorControlPlaneStack` + `ServiceCatalogStack`.
- Three Lambda workers (`lambda/`) — health probe, intent router, receipt writer.
- Canonical Postgres schema + seed + indexes (`db/`).
- GitHub Actions deploy pipeline (`.github/workflows/ccp-deploy.yml` at repo root).
- AWS Service Catalog product metadata + launch constraints (`service-catalog/`).
- Bridge promotion payload (`bridge/promote.json`).
- Runbook (`runbook.md`), SLOs (`SLO.md`), ownership (`OWNERS`), one-command bootstrap (`Makefile`).

## Classification
**State:** PARTIAL  
**Reason:** Source committed and one-command provisionable; runtime deploy receipts and first execution receipts still required to reach REAL per the SLO definition.  
**Next action:** `make bootstrap` or trigger GHA `ccp-deploy` with `stage=deploy`.
