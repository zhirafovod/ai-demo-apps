# LangChain Middleware Example

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao[langchain]"` — extra: `langchain`. Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/agent/langchain-middleware) `examples/agent/langchain-middleware` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/agent/langchain-middleware`.

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

This example demonstrates how to use `SplunkAOMiddleware` to automatically log LangChain agent executions without manual callback setup.

## Overview

`SplunkAOMiddleware` provides drop-in logging for LangGraph agents. It automatically captures:

- Agent lifecycle events (start/completion)
- Model calls with prompts, responses, and metadata
- Tool calls with function names, arguments, and outputs

## Setup

1. Install dependencies:

```bash
pip install -r requirements.txt
```

1. Configure environment variables:

```bash
cp .env.example .env
# Edit .env with your API keys
```

## Running the Example

```bash
python main.py
```

The agent will:

1. Create a LangChain agent with two tools (weather and stock price)
2. Invoke the agent with a question requiring both tools. Specifically, ""What's the weather like in San Francisco and what's the current stock price of Apple?"
3. Automatically log all interactions to Splunk AO using middleware

## What Gets Logged

The middleware creates a hierarchical trace with:

- **Agent node**: Tracks overall execution with input/output state
- **LLM nodes**: Logs each model call with prompts, responses, and timing
- **Tool nodes**: Records tool invocations with arguments and outputs

## Key Features

- **Zero configuration**: Add middleware to your agent and it works automatically
- **Async support**: Works seamlessly with both sync and async execution
- **Flexible**: Can use custom loggers and control trace management
- **Comprehensive**: Captures all relevant execution details

## Comparison with Callbacks

| Feature    | SplunkAOMiddleware      | SplunkAOCallback        |
| ---------- | ---------------------- | ---------------------- |
| Setup      | Add to middleware list | Pass to each component |
| Complexity | Simple                 | Manual setup required  |
| Best for   | LangGraph agents       | Complex LangChain apps |

For more details, see the [middleware documentation](https://agent-observability-docs.splunk.com/sdk-api/third-party-integrations/langchain/middleware).
