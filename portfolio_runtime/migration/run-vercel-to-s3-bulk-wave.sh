#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$ROOT/vercel-to-s3-bulk-wave.sh"
PATCHED="$(mktemp -t vercel-to-s3-bulk-wave.XXXXXX.sh)"
trap 'rm -f "$PATCHED"' EXIT
python3 - "$SOURCE" "$PATCHED" <<'PY'
from pathlib import Path
import sys
src=Path(sys.argv[1]).read_text()
src=src.replace(
'''root_dir="$(jq -r '.raw.rootDirectory // .raw.root_directory // empty' "$INVENTORY/projects.normalized.json" 2>/dev/null | head -1 || true)"''',
'''root_dir="$(jq -r --arg name "$project" '.[] | select(.name==$name) | (.raw.rootDirectory // .raw.root_directory // empty)' "$INVENTORY/projects.normalized.json" 2>/dev/null | head -1 || true)"''')
src=src.replace("    trap 'kill $server_pid 2>/dev/null || true' RETURN\n", "")
src=src.replace("    trap - RETURN\n", "")
Path(sys.argv[2]).write_text(src)
PY
chmod +x "$PATCHED"
exec "$PATCHED" "$@"
