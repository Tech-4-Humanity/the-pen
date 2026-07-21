#!/usr/bin/env bash
set -Eeuo pipefail

export VERCEL_SCOPE="${VERCEL_SCOPE:-holo-org}"

if command -v vercel >/dev/null 2>&1; then
  VERCEL_BIN="$(command -v vercel)"
else
  VERCEL_BIN="npx --yes vercel@latest"
fi

# Make the chosen CLI available to the existing runner without modifying global npm.
TMP_BIN_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_BIN_DIR"' EXIT
cat >"$TMP_BIN_DIR/vercel" <<EOF
#!/usr/bin/env bash
exec $VERCEL_BIN "\$@"
EOF
chmod +x "$TMP_BIN_DIR/vercel"
export PATH="$TMP_BIN_DIR:$PATH"

vercel whoami >/dev/null
vercel teams ls >/dev/null 2>&1 || true

RUNNER="$(cd "$(dirname "$0")" && pwd)/run-recovery-50-sites.sh"
exec bash "$RUNNER" "$@"
