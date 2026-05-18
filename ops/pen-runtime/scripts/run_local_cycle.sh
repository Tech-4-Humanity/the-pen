#!/usr/bin/env bash
# run_local_cycle.sh
# Run the Pen runtime cycle locally
set -euo pipefail

export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
export SUPABASE_URL="${SUPABASE_URL:-}"
export SUPABASE_SERVICE_KEY="${SUPABASE_SERVICE_KEY:-}"

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "ERROR: GITHUB_TOKEN not set" && exit 1
fi

echo "==> Running Pen Runtime Cycle..."
python3 ops/pen-runtime/workers/pen_runtime_cycle.py

echo "==> Pulling Dev queue..."
python3 ops/pen-runtime/workers/dev_puller.py

echo "==> Cycle complete. Check ops/pen-runtime/receipts/bootstrap.receipt.json"
