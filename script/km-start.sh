#!/usr/bin/env bash
# Install (when missing), start and bootstrap KM with the repository this script lives in as
# the knowledge root.
#
#   ./script/km-start.sh
#
# Copy this file into any repo's script/ directory. The repo (the parent of script/) is the
# knowledge root; <repo>/planning is the planning store (created empty when missing). It passes
# --no-config, so ~/.config/km/config.json cannot supply a root, a sessions store or fleet.
# It never stops another process, writes no LaunchAgent and edits no config file.
# See docs/configuration.md in the knowledge-management repo.
#
# Steps, in order:
#   1. KM_HOME has no built daemon: clone knowledge-management there (when the directory is
#      missing) and build it with its scripts/install-km-desktop.sh --daemon.
#   2. Start the daemon (or find this repo's running one) and open the browser on its UI; the UI
#      opens the pages listed in <repo>/km-open.json.
#   3. First run: ask which local agent CLI (from GET /api/agents) the implementer uses, and save
#      it for this instance (POST /api/impl/config → <repo>/planning/autonomous/). Later runs
#      reuse it; delete that file to be asked again.
#   4. Offer to connect GitHub issues for this KB (POST /api/github/connect). The token is kept
#      under KM_GITHUB_DIR, never in the repo. Declining leaves KM running.
# Prompts need a terminal on stdin (or KM_INTERACTIVE=1); otherwise steps 3 and 4 only print.
#
# Environment:
#   KM_PORT           daemon port (default: first free of 4790-4799; 4700 / 4173 are refused)
#   KM_HOME           knowledge-management checkout with a built daemon
#                     (default: this repo when it is that checkout, else ~/.km/knowledge-management)
#   KM_REPO_URL       where step 1 clones KM from (default git@github.com:unpolarize/knowledge-management.git)
#   KM_INSTALL        0 = fail instead of installing when KM_HOME has no built daemon
#   KM_SESSIONS_ROOT  sessions store; --sessions-root is passed only when this is set
#   KM_LOG            daemon log (default: $TMPDIR/km-start-<repo>-<port>.log)
#   KM_OPEN           command that opens the UI URL (default: open / xdg-open); "none" skips it
#   KM_IMPLEMENTER    agent id for step 3 without asking (claude, grok, codex, ...)
#   KM_GITHUB_DIR     GitHub credentials for this repo (default: ~/.config/km/github/<repo>)
#   KM_INTERACTIVE    1 = prompt even without a terminal, 0 = never prompt
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
PLANNING="$REPO/planning"
IMPL_FILE="$PLANNING/autonomous/auto-implementer.json"

die() { echo "km-start: $*" >&2; exit 1; }

command -v node >/dev/null 2>&1 || die "node is not on PATH (install Node 22+)"
command -v curl >/dev/null 2>&1 || die "curl is not on PATH"

is_km_checkout() { [ -f "$1/packages/daemon/package.json" ]; }

if [ -z "${KM_HOME:-}" ]; then
  if is_km_checkout "$REPO"; then KM_HOME="$REPO"; else KM_HOME="$HOME/.km/knowledge-management"; fi
fi
CLI="$KM_HOME/packages/daemon/dist/cli.js"

if [ ! -f "$CLI" ]; then
  [ "${KM_INSTALL:-1}" = 0 ] && die "no built daemon at $CLI. Set KM_HOME to a knowledge-management checkout and run 'npm run build' there."
  if [ ! -e "$KM_HOME" ]; then
    command -v git >/dev/null 2>&1 || die "git is not on PATH; cannot clone KM into $KM_HOME"
    url="${KM_REPO_URL:-git@github.com:unpolarize/knowledge-management.git}"
    echo "km-start: KM is not installed; cloning $url into $KM_HOME"
    git clone --depth 1 "$url" "$KM_HOME" || die "could not clone $url (set KM_REPO_URL or KM_HOME)"
  fi
  is_km_checkout "$KM_HOME" || die "$KM_HOME is not a knowledge-management checkout"
  echo "km-start: building KM in $KM_HOME"
  bash "$KM_HOME/scripts/install-km-desktop.sh" --daemon || die "building KM in $KM_HOME failed"
  [ -f "$CLI" ] || die "build finished but there is still no daemon at $CLI"
fi
# Physical path: cli.js runs only when argv[1] is its real path, so a symlinked KM_HOME
# (/tmp on macOS) would exit 0 without starting.
KM_HOME="$(cd "$KM_HOME" && pwd -P)"
CLI="$KM_HOME/packages/daemon/dist/cli.js"

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

