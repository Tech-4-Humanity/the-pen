# 60_ram_deployment_notes.md

## Order of deployment

1. Schema: apply 01_ram_schema.sql via Supabase REST (run_sql RPC) on S1 lzfgigiyqpuuxslsygjt
2. RLS: apply 02_ram_rls_policies.sql
3. Workers: deploy Lambdas (ram-normalizer, ram-validator, ram-portfolio)
   - Role: arn:aws:iam::140548542136:role/lambda-execution-role
4. Register in mcp_lambda_registry: business_key=RAM, is_callable=false initially (PARTIAL)
5. Bridge route: add ram-* to allowlist with TOP-LEVEL envelope; troy-sql-executor remains NESTED-only
6. Command Centre widgets: register each from 40_ram_command-centre_widgets.tsx in t4h_ui_snippet
7. Dogfood ingestion: run ram_scout against TML-4PM/the-pen + TML-4PM/mcp-command-centre first
8. First validation pass: run ram_validator on at least 25 assets
9. First portfolio cards: generate 5 cards for brand=Outcome Ready, audience=gov
10. Dev inspection: open RCPT_ram_dev-inspection_ram_dogfood-first_20260512
11. Prod promotion: only after dev=REAL

## RDTI tag
- is_rd = true
- project_code = RAM-DGF-2026Q4
- Tag every Lambda, table, and package at creation

## Kill switch
- cap_secrets row ram_kill_switch=true halts all RAM Lambdas
- CFN parameter RamEnabled defaults to true, set to false to disable stack
- Watchers respect the kill switch within 60s

## Cost gate
- Per-asset compute budget: <= 2000 tokens of LLM time, <= 50ms worker time average
- Orphan timeout: 24h
- Zombie agents forbidden; ram_watcher enforces

## Rollback
- Schema rollback path: drop table if exists public.ram_* cascade (only via troy-cfn-deployer with CAPABILITY_NAMED_IAM)
- Lambda rollback: previous version retained for 7 days
- Bridge allowlist rollback: revert to prior commit in router config

## Health checks
- select count(*) from public.ram_assets returns >0 within 24h of dogfood start
- select count(*) from public.ram_asset_evidence where status='REAL' returns >0 before dev inspection
- select status from public.ram_dev_inspections order by created_at desc limit 1 must be REAL before prod promotion

## CIP exception
RAM Lambdas are subject to the CIP exception: HITL default per asset, remediations require cip.approvals.status='approved'. No new RAM Lambdas without explicit per-deploy approval.
