#!/usr/bin/env bash
set -Eeuo pipefail

# Canonical one-bundle runtime for issue #237.
# Loads SSM, verifies/provisions folders, deploys Sieve, sends a bounded token test,
# reads back source + agent mailboxes, creates a downstream job, and emits evidence-derived receipts.

ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
REGION="${AWS_REGION:-ap-southeast-2}"
PREFIX="${MIGADU_SSM_PREFIX:-/t4h/migadu/runtime}"
RUN_ID="${GITHUB_RUN_ID:-local-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_DIR="${RECEIPT_DIR:-$ROOT/runtime/issue-237/$RUN_ID/one-bundle}"
LEDGER="$ROOT/runtime/ledger/issue-237.jsonl"
RECEIPT="$RUN_DIR/deployment-receipt.json"
mkdir -p "$RUN_DIR" "$(dirname "$LEDGER")"

STATE=BLOCKED
STEP=preflight
EXIT_CODE=0
FOLDERS_VERIFIED=false
SIEVE_UPLOADED=false
ROUTING_VERIFIED=false
AGENT_DELIVERY=false
JOB_CREATED=false
LEDGER_PERSISTED=false
TOKEN="T4H-ISSUE-237-$RUN_ID"
SCRIPT_NAME="t4h-github-agent-routing"
SIEVE_FILE="$RUN_DIR/$SCRIPT_NAME.sieve"
MS_RECEIPT="$RUN_DIR/managesieve-deployment.json"
FOLDER_RECEIPT="$RUN_DIR/folder-verification.json"
READBACK_RECEIPT="$RUN_DIR/routing-readback.json"
JOB_RECEIPT="$RUN_DIR/agent-job.json"
LOG="$RUN_DIR/execution.log"
exec > >(tee -a "$LOG") 2>&1

emit_receipt() {
  local reason="$1"
  jq -n \
    --arg schema_version "t4h.issue-237.one-bundle.v1" \
    --arg run_id "$RUN_ID" \
    --arg generated_at "$(date -u +%FT%TZ)" \
    --arg state "$STATE" \
    --arg step "$STEP" \
    --arg reason "$reason" \
    --arg token "$TOKEN" \
    --arg log "$LOG" \
    --arg folder_receipt "$FOLDER_RECEIPT" \
    --arg managesieve_receipt "$MS_RECEIPT" \
    --arg readback_receipt "$READBACK_RECEIPT" \
    --arg job_receipt "$JOB_RECEIPT" \
    --argjson exit_code "$EXIT_CODE" \
    --argjson folder_placement "$FOLDERS_VERIFIED" \
    --argjson sieve_uploaded "$SIEVE_UPLOADED" \
    --argjson routing_test_verified "$ROUTING_VERIFIED" \
    --argjson agent_delivery "$AGENT_DELIVERY" \
    --argjson job_creation "$JOB_CREATED" \
    --argjson ledger_persistence "$LEDGER_PERSISTED" \
    '{schema_version:$schema_version,run_id:$run_id,generated_at:$generated_at,state:$state,current_step:$step,exit_code:$exit_code,reason:$reason,test_token:$token,evidence:{execution_log:$log,folder_receipt:$folder_receipt,managesieve_receipt:$managesieve_receipt,readback_receipt:$readback_receipt,job_receipt:$job_receipt},real_gate:{folder_placement:$folder_placement,sieve_uploaded:$sieve_uploaded,routing_test_verified:$routing_test_verified,agent_delivery:$agent_delivery,job_creation:$job_creation,investigation:false,repair_or_rerun:false,github_readback:false,ledger_persistence:$ledger_persistence}}' > "$RECEIPT"
  jq -c . "$RECEIPT" >> "$LEDGER"
  LEDGER_PERSISTED=true
  jq -e --arg run "$RUN_ID" 'select(.run_id==$run)' "$LEDGER" >/dev/null
}

fail() {
  EXIT_CODE=$?
  STATE=BLOCKED
  emit_receipt "failed at $STEP"
  exit "$EXIT_CODE"
}
trap fail ERR

need(){ command -v "$1" >/dev/null 2>&1 || { echo "missing dependency: $1"; return 1; }; }
for c in aws jq python3 curl openssl swaks git; do need "$c"; done
[[ -f "$ROOT/tools/managesieve_direct.py" ]] || { echo "missing direct ManageSieve client"; exit 2; }

