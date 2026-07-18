#!/usr/bin/env bash
set -Eeuo pipefail

# Inventory-only next-wave collector. It does not copy, upload, delete, or alter source files.
# Produces file counts, byte totals, extension counts and candidate sensitive-file quarantine lists.

OUT_ROOT="${OUT_ROOT:-$HOME/t4h-canonical-ingest/inventory/$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$OUT_ROOT"

ROOTS=(
  "$HOME/Desktop"
  "$HOME/Documents"
  "$HOME/Downloads"
)

EXCLUDED_PREFIXES=(
  "$HOME/Desktop/000A - to be indexed - and left - daily"
  "$HOME/t4h-canonical-ingest"
  "$HOME/t4h-recovery-validation"
)

MANIFEST="$OUT_ROOT/mac_remainder_inventory.tsv"
SENSITIVE="$OUT_ROOT/sensitive_candidates.tsv"
SUMMARY="$OUT_ROOT/inventory_summary.json"

printf 'root\tpath\tsize_bytes\tmodified_epoch\textension\n' > "$MANIFEST"
printf 'root\tpath\treason\n' > "$SENSITIVE"

python3 - "$MANIFEST" "$SENSITIVE" "${ROOTS[@]}" -- "${EXCLUDED_PREFIXES[@]}" <<'PY'
from __future__ import annotations
import os
import sys
from pathlib import Path

manifest = Path(sys.argv[1])
sensitive = Path(sys.argv[2])
sep = sys.argv.index('--')
roots = [Path(p).expanduser().resolve() for p in sys.argv[3:sep]]
excluded = [Path(p).expanduser().resolve() for p in sys.argv[sep+1:]]

skip_names = {'.DS_Store'}
skip_dirs = {'.git', 'node_modules', '.next', '.venv', 'venv', '__pycache__', '.cache'}
sensitive_parts = ('.env', 'credential', 'secret', '.pem', '.p12', '.key', '.aws', '.ssh')

def under(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False

with manifest.open('a', encoding='utf-8') as mf, sensitive.open('a', encoding='utf-8') as sf:
    for root in roots:
        if not root.exists():
            continue
        for current, dirs, files in os.walk(root, topdown=True, followlinks=False):
            current_path = Path(current).resolve()
            dirs[:] = [d for d in dirs if d not in skip_dirs and not any(under(current_path / d, ex) for ex in excluded)]
            if any(under(current_path, ex) for ex in excluded):
                dirs[:] = []
                continue
            for name in files:
                if name in skip_names:
                    continue
                path = current_path / name
                if any(under(path, ex) for ex in excluded):
                    continue
                lowered = str(path).lower()
                reason = next((part for part in sensitive_parts if part in lowered), '')
                if reason:
                    sf.write(f'{root}\t{path}\t{reason}\n')
                    continue
                try:
                    stat = path.stat()
                except (FileNotFoundError, PermissionError, OSError):
                    continue
                ext = path.suffix.lower() or '[none]'
                mf.write(f'{root}\t{path}\t{stat.st_size}\t{int(stat.st_mtime)}\t{ext}\n')
PY

python3 - "$MANIFEST" "$SENSITIVE" "$SUMMARY" <<'PY'
import csv, json, sys
from collections import Counter
from pathlib import Path

manifest, sensitive, output = map(Path, sys.argv[1:])
rows = list(csv.DictReader(manifest.open(encoding='utf-8'), delimiter='\t'))
sensitive_rows = list(csv.DictReader(sensitive.open(encoding='utf-8'), delimiter='\t'))
roots = Counter(r['root'] for r in rows)
root_bytes = Counter()
extensions = Counter()
for row in rows:
    root_bytes[row['root']] += int(row['size_bytes'])
    extensions[row['extension']] += 1
summary = {
    'status': 'REAL',
    'mode': 'INVENTORY_ONLY',
    'files': len(rows),
    'bytes': sum(root_bytes.values()),
    'roots': {root: {'files': roots[root], 'bytes': root_bytes[root]} for root in roots},
    'top_extensions': dict(extensions.most_common(50)),
    'sensitive_candidates_quarantined_from_manifest': len(sensitive_rows),
    'manifest': str(manifest),
    'sensitive_candidates': str(sensitive),
    'next_action': 'Review coverage and size, then build a SHA-deduplicated approved ingest manifest.'
}
output.write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
print(json.dumps(summary, indent=2))
PY

echo "INVENTORY_SUMMARY=$SUMMARY"
