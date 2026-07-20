#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
BUNDLE="$ROOT/inbox/bundles/issue-237-runtime-one-bundle-v2.sh"
JOB_FILE="${JOB_FILE:-$ROOT/inbox/issue-237-migadu-github-routing-runtime-job.json}"
RUN_ID="${GITHUB_RUN_ID:-local-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_DIR="$ROOT/runtime/issue-237/$RUN_ID"
WORKER_LEDGER="$ROOT/runtime/ledger/issue-237-worker-runs.jsonl"
RECEIPT="$ROOT/runtime/receipts/issue-237/$RUN_ID.json"
mkdir -p "$RUN_DIR" "$(dirname "$WORKER_LEDGER")" "$(dirname "$RECEIPT")"
STATE=BLOCKED STEP=init EXIT_CODE=0 PRE_RECEIPT="" APPLY_RECEIPT=""
JOB_ID="$(jq -r '.job_id' "$JOB_FILE")" DEDUP="$(jq -r '.deduplication_key' "$JOB_FILE")"

emit(){
 local reason="$1"
 jq -n --arg run "$RUN_ID" --arg job "$JOB_ID" --arg dedup "$DEDUP" --arg state "$STATE" --arg step "$STEP" --arg reason "$reason" --arg pre "$PRE_RECEIPT" --arg apply "$APPLY_RECEIPT" --argjson exit "$EXIT_CODE" '{schema_version:"t4h.issue-237.worker.v3",run_id:$run,job_id:$job,deduplication_key:$dedup,state:$state,current_step:$step,exit_code:$exit,reason:$reason,evidence:{preflight_receipt:$pre,apply_receipt:$apply}}' > "$RECEIPT"
 jq -c . "$RECEIPT" >> "$WORKER_LEDGER"
 jq -e --arg r "$RUN_ID" 'select(.run_id==$r)' "$WORKER_LEDGER" >/dev/null
}
fail(){ local rc=$?; trap - ERR; set +e; EXIT_CODE=$rc STATE=BLOCKED; emit "worker failed at $STEP"; exit "$rc"; }
trap fail ERR
[[ -f "$BUNDLE" && -f "$JOB_FILE" ]]
chmod +x "$BUNDLE" "$ROOT/workers/issue-237-downstream-github-worker.sh" "$ROOT/tools/managesieve_direct.py"

# Canonical v2 bundle always refreshes SSM itself; inherited mail variables are ignored.
export REPO_ROOT="$ROOT" ISSUE_237_RUN_ID="$RUN_ID"
STEP=preflight
RECEIPT_DIR="$RUN_DIR/preflight" bash "$BUNDLE" preflight
PRE_RECEIPT="$RUN_DIR/preflight/deployment-receipt.json"
jq -e '.state=="REAL" and .mode=="preflight" and .real_gate.preflight and .real_gate.smtp_verified and .real_gate.ledger_persistence' "$PRE_RECEIPT" >/dev/null

STEP=apply
RECEIPT_DIR="$RUN_DIR/apply" bash "$BUNDLE" apply
APPLY_RECEIPT="$RUN_DIR/apply/deployment-receipt.json"
if jq -e '.state=="REAL" and ([.real_gate[]]|all)' "$APPLY_RECEIPT" >/dev/null; then
 STATE=REAL
elif jq -e '.real_gate.preflight and .real_gate.folder_placement and .real_gate.sieve_uploaded and .real_gate.smtp_verified and .real_gate.routing_test_verified and .real_gate.agent_delivery and .real_gate.job_creation and .real_gate.downstream_invoked and .real_gate.github_readback and .real_gate.ledger_persistence' "$APPLY_RECEIPT" >/dev/null; then
 STATE=PARTIAL
else
 STATE=BLOCKED
fi
STEP=complete EXIT_CODE=0
emit "preflight and apply executed; state derived from bundle and downstream receipts"
printf 'state=%s worker_receipt=%s preflight_receipt=%s apply_receipt=%s worker_ledger=%s\n' "$STATE" "$RECEIPT" "$PRE_RECEIPT" "$APPLY_RECEIPT" "$WORKER_LEDGER"
