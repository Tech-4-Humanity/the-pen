#!/usr/bin/env bash
set -Eeuo pipefail

REGION="${AWS_REGION:-ap-southeast-2}"
PREFIX="${MIGADU_SSM_PREFIX:-/t4h/migadu/runtime}"
KMS_KEY_ID="${MIGADU_KMS_KEY_ID:-alias/aws/ssm}"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "BLOCKED: missing dependency $1" >&2; exit 2; }; }
need aws

aws sts get-caller-identity --region "$REGION" >/dev/null

read_plain(){
  local var="$1" label="$2" value
  read -r -p "$label: " value
  [[ -n "$value" ]] || { echo "BLOCKED: $var cannot be empty" >&2; exit 3; }
  printf -v "$var" '%s' "$value"
}

read_secret(){
  local var="$1" label="$2" value
  read -r -s -p "$label: " value
  printf '\n'
  [[ -n "$value" ]] || { echo "BLOCKED: $var cannot be empty" >&2; exit 3; }
  printf -v "$var" '%s' "$value"
}

read_plain MIGADU_ADMIN_EMAIL "Migadu admin email"
read_secret MIGADU_API_KEY "Migadu API key"
read_plain MIGADU_DOMAIN "Migadu domain"
read_plain SOURCE_MAILBOX "Source mailbox"
read_secret SOURCE_MAILBOX_PASSWORD "Source mailbox password"
read_secret AGENT_MAILBOX_PASSWORD "Agent mailbox password"

put_secure(){
  local name="$1" value="$2"
  aws ssm put-parameter \
    --region "$REGION" \
    --name "$PREFIX/$name" \
    --type SecureString \
    --key-id "$KMS_KEY_ID" \
    --value "$value" \
    --overwrite >/dev/null
}

put_secure MIGADU_ADMIN_EMAIL "$MIGADU_ADMIN_EMAIL"
put_secure MIGADU_API_KEY "$MIGADU_API_KEY"
put_secure MIGADU_DOMAIN "$MIGADU_DOMAIN"
put_secure SOURCE_MAILBOX "$SOURCE_MAILBOX"
put_secure SOURCE_MAILBOX_PASSWORD "$SOURCE_MAILBOX_PASSWORD"
put_secure AGENT_MAILBOX_PASSWORD "$AGENT_MAILBOX_PASSWORD"

unset MIGADU_API_KEY SOURCE_MAILBOX_PASSWORD AGENT_MAILBOX_PASSWORD

for name in MIGADU_ADMIN_EMAIL MIGADU_API_KEY MIGADU_DOMAIN SOURCE_MAILBOX SOURCE_MAILBOX_PASSWORD AGENT_MAILBOX_PASSWORD; do
  aws ssm get-parameter \
    --region "$REGION" \
    --name "$PREFIX/$name" \
    --with-decryption \
    --query 'Parameter.ARN' \
    --output text >/dev/null
done

cat <<EOF
STATUS=REAL
STORE=AWS_SSM_SECURESTRING
REGION=$REGION
PREFIX=$PREFIX
PARAMETERS=6
VALUES_EXPOSED=false
NEXT=AWS_REGION='$REGION' MIGADU_SSM_PREFIX='$PREFIX' bash workers/issue-237-migadu-runtime-worker.sh
EOF
