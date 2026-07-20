#!/usr/bin/env bash
set -Eeuo pipefail

# Bulk Vercel -> S3 static migration runner.
# Safety contract:
# - Vercel projects are never deleted or modified.
# - DNS is never changed automatically.
# - Only validated static output is uploaded.
# - Every project emits a receipt with REAL/PARTIAL/BLOCKED classification.

AWS_REGION="${AWS_REGION:-ap-southeast-2}"
GITHUB_ORG="${GITHUB_ORG:-TML-4PM}"
VERCEL_SCOPE="${VERCEL_SCOPE:-}"
MAX_PROJECTS="${MAX_PROJECTS:-0}"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
ROOT="${ROOT:-$HOME/t4h-vercel-to-s3/$RUN_ID}"
INVENTORY="$ROOT/inventory"
SOURCES="$ROOT/sources"
BUILDS="$ROOT/builds"
RECEIPTS="$ROOT/receipts"
LOGS="$ROOT/logs"
SUMMARY="$ROOT/summary.csv"

mkdir -p "$INVENTORY" "$SOURCES" "$BUILDS" "$RECEIPTS" "$LOGS"

need() { command -v "$1" >/dev/null 2>&1 || { echo "BLOCKED: missing command: $1" >&2; exit 1; }; }
for cmd in vercel aws gh jq python3 curl git; do need "$cmd"; done

aws sts get-caller-identity >"$INVENTORY/aws-caller-identity.json"
gh auth status >"$INVENTORY/gh-auth.txt" 2>&1
vercel whoami >"$INVENTORY/vercel-whoami.txt"

scope_args=()
[[ -n "$VERCEL_SCOPE" ]] && scope_args+=(--scope "$VERCEL_SCOPE")
vercel project ls --json "${scope_args[@]}" >"$INVENTORY/vercel-projects.json"

python3 - "$INVENTORY/vercel-projects.json" "$INVENTORY/projects.normalized.json" <<'PY'
import json, pathlib, sys
src=pathlib.Path(sys.argv[1]); out=pathlib.Path(sys.argv[2])
data=json.loads(src.read_text())
projects=data.get('projects', data) if isinstance(data, dict) else data
if not isinstance(projects, list):
    raise SystemExit('BLOCKED: unrecognised vercel project list JSON')
rows=[]
for p in projects:
    if not isinstance(p, dict):
        continue
    rows.append({
        'id': p.get('id') or p.get('projectId'),
        'name': p.get('name') or p.get('projectName'),
        'framework': p.get('framework'),
        'updatedAt': p.get('updatedAt') or p.get('updated_at'),
        'raw': p,
    })
rows=[r for r in rows if r['name']]
out.write_text(json.dumps(rows, indent=2)+'\n')
print(f'PROJECTS={len(rows)}')
PY

printf 'project,status,reason,bucket,source_repo,build_output,object_count,website_url,receipt\n' >"$SUMMARY"

mapfile_compat() {
  python3 - "$INVENTORY/projects.normalized.json" "$MAX_PROJECTS" <<'PY'
import json,sys
rows=json.load(open(sys.argv[1])); limit=int(sys.argv[2])
if limit>0: rows=rows[:limit]
for r in rows: print(r['name'])
PY
}

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9.-]+/-/g;s/^-+//;s/-+$//' | cut -c1-48
}

emit_receipt() {
  local project="$1" status="$2" reason="$3" bucket="$4" repo="$5" output="$6" count="$7" url="$8"
  local receipt="$RECEIPTS/$(slugify "$project").json"
  python3 - "$receipt" "$RUN_ID" "$project" "$status" "$reason" "$bucket" "$repo" "$output" "$count" "$url" <<'PY'
import json,pathlib,sys
out,run_id,project,status,reason,bucket,repo,build,count,url=sys.argv[1:]
payload={
 'schema':'t4h.vercel_to_s3.project_receipt.v1',
 'run_id':run_id,'project':project,'status':status,'reason':reason or None,
 'bucket':bucket or None,'source_repo':repo or None,'build_output':build or None,
 'remote_object_count':int(count or 0),'website_url':url or None,
 'vercel_deleted':False,'dns_changed':False
}
pathlib.Path(out).write_text(json.dumps(payload,indent=2)+'\n')
PY
  printf '"%s","%s","%s","%s","%s","%s","%s","%s","%s"\n' \
    "$project" "$status" "${reason//\"/\"\"}" "$bucket" "$repo" "$output" "$count" "$url" "$receipt" >>"$SUMMARY"
}

