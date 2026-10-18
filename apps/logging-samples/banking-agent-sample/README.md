# Banking agent with Agent Streams

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao[openai]"` — extra: `openai`. Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/logging-samples/banking-agent-sample) `examples/logging-samples/banking-agent-sample` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/logging-samples/banking-agent-sample`.

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

The sample runs three banking queries in one named session. `@log` captures the
agent workflow and simulated tools; the wrapped OpenAI client captures LLM calls.
The code follows the original sample's structure, including a module-level client,
`load_dotenv("../.env")`, and the original context manager around the three queries.
The tools use mock accounts and a demonstration eligibility rule.

## Configuration

Create `examples/logging-samples/.env` with:

```dotenv
OPENAI_API_KEY=your-openai-api-key
SPLUNK_AO_PROJECT=your-project-name
SPLUNK_AO_AGENT_STREAM=your-agent-stream-name
```

Add the credentials for **one** deployment:

- **Standalone:** `SPLUNK_AO_API_KEY` and `SPLUNK_AO_CONSOLE_URL`.
- **O11y Cloud:** `SPLUNK_AO_REALM` and `SPLUNK_AO_O11Y_TOKEN`.
  Session creation requires CRUD permissions on the ingest token or a separate
  `SPLUNK_AO_O11Y_API_TOKEN` with those permissions.

See the repository's [setup guide](../../../README.md#setup) for deployment details.

## Run

Run from the sample directory:

```shell
cd examples/logging-samples/banking-agent-sample
uv run sample_app.py
```

Running the example calls OpenAI and sends telemetry to the configured Splunk
Agent Observability deployment. Inspect the session in your project's Agent Stream
to compare tool selection and context adherence across the three queries.
