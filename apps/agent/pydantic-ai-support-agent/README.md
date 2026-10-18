# PydanticAI Example Project

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao"` — extra: none (base package). Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** OpenTelemetry manual setup with the AO span processor ([otel-manual](../../../knowledge/instrumentation/otel-manual.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/agent/pydantic-ai-support-agent) `examples/agent/pydantic-ai-support-agent` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/agent/pydantic-ai-support-agent`.

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

This is an example project demonstrating how to use Splunk AO with PydanticAI. It showcases an enterprise customer support agent with tools for looking up customer data, checking order status, creating support tickets, and processing refunds.

The example uses the Splunk AO SDK's built-in OpenTelemetry support combined with PydanticAI's native instrumentation to send traces to Splunk AO for observability.

## Getting Started

To get started with this project, you'll need to have Python 3.11 or later installed. You can then install the required dependencies using uv:

```bash
uv sync
```

## Usage

Once the dependencies are installed, you can run the example application:

```bash
uv run src/main.py
```

## Project Structure

The project structure is as follows:

```
pydantic-ai-support-agent/
├── src/                 # Main application files
│   └── main.py
├── pyproject.toml       # Project configuration file
├── README.md            # Project documentation
└── .env.example         # List of environment variables
```
