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

# The AWS CLI may emit one result per API page when --output text is combined
# with a JMESPath query. Fetch the complete paginated response as JSON and
# select exactly one newest matching key in Python instead.
find_latest_key() {
  local name="$1"
  local listing="$TMP_DIR/list-${name}.json"

  aws s3api list-objects-v2 \
    --bucket "$BUCKET" \
    --prefix "$SEARCH_PREFIX" \
    --output json > "$listing"

  python3 - "$listing" "$name" "${CANONICAL_PREFIX%/}/$name" <<'PY'
import json
import sys

path, filename, canonical_key = sys.argv[1:]
with open(path, encoding="utf-8") as handle:
    payload = json.load(handle)

matches = []
for item in payload.get("Contents", []):
    key = item.get("Key")
    modified = item.get("LastModified", "")
    if not key or key == canonical_key:
        continue
    if key.endswith(filename):
        matches.append((modified, key))

if matches:
    matches.sort(reverse=True)
    print(matches[0][1])
PY
}

validate_key() {
  local key="$1"
  [[ -n "$key" ]] || return 1
  [[ "$key" != "None" && "$key" != "null" ]] || return 1
  [[ "$key" != *$'\n'* && "$key" != *$'\r'* ]] || return 1
  [[ "$key" == "$SEARCH_PREFIX"/* ]] || return 1
}

manifest_entries=()
for name in "${FILES[@]}"; do
  key="$(find_latest_key "$name" | tr -d '\r')"
  if ! validate_key "$key"; then
    echo "Missing or invalid required object: $name" >&2
    printf 'Resolved key: %q\n' "$key" >&2
    exit 3
  fi

  echo "Resolved $name -> s3://$BUCKET/$key"
  dest_key="${CANONICAL_PREFIX%/}/$name"
  if [[ "$key" != "$dest_key" ]]; then
    aws s3 cp "s3://$BUCKET/$key" "s3://$BUCKET/$dest_key" \
      --only-show-errors \
      --metadata-directive COPY
  fi

  aws s3 cp "s3://$BUCKET/$dest_key" "$TMP_DIR/found/$name" --only-show-errors
  size="$(wc -c < "$TMP_DIR/found/$name" | tr -d ' ')"
  rows="$(python3 - "$TMP_DIR/found/$name" <<'PY'
import csv
import sys

# Preservation inventories can contain full HTML, JSON or embedded source in a
# single CSV field. Raise Python's conservative 128 KiB default to the largest
# value supported by this interpreter/platform without overflowing C long.
limit = sys.maxsize
while True:
    try:
        csv.field_size_limit(limit)
        break
    except OverflowError:
        limit //= 10

with open(sys.argv[1], newline='', encoding='utf-8-sig') as handle:
    count = sum(1 for _ in csv.reader(handle))
print(max(0, count - 1))
PY
)"
  sha="$(shasum -a 256 "$TMP_DIR/found/$name" | awk '{print $1}')"
  etag="$(aws s3api head-object --bucket "$BUCKET" --key "$dest_key" --query ETag --output text | tr -d '"')"
  manifest_entries+=("$name|$dest_key|$size|$rows|$sha|$etag")
  echo "Validated $name: rows=$rows bytes=$size sha256=$sha"
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
