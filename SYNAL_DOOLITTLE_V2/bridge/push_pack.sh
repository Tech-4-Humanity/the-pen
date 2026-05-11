#!/usr/bin/env bash
# Synal Doolittle V2 — pack pusher
# Runs locally on Troy's box where bridge dual-auth keys are available.
# Pushes all 7 pack files to TML-4PM/the-pen/SYNAL_DOOLITTLE_V2/* via
# public.fn_github_push() RPC routed through troy-sql-executor on the bridge.
#
# Required env:
#   T4H_BRIDGE_URL      e.g. https://zdgnab3py0.execute-api.ap-southeast-2.amazonaws.com/prod/lambda/invoke
#   T4H_BRIDGE_API_KEY  x-api-key header (40c, wGqgmm5E...)
#   T4H_BRIDGE_BEARER   Authorization: Bearer (57c, bk_gfTUR...)
#   PACK_DIR            absolute path to SYNAL_DOOLITTLE_V2 root (default: cwd)

set -euo pipefail

PACK_DIR="${PACK_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
REPO="TML-4PM/the-pen"
BRANCH="main"
PREFIX="SYNAL_DOOLITTLE_V2"

: "${T4H_BRIDGE_URL:?missing}"
: "${T4H_BRIDGE_API_KEY:?missing}"
: "${T4H_BRIDGE_BEARER:?missing}"

push_file () {
  local rel="$1"
  local src="$PACK_DIR/$rel"
  local dest="$PREFIX/$rel"
  [[ -f "$src" ]] || { echo "MISS $src"; return 1; }

  # base64-encode content, then build a SQL string that calls fn_github_push
  local b64; b64="$(base64 -w0 "$src")"
  local msg="synal-doolittle-v2: $rel"
  local sql
  sql=$(printf "SELECT public.fn_github_push('%s','%s', convert_from(decode('%s','base64'),'UTF8'), '%s', '%s');" \
        "$REPO" "$dest" "$b64" "$msg" "$BRANCH")

  # troy-sql-executor expects a NESTED payload (per memory trap)
  local payload
  payload=$(jq -nc --arg s "$sql" '{name:"troy-sql-executor", payload:{sql:$s}}')

  echo ">>> push $dest"
  curl -sS --fail-with-body -X POST "$T4H_BRIDGE_URL" \
    -H "x-api-key: $T4H_BRIDGE_API_KEY" \
    -H "Authorization: Bearer $T4H_BRIDGE_BEARER" \
    -H 'content-type: application/json' \
    --data "$payload" \
    | tee >(jq -r '.commit_sha // .sha // .result // .' 2>/dev/null || cat)
  echo
}

# 7 files, ordered: docs first then app
push_file README.md
push_file doctrine/CROUX_REGISTRY.md
push_file doctrine/WAVE10_BINDING.md
push_file api/routes.md
push_file schema/01_tables.sql
push_file schema/02_seed.sql
push_file bridge/ledger_entry.json
push_file app/index.html

echo
echo "✓ pack delivered to https://github.com/$REPO/tree/$BRANCH/$PREFIX"
