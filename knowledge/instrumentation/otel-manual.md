# OpenTelemetry, manual setup

"Manual" here means the application code configures OpenTelemetry itself: it creates a
`TracerProvider`, attaches an exporter or span processor, and turns on instrumentation libraries
(OpenInference, `opentelemetry-instrumentation-*`, or a framework's built-in OTel switch). The
instrumentors then create spans automatically, and the code may add its own spans.

There are two ways the apps here get those spans into AO.

## 1. OTel + the AO span processor (`splunk-ao`, base package)

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from splunk_ao import otel

provider = TracerProvider()
otel.add_splunk_ao_span_processor(provider)   # reads SPLUNK_AO_* env vars, exports to AO
trace.set_tracer_provider(provider)
SomeInstrumentor().instrument(tracer_provider=provider)
...
provider.shutdown()   # the app owns this provider
```

The SDK supplies only the export side (endpoint, auth, project/agent-stream routing, batching).
The env vars and the "do not mix on-prem and o11y Cloud variables" rule are the same as in
[ao.md](ao.md). No extra is needed.

| App | What instruments it |
| --- | --- |
| [agent/langgraph-open-telemetry](../../apps/agent/langgraph-open-telemetry/README.md) | `opentelemetry-instrumentation-langchain` + `opentelemetry-instrumentation-openai-v2` |
| [agent/google-adk](../../apps/agent/google-adk/README.md) | `openinference-instrumentation-google-adk` |
| [agent/microsoft-agent-framework](../../apps/agent/microsoft-agent-framework/README.md) | the framework's `enable_instrumentation()` |
| [agent/pydantic-ai-support-agent](../../apps/agent/pydantic-ai-support-agent/README.md) | `Agent.instrument_all()` |
| [logging-samples/distributed-tracing-otel-python-java](../../apps/logging-samples/distributed-tracing-otel-python-java/README.md) (Python service) | OpenInference LangChain + OpenAI, FastAPI instrumentor, plus a hand-made AO `RetrieverSpan`; exports OTLP to a collector |

## 2. Plain OTLP to AO, no `splunk-ao` package

The app builds an OTLP/HTTP exporter itself and puts the AO credentials in its headers
(`Splunk-AO-API-Key`, `project`, `logstream`). These apps do not install `splunk-ao` at all.
Each sets the AO OTLP endpoint itself (`<api url>/otel/v1/traces` in langgraph-otel,
`SPLUNK_AO_API_ENDPOINT` in strands-agents, `TRACELOOP_BASE_URL` + `TRACELOOP_HEADERS` in
langgraph-traceloop), so they show the on-prem / API-key style only, not o11y Cloud realm routing.

| App | What instruments it |
| --- | --- |
| [agent/langgraph-otel](../../apps/agent/langgraph-otel/README.md) | OpenInference LangChain + OpenAI, `OTLPSpanExporter` with AO headers |
| [agent/strands-agents](../../apps/agent/strands-agents/README.md) | Strands' built-in `StrandsTelemetry`, OTLP endpoint + headers from env |
| [agent/langgraph-traceloop](../../apps/agent/langgraph-traceloop/README.md) | Traceloop / OpenLLMetry `Traceloop.init(...)` pointed at AO |

The collector variant: in `distributed-tracing-otel-python-java` both services send plain OTLP to
an OpenTelemetry Collector, and only the collector's `otlphttp/splunk_ao` exporter holds the AO
credentials (`otel-collector/config.yaml`).

## What the other apps cannot show

Every other app instruments with the AO SDK directly (wrappers, `@log`, handlers) and does not
build its own OTel pipeline; see [ao.md](ao.md).
