#!/usr/bin/env bash
set -euo pipefail

RAW='https://raw.githubusercontent.com/TML-4PM/the-pen/main/docs/operations/t4h-shell.sh'
TARGET="$HOME/.t4h-shell.sh"

curl -fsSL "$RAW" -o "$TARGET"
chmod 644 "$TARGET"

if [[ "${SHELL:-}" == */zsh ]]; then
  RC="$HOME/.zshrc"
else
  RC="$HOME/.bashrc"
fi

grep -qxF '. ~/.t4h-shell.sh' "$RC" 2>/dev/null || printf '\n. ~/.t4h-shell.sh\n' >> "$RC"
. "$TARGET"

printf 'T4H shell installed: %s\n' "$RC"
repo status
