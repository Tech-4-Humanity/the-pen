#!/usr/bin/env bash
set -Eeuo pipefail

AWS_REGION="${AWS_REGION:-ap-southeast-2}"
ARCHIVE_BUCKET="${ARCHIVE_BUCKET:-t4h-archive-140548542136}"
MANIFEST="${MANIFEST:-portfolio_runtime/migration/batches/three-site-static-20260730.json}"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_ROOT="${RUN_ROOT:-$HOME/Downloads/t4h-three-site-migration-$RUN_ID}"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "BLOCKED: missing $1" >&2; exit 1; }; }
for command_name in aws gh git jq curl shasum rsync npm; do need "$command_name"; done
[[ -f "$MANIFEST" ]] || { echo "BLOCKED: manifest not found: $MANIFEST" >&2; exit 1; }

mkdir -p "$RUN_ROOT/sites"
exec > >(tee "$RUN_ROOT/execution.log") 2>&1
aws sts get-caller-identity > "$RUN_ROOT/aws-caller-identity.json"
ACCOUNT_ID="$(jq -r '.Account' "$RUN_ROOT/aws-caller-identity.json")"
[[ "$ACCOUNT_ID" == "$(jq -r '.account_id' "$MANIFEST")" ]] || {
  echo "BLOCKED: AWS account mismatch" >&2
  exit 1
}

site_count="$(jq '.sites | length' "$MANIFEST")"
overall=true

for index in $(seq 0 $((site_count - 1))); do
  site="$(jq -c ".sites[$index]" "$MANIFEST")"
  site_id="$(jq -r '.site_id' <<< "$site")"
  domain="$(jq -r '.domain' <<< "$site")"
  repository="$(jq -r '.repository' <<< "$site")"
  branch="$(jq -r '.branch' <<< "$site")"
  build_type="$(jq -r '.build_type' <<< "$site")"
  output_directory="$(jq -r '.output_directory' <<< "$site")"
  bucket="$(jq -r '.target_bucket' <<< "$site")"
  site_root="$RUN_ROOT/sites/$site_id"
  source_dir="$site_root/source"
  publish_dir="$site_root/publish"
  receipt_dir="$site_root/receipt"

  mkdir -p "$publish_dir" "$receipt_dir"
  echo "=== SITE=$site_id DOMAIN=$domain REPOSITORY=$repository ==="

  gh repo clone "$repository" "$source_dir" -- --branch "$branch"
  git -C "$source_dir" rev-parse HEAD > "$receipt_dir/source-commit.txt"
  git -C "$source_dir" status --short > "$receipt_dir/source-status.txt"
  [[ ! -s "$receipt_dir/source-status.txt" ]] || {
    echo "BLOCKED: dirty source checkout for $site_id" >&2
    exit 1
  }

  curl -LfsS -o "$receipt_dir/live-before.html" -w '%{http_code},%{time_total}\n'     "https://$domain/" > "$receipt_dir/live-before-metrics.csv" || true

  hosted_zone_id="$(aws route53 list-hosted-zones-by-name --dns-name "$domain"     --query "HostedZones[?Name=='$domain.'].Id | [0]" --output text)"
  if [[ -n "$hosted_zone_id" && "$hosted_zone_id" != "None" ]]; then
    aws route53 list-resource-record-sets --hosted-zone-id "$hosted_zone_id"       > "$receipt_dir/dns-before.json"
  else
    echo '{"ResourceRecordSets":[]}' > "$receipt_dir/dns-before.json"
  fi

  aws acm list-certificates --region us-east-1     --certificate-statuses ISSUED PENDING_VALIDATION FAILED EXPIRED INACTIVE     > "$receipt_dir/acm-inventory.json"

  case "$build_type" in
    vite_spa)
      (
        cd "$source_dir"
        if [[ -f package-lock.json ]]; then npm ci; else npm install; fi
        npm run build
      ) > "$receipt_dir/build.log" 2>&1
      rsync -a "$source_dir/$output_directory/" "$publish_dir/"
      ;;
    static_html)
      rsync -a --exclude='.git' --exclude='.github' "$source_dir/" "$publish_dir/"
      ;;
    *)
      echo "BLOCKED: unsupported build type $build_type" >&2
      exit 1
      ;;
  esac

  [[ -f "$publish_dir/index.html" ]] || {
    echo "BLOCKED: $site_id build has no index.html" >&2
    exit 1
  }

  (
    cd "$publish_dir"
    find . -type f | LC_ALL=C sort | while IFS= read -r file; do
      shasum -a 256 "$file"
    done
  ) > "$receipt_dir/local-sha256.txt"
  local_count="$(wc -l < "$receipt_dir/local-sha256.txt" | tr -d ' ')"
  local_bytes="$(du -sk "$publish_dir" | awk '{print $1 * 1024}')"

  if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    aws s3api create-bucket --bucket "$bucket" --region "$AWS_REGION"       --create-bucket-configuration "LocationConstraint=$AWS_REGION"       > "$receipt_dir/bucket-create.json"
    aws s3api put-public-access-block --bucket "$bucket"       --public-access-block-configuration       BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
    aws s3api put-bucket-versioning --bucket "$bucket"       --versioning-configuration Status=Enabled
  fi

  aws s3 sync "$publish_dir/" "s3://$bucket/" --region "$AWS_REGION"     > "$receipt_dir/s3-sync.log"
  aws s3 cp "$receipt_dir/local-sha256.txt" "s3://$bucket/_migration/local-sha256.txt"     --region "$AWS_REGION" >/dev/null
  aws s3 cp "s3://$bucket/_migration/local-sha256.txt"     "$receipt_dir/local-sha256.readback.txt" --region "$AWS_REGION" >/dev/null

  local_sha="$(shasum -a 256 "$receipt_dir/local-sha256.txt" | awk '{print $1}')"
  readback_sha="$(shasum -a 256 "$receipt_dir/local-sha256.readback.txt" | awk '{print $1}')"
  [[ "$local_sha" == "$readback_sha" ]] || {
    echo "BLOCKED: S3 manifest readback mismatch for $site_id" >&2
    exit 1
  }

  aws s3api list-objects-v2 --bucket "$bucket" > "$receipt_dir/s3-objects.json"
  remote_count="$(jq '[.Contents[]? | select(.Key | startswith("_migration/") | not)] | length' "$receipt_dir/s3-objects.json")"

  classification="REAL_S3_PATH"
  [[ "$local_count" -eq "$remote_count" ]] || {
    classification="PARTIAL"
    overall=false
  }

  jq -n --arg schema "t4h.portfolio.site-s3-proof.v1"     --arg status "$classification" --arg classification "PARTIAL"     --arg run_id "$RUN_ID" --arg site_id "$site_id" --arg domain "$domain"     --arg repository "$repository" --arg commit "$(cat "$receipt_dir/source-commit.txt")"     --arg bucket "$bucket" --arg local_sha "$local_sha" --arg readback_sha "$readback_sha"     --argjson local_count "$local_count" --argjson remote_count "$remote_count"     --argjson local_bytes "$local_bytes"     '{schema:$schema,status:$status,classification:$classification,run_id:$run_id,site_id:$site_id,domain:$domain,repository:$repository,commit:$commit,bucket:$bucket,local_file_count:$local_count,remote_file_count:$remote_count,local_bytes:$local_bytes,manifest_sha256:$local_sha,s3_readback_sha256:$readback_sha,dns_changed:false,next_gate:"Route inventory confirmation, CloudFront and ACM pre-cutover"}'     > "$receipt_dir/final-receipt.json"
