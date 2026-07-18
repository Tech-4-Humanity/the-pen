#!/usr/bin/env bash
set -Eeuo pipefail

# T4H Mail OS — Migadu GitHub Failure Routing + Autonomous Agent Intake
# ALL-SPRINTS STRAP-ON BUNDLE
#
# Purpose
#   Provision a dedicated Migadu agent mailbox, create/verify the target IMAP
#   folders, install a loop-safe Sieve routing policy, perform bounded tests,
#   and emit receipt-grade evidence.
#
# Truth state
#   The source bundle is deployable. Runtime state is PARTIAL until this script
#   completes against live Migadu credentials and the downstream agent returns
#   a verified investigation/fix receipt.
#
# Required environment
#   MIGADU_ADMIN_EMAIL       Migadu administrator login
#   MIGADU_API_KEY           Migadu API key
#   MIGADU_DOMAIN            e.g. tech4humanity.net
#   SOURCE_MAILBOX           e.g. troy@tech4humanity.net
#   SOURCE_MAILBOX_PASSWORD  app/mailbox password for IMAP + ManageSieve
#
# Optional environment
#   AGENT_LOCAL_PART         default github-agent
#   AGENT_MAILBOX_PASSWORD   required when creating a login-capable mailbox
#   IMAP_HOST                default imap.migadu.com
#   IMAP_PORT                default 993
#   SIEVE_HOST               default sieve.migadu.com
#   SIEVE_PORT               default 4190
#   RECEIPT_DIR              default ./receipts/migadu-github-agent-routing
#   APPLY                    0=dry-run, 1=execute (default 0)
#   TEST_RECIPIENT           defaults to SOURCE_MAILBOX
#   GITHUB_SENDER_DOMAIN     default github.com
#
# Dependencies
#   bash, curl, jq, openssl, python3
#   optional but recommended: swaks, sieveshell or sieve-connect

BUNDLE_ID="migadu-github-agent-routing-all-sprints-20260718"
APPLY="${APPLY:-0}"
MIGADU_API_BASE="${MIGADU_API_BASE:-https://api.migadu.com/v1}"
AGENT_LOCAL_PART="${AGENT_LOCAL_PART:-github-agent}"
IMAP_HOST="${IMAP_HOST:-imap.migadu.com}"
IMAP_PORT="${IMAP_PORT:-993}"
SIEVE_HOST="${SIEVE_HOST:-sieve.migadu.com}"
SIEVE_PORT="${SIEVE_PORT:-4190}"
GITHUB_SENDER_DOMAIN="${GITHUB_SENDER_DOMAIN:-github.com}"
RECEIPT_DIR="${RECEIPT_DIR:-./receipts/migadu-github-agent-routing}"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$RECEIPT_DIR/$RUN_ID"
mkdir -p "$RUN_DIR"
LOG="$RUN_DIR/execution.log"
RECEIPT="$RUN_DIR/deployment-receipt.json"
LEDGER="$RECEIPT_DIR/ledger.jsonl"
SIEVE_FILE="$RUN_DIR/github-agent-routing.sieve"

exec > >(tee -a "$LOG") 2>&1

state="PARTIAL"
step="preflight"
rollback_actions=()

fail() {
  local rc=$?
  state="BLOCKED"
  printf 'ERROR step=%s rc=%s line=%s\n' "$step" "$rc" "${BASH_LINENO[0]}"
  emit_receipt "$rc"
  exit "$rc"
}
trap fail ERR

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing dependency: $1"; return 1; }; }
require_env() { [[ -n "${!1:-}" ]] || { echo "missing environment variable: $1"; return 1; }; }
sha256_file() { openssl dgst -sha256 "$1" | awk '{print $NF}'; }
json_bool() { [[ "$1" == "1" ]] && echo true || echo false; }

