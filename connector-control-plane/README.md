# Connector Control Plane

Amazon-grade AI runtime infrastructure for persistent connector authority, session continuity, health monitoring, intent routing, fallback dispatch, and evidence-bound receipts.

## Production Contract

This package is not a builder-layer document. It is the deployable operating package for a service-catalog-ready control plane.

## Components

- CDK application scaffold
- Connector registry schema
- Session passport schema
- Intent route registry
- Runtime receipt ledger
- Lambda health worker
- Lambda intent router
- Lambda receipt writer
- AWS Service Catalog metadata
- GitHub Actions CI
- Bridge promotion payload
- Operations and recovery runbooks

## Deploy Locally

```bash
cd connector-control-plane/cdk
npm install
npm run build
npm run synth
```

## Promote Through Bridge

Use:

```text
connector-control-plane/bridge/promote-connector-control-plane-v1.json
```

## Reality Status

PARTIAL until runtime deploy receipts, health worker receipts, and Service Catalog registration receipts exist.

## Required Proof For REAL

- GitHub source commit receipt
- CDK synth receipt
- deployment receipt
- first connector health receipt
- Service Catalog registration receipt
- Reality Ledger write receipt
