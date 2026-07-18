#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
JOB_FILE="${JOB_FILE:-$REPO_ROOT/inbox/issue-237-migadu-github-routing-runtime-job.json}"
WORKER_ID="${WORKER_ID:-github-actions-issue-237-worker}"
RUN_ID="${GITHUB_RUN_ID:-local-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_DIR="$REPO_ROOT/runtime/issue-237/$RUN_ID"
CLAIM_DIR="$REPO_ROOT/runtime/claims"
RECEIPT_DIR="$REPO_ROOT/runtime/receipts/issue-237"
LEDGER="$REPO_ROOT/runtime/ledger/issue-237.jsonl"
mkdir -p "$RUN_DIR" "$CLAIM_DIR" "$RECEIPT_DIR" "$(dirname "$LEDGER")"

JOB_ID="$(jq -r '.job_id' "$JOB_FILE")"
DEDUP_KEY="$(jq -r '.deduplication_key' "$JOB_FILE")"
CLAIM_FILE="$CLAIM_DIR/$JOB_ID.json"
FINAL_RECEIPT="$RECEIPT_DIR/$RUN_ID.json"
STARTED_AT="$(date -u +%FT%TZ)"
STATE="PARTIAL"
CURRENT_STEP="claim"
EXIT_CODE=0
BUNDLE_RECEIPT=""

emit_receipt() {
  local reason="$1"
  local finished_at
  finished_at="$(date -u +%FT%TZ)"
  jq -n \
    --arg schema_version "t4h.pen.worker-receipt.v1" \
    --arg job_id "$JOB_ID" \
    --arg deduplication_key "$DEDUP_KEY" \
    --arg worker_id "$WORKER_ID" \
    --arg run_id "$RUN_ID" \
    --arg started_at "$STARTED_AT" \
    --arg finished_at "$finished_at" \
    --arg state "$STATE" \
    --arg current_step "$CURRENT_STEP" \
    --arg reason "$reason" \
    --arg claim_file "${CLAIM_FILE#$REPO_ROOT/}" \
    --arg bundle_receipt "$BUNDLE_RECEIPT" \
    --argjson exit_code "$EXIT_CODE" \
    '{schema_version:$schema_version,job_id:$job_id,deduplication_key:$deduplication_key,worker_id:$worker_id,run_id:$run_id,started_at:$started_at,finished_at:$finished_at,state:$state,current_step:$current_step,exit_code:$exit_code,reason:$reason,evidence:{claim_file:$claim_file,bundle_receipt:$bundle_receipt},real_gate:{folder_placement:false,agent_delivery:false,job_creation:true,investigation:false,repair_or_rerun:false,github_readback:false,ledger_persistence:true}}' > "$FINAL_RECEIPT"
  jq -c . "$FINAL_RECEIPT" >> "$LEDGER"
}

on_error() {
  EXIT_CODE=$?
  STATE="BLOCKED"
  emit_receipt "worker failed at $CURRENT_STEP; retry after correcting the recorded dependency or credential failure"
  exit "$EXIT_CODE"
}
trap on_error ERR

[[ -f "$JOB_FILE" ]] || { echo "missing job file: $JOB_FILE"; exit 2; }

# Deduplicated claim. A completed REAL receipt suppresses duplicate execution.
if jq -e --arg key "$DEDUP_KEY" 'select(.deduplication_key==$key and .state=="REAL")' "$LEDGER" >/dev/null 2>&1; then
  STATE="REAL"
  CURRENT_STEP="deduplication"
  emit_receipt "matching REAL ledger entry already exists; duplicate execution suppressed"
  exit 0
fi

jq -n \
  --arg job_id "$JOB_ID" \
  --arg deduplication_key "$DEDUP_KEY" \
  --arg worker_id "$WORKER_ID" \
  --arg claimed_at "$STARTED_AT" \
  --arg run_id "$RUN_ID" \
  '{job_id:$job_id,deduplication_key:$deduplication_key,worker_id:$worker_id,claimed_at:$claimed_at,run_id:$run_id,state:"CLAIMED"}' > "$CLAIM_FILE"

CURRENT_STEP="preflight"
required=(MIGADU_ADMIN_EMAIL MIGADU_API_KEY MIGADU_DOMAIN SOURCE_MAILBOX SOURCE_MAILBOX_PASSWORD AGENT_MAILBOX_PASSWORD)
missing=()
for name in "${required[@]}"; do
  [[ -n "${!name:-}" ]] || missing+=("$name")
done
if ((${#missing[@]})); then
  STATE="BLOCKED"
  EXIT_CODE=20
  emit_receipt "missing runtime secrets: $(IFS=,; echo "${missing[*]}")"
  exit 0
fi

CURRENT_STEP="execute-bundle"
export APPLY=1
export RECEIPT_DIR="$RUN_DIR/bundle-receipts"
bash "$REPO_ROOT/inbox/bundles/migadu-github-agent-routing-all-sprints-20260718.sh"

BUNDLE_RECEIPT="$(find "$RUN_DIR/bundle-receipts" -name deployment-receipt.json -type f | sort | tail -1)"
[[ -n "$BUNDLE_RECEIPT" && -f "$BUNDLE_RECEIPT" ]] || { echo "bundle receipt missing"; exit 21; }
BUNDLE_RECEIPT="${BUNDLE_RECEIPT#$REPO_ROOT/}"

CURRENT_STEP="validate-bundle-receipt"
if jq -e '.state=="REAL" and ([.real_gate[]] | all)' "$REPO_ROOT/$BUNDLE_RECEIPT" >/dev/null; then
  STATE="REAL"
  EXIT_CODE=0
  emit_receipt "all issue #237 runtime gates observed"
else
  STATE="PARTIAL"
  EXIT_CODE=0
  emit_receipt "bundle executed but one or more REAL gates remain unobserved"
fi

# Independent ledger readback gate.
CURRENT_STEP="ledger-readback"
jq -e --arg run_id "$RUN_ID" 'select(.run_id==$run_id)' "$LEDGER" >/dev/null
printf 'worker_receipt=%s\nledger=%s\nstate=%s\n' "$FINAL_RECEIPT" "$LEDGER" "$STATE"
