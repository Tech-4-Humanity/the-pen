#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
JOB_FILE="${JOB_FILE:-$REPO_ROOT/inbox/issue-237-migadu-github-routing-runtime-job.json}"
BUNDLE="$REPO_ROOT/inbox/bundles/issue-237-runtime-one-bundle.sh"
WORKER_ID="${WORKER_ID:-issue-237-one-bundle-worker}"
RUN_ID="${GITHUB_RUN_ID:-local-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_DIR="$REPO_ROOT/runtime/issue-237/$RUN_ID"
CLAIM_DIR="$REPO_ROOT/runtime/claims"
RECEIPT_DIR="$REPO_ROOT/runtime/receipts/issue-237"
LEDGER="$REPO_ROOT/runtime/ledger/issue-237.jsonl"
FINAL_RECEIPT="$RECEIPT_DIR/$RUN_ID.json"
mkdir -p "$RUN_DIR" "$CLAIM_DIR" "$RECEIPT_DIR" "$(dirname "$LEDGER")"

JOB_ID="$(jq -r '.job_id' "$JOB_FILE")"
DEDUP_KEY="$(jq -r '.deduplication_key' "$JOB_FILE")"
CLAIM_FILE="$CLAIM_DIR/$JOB_ID.json"
STARTED_AT="$(date -u +%FT%TZ)"
STATE=PARTIAL
CURRENT_STEP=claim
EXIT_CODE=0
BUNDLE_RECEIPT=""

emit_receipt(){
  local reason="$1" finished_at
  finished_at="$(date -u +%FT%TZ)"
  jq -n \
    --arg schema_version "t4h.pen.worker-receipt.v2" \
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
    '{schema_version:$schema_version,job_id:$job_id,deduplication_key:$deduplication_key,worker_id:$worker_id,run_id:$run_id,started_at:$started_at,finished_at:$finished_at,state:$state,current_step:$current_step,exit_code:$exit_code,reason:$reason,evidence:{claim_file:$claim_file,bundle_receipt:$bundle_receipt}}' > "$FINAL_RECEIPT"
  jq -c . "$FINAL_RECEIPT" >> "$LEDGER"
  jq -e --arg run "$RUN_ID" 'select(.run_id==$run)' "$LEDGER" >/dev/null
}

fail(){
  EXIT_CODE=$?
  STATE=BLOCKED
  emit_receipt "worker failed at $CURRENT_STEP"
  exit "$EXIT_CODE"
}
trap fail ERR

load_ssm(){
  local region="${AWS_REGION:-ap-southeast-2}" prefix="${MIGADU_SSM_PREFIX:-/t4h/migadu/runtime}" name value
  for name in MIGADU_ADMIN_EMAIL MIGADU_API_KEY MIGADU_DOMAIN SOURCE_MAILBOX SOURCE_MAILBOX_PASSWORD AGENT_MAILBOX_PASSWORD SWAKS_SERVER SWAKS_USER SWAKS_PASSWORD; do
    [[ -n "${!name:-}" ]] && continue
    value="$(aws ssm get-parameter --region "$region" --name "$prefix/$name" --with-decryption --query 'Parameter.Value' --output text 2>/dev/null || true)"
    [[ -n "$value" && "$value" != None ]] && printf -v "$name" '%s' "$value" && export "$name"
  done
}

[[ -f "$JOB_FILE" ]] || { echo "missing job file: $JOB_FILE"; exit 2; }
[[ -f "$BUNDLE" ]] || { echo "missing canonical bundle: $BUNDLE"; exit 2; }

if jq -e --arg key "$DEDUP_KEY" 'select(.deduplication_key==$key and .state=="REAL")' "$LEDGER" >/dev/null 2>&1; then
  STATE=REAL
  CURRENT_STEP=deduplication
  emit_receipt "matching REAL ledger entry already exists"
  exit 0
fi

jq -n --arg job_id "$JOB_ID" --arg deduplication_key "$DEDUP_KEY" --arg worker_id "$WORKER_ID" --arg claimed_at "$STARTED_AT" --arg run_id "$RUN_ID" '{job_id:$job_id,deduplication_key:$deduplication_key,worker_id:$worker_id,claimed_at:$claimed_at,run_id:$run_id,state:"CLAIMED"}' > "$CLAIM_FILE"

CURRENT_STEP=load-secrets
load_ssm

CURRENT_STEP=preflight
required=(MIGADU_ADMIN_EMAIL MIGADU_API_KEY MIGADU_DOMAIN SOURCE_MAILBOX SOURCE_MAILBOX_PASSWORD AGENT_MAILBOX_PASSWORD SWAKS_SERVER SWAKS_USER SWAKS_PASSWORD)
missing=()
for name in "${required[@]}"; do [[ -n "${!name:-}" ]] || missing+=("$name"); done
if ((${#missing[@]})); then
  STATE=BLOCKED
  EXIT_CODE=20
  emit_receipt "missing runtime secrets: $(IFS=,; echo "${missing[*]}")"
  exit 0
fi

CURRENT_STEP=execute-one-bundle
export REPO_ROOT
export RECEIPT_DIR="$RUN_DIR/one-bundle"
bash "$BUNDLE"

BUNDLE_RECEIPT="$(find "$RUN_DIR/one-bundle" -name deployment-receipt.json -type f | sort | tail -1)"
[[ -n "$BUNDLE_RECEIPT" && -f "$BUNDLE_RECEIPT" ]] || { echo "bundle receipt missing"; exit 21; }
BUNDLE_RECEIPT="${BUNDLE_RECEIPT#$REPO_ROOT/}"

CURRENT_STEP=validate-bundle
if jq -e '.state=="REAL" and ([.real_gate[]]|all)' "$REPO_ROOT/$BUNDLE_RECEIPT" >/dev/null; then
  STATE=REAL
  emit_receipt "all issue #237 gates observed"
elif jq -e '.real_gate.folder_placement and .real_gate.sieve_uploaded and .real_gate.routing_test_verified and .real_gate.agent_delivery and .real_gate.job_creation and .real_gate.ledger_persistence' "$REPO_ROOT/$BUNDLE_RECEIPT" >/dev/null; then
  STATE=PARTIAL
  emit_receipt "mail routing and downstream job creation are REAL; GitHub investigation, repair/rerun and readback remain pending"
else
  STATE=BLOCKED
  emit_receipt "one or more routing/runtime gates failed"
fi

printf 'worker_receipt=%s\nbundle_receipt=%s\nledger=%s\nstate=%s\n' "$FINAL_RECEIPT" "$BUNDLE_RECEIPT" "$LEDGER" "$STATE"
