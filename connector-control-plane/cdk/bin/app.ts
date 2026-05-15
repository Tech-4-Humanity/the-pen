#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { ConnectorControlPlaneStack } from '../lib/connector-control-plane-stack';
import { ServiceCatalogStack } from '../lib/service-catalog-stack';
import { CCP } from '../lib/constants';

const app = new cdk.App();

const env = {
  account: process.env.CDK_DEFAULT_ACCOUNT ?? CCP.ACCOUNT,
  region:  process.env.CDK_DEFAULT_REGION  ?? CCP.REGION,
};

const tags = {
  Owner: CCP.OWNER,
  Product: CCP.PRODUCT,
  CostCenter: CCP.COST_CENTER,
  Environment: process.env.CCP_ENV ?? 'prod',
  ABN: '70 666 271 272',
};

const ccp = new ConnectorControlPlaneStack(app, 'ConnectorControlPlane', {
  env,
  description: 'Connector Control Plane — Lambda workers, ledger, intent routing, health probes.',
  tags,
});

new ServiceCatalogStack(app, 'ConnectorControlPlaneCatalog', {
  env,
  description: 'AWS Service Catalog product wrapper for Connector Control Plane.',
  tags,
  controlPlaneStackName: ccp.stackName,
});

app.synth();