done

batch_status="REAL_THREE_SITE_S3_PATHS"
[[ "$overall" == true ]] || batch_status="PARTIAL"
jq -n --arg schema "t4h.portfolio.aws-migration.batch-receipt.v1"   --arg status "$batch_status" --arg classification "PARTIAL" --arg run_id "$RUN_ID"   --slurpfile manifest "$MANIFEST"   --arg run_root "$RUN_ROOT"   '{schema:$schema,status:$status,classification:$classification,run_id:$run_id,sites:$manifest[0].sites,run_root:$run_root,dns_changed:false,next_gate:"Per-site CloudFront/ACM pre-cutover validation before approved DNS changes"}'   > "$RUN_ROOT/final-receipt.json"

FINAL_SHA="$(shasum -a 256 "$RUN_ROOT/final-receipt.json" | awk '{print $1}')"
printf '{"timestamp":"%s","run_id":"%s","event":"THREE_SITE_S3_PATH_PROOF","status":"%s","evidence_sha256":"%s"}\n'   "$(date -u +%FT%TZ)" "$RUN_ID" "$batch_status" "$FINAL_SHA" > "$RUN_ROOT/ledger.jsonl"

S3_PREFIX="s3://$ARCHIVE_BUCKET/deployments/portfolio/three-site-static/$RUN_ID"
aws s3 sync "$RUN_ROOT" "$S3_PREFIX/" --region "$AWS_REGION" > "$RUN_ROOT/archive-upload.log"
aws s3 cp "$S3_PREFIX/final-receipt.json" "$RUN_ROOT/final-receipt.readback.json"   --region "$AWS_REGION" >/dev/null
READBACK_SHA="$(shasum -a 256 "$RUN_ROOT/final-receipt.readback.json" | awk '{print $1}')"
[[ "$FINAL_SHA" == "$READBACK_SHA" ]] || {
  echo "BLOCKED: batch receipt readback mismatch" >&2
  exit 1
}

cat "$RUN_ROOT/final-receipt.json"
echo "STATUS=$batch_status"
echo "DNS_CHANGED=false"
echo "S3_RECEIPT=$S3_PREFIX/final-receipt.json"
echo "S3_READBACK_SHA256=$READBACK_SHA"
echo "RUN_ROOT=$RUN_ROOT"
