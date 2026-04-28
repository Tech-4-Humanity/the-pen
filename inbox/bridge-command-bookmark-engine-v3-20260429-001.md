# BRIDGE COMMAND: Bookmark Execution Engine v3

job_id: bookmark-execution-engine-v3-20260429-001
mode: audit_queue_only
reality_state: PARTIAL_PENDING_RUNTIME_PROOF

## Command

Bridge runner must ingest the COAX Bookmark Execution Engine v3 bundle and stage it for audit execution.

## Required placement

- inbox/bookmark-execution-engine-v3-20260429-001.json
- supabase/supabase_commented_schema.sql
- runner/coax_task_runner_commented.py
- .github/workflows/bookmark_execution_engine_v3.yml

## Mandatory comments

- Keep schema comments.
- Keep runner stage comments.
- Receipt must say what ran, what changed, what remains blocked.

## Safety rails

- No deletes. Archive only.
- No payments.
- No credential changes.
- No IAM changes.

## Expected receipt

receipts/runtime/bookmark-execution-engine-v3-20260429-001.receipt.json

## Done definition

- GitHub action or bridge run creates receipt.
- Receipt includes evidence payload.
- Any blocked runtime step is listed explicitly.