# FORCE RUNNER COMMAND

job_id: bookmark-execution-engine-v3-20260429-001
force_id: force-runner-bookmark-engine-v3-003
mode: runtime_probe

## Objective

Confirm whether any bridge or worker is watching inbox commands and can write a receipt.

## Read inputs

- inbox/bridge-command-bookmark-engine-v3-20260429-001.md
- inbox/bridge-trigger-bookmark-engine-v3-20260429-002.md

## Required action

Write one of these receipts:

1. SUCCESS receipt:
   receipts/runtime/bookmark-execution-engine-v3-20260429-001.receipt.json

2. BLOCKED receipt:
   receipts/runtime/bookmark-execution-engine-v3-20260429-001.blocked.json

## Blocked receipt must include

- error
- impact
- rollback
- next_step
- observed_runner_identity
- checked_at_utc

## Safety

No delete. No payment. No credentials. No IAM. Archive only.