while IFS= read -r project; do
  [[ -n "$project" ]] || continue
  slug="$(slugify "$project")"
  log="$LOGS/$slug.log"
  repo="$GITHUB_ORG/$project"
  src="$SOURCES/$slug"
  build_out=""
  bucket=""
  count=0
  url=""

  {
    echo "=== $project ==="

    # Prefer exact repository name. A missing exact match is BLOCKED rather than guessed.
    if ! gh repo view "$repo" --json nameWithOwner,defaultBranchRef,url >"$INVENTORY/$slug.github.json" 2>/dev/null; then
      emit_receipt "$project" "BLOCKED" "SOURCE_REPOSITORY_NOT_RESOLVED" "" "$repo" "" 0 ""
      echo "BLOCKED: source repository not resolved: $repo"
      continue
    fi

    rm -rf "$src"
    if ! gh repo clone "$repo" "$src" -- --depth 1; then
      emit_receipt "$project" "BLOCKED" "SOURCE_CLONE_FAILED" "" "$repo" "" 0 ""
      continue
    fi

    # Explicit dynamic markers. These stay on Vercel and are not uploaded.
    if find "$src" -maxdepth 4 -type f \( \
      -path '*/api/*' -o -path '*/pages/api/*' -o -path '*/app/api/*' -o \
      -name 'middleware.ts' -o -name 'middleware.js' -o -name 'server.ts' -o -name 'server.js' \
    \) -print -quit | grep -q .; then
      emit_receipt "$project" "BLOCKED" "KNOWN_DYNAMIC_RUNTIME_MARKERS" "" "$repo" "" 0 ""
      echo "BLOCKED: dynamic runtime markers found"
      continue
    fi

    work="$src"
    root_dir="$(jq -r '.raw.rootDirectory // .raw.root_directory // empty' "$INVENTORY/projects.normalized.json" 2>/dev/null | head -1 || true)"
    [[ -n "$root_dir" && -d "$src/$root_dir" ]] && work="$src/$root_dir"

    if [[ -f "$work/package.json" ]]; then
      pushd "$work" >/dev/null
      if [[ -f pnpm-lock.yaml ]]; then
        command -v pnpm >/dev/null || npm install -g pnpm
        pnpm install --frozen-lockfile || pnpm install
        pnpm run build
      elif [[ -f yarn.lock ]]; then
        command -v yarn >/dev/null || npm install -g yarn
        yarn install --frozen-lockfile || yarn install
        yarn build
      else
        npm ci || npm install
        npm run build
      fi
      popd >/dev/null
    fi

    for candidate in dist build out public; do
      if [[ -f "$work/$candidate/index.html" ]]; then build_out="$work/$candidate"; break; fi
    done
    [[ -z "$build_out" && -f "$work/index.html" ]] && build_out="$work"

    if [[ -z "$build_out" ]]; then
      emit_receipt "$project" "BLOCKED" "NO_STATIC_INDEX_OUTPUT" "" "$repo" "" 0 ""
      echo "BLOCKED: no static index output"
      continue
    fi

    # Reject accidental uploads of source trees when root index.html is used.
    if [[ "$build_out" == "$work" && -f "$work/package.json" ]]; then
      emit_receipt "$project" "BLOCKED" "ROOT_INDEX_WITH_SOURCE_TREE_REQUIRES_REVIEW" "" "$repo" "$build_out" 0 ""
      continue
    fi

    # Local HTTP smoke test.
    port=$((18000 + RANDOM % 1000))
    python3 -m http.server "$port" --directory "$build_out" >"$LOGS/$slug-http.log" 2>&1 &
    server_pid=$!
    trap 'kill $server_pid 2>/dev/null || true' RETURN
    sleep 1
    if ! curl -fsS "http://127.0.0.1:$port/" >/dev/null; then
      kill "$server_pid" 2>/dev/null || true
      emit_receipt "$project" "BLOCKED" "LOCAL_HTTP_VALIDATION_FAILED" "" "$repo" "$build_out" 0 ""
      continue
    fi
    kill "$server_pid" 2>/dev/null || true
    trap - RETURN

    # Bucket names are globally unique; account suffix avoids collisions while staying traceable.
    account="$(jq -r '.Account' "$INVENTORY/aws-caller-identity.json")"
    bucket="t4h-${slug}-${account}"
    bucket="${bucket:0:63}"

    if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
      aws s3api create-bucket --bucket "$bucket" --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION" >/dev/null
    fi
    aws s3api put-bucket-versioning --bucket "$bucket" --versioning-configuration Status=Enabled
    aws s3api put-bucket-encryption --bucket "$bucket" --server-side-encryption-configuration \
      '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'

    # Temporary public website endpoint for verified recovery. DNS remains unchanged.
    aws s3api delete-public-access-block --bucket "$bucket" || true
    aws s3api put-bucket-policy --bucket "$bucket" --policy "$(cat <<JSON
{"Version":"2012-10-17","Statement":[{"Sid":"PublicReadStaticSite","Effect":"Allow","Principal":"*","Action":"s3:GetObject","Resource":"arn:aws:s3:::$bucket/*"}]}
JSON
)"
    aws s3api put-bucket-website --bucket "$bucket" --website-configuration \
      '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"index.html"}}'

    aws s3 sync "$build_out/" "s3://$bucket/" --delete --only-show-errors
    count="$(aws s3api list-objects-v2 --bucket "$bucket" --query 'KeyCount' --output text)"
    url="http://$bucket.s3-website-$AWS_REGION.amazonaws.com"

    if ! curl -fsS "$url/" >/dev/null; then
      emit_receipt "$project" "PARTIAL" "S3_UPLOAD_COMPLETE_HTTP_READBACK_FAILED" "$bucket" "$repo" "$build_out" "$count" "$url"
      continue
    fi

    emit_receipt "$project" "REAL" "" "$bucket" "$repo" "$build_out" "$count" "$url"
    echo "REAL: $url"
  } >"$log" 2>&1 || {
    emit_receipt "$project" "BLOCKED" "UNHANDLED_EXECUTION_FAILURE_SEE_LOG" "$bucket" "$repo" "$build_out" "$count" "$url"
  }
done < <(mapfile_compat)

python3 - "$RECEIPTS" "$ROOT/final-receipt.json" "$RUN_ID" "$SUMMARY" <<'PY'
import csv,json,pathlib,sys
receipts=pathlib.Path(sys.argv[1]); out=pathlib.Path(sys.argv[2]); run_id=sys.argv[3]; summary=sys.argv[4]
items=[]
for p in sorted(receipts.glob('*.json')):
    try: items.append(json.loads(p.read_text()))
    except Exception: pass
counts={s:sum(1 for x in items if x.get('status')==s) for s in ('REAL','PARTIAL','BLOCKED')}
payload={'schema':'t4h.vercel_to_s3.bulk_receipt.v1','run_id':run_id,'status':'REAL' if items and counts['BLOCKED']==0 and counts['PARTIAL']==0 else 'PARTIAL','projects':len(items),'counts':counts,'summary_csv':summary,'receipts_dir':str(receipts)}
out.write_text(json.dumps(payload,indent=2)+'\n')
print(json.dumps(payload,indent=2))
PY

echo "RUN_ROOT=$ROOT"
echo "SUMMARY=$SUMMARY"
echo "FINAL_RECEIPT=$ROOT/final-receipt.json"
