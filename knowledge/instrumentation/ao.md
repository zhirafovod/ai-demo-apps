# Instrumenting with the Splunk AO SDK

The Splunk Agent Observability (AO) Python SDK is the `splunk-ao` package on PyPI. Its source is
[splunk/splunk-ao-python](https://github.com/splunk/splunk-ao-python) (Apache-2.0). The apps in
this repo depend on the published package; none of them contains a copy of it.

## Install

```shell
pip install splunk-ao                       # base: SDK, @log, SplunkAOLogger, splunk_ao.otel
pip install "splunk-ao[openai]"             # OpenAI client wrapper (splunk_ao.openai / `from splunk_ao import openai`)
pip install "splunk-ao[langchain]"          # LangChain / LangGraph callback + middleware handlers
pip install "splunk-ao[crewai]"             # CrewAI handler (Python < 3.14)
pip install "splunk-ao[middleware]"         # Starlette tracing middleware (splunk_ao.middleware)
pip install "splunk-ao[distributed-tracing]" # configure_distributed_tracing(): FastAPI/Starlette, requests, httpx, aiohttp
pip install "splunk-ao[all]"                # everything above
```

Pick the extra that matches the integration the app imports. Each app README in `apps/` names
its extra; its `requirements.txt` / `pyproject.toml` already pins `splunk-ao[<extra>]`.

| Extra | Apps here that use it |
| --- | --- |
| *(none, base)* | google-adk, langgraph-open-telemetry, microsoft-agent-framework, pydantic-ai-support-agent, weather-vibes-agent, elevenlabs-chatbot, sample-project-chatbot/anthropic + azure-inference, dataset-experiments, experiments/multi-turn + upload_experiment, distributed-tracing-otel-python-java, log-mcp-calls, splunk-ao-logger |
| `openai` | minimal-agent-example, startup-simulator-3000, chatbot/basic-examples, sample-project-chatbot/openai-ollama, experiments/rag-and-tools, banking-agent-sample, openai-responses, rag/cli-rag-demo |
| `langchain` | healthcare-assistant, langchain-agent, langchain-middleware, langgraph-fsi-agent/after, langgraph-telecom-agent, langgraph, rag/elastic-chatbot-rag-app |
| `crewai` | agent/crewAI/research_crew |
| `middleware` (+`openai`) | logging-samples/distributed-tracing, DT_2.0/distributed-tracing |
| `distributed-tracing` (+`openai`) | DT_2.0/distributed-tracing-auto |

## The three env vars (on-prem / standalone AO)

| Variable | Meaning |
| --- | --- |
| `SPLUNK_AO_API_KEY` | AO API key (required) |
| `SPLUNK_AO_CONSOLE_URL` | AO console URL, e.g. `https://console.subdomain.yourcompany.com` (required) |
| `SPLUNK_AO_API_URL` | Custom API URL (optional) |

Splunk Observability (o11y) Cloud uses a different set instead: `SPLUNK_AO_REALM` and
`SPLUNK_AO_O11Y_TOKEN` (ingest), optionally `SPLUNK_AO_O11Y_API_TOKEN` (CRUD). The SDK derives
the console, API and OTLP endpoints from the realm, so on o11y Cloud do **not** set
`SPLUNK_AO_CONSOLE_URL` or `SPLUNK_AO_API_URL`.

**Do not mix on-prem and o11y Cloud variables.** The SDK detects the deployment from the
variables present and rejects an ambiguous mix.

Routing, shared by both deployments: `SPLUNK_AO_PROJECT` and `SPLUNK_AO_AGENT_STREAM`
(`SPLUNK_AO_LOG_STREAM` is a deprecated alias). `OTEL_SERVICE_NAME` names the service in APM.
`SPLUNK_AO_LOGGING_DISABLED=true` turns collection and export off. Keep real values in a local
`.env`; never commit it.

## What the SDK does vs. what the app code does

| The SDK does | The app code does |
| --- | --- |
| Reads the env vars above, authenticates, resolves project and agent stream | Sets the env vars (or calls `splunk_ao_context.init(project=..., agent_stream=...)`) |
| Owns an OpenTelemetry `TracerProvider` + `BatchSpanProcessor` and exports spans to AO over OTLP | Chooses *what* to trace: wraps a client, decorates functions, or attaches a handler |
| Wraps the OpenAI client (`from splunk_ao import openai`) so every call becomes an LLM span with model, tokens, finish reason | Uses the wrapped client instead of the plain `openai` module |
| Turns `@log` / `@log(span_type="tool" \| "retriever")` calls into spans; nested calls become children | Decorates its own agent, tool and retrieval functions |
| Turns LangChain / LangGraph / CrewAI callbacks into spans (`SplunkAOCallback`, middleware, CrewAI handler) | Passes the callback/handler into the framework |
| Propagates W3C trace context and the session across HTTP (`distributed-tracing`, `middleware` extras) | Calls `configure_distributed_tracing(app=app)` once at startup, or adds the middleware |
| Batches and exports in the background | Calls `splunk_ao_context.flush()` / `logger.terminate()` before a finite script exits |
| Datasets, experiments, prompts, metrics APIs (`splunk_ao.datasets`, `.experiments`, `.prompts`) | Builds the dataset and the function under test |

Minimal shape (from the SDK README):

```python
from splunk_ao import log, splunk_ao_context
from splunk_ao import openai           # needs splunk-ao[openai]

splunk_ao_context.init(project="my-project", agent_stream="dev")
client = openai.OpenAI()

@log
def answer(q: str) -> str:
    return client.chat.completions.create(
        model="gpt-4o-mini", messages=[{"role": "user", "content": q}]
    ).choices[0].message.content

print(answer("hello"))
splunk_ao_context.flush()
```

## Other instrumentation types

- [OpenTelemetry, manual setup](otel-manual.md) — the app builds a `TracerProvider` and adds
  instrumentors; spans reach AO through `splunk_ao.otel` or a plain OTLP exporter.
- [OpenTelemetry, zero-code](otel-zero-code.md) — an agent or `opentelemetry-instrument` wrapper,
  no code changes. Only part of one app here shows it.