load_secret(){
  local name="$1" value
  [[ -n "${!name:-}" ]] && return 0
  value="$(aws ssm get-parameter --region "$REGION" --name "$PREFIX/$name" --with-decryption --query 'Parameter.Value' --output text)"
  [[ -n "$value" && "$value" != None ]] || return 1
  printf -v "$name" '%s' "$value"
  export "$name"
}

STEP=load-secrets
for n in MIGADU_ADMIN_EMAIL MIGADU_API_KEY MIGADU_DOMAIN SOURCE_MAILBOX SOURCE_MAILBOX_PASSWORD AGENT_MAILBOX_PASSWORD SWAKS_SERVER SWAKS_USER SWAKS_PASSWORD; do load_secret "$n"; done
AGENT_MAILBOX="github-agent@$MIGADU_DOMAIN"
IMAP_HOST="${IMAP_HOST:-imap.migadu.com}"
IMAP_PORT="${IMAP_PORT:-993}"
SIEVE_HOST="${SIEVE_HOST:-imap.migadu.com}"
SIEVE_PORT="${SIEVE_PORT:-4190}"
SMTP_SERVER="${SWAKS_SERVER:-smtp.migadu.com:587}"

STEP=folders
IMAP_HOST="$IMAP_HOST" IMAP_PORT="$IMAP_PORT" SOURCE_MAILBOX="$SOURCE_MAILBOX" SOURCE_MAILBOX_PASSWORD="$SOURCE_MAILBOX_PASSWORD" FOLDER_RECEIPT="$FOLDER_RECEIPT" python3 - <<'PY'
import imaplib,json,os,time
folders=['Systems','Systems/GitHub','Systems/GitHub/Failures','Systems/GitHub/Security','Systems/GitHub/Pull Requests','Systems/GitHub/Receipts']

def q(name: str) -> str:
    return '"' + name.replace('\\', '\\\\').replace('"', '\\"') + '"'

with imaplib.IMAP4_SSL(os.environ['IMAP_HOST'],int(os.environ['IMAP_PORT']),timeout=30) as m:
    m.login(os.environ['SOURCE_MAILBOX'],os.environ['SOURCE_MAILBOX_PASSWORD'])
    status,rows=m.list()
    listing='\n'.join(x.decode(errors='replace') for x in (rows or []))
    created=[]
    for folder in folders:
        if q(folder) in listing or f' {folder}' in listing:
            created.append({'folder':folder,'status':'EXISTS','response':['already present']})
            continue
        last_status='NO'; last_data=[]
        for attempt in range(1,4):
            try:
                last_status,last_data=m.create(q(folder))
            except imaplib.IMAP4.error as exc:
                last_status='BAD'; last_data=[str(exc)]
            if last_status=='OK':
                break
            time.sleep(attempt)
        created.append({'folder':folder,'status':last_status,'response':[x.decode(errors='replace') if isinstance(x,bytes) else str(x) for x in (last_data or [])]})
        status,rows=m.list()
        listing='\n'.join(x.decode(errors='replace') for x in (rows or []))
    status,rows=m.list()
    listing='\n'.join(x.decode(errors='replace') for x in (rows or []))
    missing=[f for f in folders if q(f) not in listing and f' {f}' not in listing]
    out={'verified':not missing,'missing':missing,'created':created,'listing':listing}
    open(os.environ['FOLDER_RECEIPT'],'w').write(json.dumps(out,indent=2)+'\n')
    if missing: raise SystemExit(3)
PY
FOLDERS_VERIFIED=true

STEP=build-sieve
cat > "$SIEVE_FILE" <<SIEVE
require ["fileinto", "copy"];

# Bounded acceptance test. Production mail never carries this generated token header.
if header :is "X-T4H-Routing-Test" "$TOKEN" {
    fileinto :copy "Systems/GitHub/Failures";
    redirect :copy "$AGENT_MAILBOX";
    stop;
}

