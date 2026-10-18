#!/usr/bin/env bash
# Start KM with the repository this script lives in as the knowledge root.
#
#   ./script/km-start.sh
#
# Copy this file into any repo's script/ directory. The repo (the parent of script/) is the
# knowledge root; <repo>/planning is the planning store (created empty when missing). It passes
# --no-config, so ~/.config/km/config.json cannot supply a root, a sessions store or fleet.
# It never stops another process, writes no LaunchAgent and edits no config file.
# See docs/configuration.md in the knowledge-management repo.
#
# Environment:
#   KM_PORT           daemon port (default: first free of 4790-4799; 4700 / 4173 are refused)
#   KM_HOME           knowledge-management checkout with a built daemon
#                     (default: this repo, when it is that checkout)
#   KM_SESSIONS_ROOT  sessions store; --sessions-root is passed only when this is set
#   KM_LOG            daemon log (default: $TMPDIR/km-start-<repo>-<port>.log)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
PLANNING="$REPO/planning"

die() { echo "km-start: $*" >&2; exit 1; }

KM_HOME="${KM_HOME:-$REPO}"
CLI="$KM_HOME/packages/daemon/dist/cli.js"
[ -f "$CLI" ] || die "no built daemon at $CLI. Set KM_HOME to a knowledge-management checkout and run 'npm run build' there."
command -v node >/dev/null 2>&1 || die "node is not on PATH"

reserved() { [ "$1" = 4700 ] || [ "$1" = 4173 ]; }
listening() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
health() { curl -sf --max-time 2 "http://127.0.0.1:$1/api/health" 2>/dev/null; }

# Command line of the daemon answering on port $1, from the pid its /api/health reports.
daemon_cmdline() {
  local pid
  pid="$(health "$1" | sed -n 's/.*"pid":\([0-9][0-9]*\).*/\1/p')"
  [ -n "$pid" ] && ps -o command= -p "$pid" 2>/dev/null
}

serves_this_repo() {
  local cmd
  cmd="$(daemon_cmdline "$1")" || return 1
  case "$cmd " in *"--kb-root $REPO "*) return 0 ;; esac
  return 1
}

# 0 = this repo's daemon already answers there, 1 = free, 2 = taken by something else.
port_state() {
  if serves_this_repo "$1"; then return 0; fi
  if listening "$1"; then return 2; fi
  return 1
}

already_running() {
  echo "KM for $REPO is already running: http://127.0.0.1:$1/"
  exit 0
}

PORT=""
if [ -n "${KM_PORT:-}" ]; then
  reserved "$KM_PORT" && die "KM_PORT=$KM_PORT is reserved for the live KM instance (daemon 4700, UI 4173)"
  st=0; port_state "$KM_PORT" || st=$?
  case "$st" in
    0) already_running "$KM_PORT" ;;
    2) die "port $KM_PORT is in use by another process (not KM for $REPO). Pick another KM_PORT." ;;
  esac
  PORT="$KM_PORT"
else
  # Scan the whole range first: this repo's daemon on a later port wins over a free earlier one.
  for p in 4790 4791 4792 4793 4794 4795 4796 4797 4798 4799; do
    st=0; port_state "$p" || st=$?
    case "$st" in
      0) already_running "$p" ;;
      1) [ -z "$PORT" ] && PORT="$p" ;;
    esac
  done
  [ -n "$PORT" ] || die "ports 4790-4799 are all in use. Set KM_PORT to a free port."
fi

mkdir -p "$PLANNING"

ARGS=(--no-config --port "$PORT" --root "$PLANNING" --kb-root "$REPO")
if [ -n "${KM_SESSIONS_ROOT:-}" ]; then ARGS+=(--sessions-root "$KM_SESSIONS_ROOT"); fi
if [ -d "$KM_HOME/packages/ui/dist" ]; then ARGS+=(--ui-dist "$KM_HOME/packages/ui/dist"); fi

TMP="${TMPDIR:-/tmp}"
LOG="${KM_LOG:-${TMP%/}/km-start-$(basename "$REPO")-$PORT.log}"
nohup node "$CLI" "${ARGS[@]}" >>"$LOG" 2>&1 &
PID=$!

for _ in $(seq 1 60); do
  if health "$PORT" >/dev/null; then
    echo "KM for $REPO: http://127.0.0.1:$PORT/ (pid $PID, log $LOG)"
    exit 0
  fi
  kill -0 "$PID" 2>/dev/null || die "daemon exited during boot; see $LOG"
  sleep 0.5
done
die "daemon (pid $PID) did not answer /api/health on port $PORT within 30s; see $LOG"
