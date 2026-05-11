-- Synal Doolittle V2 — reality_ledger insert
-- Wrap inside troy-sql-executor NESTED payload, e.g.
--   {"name":"troy-sql-executor","payload":{"sql":"<contents of this file>"}}
-- Per memory: audit.log REST 404 trap → write public.reality_ledger directly.

INSERT INTO public.reality_ledger (
  task_id, intent, execution, output, status, evidence, score, created_at
) VALUES (
  'synal-doolittle-v2-build-20260508'::uuid,
  'Build Synal Doolittle V2 multi-party translation operating room (white-label SaaS, COAX/CROUX/F-COAX doctrine)',
  jsonb_build_object(
    'schema', 'doolittle',
    'tables', ARRAY['tenants','tenant_limits','project_spaces','threads','parties',
                    'thread_parties','messages','attachments','evidence_logs',
                    'resource_allocations','decisions','exports'],
    'rls', 'enabled on all 12 tables; svc_all policy bound to service_role',
    'seeded', jsonb_build_object('parties',12,'tenants',1,'project_spaces',3,'tenant_limits',1),
    'pack_root', '/home/claude/SYNAL_DOOLITTLE_V2/',
    'pack_target', 'TML-4PM/the-pen/SYNAL_DOOLITTLE_V2/',
    'pack_files', 9,
    'pack_bytes', 67290
  ),
  jsonb_build_object(
    'product', 'Synal Doolittle',
    'version', 'V2',
    'parties_supported', ARRAY['human','doolittle','croux-g','croux-c','croux-x','croux-p',
                               'f-coax','animal','device','system','external','bridge'],
    'persistence_modes', ARRAY['OFF','LOCAL','PROJECT','PROOF']
  ),
  'PARTIAL',
  jsonb_build_array(
    jsonb_build_object('type','database_result','name','doolittle.parties count','value',12),
    jsonb_build_object('type','database_result','name','doolittle.tenants count','value',1),
    jsonb_build_object('type','database_result','name','doolittle.project_spaces count','value',3),
    jsonb_build_object('type','hash','name','app/index.html','value','202a9ddc043e33590eea6c6d62551ccd86879931651530327123d5ee876027f2'),
    jsonb_build_object('type','hash','name','schema/01_tables.sql','value','e2bca2d92f460923908330d4671ba0b72e8630a45e177f927385403e23a0ed15'),
    jsonb_build_object('type','hash','name','schema/02_seed.sql','value','df221449079143d7bb64c4c1e9e9f9379e9f55063ed423760b5d0f857c647539'),
    jsonb_build_object('type','hash','name','bridge/push_pack.sh','value','4d1cde7e6c2ddb1901888271b18e42c0a9f61a97760f9f1509143eea9641157a'),
    jsonb_build_object('type','cli_output','name','node --check on embedded JS','value','returncode 0')
  ),
  jsonb_build_object(
    'value_score', 0.95,
    'confidence', 0.85,
    'economic_potential', 0.70,
    'execution', 0.30, 'evidence', 0.20, 'economic', 0.20, 'reuse', 0.15, 'delta', 0.10,
    'wave10_overall', 'PARTIAL'
  ),
  now()
)
ON CONFLICT (task_id) DO UPDATE SET
  status = EXCLUDED.status,
  execution = EXCLUDED.execution,
  evidence = EXCLUDED.evidence,
  score = EXCLUDED.score
RETURNING task_id, status, score->>'value_score' AS value_score, created_at;
