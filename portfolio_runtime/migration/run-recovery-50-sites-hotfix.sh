#!/usr/bin/env bash
set -Eeuo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RUNNER="$HERE/run-recovery-50-sites.sh"

if [[ ! -x "$RUNNER" ]]; then
  chmod +x "$RUNNER"
fi

# The base runner previously attempted `npm install -g vercel` when the CLI was
# absent. On Troy's Mac that can fail against a stale global npm directory and
# stop the entire recovery wave before any site is processed.
#
# Provide a bounded no-op Vercel shim only when no usable CLI is already in
# PATH. Vercel-project extraction will fail cleanly per site, after which the
# base runner continues to its public URL mirror and local-preservation
# fallbacks. GitHub builds, S3 publication and receipt emission remain active.
TMP_BIN="$(mktemp -d "${TMPDIR:-/tmp}/t4h-recovery-bin.XXXXXX")"
cleanup(){ rm -rf "$TMP_BIN"; }
trap cleanup EXIT

if command -v vercel >/dev/null 2>&1; then
  echo "VERCEL_MODE=EXISTING_CLI"
else
  cat >"$TMP_BIN/vercel" <<'SH'
#!/usr/bin/env bash
echo "VERCEL_CLI_UNAVAILABLE: continuing with URL/local fallbacks" >&2
exit 127
SH
  chmod +x "$TMP_BIN/vercel"
  export PATH="$TMP_BIN:$PATH"
  echo "VERCEL_MODE=FALLBACK_ONLY"
fi

exec "$RUNNER" "$@"
