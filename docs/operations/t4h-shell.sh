#!/usr/bin/env bash
# T4H shell navigation helpers. Keep this layer small; the-pen is canonical.

T4H_GUIDE_URL="https://github.com/TML-4PM/the-pen/blob/main/docs/operations/T4H_REPOSITORY_PRELOAD_GUIDE.md"
T4H_QM_URL="http://localhost:18081/"
T4H_AWS_REGION="ap-southeast-2"
T4H_EC2_INSTANCE="i-09f18f2e1123a5702"
T4H_QM_TUNNEL_LOG="${TMPDIR:-/tmp}/t4h-qm-tunnel.log"

_t4h_path() {
  case "$1" in
    runtime-real) if [ -d "$HOME/projects/runtime-real/.git" ]; then printf '%s' "$HOME/projects/runtime-real"; else printf '%s' "$HOME/runtime-real"; fi ;;
    the-pen) if [ -d "$HOME/projects/TML-4PM/the-pen/.git" ]; then printf '%s' "$HOME/projects/TML-4PM/the-pen"; elif [ -d "$HOME/projects/the-pen/.git" ]; then printf '%s' "$HOME/projects/the-pen"; else printf '%s' "$HOME/the-pen"; fi ;;
    control-plane) printf '%s' "$HOME/t4h-engineering-control-plane" ;;
    mcp) printf '%s' "$HOME/t4h-remote-mcp-server-clean" ;;
    bridge) printf '%s' "$HOME/bridge-worker-intake" ;;
    command-centre) printf '%s' "$HOME/mcp-command-centre" ;;
    synal-core) if [ -d "$HOME/projects/synal-core/.git" ]; then printf '%s' "$HOME/projects/synal-core"; else printf '%s' "$HOME/my-project"; fi ;;
  esac
}

repo() {
  case "${1:-}" in
    runtime-real|the-pen|control-plane|mcp|bridge|command-centre|synal-core) cd "$(_t4h_path "$1")" || return 1 ;;
    status)
      for name in runtime-real the-pen control-plane mcp bridge command-centre; do
        path="$(_t4h_path "$name")"
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

# Mac entry points. Keep these here so the operator surface has one canonical helper.
ec2() {
  ssh t4h-ec2 -t 'cd ~/my-project && exec bash -l'
}

_t4h_qm_tunnel_running() {
  command -v lsof >/dev/null 2>&1 && lsof -nP -iTCP:18081 -sTCP:LISTEN >/dev/null 2>&1
}

_t4h_start_qm_tunnel() {
  : >"$T4H_QM_TUNNEL_LOG"
  nohup aws ssm start-session \
    --region "$T4H_AWS_REGION" \
    --target "$T4H_EC2_INSTANCE" \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["18081"],"localPortNumber":["18081"]}' \
    >"$T4H_QM_TUNNEL_LOG" 2>&1 </dev/null &
  printf '%s' "$!"
}

_t4h_wait_for_qm_tunnel() {
  i=0
  while [ "$i" -lt 30 ]; do
    if _t4h_qm_tunnel_running; then return 0; fi
    if [ -s "$T4H_QM_TUNNEL_LOG" ] && grep -Eq 'failed|error|AccessDenied|TargetNotConnected|Connection refused' "$T4H_QM_TUNNEL_LOG"; then
      return 1
    fi
    sleep 0.5
    i=$((i + 1))
  done
  return 1
}

ec2b() {
  tunnel_pid=""
  own_tunnel=0

  if _t4h_qm_tunnel_running; then
    printf '%s\n' 'ec2b: QM tunnel already running on localhost:18081.'
  else
    tunnel_pid="$(_t4h_start_qm_tunnel)"
    own_tunnel=1
    if ! _t4h_wait_for_qm_tunnel; then
      printf '%s\n' 'ec2b: QM tunnel did not become ready.'
      cat "$T4H_QM_TUNNEL_LOG" 2>/dev/null || true
      kill "$tunnel_pid" 2>/dev/null || true
      return 1
    fi
    printf '%s\n' "ec2b: QM tunnel ready at $T4H_QM_URL"
  fi

  if command -v open >/dev/null 2>&1; then
    open "$T4H_QM_URL" >/dev/null 2>&1 &
  fi

  aws ssm start-session \
    --region "$T4H_AWS_REGION" \
    --target "$T4H_EC2_INSTANCE" \
    --document-name AWS-StartInteractiveCommand \
    --parameters 'command=["sudo -iu ssm-user bash -lc '\''cd ~/qm-docker && exec bash -l'\''"]'
  session_rc=$?

  if [ "$own_tunnel" -eq 1 ]; then
    kill "$tunnel_pid" 2>/dev/null || true
  fi

  return "$session_rc"
}

qmtunnel() {
  if _t4h_qm_tunnel_running; then
    printf '%s\n' 'qmtunnel: local port 18081 is already in use; existing tunnel may already be running.'
    return 1
  fi
  aws ssm start-session \
    --region "$T4H_AWS_REGION" \
    --target "$T4H_EC2_INSTANCE" \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["18081"],"localPortNumber":["18081"]}'
}

guide() {
  if command -v open >/dev/null 2>&1; then open "$T4H_GUIDE_URL";
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$T4H_GUIDE_URL" >/dev/null 2>&1 &
  else printf '%s\n' "$T4H_GUIDE_URL"; fi
}
