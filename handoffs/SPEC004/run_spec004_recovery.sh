#!/usr/bin/env bash
set -euo pipefail

# SPEC-004 recovery runner
# Pulls patch asset, applies it, and prints proof signals.

WORKDIR="${WORKDIR:-/tmp/spec-004-recovery}"
REPO="TML-4PM/t4h-remote-mcp-server-clean"
BRANCH="fix/lazy-init-dns-cache"
PATCH_URL="https://raw.githubusercontent.com/TML-4PM/the-pen/main/handoffs/SPEC004/github_write_tools_inline_patch.js"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ ! -d repo ]; then
  git clone "https://github.com/${REPO}.git" repo
fi
cd repo

git fetch origin
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  git checkout "${BRANCH}"
else
  git checkout -b "${BRANCH}"
fi

curl -fsSL "$PATCH_URL" -o github_write_tools_inline_patch.js
node github_write_tools_inline_patch.js

echo "EXIT_CODE=$?"
