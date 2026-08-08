#!/usr/bin/env bash
# T4H shell navigation helpers. Keep this layer small; the-pen is canonical.

T4H_GUIDE_URL="https://github.com/TML-4PM/the-pen/blob/main/docs/operations/T4H_REPOSITORY_PRELOAD_GUIDE.md"

repo() {
  case "${1:-}" in
    runtime-real) cd "$HOME/runtime-real" ;;
    the-pen) cd "$HOME/the-pen" ;;
    control-plane) cd "$HOME/t4h-engineering-control-plane" ;;
    mcp) cd "$HOME/t4h-remote-mcp-server-clean" ;;
    bridge) cd "$HOME/bridge-worker-intake" ;;
    command-centre) cd "$HOME/mcp-command-centre" ;;
    synal-core) cd "$HOME/my-project" ;;
    status)
      for pair in \
        "runtime-real:$HOME/runtime-real" \
        "the-pen:$HOME/the-pen" \
        "control-plane:$HOME/t4h-engineering-control-plane" \
        "mcp:$HOME/t4h-remote-mcp-server-clean" \
        "bridge:$HOME/bridge-worker-intake" \
        "command-centre:$HOME/mcp-command-centre"; do
        name=${pair%%:*}; path=${pair#*:}
        if [ -d "$path/.git" ]; then printf 'REAL     %s\n' "$name"; else printf 'MISSING  %s\n' "$name"; fi
      done
      ;;
    help|"")
      printf '%s\n' 'T4H REPOSITORIES' \
        '  repo runtime-real' \
        '  repo the-pen' \
        '  repo control-plane' \
        '  repo mcp' \
        '  repo bridge' \
        '  repo command-centre' \
        '  repo synal-core' \
        '  repo status' \
        '  guide'
      ;;
    *) echo "Unknown repo: $1"; repo help; return 2 ;;
  esac
}

guide() {
  if command -v open >/dev/null 2>&1; then open "$T4H_GUIDE_URL";
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$T4H_GUIDE_URL" >/dev/null 2>&1 &
  else printf '%s\n' "$T4H_GUIDE_URL"; fi
}
