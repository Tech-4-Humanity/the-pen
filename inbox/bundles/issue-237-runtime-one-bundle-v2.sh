#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
REGION="${AWS_REGION:-ap-southeast-2}" PREFIX="${MIGADU_SSM_PREFIX:-/t4h/migadu/runtime}"
MODE="${1:-preflight}" RUN_ID="${ISSUE_237_RUN_ID:-local-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_DIR="${RECEIPT_DIR:-$ROOT/runtime/issue-237/$RUN_ID/$MODE}"
BUNDLE_LEDGER="$ROOT/runtime/ledger/issue-237-bundle-runs.jsonl"
JOB_LEDGER="$ROOT/runtime/ledger/issue-237-jobs.jsonl"
RECEIPT="$RUN_DIR/deployment-receipt.json" LOG="$RUN_DIR/execution.log"
mkdir -p "$RUN_DIR" "$(dirname "$BUNDLE_LEDGER")"; exec > >(tee -a "$LOG") 2>&1
[[ "$MODE" == preflight || "$MODE" == apply ]] || exit 2
STATE=BLOCKED STEP=init EXIT_CODE=0 TOKEN="T4H-ISSUE-237-$RUN_ID"
FOLDERS=false SIEVE=false SMTP=false ROUTING=false AGENT=false JOB=false DOWNSTREAM=false GITHUB=false INVESTIGATION=false REPAIR=false LEDGER=false
PREFLIGHT="$RUN_DIR/preflight.json" FOLDER_R="$RUN_DIR/folders.json" MS_R="$RUN_DIR/managesieve.json" READBACK="$RUN_DIR/readback.json" JOB_R="$RUN_DIR/job.json" DOWNSTREAM_R="$RUN_DIR/downstream.json" SIEVE_FILE="$RUN_DIR/routing.sieve"

receipt(){
 local reason="$1"
 jq -n --arg mode "$MODE" --arg run "$RUN_ID" --arg state "$STATE" --arg step "$STEP" --arg reason "$reason" --arg token "$TOKEN" --arg log "$LOG" --arg pre "$PREFLIGHT" --arg folders "$FOLDER_R" --arg ms "$MS_R" --arg readback "$READBACK" --arg job "$JOB_R" --arg downstream "$DOWNSTREAM_R" --argjson exit "$EXIT_CODE" --argjson folder "$FOLDERS" --argjson sieve "$SIEVE" --argjson smtp "$SMTP" --argjson routing "$ROUTING" --argjson agent "$AGENT" --argjson job_created "$JOB" --argjson downstream_invoked "$DOWNSTREAM" --argjson github "$GITHUB" --argjson investigation "$INVESTIGATION" --argjson repair "$REPAIR" --argjson ledger "$LEDGER" '{schema_version:"t4h.issue-237.bundle.v2",mode:$mode,run_id:$run,state:$state,current_step:$step,exit_code:$exit,reason:$reason,test_token:$token,evidence:{log:$log,preflight:$pre,folders:$folders,managesieve:$ms,readback:$readback,job:$job,downstream:$downstream},real_gate:{preflight:true,folder_placement:$folder,sieve_uploaded:$sieve,smtp_verified:$smtp,routing_test_verified:$routing,agent_delivery:$agent,job_creation:$job_created,downstream_invoked:$downstream_invoked,github_readback:$github,investigation:$investigation,repair_or_rerun:$repair,ledger_persistence:$ledger}}' > "$RECEIPT"
}
persist(){ LEDGER=true; receipt "$1"; jq -c . "$RECEIPT" >> "$BUNDLE_LEDGER"; jq -e --arg r "$RUN_ID" --arg m "$MODE" 'select(.run_id==$r and .mode==$m)' "$BUNDLE_LEDGER" >/dev/null; }
fail(){ local rc=$?; trap - ERR; set +e; EXIT_CODE=$rc STATE=BLOCKED; persist "failed at $STEP"; exit "$rc"; }
trap fail ERR
for c in aws jq python3 openssl git gh; do command -v "$c" >/dev/null; done
[[ -f "$ROOT/tools/managesieve_direct.py" && -f "$ROOT/workers/issue-237-downstream-github-worker.sh" ]]

ssm(){ local n="$1" v; v="$(aws ssm get-parameter --region "$REGION" --name "$PREFIX/$n" --with-decryption --query Parameter.Value --output text)"; [[ -n "$v" && "$v" != None ]]; printf -v "$n" %s "$v"; export "$n"; }
STEP=ssm
for n in MIGADU_ADMIN_EMAIL MIGADU_API_KEY MIGADU_DOMAIN SOURCE_MAILBOX SOURCE_MAILBOX_PASSWORD AGENT_MAILBOX_PASSWORD SWAKS_SERVER SWAKS_USER SWAKS_PASSWORD; do ssm "$n"; done
AGENT_MAILBOX="github-agent@$MIGADU_DOMAIN" IMAP_HOST=imap.migadu.com IMAP_PORT=993 SIEVE_HOST=imap.migadu.com SIEVE_PORT=4190
SMTP_HOST="${SWAKS_SERVER%:*}" SMTP_PORT="${SWAKS_SERVER##*:}" SMTP_TLS_MODE=starttls
[[ "$SMTP_HOST" == smtp.migadu.com && "$SMTP_PORT" == 587 && "$SMTP_TLS_MODE" == starttls ]]

