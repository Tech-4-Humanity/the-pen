#!/usr/bin/env bash
set -Eeuo pipefail

AWS_REGION="${AWS_REGION:-ap-southeast-2}"
ARCHIVE_BUCKET="${ARCHIVE_BUCKET:-t4h-archive-140548542136}"
MANIFEST="${MANIFEST:-portfolio_runtime/migration/batches/three-site-static-20260730.json}"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
RUN_ROOT="${RUN_ROOT:-$HOME/Downloads/t4h-three-site-cloudfront-$RUN_ID}"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "BLOCKED: missing $1" >&2; exit 1; }; }
for command_name in aws jq curl shasum; do need "$command_name"; done
[[ -f "$MANIFEST" ]] || { echo "BLOCKED: manifest missing" >&2; exit 1; }

mkdir -p "$RUN_ROOT/sites"
exec > >(tee "$RUN_ROOT/execution.log") 2>&1
CURRENT_SITE=""
CURRENT_BUCKET=""
CURRENT_DIST=""
CURRENT_CREATED=false
POLICY_MUTATED=false
PREVIOUS_POLICY_PRESENT=false
FINAL_WRITTEN=false

wait_distribution(){
  local distribution_id="$1"
  local receipt_dir="$2"
  for attempt in $(seq 1 90); do
    aws cloudfront get-distribution --id "$distribution_id" > "$receipt_dir/distribution-readback.json"
    local state
    state="$(jq -r '.Distribution.Status' "$receipt_dir/distribution-readback.json")"
    echo "SITE=$CURRENT_SITE CLOUDFRONT_STATUS=$state ATTEMPT=$attempt"
    [[ "$state" == "Deployed" ]] && return 0
    [[ "$attempt" -lt 90 ]] || return 1
    sleep 20
  done
}

recover_current(){
  local receipt_dir="$RUN_ROOT/sites/$CURRENT_SITE"
  set +e
  if [[ "$POLICY_MUTATED" == true ]]; then
    if [[ "$PREVIOUS_POLICY_PRESENT" == true ]]; then
      aws s3api put-bucket-policy --bucket "$CURRENT_BUCKET"         --policy "file://$receipt_dir/previous-bucket-policy-document.json"
    else
      aws s3api delete-bucket-policy --bucket "$CURRENT_BUCKET"
    fi
  fi
  if [[ "$CURRENT_CREATED" == true && -n "$CURRENT_DIST" ]]; then
    aws cloudfront get-distribution-config --id "$CURRENT_DIST" > "$receipt_dir/recovery-current.json"
    local etag
    etag="$(jq -r '.ETag' "$receipt_dir/recovery-current.json")"
    jq '.DistributionConfig | .Enabled=false' "$receipt_dir/recovery-current.json" > "$receipt_dir/recovery-disable.json"
    aws cloudfront update-distribution --id "$CURRENT_DIST" --if-match "$etag"       --distribution-config "file://$receipt_dir/recovery-disable.json" > "$receipt_dir/recovery-operation.json"
  fi
  jq -n --arg site "$CURRENT_SITE" --arg distribution_id "$CURRENT_DIST"     --arg action "RESTORE_BUCKET_POLICY_AND_DISABLE_NEW_DISTRIBUTION_REQUESTED_WHEN_APPLICABLE"     '{site_id:$site,distribution_id:$distribution_id,action:$action}' > "$receipt_dir/recovery.json"
}

on_error(){
  local exit_code="$?"
  set +e
  [[ -n "$CURRENT_SITE" ]] && recover_current
  if [[ "$FINAL_WRITTEN" == false ]]; then
    jq -n --arg schema "t4h.portfolio.three-site-cloudfront.v1"       --arg status "BLOCKED" --arg classification "PARTIAL" --arg run_id "$RUN_ID"       --arg site "$CURRENT_SITE" --argjson exit_code "$exit_code"       '{schema:$schema,status:$status,classification:$classification,run_id:$run_id,failed_site:$site,exit_code:$exit_code,recovery:"See per-site recovery.json"}'       > "$RUN_ROOT/final-receipt.json"
  fi
  echo "STATUS=BLOCKED"
  echo "RECEIPT=$RUN_ROOT/final-receipt.json"
  exit "$exit_code"
}
trap on_error ERR

