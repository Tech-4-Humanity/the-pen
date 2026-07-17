#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

BUCKET="${BUCKET:-t4h-archive-140548542136}"
CANONICAL_PREFIX="${CANONICAL_PREFIX:-portfolio-preservation/runtime-input/current}"
SEARCH_PREFIX="${SEARCH_PREFIX:-portfolio-preservation}"
EXPECTED_ROOTS="${EXPECTED_ROOTS:-228}"

FILES=(
  page_inventory.csv
  content_blocks.csv
  asset_inventory.csv
  feature_workflow.csv
  rebuild_manifest.csv
)

RUN_ID="portfolio-input-bootstrap-$(date -u +%Y%m%dT%H%M%SZ)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

command -v aws >/dev/null || { echo "aws CLI required" >&2; exit 2; }
command -v python3 >/dev/null || { echo "python3 required" >&2; exit 2; }

aws sts get-caller-identity >/dev/null
aws s3api head-bucket --bucket "$BUCKET" >/dev/null

mkdir -p "$TMP_DIR/found"

find_latest_key() {
  local name="$1"
  aws s3api list-objects-v2 \
    --bucket "$BUCKET" \
    --prefix "$SEARCH_PREFIX" \
    --query "reverse(sort_by(Contents[?ends_with(Key, \`$name\`)], &LastModified))[0].Key" \
    --output text
}

manifest_entries=()
for name in "${FILES[@]}"; do
  key="$(find_latest_key "$name")"
  if [[ -z "$key" || "$key" == "None" ]]; then
    echo "Missing required object: $name" >&2
    exit 3
  fi

  dest_key="${CANONICAL_PREFIX%/}/$name"
  if [[ "$key" != "$dest_key" ]]; then
    aws s3 cp "s3://$BUCKET/$key" "s3://$BUCKET/$dest_key" \
      --only-show-errors \
      --metadata-directive COPY
  fi

  aws s3 cp "s3://$BUCKET/$dest_key" "$TMP_DIR/found/$name" --only-show-errors
  size="$(wc -c < "$TMP_DIR/found/$name" | tr -d ' ')"
  rows="$(python3 - "$TMP_DIR/found/$name" <<'PY'
import csv, sys
with open(sys.argv[1], newline='', encoding='utf-8-sig') as f:
    print(sum(1 for _ in csv.reader(f)) - 1)
PY
)"
  sha="$(shasum -a 256 "$TMP_DIR/found/$name" | awk '{print $1}')"
  etag="$(aws s3api head-object --bucket "$BUCKET" --key "$dest_key" --query ETag --output text | tr -d '"')"
  manifest_entries+=("$name|$dest_key|$size|$rows|$sha|$etag")
done

python3 - "$BUCKET" "$CANONICAL_PREFIX" "$EXPECTED_ROOTS" "$RUN_ID" "${manifest_entries[@]}" > "$TMP_DIR/_READY.json" <<'PY'
import json, sys
bucket, prefix, expected_roots, run_id, *entries = sys.argv[1:]
files=[]
for entry in entries:
    name,key,size,rows,sha,etag=entry.split('|')
    files.append({
        'name':name,'key':key,'size_bytes':int(size),'row_count':int(rows),
        'sha256':sha,'etag':etag
    })
print(json.dumps({
    'schema_version':'1.0.0',
    'run_id':run_id,
    'status':'READY',
    'bucket':bucket,
    'prefix':prefix,
    'expected_source_roots':int(expected_roots),
    'required_files':files
}, indent=2, sort_keys=True))
PY

aws s3 cp "$TMP_DIR/_READY.json" "s3://$BUCKET/${CANONICAL_PREFIX%/}/_READY.json" \
  --content-type application/json \
  --only-show-errors

printf '\nCanonical runtime input created:\n'
printf '  Bucket: %s\n' "$BUCKET"
printf '  Prefix: %s\n' "$CANONICAL_PREFIX"
printf '  Ready:  s3://%s/%s/_READY.json\n' "$BUCKET" "${CANONICAL_PREFIX%/}"

aws s3 ls "s3://$BUCKET/${CANONICAL_PREFIX%/}/"
