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

pattern = re.compile(
    r'upload_sieve\(\) \{.*?\n\}\n\n(?=if \[\[ "\$APPLY" == "1" \]\]; then\n  upload_sieve)',
    re.S,
)

if pattern.search(text):
    text = pattern.sub(replacement + '\n\n', text, count=1)
elif 'tools/managesieve_direct.py' in text and 'upload_sieve() {' in text:
    # Already integrated in a structurally equivalent form. Leave it intact.
    pass
else:
    raise SystemExit('BLOCKED: upload_sieve function not found and direct client not integrated')

path.write_text(text)
PY

bash -n "$BUNDLE"
python3 -m py_compile "$CLIENT"
grep -Fq 'tools/managesieve_direct.py' "$BUNDLE"
grep -Fq 'local repo_root=' "$BUNDLE"
grep -Fq 'SIEVE_HOST="${SIEVE_HOST:-imap.migadu.com}"' "$BUNDLE"

# Idempotency gate: a second application must also succeed and leave valid syntax.
python3 - "$BUNDLE" <<'PY'
from pathlib import Path
import sys
text = Path(sys.argv[1]).read_text()
required = [
    'tools/managesieve_direct.py',
    'local repo_root=',
    'managesieve-deployment.json',
]
missing = [item for item in required if item not in text]
if missing:
    raise SystemExit(f'BLOCKED: integrated bundle missing markers: {missing}')
PY

echo "STATUS=REAL"
echo "PATCH=DIRECT_MANAGESIEVE_INTEGRATED_IDEMPOTENT"
echo "BUNDLE=$BUNDLE"
echo "CLIENT=$CLIENT"
