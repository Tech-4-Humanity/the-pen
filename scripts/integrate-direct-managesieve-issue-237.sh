#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
BUNDLE="$ROOT/inbox/bundles/migadu-github-agent-routing-all-sprints-20260718.sh"
CLIENT="$ROOT/tools/managesieve_direct.py"

[[ -f "$BUNDLE" ]] || { echo "BLOCKED missing bundle: $BUNDLE"; exit 2; }
[[ -f "$CLIENT" ]] || { echo "BLOCKED missing client: $CLIENT"; exit 2; }

python3 - "$BUNDLE" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
text = text.replace('SIEVE_HOST="${SIEVE_HOST:-sieve.migadu.com}"', 'SIEVE_HOST="${SIEVE_HOST:-imap.migadu.com}"')
text = text.replace('#   SIEVE_HOST               default sieve.migadu.com', '#   SIEVE_HOST               default imap.migadu.com')
text = text.replace('#   optional but recommended: swaks, sieveshell or sieve-connect', '#   optional: swaks; ManageSieve deployment uses tools/managesieve_direct.py')
text = text.replace('require ["fileinto", "copy", "redirect"];', 'require ["fileinto", "copy"];')

replacement = '''upload_sieve() {
  local ms_receipt="$RUN_DIR/managesieve-deployment.json"
  local repo_root="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  local client="$repo_root/tools/managesieve_direct.py"
  [[ -f "$client" ]] || { echo "BLOCKED missing direct ManageSieve client: $client"; return 4; }
  python3 "$client" \\
    --host "$SIEVE_HOST" \\
    --port "$SIEVE_PORT" \\
    --user "$SOURCE_MAILBOX" \\
    --password "$SOURCE_MAILBOX_PASSWORD" \\
    --script "$SIEVE_FILE" \\
    --name t4h-github-agent-routing \\
    --receipt "$ms_receipt"
  jq -e '.state=="REAL" and .authenticated==true and .uploaded==true and .active==true' "$ms_receipt" >/dev/null
}'''

pattern = re.compile(r'upload_sieve\(\) \{.*?\n\}\n\nif \[\[ "\$APPLY" == "1" \]\]; then\n  upload_sieve \| tee "\$RUN_DIR/sieve-upload.txt"', re.S)
match = pattern.search(text)
if match:
    text = text[:match.start()] + replacement + '\n\nif [[ "$APPLY" == "1" ]]; then\n  upload_sieve | tee "$RUN_DIR/sieve-upload.txt"' + text[match.end():]
elif 'python3 "$client"' not in text:
    raise SystemExit('BLOCKED: unable to locate or verify upload_sieve implementation')

path.write_text(text)
PY

bash -n "$BUNDLE"
python3 -m py_compile "$CLIENT"
grep -Fq 'tools/managesieve_direct.py' "$BUNDLE"
grep -Fq 'local repo_root=' "$BUNDLE"
grep -Fq 'SIEVE_HOST="${SIEVE_HOST:-imap.migadu.com}"' "$BUNDLE"
grep -Fq 'require ["fileinto", "copy"];' "$BUNDLE"
! grep -Fq 'require ["fileinto", "copy", "redirect"];' "$BUNDLE"

echo "STATUS=REAL"
echo "PATCH=DIRECT_MANAGESIEVE_AND_SIEVE_CAPABILITIES"
echo "BUNDLE=$BUNDLE"
echo "CLIENT=$CLIENT"
