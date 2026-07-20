#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
JOB_FILE="${1:?job file required}"
RECEIPT="${2:?receipt path required}"
LEDGER="${ISSUE_237_JOB_LEDGER:-$ROOT/runtime/ledger/issue-237-jobs.jsonl}"
mkdir -p "$(dirname "$RECEIPT")" "$(dirname "$LEDGER")"

started_at="$(date -u +%FT%TZ)"
state="BLOCKED"
reason=""
github_readback=false
investigation=false
repair_or_rerun=false
issue_state=""
issue_url=""

finish() {
  local rc="${1:-0}" finished_at
  finished_at="$(date -u +%FT%TZ)"
  jq -n \
    --arg schema_version "t4h.issue-237.downstream.v1" \
    --arg started_at "$started_at" \
    --arg finished_at "$finished_at" \
    --arg state "$state" \
    --arg reason "$reason" \
    --arg issue_state "$issue_state" \
    --arg issue_url "$issue_url" \
    --argjson exit_code "$rc" \
    --argjson github_readback "$github_readback" \
    --argjson investigation "$investigation" \
    --argjson repair_or_rerun "$repair_or_rerun" \
    '{schema_version:$schema_version,started_at:$started_at,finished_at:$finished_at,state:$state,exit_code:$exit_code,reason:$reason,github:{issue:237,state:$issue_state,url:$issue_url},real_gate:{invoked:true,github_readback:$github_readback,investigation:$investigation,repair_or_rerun:$repair_or_rerun}}' > "$RECEIPT"
  jq -c . "$RECEIPT" >> "$LEDGER"
  jq -e --arg started "$started_at" 'select(.started_at==$started)' "$LEDGER" >/dev/null
}

trap 'rc=$?; trap - ERR; state=BLOCKED; reason="downstream worker failed"; finish "$rc"; exit "$rc"' ERR

jq -e '.state=="QUEUED" and .job_id and .source_token' "$JOB_FILE" >/dev/null
command -v gh >/dev/null 2>&1
gh auth status >/dev/null 2>&1

issue_json="$(gh issue view 237 --repo TML-4PM/the-pen --json state,url,title)"
issue_state="$(jq -r '.state' <<<"$issue_json")"
issue_url="$(jq -r '.url' <<<"$issue_json")"
github_readback=true

# This synthetic acceptance job proves invocation and GitHub readback. It does not
# pretend that a real failed workflow was investigated or repaired.
state="PARTIAL"
reason="downstream job invoked and issue #237 read back; no concrete failed workflow/run was attached to the synthetic routing test"
finish 0
printf 'state=%s receipt=%s ledger=%s\n' "$state" "$RECEIPT" "$LEDGER"
