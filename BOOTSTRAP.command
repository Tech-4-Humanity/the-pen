#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="${T4H_REPO_URL:-https://github.com/TML-4PM/the-pen.git}"
REPO_SLUG="TML-4PM/the-pen"
BRANCH="${T4H_BRANCH:-main}"
RUN_ID="${T4H_RUN_ID:-bootstrap-$(date -u +%Y%m%dT%H%M%SZ)}"
export T4H_RUN_ID="$RUN_ID"

log(){ printf '\n[%s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }
fail(){ printf '\nBLOCKED: %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || fail "git is required"
command -v node >/dev/null 2>&1 || fail "Node.js 18+ is required"
command -v npm >/dev/null 2>&1 || fail "npm is required"

find_repo(){
  local candidates=(
    "${T4H_REPO_DIR:-}"
    "$PWD"
    "$HOME/projects/TML-4PM/the-pen"
    "$HOME/TML-4PM/the-pen"
    "$HOME/projects/the-pen"
    "$HOME/the-pen"
  )
  local c remote
  for c in "${candidates[@]}"; do
    [[ -n "$c" && -d "$c/.git" ]] || continue
    remote="$(git -C "$c" remote get-url origin 2>/dev/null || true)"
    if [[ "$remote" == *"TML-4PM/the-pen"* || "$remote" == *"TML-4PM/the-pen.git"* ]]; then
      printf '%s\n' "$c"
      return 0
    fi
  done

  while IFS= read -r gitdir; do
    c="${gitdir%/.git}"
    remote="$(git -C "$c" remote get-url origin 2>/dev/null || true)"
    if [[ "$remote" == *"TML-4PM/the-pen"* || "$remote" == *"TML-4PM/the-pen.git"* ]]; then
      printf '%s\n' "$c"
      return 0
    fi
  done < <(find "$HOME" -maxdepth 5 -type d -name .git 2>/dev/null | head -200)
  return 1
}

REPO_DIR="$(find_repo || true)"
if [[ -z "$REPO_DIR" ]]; then
  BASE="${T4H_INSTALL_ROOT:-$HOME/projects/TML-4PM}"
  REPO_DIR="$BASE/the-pen"
  mkdir -p "$BASE"
  log "Repository not found; cloning $REPO_SLUG to $REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"
log "Repository: $REPO_DIR"

CURRENT="$(git branch --show-current 2>/dev/null || true)"
if [[ -n "$(git status --porcelain)" ]]; then
  fail "working tree contains uncommitted changes; refusing to overwrite them"
fi

git fetch --prune origin
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git checkout "$BRANCH"
else
  git checkout -B "$BRANCH" "origin/$BRANCH"
fi

git pull --ff-only origin "$BRANCH"

log "Installing locked dependencies"
npm ci

log "Stage 1/3: doctor"
npm run doctor

log "Stage 2/3: bringup"
npm run bringup

log "Stage 3/3: runtime:auto-advance"
npm run runtime:auto-advance

log "Bootstrap complete: $RUN_ID"
