import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as servicecatalog from 'aws-cdk-lib/aws-servicecatalog';
import * as path from 'path';

export interface ServiceCatalogStackProps extends cdk.StackProps {
  controlPlaneStackName: string;
}

export class ServiceCatalogStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: ServiceCatalogStackProps) {
    super(scope, id, props);

    const portfolio = new servicecatalog.Portfolio(this, 'CcpPortfolio', {
      displayName: 'Tech4Humanity Connector Control Plane',
      providerName: 'Tech 4 Humanity Pty Ltd',
      description: 'Provisionable AWS Service Catalog portfolio for the Connector Control Plane.',
    });

    const product = new servicecatalog.CloudFormationProduct(this, 'CcpProduct', {
      productName: 'connector-control-plane',
      owner: 'Tech 4 Humanity Pty Ltd',
      description: 'CDK-generated control plane: Lambda workers, ledger, intent router, health probes.',
      productVersions: [{
        productVersionName: 'v0.1.0',
        cloudFormationTemplate: servicecatalog.CloudFormationTemplate.fromAsset(
          path.join(__dirname, '..', 'cdk.out', `${props.controlPlaneStackName}.template.json`),
        ),
        description: 'Initial productionised version.',
      }],
    });

    portfolio.addProduct(product);
  }
}