STEP=preflight
IMAP_HOST="$IMAP_HOST" IMAP_PORT="$IMAP_PORT" SOURCE_MAILBOX="$SOURCE_MAILBOX" SOURCE_MAILBOX_PASSWORD="$SOURCE_MAILBOX_PASSWORD" AGENT_MAILBOX="$AGENT_MAILBOX" AGENT_MAILBOX_PASSWORD="$AGENT_MAILBOX_PASSWORD" SMTP_HOST="$SMTP_HOST" SMTP_PORT="$SMTP_PORT" SMTP_USER="$SWAKS_USER" SMTP_PASSWORD="$SWAKS_PASSWORD" PREFLIGHT="$PREFLIGHT" python3 - <<'PY'
import imaplib,json,os,smtplib,ssl
out={}
for k,u,p in [('source',os.environ['SOURCE_MAILBOX'],os.environ['SOURCE_MAILBOX_PASSWORD']),('agent',os.environ['AGENT_MAILBOX'],os.environ['AGENT_MAILBOX_PASSWORD'])]:
 with imaplib.IMAP4_SSL(os.environ['IMAP_HOST'],int(os.environ['IMAP_PORT']),timeout=30) as m: out[k+'_imap']=m.login(u,p)[0]=='OK'
with smtplib.SMTP(os.environ['SMTP_HOST'],int(os.environ['SMTP_PORT']),timeout=30) as s:
 s.ehlo(); s.starttls(context=ssl.create_default_context()); s.ehlo(); s.login(os.environ['SMTP_USER'],os.environ['SMTP_PASSWORD']); out['smtp_auth']=True
open(os.environ['PREFLIGHT'],'w').write(json.dumps(out,indent=2)+'\n')
if not all(out.values()): raise SystemExit(4)
PY
gh auth status >/dev/null
echo | openssl s_client -starttls sieve -connect "$SIEVE_HOST:$SIEVE_PORT" -servername "$SIEVE_HOST" -brief > "$RUN_DIR/managesieve-preflight.txt" 2>&1
jq '.+{github_auth:true,managesieve_tls:true}' "$PREFLIGHT" > "$PREFLIGHT.tmp" && mv "$PREFLIGHT.tmp" "$PREFLIGHT"; SMTP=true
if [[ "$MODE" == preflight ]]; then STATE=REAL STEP=done; persist "non-mutating preflight passed"; echo "state=$STATE receipt=$RECEIPT"; exit 0; fi

STEP=folders
IMAP_HOST="$IMAP_HOST" IMAP_PORT="$IMAP_PORT" SOURCE_MAILBOX="$SOURCE_MAILBOX" SOURCE_MAILBOX_PASSWORD="$SOURCE_MAILBOX_PASSWORD" OUT="$FOLDER_R" python3 - <<'PY'
import imaplib,json,os,time
fs=['Systems','Systems/GitHub','Systems/GitHub/Failures','Systems/GitHub/Security','Systems/GitHub/Pull Requests','Systems/GitHub/Receipts']; q=lambda s:'"'+s.replace('\\','\\\\').replace('"','\\"')+'"'
with imaplib.IMAP4_SSL(os.environ['IMAP_HOST'],int(os.environ['IMAP_PORT']),timeout=30) as m:
 m.login(os.environ['SOURCE_MAILBOX'],os.environ['SOURCE_MAILBOX_PASSWORD']); made=[]
 for f in fs:
  _,r=m.list(); listing='\n'.join(x.decode(errors='replace') for x in (r or []))
  if q(f) in listing: made.append({'folder':f,'status':'EXISTS'}); continue
  st='NO'; d=[]
  for a in range(1,4):
   st,d=m.create(q(f))
   if st=='OK': break
   time.sleep(a)
  made.append({'folder':f,'status':st})
 _,r=m.list(); listing='\n'.join(x.decode(errors='replace') for x in (r or [])); missing=[f for f in fs if q(f) not in listing]
 open(os.environ['OUT'],'w').write(json.dumps({'verified':not missing,'missing':missing,'created':made,'listing':listing},indent=2)+'\n')
 if missing: raise SystemExit(5)
PY
FOLDERS=true

