# Trigger Live Actions Run

Task ID: pen-smoke-task
Mode: execute-equivalent via push trigger

This file exists to trigger `.github/workflows/pen-execution-worker.yml` through the `push` event on `tasks/**`.

Expected result:
- GitHub Actions runs `scripts/pen-executor.mjs`
- Runtime output is written to `outputs/runtime/...`
- Runtime receipt is written to `receipts/runtime/...`
- Issue #5 receives an automated return receipt comment
