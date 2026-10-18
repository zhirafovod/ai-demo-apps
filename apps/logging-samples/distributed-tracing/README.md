# Splunk AO Distributed Tracing - Decorator Example

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao[middleware,openai]"` — extra: `middleware`, `openai`. Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/logging-samples/distributed-tracing) `examples/logging-samples/distributed-tracing` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/logging-samples/distributed-tracing`.

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

This example demonstrates distributed tracing across two services using Splunk AO's `@log` decorator.

## Architecture

- **Retrieval Service** (`retrieval_service.py`): A FastAPI service running on port 8000 that handles information retrieval
- **Orchestrator Service** (`main_run.py`): The main client that coordinates the RAG pipeline by calling the retrieval service

## Setup Instructions

### 1. Create and Activate Virtual Environment

```bash
# Navigate to the distributed-tracing example directory
cd examples/logging-samples/distributed-tracing

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate
```

### 2. Install Dependencies
Run

```bash
pip install -r requirements.txt
```



### 3. Configure Environment Variables
Your `.env` should look like this. Feel free to follow the `.env.example` and enter your credentials
```bash

# Required: Your Splunk AO API key
SPLUNK_AO_API_KEY="your-splunk-ao-api-key"

# Required: OpenAI API key
OPENAI_API_KEY="your-openai-api-key"

# Optional: Splunk AO project and log stream names
SPLUNK_AO_PROJECT="your-splunk-ao-project"
SPLUNK_AO_AGENT_STREAM=distributed-tracing-example

# Provide the console url below if you are not using app.galileo.ai
# SPLUNK_AO_CONSOLE_URL="your-splunk-ao-console-url"
```

### 4. Run the Services

You need to run both services in **separate terminal processes**.

#### Terminal 1: Start the Retrieval Service

```bash
# Make sure you're in the distributed-tracing example directory
# cd examples/logging-samples/distributed-tracing

# Activate venv (if not already activated)
# source venv/bin/activate

# Start the retrieval service on port 8000
uvicorn retrieval_service:app --reload --port 8000
```

You should see output like:
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

#### Terminal 2: Run the Orchestrator

```bash
# In a NEW terminal, navigate to the distributed-tracing example directory
cd examples/logging-samples/distributed-tracing

# Activate venv
source venv/bin/activate

# Run the orchestrator
python main_run.py
```

## Expected Output

When you run the orchestrator, you should see:

```
============================================================
Question: What did Galileo Galilei research?
============================================================
Answer: Galileo Galilei made scientific observations that transformed our understanding of the universe.
```
