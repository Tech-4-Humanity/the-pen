INSERT INTO t4h_canonical_changes (
    created_at, change_type, title, summary, affected, evidence_ref, author,
    broadcast_to, broadcast_ok, severity, body_md,
    is_rd, project_code, business_keys
) VALUES (
    now(),
    'SYSTEM_CHANGE',
    'Forge trial sweep pod registered',
    'Registered troy-forge-trial-sweep in mcp_lambda_registry with is_callable=true. Action forge.run_trial_sweep.',
    ARRAY['troy-forge-trial-sweep','mcp_lambda_registry'],
    'forge-alpha-trial-20260429-001',
    'master_orchestrator',
    ARRAY['T4H'],
    true,
    'NORMAL',
    'Forge alpha trial pod is now bridge-callable. Action forge.run_trial_sweep reads JSON/JSONL from S3 input prefix, samples N records (default 250), writes receipt JSON. Lambda role lambda-execution-role, py3.12, 512MB, 300s timeout.',
    true,
    'OUTRD-FORGE-001',
    ARRAY['T4H']
);
