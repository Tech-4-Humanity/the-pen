#!/usr/bin/env bash
set -Eeuo pipefail

# One entrypoint: discover -> self-check -> attempt up to 3 times -> receipt -> move on.
REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
REPO="${GITHUB_REPOSITORY:-TML-4PM/the-pen}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
MAX_ISSUES_PER_RUN="${MAX_ISSUES_PER_RUN:-20}"
LABEL="${ISSUE_LABEL:-work-queue}"
RUN_ID="${GITHUB_RUN_ID:-local-$(date -u +%Y%m%dT%H%M%SZ)}"
RUNTIME="$REPO_ROOT/runtime/open-issues-worker/$RUN_ID"
LEDGER="$REPO_ROOT/runtime/ledger/open-issues-worker.jsonl"
mkdir -p "$RUNTIME" "$(dirname "$LEDGER")"

log(){ printf '[%s] %s\n' "$(date -u +%FT%TZ)" "$*"; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "BLOCKED missing dependency: $1"; return 1; }; }
json_ok(){ jq empty "$1" >/dev/null 2>&1; }

# Self-check the runner before touching the queue.
self_check(){
  local failed=0
  for c in gh jq bash git find sort; do need "$c" || failed=1; done
  [[ "$MAX_ATTEMPTS" =~ ^[1-9][0-9]*$ ]] || { log "invalid MAX_ATTEMPTS=$MAX_ATTEMPTS"; failed=1; }
  [[ "$MAX_ISSUES_PER_RUN" =~ ^[1-9][0-9]*$ ]] || { log "invalid MAX_ISSUES_PER_RUN=$MAX_ISSUES_PER_RUN"; failed=1; }
  [[ -d "$REPO_ROOT/.git" ]] || { log "not a git repository: $REPO_ROOT"; failed=1; }
  gh auth status >/dev/null 2>&1 || { log "GitHub CLI is not authenticated"; failed=1; }
  bash -n "$0" || failed=1
  (( failed == 0 ))
}

write_receipt(){
  local file="$1" issue="$2" attempt="$3" state="$4" reason="$5" handler="$6" rc="$7" started="$8" finished="$9" evidence="${10:-}"
  jq -n \
    --argjson issue "$issue" --arg run_id "$RUN_ID" --argjson attempt "$attempt" \
    --arg started "$started" --arg finished "$finished" --arg state "$state" \
    --arg reason "$reason" --arg handler "$handler" --argjson exit_code "$rc" \
    --arg evidence "$evidence" \
    '{schema_version:"t4h.pen.issue-attempt.v2",issue:$issue,run_id:$run_id,attempt:$attempt,started_at:$started,finished_at:$finished,state:$state,reason:$reason,handler:$handler,exit_code:$exit_code,evidence:$evidence}' > "$file"
  json_ok "$file"
  jq -c . "$file" >> "$LEDGER"
  tail -n 1 "$LEDGER" | jq -e --arg run "$RUN_ID" --argjson issue "$issue" --argjson attempt "$attempt" 'select(.run_id==$run and .issue==$issue and .attempt==$attempt)' >/dev/null
}