STEP=sieve
cat > "$SIEVE_FILE" <<SIEVE
require ["fileinto", "copy"];
if header :is "X-T4H-Routing-Test" "$TOKEN" { fileinto :copy "Systems/GitHub/Failures"; redirect :copy "$AGENT_MAILBOX"; stop; }
if allof (not header :is "X-T4H-Agent-Processed" "true", address :domain :is "from" "github.com", anyof (header :contains "subject" "Run failed:", header :contains "subject" "Workflow run failed", header :contains "subject" "Action required", header :contains "subject" "Check run failed", header :contains "subject" "Dependabot alert", header :contains "subject" "Code scanning alert", header :contains "subject" "Secret scanning alert")) { fileinto :copy "Systems/GitHub/Failures"; redirect :copy "$AGENT_MAILBOX"; stop; }
if address :domain :is "from" "github.com" { fileinto "Systems/GitHub"; stop; }
SIEVE
python3 "$ROOT/tools/managesieve_direct.py" --host "$SIEVE_HOST" --port "$SIEVE_PORT" --user "$SOURCE_MAILBOX" --password "$SOURCE_MAILBOX_PASSWORD" --script "$SIEVE_FILE" --name t4h-github-agent-routing --receipt "$MS_R"
jq -e '.state=="REAL" and .authenticated and .uploaded and .active' "$MS_R" >/dev/null; SIEVE=true

STEP=send
SMTP_HOST="$SMTP_HOST" SMTP_PORT="$SMTP_PORT" SMTP_USER="$SWAKS_USER" SMTP_PASSWORD="$SWAKS_PASSWORD" TO="$SOURCE_MAILBOX" TOKEN="$TOKEN" python3 - <<'PY'
import os,smtplib,ssl
from email.message import EmailMessage
m=EmailMessage(); m['From']=os.environ['SMTP_USER']; m['To']=os.environ['TO']; m['Subject']='T4H bounded routing test '+os.environ['TOKEN']; m['X-T4H-Routing-Test']=os.environ['TOKEN']; m.set_content('Bounded issue #237 routing acceptance test '+os.environ['TOKEN'])
with smtplib.SMTP(os.environ['SMTP_HOST'],int(os.environ['SMTP_PORT']),timeout=30) as s: s.ehlo(); s.starttls(context=ssl.create_default_context()); s.ehlo(); s.login(os.environ['SMTP_USER'],os.environ['SMTP_PASSWORD']); s.send_message(m)
PY

STEP=readback
IMAP_HOST="$IMAP_HOST" IMAP_PORT="$IMAP_PORT" SOURCE_MAILBOX="$SOURCE_MAILBOX" SOURCE_MAILBOX_PASSWORD="$SOURCE_MAILBOX_PASSWORD" AGENT_MAILBOX="$AGENT_MAILBOX" AGENT_MAILBOX_PASSWORD="$AGENT_MAILBOX_PASSWORD" TOKEN="$TOKEN" OUT="$READBACK" python3 - <<'PY'
import imaplib,json,os,time
q=lambda s:'"'+s.replace('\\','\\\\').replace('"','\\"')+'"'
def count(u,p,f):
 with imaplib.IMAP4_SSL(os.environ['IMAP_HOST'],int(os.environ['IMAP_PORT']),timeout=30) as m:
  m.login(u,p); t,_=m.select(q(f),readonly=True)
  if t!='OK': return 0
  t,d=m.search(None,'HEADER','X-T4H-Routing-Test',q(os.environ['TOKEN'])); return len((d[0] or b'').split()) if t=='OK' else 0
s=a=0
for _ in range(12):
 s=count(os.environ['SOURCE_MAILBOX'],os.environ['SOURCE_MAILBOX_PASSWORD'],'Systems/GitHub/Failures'); a=count(os.environ['AGENT_MAILBOX'],os.environ['AGENT_MAILBOX_PASSWORD'],'INBOX')
 if s==1 and a==1: break
 time.sleep(5)
out={'source':s,'agent':a,'exactly_once':s==1 and a==1}; open(os.environ['OUT'],'w').write(json.dumps(out,indent=2)+'\n')
if not out['exactly_once']: raise SystemExit(6)
PY
ROUTING=true AGENT=true

STEP=downstream
jq -n --arg id "github-investigation-$TOKEN" --arg token "$TOKEN" --arg mailbox "$AGENT_MAILBOX" '{schema_version:"t4h.github-investigation-job.v2",job_id:$id,source_token:$token,source_mailbox:$mailbox,state:"QUEUED"}' > "$JOB_R"
jq -c . "$JOB_R" >> "$JOB_LEDGER"; JOB=true
REPO_ROOT="$ROOT" ISSUE_237_JOB_LEDGER="$JOB_LEDGER" bash "$ROOT/workers/issue-237-downstream-github-worker.sh" "$JOB_R" "$DOWNSTREAM_R"; DOWNSTREAM=true
GITHUB="$(jq -r '.real_gate.github_readback' "$DOWNSTREAM_R")" INVESTIGATION="$(jq -r '.real_gate.investigation' "$DOWNSTREAM_R")" REPAIR="$(jq -r '.real_gate.repair_or_rerun' "$DOWNSTREAM_R")"
STEP=done; [[ "$GITHUB" == true && "$INVESTIGATION" == true && "$REPAIR" == true ]] && STATE=REAL || STATE=PARTIAL
persist "apply completed; state derived from downstream evidence"
echo "state=$STATE receipt=$RECEIPT bundle_ledger=$BUNDLE_LEDGER job_ledger=$JOB_LEDGER"