aws sts get-caller-identity > "$RUN_ROOT/aws-caller-identity.json"
ACCOUNT_ID="$(jq -r '.Account' "$RUN_ROOT/aws-caller-identity.json")"
CACHE_POLICY_ID="$(aws cloudfront list-cache-policies --type managed   --query "CachePolicyList.Items[?CachePolicy.CachePolicyConfig.Name=='Managed-CachingOptimized'].CachePolicy.Id | [0]"   --output text)"
[[ -n "$CACHE_POLICY_ID" && "$CACHE_POLICY_ID" != "None" ]] || {
  echo "BLOCKED: CloudFront managed cache policy unavailable" >&2
  exit 1
}

site_count="$(jq '.sites | length' "$MANIFEST")"
distribution_receipts=()

for index in $(seq 0 $((site_count - 1))); do
  site="$(jq -c ".sites[$index]" "$MANIFEST")"
  CURRENT_SITE="$(jq -r '.site_id' <<< "$site")"
  domain="$(jq -r '.domain' <<< "$site")"
  CURRENT_BUCKET="$(jq -r '.target_bucket' <<< "$site")"
  receipt_dir="$RUN_ROOT/sites/$CURRENT_SITE"
  mkdir -p "$receipt_dir"
  CURRENT_DIST=""
  CURRENT_CREATED=false
  POLICY_MUTATED=false
  PREVIOUS_POLICY_PRESENT=false

  echo "=== CLOUDFRONT SITE=$CURRENT_SITE BUCKET=$CURRENT_BUCKET ==="
  aws s3api head-bucket --bucket "$CURRENT_BUCKET"
  aws s3api get-bucket-versioning --bucket "$CURRENT_BUCKET" > "$receipt_dir/bucket-versioning.json"
  aws s3api get-public-access-block --bucket "$CURRENT_BUCKET" > "$receipt_dir/public-access-block.json"
  aws s3api list-objects-v2 --bucket "$CURRENT_BUCKET" > "$receipt_dir/s3-objects.json"
  [[ "$(jq -r '[.Contents[]?.Key] | index("index.html") != null' "$receipt_dir/s3-objects.json")" == true ]] || {
    echo "BLOCKED: index.html missing from $CURRENT_BUCKET" >&2
    exit 1
  }

  if aws s3api get-bucket-policy --bucket "$CURRENT_BUCKET" > "$receipt_dir/previous-bucket-policy.json" 2>/dev/null; then
    PREVIOUS_POLICY_PRESENT=true
    jq -r '.Policy' "$receipt_dir/previous-bucket-policy.json" | jq . > "$receipt_dir/previous-bucket-policy-document.json"
  fi

  oac_name="t4h-$CURRENT_SITE-oac"
  OAC_ID="$(aws cloudfront list-origin-access-controls     --query "OriginAccessControlList.Items[?Name=='$oac_name'].Id | [0]" --output text)"
  if [[ -z "$OAC_ID" || "$OAC_ID" == "None" ]]; then
    jq -n --arg name "$oac_name"       '{Name:$name,Description:"T4H private S3 origin",SigningProtocol:"sigv4",SigningBehavior:"always",OriginAccessControlOriginType:"s3"}'       > "$receipt_dir/oac-config.json"
    aws cloudfront create-origin-access-control       --origin-access-control-config "file://$receipt_dir/oac-config.json" > "$receipt_dir/oac-create.json"
    OAC_ID="$(jq -r '.OriginAccessControl.Id' "$receipt_dir/oac-create.json")"
  fi

  comment="t4h-three-site:$CURRENT_SITE"
  CURRENT_DIST="$(aws cloudfront list-distributions     --query "DistributionList.Items[?Comment=='$comment'].Id | [0]" --output text)"
  if [[ -z "$CURRENT_DIST" || "$CURRENT_DIST" == "None" ]]; then
    origin_domain="$CURRENT_BUCKET.s3.$AWS_REGION.amazonaws.com"
    jq -n --arg caller "$CURRENT_SITE-$RUN_ID" --arg comment "$comment"       --arg origin "$origin_domain" --arg oac "$OAC_ID" --arg cache "$CACHE_POLICY_ID"       '{
        CallerReference:$caller,Comment:$comment,Enabled:true,IsIPV6Enabled:true,
        DefaultRootObject:"index.html",PriceClass:"PriceClass_100",HttpVersion:"http2and3",
        Origins:{Quantity:1,Items:[{
          Id:"private-s3",DomainName:$origin,OriginPath:"",
          CustomHeaders:{Quantity:0},S3OriginConfig:{OriginAccessIdentity:""},
          OriginAccessControlId:$oac,ConnectionAttempts:3,ConnectionTimeout:10,
          OriginShield:{Enabled:false}
        }]},
        DefaultCacheBehavior:{
          TargetOriginId:"private-s3",ViewerProtocolPolicy:"redirect-to-https",
          AllowedMethods:{Quantity:2,Items:["GET","HEAD"],CachedMethods:{Quantity:2,Items:["GET","HEAD"]}},
          SmoothStreaming:false,Compress:true,
          LambdaFunctionAssociations:{Quantity:0},FunctionAssociations:{Quantity:0},
          FieldLevelEncryptionId:"",CachePolicyId:$cache,
          TrustedSigners:{Enabled:false,Quantity:0},TrustedKeyGroups:{Enabled:false,Quantity:0}
        },
        CacheBehaviors:{Quantity:0},
        CustomErrorResponses:{Quantity:2,Items:[
          {ErrorCode:403,ResponsePagePath:"/index.html",ResponseCode:"200",ErrorCachingMinTTL:0},
          {ErrorCode:404,ResponsePagePath:"/index.html",ResponseCode:"200",ErrorCachingMinTTL:0}
        ]},
        Logging:{Enabled:false,IncludeCookies:false,Bucket:"",Prefix:""},
        ViewerCertificate:{CloudFrontDefaultCertificate:true,MinimumProtocolVersion:"TLSv1",CertificateSource:"cloudfront"},
        Restrictions:{GeoRestriction:{RestrictionType:"none",Quantity:0}},WebACLId:""
      }' > "$receipt_dir/distribution-config.json"
    aws cloudfront create-distribution       --distribution-config "file://$receipt_dir/distribution-config.json" > "$receipt_dir/distribution-create.json"
    CURRENT_DIST="$(jq -r '.Distribution.Id' "$receipt_dir/distribution-create.json")"
    CURRENT_CREATED=true
  fi

  aws cloudfront get-distribution --id "$CURRENT_DIST" > "$receipt_dir/distribution-initial.json"
  distribution_arn="$(jq -r '.Distribution.ARN' "$receipt_dir/distribution-initial.json")"
  cf_domain="$(jq -r '.Distribution.DomainName' "$receipt_dir/distribution-initial.json")"

  jq -n --arg bucket "$CURRENT_BUCKET" --arg distribution_arn "$distribution_arn"     '{
      Version:"2012-10-17",
      Statement:[{
        Sid:"AllowCloudFrontServicePrincipalReadOnly",
        Effect:"Allow",
        Principal:{Service:"cloudfront.amazonaws.com"},
        Action:"s3:GetObject",
        Resource:("arn:aws:s3:::"+$bucket+"/*"),
        Condition:{StringEquals:{"AWS:SourceArn":$distribution_arn}}
      }]
    }' > "$receipt_dir/bucket-policy.json"
  aws s3api put-bucket-policy --bucket "$CURRENT_BUCKET"     --policy "file://$receipt_dir/bucket-policy.json"
  POLICY_MUTATED=true

  wait_distribution "$CURRENT_DIST" "$receipt_dir" || {
    echo "BLOCKED: CloudFront deployment timeout for $CURRENT_SITE" >&2
    exit 1
  }

  printf 'path,http_status,duration_seconds\n' > "$receipt_dir/http-readback.csv"
  all_ok=true
  for path in / /__spa_route_probe__; do
    metrics="$(curl -LfsS -o /dev/null -w '%{http_code},%{time_total}' "https://$cf_domain$path" || true)"
    printf '%s,%s\n' "$path" "$metrics" | tee -a "$receipt_dir/http-readback.csv"
    code="${metrics%%,*}"
    [[ "$code" == "200" ]] || all_ok=false
  done

  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    safe_key="${key// /%20}"
    metrics="$(curl -LfsS -o /dev/null -w '%{http_code},%{time_total}' "https://$cf_domain/$safe_key" || true)"
    printf '/%s,%s\n' "$key" "$metrics" | tee -a "$receipt_dir/http-readback.csv"
    code="${metrics%%,*}"
    [[ "$code" == "200" ]] || all_ok=false
  done < <(jq -r '[.Contents[]?.Key | select(startswith("assets/"))][0:5][]?' "$receipt_dir/s3-objects.json")

  [[ "$all_ok" == true ]] || {
    echo "BLOCKED: CloudFront validation failed for $CURRENT_SITE" >&2
    exit 1
  }

  jq -n --arg schema "t4h.portfolio.site-cloudfront-proof.v1"     --arg status "REAL_CLOUDFRONT_PRECUTOVER_PATH" --arg classification "PARTIAL"     --arg run_id "$RUN_ID" --arg site_id "$CURRENT_SITE" --arg domain "$domain"     --arg bucket "$CURRENT_BUCKET" --arg distribution_id "$CURRENT_DIST"     --arg cloudfront_domain "https://$cf_domain"     '{schema:$schema,status:$status,classification:$classification,run_id:$run_id,site_id:$site_id,domain:$domain,bucket:$bucket,distribution_id:$distribution_id,cloudfront_domain:$cloudfront_domain,private_s3_origin:true,spa_fallback_verified:true,dns_changed:false,next_gate:"ACM certificate and alias validation before approved Route53 cutover"}'     > "$receipt_dir/final-receipt.json"
  distribution_receipts+=("$receipt_dir/final-receipt.json")
