# How to use this repo in KM

This repo is a knowledge base for [Knowledge Management (KM)](https://github.com/unpolarize/knowledge-management):
the apps, the instrumentation pages under `knowledge/`, and a board under `planning/`.

## Bootstrap (one step)

```shell
./script/km-start.sh
```

That one command:

1. **Installs KM when it is missing.** With no built daemon in `KM_HOME`
   (default `~/.km/knowledge-management`) it clones knowledge-management there and runs its
   `scripts/install-km-desktop.sh --daemon` (Node 22+ and read access to the repo; no Rust,
   no app bundle). An existing build is used as is.
2. **Starts KM on this repo and opens the browser.** The daemon runs on the first free port of
   4790–4799 with this repo as the knowledge root, `planning/` as the board (git-ignored),
   `--no-config` and fleet off. Your browser opens `http://127.0.0.1:<port>/`.
3. **Asks which agent implements board items.** It lists the agent CLIs found on this machine
   (Claude Code, Grok, Codex) and saves your pick for this repo's KM only
   (`planning/autonomous/auto-implementer.json`). Next time it reuses the pick; delete that file
   to choose again.
4. **Opens these pages.** [`km-open.json`](../km-open.json) opens the [README](../README.md), this
   page, [the AO page](instrumentation/ao.md) and the board.
5. **Offers GitHub issues.** Say yes to see and edit this repo's GitHub issues on the KM board.
   It asks for the repository (default: `origin`) and a token (the `gh` CLI's, or one you paste).
   The token is stored in `~/.config/km/github/ai-demo-apps/`, never in this repo. Say no and KM
   keeps running; connect later in **KM Daemon → Configuration → Integrations**.

Running it again finds the running KM, opens the browser and asks nothing already answered.

## Everyday use

- **Read**: the Knowledge panel shows this repo's markdown; links between pages work.
- **Plan**: add cards on the board. They are files under `planning/`, local to your clone.
- **Build**: [[chat:build-app|Build a new app]] opens a chat with the prompt in
  [`km-chats/build-app.md`](../km-chats/build-app.md). Nothing is sent until you press Send.

## Settings

| Variable | Default | What it does |
| --- | --- | --- |
| `KM_HOME` | `~/.km/knowledge-management` | KM checkout to run (and install into) |
| `KM_PORT` | first free of 4790–4799 | daemon + UI port |
| `KM_IMPLEMENTER` | ask | agent id to use without asking (`claude`, `grok`, `codex`) |
| `KM_OPEN` | `open` / `xdg-open` | browser command; `none` to only print the URL |
| `KM_SESSIONS_ROOT` | none | sessions store to show, e.g. `~/.sessions` |
| `KM_INTERACTIVE` | when stdin is a terminal | `1` always prompt, `0` never |

KM is stopped like any process: the script prints the daemon's pid and log path.
