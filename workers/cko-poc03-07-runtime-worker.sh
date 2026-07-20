#!/usr/bin/env bash
set -euo pipefail

PROJECT_REF="${SUPABASE_PROJECT_REF:-jjsycelagfmuquvxryfo}"
BUCKET="${CKO_EVIDENCE_BUCKET:-t4h-archive-140548542136}"
REGION="${AWS_REGION:-ap-southeast-2}"
SOURCE_CKO_ID="${SOURCE_CKO_ID:-cko:pdf:7b72f182832a49a6253aea05}"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
ROOT="${ROOT:-$(pwd)}"
RUN_DIR="${ROOT}/runtime/cko-poc03-07/${RUN_ID}"
RECEIPT_DIR="${ROOT}/receipts/runtime/cko-poc03-07/${RUN_ID}"
SQL_FILE="${ROOT}/system/knowledge-runtime/poc03_07_schema.sql"
mkdir -p "$RUN_DIR" "$RECEIPT_DIR"

STATUS="RUNNING"
CURRENT_STAGE="bootstrap"
ERROR=""

emit_receipt(){
  local exit_code="${1:-0}"
  python3 - "$RECEIPT_DIR/final-receipt.json" "$STATUS" "$RUN_ID" "$CURRENT_STAGE" "$ERROR" "$exit_code" "$PROJECT_REF" "$SOURCE_CKO_ID" "$BUCKET" "$REGION" <<'PY'
import json,sys,hashlib
from datetime import datetime,timezone
p,status,run_id,stage,error,exit_code,project,source,bucket,region=sys.argv[1:]
base={
  "schema_version":"t4h.cko.poc03-07.receipt.v1",
  "run_id":run_id,
  "status":status,
  "current_stage":stage,
  "error":error or None,
  "exit_code":int(exit_code),
  "project_ref":project,
  "source_cko_id":source,
  "evidence_bucket":bucket,
  "region":region,
  "completed_at":datetime.now(timezone.utc).isoformat(),
}
canonical=json.dumps(base,sort_keys=True,separators=(",",":")).encode()
base["receipt_sha256"]=hashlib.sha256(canonical).hexdigest()
open(p,"w").write(json.dumps(base,indent=2)+"\n")
print(json.dumps(base,indent=2))
PY
}

fail(){
  local code="$?"
  STATUS="BLOCKED"
  ERROR="stage=${CURRENT_STAGE}; command=${BASH_COMMAND}; exit=${code}"
  emit_receipt "$code"
  exit "$code"
}
trap fail ERR

command -v supabase >/dev/null || { STATUS="BLOCKED"; ERROR="supabase CLI missing"; emit_receipt 127; exit 127; }
command -v python3 >/dev/null || { STATUS="BLOCKED"; ERROR="python3 missing"; emit_receipt 127; exit 127; }
[[ -f "$SQL_FILE" ]] || { STATUS="BLOCKED"; ERROR="schema file missing: $SQL_FILE"; emit_receipt 2; exit 2; }

CURRENT_STAGE="supabase-link"
WORKDIR="${RUN_DIR}/supabase"
mkdir -p "$WORKDIR"
supabase link --project-ref "$PROJECT_REF" --workdir "$WORKDIR"

CURRENT_STAGE="schema-apply"
supabase db query --linked --workdir "$WORKDIR" --file "$SQL_FILE" --agent=no --output table | tee "$RUN_DIR/schema-apply.txt"

CURRENT_STAGE="source-readback"
cat > "$RUN_DIR/source-readback.sql" <<SQL
select cko_id, object_type, title, lifecycle_state, source_sha256, cko_sha256
from knowledge_runtime.canonical_knowledge_objects
where cko_id = '${SOURCE_CKO_ID}';
SQL
supabase db query --linked --workdir "$WORKDIR" --file "$RUN_DIR/source-readback.sql" --agent=no --output json > "$RUN_DIR/source-readback.json"
python3 - "$RUN_DIR/source-readback.json" <<'PY'
import json,sys
rows=json.load(open(sys.argv[1]))
if len(rows)!=1:
    raise SystemExit(f"expected one source CKO, got {len(rows)}")
if rows[0].get("cko_sha256") is None:
    raise SystemExit("source CKO missing cko_sha256")
print("SOURCE_CKO_READBACK=REAL")
PY

