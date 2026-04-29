INSERT INTO mcp_lambda_registry (
    function_name, category, subcategory, runtime, memory_mb, timeout_sec, iam_role,
    status, business_key, description, invocation_pattern, github_repo,
    is_rdti_relevant, is_callable, callable_reason, callable_set_at, callable_set_by
) VALUES (
    'troy-forge-trial-sweep',
    'forge', 'trial', 'python3.12', 512, 300,
    'arn:aws:iam::140548542136:role/lambda-execution-role',
    'active',
    'T4H',
    'Forge alpha trial sweep: read JSON files from S3 prefix, sample N records, write receipt. Action: forge.run_trial_sweep. Project: OUTRD-FORGE-001.',
    'DIRECT',
    'TML-4PM/the-pen',
    true,
    true,
    'Forge alpha trial pod registered for bridge invocation',
    now(),
    'master_orchestrator'
)
ON CONFLICT (function_name) DO UPDATE
SET category=EXCLUDED.category,
    subcategory=EXCLUDED.subcategory,
    runtime=EXCLUDED.runtime,
    memory_mb=EXCLUDED.memory_mb,
    timeout_sec=EXCLUDED.timeout_sec,
    iam_role=EXCLUDED.iam_role,
    status='active',
    description=EXCLUDED.description,
    invocation_pattern=EXCLUDED.invocation_pattern,
    is_rdti_relevant=true,
    is_callable=true,
    callable_reason=EXCLUDED.callable_reason,
    callable_set_at=now(),
    callable_set_by=EXCLUDED.callable_set_by;
