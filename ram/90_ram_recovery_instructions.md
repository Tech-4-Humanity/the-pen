# 90_ram_recovery_instructions.md

## Purpose
Make RAM survivable across session loss, workstation loss, bridge failure, and partial deployment.

## Session-start protocol
1. Pin bridge DNS:
   ```
   python3 -c "import socket; H='zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com'; t=open('/etc/hosts').read(); H in t or open('/etc/hosts','a').write(socket.gethostbyname(H)+' '+H+'\n')"
   ```
2. Read BLOCKED rows from Reality Ledger:
   ```sql
   select * from public.reality_ledger where status='BLOCKED';
   ```
3. Check RAM Lambdas via `aws_lambda_inspect` (functionName)
4. Check most recent RAM package status:
   ```sql
   select package_name, status, receipt_uri from public.ram_packages
   order by updated_at desc limit 5;
   ```

## Bridge failure recovery
- If bridge returns 4xx: verify auth headers (`x-api-key` BRIDGE_ROUTER_KEY + `Authorization: Bearer` BRIDGE_API_KEY)
- If 5xx: retry with exponential backoff (max 3), then mark `BLOCKED`
- If DNS fail: re-run bridge DNS pin
- If `troy-sql-executor` returns `rows:[]` unexpectedly: check for trailing `;`, verify via PostgREST direct read

## Schema rollback
- Schema rollback gated through `troy-cfn-deployer` with `CAPABILITY_NAMED_IAM`
- Never drop tables directly via `troy-sql-executor`
- All RAM tables retain audit history via `audit.log`

## Lambda recovery
- Use `troy-cfn-deployer` for IAM-bound deploys (`lovable-mcp-client` has no IAM writes)
- Previous version retained 7 days; redeploy via `troy-lambda-deploy` (TOP-LEVEL envelope)
- `troy-code-pusher` is a Lambda code updater only; not a GitHub file pusher

## Partial deployment recovery
If only schema is deployed but no workers:
- Mark RAM as PARTIAL, status=BLOCKED on prod promotions
- Workers can be deployed independently; schema does not depend on them

If workers are deployed but schema is missing:
- Workers will fail closed (no asset rows to operate on)
- No false REAL states are possible

## Receipt recovery
If a package was sent to GitHub but no receipt was captured:
- Read commit history via `T4H Remote MCP Clean:github_file_read` to recover SHAs
- Back-fill `ram_packages.manifest.commits[]`
- Write `audit.log` retroactively with reason=`receipt_recovered`

## Identity / runtime drift
- If `runtime_id` mismatch detected: quarantine the asset, write `ram_watch_events` severity=`critical`
- If identity drift detected: STAMP approval required before remediation

## Kill switch
- Set `cap_secrets.ram_kill_switch=true` to halt all RAM Lambdas within 60s
- CFN parameter `RamEnabled=false` halts the stack

## Replay
- Every RAM action is idempotent and replayable
- `ram_asset_lineage` enables full rename history
- `ram_asset_evidence` enables full evidence reconstruction

## Quarantine policy
- An asset is quarantined after 3 consecutive validation failures
- A quarantined asset is excluded from portfolio surfaces until manually reclassified
- A quarantined Lambda is removed from the bridge allowlist until inspection passes

## Catastrophic recovery
If the entire RAM stack is lost:
1. Re-apply `01_ram_schema.sql` and `02_ram_rls_policies.sql`
2. Re-deploy workers via `troy-cfn-deployer`
3. Re-register widgets in `t4h_ui_snippet`
4. Re-ingest from canonical sources (Pen, Command Centre)
5. Mark all RAM as PARTIAL until at least one full validation pass completes
6. Run dev inspection before any prod promotion
