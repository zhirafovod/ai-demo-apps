# Terminal-based RAG Demo

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao[openai]"` — extra: `openai`. Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/rag/cli-rag-demo) `examples/rag/cli-rag-demo` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/rag/cli-rag-demo`.

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

This is a terminal-based Retrieval-Augmented Generation (RAG) demo that uses the Splunk AO SDK for observability.

## Features

- Interactive terminal UI with rich text formatting
- Simulated document retrieval with the `@log(span_type="retriever")` decorator for Splunk AO observability
- OpenAI GPT-4o integration for answering questions

## Prerequisites

- Python 3.11+
- OpenAI API key
- Splunk AO API key (optional, for observability)

## Installation

1. Create a virtual environment:

```bash
python -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Set up environment variables by creating a `.env` file:

```
# Splunk AO Environment Variables
SPLUNK_AO_API_KEY=your-splunk-ao-api-key             # Your Splunk AO API key.
SPLUNK_AO_PROJECT=your-splunk-ao-project-name        # Your Splunk AO project name.
SPLUNK_AO_AGENT_STREAM=your-splunk-ao-log-stream       # The name of the log stream you want to use for logging.

# Provide the console url below if you are using a custom deployment, and not using app.galileo.ai
# SPLUNK_AO_CONSOLE_URL=your-splunk-ao-console-url   # Optional if you are using a hosted version of Splunk AO

OPENAI_API_KEY=your-openai-api-key
```

## Usage

Run the application:

```bash
python app.py
```

The application will:
1. Prompt you to enter a question
2. Retrieve relevant documents (simulated in this demo)
3. Generate an answer using OpenAI's GPT-4o
4. Display the answer
5. Ask if you want to continue with another question

To exit the application, type `exit`, `quit`, or `q` when prompted for a question, or press `Ctrl+C` at any time.

## Understanding the Splunk AO Integration

This demo uses the Splunk AO SDK for observability:

- The `@log(span_type="retriever")` decorator is applied to the `retrieve_documents` function
- This allows Splunk AO to track and analyze the retrieval process
- The `span_type="retriever"` parameter specifically identifies this as a retrieval operation in the observability pipeline

When Splunk AO logging is enabled (by setting the appropriate environment variables), you can view detailed metrics and traces in the Splunk AO console.

## Customization

To implement a real retrieval system:
1. Replace the simulated document list in `retrieve_documents()` with actual vector database queries
2. Keep the `@log(span_type="retriever")` decorator to maintain observability
3. Adjust the prompt in the `rag()` function as needed for your specific use case 