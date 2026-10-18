# OpenTelemetry, zero-code

Zero-code instrumentation means the application source is not changed: an agent or launcher
wraps the process and installs instrumentation at startup, configured only by `OTEL_*` env vars.

- Python: `pip install opentelemetry-distro opentelemetry-exporter-otlp`,
  `opentelemetry-bootstrap -a install`, then `opentelemetry-instrument python app.py`.
- Java: `java -javaagent:opentelemetry-javaagent.jar -jar app.jar`.

Typical configuration: `OTEL_SERVICE_NAME`, `OTEL_EXPORTER_OTLP_ENDPOINT`,
`OTEL_EXPORTER_OTLP_PROTOCOL`, `OTEL_TRACES_EXPORTER`.

## What the apps here can show

| App | Zero-code part | Where those spans go |
| --- | --- | --- |
| [logging-samples/distributed-tracing-otel-python-java](../../apps/logging-samples/distributed-tracing-otel-python-java/README.md) | The **Java gateway** runs under the OpenTelemetry Java agent (`-javaagent:` in `java-service/Dockerfile`); it injects W3C `traceparent` into its HTTP call to the Python service | OTLP → the bundled OpenTelemetry Collector → AO (`otlphttp/splunk_ao` exporter). The Python service in the same app is *manual* setup ([otel-manual.md](otel-manual.md)) |
| [rag/elastic-chatbot-rag-app](../../apps/rag/elastic-chatbot-rag-app/README.md) | `opentelemetry-instrument python api/app.py` with the Elastic Distribution of OpenTelemetry (EDOT) Python, enabled by `OTEL_SDK_DISABLED=false` | The `OTEL_EXPORTER_OTLP_ENDPOINT` in `env.example`, which defaults to Elastic APM, **not** AO. Its AO traces come from the AO SDK's LangChain callback (`splunk-ao[langchain]`), not from the zero-code agent |

## What they cannot show

No app here runs a Python service under `opentelemetry-instrument` with its spans exported to AO.
The collector pattern above is how the repo routes zero-code (Java) spans to AO: point
`OTEL_EXPORTER_OTLP_ENDPOINT` at a collector whose exporter carries the AO credentials, and keep
those credentials out of the application. Building a Python zero-code app that exports to AO would
be a new app, not an existing one.
