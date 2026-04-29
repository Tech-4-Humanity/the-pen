#!/usr/bin/env bash
# fix-job.sh
# Patches a single job with missing fields and returns it to inbox for re-processing
# Usage: ./scripts/bridge/fix-job.sh <filename> <origin> <destination> <topic>
# Example: ./scripts/bridge/fix-job.sh direct-bridge-invoke-012.json the-pen bridge-runner sql-exec

set -euo pipefail

REPO="TML-4PM/the-pen"

if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <filename> <origin> <destination> <topic>"
  echo "Example: $0 direct-bridge-invoke-012.json the-pen bridge-runner sql-exec"
  exit 1
fi

FILE_NAME="$1"
ORIGIN="$2"
DESTINATION="$3"
TOPIC="$4"

# Find file in repair/, then inbox/
SOURCE_PATH=""
FILE_SHA=""
for dir in repair inbox; do
  RESP=$(gh api "repos/$REPO/contents/$dir/$FILE_NAME" 2>/dev/null || echo "")
  if [[ -n "$RESP" ]]; then
    FILE_SHA=$(echo "$RESP" | jq -r '.sha')
    if [[ "$FILE_SHA" != "null" && -n "$FILE_SHA" ]]; then
      SOURCE_PATH="$dir/$FILE_NAME"
      CONTENT=$(echo "$RESP" | jq -r '.content' | base64 --decode)
      break
    fi
  fi
done

if [[ -z "$SOURCE_PATH" ]]; then
  echo "ERROR: $FILE_NAME not found in repair/ or inbox/"
  exit 1
fi

echo "Found: $SOURCE_PATH"

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PATCHED=$(echo "$CONTENT" | jq \
  --arg origin "$ORIGIN" \
  --arg destination "$DESTINATION" \
  --arg topic "$TOPIC" \
  --arg ts "$TS" \
  'del(._repair) | .origin = $origin | .destination = $destination | .topic = $topic | .patched_at = $ts')

echo "Patched:"
echo "$PATCHED" | jq '{fn,action,idempotency_key,origin,destination,topic,patched_at}'

ENCODED=$(echo "$PATCHED" | base64)

# Check if file already exists in inbox (get its sha if so)
EXISTING_INBOX=$(gh api "repos/$REPO/contents/inbox/$FILE_NAME" 2>/dev/null || echo "")
if [[ -n "$EXISTING_INBOX" ]]; then
  INBOX_SHA=$(echo "$EXISTING_INBOX" | jq -r '.sha')
  gh api --method PUT "repos/$REPO/contents/inbox/$FILE_NAME" \
    --field message="fix-job: patch $FILE_NAME origin=$ORIGIN destination=$DESTINATION topic=$TOPIC" \
    --field content="$ENCODED" \
    --field sha="$INBOX_SHA" \
    --field branch="main" > /dev/null 2>&1
else
  gh api --method PUT "repos/$REPO/contents/inbox/$FILE_NAME" \
    --field message="fix-job: patch $FILE_NAME origin=$ORIGIN destination=$DESTINATION topic=$TOPIC" \
    --field content="$ENCODED" \
    --field branch="main" > /dev/null 2>&1
fi
echo "✔ Written to inbox/$FILE_NAME"

# Remove from repair/ if that's where it came from
if [[ "$SOURCE_PATH" == repair/* ]]; then
  gh api --method DELETE "repos/$REPO/contents/$SOURCE_PATH" \
    --field message="fix-job: remove $FILE_NAME from repair after patch" \
    --field sha="$FILE_SHA" \
    --field branch="main" > /dev/null 2>&1
  echo "✔ Removed from repair/$FILE_NAME"
fi

echo ""
echo "Ready. Run: ./scripts/bridge/validate-and-promote.sh"
