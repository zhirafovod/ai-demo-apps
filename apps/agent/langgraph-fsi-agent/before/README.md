# agent/langgraph-fsi-agent/before

## Splunk AO setup (ai-demo-apps)

- **Install:** No Splunk AO package: this version deliberately has no instrumentation.
- **Instrumentation:** None. This is the uninstrumented *before* version; compare with [`../after`](../after/README.md), which adds the AO SDK.
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/agent/langgraph-fsi-agent/before) `examples/agent/langgraph-fsi-agent/before` (Apache-2.0, see [LICENSE](../../../../LICENSE) and [NOTICE](../../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/agent/langgraph-fsi-agent/before`.

Environment variables (pick **one** deployment, never both):

| Deployment | Variables |
| --- | --- |
| On-prem / standalone AO | `SPLUNK_AO_API_KEY` (required), `SPLUNK_AO_CONSOLE_URL` (required), `SPLUNK_AO_API_URL` (optional) |
| Splunk Observability (o11y) Cloud | `SPLUNK_AO_REALM`, `SPLUNK_AO_O11Y_TOKEN` (and optionally `SPLUNK_AO_O11Y_API_TOKEN`) |

Do not mix on-prem and o11y Cloud variables: the SDK picks the deployment from the variables it
finds and rejects an ambiguous mix. On o11y Cloud do not set `SPLUNK_AO_CONSOLE_URL` or
`SPLUNK_AO_API_URL`. Routing: `SPLUNK_AO_PROJECT` and `SPLUNK_AO_AGENT_STREAM`.
Copy `.env.example` (or `env.example`) to `.env` and fill it in locally; `.env` is git-ignored and
must never be committed.

## Run

See the entry-point script(s) in this directory. Install the requirements in a fresh virtualenv, fill `.env` from `.env.example`, then run the main script with `python`.
