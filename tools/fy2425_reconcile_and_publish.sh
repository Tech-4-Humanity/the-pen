#!/usr/bin/env bash
set -euo pipefail

OUTPUT_DIR="${1:?output directory required}"
BUCKET="${2:?S3 bucket required}"
PREFIX="${3:?S3 prefix required}"
REGION="${AWS_REGION:-ap-southeast-2}"
RECEIPT="$OUTPUT_DIR/fy2425_fresh_export_receipt.json"
MANIFEST="$OUTPUT_DIR/fy2425_privacy_safe_manifest.json"
READBACK_DIR="$(mktemp -d)"
trap 'rm -rf "$READBACK_DIR"' EXIT

[[ -f "$RECEIPT" ]] || { echo "missing receipt: $RECEIPT" >&2; exit 2; }

python3 - "$RECEIPT" <<'PY'
import json, pathlib, sys
receipt = json.loads(pathlib.Path(sys.argv[1]).read_text())
if receipt.get("ready_for_publish") is not True:
    raise SystemExit("completion gate failed: export receipt is not ready_for_publish")
validation = receipt.get("validation") or {}
failed = sorted(k for k, v in validation.items() if v is not True)
if failed:
    raise SystemExit(f"completion gate failed: {failed}")
PY

python3 - "$OUTPUT_DIR" "$MANIFEST" <<'PY'
import hashlib, json, pathlib, sys
out = pathlib.Path(sys.argv[1])
manifest_path = pathlib.Path(sys.argv[2])
required = [
'fy2425_fresh_account_summary.csv','fy2425_fresh_source_file_inventory.csv',
'fy2425_fresh_transactions.csv','fy2425_statement_period_coverage.csv',
'fy2425_balance_reconciliation.csv','fy2425_transfer_pairs.csv',
'fy2425_amex_repayment_pairs.csv','fy2425_refund_reversals.csv',
'fy2425_supplier_normalisation.csv','fy2425_cost_discovery_register.csv',
'fy2425_director_funded_candidates.csv','fy2425_excluded_movements.csv']
objects=[]
for name in required:
    p=out/name
    if not p.is_file(): raise SystemExit(f'missing required output: {name}')
    h=hashlib.sha256(p.read_bytes()).hexdigest()
    objects.append({'name':name,'sha256':h,'bytes':p.stat().st_size})
manifest={'schema':'t4h.issue267.privacy_safe_manifest.v1','objects':objects}
manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
PY

# Upload private evidence, including the privacy-safe locator manifest.
while IFS= read -r -d '' file; do
  name="$(basename "$file")"
  aws s3 cp "$file" "s3://$BUCKET/$PREFIX/$name" --region "$REGION" --only-show-errors
  aws s3api head-object --bucket "$BUCKET" --key "$PREFIX/$name" --region "$REGION" >/dev/null
  aws s3 cp "s3://$BUCKET/$PREFIX/$name" "$READBACK_DIR/$name" --region "$REGION" --only-show-errors
  local_hash="$(sha256sum "$file" | awk '{print $1}')"
  remote_hash="$(sha256sum "$READBACK_DIR/$name" | awk '{print $1}')"
  [[ "$local_hash" == "$remote_hash" ]] || { echo "readback hash mismatch: $name" >&2; exit 3; }
done < <(find "$OUTPUT_DIR" -maxdepth 1 -type f \( -name 'fy2425_*.csv' -o -name 'fy2425_privacy_safe_manifest.json' \) -print0 | sort -z)

python3 - "$RECEIPT" "$MANIFEST" "$BUCKET" "$PREFIX" <<'PY'
import json, pathlib, sys
receipt_path=pathlib.Path(sys.argv[1]); manifest_path=pathlib.Path(sys.argv[2])
bucket,prefix=sys.argv[3],sys.argv[4]
r=json.loads(receipt_path.read_text()); m=json.loads(manifest_path.read_text())
if r.get('ready_for_publish') is not True:
    raise SystemExit('completion gate failed before REAL promotion')
for obj in m['objects']:
    obj['s3_uri']=f"s3://{bucket}/{prefix}/{obj['name']}"
    obj['readback_verified']=True
r['s3_bucket']=bucket; r['s3_prefix']=prefix
r['readback_results']=m['objects']
r['classification']='REAL'
r['classification_reason']='Live export, SHA-256, S3 upload and independent readback all succeeded'
receipt_path.write_text(json.dumps(r,indent=2)+'\n')
# Rewrite manifest after the receipt changed, then upload/readback receipt and manifest once more.
manifest_path.write_text(json.dumps(m,indent=2)+'\n')
PY

for file in "$RECEIPT" "$MANIFEST"; do
  name="$(basename "$file")"
  aws s3 cp "$file" "s3://$BUCKET/$PREFIX/$name" --region "$REGION" --only-show-errors
  aws s3 cp "s3://$BUCKET/$PREFIX/$name" "$READBACK_DIR/final-$name" --region "$REGION" --only-show-errors
  cmp -s "$file" "$READBACK_DIR/final-$name" || { echo "final readback mismatch: $name" >&2; exit 4; }
done

python3 - "$RECEIPT" "$MANIFEST" <<'PY'
import hashlib, json, pathlib, sys
def digest(path):
    return hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()
print(json.dumps({
    "status": "REAL",
    "receipt_sha256": digest(sys.argv[1]),
    "manifest_sha256": digest(sys.argv[2]),
    "readback_verified": True,
}, indent=2))
PY
