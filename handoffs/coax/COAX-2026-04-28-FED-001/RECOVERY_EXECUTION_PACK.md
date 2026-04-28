# RECOVERY EXECUTION PACK — COAX REL deploy stalled

## Thread
COAX-2026-04-28-FED-001

## Origin
https://github.com/TML-4PM/the-pen/issues/27

## Current validated state
- GitHub issue exists.
- Watchdog is active.
- Acceptance request was posted.
- No executor acknowledgement was visible at validation time.
- No bridge_request_id was visible.
- No CloudWatch runtime proof was visible.
- No Supabase proof was visible.
- Reality classification: PARTIAL.
- Operational state: BLOCKED_NO_EXECUTOR_RESPONSE.

## Recovery goal
Move from passive handoff to executable dev/bridge acceptance.

## Owner role
Pen or Bridge first. Symbio may execute DEV wiring. Synapse only after production evidence gate.

## Required build actions
1. Create executable branch or PR referencing issue #27.
2. Materialise assets from the issue body into repo paths:
   - docs/EXECUTION_BRIEF.md
   - docs/REALITY_CALL.md
   - docs/REL_EXPANDED_PASS.md
   - docs/coax-g-orchestrator.md
   - docs/coax-c-spec.md
   - sql/pcs_coax_v1.sql
   - lambdas/coax-verifier-lambda.py
   - schemas/coax-exchange.schema.json
   - scripts/coax-smoke-test.sh
3. Deploy SQL via Bridge dry-run then execute.
4. Deploy verifier Lambda.
5. Run smoke test.
6. Emit machine receipt under receipts/runtime/coax/.
7. Comment back on issue #27 with acceptance or blocker.

## Acceptance JSON
```json
{
  "thread_id": "COAX-2026-04-28-FED-001",
  "status": "ACCEPTED_BY_DEV_OR_BRIDGE",
  "github_commit_sha": "REQUIRED",
  "bridge_request_id": "REQUIRED_OR_BLOCKED_REASON",
  "cloudwatch_verified": false,
  "supabase_verified": false,
  "command_centre_verified": false,
  "reality": "PARTIAL_UNTIL_RUNTIME_PROOF"
}
```

## Blocker JSON
```json
{
  "thread_id": "COAX-2026-04-28-FED-001",
  "status": "BLOCKED",
  "blocking_layer": "Bridge|Supabase|AWS|GitHub|Executor|Secrets|Other",
  "blocking_reason": "specific missing authority or dependency",
  "next_executable_step": "specific action",
  "reality": "PARTIAL"
}
```

## Non-negotiable
Do not mark REAL from this recovery file alone. This file is an executable recovery trigger and acceptance rail only. REAL requires runtime evidence.
