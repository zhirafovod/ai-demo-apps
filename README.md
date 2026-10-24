# ai-demo-apps

Runnable GenAI / agent demo apps that send traces to **Splunk Agent Observability (AO)**, plus a
short knowledge base on *how* each one is instrumented.

The apps are copied from the `examples/` directory of
[splunk/splunk-ao-python](https://github.com/splunk/splunk-ao-python) (Apache-2.0, see
[LICENSE](LICENSE) and [NOTICE](NOTICE)). They are kept separate from the instrumentation: this
repo contains **no SDK source**. Every app installs the published package
`splunk-ao[<extra>]` from PyPI through its own `requirements.txt` / `pyproject.toml`.

## Instrumentation knowledge

- [Splunk AO SDK](knowledge/instrumentation/ao.md) — install, extras, the env vars
  `SPLUNK_AO_API_KEY` / `SPLUNK_AO_CONSOLE_URL` / `SPLUNK_AO_API_URL`, what the SDK does vs. the app.
- [OpenTelemetry, manual setup](knowledge/instrumentation/otel-manual.md) — the app builds the
  `TracerProvider`; spans go to AO through `splunk_ao.otel` or plain OTLP.
- [OpenTelemetry, zero-code](knowledge/instrumentation/otel-zero-code.md) — Java agent /
  `opentelemetry-instrument`; what the apps here can and cannot show.

Do not mix on-prem (`SPLUNK_AO_API_KEY`, `SPLUNK_AO_CONSOLE_URL`, `SPLUNK_AO_API_URL`) and
o11y Cloud (`SPLUNK_AO_REALM`, `SPLUNK_AO_O11Y_TOKEN`) variables. Keep real values in a local
`.env` (git-ignored); every `.env.example` here holds placeholders only.

## Apps