# Production GitHub failure routing.
if allof (
    not header :is "X-T4H-Agent-Processed" "true",
    address :domain :is "from" "github.com",
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

if address :domain :is "from" "github.com" {
    fileinto "Systems/GitHub";
    stop;
}
SIEVE

grep -Fq "$TOKEN" "$SIEVE_FILE"
grep -Fq 'require ["fileinto", "copy"];' "$SIEVE_FILE"

STEP=deploy-sieve
python3 "$ROOT/tools/managesieve_direct.py" --host "$SIEVE_HOST" --port "$SIEVE_PORT" --user "$SOURCE_MAILBOX" --password "$SOURCE_MAILBOX_PASSWORD" --script "$SIEVE_FILE" --name "$SCRIPT_NAME" --receipt "$MS_RECEIPT"
jq -e '.state=="REAL" and .authenticated and .uploaded and .active' "$MS_RECEIPT" >/dev/null
SIEVE_UPLOADED=true

STEP=send-test
swaks --server "$SMTP_SERVER" --tls --auth LOGIN --auth-user "$SWAKS_USER" --auth-password "$SWAKS_PASSWORD" --from "$SWAKS_USER" --to "$SOURCE_MAILBOX" --header "Subject: T4H bounded routing test $TOKEN" --header "X-T4H-Routing-Test: $TOKEN" --body "Bounded issue #237 routing acceptance test $TOKEN" | tee "$RUN_DIR/test-send.txt"

STEP=readback
IMAP_HOST="$IMAP_HOST" IMAP_PORT="$IMAP_PORT" SOURCE_MAILBOX="$SOURCE_MAILBOX" SOURCE_MAILBOX_PASSWORD="$SOURCE_MAILBOX_PASSWORD" AGENT_MAILBOX="$AGENT_MAILBOX" AGENT_MAILBOX_PASSWORD="$AGENT_MAILBOX_PASSWORD" TOKEN="$TOKEN" READBACK_RECEIPT="$READBACK_RECEIPT" python3 - <<'PY'
import imaplib,json,os,time

def q(name: str) -> str:
    return '"' + name.replace('\\', '\\\\').replace('"', '\\"') + '"'

def count(mailbox,password,folder):
    with imaplib.IMAP4_SSL(os.environ['IMAP_HOST'],int(os.environ['IMAP_PORT']),timeout=30) as m:
        m.login(mailbox,password)
        typ,_=m.select(q(folder),readonly=True)
        if typ!='OK': return 0
        typ,data=m.search(None,'HEADER','X-T4H-Routing-Test',q(os.environ['TOKEN']))
        return len((data[0] or b'').split()) if typ=='OK' else 0

source=agent=0
for attempt in range(1,7):
    source=count(os.environ['SOURCE_MAILBOX'],os.environ['SOURCE_MAILBOX_PASSWORD'],'Systems/GitHub/Failures')
    agent=count(os.environ['AGENT_MAILBOX'],os.environ['AGENT_MAILBOX_PASSWORD'],'INBOX')
    if source==1 and agent==1: break
    time.sleep(5)
out={'token':os.environ['TOKEN'],'source_folder_count':source,'agent_inbox_count':agent,'folder_placement':source==1,'agent_delivery':agent==1,'exactly_once':source==1 and agent==1}
open(os.environ['READBACK_RECEIPT'],'w').write(json.dumps(out,indent=2)+'\n')
if not out['exactly_once']: raise SystemExit(4)
PY
ROUTING_VERIFIED=true
AGENT_DELIVERY=true

STEP=create-job
jq -n --arg job_id "github-investigation-$TOKEN" --arg token "$TOKEN" --arg mailbox "$AGENT_MAILBOX" --arg created_at "$(date -u +%FT%TZ)" '{schema_version:"t4h.github-investigation-job.v1",job_id:$job_id,source_token:$token,source_mailbox:$mailbox,created_at:$created_at,state:"QUEUED",requested_actions:["identify workflow/run/job","collect logs","classify failure","apply bounded repair","rerun failed jobs","read back GitHub final state","emit downstream receipt"]}' > "$JOB_RECEIPT"
jq -e '.state=="QUEUED" and .job_id' "$JOB_RECEIPT" >/dev/null
JOB_CREATED=true

STEP=classify
STATE=PARTIAL
EXIT_CODE=0
emit_receipt "routing, exactly-once agent delivery and downstream job creation are REAL; GitHub investigation, repair/rerun and readback remain pending"
printf 'state=%s\nreceipt=%s\nledger=%s\n' "$STATE" "$RECEIPT" "$LEDGER"
