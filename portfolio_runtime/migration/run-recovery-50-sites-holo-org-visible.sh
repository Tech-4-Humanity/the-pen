#!/usr/bin/env bash
set -Eeuo pipefail

export VERCEL_SCOPE="${VERCEL_SCOPE:-holo-org}"
export CI=1
export VERCEL_TELEMETRY_DISABLED=1

if command -v vercel >/dev/null 2>&1; then
  VERCEL_BIN="$(command -v vercel)"
else
  VERCEL_BIN="npx --yes vercel@latest"
fi

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_RUNNER="$BASE_DIR/run-recovery-50-sites.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat >"$TMP_DIR/vercel" <<EOF
#!/usr/bin/env bash
exec $VERCEL_BIN "\$@"
EOF
chmod +x "$TMP_DIR/vercel"
export PATH="$TMP_DIR:$PATH"

# Patch only the temporary execution copy:
# - remove the silent whoami preflight that can wait indefinitely;
# - show each site and stream its log to the terminal.
python3 - "$SOURCE_RUNNER" "$TMP_DIR/runner.sh" <<'PY'
from pathlib import Path
import sys
src = Path(sys.argv[1]).read_text()
src = src.replace('vercel whoami >"$ROOT/vercel-whoami.txt" 2>&1 || true\n',
                  'printf "SKIPPED_NONESSENTIAL_VERCEL_WHOAMI=true\\n" >"$ROOT/vercel-whoami.txt"\n')
src = src.replace('  log="$LOGS/$(slugify "$site").log"\n  {',
                  '  log="$LOGS/$(slugify "$site").log"\n  echo "START [$processed/$MAX_SITES] $site mode=$mode ref=$ref"\n  {')
src = src.replace('  } >"$log" 2>&1 || {',
                  '  } > >(tee "$log") 2>&1 || {')
Path(sys.argv[2]).write_text(src)
PY
chmod +x "$TMP_DIR/runner.sh"

echo "RECOVERY_SCOPE=$VERCEL_SCOPE"
echo "RECOVERY_MODE=VISIBLE_NONINTERACTIVE"
echo "RUNNER=$TMP_DIR/runner.sh"
exec bash "$TMP_DIR/runner.sh" "$@"
