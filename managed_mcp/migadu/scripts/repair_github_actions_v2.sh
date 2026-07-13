#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
REPO="${REPO:-TML-4PM/the-pen}"; BRANCH="${BRANCH:-feat/migadu-managed-mcp}"
WORKFLOW="${WORKFLOW:-migadu-managed-mcp-validation.yml}"; FAILED_RUN_ID="${FAILED_RUN_ID:-29223807951}"
RECEIPT_DIR="${RECEIPT_DIR:-./github-actions-repair-receipts}"; LEDGER_FILE="${LEDGER_FILE:-}"
KEYCHAIN_SERVICE="${TOKEN_KEYCHAIN_SERVICE:-t4h-github-token}"; WAIT_FOR_RUN="${WAIT_FOR_RUN:-true}"
RUN_KEY="gha-repair-$(date -u +%Y%m%dT%H%M%SZ)-$$"; STARTED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
mkdir -p "$RECEIPT_DIR"; LOG="$RECEIPT_DIR/$RUN_KEY.log"; JSON="$RECEIPT_DIR/$RUN_KEY.json"; MD="$RECEIPT_DIR/$RUN_KEY.md"
exec > >(tee -a "$LOG") 2>&1
STATUS=PARTIAL; STAGE=init; REASON=""; TOKEN_SOURCE=none; PERMISSION=""; NEW_RUN=""; CONCLUSION=""
ACTIONS_BEFORE='{}'; ACTIONS_AFTER='{}'; WORKFLOW_BEFORE='{}'; WORKFLOW_AFTER='{}'
log(){ printf '\n== %s ==\n' "$*"; }; have(){ command -v "$1" >/dev/null 2>&1; }
block(){ STATUS=BLOCKED; STAGE="$1"; REASON="$2"; echo "BLOCKED[$STAGE]: $REASON" >&2; exit "${3:-1}"; }
receipt(){
  local rc=$? ended hash
  ended="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  hash="$(shasum -a 256 "$LOG" 2>/dev/null | awk '{print $1}' || sha256sum "$LOG" 2>/dev/null | awk '{print $1}' || echo unavailable)"
  export R_RUN="$RUN_KEY" R_STARTED="$STARTED" R_ENDED="$ended" R_STATUS="$STATUS" R_STAGE="$STAGE" R_REASON="$REASON"
  export R_REPO="$REPO" R_BRANCH="$BRANCH" R_WORKFLOW="$WORKFLOW" R_FAILED="$FAILED_RUN_ID" R_NEW="$NEW_RUN" R_CONCLUSION="$CONCLUSION"
  export R_SOURCE="$TOKEN_SOURCE" R_PERMISSION="$PERMISSION" R_AB="$ACTIONS_BEFORE" R_AA="$ACTIONS_AFTER" R_WB="$WORKFLOW_BEFORE" R_WA="$WORKFLOW_AFTER" R_LOG="$LOG" R_HASH="$hash"
  python3 - "$JSON" <<'PY'
import json,os,sys
def j(n):
 try:return json.loads(os.environ.get(n,'{}') or '{}')
 except:return {'unparsed':os.environ.get(n,'')}
d={
'schema_version':'1.0.0','run_id':os.environ['R_RUN'],'started_at':os.environ['R_STARTED'],'ended_at':os.environ['R_ENDED'],
'status':os.environ['R_STATUS'],'stage':os.environ['R_STAGE'],'reason':os.environ['R_REASON'],'repository':os.environ['R_REPO'],
'branch':os.environ['R_BRANCH'],'workflow':os.environ['R_WORKFLOW'],'failed_run_inspected':os.environ['R_FAILED'],
'dispatched_run_id':os.environ['R_NEW'],'final_conclusion':os.environ['R_CONCLUSION'],'token_source':os.environ['R_SOURCE'],
'token_value_recorded':False,'repository_permission':os.environ['R_PERMISSION'],'actions_before':j('R_AB'),'actions_after':j('R_AA'),
'workflow_permissions_before':j('R_WB'),'workflow_permissions_after':j('R_WA'),'raw_log':os.path.basename(os.environ['R_LOG']),'raw_log_sha256':os.environ['R_HASH']}
json.dump(d,open(sys.argv[1],'w'),indent=2,sort_keys=True)
PY
  cat > "$MD" <<EOF
# GitHub Actions Repair Receipt
- Run: \`$RUN_KEY\`
- Status: **$STATUS**
- Stage: \`$STAGE\`
- Reason: \`${REASON:-none}\`
- Repository: \`$REPO\`
- Token source: \`$TOKEN_SOURCE\` (value not stored)
- Permission: \`$PERMISSION\`
- Dispatched run: \`${NEW_RUN:-none}\`
- Conclusion: \`${CONCLUSION:-not observed}\`
- Log SHA-256: \`$hash\`
EOF
  if [[ -n "$LEDGER_FILE" ]]; then mkdir -p "$(dirname "$LEDGER_FILE")"; python3 - "$JSON" "$LEDGER_FILE" <<'PY'
import json,sys
r=json.load(open(sys.argv[1])); r={'entry_type':'GITHUB_ACTIONS_REPAIR',**{k:r.get(k) for k in ('run_id','started_at','ended_at','status','stage','reason','repository','branch','workflow','dispatched_run_id','final_conclusion','raw_log_sha256')}}
open(sys.argv[2],'a').write(json.dumps(r,sort_keys=True)+'\n')
PY
  fi
  exit $rc
}
trap receipt EXIT

log '1. Network preflight'; have curl || block preflight 'curl missing'; have python3 || block preflight 'python3 missing'
python3 - <<'PY' || block network 'github.com DNS resolution failed' 2
import socket; socket.getaddrinfo('github.com',443)
PY
curl -fsSI --max-time 20 https://github.com >/dev/null || block network 'HTTPS to github.com failed' 2

log '2. Install gh'
if ! have gh; then
  if have brew; then brew install gh
  elif have apt-get; then sudo mkdir -p -m 755 /etc/apt/keyrings; curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null; sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null; sudo apt-get update; sudo apt-get install -y gh
  else block install_gh 'no supported package manager'; fi
fi
gh --version

log '3. Resolve token without persistence'
if [[ -n "${GH_TOKEN:-}" ]]; then TOKEN_SOURCE=GH_TOKEN
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then export GH_TOKEN="$GITHUB_TOKEN"; TOKEN_SOURCE=GITHUB_TOKEN
elif have security && token="$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || true)" && [[ -n "$token" ]]; then export GH_TOKEN="$token"; unset token; TOKEN_SOURCE="Keychain:$KEYCHAIN_SERVICE"
else read -rsp 'Paste GitHub token (input hidden): ' GH_TOKEN; echo; export GH_TOKEN; TOKEN_SOURCE='interactive hidden input'; fi
[[ -n "${GH_TOKEN:-}" ]] || block credentials 'no token available'

log '4. Authenticate and verify authority'
login="$(gh api user --jq .login 2>/dev/null)" || block authentication 'token rejected'; echo "Authenticated as $login"
repo_json="$(gh repo view "$REPO" --json viewerPermission,nameWithOwner,isPrivate)" || block repository_access "cannot read $REPO"
PERMISSION="$(printf '%s' "$repo_json" | python3 -c 'import json,sys;print(json.load(sys.stdin)["viewerPermission"])')"; echo "$repo_json"
case "$PERMISSION" in ADMIN|MAINTAIN) ;; *) block repository_authority "ADMIN or MAINTAIN required; got $PERMISSION";; esac

log '5. Inspect existing state'
gh workflow list -R "$REPO" || true; gh run list -R "$REPO" --limit 10 || true
[[ -z "$FAILED_RUN_ID" ]] || gh run view "$FAILED_RUN_ID" -R "$REPO" --json status,conclusion,event,headSha,jobs,url || true

log '6. Repair and verify Actions settings'
ACTIONS_BEFORE="$(gh api "/repos/$REPO/actions/permissions")" || block actions_read 'cannot read Actions permissions'
WORKFLOW_BEFORE="$(gh api "/repos/$REPO/actions/permissions/workflow")" || block workflow_read 'cannot read workflow permissions'
gh api --method PUT "/repos/$REPO/actions/permissions" -F enabled=true -f allowed_actions=all >/dev/null || block actions_update 'failed to enable Actions'
gh api --method PUT "/repos/$REPO/actions/permissions/workflow" -f default_workflow_permissions=write -F can_approve_pull_request_reviews=false >/dev/null || block workflow_update 'failed to set workflow permissions'
ACTIONS_AFTER="$(gh api "/repos/$REPO/actions/permissions")"; WORKFLOW_AFTER="$(gh api "/repos/$REPO/actions/permissions/workflow")"
export ACTIONS_AFTER WORKFLOW_AFTER; python3 - <<'PY' || block settings_verify 'Actions settings did not persist'
import json,os
a=json.loads(os.environ['ACTIONS_AFTER']);w=json.loads(os.environ['WORKFLOW_AFTER'])
assert a.get('enabled') is True and a.get('allowed_actions')=='all'; assert w.get('default_workflow_permissions')=='write'
PY

log '7. Dispatch and observe validation workflow'
before="$(gh run list -R "$REPO" --workflow "$WORKFLOW" --limit 20 --json databaseId --jq '.[].databaseId' 2>/dev/null || true)"
gh workflow run "$WORKFLOW" -R "$REPO" --ref "$BRANCH" || block dispatch 'workflow dispatch failed'
for _ in {1..20}; do sleep 3; NEW_RUN="$(gh run list -R "$REPO" --workflow "$WORKFLOW" --branch "$BRANCH" --event workflow_dispatch --limit 1 --json databaseId --jq '.[0].databaseId // empty' 2>/dev/null || true)"; [[ -n "$NEW_RUN" ]] && ! grep -qx "$NEW_RUN" <<<"$before" && break; done
[[ -n "$NEW_RUN" ]] || block observation 'new workflow run not observed'
[[ "$WAIT_FOR_RUN" != true ]] || gh run watch "$NEW_RUN" -R "$REPO" --exit-status || true
run_json="$(gh run view "$NEW_RUN" -R "$REPO" --json status,conclusion,event,headSha,jobs,url)"; echo "$run_json"
CONCLUSION="$(printf '%s' "$run_json" | python3 -c 'import json,sys;print(json.load(sys.stdin).get("conclusion") or "")')"
gh run view "$NEW_RUN" -R "$REPO" --log > "$RECEIPT_DIR/$RUN_KEY-workflow.log" 2>&1 || true
mkdir -p "$RECEIPT_DIR/$RUN_KEY-artifacts"; gh run download "$NEW_RUN" -R "$REPO" -D "$RECEIPT_DIR/$RUN_KEY-artifacts" || true
if [[ "$CONCLUSION" == success ]]; then STATUS=REAL; STAGE=complete; else STATUS=PARTIAL; STAGE=workflow; REASON="conclusion: ${CONCLUSION:-unknown}"; fi
log "8. Final state: $STATUS"
