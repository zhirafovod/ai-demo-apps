# Strands Agents + OpenTelemetry Example Project

## Splunk AO setup (ai-demo-apps)

- **Install:** Does **not** use the `splunk-ao` package (no extra). It sends OTLP to AO with the API key in the exporter headers.
- **Instrumentation:** OpenTelemetry, manual setup in code; exports OTLP straight to AO without the `splunk-ao` package. See [../../../knowledge/instrumentation/otel-manual.md](../../../knowledge/instrumentation/otel-manual.md).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/agent/strands-agents) `examples/agent/strands-agents` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/agent/strands-agents`.

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

This is an example project demonstrating how to use Splunk AO with the [Strands Agent SDK](https://strandsagents.com/latest/), using AWS Bedrock as the LLM provider. This uses the simple [quickstart from the Strands Agents documentation](https://strandsagents.com/latest/documentation/docs/user-guide/quickstart/), and adds Splunk AO logging.

## Getting Started

To get started with this project, you'll need to have Python 3.10 or later installed. You can then install the required dependencies in a virtual environment:

```bash
pip install -r requirements.txt
```

## Configure environment variables

You will need to configure environment variables to use this project. Copy the `.env.example` file to `.env`, then update the environment variables in the `.env` file with your AWS and Splunk AO values:

```ini
# AWS environment variables
AWS_BEARER_TOKEN_BEDROCK=

# Splunk AO environment variables
# SPLUNK_AO_API_ENDPOINT=    # Optional, only set this if you are using a custom Splunk AO deployment
SPLUNK_AO_API_KEY=
SPLUNK_AO_PROJECT=
SPLUNK_AO_AGENT_STREAM=
```

For the `SPLUNK_AO_API_ENDPOINT`, you only need to set this if you are using a custom Splunk AO deployment. There is no need to set this if you ae using [app.galileo.ai](https://app.galileo.ai). This endpoint is different to the console URL that you would normally use. See the [Splunk AO OpenTelemetry documentation](https://agent-observability-docs.splunk.com/sdk-api/third-party-integrations/opentelemetry-and-openinference#self-hosted-deployments:~:text=Self%2Dhosted%20deployments%3A%20Set%20the%20OTel%20endpoint) for more details.

## Usage

Once the dependencies are installed, you can run the example application:

```bash
python agent.py
```

Traces will be captured and logged to Splunk AO.

## Project Structure

The project structure is as follows:

```folder
strands-agents/
├─ env.example         # List of environment variables
├── agent.py           # The main agent application
├── requirements.txt   # Python project requirements
└── README.md          # Project documentation
```