emit_receipt() {
  local rc="${1:-0}"
  local sieve_sha=""
  [[ -f "$SIEVE_FILE" ]] && sieve_sha="$(sha256_file "$SIEVE_FILE")"
  jq -n \
    --arg bundle_id "$BUNDLE_ID" \
    --arg run_id "$RUN_ID" \
    --arg generated_at "$(date -u +%FT%TZ)" \
    --arg state "$state" \
    --arg step "$step" \
    --arg domain "${MIGADU_DOMAIN:-}" \
    --arg source_mailbox "${SOURCE_MAILBOX:-}" \
    --arg agent_mailbox "${AGENT_LOCAL_PART}@${MIGADU_DOMAIN:-}" \
    --arg sieve_sha256 "$sieve_sha" \
    --arg log "$LOG" \
    --argjson apply "$(json_bool "$APPLY")" \
    --argjson exit_code "$rc" \
    '{
      bundle_id:$bundle_id,
      run_id:$run_id,
      generated_at:$generated_at,
      state:$state,
      current_step:$step,
      apply:$apply,
      exit_code:$exit_code,
      target:{domain:$domain,source_mailbox:$source_mailbox,agent_mailbox:$agent_mailbox},
      evidence:{sieve_sha256:$sieve_sha256,execution_log:$log},
      real_gate:{
        provisioned:false,
        folders_verified:false,
        sieve_uploaded:false,
        routing_test_verified:false,
        agent_job_created:false,
        investigation_completed:false,
        repair_verified:false,
        downstream_receipt_observed:false
      },
      classification_reason:(if $state=="REAL" then "All local and downstream runtime gates observed" else "Bundle emitted; one or more live/runtime/downstream gates remain unobserved" end)
    }' > "$RECEIPT"
  printf '%s\n' "$(cat "$RECEIPT")" >> "$LEDGER"
  echo "receipt=$RECEIPT"
}

# ---------------------------------------------------------------------------
# SPRINT 00 — Intent, authority, safety and preflight
# ---------------------------------------------------------------------------
step="sprint-00-preflight"
for c in bash curl jq openssl python3; do need "$c"; done
for v in MIGADU_ADMIN_EMAIL MIGADU_API_KEY MIGADU_DOMAIN SOURCE_MAILBOX SOURCE_MAILBOX_PASSWORD; do require_env "$v"; done

AGENT_MAILBOX="${AGENT_LOCAL_PART}@${MIGADU_DOMAIN}"
TEST_RECIPIENT="${TEST_RECIPIENT:-$SOURCE_MAILBOX}"

[[ "$SOURCE_MAILBOX" == *@"$MIGADU_DOMAIN" ]] || {
  echo "SOURCE_MAILBOX must belong to MIGADU_DOMAIN"
  exit 2
}

cat > "$RUN_DIR/authority.json" <<JSON
{
  "bundle_id": "$BUNDLE_ID",
  "allowed": [
    "read Migadu domain/mailbox configuration",
    "create bounded agent mailbox",
    "create IMAP folders",
    "install named Sieve script",
    "send bounded routing test",
    "emit receipt and ledger"
  ],
  "forbidden_without_separate_authority": [
    "delete mailboxes",
    "delete messages",
    "modify unrelated Sieve scripts",
    "destructive GitHub changes",
    "credential disclosure"
  ]
}
JSON

# ---------------------------------------------------------------------------
# SPRINT 01 — Discover current Migadu state through API
# ---------------------------------------------------------------------------
step="sprint-01-discovery"
api() {
  local method="$1" path="$2" body="${3:-}"
  local args=(--fail-with-body --silent --show-error --user "$MIGADU_ADMIN_EMAIL:$MIGADU_API_KEY" -X "$method")
  [[ -n "$body" ]] && args+=(--header 'Content-Type: application/json' --data "$body")
  curl "${args[@]}" "$MIGADU_API_BASE$path"
}

api GET "/domains/$MIGADU_DOMAIN" > "$RUN_DIR/domain-before.json"
api GET "/domains/$MIGADU_DOMAIN/mailboxes" > "$RUN_DIR/mailboxes-before.json"

