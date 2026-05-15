import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as lambdaNodejs from 'aws-cdk-lib/aws-lambda-nodejs';
import * as events from 'aws-cdk-lib/aws-events';
import * as targets from 'aws-cdk-lib/aws-events-targets';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as apigw from 'aws-cdk-lib/aws-apigatewayv2';
import * as integrations from 'aws-cdk-lib/aws-apigatewayv2-integrations';
import * as cloudwatch from 'aws-cdk-lib/aws-cloudwatch';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import * as path from 'path';

export class ConnectorControlPlaneStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ---------- Secrets ----------
    const supabaseSecret = new secretsmanager.Secret(this, 'SupabaseSecret', {
      secretName: 'ccp/supabase',
      description: 'Supabase service-role URL + key for CCP ledger writes.',
    });

    // ---------- DLQ ----------
    const dlq = new sqs.Queue(this, 'CcpDlq', {
      queueName: 'ccp-dlq',
      retentionPeriod: cdk.Duration.days(14),
    });

    // ---------- Hot-state table (idempotency + last-known health) ----------
    const stateTable = new dynamodb.Table(this, 'CcpState', {
      tableName: 'ccp-state',
      partitionKey: { name: 'pk', type: dynamodb.AttributeType.STRING },
      sortKey:      { name: 'sk', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      pointInTimeRecoverySpecification: { pointInTimeRecoveryEnabled: true },
      timeToLiveAttribute: 'ttl',
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    // ---------- Lambda defaults ----------
    const sharedEnv: Record<string, string> = {
      CCP_STATE_TABLE: stateTable.tableName,
      CCP_DLQ_URL: dlq.queueUrl,
      CCP_SUPABASE_SECRET_ARN: supabaseSecret.secretArn,
      LOG_LEVEL: 'info',
      NODE_OPTIONS: '--enable-source-maps',
    };

    const mkFn = (logicalId: string, fnName: string, entry: string, extra: Partial<lambdaNodejs.NodejsFunctionProps> = {}) =>
      new lambdaNodejs.NodejsFunction(this, logicalId, {
        functionName: fnName,
        runtime: lambda.Runtime.NODEJS_20_X,
        architecture: lambda.Architecture.ARM_64,
        memorySize: 512,
        timeout: cdk.Duration.seconds(30),
        logRetention: logs.RetentionDays.ONE_MONTH,
        tracing: lambda.Tracing.ACTIVE,
        environment: sharedEnv,
        deadLetterQueueEnabled: true,
        deadLetterQueue: dlq,
        entry: path.join(__dirname, '../../lambda', entry),
        handler: 'handler',
        bundling: {
          minify: true,
          sourceMap: true,
          target: 'node20',
          externalModules: ['@aws-sdk/*'],
        },
        ...extra,
      });

    const healthWorker  = mkFn('HealthWorker',  'ccp-health-worker',  'health-worker.ts',  { timeout: cdk.Duration.minutes(2) });
    const intentRouter  = mkFn('IntentRouter',  'ccp-intent-router',  'intent-router.ts');
    const receiptWriter = mkFn('ReceiptWriter', 'ccp-receipt-writer', 'receipt-writer.ts');

    for (const fn of [healthWorker, intentRouter, receiptWriter]) {
      stateTable.grantReadWriteData(fn);
      supabaseSecret.grantRead(fn);
      dlq.grantSendMessages(fn);
    }

    // ---------- EventBridge schedule (every 5 min) ----------
    new events.Rule(this, 'HealthSchedule', {
      ruleName: 'ccp-health-schedule',
      schedule: events.Schedule.rate(cdk.Duration.minutes(5)),
      targets: [new targets.LambdaFunction(healthWorker, {
        retryAttempts: 2,
        deadLetterQueue: dlq,
      })],
    });

    // ---------- HTTP API for intent routing ----------
    const api = new apigw.HttpApi(this, 'CcpApi', {
      apiName: 'ccp-api',
      description: 'Connector Control Plane intent routing API.',
      corsPreflight: {
        allowOrigins: ['*'],
        allowMethods: [apigw.CorsHttpMethod.POST, apigw.CorsHttpMethod.GET],
        allowHeaders: ['content-type', 'authorization'],
      },
    });

    api.addRoutes({
      path: '/intent',
      methods: [apigw.HttpMethod.POST],
      integration: new integrations.HttpLambdaIntegration('IntentInt', intentRouter),
    });
    api.addRoutes({
      path: '/receipt',
      methods: [apigw.HttpMethod.POST],
      integration: new integrations.HttpLambdaIntegration('ReceiptInt', receiptWriter),
    });
    api.addRoutes({
      path: '/health',
      methods: [apigw.HttpMethod.GET],
      integration: new integrations.HttpLambdaIntegration('HealthInt', healthWorker),
    });

    // ---------- Alarms ----------
    const errorAlarm = (fn: lambda.IFunction, key: string) =>
      new cloudwatch.Alarm(this, `${key}Errors`, {
        alarmName: `ccp-${fn.functionName}-errors`,
        metric: fn.metricErrors({ period: cdk.Duration.minutes(5) }),
        threshold: 3,
        evaluationPeriods: 2,
        treatMissingData: cloudwatch.TreatMissingData.NOT_BREACHING,
      });
    errorAlarm(healthWorker,  'HealthWorker');
    errorAlarm(intentRouter,  'IntentRouter');
    errorAlarm(receiptWriter, 'ReceiptWriter');

    new cloudwatch.Alarm(this, 'DlqDepth', {
      alarmName: 'ccp-dlq-depth',
      metric: dlq.metricApproximateNumberOfMessagesVisible(),
      threshold: 1,
      evaluationPeriods: 1,
      treatMissingData: cloudwatch.TreatMissingData.NOT_BREACHING,
    });

    // ---------- Outputs ----------
    new cdk.CfnOutput(this, 'ApiUrl',           { value: api.apiEndpoint });
    new cdk.CfnOutput(this, 'StateTableName',   { value: stateTable.tableName });
    new cdk.CfnOutput(this, 'DlqUrl',           { value: dlq.queueUrl });
    new cdk.CfnOutput(this, 'SupabaseSecretArn',{ value: supabaseSecret.secretArn });
  }
}