CURRENT_STAGE="profile-readback"
cat > "$RUN_DIR/profile-readback.sql" <<'SQL'
select profile_key, profile_version, output_media_type, active
from knowledge_runtime.translation_profiles
where active=true
order by profile_key;
SQL
supabase db query --linked --workdir "$WORKDIR" --file "$RUN_DIR/profile-readback.sql" --agent=no --output json > "$RUN_DIR/profile-readback.json"
python3 - "$RUN_DIR/profile-readback.json" <<'PY'
import json,sys
rows=json.load(open(sys.argv[1]))
expected={"exec-summary-v1","sales-catalog-v1","website-pricing-v1","compliance-safe-v1","partner-summary-v1","audit-summary-v1"}
actual={r["profile_key"] for r in rows}
if actual != expected:
    raise SystemExit(f"translation profile mismatch: expected={sorted(expected)} actual={sorted(actual)}")
print("TRANSLATION_PROFILES=6")
PY

CURRENT_STAGE="runtime-seed"
cat > "$RUN_DIR/runtime-seed.sql" <<SQL
insert into knowledge_runtime.ingestion_events(
  idempotency_key, source_system, event_type, payload, status, attempt_count, max_attempts
) values (
  'cko-poc03-07:${RUN_ID}',
  'pen-runtime',
  'cko_program_requested',
  jsonb_build_object(
    'run_id','${RUN_ID}',
    'source_cko_id','${SOURCE_CKO_ID}',
    'program',jsonb_build_array('POC-03','POC-04','POC-05','POC-06','POC-07'),
    'issue_number',243
  ),
  'QUEUED',0,3
)
on conflict (idempotency_key) do update
set payload=excluded.payload, updated_at=now()
returning event_id, idempotency_key, status;
SQL
supabase db query --linked --workdir "$WORKDIR" --file "$RUN_DIR/runtime-seed.sql" --agent=no --output json > "$RUN_DIR/runtime-seed.json"

CURRENT_STAGE="program-manifest"
python3 - "$RUN_DIR/program-manifest.json" "$RUN_ID" "$SOURCE_CKO_ID" <<'PY'
import json,sys,hashlib
p,run_id,source=sys.argv[1:]
manifest={
  "run_id":run_id,
  "source_cko_id":source,
  "stages":[
    {"poc":"POC-03","capability":"translation","state":"QUEUED"},
    {"poc":"POC-04","capability":"validation-policy","state":"QUEUED"},
    {"poc":"POC-05","capability":"relationship-graph","state":"QUEUED"},
    {"poc":"POC-06","capability":"search-memory","state":"QUEUED"},
    {"poc":"POC-07","capability":"event-agent-runtime","state":"QUEUED"},
  ],
  "classification":"PARTIAL",
  "reason":"runtime schema, profiles, rules and ingress event loaded; stage execution remains queued"
}
canonical=json.dumps(manifest,sort_keys=True,separators=(",",":")).encode()
manifest["manifest_sha256"]=hashlib.sha256(canonical).hexdigest()
open(p,"w").write(json.dumps(manifest,indent=2)+"\n")
print(json.dumps(manifest,indent=2))
PY

CURRENT_STAGE="s3-evidence"
if command -v aws >/dev/null && aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
  aws s3 cp "$RUN_DIR/program-manifest.json" "s3://${BUCKET}/knowledge-runtime/poc03-07/${RUN_ID}/program-manifest.json" --region "$REGION" --content-type application/json
  aws s3 cp "s3://${BUCKET}/knowledge-runtime/poc03-07/${RUN_ID}/program-manifest.json" "$RUN_DIR/program-manifest-readback.json" --region "$REGION" >/dev/null
  cmp "$RUN_DIR/program-manifest.json" "$RUN_DIR/program-manifest-readback.json"
  S3_STATE="REAL"
else
  S3_STATE="BLOCKED"
  echo "S3 evidence deferred: AWS CLI or credentials unavailable" | tee "$RUN_DIR/s3-blocked.txt"
fi

CURRENT_STAGE="complete"
STATUS="PARTIAL"
ERROR=""
emit_receipt 0

echo "CKO_POC03_07_BUNDLE_LOADED=true"
echo "RUN_ID=${RUN_ID}"
echo "SOURCE_CKO_ID=${SOURCE_CKO_ID}"
echo "TRANSLATION_PROFILES=6"
echo "PROGRAM_STAGES=5"
echo "S3_STATE=${S3_STATE}"
echo "STATUS=${STATUS}"
echo "NEXT=execute POC-03 translations and advance sequentially only after each acceptance gate"
