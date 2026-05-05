#!/usr/bin/env bash
# COAX session 2026-05-05 - GitHub push companion (terminal fallback)
# This was originally written when wrapper github_bulk_dispatch was assumed dead.
# In session 2026-05-05 the wrapper was confirmed live and pushed direct.
# Kept here as fallback runner for future sessions when wrapper is genuinely down.

set -euo pipefail

OWNER="TML-4PM"
REPO="the-pen"
SESSION="2026-05-05"
PATH_PREFIX="inbox/coax-sessions/${SESSION}"
DRIVE_FOLDER_ID="1wWR0YKKNXOQyn5QjhyT6FKykWxY8F2c3"

# Required: gh CLI authenticated. Note PATs expired 2026-05-03 - rotate first.
if ! gh auth status >/dev/null 2>&1; then
  echo "gh not authenticated. Run: gh auth login (rotate PAT first - expired 2026-05-03)"
  exit 1
fi

FILES=(
  "bundle.md"
  "status_table.md"
  "bridge_reality_correction.md"
  "memory_diff.md"
  "manifest.json"
  "push_to_github.sh"
)

for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing: $f"
    echo "Pull from Drive folder: https://drive.google.com/drive/folders/${DRIVE_FOLDER_ID}"
    exit 1
  fi
done

for f in "${FILES[@]}"; do
  GH_PATH="${PATH_PREFIX}/${f}"
  CONTENT_B64=$(base64 -w0 "$f")
  EXISTING_SHA=$(gh api "repos/${OWNER}/${REPO}/contents/${GH_PATH}" --jq '.sha' 2>/dev/null || echo "")

  if [[ -n "$EXISTING_SHA" ]]; then
    echo "Updating ${GH_PATH} (sha=${EXISTING_SHA:0:7})"
    gh api --method PUT "repos/${OWNER}/${REPO}/contents/${GH_PATH}" \
      -f message="coax(${SESSION}): update ${f}" \
      -f content="${CONTENT_B64}" \
      -f sha="${EXISTING_SHA}" \
      --jq '.commit.sha'
  else
    echo "Creating ${GH_PATH}"
    gh api --method PUT "repos/${OWNER}/${REPO}/contents/${GH_PATH}" \
      -f message="coax(${SESSION}): create ${f}" \
      -f content="${CONTENT_B64}" \
      --jq '.commit.sha'
  fi
done

echo ""
echo "DONE. Both-SHA invariant requires receipt back into ops.handover."
echo "Outbound SHAs printed above. Drive folder: https://drive.google.com/drive/folders/${DRIVE_FOLDER_ID}"
