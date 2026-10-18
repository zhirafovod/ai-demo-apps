# LangGraph + OpenTelemetry + Splunk AO Integration

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao"` — extra: none (base package). Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** OpenTelemetry manual setup with the AO span processor ([otel-manual](../../../knowledge/instrumentation/otel-manual.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/agent/langgraph-open-telemetry) `examples/agent/langgraph-open-telemetry` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/agent/langgraph-open-telemetry`.

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

This example demonstrates how to add comprehensive observability to your LangGraph AI workflows using OpenTelemetry and Splunk AO. You'll get detailed traces showing the complete execution flow, LLM calls, token usage, and input/output data.

## What are these tools?

**OpenTelemetry** is an observability framework that creates traces showing what functions ran, their timing, and data flow through your application. The **OpenTelemetry instrumentation libraries** automatically instrument AI frameworks like LangChain and OpenAI. **Splunk AO** provides a sophisticated platform for visualizing and analyzing your AI application traces.

For detailed explanations and advanced patterns, see the [LangGraph OpenTelemetry cookbook](https://agent-observability-docs.splunk.com/cookbooks/features/integrations/langgraph-otel-cookbook)

## Quick start

### Prerequisites

- Python 3.12+
- [UV package manager](https://docs.astral.sh/uv/getting-started/installation/)
- [Splunk AO account](https://app.galileo.ai) (free)
- OpenAI API key

### Installation

```bash
# Clone and navigate
git clone https://github.com/rungalileo/sdk-examples
cd sdk-examples/python/agent/langgraph-open-telemetry

# Install dependencies
uv sync

# Create environment file
cp .env.example .env
# Edit .env with your API keys (see below)
```

### Environment variables

Create a `.env` file in the project root with the following variables:

```bash
# Your Splunk AO API key (get from https://app.galileo.ai/settings/api-keys)
SPLUNK_AO_API_KEY=your_splunk_ao_api_key_here

# Your Splunk AO project name
SPLUNK_AO_PROJECT=your_project_name

# Log stream for organizing traces
SPLUNK_AO_AGENT_STREAM=langgraph

# Splunk AO console URL (if using a custom deployment is different than https://app.galileo.ai)
SPLUNK_AO_CONSOLE_URL=https://app.galileo.ai

# Your OpenAI API key
OPENAI_API_KEY=your_openai_api_key_here
```

| Variable            | Required | Description                                                                    |
| ------------------- | -------- | ------------------------------------------------------------------------------ |
| `SPLUNK_AO_API_KEY`   | Yes      | Your Splunk AO API key from [settings](https://app.galileo.ai/settings/api-keys) |
| `SPLUNK_AO_PROJECT`   | Yes      | Splunk AO project name (create one in your dashboard)                            |
| `SPLUNK_AO_AGENT_STREAM` | Yes      | Log stream name for organizing traces (default: "default")                     |
| `OPENAI_API_KEY`    | Yes      | Your OpenAI API key from [OpenAI](https://platform.openai.com/api-keys)        |

### Run

```bash
uv run python main.py
```

This runs a question-answering LangGraph workflow with comprehensive OpenTelemetry tracing. Check your Splunk AO project for detailed traces!

## What's included

- **`main.py`** - Complete LangGraph workflow with OpenTelemetry tracing
- **`pyproject.toml`** - All dependencies managed via UV
- **`.env.example`** - Example environment variables (copy to `.env` and add your API keys)
- **`README.md`** - This comprehensive guide

## Learn more

- [LangGraph OpenTelemetry cookbook](https://agent-observability-docs.splunk.com/cookbooks/features/integrations/langgraph-otel-cookbook)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [OpenTelemetry Python](https://opentelemetry.io/docs/instrumentation/python/)
- [Splunk AO Documentation](https://agent-observability-docs.splunk.com/)
- [UV Package Manager](https://docs.astral.sh/uv/)
