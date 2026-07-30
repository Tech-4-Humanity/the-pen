#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

REPO="${REPO:-TML-4PM/the-pen}"
BRANCH="${BRANCH:-feat/migadu-managed-mcp}"
WORKFLOW="${WORKFLOW:-migadu-managed-mcp-validation.yml}"
FAILED_RUN_ID="${FAILED_RUN_ID:-29223807951}"
TOKEN_KEYCHAIN_SERVICE="${TOKEN_KEYCHAIN_SERVICE:-t4h-github-token}"
TOKEN_SSM_PARAMETER="${TOKEN_SSM_PARAMETER:-}"
TOKEN_OP_REFERENCE="${TOKEN_OP_REFERENCE:-}"
RECEIPT_DIR="${RECEIPT_DIR:-./github-actions-repair-receipts}"
LEDGER_FILE="${LEDGER_FILE:-}"
WAIT_FOR_RUN="${WAIT_FOR_RUN:-true}"

RUN_ID="gha-repair-$(date -u +%Y%m%dT%H%M%SZ)-$$"
STARTED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
mkdir -p "$RECEIPT_DIR"
RAW_LOG="$RECEIPT_DIR/${RUN_ID}.log"
JSON_RECEIPT="$RECEIPT_DIR/${RUN_ID}.json"
MD_RECEIPT="$RECEIPT_DIR/${RUN_ID}.md"

exec > >(tee -a "$RAW_LOG") 2>&1

STATUS="PARTIAL"
FAILURE_STAGE=""
FAILURE_REASON=""
DISPATCHED_RUN_ID=""
REPO_PERMISSION=""
TOKEN_SOURCE="none"
ACTIONS_BEFORE="{}"
WORKFLOW_PERMS_BEFORE="{}"
ACTIONS_AFTER="{}"
WORKFLOW_PERMS_AFTER="{}"
FINAL_CONCLUSION=""

log(){ printf '\n== %s ==\n' "$*"; }
warn(){ printf 'WARN: %s\n' "$*" >&2; }
die(){ FAILURE_STAGE="${1:-unknown}"; FAILURE_REASON="${2:-failure}"; STATUS="BLOCKED"; return 1; }
command_exists(){ command -v "$1" >/dev/null 2>&1; }

