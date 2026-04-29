-- 2026-04-29: 1-touch GitHub PAT rotation
-- Atomic rotate: writes new value to cap_secrets, clears burn-state, logs canonical change.
-- Caller pattern (Troy): SELECT public.fn_rotate_github_pat('ghp_NEW_TOKEN','GITHUB_PAT','token notes');

CREATE OR REPLACE FUNCTION public.fn_rotate_github_pat(
  p_new_value text,
  p_key text DEFAULT 'GITHUB_PAT',
  p_notes text DEFAULT NULL,
  p_caller text DEFAULT 'manual'
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  v_old_len int;
  v_new_len int := length(p_new_value);
  v_canon_id bigint;
  v_today text := to_char(now(), 'YYYY-MM-DD');
  v_notes text;
BEGIN
  -- Guards
  IF p_key NOT IN ('GITHUB_PAT', 'GITHUB_TOKEN') THEN
    RETURN jsonb_build_object('ok', false, 'error', 'p_key must be GITHUB_PAT or GITHUB_TOKEN');
  END IF;
  IF v_new_len < 40 OR p_new_value !~ '^(ghp_|github_pat_)' THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid PAT format (expected ghp_ or github_pat_ prefix, length >= 40)');
  END IF;

  -- Capture old metadata (we deliberately do NOT log old value)
  SELECT length(value) INTO v_old_len FROM cap_secrets WHERE key = p_key;
  IF v_old_len IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', format('key %s does not exist in cap_secrets', p_key));
  END IF;

  v_notes := format(
    '%s exp YYYY-MM-DD - rotated %s by %s%s',
    CASE WHEN p_key='GITHUB_PAT' THEN 'Primary write PAT' ELSE 'PAT_2 write-capable' END,
    v_today,
    p_caller,
    CASE WHEN p_notes IS NOT NULL THEN E'\n' || p_notes ELSE '' END
  );

  -- Atomic update
  UPDATE cap_secrets
     SET value = p_new_value,
         notes = v_notes,
         is_deprecated = false,
         updated_at = now()
   WHERE key = p_key;

  -- Log canonical change (no value leakage)
  INSERT INTO t4h_canonical_changes (
    change_type, severity, title, summary,
    affected, broadcast_to, broadcast_ok,
    author, is_rd, project_code, business_keys, audiences
  ) VALUES (
    'SYSTEM_CHANGE', 'NORMAL',
    format('%s rotated', p_key),
    format('1-touch rotation: %s rotated %s by %s. old_len=%s new_len=%s. cleared burn-state, is_deprecated=false.',
           p_key, v_today, p_caller, v_old_len, v_new_len),
    ARRAY['cap_secrets', p_key, 'github-write-path']::text[],
    ARRAY['operator', 'ai-llms']::text[], false,
    p_caller, false, NULL,
    ARRAY['T4H']::text[],
    ARRAY['ENG_AUDIT','KB_SOP']::gov_audience[]
  ) RETURNING id INTO v_canon_id;

  RETURN jsonb_build_object(
    'ok', true,
    'key', p_key,
    'rotated_at', now(),
    'rotated_by', p_caller,
    'old_len', v_old_len,
    'new_len', v_new_len,
    'canonical_change_id', v_canon_id
  );
END
$fn$;

COMMENT ON FUNCTION public.fn_rotate_github_pat(text,text,text,text) IS
  '1-touch GitHub PAT rotation. Atomic update of cap_secrets + canonical change log. '
  'Validates ghp_/github_pat_ prefix and minimum length. No value leakage to logs.';

-- One-shot helper: verify the new PAT works end-to-end (does a no-op API call)
CREATE OR REPLACE FUNCTION public.fn_test_github_pat(
  p_key text DEFAULT 'GITHUB_PAT'
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  v_token text;
  v_resp record;
BEGIN
  SELECT value INTO v_token FROM cap_secrets WHERE key = p_key AND NOT is_deprecated LIMIT 1;
  IF v_token IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'no active PAT for ' || p_key);
  END IF;
  SELECT * INTO v_resp FROM public.http((
    'GET'::http_method,
    'https://api.github.com/user',
    ARRAY[
      public.http_header('Authorization', 'Bearer ' || v_token),
      public.http_header('Accept', 'application/vnd.github+json'),
      public.http_header('User-Agent', 't4h-pat-test'),
      public.http_header('X-GitHub-Api-Version', '2022-11-28')
    ],
    NULL, NULL
  )::public.http_request);
  RETURN jsonb_build_object(
    'ok', v_resp.status BETWEEN 200 AND 299,
    'key', p_key,
    'http_status', v_resp.status,
    'login', (v_resp.content::jsonb)->>'login',
    'scopes_header_hint', 'check x-oauth-scopes header in CloudWatch if unsure'
  );
END
$fn$;
