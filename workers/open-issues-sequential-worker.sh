#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
REPO="${GITHUB_REPOSITORY:-TML-4PM/the-pen}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
MAX_ISSUES_PER_RUN="${MAX_ISSUES_PER_RUN:-20}"
LABEL="${ISSUE_LABEL:-work-queue}"
RUN_ID="${GITHUB_RUN_ID:-local-$(date -u +%Y%m%dT%H%M%SZ)}"
RUNTIME="$REPO_ROOT/runtime/open-issues-worker/$RUN_ID"
LEDGER="$REPO_ROOT/runtime/ledger/open-issues-worker.jsonl"
mkdir -p "$RUNTIME" "$(dirname "$LEDGER")"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "missing dependency: $1"; exit 2; }; }
for c in gh jq bash git; do need "$c"; done

gh auth status >/dev/null

mapfile -t ISSUES < <(gh issue list --repo "$REPO" --state open --label "$LABEL" --limit 1000 --json number --jq 'sort_by(.number) | .[].number')
processed=0

for issue in "${ISSUES[@]}"; do
  (( processed >= MAX_ISSUES_PER_RUN )) && break
  processed=$((processed+1))
  issue_dir="$RUNTIME/issue-$issue"
  mkdir -p "$issue_dir"
  state="BLOCKED"
  reason="no issue-specific executable worker found"
  completed=false

  # Already completed issues are skipped using durable ledger evidence.
  if jq -e --argjson n "$issue" 'select(.issue==$n and .state=="REAL")' "$LEDGER" >/dev/null 2>&1; then
    continue
  fi

  gh issue comment "$issue" --repo "$REPO" --body "Sequential runtime worker claimed issue #$issue. Maximum attempts: $MAX_ATTEMPTS. It will move to the next issue after completion or the third unsuccessful attempt. Run: $RUN_ID." || true

  candidates=(
    "$REPO_ROOT/workers/issue-$issue-worker.sh"
    "$REPO_ROOT/workers/issue-$issue-runtime-worker.sh"
    "$REPO_ROOT/workers/issue-$issue-"*.sh
  )
  worker=""
  for candidate in "${candidates[@]}"; do
    [[ -f "$candidate" ]] && { worker="$candidate"; break; }
  done

  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    attempt_dir="$issue_dir/attempt-$attempt"
    mkdir -p "$attempt_dir"
    started="$(date -u +%FT%TZ)"
    rc=0

    if [[ -n "$worker" ]]; then
      set +e
      ISSUE_NUMBER="$issue" WORKER_ATTEMPT="$attempt" REPO_ROOT="$REPO_ROOT" bash "$worker" >"$attempt_dir/output.log" 2>&1
      rc=$?
      set -e
      if [[ $rc -eq 0 ]]; then
        receipt="$(find "$REPO_ROOT/runtime" -type f -name '*.json' -newer "$attempt_dir" 2>/dev/null | sort | tail -1 || true)"
        if [[ -n "$receipt" ]] && jq -e '.state=="REAL"' "$receipt" >/dev/null 2>&1; then
          state="REAL"; reason="issue-specific worker returned a REAL receipt"; completed=true
        else
          state="PARTIAL"; reason="worker exited successfully but no REAL receipt was observed"
        fi
      else
        state="BLOCKED"; reason="worker attempt failed with exit code $rc"
      fi
    else
      printf '%s\n' "$reason" > "$attempt_dir/output.log"
      rc=127
    fi

    finished="$(date -u +%FT%TZ)"
    jq -n --argjson issue "$issue" --arg run_id "$RUN_ID" --argjson attempt "$attempt" --arg started "$started" --arg finished "$finished" --arg state "$state" --arg reason "$reason" --arg worker "${worker#$REPO_ROOT/}" --argjson exit_code "$rc" '{issue:$issue,run_id:$run_id,attempt:$attempt,started_at:$started,finished_at:$finished,state:$state,reason:$reason,worker:$worker,exit_code:$exit_code}' > "$attempt_dir/receipt.json"
    jq -c . "$attempt_dir/receipt.json" >> "$LEDGER"

    if [[ "$completed" == true ]]; then
      gh issue comment "$issue" --repo "$REPO" --body "REAL receipt observed on attempt $attempt. Sequential worker is moving to the next issue. Runtime ledger: runtime/ledger/open-issues-worker.jsonl" || true
      break
    fi

    if (( attempt < MAX_ATTEMPTS )); then
      sleep $((attempt * 10))
    else
      gh issue comment "$issue" --repo "$REPO" --body "Three bounded attempts completed without a REAL receipt. Final state: $state. Reason: $reason. The issue remains open and the worker has moved to the next queued issue. Runtime evidence: runtime/open-issues-worker/$RUN_ID/issue-$issue/" || true
    fi
  done
done

jq -e --arg run_id "$RUN_ID" 'select(.run_id==$run_id)' "$LEDGER" >/dev/null
printf 'run_id=%s processed=%s ledger=%s\n' "$RUN_ID" "$processed" "$LEDGER"