# --- bootstrap (steps 2-4) ---

interactive() {
  case "${KM_INTERACTIVE:-}" in
    1) return 0 ;;
    0) return 1 ;;
  esac
  [ -t 0 ]
}

ask() { # ask <prompt> → the answer line on stdout ("" at end of input)
  local reply=""
  printf '%s' "$1" >&2
  IFS= read -r reply || true
  printf '%s' "$reply"
}

api() { # api <GET|POST> <path> [json body on stdin]
  if [ "$1" = POST ]; then
    curl -sS --max-time 60 -X POST -H 'content-type: application/json' --data-binary @- "$BASE/api$2"
  else
    curl -sS --max-time 10 "$BASE/api$2"
  fi
}

# Read one field of JSON on stdin: jget '<js expression of j>'.
jget() { node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{let j;try{j=JSON.parse(s)}catch{j=null}let v;try{v=(new Function("j","return ("+process.argv[1]+")"))(j)}catch{v=""}process.stdout.write(v==null?"":String(v))})' "$1"; }

open_browser() {
  local cmd="${KM_OPEN:-}"
  if [ "$cmd" = none ]; then echo "Open $BASE/ in a browser."; return; fi
  if [ -z "$cmd" ]; then
    if [ "$(uname -s)" = Darwin ]; then cmd=open
    elif command -v xdg-open >/dev/null 2>&1; then cmd=xdg-open
    else echo "Open $BASE/ in a browser."; return
    fi
  fi
  $cmd "$BASE/" >/dev/null 2>&1 || echo "km-start: could not run '$cmd'; open $BASE/ in a browser." >&2
}

saved_implementer() {
  [ -f "$IMPL_FILE" ] || return 0
  jget 'j && (j.provider || j.backend) || ""' <"$IMPL_FILE"
}

save_implementer() { # save_implementer <id> <model>
  local out
  out="$(printf '{"provider":"%s","model":"%s"}' "$1" "$2" | api POST /impl/config)" ||
    { echo "km-start: could not save the implementer: $out" >&2; return; }
  echo "Implementer: $(printf '%s' "$out" | jget 'j.provider') (saved in $IMPL_FILE)"
}

pick_implementer() {
  local saved rows n=0 i reply id
  saved="$(saved_implementer)"
  if [ -n "$saved" ] && [ -z "${KM_IMPLEMENTER:-}" ]; then
    echo "Implementer: $saved (from $IMPL_FILE; delete it to choose again)"
    return
  fi
  # "id<TAB>label<TAB>first model", one line per agent CLI found on this machine.
  rows="$(api GET /agents | jget '((j && j.agents) || []).filter(a => a.available && !String(a.id).startsWith("mock")).map(a => [a.id, a.label, (a.models || [])[0] || "default"].join("\t")).join("\n")')" || rows=""
  local ids=() labels=() models=()
  while IFS=$'\t' read -r id label model; do
    [ -n "$id" ] || continue
    ids+=("$id"); labels+=("$label"); models+=("$model")
  done <<<"$rows"
  n=${#ids[@]}
  if [ -n "${KM_IMPLEMENTER:-}" ]; then
    for ((i = 0; i < n; i++)); do
      if [ "${ids[$i]}" = "$KM_IMPLEMENTER" ]; then save_implementer "${ids[$i]}" "${models[$i]}"; return; fi
    done
    echo "km-start: KM_IMPLEMENTER=$KM_IMPLEMENTER is not an agent CLI found on this machine (found: ${ids[*]:-none})" >&2
    return
  fi
  if [ "$n" = 0 ]; then
    echo "Implementer: no agent CLI found (install claude, grok or codex, then run this again)."
    return
  fi
  if ! interactive; then
    echo "Implementer: not set. Found: ${ids[*]}. Run in a terminal, or set KM_IMPLEMENTER=<id>."
    return
  fi
  echo "Agent CLIs on this machine:"
  for ((i = 0; i < n; i++)); do echo "  $((i + 1))) ${labels[$i]} (${ids[$i]})"; done
  reply="$(ask "Which one should the KM implementer use? [1-$n, Enter = 1, s = skip] ")"
  case "$reply" in
    s|S|n|N) echo "Implementer: skipped (you will be asked next time)."; return ;;
    "") i=0 ;;
    *[!0-9]*) echo "Implementer: '$reply' is not a choice; skipped."; return ;;
    *) i=$((reply - 1)) ;;
  esac
  if [ "$i" -lt 0 ] || [ "$i" -ge "$n" ]; then echo "Implementer: '$reply' is not a choice; skipped."; return; fi
  save_implementer "${ids[$i]}" "${models[$i]}"
}

