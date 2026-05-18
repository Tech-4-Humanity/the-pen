#!/usr/bin/env zsh
set -euo pipefail

# push-hcc.sh — Bridge push script for TML-4PM/the-pen
# Stages all changes, commits, pushes to origin main, and writes a receipt to RECEIPTS/

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
RECEIPT_DIR="$REPO_DIR/RECEIPTS"
RECEIPT_FILE="$RECEIPT_DIR/push-hcc-${TIMESTAMP}.md"

echo "📍 Repo: $REPO_DIR"
echo "🕐 Timestamp: $TIMESTAMP"
echo ""

cd "$REPO_DIR"

echo "🔍 Git status..."
git status --short
echo ""

echo "📦 Staging all changes..."
git add -A

# Bail early if nothing to commit
if git diff --cached --quiet; then
  echo "⚠️  Nothing to commit. Working tree clean."
  exit 0
fi

echo "📝 Committing..."
COMMIT_MSG="hcc: bridge push ${TIMESTAMP}"
git commit -m "$COMMIT_MSG"

echo ""
echo "🚀 Pushing to origin main..."
git push origin main

COMMIT_SHA=$(git rev-parse HEAD)
PUSHED_BY=$(git config user.email 2>/dev/null || echo "unknown")

echo ""
echo "✅ Push complete."
echo "   SHA: $COMMIT_SHA"
echo ""

# Write receipt
echo "🧾 Writing receipt..."
mkdir -p "$RECEIPT_DIR"

cat > "$RECEIPT_FILE" <<RECEIPT
# Bridge Push Receipt

- **timestamp**: ${TIMESTAMP}
- **commit_sha**: ${COMMIT_SHA}
- **commit_message**: ${COMMIT_MSG}
- **pushed_by**: ${PUSHED_BY}
- **status**: SUCCESS
- **repo**: https://github.com/TML-4PM/the-pen
RECEIPT

git add "$RECEIPT_FILE"
git commit -m "receipt: push-hcc ${TIMESTAMP}"
git push origin main

RECEIPT_SHA=$(git rev-parse HEAD)

echo ""
echo "🧾 Receipt committed: RECEIPTS/push-hcc-${TIMESTAMP}.md"
echo "🔗 https://github.com/TML-4PM/the-pen/blob/main/RECEIPTS/push-hcc-${TIMESTAMP}.md"
echo "   Receipt SHA: $RECEIPT_SHA"
echo ""
echo "✅ Done."
