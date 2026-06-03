# troy-runtime-proof-sweeper — Deploy Instructions

## Status
Lambda does not yet exist in AWS. Must be created.

## Runtime
- Runtime: Node.js 20.x
- Region: ap-southeast-2
- Memory: 128MB
- Timeout: 60s
- Architecture: x86_64

## Required env vars
```
SUPABASE_URL=https://lzfgigiyqpuuxslsygjt.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<from cap_secrets>
```

## Deploy steps
```bash
npm install
zip -r function.zip index.js node_modules package.json

aws lambda create-function \
  --function-name troy-runtime-proof-sweeper \
  --runtime nodejs20.x \
  --role arn:aws:iam::140548542136:role/lambda-execution-role \
  --handler index.handler \
  --zip-file fileb://function.zip \
  --timeout 60 \
  --memory-size 128 \
  --region ap-southeast-2

# Set env vars
aws lambda update-function-configuration \
  --function-name troy-runtime-proof-sweeper \
  --environment "Variables={SUPABASE_URL=https://lzfgigiyqpuuxslsygjt.supabase.co,SUPABASE_SERVICE_ROLE_KEY=<key>}" \
  --region ap-southeast-2

# Set concurrency
aws lambda put-function-concurrency \
  --function-name troy-runtime-proof-sweeper \
  --reserved-concurrent-executions 2 \
  --region ap-southeast-2
```

## After deploy
1. Test invoke: `aws lambda invoke --function-name troy-runtime-proof-sweeper --region ap-southeast-2 out.json && cat out.json`
2. Verify audit.log row written
3. Re-enable cron: `SELECT cron.schedule('runtime_proof_sweeper_hourly', '15 * * * *', 'SELECT public.fn_runtime_proof_sweeper_kick()')`
4. Reset blocked jobs: `UPDATE ops.work_queue SET status = 'ready', blocked_reason = NULL, updated_at = NOW() WHERE status = 'blocked' AND topic = 'runtime_proof_sweeper'`

## Bridge registration
Add to Lambda registry after deploy:
```sql
INSERT INTO public.lambda_registry (fn_name, description, status)
VALUES ('troy-runtime-proof-sweeper', 'Sweeps stalled work_queue jobs. Advances done->verified.', 'active')
ON CONFLICT (fn_name) DO UPDATE SET status = 'active', updated_at = NOW();
```
