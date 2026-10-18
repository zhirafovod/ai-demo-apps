# Google ADK + OpenTelemetry Example Project

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao"` — extra: none (base package). Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** OpenTelemetry manual setup with the AO span processor ([otel-manual](../../../knowledge/instrumentation/otel-manual.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/agent/google-adk) `examples/agent/google-adk` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/agent/google-adk`.

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

This is an example project demonstrating how to use Splunk AO with the Google ADK. This uses the simple [quickstart from the Google ADK documentation](https://google.github.io/adk-docs/get-started/python/#create-an-agent-project), and adds Splunk AO logging.

## Getting Started

To get started with this project, you'll need to have Python 3.10 or later installed. You can then install the required dependencies in a virtual environment:

```bash
pip install -r requirements.txt
```

## Configure environment variables

You will need to configure environment variables to use this project. Copy the `.env.example` file to `.env`, then update the environment variables in the `.env` file with your Google and Splunk AO values:

```ini
# Gemini environment variables
GOOGLE_GENAI_USE_VERTEXAI=0
GOOGLE_API_KEY=

# Splunk AO environment variables
SPLUNK_AO_API_ENDPOINT=
SPLUNK_AO_API_KEY=
SPLUNK_AO_PROJECT=
SPLUNK_AO_AGENT_STREAM=
```

For the `SPLUNK_AO_API_ENDPOINT`, this is different to the console URL that you would normally use. If you are using `app.galileo.ai` for example, the endpoint is `https://api.galileo.ai/otel/v1/traces`.

See the [Splunk AO OTel and OpenInference documentation](https://agent-observability-docs.splunk.com/sdk-api/third-party-integrations/opentelemetry-and-openinference) for more details.

## Usage

Once the dependencies are installed, you can run the example application using the `adk` command:

```bash
adk run my_agent
```

Traces will be captured and logged to Splunk AO.

## Project Structure

The project structure is as follows:

```folder
google-adk/
├── my_agent/          # The main agent application
│   ├── __init__.py
│   ├── agent.py
│   └── env.example    # List of environment variables
├── requirements.txt   # Python project requirements
└── README.md          # Project documentation
```
