#!/usr/bin/env bash
set -Eeuo pipefail

AWS_REGION="${AWS_REGION:-ap-southeast-2}"
VERCEL_SCOPE="${VERCEL_SCOPE:-}"
MAX_SITES="${MAX_SITES:-50}"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
ROOT="${ROOT:-$HOME/t4h-site-recovery/$RUN_ID}"
QUEUE="${QUEUE:-$(cd "$(dirname "$0")" && pwd)/recovery-50-sites.csv}"
PRESERVATION_ROOTS="${PRESERVATION_ROOTS:-$HOME/t4h-s3-migration:$HOME/Desktop:$HOME/Downloads:$HOME/Library/CloudStorage}"
SUMMARY="$ROOT/summary.csv"
RECEIPTS="$ROOT/receipts"
LOGS="$ROOT/logs"
SOURCES="$ROOT/sources"
BUILDS="$ROOT/builds"
MIRRORS="$ROOT/mirrors"

mkdir -p "$RECEIPTS" "$LOGS" "$SOURCES" "$BUILDS" "$MIRRORS"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "BLOCKED: missing command $1" >&2; exit 1; }; }
for c in aws gh git jq python3 curl; do need "$c"; done
command -v wget >/dev/null 2>&1 || { echo "Installing wget with Homebrew"; brew install wget; }
command -v vercel >/dev/null 2>&1 || npm install -g vercel

aws sts get-caller-identity >"$ROOT/aws-caller-identity.json"
gh auth status >"$ROOT/gh-auth.txt" 2>&1
vercel whoami >"$ROOT/vercel-whoami.txt" 2>&1 || true
ACCOUNT_ID="$(jq -r '.Account' "$ROOT/aws-caller-identity.json")"

printf 'priority,site,status,reason,source_mode,source_ref,bucket,object_count,url,receipt\n' >"$SUMMARY"

slugify(){ printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9.-]+/-/g;s/^-+//;s/-+$//' | cut -c1-42; }

emit(){
  local priority="$1" site="$2" status="$3" reason="$4" mode="$5" ref="$6" bucket="$7" count="$8" url="$9"
  local receipt="$RECEIPTS/$(slugify "$site").json"
  python3 - "$receipt" "$RUN_ID" "$priority" "$site" "$status" "$reason" "$mode" "$ref" "$bucket" "$count" "$url" <<'PY'
import json, pathlib, sys
p,run_id,priority,site,status,reason,mode,ref,bucket,count,url=sys.argv[1:]
payload={
 'schema':'t4h.site_recovery.receipt.v2','run_id':run_id,'priority':int(priority),
 'site':site,'status':status,'reason':reason or None,'source_mode':mode,'source_ref':ref,
 'bucket':bucket or None,'object_count':int(count or 0),'recovery_url':url or None,
 'dns_changed':False,'source_deleted':False
}
pathlib.Path(p).write_text(json.dumps(payload,indent=2)+'\n')
PY
  printf '"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s"\n' \
    "$priority" "$site" "$status" "${reason//\"/\"\"}" "$mode" "$ref" "$bucket" "$count" "$url" "$receipt" >>"$SUMMARY"
}

find_static_output(){
  local base="$1"
  for d in dist build out public .vercel/output/static; do
    [[ -f "$base/$d/index.html" ]] && { printf '%s\n' "$base/$d"; return 0; }
  done
  [[ -f "$base/index.html" ]] && { printf '%s\n' "$base"; return 0; }
  return 1
}

build_repo(){
  local repo="$1" site="$2" dest="$SOURCES/$(slugify "$site")"
  rm -rf "$dest"
  gh repo clone "$repo" "$dest" -- --depth 1 >/dev/null 2>&1 || return 1
  if [[ -f "$dest/package.json" ]]; then
    pushd "$dest" >/dev/null
    if [[ -f pnpm-lock.yaml ]]; then command -v pnpm >/dev/null || npm i -g pnpm; pnpm i --frozen-lockfile || pnpm i; pnpm run build
    elif [[ -f yarn.lock ]]; then command -v yarn >/dev/null || npm i -g yarn; yarn install --frozen-lockfile || yarn install; yarn build
    else npm ci || npm install; npm run build
    fi
    popd >/dev/null
  fi
  find_static_output "$dest"
}

build_vercel(){
  local project="$1" site="$2" dest="$SOURCES/$(slugify "$site")-vercel"
  rm -rf "$dest"; mkdir -p "$dest"; pushd "$dest" >/dev/null
  local scope_args=(); [[ -n "$VERCEL_SCOPE" ]] && scope_args+=(--scope "$VERCEL_SCOPE")
  vercel link --yes --project "$project" "${scope_args[@]}" >/dev/null 2>&1 || { popd >/dev/null; return 1; }
  vercel pull --yes --environment=production "${scope_args[@]}" >/dev/null 2>&1 || true
  vercel build --prod "${scope_args[@]}" >/dev/null 2>&1 || { popd >/dev/null; return 1; }
  popd >/dev/null
  find_static_output "$dest"
}

mirror_url(){
  local url="$1" site="$2" dest="$MIRRORS/$(slugify "$site")"
  rm -rf "$dest"; mkdir -p "$dest"
  wget --quiet --mirror --page-requisites --convert-links --adjust-extension --no-parent \
    --directory-prefix "$dest" "$url" || return 1
  local host; host="$(python3 - "$url" <<'PY'
from urllib.parse import urlparse
import sys
print(urlparse(sys.argv[1]).netloc)
PY
)"
  local root="$dest/$host"
  [[ -f "$root/index.html" ]] || return 1
  printf '%s\n' "$root"
}

