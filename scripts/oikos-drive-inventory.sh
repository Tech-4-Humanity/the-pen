#!/usr/bin/env bash
set -Eeuo pipefail

# OIKOS Journey — lossless, read-only Drive inventory.
# Usage:
#   bash scripts/oikos-drive-inventory.sh [rclone-remote] [folder-path] [output-dir]
# Example:
#   bash scripts/oikos-drive-inventory.sh gdrive "OIKOS Journey"
#
# This script never moves, renames, deletes, or uploads Drive objects.

REMOTE="${1:-gdrive}"
SOURCE_PATH="${2:-OIKOS Journey}"
RUN_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUTPUT_DIR="${3:-$PWD/runtime/oikos-drive-inventory/$RUN_STAMP}"
SOURCE_REF="${REMOTE}:${SOURCE_PATH}"
RAW_JSON="$OUTPUT_DIR/inventory-rclone.json"
MANIFEST_JSON="$OUTPUT_DIR/asset-manifest.json"
MANIFEST_CSV="$OUTPUT_DIR/asset-manifest.csv"
HASH_TSV="$OUTPUT_DIR/sha256.tsv"
DUPLICATES_JSON="$OUTPUT_DIR/exact-duplicates.json"
CHRONOLOGY_CSV="$OUTPUT_DIR/chronology.csv"
MOVEMENT_PLAN="$OUTPUT_DIR/movement-plan.csv"
RECEIPT="$OUTPUT_DIR/execution-receipt.json"

mkdir -p "$OUTPUT_DIR"

for command_name in rclone jq shasum base64; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "BLOCKED: missing command: $command_name" >&2
    exit 2
  }
done

if printf 'dGVzdA==' | base64 --decode >/dev/null 2>&1; then
  BASE64_DECODE_FLAG="--decode"
else
  BASE64_DECODE_FLAG="-D"
fi

rclone listremotes | sed 's/:$//' | grep -Fx "$REMOTE" >/dev/null || {
  echo "BLOCKED: rclone remote '$REMOTE' is not configured" >&2
  echo "Available remotes:" >&2
  rclone listremotes >&2
  exit 3
}

echo "SOURCE=$SOURCE_REF"
echo "OUTPUT=$OUTPUT_DIR"
echo "MODE=READ_ONLY"

# Complete recursive metadata inventory. No provider page is truncated by this script.
rclone lsjson "$SOURCE_REF"   --recursive   --files-only   --hash   --metadata   --no-mimetype=false > "$RAW_JSON"