done

jq -n --arg schema "t4h.portfolio.three-site-cloudfront.v1"   --arg status "REAL_THREE_SITE_CLOUDFRONT_PATHS" --arg classification "PARTIAL"   --arg run_id "$RUN_ID" --arg run_root "$RUN_ROOT"   '{schema:$schema,status:$status,classification:$classification,run_id:$run_id,run_root:$run_root,dns_changed:false,next_gate:"Per-site ACM and aliases, then separately approved DNS cutovers"}'   > "$RUN_ROOT/final-receipt.json"

FINAL_SHA="$(shasum -a 256 "$RUN_ROOT/final-receipt.json" | awk '{print $1}')"
printf '{"timestamp":"%s","run_id":"%s","event":"THREE_SITE_CLOUDFRONT_VALIDATED","status":"REAL_THREE_SITE_CLOUDFRONT_PATHS","evidence_sha256":"%s"}\n'   "$(date -u +%FT%TZ)" "$RUN_ID" "$FINAL_SHA" > "$RUN_ROOT/ledger.jsonl"

S3_PREFIX="s3://$ARCHIVE_BUCKET/deployments/portfolio/three-site-cloudfront/$RUN_ID"
aws s3 sync "$RUN_ROOT" "$S3_PREFIX/" > "$RUN_ROOT/archive-upload.log"
aws s3 cp "$S3_PREFIX/final-receipt.json" "$RUN_ROOT/final-receipt.readback.json" >/dev/null
READBACK_SHA="$(shasum -a 256 "$RUN_ROOT/final-receipt.readback.json" | awk '{print $1}')"
[[ "$FINAL_SHA" == "$READBACK_SHA" ]] || {
  echo "BLOCKED: batch receipt readback mismatch" >&2
  exit 1
}

FINAL_WRITTEN=true
cat "$RUN_ROOT/final-receipt.json"
echo "STATUS=REAL_THREE_SITE_CLOUDFRONT_PATHS"
echo "DNS_CHANGED=false"
echo "S3_RECEIPT=$S3_PREFIX/final-receipt.json"
echo "S3_READBACK_SHA256=$READBACK_SHA"
echo "RUN_ROOT=$RUN_ROOT"
