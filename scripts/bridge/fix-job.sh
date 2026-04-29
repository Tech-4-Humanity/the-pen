#!/usr/bin/env bash
# fix-job.sh
# Patches a single job in repair/ with missing fields so it can be re-queued to inbox
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

# Try repair/ first, then inbox/
SOURCE_PATH=""
for dir in repair inbox; do
  EXISTS=$(gh api "repos/$REPO/contents/$dir/$FILE_NAME" --jq '.sha' 2>/dev/null || echo "")
  if [[ -n "$EXISTS" ]]; then
    SOURCE_PATH="$dir/$FILE_NAME"
    FILE_SHA="$EXISTS"
    break
  fi
done

if [[ -z "$SOURCE_PATH" ]]; then
  echo "ERROR: $FILE_NAME not found in repair/ or inbox/"
  exit 1
fi

echo "Found: $SOURCE_PATH"

# Fetch content
CONTENT=$(gh api "repos/$REPO/contents/$SOURCE_PATH" --jq '.content' | base64 --decode)

# Patch fields — strip _repair metadata if present, inject required fields
PATCHED=$(echo "$CONTENT" | jq \
  --arg origin "$ORIGIN" \
  --arg destination "$DESTINATION" \
  --arg topic "$TOPIC" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  'del(._repair) | .origin = $origin | .destination = $destination | .topic = $topic | .patched_at = $ts'
)

echo "Patched job:"
echo "$PATCHED" | jq '{fn,action,idempotency_key,origin,destination,topic,patched_at}'

# Write back to inbox/ for re-processing
ENCODED=$(echo "$PATCHED" | base64)
gh api --method PUT "repos/$REPO/contents/inbox/$FILE_NAME" \
  --field message="fix-job: patch $FILE_NAME → origin=$ORIGIN destination=$DESTINATION topic=$TOPIC" \
  --field content="$ENCODED" \
  --field branch="main" > /dev/null 2>&1

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
echo "Job ready. Run validate-and-promote.sh to send it to bridge_jobs."
