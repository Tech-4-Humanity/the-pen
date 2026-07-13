#!/usr/bin/env bash
set -Eeuo pipefail

AWS_PROFILE="${AWS_PROFILE:-default}"
AWS_REGION="${AWS_REGION:-ap-southeast-2}"
REPO_DIR="${REPO_DIR:-$HOME/Downloads/the-pen}"
ARTIFACT_DIR="$REPO_DIR/deploy/the-pen-status"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
RECEIPT_DIR="$REPO_DIR/receipts/the-pen-deploy/$RUN_ID"
mkdir -p "$RECEIPT_DIR"
exec > >(tee -a "$RECEIPT_DIR/run.log") 2>&1

need(){ command -v "$1" >/dev/null 2>&1 || { echo "BLOCKED missing $1"; exit 1; }; }
need aws; need git; need curl; need python3; need shasum

cd "$REPO_DIR"
git pull --ff-only origin main
[[ -f "$ARTIFACT_DIR/index.html" ]] || { echo "BLOCKED canonical artefact missing"; exit 1; }
grep -q 'THE_PEN_CONTROL_SURFACE_V1' "$ARTIFACT_DIR/index.html" || { echo "BLOCKED identity marker missing"; exit 1; }

ACCOUNT_ID="$(aws --profile "$AWS_PROFILE" sts get-caller-identity --query Account --output text)"
BUCKET="t4h-the-pen-prod-$ACCOUNT_ID"
OAC_NAME="the-pen-oac-$ACCOUNT_ID"
CALLER_REFERENCE="the-pen-$RUN_ID"

if ! aws --profile "$AWS_PROFILE" --region "$AWS_REGION" s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  if [[ "$AWS_REGION" == "us-east-1" ]]; then
    aws --profile "$AWS_PROFILE" s3api create-bucket --bucket "$BUCKET"
  else
    aws --profile "$AWS_PROFILE" --region "$AWS_REGION" s3api create-bucket --bucket "$BUCKET" --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
fi

aws --profile "$AWS_PROFILE" --region "$AWS_REGION" s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws --profile "$AWS_PROFILE" --region "$AWS_REGION" s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
aws --profile "$AWS_PROFILE" --region "$AWS_REGION" s3api put-bucket-encryption --bucket "$BUCKET" --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws --profile "$AWS_PROFILE" --region "$AWS_REGION" s3 sync "$ARTIFACT_DIR/" "s3://$BUCKET/" --delete --only-show-errors

OAC_ID="$(aws --profile "$AWS_PROFILE" cloudfront list-origin-access-controls --query "OriginAccessControlList.Items[?Name=='$OAC_NAME'].Id | [0]" --output text)"
if [[ -z "$OAC_ID" || "$OAC_ID" == "None" ]]; then
  cat > "$RECEIPT_DIR/oac.json" <<JSON
{"OriginAccessControlConfig":{"Name":"$OAC_NAME","Description":"The Pen production OAC","SigningProtocol":"sigv4","SigningBehavior":"always","OriginAccessControlOriginType":"s3"}}
JSON
  OAC_ID="$(aws --profile "$AWS_PROFILE" cloudfront create-origin-access-control --cli-input-json file://"$RECEIPT_DIR/oac.json" --query OriginAccessControl.Id --output text)"
fi

DIST_ID="$(aws --profile "$AWS_PROFILE" cloudfront list-distributions --query "DistributionList.Items[?Comment=='The Pen production control surface'].Id | [0]" --output text)"
if [[ -z "$DIST_ID" || "$DIST_ID" == "None" ]]; then
  cat > "$RECEIPT_DIR/distribution.json" <<JSON
{
  "CallerReference":"$CALLER_REFERENCE",
  "Comment":"The Pen production control surface",
  "Enabled":true,
  "DefaultRootObject":"index.html",
  "Origins":{"Quantity":1,"Items":[{"Id":"the-pen-s3","DomainName":"$BUCKET.s3.$AWS_REGION.amazonaws.com","OriginAccessControlId":"$OAC_ID","S3OriginConfig":{"OriginAccessIdentity":""}}]},
  "DefaultCacheBehavior":{"TargetOriginId":"the-pen-s3","ViewerProtocolPolicy":"redirect-to-https","AllowedMethods":{"Quantity":2,"Items":["GET","HEAD"],"CachedMethods":{"Quantity":2,"Items":["GET","HEAD"]}},"Compress":true,"ForwardedValues":{"QueryString":false,"Cookies":{"Forward":"none"}},"MinTTL":0,"DefaultTTL":300,"MaxTTL":86400},
  "PriceClass":"PriceClass_100",
  "ViewerCertificate":{"CloudFrontDefaultCertificate":true},
  "Restrictions":{"GeoRestriction":{"RestrictionType":"none","Quantity":0}}
}
JSON
  DIST_ID="$(aws --profile "$AWS_PROFILE" cloudfront create-distribution --distribution-config file://"$RECEIPT_DIR/distribution.json" --query Distribution.Id --output text)"
