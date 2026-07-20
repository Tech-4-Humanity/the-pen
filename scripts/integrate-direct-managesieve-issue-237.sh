#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
BUNDLE="$ROOT/inbox/bundles/migadu-github-agent-routing-all-sprints-20260718.sh"
CLIENT="$ROOT/tools/managesieve_direct.py"

[[ -f "$BUNDLE" ]] || { echo "BLOCKED missing bundle: $BUNDLE"; exit 2; }
[[ -f "$CLIENT" ]] || { echo "BLOCKED missing client: $CLIENT"; exit 2; }

python3 - "$BUNDLE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
text = text.replace('SIEVE_HOST="${SIEVE_HOST:-sieve.migadu.com}"', 'SIEVE_HOST="${SIEVE_HOST:-imap.migadu.com}"')
text = text.replace('#   SIEVE_HOST               default sieve.migadu.com', '#   SIEVE_HOST               default imap.migadu.com')
text = text.replace('#   optional but recommended: swaks, sieveshell or sieve-connect', '#   optional: swaks; ManageSieve deployment uses tools/managesieve_direct.py')

start = text.index('upload_sieve() {')
end_marker = '\n}\n\nif [[ "$APPLY" == "1" ]]; then\n  upload_sieve | tee "$RUN_DIR/sieve-upload.txt"'
end = text.index(end_marker, start) + 3
replacement = '''upload_sieve() {
  local ms_receipt="$RUN_DIR/managesieve-deployment.json"
  python3 "$REPO_ROOT/tools/managesieve_direct.py" \\
    --host "$SIEVE_HOST" \\
    --port "$SIEVE_PORT" \\
    --user "$SOURCE_MAILBOX" \\
    --password "$SOURCE_MAILBOX_PASSWORD" \\
    --script "$SIEVE_FILE" \\
    --name t4h-github-agent-routing \\
    --receipt "$ms_receipt"
  jq -e '.state=="REAL" and .authenticated==true and .uploaded==true and .active==true' "$ms_receipt" >/dev/null
}'''
text = text[:start] + replacement + text[end:]
path.write_text(text)
PY

bash -n "$BUNDLE"
python3 -m py_compile "$CLIENT"
grep -Fq 'tools/managesieve_direct.py' "$BUNDLE"
grep -Fq 'SIEVE_HOST="${SIEVE_HOST:-imap.migadu.com}"' "$BUNDLE"

echo "STATUS=REAL"
echo "PATCH=DIRECT_MANAGESIEVE_INTEGRATED"
echo "BUNDLE=$BUNDLE"
echo "CLIENT=$CLIENT"
