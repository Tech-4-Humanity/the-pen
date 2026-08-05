#!/usr/bin/env bash
set -Eeuo pipefail

# Non-destructive recovery of disposable caches after canonical ingest staging.
# Does not touch source folders, run manifests, receipts, S3 data, Git repos,
# Documents, Desktop, Downloads content, or user-created application data.

TARGET_FREE_GB="${TARGET_FREE_GB:-12}"
MODE="${1:---dry-run}"

case "$MODE" in
  --dry-run|--execute) ;;
  *) echo "Usage: $0 [--dry-run|--execute]" >&2; exit 2 ;;
esac

avail_kb() { df -k / | awk 'NR==2 {print $4}'; }
avail_gb() { awk -v kb="$(avail_kb)" 'BEGIN {printf "%.2f", kb/1024/1024}'; }

safe_remove() {
  local path="$1"
  [[ -e "$path" ]] || return 0
  local size
  size="$(du -sh "$path" 2>/dev/null | awk '{print $1}')"
  if [[ "$MODE" == "--execute" ]]; then
    rm -rf -- "$path"
    printf 'REMOVED\t%s\t%s\n' "$size" "$path"
  else
    printf 'WOULD_REMOVE\t%s\t%s\n' "$size" "$path"
  fi
}

echo "MODE=$MODE"
echo "FREE_BEFORE_GB=$(avail_gb)"
echo "TARGET_FREE_GB=$TARGET_FREE_GB"

# Package-manager caches and failed global-install residue.
safe_remove "$HOME/.npm/_cacache"
safe_remove "$HOME/.npm/_logs"
safe_remove "$HOME/Library/Caches/npm"
safe_remove "$HOME/Library/Caches/Homebrew"
safe_remove "$HOME/Library/Caches/pip"
safe_remove "$HOME/Library/Caches/node-gyp"

# Rebuildable browser/tool caches. Deliberately excludes browser profiles/data.
safe_remove "$HOME/Library/Caches/ms-playwright"
safe_remove "$HOME/Library/Caches/com.amazonaws.jsii"
safe_remove "$HOME/Library/Caches/com.anthropic.claudefordesktop.ShipIt"

# Failed/incomplete global Vercel install may leave npm temporary directories.
find "$HOME/.npm" -maxdepth 2 -type d -name '_npx' -print0 2>/dev/null |
while IFS= read -r -d '' path; do safe_remove "$path"; done

if [[ "$MODE" == "--execute" ]]; then
  npm cache verify >/dev/null 2>&1 || true
  brew cleanup --prune=all >/dev/null 2>&1 || true
fi

echo "FREE_AFTER_GB=$(avail_gb)"

python3 - "$(avail_kb)" "$TARGET_FREE_GB" <<'PY'
import json,sys
available_kb=int(sys.argv[1]); target=float(sys.argv[2])
available_gb=available_kb/1024/1024
print(json.dumps({
  "status":"REAL" if available_gb >= target else "PARTIAL",
  "available_gb":round(available_gb,2),
  "target_gb":target,
  "safe_for_next_wave":available_gb >= target
},indent=2))
PY
