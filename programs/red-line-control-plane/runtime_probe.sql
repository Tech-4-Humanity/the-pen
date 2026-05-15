-- Runtime probe pack
-- Run via troy-sql-executor

SELECT current_timestamp AS probe_started;

-- fn exists
SELECT proname FROM pg_proc WHERE proname='fn_github_push';

-- secret exists (non destructive)
SELECT key,is_deprecated FROM public.cap_secrets WHERE key IN ('GITHUB_PAT','GITHUB_TOKEN');

-- http extension exists
SELECT extname FROM pg_extension WHERE extname='http';

-- receipt table exists
SELECT table_name FROM information_schema.tables WHERE table_name='t4h_canonical_changes';
