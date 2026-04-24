import { LambdaClient, CreateFunctionCommand, UpdateFunctionCodeCommand } from '@aws-sdk/client-lambda';
import fs from 'node:fs';
import path from 'node:path';

const lambda = new LambdaClient({});

const FUNCTIONS = [
  {
    name: 't4h-route53-domain-sync',
    file: 'lambdas/t4h-route53-domain-sync/index.mjs',
    handler: 'index.handler'
  },
  {
    name: 't4h-domain-health-check',
    file: 'lambdas/t4h-domain-health-check/index.mjs',
    handler: 'index.handler'
  }
];

function zipBuffer(filePath) {
  const content = fs.readFileSync(filePath);
  return content;
}

async function upsertLambda(fn) {
  // working-directory is registry/domain-control-system — resolve relative to cwd
  const code = zipBuffer(path.resolve(process.cwd(), fn.file));
  try {
    await lambda.send(new UpdateFunctionCodeCommand({
      FunctionName: fn.name,
      ZipFile: code
    }));
    console.log(`Updated ${fn.name}`);
  } catch (e) {
    await lambda.send(new CreateFunctionCommand({
      FunctionName: fn.name,
      Runtime: 'nodejs20.x',
      Role: process.env.LAMBDA_EXEC_ROLE_ARN,
      Handler: fn.handler,
      Code: { ZipFile: code },
      Timeout: 30,
      MemorySize: 256,
      Environment: {
        Variables: {
          SUPABASE_URL: process.env.SUPABASE_URL,
          SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY
        }
      }
    }));
    console.log(`Created ${fn.name}`);
  }
}

for (const fn of FUNCTIONS) {
  await upsertLambda(fn);
}

console.log('Deploy complete');
