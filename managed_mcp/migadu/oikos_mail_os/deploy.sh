#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="dry-run"
RECEIPT_DIR="${RECEIPT_DIR:-$ROOT/receipts}"
LEDGER_FILE="${LEDGER_FILE:-$ROOT/../ledger/execution_ledger.jsonl}"
RUN_ID="oikos-mail-os-$(date -u +%Y%m%dT%H%M%SZ)-$$"
STARTED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
STATUS="PARTIAL"
FAILURE_STAGE=""
FAILURE_REASON=""
SCHEMA_APPLIED=false
TESTS_PASSED=false

usage(){ echo "Usage: $0 [--dry-run|--apply-schema]"; }
case "${1:---dry-run}" in
  --dry-run) MODE="dry-run" ;;
  --apply-schema) MODE="apply-schema" ;;
  -h|--help) usage; exit 0 ;;
  *) usage; exit 2 ;;
esac

mkdir -p "$RECEIPT_DIR"
LOG="$RECEIPT_DIR/$RUN_ID.log"
JSON_RECEIPT="$RECEIPT_DIR/$RUN_ID.json"
MD_RECEIPT="$RECEIPT_DIR/$RUN_ID.md"
exec > >(tee -a "$LOG") 2>&1

write_receipt(){
  local rc=$? ended hash
  ended="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  hash="$(shasum -a 256 "$ROOT/registry.json" | awk '{print $1}')"
  python3 - "$JSON_RECEIPT" "$RUN_ID" "$STARTED_AT" "$ended" "$STATUS" "$MODE" "$hash" "$SCHEMA_APPLIED" "$TESTS_PASSED" "$FAILURE_STAGE" "$FAILURE_REASON" <<'PY'
import json,sys
path,run_id,started,ended,status,mode,registry_hash,schema_applied,tests_passed,stage,reason=sys.argv[1:]
data={
 "schema_version":"1.0.0","run_id":run_id,"started_at":started,"ended_at":ended,
 "status":status,"mode":mode,"registry_hash":registry_hash,
 "schema_applied":schema_applied=="true","tests_passed":tests_passed=="true",
 "failure_stage":stage,"failure_reason":reason,
 "truth_boundary":"REAL requires live mailbox readback, event execution, receipt, ledger and telemetry."
}
open(path,"w").write(json.dumps(data,indent=2,sort_keys=True)+"\n")
PY
  cat > "$MD_RECEIPT" <<MD
# OIKOS Mail Operations Deployment Receipt

- Run: \`$RUN_ID\`
- Status: **$STATUS**
- Mode: \`$MODE\`
- Schema applied: \`$SCHEMA_APPLIED\`
- Tests passed: \`$TESTS_PASSED\`
- Failure stage: \`${FAILURE_STAGE:-none}\`
- Failure reason: \`${FAILURE_REASON:-none}\`

This receipt does not claim live mailbox deployment unless independent readback, event execution, ledger and telemetry are present.
MD
  if [[ -n "$LEDGER_FILE" ]]; then
    mkdir -p "$(dirname "$LEDGER_FILE")"
    python3 - "$JSON_RECEIPT" "$LEDGER_FILE" <<'PY'
import json,sys
r=json.load(open(sys.argv[1]))
r["entry_type"]="OIKOS_MAIL_OS_DEPLOYMENT"
with open(sys.argv[2],"a") as f: f.write(json.dumps(r,sort_keys=True)+"\n")
PY
  fi
  exit "$rc"
}
trap write_receipt EXIT

printf 'Run ID: %s\nMode: %s\n' "$RUN_ID" "$MODE"
command -v python3 >/dev/null || { STATUS=BLOCKED; FAILURE_STAGE=preflight; FAILURE_REASON='python3 missing'; exit 3; }

python3 "$ROOT/runtime.py" validate
python3 "$ROOT/test_runtime.py"
TESTS_PASSED=true

python3 "$ROOT/runtime.py" plan --profile profile-human --address human@example.test > "$RECEIPT_DIR/$RUN_ID-human-plan.json"
python3 "$ROOT/runtime.py" plan --profile profile-machine --address github@example.test > "$RECEIPT_DIR/$RUN_ID-machine-plan.json"
python3 "$ROOT/runtime.py" plan --profile profile-catchall --address catchall@example.test > "$RECEIPT_DIR/$RUN_ID-catchall-plan.json"

if [[ "$MODE" == "apply-schema" ]]; then
  command -v psql >/dev/null || { STATUS=BLOCKED; FAILURE_STAGE=schema; FAILURE_REASON='psql missing'; exit 4; }
  [[ -n "${DATABASE_URL:-}" ]] || { STATUS=BLOCKED; FAILURE_STAGE=schema; FAILURE_REASON='DATABASE_URL missing'; exit 4; }
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$ROOT/schema.sql"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -Atc "select count(*) from mail_registry_tables" > "$RECEIPT_DIR/$RUN_ID-schema-readback.txt"
  SCHEMA_APPLIED=true
fi

STATUS=PARTIAL
echo "Package validation complete. Live mailbox deployment remains a separate verified gate."
