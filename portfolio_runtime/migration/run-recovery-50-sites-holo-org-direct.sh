#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
export AWS_REGION="${AWS_REGION:-ap-southeast-2}"
export VERCEL_SCOPE="${VERCEL_SCOPE:-holo-org}"
export MAX_SITES="${MAX_SITES:-50}"
export QUEUE="${QUEUE:-$BASE_DIR/recovery-50-sites.csv}"

TMP_BIN_DIR="$(mktemp -d)"
cleanup(){ rm -rf "$TMP_BIN_DIR"; }
trap cleanup EXIT

cat >"$TMP_BIN_DIR/vercel" <<'EOF'
#!/usr/bin/env bash
exec npx --yes vercel@latest "$@"
EOF
chmod +x "$TMP_BIN_DIR/vercel"
export PATH="$TMP_BIN_DIR:$PATH"

echo "RECOVERY_SCOPE=$VERCEL_SCOPE"
echo "QUEUE=$QUEUE"
echo "MAX_SITES=$MAX_SITES"
echo "VERCEL_BIN=$TMP_BIN_DIR/vercel"

exec bash "$BASE_DIR/run-recovery-50-sites.sh"