jq --arg source "$SOURCE_REF" '
  map({
    path: .Path,
    name: .Name,
    size_bytes: .Size,
    mime_type: (.MimeType // ""),
    modified_time: (.ModTime // ""),
    drive_id: (.ID // ""),
    provider_hashes: (.Hashes // {}),
    source: $source
  })
  | sort_by(.modified_time, .path)
' "$RAW_JSON" > "$MANIFEST_JSON"

jq -r '
  ["path","name","size_bytes","mime_type","modified_time","drive_id","md5","sha1","source"],
  (.[] | [
    .path,
    .name,
    .size_bytes,
    .mime_type,
    .modified_time,
    .drive_id,
    (.provider_hashes.MD5 // ""),
    (.provider_hashes.SHA-1 // ""),
    .source
  ])
  | @csv
' "$MANIFEST_JSON" > "$MANIFEST_CSV"

: > "$HASH_TSV"
FILE_COUNT="$(jq 'length' "$MANIFEST_JSON")"
CURRENT=0

# Stream each object through SHA-256. Bytes are not retained locally.
while IFS= read -r encoded_path; do
  CURRENT=$((CURRENT + 1))
  file_path="$(printf '%s' "$encoded_path" | base64 "$BASE64_DECODE_FLAG")"
  printf '[%s/%s] SHA256 %s\n' "$CURRENT" "$FILE_COUNT" "$file_path" >&2
  digest="$(rclone cat "$SOURCE_REF/$file_path" | shasum -a 256 | awk '{print $1}')"
  printf '%s\t%s\n' "$digest" "$file_path" >> "$HASH_TSV"
done < <(jq -r '.[].path | @base64' "$MANIFEST_JSON")

jq -Rn '
  [inputs
    | split("\t")
    | {sha256: .[0], path: (.[1:] | join("\t"))}
  ]
  | group_by(.sha256)
  | map(select(length > 1) | {
      sha256: .[0].sha256,
      count: length,
      paths: map(.path)
    })
' "$HASH_TSV" > "$DUPLICATES_JSON"

jq -r '
  ["sequence","modified_time","path","name","size_bytes","mime_type","drive_id"],
  (to_entries[] | [
    (.key + 1),
    .value.modified_time,
    .value.path,
    .value.name,
    .value.size_bytes,
    .value.mime_type,
    .value.drive_id
  ])
  | @csv
' "$MANIFEST_JSON" > "$CHRONOLOGY_CSV"

# Proposal only. destination/action remain deliberately unapproved.
jq -r '
  ["source_path","drive_id","proposed_destination","proposed_name","proposed_action","approval_state","reason"],
  (.[] | [
    .path,
    .drive_id,
    "",
    "",
    "REVIEW",
    "UNAPPROVED",
    "Classification and chronology require editorial review before any Drive mutation"
  ])
  | @csv
' "$MANIFEST_JSON" > "$MOVEMENT_PLAN"

MANIFEST_SHA256="$(shasum -a 256 "$MANIFEST_JSON" | awk '{print $1}')"
CSV_SHA256="$(shasum -a 256 "$MANIFEST_CSV" | awk '{print $1}')"
HASHES_SHA256="$(shasum -a 256 "$HASH_TSV" | awk '{print $1}')"
DUP_GROUPS="$(jq 'length' "$DUPLICATES_JSON")"
DUP_FILES="$(jq '[.[].count] | add // 0' "$DUPLICATES_JSON")"
TOTAL_BYTES="$(jq '[.[].size_bytes] | add // 0' "$MANIFEST_JSON")"
FINISHED_AT="$(date -u +%FT%TZ)"

jq -n   --arg status "REAL_READ_ONLY_INVENTORY"   --arg classification "PARTIAL"   --arg source "$SOURCE_REF"   --arg started_at "$RUN_STAMP"   --arg finished_at "$FINISHED_AT"   --arg output_dir "$OUTPUT_DIR"   --arg manifest_sha256 "$MANIFEST_SHA256"   --arg csv_sha256 "$CSV_SHA256"   --arg hashes_sha256 "$HASHES_SHA256"   --argjson file_count "$FILE_COUNT"   --argjson total_bytes "$TOTAL_BYTES"   --argjson exact_duplicate_groups "$DUP_GROUPS"   --argjson exact_duplicate_files "$DUP_FILES"   '{
    status: $status,
    classification: $classification,
    operation: "read-only recursive inventory and byte-level SHA-256 analysis",
    source: $source,
    started_at: $started_at,
    finished_at: $finished_at,
    output_dir: $output_dir,
    counts: {
      files: $file_count,
      total_bytes: $total_bytes,
      exact_duplicate_groups: $exact_duplicate_groups,
      files_in_duplicate_groups: $exact_duplicate_files
    },
    evidence: {
      manifest_json_sha256: $manifest_sha256,
      manifest_csv_sha256: $csv_sha256,
      streamed_hashes_sha256: $hashes_sha256
    },
    mutations: [],
    real_gate: "PARTIAL until classification is approved, the exhibition is compiled, deployed, and read back with telemetry"
  }' | tee "$RECEIPT"

find "$OUTPUT_DIR" -type f ! -name SHA256SUMS -print0 |
  sort -z |
  xargs -0 shasum -a 256 > "$OUTPUT_DIR/SHA256SUMS"

echo
echo "STATUS=REAL_READ_ONLY_INVENTORY"
echo "CLASSIFICATION=PARTIAL"
echo "FILES=$FILE_COUNT"
echo "TOTAL_BYTES=$TOTAL_BYTES"
echo "EXACT_DUPLICATE_GROUPS=$DUP_GROUPS"
echo "FILES_IN_DUPLICATE_GROUPS=$DUP_FILES"
echo "RECEIPT=$RECEIPT"
echo "SHA256SUMS=$OUTPUT_DIR/SHA256SUMS"