# ---------------------------------------------------------------------------
# SPRINT 02 — Provision or verify dedicated GitHub agent mailbox
# ---------------------------------------------------------------------------
step="sprint-02-agent-mailbox"
agent_exists="$(jq -r --arg a "$AGENT_MAILBOX" '[..|objects|.address? // empty] | any(. == $a)' "$RUN_DIR/mailboxes-before.json")"

if [[ "$agent_exists" != "true" ]]; then
  [[ "$APPLY" == "1" ]] || echo "DRY-RUN: would create $AGENT_MAILBOX"
  if [[ "$APPLY" == "1" ]]; then
    require_env AGENT_MAILBOX_PASSWORD
    payload="$(jq -n \
      --arg local "$AGENT_LOCAL_PART" \
      --arg password "$AGENT_MAILBOX_PASSWORD" \
      '{name:"GitHub Investigation Agent",local_part:$local,password:$password,password_method:"plain",is_internal:false,may_receive:true,may_send:true,may_access_imap:true,may_access_pop3:false,may_access_managesieve:true}')"
    api POST "/domains/$MIGADU_DOMAIN/mailboxes" "$payload" > "$RUN_DIR/mailbox-create-response.json"
    rollback_actions+=("review/remove newly created mailbox $AGENT_MAILBOX only after preserving messages")
  fi
else
  echo "agent mailbox already exists: $AGENT_MAILBOX"
fi

if [[ "$APPLY" == "1" ]]; then
  api GET "/domains/$MIGADU_DOMAIN/mailboxes/$AGENT_LOCAL_PART" > "$RUN_DIR/agent-mailbox-after.json"
fi

# ---------------------------------------------------------------------------
# SPRINT 03 — Build canonical, loop-safe Sieve policy
# ---------------------------------------------------------------------------
step="sprint-03-build-sieve"
cat > "$SIEVE_FILE" <<SIEVE
require ["fileinto", "copy", "redirect"];

# T4H canonical GitHub failure routing.
# Keep the original, file it, and send one copy to the investigation agent.
if allof (
    not header :is "X-T4H-Agent-Processed" "true",
    address :domain :is "from" "$GITHUB_SENDER_DOMAIN",
    anyof (
        header :contains "subject" "Run failed:",
        header :contains "subject" "Workflow run failed",
        header :contains "subject" "Action required",
        header :contains "subject" "Check run failed",
        header :contains "subject" "Dependabot alert",
        header :contains "subject" "Code scanning alert",
        header :contains "subject" "Secret scanning alert"
    )
) {
    fileinto :copy "Systems/GitHub/Failures";
    redirect :copy "$AGENT_MAILBOX";
    stop;
}

# Non-failure GitHub notifications are filed without being sent to the agent.
if address :domain :is "from" "$GITHUB_SENDER_DOMAIN" {
    fileinto "Systems/GitHub";
    stop;
}
SIEVE

# Basic static validation: required clauses and no broad unconditional redirect.
grep -Fq 'X-T4H-Agent-Processed' "$SIEVE_FILE"
grep -Fq 'fileinto :copy "Systems/GitHub/Failures"' "$SIEVE_FILE"
grep -Fq "redirect :copy \"$AGENT_MAILBOX\"" "$SIEVE_FILE"
! grep -Eq '^redirect ' "$SIEVE_FILE"