write_receipts(){
  local ended_at host os gh_version token_source_safe log_hash
  ended_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  host="$(hostname 2>/dev/null || echo unknown)"
  os="$(uname -a 2>/dev/null || echo unknown)"
  gh_version="$(gh --version 2>/dev/null | head -1 || echo unavailable)"
  token_source_safe="$TOKEN_SOURCE"
  log_hash="$(shasum -a 256 "$RAW_LOG" 2>/dev/null | awk '{print $1}' || sha256sum "$RAW_LOG" 2>/dev/null | awk '{print $1}' || echo unavailable)"

  python3 - "$JSON_RECEIPT" <<PY
import json, os, sys
path=sys.argv[1]
data={
  "schema_version":"1.0.0",
  "run_id":${RUN_ID@Q},
  "started_at":${STARTED_AT@Q},
  "ended_at":${ended_at@Q},
  "status":${STATUS@Q},
  "repository":${REPO@Q},
  "branch":${BRANCH@Q},
  "workflow":${WORKFLOW@Q},
  "failed_run_inspected":${FAILED_RUN_ID@Q},
  "dispatched_run_id":${DISPATCHED_RUN_ID@Q},
  "final_conclusion":${FINAL_CONCLUSION@Q},
  "repository_permission":${REPO_PERMISSION@Q},
  "token_source":${token_source_safe@Q},
  "token_value_recorded":False,
  "failure_stage":${FAILURE_STAGE@Q},
  "failure_reason":${FAILURE_REASON@Q},
  "host":${host@Q},
  "os":${os@Q},
  "gh_version":${gh_version@Q},
  "actions_permissions_before":json.loads(${ACTIONS_BEFORE@Q} or "{}"),
  "workflow_permissions_before":json.loads(${WORKFLOW_PERMS_BEFORE@Q} or "{}"),
  "actions_permissions_after":json.loads(${ACTIONS_AFTER@Q} or "{}"),
  "workflow_permissions_after":json.loads(${WORKFLOW_PERMS_AFTER@Q} or "{}"),
  "raw_log":os.path.basename(${RAW_LOG@Q}),
  "raw_log_sha256":${log_hash@Q}
}
with open(path,"w") as f: json.dump(data,f,indent=2,sort_keys=True)
PY

  cat > "$MD_RECEIPT" <<MD
# GitHub Actions Repair Receipt

- Run ID: \`$RUN_ID\`
- Status: **$STATUS**
- Repository: \`$REPO\`
- Branch: \`$BRANCH\`
- Workflow: \`$WORKFLOW\`
- Token source: \`$token_source_safe\` (value not stored)
- Repository permission: \`$REPO_PERMISSION\`
- Dispatched run: \`${DISPATCHED_RUN_ID:-none}\`
- Final conclusion: \`${FINAL_CONCLUSION:-not observed}\`
- Failure stage: \`${FAILURE_STAGE:-none}\`
- Failure reason: \`${FAILURE_REASON:-none}\`
- Raw log: \`$(basename "$RAW_LOG")\`
- Raw log SHA-256: \`$log_hash\`

## Truth boundary

This receipt proves only the operations and observations captured in the raw log. It does not expose or persist the GitHub token.
MD

  if [[ -n "$LEDGER_FILE" ]]; then
    mkdir -p "$(dirname "$LEDGER_FILE")"
    python3 - "$JSON_RECEIPT" "$LEDGER_FILE" <<'PY'
import json,sys
r=json.load(open(sys.argv[1]))
entry={k:r.get(k) for k in ["run_id","started_at","ended_at","status","repository","branch","workflow","dispatched_run_id","final_conclusion","failure_stage","failure_reason","raw_log_sha256"]}
entry["entry_type"]="GITHUB_ACTIONS_REPAIR"
with open(sys.argv[2],"a") as f: f.write(json.dumps(entry,sort_keys=True)+"\n")
PY
  fi
}
trap 'rc=$?; if [[ $rc -ne 0 && "$STATUS" != "BLOCKED" ]]; then STATUS="PARTIAL"; FAILURE_STAGE="${FAILURE_STAGE:-unexpected}"; FAILURE_REASON="${FAILURE_REASON:-exit code $rc}"; fi; write_receipts; exit $rc' EXIT

log "1. Runtime preflight"
command_exists curl || { die preflight "curl missing"; exit 1; }
command_exists python3 || { die preflight "python3 missing"; exit 1; }

if ! python3 - <<'PY'
import socket
socket.getaddrinfo('github.com',443)
PY
then die network "github.com DNS resolution failed"; exit 2; fi
curl -fsSI --max-time 20 https://github.com >/dev/null || { die network "HTTPS to github.com failed"; exit 2; }

log "2. Install GitHub CLI"
if ! command_exists gh; then
  if command_exists brew; then
    brew install gh
  elif command_exists apt-get; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y gh
  elif command_exists dnf; then
    sudo dnf install -y 'dnf-command(config-manager)'
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh
  elif command_exists yum; then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo yum install -y gh
  else
    die install_gh "no supported package manager"; exit 3
  fi
fi
gh --version

log "3. Discover GitHub credential without printing it"
if [[ -n "${GH_TOKEN:-}" ]]; then
  TOKEN_SOURCE="GH_TOKEN environment"
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  export GH_TOKEN="$GITHUB_TOKEN"
  TOKEN_SOURCE="GITHUB_TOKEN environment"
elif command_exists security; then
  token="$(security find-generic-password -s "$TOKEN_KEYCHAIN_SERVICE" -w 2>/dev/null || true)"
  if [[ -n "$token" ]]; then export GH_TOKEN="$token"; unset token; TOKEN_SOURCE="macOS Keychain:$TOKEN_KEYCHAIN_SERVICE"; fi
fi
if [[ -z "${GH_TOKEN:-}" && -n "$TOKEN_OP_REFERENCE" ]] && command_exists op; then
  token="$(op read "$TOKEN_OP_REFERENCE" 2>/dev/null || true)"
  if [[ -n "$token" ]]; then export GH_TOKEN="$token"; unset token; TOKEN_SOURCE="1Password reference"; fi
fi
if [[ -z "${GH_TOKEN:-}" && -n "$TOKEN_SSM_PARAMETER" ]] && command_exists aws; then
  token="$(aws ssm get-parameter --name "$TOKEN_SSM_PARAMETER" --with-decryption --query Parameter.Value --output text 2>/dev/null || true)"
  if [[ -n "$token" ]]; then export GH_TOKEN="$token"; unset token; TOKEN_SOURCE="AWS SSM:$TOKEN_SSM_PARAMETER"; fi
fi
if [[ -z "${GH_TOKEN:-}" ]]; then
  read -rsp "Paste GitHub token (input hidden): " GH_TOKEN
  echo
  export GH_TOKEN
  TOKEN_SOURCE="interactive hidden input"
fi
[[ -n "${GH_TOKEN:-}" ]] || { die credentials "no token available"; exit 4; }

log "4. Verify authentication"
# GH_TOKEN is the supported non-persistent authentication method. Do not call gh auth login.
LOGIN="$(gh api user --jq '.login' 2>/dev/null)" || { die authentication "token rejected by GitHub API"; exit 5; }
echo "Authenticated as: $LOGIN"
gh auth status || true

log "5. Verify repository authority"
repo_json="$(gh repo view "$REPO" --json nameWithOwner,viewerPermission,isPrivate,defaultBranchRef)" || { die repository_access "cannot read $REPO"; exit 6; }
echo "$repo_json"
REPO_PERMISSION="$(printf '%s' "$repo_json" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("viewerPermission",""))')"
case "$REPO_PERMISSION" in ADMIN|MAINTAIN) ;; *) die repository_authority "ADMIN or MAINTAIN required; observed $REPO_PERMISSION"; exit 7;; esac

log "6. Inspect existing Actions state and failed run"
gh workflow list -R "$REPO" || true
gh run list -R "$REPO" --limit 10 || true
if [[ -n "$FAILED_RUN_ID" ]]; then
  gh run view "$FAILED_RUN_ID" -R "$REPO" --json status,conclusion,event,headSha,jobs,url || true
  gh run view "$FAILED_RUN_ID" -R "$REPO" --log-failed || true
fi

log "7. Capture Actions permissions before change"
ACTIONS_BEFORE="$(gh api "/repos/${REPO}/actions/permissions")" || { die actions_read "cannot read Actions permissions"; exit 8; }
WORKFLOW_PERMS_BEFORE="$(gh api "/repos/${REPO}/actions/permissions/workflow")" || { die workflow_permissions_read "cannot read workflow permissions"; exit 8; }
echo "Actions before: $ACTIONS_BEFORE"
echo "Workflow permissions before: $WORKFLOW_PERMS_BEFORE"

log "8. Enable Actions and workflow write permissions"
gh api --method PUT "/repos/${REPO}/actions/permissions" -F enabled=true -f allowed_actions=all >/dev/null || { die actions_update "failed to enable Actions"; exit 9; }
gh api --method PUT "/repos/${REPO}/actions/permissions/workflow" -f default_workflow_permissions=write -F can_approve_pull_request_reviews=false >/dev/null || { die workflow_permissions_update "failed to set workflow permissions"; exit 9; }

ACTIONS_AFTER="$(gh api "/repos/${REPO}/actions/permissions")"
WORKFLOW_PERMS_AFTER="$(gh api "/repos/${REPO}/actions/permissions/workflow")"
echo "Actions after: $ACTIONS_AFTER"
echo "Workflow permissions after: $WORKFLOW_PERMS_AFTER"

python3 - <<PY
import json
ap=json.loads(${ACTIONS_AFTER@Q}); wp=json.loads(${WORKFLOW_PERMS_AFTER@Q})
assert ap.get('enabled') is True, ap
assert ap.get('allowed_actions') == 'all', ap
assert wp.get('default_workflow_permissions') == 'write', wp
print('Actions permissions verified')
PY

log "9. Dispatch repaired workflow"
before_ids="$(gh run list -R "$REPO" --workflow "$WORKFLOW" --limit 20 --json databaseId --jq '.[].databaseId' 2>/dev/null || true)"
gh workflow run "$WORKFLOW" -R "$REPO" --ref "$BRANCH" || { die workflow_dispatch "dispatch failed"; exit 10; }

for _ in {1..20}; do
  sleep 3
  DISPATCHED_RUN_ID="$(gh run list -R "$REPO" --workflow "$WORKFLOW" --branch "$BRANCH" --event workflow_dispatch --limit 10 --json databaseId --jq '.[0].databaseId // empty' 2>/dev/null || true)"
  if [[ -n "$DISPATCHED_RUN_ID" ]] && ! grep -qx "$DISPATCHED_RUN_ID" <<<"$before_ids"; then break; fi
done
[[ -n "$DISPATCHED_RUN_ID" ]] || { die workflow_observation "dispatch accepted but new run not observed"; exit 11; }
echo "Dispatched run ID: $DISPATCHED_RUN_ID"

log "10. Observe result and collect evidence"
if [[ "$WAIT_FOR_RUN" == "true" ]]; then
  gh run watch "$DISPATCHED_RUN_ID" -R "$REPO" --exit-status || true
fi
run_json="$(gh run view "$DISPATCHED_RUN_ID" -R "$REPO" --json status,conclusion,event,headSha,jobs,url)"
echo "$run_json"
FINAL_CONCLUSION="$(printf '%s' "$run_json" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("conclusion") or "")')"
gh run view "$DISPATCHED_RUN_ID" -R "$REPO" --log > "$RECEIPT_DIR/${RUN_ID}-workflow.log" 2>&1 || true
mkdir -p "$RECEIPT_DIR/${RUN_ID}-artifacts"
gh run download "$DISPATCHED_RUN_ID" -R "$REPO" -D "$RECEIPT_DIR/${RUN_ID}-artifacts" || warn "No downloadable artifacts"

case "$FINAL_CONCLUSION" in
  success) STATUS="REAL" ;;
  failure|cancelled|timed_out|action_required|startup_failure) STATUS="PARTIAL"; FAILURE_STAGE="workflow_execution"; FAILURE_REASON="workflow conclusion: $FINAL_CONCLUSION" ;;
  *) STATUS="PARTIAL"; FAILURE_STAGE="workflow_observation"; FAILURE_REASON="non-terminal or unknown conclusion: $FINAL_CONCLUSION" ;;
esac

log "11. Final classification: $STATUS"
exit 0
