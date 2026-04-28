# ACTIVATE RUNNER INFRA

job_id: bookmark-execution-engine-v3-20260429-001
activation_id: activate-runner-infra-bookmark-engine-v3-004
mode: runtime_activation_probe

## Objective

Restore or prove the execution path for inbox-driven bridge jobs.

## Required checks

1. Confirm watcher is polling `inbox/`.
2. Confirm runner identity and host path.
3. Confirm runtime can write to `receipts/runtime/`.
4. Confirm GitHub push events are visible to the runner.
5. Confirm any cron/EventBridge/worker trigger is active.

## Required action

Write exactly one output:

SUCCESS:
`receipts/runtime/bookmark-execution-engine-v3-20260429-001.receipt.json`

BLOCKED:
`receipts/runtime/bookmark-execution-engine-v3-20260429-001.blocked.json`

## BLOCKED payload must include

- error
- impact
- rollback
- next_step
- observed_runner_identity
- checked_at_utc
- watched_paths
- last_seen_commit

## Safety rails

- No delete.
- No payment.
- No credential changes.
- No IAM changes.
- Archive only.
- Dry-run before any runtime change.

## Source commits to inspect

- command commit: e00b065029f8d90c2d4cd484c14679651c5300ea
- trigger commit: 0a6138791785ae77e2124b8f39b897cf03a20c81
- force probe commit: d1bdaca27808189b270cab17883b3af63efcb714

## Done definition

Done only when a receipt or blocked receipt exists under `receipts/runtime/`.