fi

DIST_ARN="arn:aws:cloudfront::$ACCOUNT_ID:distribution/$DIST_ID"
cat > "$RECEIPT_DIR/bucket-policy.json" <<JSON
{"Version":"2012-10-17","Statement":[{"Sid":"AllowCloudFrontRead","Effect":"Allow","Principal":{"Service":"cloudfront.amazonaws.com"},"Action":"s3:GetObject","Resource":"arn:aws:s3:::$BUCKET/*","Condition":{"StringEquals":{"AWS:SourceArn":"$DIST_ARN"}}}]}
JSON
aws --profile "$AWS_PROFILE" --region "$AWS_REGION" s3api put-bucket-policy --bucket "$BUCKET" --policy file://"$RECEIPT_DIR/bucket-policy.json"

aws --profile "$AWS_PROFILE" cloudfront wait distribution-deployed --id "$DIST_ID"
DOMAIN="$(aws --profile "$AWS_PROFILE" cloudfront get-distribution --id "$DIST_ID" --query Distribution.DomainName --output text)"
INVALIDATION_ID="$(aws --profile "$AWS_PROFILE" cloudfront create-invalidation --distribution-id "$DIST_ID" --paths '/*' --query Invalidation.Id --output text)"
aws --profile "$AWS_PROFILE" cloudfront wait invalidation-completed --distribution-id "$DIST_ID" --id "$INVALIDATION_ID"

HTTP_CODE="$(curl -L -sS -o "$RECEIPT_DIR/live.html" -w '%{http_code}' "https://$DOMAIN/")"
grep -q 'THE_PEN_CONTROL_SURFACE_V1' "$RECEIPT_DIR/live.html" || { echo "BLOCKED live identity mismatch"; exit 1; }
[[ "$HTTP_CODE" == "200" ]] || { echo "BLOCKED HTTP $HTTP_CODE"; exit 1; }
SOURCE_SHA="$(shasum -a 256 "$ARTIFACT_DIR/index.html" | awk '{print $1}')"
LIVE_SHA="$(shasum -a 256 "$RECEIPT_DIR/live.html" | awk '{print $1}')"
[[ "$SOURCE_SHA" == "$LIVE_SHA" ]] || { echo "BLOCKED checksum mismatch"; exit 1; }

cat > "$RECEIPT_DIR/deployment_receipt.json" <<JSON
{"status":"REAL","target_id":"the-pen-production","repository":"TML-4PM/the-pen","artifact_path":"deploy/the-pen-status","source_commit":"$(git rev-parse HEAD)","s3_bucket":"$BUCKET","cloudfront_distribution_id":"$DIST_ID","canonical_url":"https://$DOMAIN","expected_content_identity":{"type":"sha256","path":"index.html","value":"$SOURCE_SHA"},"live_checksum":"$LIVE_SHA","http_status":200,"cloudfront_invalidation_id":"$INVALIDATION_ID","rollback_source":"S3 versioning plus canonical Git commit","owner":"Tech 4 Humanity"}
JSON

git add "$RECEIPT_DIR"
git commit -m "Record The Pen S3 CloudFront deployment $RUN_ID"
git push origin main

printf '\nSTATUS=REAL\nURL=https://%s\nBUCKET=%s\nDISTRIBUTION=%s\nRECEIPT=%s\n' "$DOMAIN" "$BUCKET" "$DIST_ID" "$RECEIPT_DIR/deployment_receipt.json"
