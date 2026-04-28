# BRIDGE TRIGGER

job_id: bookmark-execution-engine-v3-20260429-001
trigger_id: bookmark-engine-v3-trigger-002
triggered_at_utc: 2026-04-29T00:00:00Z

## Execute

Pick up the existing command file:

`inbox/bridge-command-bookmark-engine-v3-20260429-001.md`

## Required output

Write runtime receipt:

`receipts/runtime/bookmark-execution-engine-v3-20260429-001.receipt.json`

## If blocked

Write blocked receipt with:

- error
- impact
- rollback
- next step

## Safety

Archive only. No delete. No payments. No credentials. No IAM.