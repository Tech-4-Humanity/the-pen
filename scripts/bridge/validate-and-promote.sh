#!/usr/bin/env bash
# validate-and-promote.sh
# Reads inbox/*.json, validates required fields, promotes valid jobs to bridge_jobs/
# Quarantines invalid jobs to repair/ with a reason file
# Usage: ./scripts/bridge/validate-and-promote.sh [--dry-run]

set -euo pipefail

REPO="TML-4PM/the-pen"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

REQUIRED_FIELDS=("fn" "action" "idempotency_key" "origin" "destination" "topic")

PROMOTED=0
QUARANTINED=0
SKIPPED=0

echo "=== PEN validate-and-promote ==="
echo "Repo:     $REPO"
echo "Dry run:  $DRY_RUN"
echo "Started:  $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

INBOX_FILES=$(gh api "repos/$REPO/contents/inbox" --jq '[.[] | select(.type=="file" and (.name | endswith(".json"))) | {name: .name, path: .path, sha: .sha}]')
FILE_COUNT=$(echo "$INBOX_FILES" | jq length)
echo "Found $FILE_COUNT JSON files in inbox/"
echo ""

for row in $(echo "$INBOX_FILES" | jq -r '.[] | @base64'); do
  _jq() { echo "$row" | base64 --decode | jq -r "$1"; }

  FILE_NAME=$(_jq '.name')
  FILE_PATH=$(_jq '.path')
  FILE_SHA=$(_jq '.sha')

  CONTENT=$(gh api "repos/$REPO/contents/$FILE_PATH" --jq '.content' | base64 --decode 2>/dev/null || echo "")

  if [[ -z "$CONTENT" ]]; then
    echo "  SKIP (unreadable): $FILE_NAME"
    ((SKIPPED++)) || true
    continue
  fi

  VALID=true
  MISSING_LIST=""
  for field in "${REQUIRED_FIELDS[@]}"; do
    VALUE=$(echo "$CONTENT" | jq -r ".${field} // \"__MISSING__\"")
    if [[ "$VALUE" == "null" || "$VALUE" == "__MISSING__" ]]; then
      VALID=false
      MISSING_LIST="${MISSING_LIST}${field},"
    fi
  done
  MISSING_LIST="${MISSING_LIST%,}"

  if [[ "$VALID" == true ]]; then
    echo "  VALID → promote: $FILE_NAME"
    if [[ "$DRY_RUN" == false ]]; then
      ENCODED=$(echo "$CONTENT" | base64)
      gh api --method PUT "repos/$REPO/contents/bridge_jobs/$FILE_NAME" \
        --field message="promote: $FILE_NAME inbox→bridge_jobs" \
        --field content="$ENCODED" \
        --field branch="main" > /dev/null 2>&1 && echo "    ✔ written to bridge_jobs/$FILE_NAME"
      gh api --method DELETE "repos/$REPO/contents/$FILE_PATH" \
        --field message="promote: remove $FILE_NAME from inbox" \
        --field sha="$FILE_SHA" \
        --field branch="main" > /dev/null 2>&1 && echo "    ✔ removed from inbox"
    fi
    ((PROMOTED++)) || true
  else
    echo "  INVALID → repair: $FILE_NAME (missing: $MISSING_LIST)"
    if [[ "$DRY_RUN" == false ]]; then
      TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
      REASON=$(echo "$CONTENT" | jq --arg missing "$MISSING_LIST" --arg file "$FILE_NAME" --arg ts "$TS" '. + {_repair: {reason: "missing required fields", missing_fields: ($missing | split(",")), quarantined_at: $ts, source_file: $file}}')
      ENCODED=$(echo "$REASON" | base64)
      gh api --method PUT "repos/$REPO/contents/repair/$FILE_NAME" \
        --field message="quarantine: $FILE_NAME missing [$MISSING_LIST]" \
        --field content="$ENCODED" \
        --field branch="main" > /dev/null 2>&1 && echo "    ✔ written to repair/$FILE_NAME"
      gh api --method DELETE "repos/$REPO/contents/$FILE_PATH" \
        --field message="quarantine: remove $FILE_NAME from inbox" \
        --field sha="$FILE_SHA" \
        --field branch="main" > /dev/null 2>&1 && echo "    ✔ removed from inbox"
    fi
    ((QUARANTINED++)) || true
  fi
done

echo ""
echo "=== SUMMARY ==="
echo "Promoted:    $PROMOTED"
echo "Quarantined: $QUARANTINED"
echo "Skipped:     $SKIPPED"
echo "Total inbox: $FILE_COUNT"
echo ""

RECEIPT_NAME="validate-promote-$(date -u +%Y%m%d-%H%M%S).receipt.json"
RECEIPT=$(jq -n \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson promoted "$PROMOTED" \
  --argjson quarantined "$QUARANTINED" \
  --argjson skipped "$SKIPPED" \
  --argjson total "$FILE_COUNT" \
  --arg dry "$DRY_RUN" \
  '{run_at: $ts, dry_run: $dry, promoted: $promoted, quarantined: $quarantined, skipped: $skipped, total_inbox: $total}')

if [[ "$DRY_RUN" == false ]]; then
  ENCODED=$(echo "$RECEIPT" | base64)
  gh api --method PUT "repos/$REPO/contents/receipts/runtime/$RECEIPT_NAME" \
    --field message="receipt: validate-and-promote $RECEIPT_NAME" \
    --field content="$ENCODED" \
    --field branch="main" > /dev/null 2>&1 && echo "Receipt: receipts/runtime/$RECEIPT_NAME"
else
  echo "[dry-run] Receipt: receipts/runtime/$RECEIPT_NAME"
  echo "$RECEIPT"
fi