# Built-in issue handlers. They return output only; the orchestrator owns receipts.
run_builtin(){
  local issue="$1" attempt_dir="$2"
  case "$issue" in
    237)
      local bundle="$REPO_ROOT/inbox/bundles/migadu-github-agent-routing-all-sprints-20260718.sh"
      [[ -f "$bundle" ]] || { echo "missing bundle: ${bundle#$REPO_ROOT/}"; return 127; }
      bash -n "$bundle" || return 126
      local required=(MIGADU_ADMIN_EMAIL MIGADU_API_KEY MIGADU_DOMAIN SOURCE_MAILBOX SOURCE_MAILBOX_PASSWORD AGENT_MAILBOX_PASSWORD)
      local missing=() name
      for name in "${required[@]}"; do [[ -n "${!name:-}" ]] || missing+=("$name"); done
      if ((${#missing[@]})); then
        printf 'missing runtime secrets: %s\n' "$(IFS=,; echo "${missing[*]}")"
        return 20
      fi
      APPLY=1 RECEIPT_DIR="$attempt_dir/bundle-receipts" bash "$bundle"
      ;;
    *) return 125 ;;
  esac
}

find_external_handler(){
  local issue="$1" f
  for f in \
    "$REPO_ROOT/workers/issue-$issue-worker.sh" \
    "$REPO_ROOT/workers/issue-$issue-runtime-worker.sh" \
    "$REPO_ROOT/workers/issue-$issue-"*.sh; do
    [[ -f "$f" && "$f" != "$0" ]] && { printf '%s\n' "$f"; return 0; }
  done
  return 1
}

find_real_receipt(){
  local dir="$1" receipt
  while IFS= read -r receipt; do
    json_ok "$receipt" && jq -e '.state=="REAL"' "$receipt" >/dev/null 2>&1 && { printf '%s\n' "$receipt"; return 0; }
  done < <(find "$dir" -type f -name '*.json' 2>/dev/null | sort)
  return 1
}

self_check || {
  mkdir -p "$RUNTIME/self-check"
  jq -n --arg run_id "$RUN_ID" --arg state BLOCKED --arg reason "runner self-check failed" '{run_id:$run_id,state:$state,reason:$reason}' > "$RUNTIME/self-check/receipt.json"
  exit 2
}

issues_json="$(gh issue list --repo "$REPO" --state open --label "$LABEL" --limit 1000 --json number,title)"
mapfile -t ISSUES < <(jq -r 'sort_by(.number) | .[].number' <<<"$issues_json")
processed=0

for issue in "${ISSUES[@]}"; do
  (( processed >= MAX_ISSUES_PER_RUN )) && break

  # Durable REAL evidence suppresses repeat execution.
  if [[ -s "$LEDGER" ]] && jq -e --argjson n "$issue" 'select(.issue==$n and .state=="REAL")' "$LEDGER" >/dev/null 2>&1; then
    log "issue #$issue already REAL; skipping"
    continue
  fi

  processed=$((processed+1))
  issue_dir="$RUNTIME/issue-$issue"
  mkdir -p "$issue_dir"
  gh issue comment "$issue" --repo "$REPO" --body "Sequential worker claimed issue #$issue. Self-check passed. Up to $MAX_ATTEMPTS attempts; then it advances. Run: $RUN_ID." >/dev/null || true

  external="$(find_external_handler "$issue" || true)"
  completed=false
  final_state="BLOCKED"
  final_reason="no executable handler available"

  for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
    attempt_dir="$issue_dir/attempt-$attempt"
    mkdir -p "$attempt_dir"
    started="$(date -u +%FT%TZ)"
    rc=0 state="BLOCKED" reason="" handler="builtin-or-discovered" evidence=""

    set +e
    if [[ -n "$external" ]]; then
      handler="${external#$REPO_ROOT/}"
      bash -n "$external" >"$attempt_dir/syntax-check.log" 2>&1
      syntax_rc=$?
      if (( syntax_rc == 0 )); then
        ISSUE_NUMBER="$issue" WORKER_ATTEMPT="$attempt" REPO_ROOT="$REPO_ROOT" bash "$external" >"$attempt_dir/output.log" 2>&1
        rc=$?
      else
        rc=126
        cat "$attempt_dir/syntax-check.log" > "$attempt_dir/output.log"
      fi
    else
      handler="builtin:$issue"
      run_builtin "$issue" "$attempt_dir" >"$attempt_dir/output.log" 2>&1
      rc=$?
    fi
    set -e

    if evidence_path="$(find_real_receipt "$attempt_dir" || true)" && [[ -n "$evidence_path" ]]; then
      state="REAL"; reason="REAL receipt observed"; evidence="${evidence_path#$REPO_ROOT/}"; completed=true
    elif (( rc == 0 )); then
      state="PARTIAL"; reason="handler exited 0 but emitted no REAL receipt"
    elif (( rc == 125 || rc == 127 )); then
      state="BLOCKED"; reason="no issue-specific handler or required bundle exists"
    elif (( rc == 20 )); then
      state="BLOCKED"; reason="runtime credentials are missing"
    else
      state="BLOCKED"; reason="handler failed with exit code $rc"
    fi

    finished="$(date -u +%FT%TZ)"
    write_receipt "$attempt_dir/receipt.json" "$issue" "$attempt" "$state" "$reason" "$handler" "$rc" "$started" "$finished" "$evidence"
    final_state="$state"; final_reason="$reason"

    if [[ "$completed" == true ]]; then
      gh issue comment "$issue" --repo "$REPO" --body "REAL receipt observed on attempt $attempt. Evidence: $evidence. Moving to the next issue. Run: $RUN_ID." >/dev/null || true
      break
    fi

    (( attempt < MAX_ATTEMPTS )) && sleep "$attempt"
  done

  if [[ "$completed" != true ]]; then
    gh issue comment "$issue" --repo "$REPO" --body "$MAX_ATTEMPTS bounded attempts finished. State: $final_state. Reason: $final_reason. Issue remains open; worker moved on. Evidence: runtime/open-issues-worker/$RUN_ID/issue-$issue/." >/dev/null || true
  fi
done

# Final independent readback.
[[ "$processed" -eq 0 ]] || jq -e --arg run "$RUN_ID" 'select(.run_id==$run)' "$LEDGER" >/dev/null
printf 'run_id=%s processed=%s ledger=%s status=%s\n' "$RUN_ID" "$processed" "$LEDGER" "COMPLETED_QUEUE_PASS"