# ---------------------------------------------------------------------------
# SPRINT 04 — Create and verify IMAP folders
# ---------------------------------------------------------------------------
step="sprint-04-imap-folders"
cat > "$RUN_DIR/create_folders.py" <<'PY'
import imaplib, json, os, ssl, sys
host=os.environ['IMAP_HOST']; port=int(os.environ['IMAP_PORT'])
user=os.environ['SOURCE_MAILBOX']; password=os.environ['SOURCE_MAILBOX_PASSWORD']
folders=['Systems','Systems/GitHub','Systems/GitHub/Failures','Systems/GitHub/Security','Systems/GitHub/Pull Requests','Systems/GitHub/Receipts']
ctx=ssl.create_default_context()
with imaplib.IMAP4_SSL(host, port, ssl_context=ctx) as m:
    typ,_=m.login(user,password)
    if typ!='OK': raise RuntimeError('IMAP login failed')
    created=[]
    for folder in folders:
        typ,data=m.create(folder)
        # ALREADYEXISTS is acceptable; LIST below is the independent gate.
        created.append({'folder':folder,'create_status':typ,'response':[x.decode(errors='replace') if isinstance(x,bytes) else str(x) for x in (data or [])]})
    typ,data=m.list()
    listing='\n'.join(x.decode(errors='replace') for x in (data or []))
    missing=[f for f in folders if f not in listing]
    out={'created':created,'missing':missing,'verified':not missing,'listing':listing}
    print(json.dumps(out,indent=2))
    if missing: sys.exit(3)
PY

if [[ "$APPLY" == "1" ]]; then
  IMAP_HOST="$IMAP_HOST" IMAP_PORT="$IMAP_PORT" SOURCE_MAILBOX="$SOURCE_MAILBOX" SOURCE_MAILBOX_PASSWORD="$SOURCE_MAILBOX_PASSWORD" \
    python3 "$RUN_DIR/create_folders.py" > "$RUN_DIR/folder-verification.json"
else
  echo "DRY-RUN: would create and verify canonical GitHub folders"
fi

# ---------------------------------------------------------------------------
# SPRINT 05 — Upload named Sieve script through CLI
# ---------------------------------------------------------------------------
step="sprint-05-sieve-upload"
upload_sieve() {
  if command -v sieve-connect >/dev/null 2>&1; then
    sieve-connect --server "$SIEVE_HOST" --port "$SIEVE_PORT" \
      --user "$SOURCE_MAILBOX" --password "$SOURCE_MAILBOX_PASSWORD" \
      --upload "$SIEVE_FILE" --scriptname t4h-github-agent-routing --activate
  elif command -v sieveshell >/dev/null 2>&1; then
    # sieveshell is interactive by default; feed deterministic commands.
    printf 'put %s t4h-github-agent-routing\nactivate t4h-github-agent-routing\nlist\nquit\n' "$SIEVE_FILE" |
      sieveshell --user "$SOURCE_MAILBOX" --authname "$SOURCE_MAILBOX" "$SIEVE_HOST:$SIEVE_PORT"
  else
    echo "BLOCKED: install sieve-connect or sieveshell for CLI deployment"
    return 4
  fi
}

if [[ "$APPLY" == "1" ]]; then
  upload_sieve | tee "$RUN_DIR/sieve-upload.txt"
else
  echo "DRY-RUN: would upload and activate t4h-github-agent-routing"
fi

# ---------------------------------------------------------------------------
# SPRINT 06 — Bounded routing test and readback
# ---------------------------------------------------------------------------
step="sprint-06-routing-test"
TEST_TOKEN="T4H-GITHUB-ROUTING-$RUN_ID"
cat > "$RUN_DIR/test-message.eml" <<MAIL
From: notifications@github.com
To: $TEST_RECIPIENT
Subject: [TML-4PM/the-pen] Run failed: Routing acceptance test $TEST_TOKEN
Message-ID: <$TEST_TOKEN@tech4humanity.net>
Date: $(LC_ALL=C date -R)

Synthetic bounded test generated by $BUNDLE_ID.
No production workflow failed.
MAIL