| App | `splunk-ao` extra | Instrumentation |
| --- | --- | --- |
| [agent/crewAI/research_crew](apps/agent/crewAI/research_crew/README.md) | `crewai` | AO SDK (CrewAI handler) |
| [agent/google-adk](apps/agent/google-adk/README.md) | base | OTel manual + AO span processor |
| [agent/healthcare-assistant](apps/agent/healthcare-assistant/README.md) | `langchain` | AO SDK (LangChain/LangGraph) |
| [agent/langchain-agent](apps/agent/langchain-agent/README.md) | `langchain` | AO SDK (LangChain callback) |
| [agent/langchain-middleware](apps/agent/langchain-middleware/README.md) | `langchain` | AO SDK (LangChain middleware) |
| [agent/langgraph-fsi-agent/before](apps/agent/langgraph-fsi-agent/before/README.md) | — | none (baseline) |
| [agent/langgraph-fsi-agent/after](apps/agent/langgraph-fsi-agent/after/README.md) | `langchain` | AO SDK |
| [agent/langgraph-open-telemetry](apps/agent/langgraph-open-telemetry/README.md) | base | OTel manual + AO span processor |
| [agent/langgraph-otel](apps/agent/langgraph-otel/README.md) | — (no SDK) | OTel manual, plain OTLP |
| [agent/langgraph-telecom-agent](apps/agent/langgraph-telecom-agent/README.md) | `langchain` | AO SDK |
| [agent/langgraph-traceloop](apps/agent/langgraph-traceloop/README.md) | — (no SDK) | OTel manual via Traceloop |
| [agent/microsoft-agent-framework](apps/agent/microsoft-agent-framework/README.md) | base | OTel manual + AO span processor |
| [agent/minimal-agent-example](apps/agent/minimal-agent-example/README.md) | `openai` | AO SDK |
| [agent/pydantic-ai-support-agent](apps/agent/pydantic-ai-support-agent/README.md) | base | OTel manual + AO span processor |
| [agent/startup-simulator-3000](apps/agent/startup-simulator-3000/README.md) | `openai` | AO SDK |
| [agent/strands-agents](apps/agent/strands-agents/README.md) | — (no SDK) | OTel manual, plain OTLP |
| [agent/weather-vibes-agent](apps/agent/weather-vibes-agent/README.md) | base | AO SDK |
| [chatbot/basic-examples](apps/chatbot/basic-examples/README.md) | `openai` | AO SDK |
| [chatbot/elevenlabs-chatbot](apps/chatbot/elevenlabs-chatbot/README.md) | base | AO SDK |
| [chatbot/sample-project-chatbot/anthropic](apps/chatbot/sample-project-chatbot/anthropic/README.md) | base | AO SDK |
| [chatbot/sample-project-chatbot/azure-inference](apps/chatbot/sample-project-chatbot/azure-inference/README.md) | base | AO SDK |
| [chatbot/sample-project-chatbot/openai-ollama](apps/chatbot/sample-project-chatbot/openai-ollama/README.md) | `openai` | AO SDK |
| [dataset-experiments](apps/dataset-experiments/README.md) | base | AO SDK (datasets, experiments) |
| [experiments/multi-turn](apps/experiments/multi-turn/README.md) | base | AO SDK (experiments) |
| [experiments/rag-and-tools](apps/experiments/rag-and-tools/README.md) | `openai` | AO SDK (experiments) |
| [experiments/upload_experiment](apps/experiments/upload_experiment/README.md) | base | AO SDK (experiments) |
| [langgraph](apps/langgraph/README.md) | `langchain` | AO SDK (LangChain callback) |
| [logging-samples/banking-agent-sample](apps/logging-samples/banking-agent-sample/README.md) | `openai` | AO SDK |
| [logging-samples/distributed-tracing](apps/logging-samples/distributed-tracing/README.md) | `openai,middleware` | AO SDK (manual header propagation) |
| [logging-samples/DT_2.0/distributed-tracing](apps/logging-samples/DT_2.0/distributed-tracing/README.md) | `openai,middleware` | AO SDK |
| [logging-samples/DT_2.0/distributed-tracing-auto](apps/logging-samples/DT_2.0/distributed-tracing-auto/README.md) | `openai,distributed-tracing` | AO SDK (`configure_distributed_tracing`) |
| [logging-samples/distributed-tracing-otel-python-java](apps/logging-samples/distributed-tracing-otel-python-java/README.md) | base | OTel zero-code (Java) + OTel manual (Python) via collector |
| [logging-samples/log-mcp-calls](apps/logging-samples/log-mcp-calls/README.md) | base | AO SDK |
| [logging-samples/openai-responses](apps/logging-samples/openai-responses/README.md) | `openai` | AO SDK |
| [logging-samples/splunk-ao-logger](apps/logging-samples/splunk-ao-logger/README.md) | base | AO SDK (`SplunkAOLogger`) |
| [rag/cli-rag-demo](apps/rag/cli-rag-demo/README.md) | `openai` | AO SDK |
| [rag/elastic-chatbot-rag-app](apps/rag/elastic-chatbot-rag-app/README.md) | `langchain` | AO SDK; OTel zero-code to Elastic APM |

## Open in KM

One step installs (when missing), starts and bootstraps
[knowledge-management](https://github.com/unpolarize/knowledge-management) with this repo as the
knowledge root:

```shell
./script/km-start.sh
```

It builds KM into `KM_HOME` (default `~/.km/knowledge-management`) if there is no built daemon,
starts it on a free port in 4790–4799 (`--no-config`, fleet off, `<repo>/planning` as a git-ignored
board), opens your browser on it, asks which local agent CLI (Claude Code, Grok, Codex) the
implementer uses, and offers to connect this repo's GitHub issues. The token stays in
`~/.config/km/github/ai-demo-apps/`, never in the repo. [`km-open.json`](km-open.json) opens this
README, [How to use](knowledge/how-to-use.md), [the AO page](knowledge/instrumentation/ao.md) and
the board. Details and settings: [How to use this repo in KM](knowledge/how-to-use.md).

- [[chat:build-app|Build a new app]] — in KM, opens a chat with the prompt from
  [`km-chats/build-app.md`](km-chats/build-app.md) (scaffold another demo app here, separate from
  the instrumentation package). Nothing is sent until you press Send.
