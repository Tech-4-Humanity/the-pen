#!/usr/bin/env bash
set -euo pipefail

# Installs a repository-level GitHub Actions self-hosted runner for TML-4PM/the-pen.
# Required environment:
#   GH_TOKEN  Fine-grained token with Administration:write for TML-4PM/the-pen
# Optional:
#   RUNNER_USER, RUNNER_ROOT, RUNNER_NAME, RUNNER_LABELS, REPO

REPO="${REPO:-TML-4PM/the-pen}"
RUNNER_USER="${RUNNER_USER:-ubuntu}"
RUNNER_ROOT="${RUNNER_ROOT:-/opt/actions-runner-the-pen}"
RUNNER_NAME="${RUNNER_NAME:-t4h-bridge-$(hostname -s)}"
RUNNER_LABELS="${RUNNER_LABELS:-t4h-bridge,calmbound,postgres,docker}"
API_VERSION="2026-03-10"
RECEIPT_DIR="${RECEIPT_DIR:-/var/log/t4h-runner}"

fail() { echo "ERROR: $*" >&2; exit 1; }
command -v curl >/dev/null || fail "curl is required"
command -v jq >/dev/null || fail "jq is required"
command -v tar >/dev/null || fail "tar is required"
command -v systemctl >/dev/null || fail "systemd is required"
command -v docker >/dev/null || fail "docker is required for PostgreSQL service containers"
[[ -n "${GH_TOKEN:-}" ]] || fail "GH_TOKEN is required"
id "$RUNNER_USER" >/dev/null 2>&1 || fail "runner user $RUNNER_USER does not exist"

sudo mkdir -p "$RUNNER_ROOT" "$RECEIPT_DIR"
sudo chown -R "$RUNNER_USER:$RUNNER_USER" "$RUNNER_ROOT" "$RECEIPT_DIR"

LATEST_JSON="$(curl -fsSL -H 'Accept: application/vnd.github+json' https://api.github.com/repos/actions/runner/releases/latest)"
VERSION="$(jq -r '.tag_name | sub("^v"; "")' <<<"$LATEST_JSON")"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ASSET="actions-runner-linux-x64-${VERSION}.tar.gz" ;;
  aarch64|arm64) ASSET="actions-runner-linux-arm64-${VERSION}.tar.gz" ;;
  *) fail "unsupported architecture: $ARCH" ;;
esac
URL="$(jq -r --arg asset "$ASSET" '.assets[] | select(.name==$asset) | .browser_download_url' <<<"$LATEST_JSON")"
[[ -n "$URL" && "$URL" != "null" ]] || fail "runner asset not found: $ASSET"

REGISTRATION_JSON="$(curl -fsSL -X POST \
  -H 'Accept: application/vnd.github+json' \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "X-GitHub-Api-Version: ${API_VERSION}" \
  "https://api.github.com/repos/${REPO}/actions/runners/registration-token")"
REGISTRATION_TOKEN="$(jq -r '.token' <<<"$REGISTRATION_JSON")"
[[ -n "$REGISTRATION_TOKEN" && "$REGISTRATION_TOKEN" != "null" ]] || fail "registration token not returned"

sudo -u "$RUNNER_USER" bash -lc "
  set -euo pipefail
  cd '$RUNNER_ROOT'
  if [[ -f .runner ]]; then
    echo 'Runner is already configured; leaving registration intact.'
  else
    curl -fsSL '$URL' -o '$ASSET'
    tar xzf '$ASSET'
    rm -f '$ASSET'
    ./config.sh --unattended \
      --url 'https://github.com/$REPO' \
      --token '$REGISTRATION_TOKEN' \
      --name '$RUNNER_NAME' \
      --labels '$RUNNER_LABELS' \
      --work '_work' \
      --replace
  fi
"

cd "$RUNNER_ROOT"
sudo ./svc.sh install "$RUNNER_USER" || true
sudo ./svc.sh start
sudo ./svc.sh status

SERVICE_NAME="$(systemctl list-unit-files --type=service | awk '/actions.runner/ && /the-pen/ {print $1; exit}')"
STATUS="unknown"
if [[ -n "$SERVICE_NAME" ]] && systemctl is-active --quiet "$SERVICE_NAME"; then STATUS="active"; fi

cat > "$RECEIPT_DIR/bootstrap-receipt.json" <<JSON
{
  "repository": "$REPO",
  "runner_name": "$RUNNER_NAME",
  "labels": "$RUNNER_LABELS",
  "runner_version": "$VERSION",
  "runner_root": "$RUNNER_ROOT",
  "service": "$SERVICE_NAME",
  "service_status": "$STATUS",
  "configured_at_utc": "$(date -u +%FT%TZ)",
  "classification": "REAL_IF_SERVICE_ACTIVE_AND_GITHUB_SHOWS_ONLINE"
}
JSON

cat "$RECEIPT_DIR/bootstrap-receipt.json"