if [[ "$APPLY" == "1" ]]; then
  if command -v swaks >/dev/null 2>&1; then
    # Caller supplies SMTP credentials through SWAKS_SERVER/SWAKS_USER/SWAKS_PASSWORD.
    require_env SWAKS_SERVER
    require_env SWAKS_USER
    require_env SWAKS_PASSWORD
    swaks --server "$SWAKS_SERVER" --tls \
      --auth-user "$SWAKS_USER" --auth-password "$SWAKS_PASSWORD" \
      --from "notifications@github.com" --to "$TEST_RECIPIENT" \
      --header "Subject: [TML-4PM/the-pen] Run failed: Routing acceptance test $TEST_TOKEN" \
      --body "Synthetic bounded routing test $TEST_TOKEN" | tee "$RUN_DIR/test-send.txt"
    echo "Test sent. Independent mailbox and agent-job readback remains mandatory."
  else
    echo "PARTIAL: swaks unavailable; upload completed but routing test not sent"
  fi
else
  echo "DRY-RUN: would send bounded test token $TEST_TOKEN"
fi

# ---------------------------------------------------------------------------
# SPRINT 07 — Downstream agent execution contract
# ---------------------------------------------------------------------------
step="sprint-07-agent-contract"
cat > "$RUN_DIR/agent-execution-contract.json" <<JSON
{
  "schema_version": "1.0",
  "type": "github_failure_investigation",
  "source": "migadu",
  "mailbox": "$AGENT_MAILBOX",
  "deduplication_key": "RFC822 Message-ID",
  "loop_marker": {"header": "X-T4H-Agent-Processed", "value": "true"},
  "requested_actions": [
    "identify repository, workflow, run and failed job",
    "retrieve failed job steps and logs",
    "classify code, configuration, credential, runner or dependency fault",
    "apply bounded non-destructive repair when authorised",
    "rerun only failed jobs where appropriate",
    "verify successful completion and read back final state",
    "emit JSON receipt with evidence references"
  ],
  "authority": {
    "read_logs": true,
    "modify_repository": true,
    "rerun_workflow": true,
    "rotate_credentials": false,
    "delete_repository_data": false,
    "force_push": false
  },
  "real_requires": [
    "mail routed to folder",
    "copy observed in agent mailbox",
    "agent job ID created",
    "investigation evidence captured",
    "repair or explicit blocked classification emitted",
    "GitHub runtime re-read",
    "receipt and ledger entry persisted"
  ]
}
JSON

# ---------------------------------------------------------------------------
# SPRINT 08 — Validation, telemetry hooks, recovery and final classification
# ---------------------------------------------------------------------------
step="sprint-08-validation"
cat > "$RUN_DIR/recovery.md" <<RECOVERY
# Recovery

1. If API provisioning fails, retain before-state files and retry only after correcting credentials or API payload.
2. If folder creation fails, do not activate Sieve until all target folders verify through IMAP LIST.
3. If Sieve upload fails, preserve the generated script and use Migadu webmail Filters as a controlled fallback.
4. If routing duplicates occur, disable `t4h-github-agent-routing`, inspect active scripts, and retain the loop marker.
5. If agent execution fails, move the job to dead-letter with the original Message-ID and evidence references; do not silently discard it.
6. Never delete the source email during recovery.
RECOVERY

# The script itself can prove local generation and, in APPLY mode, bounded Migadu
# changes. It cannot honestly mark REAL without a downstream agent receipt.
if [[ "$APPLY" == "1" ]]; then
  state="PARTIAL"
else
  state="ASPIRATIONAL"
fi
step="complete"
emit_receipt 0

cat <<OUT

BUNDLE COMPLETE
state=$state
run_dir=$RUN_DIR
sieve=$SIEVE_FILE
receipt=$RECEIPT
ledger=$LEDGER

Next runtime command:
  APPLY=1 MIGADU_ADMIN_EMAIL=... MIGADU_API_KEY=... MIGADU_DOMAIN=tech4humanity.net \\
  SOURCE_MAILBOX=troy@tech4humanity.net SOURCE_MAILBOX_PASSWORD=... \\
  AGENT_MAILBOX_PASSWORD=... bash $0

REAL is withheld until the test message, agent job, investigation, repair/readback,
and downstream receipt are all observed.
OUT
