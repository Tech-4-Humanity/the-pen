# BOOTSTRAP EC2 RUNNER

job_id: bookmark-execution-engine-v3-20260429-001
bootstrap_id: bootstrap-ec2-runner-bookmark-engine-v3-005
mode: dry_run_then_report

## Doctrine

Mac is endpoint only. It must not be the production runner, watcher, scheduler, or evidence writer.

Pen, Dev, and Prod require EC2-backed runner lanes with independent uptime and receipts.

## Objective

Prove or restore an EC2-backed execution path for inbox-driven bridge jobs.

## Required dry-run checks

1. Identify current runner host for inbox jobs.
2. Confirm whether runner host is EC2, Lambda, GitHub Action, or Mac endpoint.
3. Confirm watched paths include `inbox/`.
4. Confirm receipt write path exists: `receipts/runtime/`.
5. Confirm last seen commit includes:
   - `2c51ccc0b5174cadfe34e30bfdc287418ba86f55`
6. Confirm environment lane mapping:
   - Pen = intake and validation lane
   - Symbio/Dev = build lane
   - Synapse/Prod = governed production lane
7. Confirm no lane depends on the Mac for always-on execution.

## Required output

Write exactly one file:

SUCCESS:
`receipts/runtime/bookmark-execution-engine-v3-20260429-001.ec2-bootstrap.receipt.json`

BLOCKED:
`receipts/runtime/bookmark-execution-engine-v3-20260429-001.ec2-bootstrap.blocked.json`

## Required fields

- runner_host_type
- runner_identity
- watched_paths
- receipt_write_test
- last_seen_commit
- lane_mapping
- mac_dependency_detected
- error
- impact
- rollback
- next_step
- checked_at_utc

## Safety rails

- Dry-run first.
- No delete.
- No payment.
- No credential changes.
- No IAM changes.
- No production promotion.
- Archive only.

## If EC2 runner is missing

Do not create credentials or change IAM. Report the exact missing runtime piece and the next bridge-safe action.

## Done definition

Done only when a receipt or blocked receipt exists under `receipts/runtime/` with the fields above.