find_preserved(){
  local site="$1" slug; slug="$(slugify "$site")"
  IFS=':' read -r -a roots <<<"$PRESERVATION_ROOTS"
  for r in "${roots[@]}"; do
    [[ -d "$r" ]] || continue
    local hit
    hit="$(find "$r" -type f -path "*${slug}*/index.html" -print -quit 2>/dev/null || true)"
    [[ -n "$hit" ]] && { dirname "$hit"; return 0; }
  done
  return 1
}

publish_s3(){
  local site="$1" out="$2"
  local slug bucket url count
  slug="$(slugify "$site")"
  bucket="t4h-recovery-${slug}-${ACCOUNT_ID}"
  bucket="${bucket:0:63}"
  if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    aws s3api create-bucket --bucket "$bucket" --region "$AWS_REGION" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION" >/dev/null
  fi
  aws s3api put-bucket-versioning --bucket "$bucket" --versioning-configuration Status=Enabled >/dev/null
  aws s3api put-bucket-encryption --bucket "$bucket" --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}' >/dev/null
  aws s3api delete-public-access-block --bucket "$bucket" >/dev/null 2>&1 || true
  aws s3api put-bucket-policy --bucket "$bucket" --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadRecovery\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::${bucket}/*\"}]}" >/dev/null
  aws s3api put-bucket-website --bucket "$bucket" --website-configuration \
    '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"index.html"}}' >/dev/null
  aws s3 sync "$out/" "s3://$bucket/" --delete --only-show-errors
  count="$(aws s3api list-objects-v2 --bucket "$bucket" --query KeyCount --output text)"
  url="http://${bucket}.s3-website-${AWS_REGION}.amazonaws.com"
  curl -fsS "$url/" >/dev/null
  printf '%s|%s|%s\n' "$bucket" "$count" "$url"
}

processed=0
while IFS=, read -r priority site mode ref public_url action; do
  [[ "$priority" == "priority" ]] && continue
  [[ "$action" == "RECOVER_NOW" ]] || continue
  (( processed >= MAX_SITES )) && break
  processed=$((processed+1))
  log="$LOGS/$(slugify "$site").log"
  {
    echo "=== $priority $site ==="
    out=""; reason=""
    case "$mode" in
      github)
        out="$(build_repo "$ref" "$site" || true)"
        [[ -n "$out" ]] || reason="GITHUB_BUILD_FAILED"
        ;;
      vercel-project)
        out="$(build_vercel "$ref" "$site" || true)"
        [[ -n "$out" ]] || reason="VERCEL_BUILD_FAILED"
        ;;
      url)
        out="$(mirror_url "$ref" "$site" || true)"
        [[ -n "$out" ]] || reason="URL_MIRROR_FAILED"
        ;;
    esac

    if [[ -z "$out" && -n "$public_url" ]]; then
      out="$(mirror_url "$public_url" "$site" || true)"
      [[ -n "$out" ]] && reason="FALLBACK_PUBLIC_URL_MIRROR"
    fi
    if [[ -z "$out" ]]; then
      out="$(find_preserved "$site" || true)"
      [[ -n "$out" ]] && reason="FALLBACK_LOCAL_PRESERVATION"
    fi
    if [[ -z "$out" || ! -f "$out/index.html" ]]; then
      emit "$priority" "$site" "BLOCKED" "${reason:-NO_STATIC_SOURCE}" "$mode" "$ref" "" 0 ""
      echo "BLOCKED $site ${reason:-NO_STATIC_SOURCE}"
      continue
    fi

    port=$((18000 + RANDOM % 1000))
    python3 -m http.server "$port" --directory "$out" >"$LOGS/$(slugify "$site")-http.log" 2>&1 & pid=$!
    sleep 1
    curl -fsS "http://127.0.0.1:$port/" >/dev/null || { kill "$pid" 2>/dev/null || true; emit "$priority" "$site" "BLOCKED" "LOCAL_HTTP_FAILED" "$mode" "$ref" "" 0 ""; continue; }
    kill "$pid" 2>/dev/null || true

    IFS='|' read -r bucket count url <<<"$(publish_s3 "$site" "$out")"
    emit "$priority" "$site" "REAL" "$reason" "$mode" "$ref" "$bucket" "$count" "$url"
    echo "REAL $site $url"
  } >"$log" 2>&1 || {
    emit "$priority" "$site" "BLOCKED" "UNHANDLED_FAILURE_SEE_LOG" "$mode" "$ref" "" 0 ""
  }
done <"$QUEUE"

python3 - "$RECEIPTS" "$ROOT/final-receipt.json" "$RUN_ID" "$SUMMARY" <<'PY'
import json,pathlib,sys
items=[]
for p in pathlib.Path(sys.argv[1]).glob('*.json'):
    try: items.append(json.loads(p.read_text()))
    except: pass
counts={s:sum(x.get('status')==s for x in items) for s in ('REAL','PARTIAL','BLOCKED')}
out={'schema':'t4h.site_recovery.batch_receipt.v2','run_id':sys.argv[3],
     'status':'REAL' if items and counts['BLOCKED']==0 else 'PARTIAL',
     'sites':len(items),'counts':counts,'summary_csv':sys.argv[4]}
pathlib.Path(sys.argv[2]).write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
PY

echo "RUN_ROOT=$ROOT"
echo "SUMMARY=$SUMMARY"
echo "FINAL_RECEIPT=$ROOT/final-receipt.json"