origin_repo() { # owner/name of the origin remote, when it is a GitHub URL
  git -C "$REPO" remote get-url origin 2>/dev/null |
    sed -n -E 's#^(git@|ssh://git@|https://)([^/:]*@)?github\.com[:/]([^/]+/[^/]+)$#\3#p' | sed 's/\.git$//'
}

offer_github() {
  local view reply repo token out
  view="$(api GET /github 2>/dev/null)" || return 0
  case "$(printf '%s' "$view" | jget 'j && typeof j.connected === "boolean" ? j.connected : ""')" in
    true) echo "GitHub issues: $(printf '%s' "$view" | jget 'j.repo') (connected)"; return ;;
    false) ;;
    *) return 0 ;; # this daemon has no GitHub integration
  esac
  if ! interactive; then
    echo "GitHub issues: not connected. Connect in KM Daemon → Configuration → Integrations."
    return
  fi
  reply="$(ask "Connect GitHub issues for this KB so KM can manage them? [y/N] ")"
  case "$reply" in
    y|Y|yes|Yes) ;;
    *) echo "GitHub issues: skipped. Connect later in KM Daemon → Configuration → Integrations."; return ;;
  esac
  repo="$(origin_repo)"
  reply="$(ask "GitHub repository (owner/name)${repo:+ [$repo]}: ")"
  repo="${reply:-$repo}"
  [ -n "$repo" ] || { echo "GitHub issues: no repository; skipped."; return; }
  token=""
  if command -v gh >/dev/null 2>&1 && gh auth token >/dev/null 2>&1; then
    reply="$(ask "Use the token from the gh CLI? [Y/n] ")"
    case "$reply" in n|N|no|No) ;; *) token="$(gh auth token)" ;; esac
  fi
  if [ -z "$token" ]; then
    printf 'GitHub token (stored in %s, never in the repo): ' "$GITHUB_DIR" >&2
    if [ -t 0 ]; then IFS= read -rs token || true; echo >&2; else IFS= read -r token || true; fi
  fi
  [ -n "$token" ] || { echo "GitHub issues: no token; skipped."; return; }
  out="$(GH_REPO_IN="$repo" GH_TOKEN_IN="$token" node -e 'process.stdout.write(JSON.stringify({repo:process.env.GH_REPO_IN,token:process.env.GH_TOKEN_IN,state:"open",labels:""}))' |
    api POST /github/connect)" || true
  if [ "$(printf '%s' "$out" | jget 'j && j.ok === true')" = true ]; then
    echo "GitHub issues: connected $(printf '%s' "$out" | jget 'j.repo') as $(printf '%s' "$out" | jget 'j.login') ($(printf '%s' "$out" | jget 'j.count') issues on the board)"
  else
    echo "GitHub issues: not connected ($(printf '%s' "$out" | jget 'j && j.error || "no answer"')); KM keeps running." >&2
  fi
}

bootstrap() {
  BASE="http://127.0.0.1:$1"
  open_browser
  pick_implementer
  offer_github
  echo "KM for $REPO: $BASE/"
}

GITHUB_DIR="${KM_GITHUB_DIR:-$HOME/.config/km/github/$(basename "$REPO")}"

already_running() {
  echo "KM for $REPO is already running: http://127.0.0.1:$1/"
  bootstrap "$1"
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

ARGS=(--no-config --port "$PORT" --root "$PLANNING" --kb-root "$REPO" --github-dir "$GITHUB_DIR")
if [ -n "${KM_SESSIONS_ROOT:-}" ]; then ARGS+=(--sessions-root "$KM_SESSIONS_ROOT"); fi
if [ -d "$KM_HOME/packages/ui/dist" ]; then ARGS+=(--ui-dist "$KM_HOME/packages/ui/dist"); fi

TMP="${TMPDIR:-/tmp}"
LOG="${KM_LOG:-${TMP%/}/km-start-$(basename "$REPO")-$PORT.log}"
nohup node "$CLI" "${ARGS[@]}" >>"$LOG" 2>&1 &
PID=$!

for _ in $(seq 1 60); do
  if health "$PORT" >/dev/null; then
    echo "KM daemon started (pid $PID, log $LOG)"
    bootstrap "$PORT"
    exit 0
  fi
  kill -0 "$PID" 2>/dev/null || die "daemon exited during boot; see $LOG"
  sleep 0.5
done
die "daemon (pid $PID) did not answer /api/health on port $PORT within 30s; see $LOG"
