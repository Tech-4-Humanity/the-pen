# Session Onboarding Runtime

Status: REAL (file committed)

## Purpose
Every session open must restore prior execution context, prevent restart drift, and create a continuity receipt.

## Onboarding Sequence

1. Load `GLOBAL_RULE.md` + `MCP_EXECUTION_CONTRACT.md` + `ENFORCEMENT_LIVE.md`
2. Record instruction commit SHA
3. Pull last 10 Reality Ledger entries from Supabase
4. Pull open/partial issues from The Pen
5. Identify CRITICAL/BLOCKED items (priority order)
6. Write session open receipt to `ledger.reality_ledger`
7. Surface top 5 action items to operator

## Onboarding Receipt Schema

```json
{
  "event": "session_open",
  "session_id": "<uuid>",
  "instruction_sha": "<commit_sha>",
  "memory_age_hours": 0,
  "open_issues_count": 0,
  "critical_count": 0,
  "context_restored": true,
  "opened_at": "<iso8601>"
}
```

## Acceptance Criteria
- Session open writes receipt
- Prior context loaded from ledger
- CRITICAL items surfaced immediately
- No redundant approval prompts when context is clear
