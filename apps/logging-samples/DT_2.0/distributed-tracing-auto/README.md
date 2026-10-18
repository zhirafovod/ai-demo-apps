## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao[distributed-tracing,openai]"` — extra: `distributed-tracing`, `openai`. Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/logging-samples/DT_2.0/distributed-tracing-auto) `examples/logging-samples/DT_2.0/distributed-tracing-auto` (Apache-2.0, see [LICENSE](../../../../LICENSE) and [NOTICE](../../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/logging-samples/DT_2.0/distributed-tracing-auto`.

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

## Configure

Copy `.env.example` to `.env` and set the credentials and project and agentstream.

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Start the retrieval service:
```bash
uvicorn retrieval_service:app --port 8000
```

Then run the orchestrator:
```bash
python main_run.py
```

### Observe batching before the root ends

To demonstrate incremental export, add these values to an existing `.env`:

```dotenv
OTEL_BSP_SCHEDULE_DELAY="1000"
BATCH_DEMO_SLEEP_SECONDS="20"
```

`OTEL_BSP_SCHEDULE_DELAY` is in milliseconds and is read when each batch span
processor is created. After the distributed retrieval call returns, the example
prints a batching-demo message and keeps the orchestrator root active for 20
seconds.

Set`BATCH_DEMO_SLEEP_SECONDS="0"` to disable the pause.

The local tree remains the same as the baseline. Completed children enter the
batch processor at their own end callbacks, so no per-trace flush is needed.
