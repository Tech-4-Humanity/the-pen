-- 2026-04-24 fn_github_push patch
-- Problem: pg_net 0.14 dropped net.http_put and net.http_request(method,url,headers,body) signature.
-- Effect: fn_github_push returned sql_error, breaking outbound GitHub writes from the bridge.
-- Fix: use the synchronous `http` extension (v1.6, already installed) via http_request record.
-- Applied live via troy-sql-executor on 2026-04-24 by claude-opus-4.7.
-- This file exists so the patch survives any DB rebuild from migrations.

-- Drop the broken 4-arg overload (calls net.http_put which no longer exists)
DROP FUNCTION IF EXISTS public.fn_github_push(text, text, text, text);

CREATE OR REPLACE FUNCTION public.fn_github_push(
  p_repo text,
  p_path text,
  p_content text,
  p_message text,
  p_branch text DEFAULT 'main'
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $fn$
DECLARE
  v_token text;
  v_b64 text;
  v_existing_sha text;
  v_get_resp record;
  v_put_resp record;
  v_body jsonb;
BEGIN
  SELECT value INTO v_token
    FROM public.cap_secrets
   WHERE key = 'GITHUB_PAT' AND NOT is_deprecated
   LIMIT 1;
  IF v_token IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'no PAT in cap_secrets');
  END IF;

  v_b64 := replace(encode(convert_to(p_content, 'UTF8'), 'base64'), chr(10), '');

  -- GET existing sha if the file exists (required for GitHub contents PUT on updates)
  SELECT * INTO v_get_resp FROM public.http((
    'GET'::http_method,
    'https://api.github.com/repos/' || p_repo || '/contents/' || p_path || '?ref=' || p_branch,
    ARRAY[
      public.http_header('Authorization', 'Bearer ' || v_token),
      public.http_header('Accept', 'application/vnd.github+json'),
      public.http_header('User-Agent', 't4h-fn-github-push'),
      public.http_header('X-GitHub-Api-Version', '2022-11-28')
    ],
    NULL,
    NULL
  )::public.http_request);

  IF v_get_resp.status = 200 THEN
    v_existing_sha := (v_get_resp.content::jsonb)->>'sha';
  END IF;

  v_body := jsonb_build_object('message', p_message, 'content', v_b64, 'branch', p_branch);
  IF v_existing_sha IS NOT NULL THEN
    v_body := v_body || jsonb_build_object('sha', v_existing_sha);
  END IF;

  -- PUT (create or update)
  SELECT * INTO v_put_resp FROM public.http((
    'PUT'::http_method,
    'https://api.github.com/repos/' || p_repo || '/contents/' || p_path,
    ARRAY[
      public.http_header('Authorization', 'Bearer ' || v_token),
      public.http_header('Accept', 'application/vnd.github+json'),
      public.http_header('User-Agent', 't4h-fn-github-push'),
      public.http_header('X-GitHub-Api-Version', '2022-11-28')
    ],
    'application/json',
    v_body::text
  )::public.http_request);

  IF v_put_resp.status BETWEEN 200 AND 299 THEN
    RETURN jsonb_build_object(
      'success',     true,
      'status',      v_put_resp.status,
      'path',        p_path,
      'content_sha', (v_put_resp.content::jsonb) #>> '{content,sha}',
      'commit_sha',  (v_put_resp.content::jsonb) #>> '{commit,sha}',
      'html_url',    (v_put_resp.content::jsonb) #>> '{content,html_url}'
    );
  ELSE
    RETURN jsonb_build_object(
      'success', false,
      'status',  v_put_resp.status,
      'body',    left(v_put_resp.content::text, 1000)
    );
  END IF;
END
$fn$;

COMMENT ON FUNCTION public.fn_github_push(text, text, text, text, text) IS
  'Patched 2026-04-24: uses public.http_* (sync) via http extension v1.6. '
  'Previous net.http_request broke when pg_net 0.14 dropped PUT. '
  'Uses cap_secrets.GITHUB_PAT. Idempotent (fetches sha if file exists).';
